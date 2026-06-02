"""WebSocket server for client connections."""

import asyncio
import errno
import ipaddress
import json
import logging
import ssl
import sys
from collections import deque
from dataclasses import dataclass
from pathlib import Path
from typing import Callable, Coroutine

import websockets
from pydantic import ValidationError
from websockets.asyncio.server import serve, ServerConnection

from .packet_models import SERVER_TO_CLIENT_PACKET_ADAPTER

PACKET_LOGGER = logging.getLogger("playpalace.packets")


# Connection / flood backstops. These are coarse abuse limits, not precise
# per-feature throttles (e.g. chat has its own tighter app-layer limit).
DEFAULT_MAX_CONNECTIONS = 1000
DEFAULT_MAX_CONNECTIONS_PER_IP = 20
DEFAULT_UNAUTH_TIMEOUT_SECONDS = 30.0
PACKET_RATE_WINDOW_SECONDS = 10.0
MAX_PACKETS_PER_WINDOW = 300


@dataclass
class ClientConnection:
    """Represents a connected client."""

    websocket: ServerConnection
    address: str
    username: str | None = None
    authenticated: bool = False
    replaced: bool = False
    client_type: str = ""
    platform: str = ""
    ip_address: str = ""

    async def send(self, packet: dict) -> None:
        """Send a packet to this client."""
        try:
            packet_model = SERVER_TO_CLIENT_PACKET_ADAPTER.validate_python(packet)
            payload = packet_model.model_dump(exclude_none=True)
        except ValidationError as exc:
            identifier = self.username or self.address
            PACKET_LOGGER.warning(
                "Refusing to send invalid packet (type=%s) to %s: %s",
                packet.get("type", "?"),
                identifier,
                exc,
            )
            return

        try:
            await self.websocket.send(json.dumps(payload))
        except websockets.exceptions.ConnectionClosed:
            identifier = self.username or self.address
            PACKET_LOGGER.debug(
                "Dropped packet type=%s to disconnected client %s",
                payload.get("type", "?"),
                identifier,
            )

    async def close(self) -> None:
        """Close this connection."""
        try:
            await self.websocket.close()
        except (OSError, RuntimeError, websockets.exceptions.ConnectionClosed) as exc:
            PACKET_LOGGER.debug("Failed to close websocket: %s", exc)


class WebSocketServer:
    """
    Async WebSocket server for handling client connections.

    The server is async, but game logic is synchronous. Messages are
    queued and processed synchronously, then responses are sent async.
    """

    def __init__(
        self,
        host: str = "::",
        port: int = 8000,
        on_connect: Callable[[ClientConnection], Coroutine] | None = None,
        on_disconnect: Callable[[ClientConnection], Coroutine] | None = None,
        on_message: Callable[[ClientConnection, dict], Coroutine] | None = None,
        ssl_cert: str | Path | None = None,
        ssl_key: str | Path | None = None,
        max_message_size: int | None = None,
        max_connections: int = DEFAULT_MAX_CONNECTIONS,
        max_connections_per_ip: int = DEFAULT_MAX_CONNECTIONS_PER_IP,
        unauth_timeout_seconds: float = DEFAULT_UNAUTH_TIMEOUT_SECONDS,
    ):
        self.host = host
        self.port = port
        self._on_connect = on_connect
        self._on_disconnect = on_disconnect
        self._on_message = on_message
        self._clients: dict[str, ClientConnection] = {}
        self._username_to_client: dict[str, ClientConnection] = {}
        self._server = None
        self._running = False
        self._ssl_context = None
        self._max_message_size = max_message_size
        self._max_connections = max_connections
        self._max_connections_per_ip = max_connections_per_ip
        self._unauth_timeout_seconds = unauth_timeout_seconds

        # Configure SSL if certificates provided
        if ssl_cert and ssl_key:
            self._ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
            try:
                self._ssl_context.load_cert_chain(str(ssl_cert), str(ssl_key))
            except Exception as exc:  # pylint: disable=broad-except
                print(
                    f"ERROR: Failed to load TLS certificate or key ({ssl_cert}, {ssl_key}): {exc}",
                    file=sys.stderr,
                )
                raise SystemExit(1) from exc

    @property
    def clients(self) -> dict[str, ClientConnection]:
        """Get all connected clients keyed by address."""
        return self._clients

    async def start(self) -> None:
        """Start the WebSocket server."""
        self._running = True
        # Manually enter the context manager to control lifecycle
        try:
            self._server = await serve(
                self._handle_client,
                self.host,
                self.port,
                ssl=self._ssl_context,
                max_size=self._max_message_size,
            ).__aenter__()
        except OSError as exc:
            print(
                f"ERROR: Failed to bind WebSocket server on {self.host}:{self.port}: {exc}",
                file=sys.stderr,
            )
            if exc.errno in (errno.EADDRINUSE, 48, 10048):
                print(
                    "Hint: That port is already in use. "
                    "If another PlayPalace server is running, stop it or choose a new port.",
                    file=sys.stderr,
                )
                print(
                    "To find the process: `lsof -i :{port}` or `ss -ltnp | rg :{port}`".format(
                        port=self.port
                    ),
                    file=sys.stderr,
                )
            raise SystemExit(1) from exc

        protocol = "wss" if self._ssl_context else "ws"
        print(f"WebSocket server started on {protocol}://{self.host}:{self.port}")

    async def stop(self) -> None:
        """Stop the WebSocket server."""
        self._running = False
        if self._server:
            self._server.close()
            await self._server.wait_closed()

        # Close all client connections
        for client in list(self._clients.values()):
            await client.close()
        self._clients.clear()

    @staticmethod
    def _is_trusted_proxy(ip: str) -> bool:
        """Whether forwarded headers from this peer should be believed.

        The only thing that connects to this server is the reverse proxy
        (Traefik) over a private Docker network, so forwarded headers are
        trustworthy only when the immediate peer is a private or loopback
        address. A direct public connection could otherwise spoof
        ``X-Forwarded-For`` to defeat per-IP rate limiting.
        """
        try:
            addr = ipaddress.ip_address(ip)
        except ValueError:
            return False
        return addr.is_private or addr.is_loopback

    @staticmethod
    def _extract_real_ip(websocket: ServerConnection) -> str:
        """Extract the real client IP from proxy headers, falling back to the socket address."""
        socket_ip = websocket.remote_address[0] if websocket.remote_address else "unknown"
        # Only believe forwarded headers from a trusted (private/loopback) peer.
        if not WebSocketServer._is_trusted_proxy(socket_ip):
            return socket_ip
        headers = getattr(websocket, "request", None)
        if headers is None:
            return socket_ip
        request_headers = getattr(headers, "headers", None)
        if request_headers is None:
            return socket_ip
        forwarded_for = request_headers.get("X-Forwarded-For")
        if forwarded_for:
            return forwarded_for.split(",")[0].strip()
        real_ip = request_headers.get("X-Real-IP")
        if real_ip:
            return real_ip.strip()
        return socket_ip

    async def _enforce_auth_timeout(self, client: ClientConnection) -> None:
        """Close a connection that hasn't authenticated within the grace period."""
        try:
            await asyncio.sleep(self._unauth_timeout_seconds)
        except asyncio.CancelledError:
            return
        if not client.authenticated:
            PACKET_LOGGER.warning(
                "Closing %s: no authentication within %ss",
                client.ip_address, self._unauth_timeout_seconds,
            )
            try:
                await client.close()
            except Exception:
                pass

    async def _handle_client(self, websocket: ServerConnection) -> None:
        """Handle a client connection."""
        address = f"{websocket.remote_address[0]}:{websocket.remote_address[1]}"
        real_ip = self._extract_real_ip(websocket)

        # Refuse, before registering, if we're at capacity globally or per-IP.
        if len(self._clients) >= self._max_connections:
            PACKET_LOGGER.warning("Connection from %s refused: server at capacity", real_ip)
            await websocket.close(code=1013, reason="server at capacity")
            return
        per_ip = sum(1 for c in self._clients.values() if c.ip_address == real_ip)
        if per_ip >= self._max_connections_per_ip:
            PACKET_LOGGER.warning("Connection from %s refused: too many connections", real_ip)
            await websocket.close(code=1013, reason="too many connections")
            return

        client = ClientConnection(websocket=websocket, address=address, ip_address=real_ip)
        self._clients[address] = client

        # Close the socket if it never authenticates, and cap inbound packet rate.
        auth_timeout_task = asyncio.create_task(self._enforce_auth_timeout(client))
        packet_times: deque[float] = deque()
        loop = asyncio.get_running_loop()

        try:
            if self._on_connect:
                await self._on_connect(client)

            async for message in websocket:
                now = loop.time()
                packet_times.append(now)
                while packet_times and packet_times[0] < now - PACKET_RATE_WINDOW_SECONDS:
                    packet_times.popleft()
                if len(packet_times) > MAX_PACKETS_PER_WINDOW:
                    identifier = client.username or client.address
                    PACKET_LOGGER.warning("Packet flood from %s; closing connection", identifier)
                    await websocket.close(code=1008, reason="rate limit exceeded")
                    break

                try:
                    packet = json.loads(message)
                    if self._on_message:
                        await self._on_message(client, packet)
                except json.JSONDecodeError:
                    identifier = client.username or client.address
                    PACKET_LOGGER.warning("Malformed JSON from %s", identifier)
                except Exception:
                    # Safety net: log and continue so the connection survives.
                    # The server layer should catch and handle errors before
                    # they reach here, but this prevents silent disconnects.
                    identifier = client.username or client.address
                    PACKET_LOGGER.exception(
                        "Unhandled error processing message from %s", identifier
                    )

        except websockets.exceptions.ConnectionClosed:
            pass
        finally:
            auth_timeout_task.cancel()
            if address in self._clients:
                del self._clients[address]
            if client.username and self._username_to_client.get(client.username) is client:
                del self._username_to_client[client.username]
            if self._on_disconnect:
                await self._on_disconnect(client)

    async def broadcast(self, packet: dict, exclude: ClientConnection | None = None) -> None:
        """Broadcast a packet to all authenticated clients."""
        # Snapshot: a client can disconnect (mutating _clients) during an await.
        for client in list(self._clients.values()):
            if client.authenticated and client != exclude:
                await client.send(packet)

    def register_client_username(self, client: ClientConnection, username: str) -> None:
        """Register a username-to-client mapping for O(1) lookups."""
        self._username_to_client[username] = client

    async def send_to_user(self, username: str, packet: dict) -> bool:
        """Send a packet to a specific user."""
        client = self._username_to_client.get(username)
        if client:
            await client.send(packet)
            return True
        return False

    def get_client_by_username(self, username: str) -> ClientConnection | None:
        """Get a client by username."""
        return self._username_to_client.get(username)
