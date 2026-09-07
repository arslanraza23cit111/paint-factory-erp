# Paint Factory ERP — fully offline

Node.js + Express + SQLite (better-sqlite3) + plain HTML/CSS/JS, packaged with Electron.
No internet, no cloud services, ever. All data lives in a single local `erp.db` file.

## Run as a web app (browser)

```bash
cd erp
npm install
npm run init-db      # creates erp.db with the full schema + default admin
npm start            # http://localhost:3300
```

Default login: `admin` / `admin` (change it after first use).

## Run as a desktop app

```bash
npm run electron
```

## Build a Windows .exe

```bash
npm run package:win   # output in erp/release/PaintERP-win32-x64
```

## Notes

- `erp.db` is git-ignored — it holds real business data.
- In the desktop build the database lives in the Electron user-data folder;
  set `ERP_DB_PATH` to override.
- `better-sqlite3` is a native module: on Windows install with a matching Node
  version, and run `npx electron-rebuild` if Electron reports a module version
  mismatch.
