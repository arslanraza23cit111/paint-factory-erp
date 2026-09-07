const path = require('path');
const { app: electronApp, BrowserWindow, Menu } = require('electron');

// Store the database in the user's data folder when running as a desktop app.
process.env.ERP_DB_PATH =
  process.env.ERP_DB_PATH || path.join(electronApp.getPath('userData'), 'erp.db');

const { app: server, PORT } = require('../server/index.js');

let win;

function createWindow() {
  win = new BrowserWindow({
    width: 1280,
    height: 800,
    show: false,
    webPreferences: { contextIsolation: true, nodeIntegration: false },
  });
  Menu.setApplicationMenu(null);
  win.loadURL('http://localhost:' + PORT);
  win.once('ready-to-show', () => win.show());
}

electronApp.whenReady().then(() => {
  server.listen(PORT, '127.0.0.1', () => createWindow());
});

electronApp.on('window-all-closed', () => electronApp.quit());
