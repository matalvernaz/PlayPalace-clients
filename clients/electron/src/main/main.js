const { app, BrowserWindow } = require('electron');
const path = require('path');

let mainWindow;

function createWindow() {
    mainWindow = new BrowserWindow({
        width: 980,
        height: 720,
        minWidth: 700,
        minHeight: 500,
        title: 'PlayPalace',
        webPreferences: {
            // The web client is a standalone static site — no node integration needed.
            nodeIntegration: false,
            contextIsolation: true,
        },
    });

    // Load the existing web client.
    // In development: clients/web/ relative to this repo.
    // When packaged: extraResources/web/ inside the app bundle.
    const fs = require('fs');
    const devPath = path.resolve(__dirname, '..', '..', '..', 'web', 'index.html');
    const packagedPath = path.join(process.resourcesPath, 'web', 'index.html');
    const webClientPath = fs.existsSync(devPath) ? devPath : packagedPath;
    mainWindow.loadFile(webClientPath);

    // Open DevTools in development
    if (process.argv.includes('--dev')) {
        mainWindow.webContents.openDevTools();
    }
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
    app.quit();
});

app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
});
