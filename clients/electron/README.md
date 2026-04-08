# PlayPalace Electron Wrapper

Thin Electron shell that wraps the existing `clients/web/` client into a native desktop app for macOS, Windows, and Linux.

## Quick Start

```bash
cd clients/electron
npm install
npm start
```

This opens the web client in a native window. The web client must be in its expected location at `../web/`.

## Building

```bash
# macOS
npm run build:mac

# Windows
npm run build:win

# Linux
npm run build:linux
```

The build bundles the web client from `../web/` into the app resources.

## Notes

- No code duplication — the web client is loaded as-is
- Sound files are resolved from the web client's sounds symlink
- Create `clients/web/config.js` (from `config.sample.js`) to set a default server
