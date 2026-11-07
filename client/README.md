This folder only holds a link to `clients/desktop/sounds`, the one sound pack every client here uses.

The server runs PlayAural's games, which look for their sound files under
`client/sounds`, `web_client/sounds` and `mobile_client/sounds` (PlayAural keeps
one copy per app). The links let the server measure our real sound lengths
for timing, and let PlayAural's own tests check that our pack has every sound
their games ask for. The real files live in `clients/desktop/sounds`.
