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

    // Load the existing web client directly.
    // The web client lives at clients/web/ relative to this repo.
    const webClientPath = path.resolve(__dirname, '..', '..', '..', 'web', 'index.html');
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
