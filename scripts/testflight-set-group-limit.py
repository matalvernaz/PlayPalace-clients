#!/usr/bin/env python3
"""Set the playPalace TestFlight external beta group's public-link limit to
the App Store Connect maximum (10,000) so new testers can join freely.

Reuses the JWT/auth pattern from testflight-add-to-group.py.
"""

from __future__ import annotations

import base64
import json
import subprocess
import sys
import time
from pathlib import Path

API_KEY_ID = "8LD279H5H9"
API_ISSUER_ID = "4e69fbec-a077-43c2-aea0-55045fe3dddc"
API_KEY_PATH = Path.home() / ".appstoreconnect/private_keys" / f"AuthKey_{API_KEY_ID}.p8"
BUNDLE_ID = "ca.cobd.playpalace.ios"
GROUP_NAME = "playPalace testext"
MAX_PUBLIC_LINK_LIMIT = 10_000


def b64url(data: bytes | str) -> str:
    if isinstance(data, str):
        data = data.encode()
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode()


def generate_jwt() -> str:
    now = int(time.time())
    header = json.dumps({"alg": "ES256", "kid": API_KEY_ID, "typ": "JWT"}, separators=(",", ":"))
    payload = json.dumps(
        {"iss": API_ISSUER_ID, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"},
        separators=(",", ":"),
    )
    signing_input = b64url(header) + "." + b64url(payload)
    der = subprocess.run(
        ["openssl", "dgst", "-sha256", "-sign", str(API_KEY_PATH), "-binary"],
        input=signing_input.encode(), capture_output=True, check=True,
    ).stdout

    def parse_int(data, offset):
        length = data[offset + 1]
        value = data[offset + 2 : offset + 2 + length]
        while len(value) > 32 and value[:1] == b"\x00":
            value = value[1:]
        return value.rjust(32, b"\x00"), offset + 2 + length

    r, next_off = parse_int(der, 2)
    s, _ = parse_int(der, next_off)
    return signing_input + "." + b64url(r + s)


def api(jwt: str, method: str, path: str, data: dict | None = None) -> dict:
    url = f"https://api.appstoreconnect.apple.com{path}"
    cmd = ["curl", "-s", "--globoff",
           "-H", f"Authorization: Bearer {jwt}",
           "-H", "Content-Type: application/json"]
    if data is not None:
        cmd += ["-X", method, "-d", json.dumps(data)]
    elif method != "GET":
        cmd += ["-X", method]
    cmd.append(url)
    result = subprocess.run(cmd, capture_output=True, text=True)
    return json.loads(result.stdout) if result.stdout.strip() else {}


def main():
    if not API_KEY_PATH.exists():
        print(f"Error: API key not found at {API_KEY_PATH}", file=sys.stderr)
        sys.exit(1)
    jwt = generate_jwt()

    print("Looking up app...")
    resp = api(jwt, "GET", f"/v1/apps?filter[bundleId]={BUNDLE_ID}&fields[apps]=bundleId")
    apps = resp.get("data", [])
    if not apps:
        print(f"Error: app {BUNDLE_ID} not found", file=sys.stderr)
        sys.exit(1)
    app_id = apps[0]["id"]

    print(f"Looking up beta group '{GROUP_NAME}'...")
    fields = "name,publicLinkEnabled,publicLinkLimit,publicLinkLimitEnabled,publicLink,isInternalGroup"
    resp = api(jwt, "GET", f"/v1/apps/{app_id}/betaGroups?fields[betaGroups]={fields}")
    group = next((g for g in resp.get("data", []) if g["attributes"]["name"] == GROUP_NAME), None)
    if not group:
        print(f"Error: beta group '{GROUP_NAME}' not found", file=sys.stderr)
        sys.exit(1)
    group_id = group["id"]
    attrs = group["attributes"]
    print(f"Current state: publicLinkEnabled={attrs.get('publicLinkEnabled')}, "
          f"publicLinkLimitEnabled={attrs.get('publicLinkLimitEnabled')}, "
          f"publicLinkLimit={attrs.get('publicLinkLimit')}")

    print(f"Setting publicLinkLimit={MAX_PUBLIC_LINK_LIMIT}, "
          f"publicLinkEnabled=true, publicLinkLimitEnabled=true...")
    resp = api(jwt, "PATCH", f"/v1/betaGroups/{group_id}", {
        "data": {
            "type": "betaGroups",
            "id": group_id,
            "attributes": {
                "publicLinkEnabled": True,
                "publicLinkLimit": MAX_PUBLIC_LINK_LIMIT,
                "publicLinkLimitEnabled": True,
            },
        }
    })
    errors = resp.get("errors", [])
    if errors:
        print(f"Error: {errors}", file=sys.stderr)
        sys.exit(1)

    new_attrs = resp.get("data", {}).get("attributes", {})
    print(f"New state: publicLinkEnabled={new_attrs.get('publicLinkEnabled')}, "
          f"publicLinkLimitEnabled={new_attrs.get('publicLinkLimitEnabled')}, "
          f"publicLinkLimit={new_attrs.get('publicLinkLimit')}")
    public_link = new_attrs.get("publicLink")
    if public_link:
        print(f"Public link: {public_link}")


if __name__ == "__main__":
    main()
