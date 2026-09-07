# Paint Factory ERP — Progress

Project lives in the `erp/` folder of this repository.

## Stack (confirmed, do not deviate)

- Backend: Node.js + Express
- Database: SQLite via better-sqlite3, single local file `erp/erp.db`
- Frontend: plain HTML/CSS/JS served by the same Express server
- Desktop: Electron wrapping the same server
- 100% offline, no cloud services of any kind

## Phase status

- [x] **Phase 1 — Foundation** (complete)
- [ ] Phase 2 — Items & Formula
- [ ] Phase 3 — Setup / Masters
- [ ] Phase 4 — Purchase & Production
- [ ] Phase 5 — Sales & Vouchers
- [ ] Phase 6 — Stock & Accounts
- [ ] Phase 7 — Reports & Backup
- [ ] Phase 8 — Desktop Packaging & Polish

### Phase 1 — done

- `erp/package.json` with scripts: start, init-db, electron, package:win
- `erp/server/schema.sql` — FULL schema for all modules:
  users, employees, customers, suppliers, transporters, accounts, factory_items,
  year_postings, items, item_particulars, formulas, formula_lines, purchases,
  purchase_lines, productions, production_consumption, sales, sale_lines,
  issue_vouchers, issue_voucher_lines, returns, return_lines, stock_ledger,
  vouchers, ledger_entries, backups, settings
- `erp/server/db.js` — better-sqlite3 connection (WAL, FK on), salted sha256
  password hashing, schema init + seed (admin/admin user, default chart of accounts)
- `erp/server/index.js` — Express app, session login (`/api/login`, `/api/logout`,
  `/api/me`, `/api/info`), serves the frontend
- `erp/public/` — login/lock screen, app shell: red ribbon menu matching the
  legacy main menu exactly (Counter Sale, Purchase, Production, Return, Stock,
  Accounts, Sale Reports, Purchase Reports, General Reports, Setup + submenu,
  Issue Voucher, Backup, Exit), dense grid CSS, status bar
- `erp/electron/main.cjs` — Electron wrapper (contextIsolation on)
- `.gitignore` excludes `node_modules/` and `erp.db`

### Remaining checklist

**Phase 2** — Items Master two-panel screen (item list left, particulars grid right:
Type, Weight/Unit, Cost Price, WS Price, Sale Price, Stock, Min, Max, F.Code);
Formula/BOM popup with raw-material lines (Value, Rate, Cost Value) and auto totals.

**Phase 3** — CRUD screens for Employees, Customers, Suppliers, Transporters,
Account Chart, Factory Items, New Year Posting.

**Phase 4** — Purchase entry (raw material stock in + supplier ledger);
Production entry (consume per Formula, produce finished goods, stock ledger).

**Phase 5** — Counter Sale; Issue Voucher (Voucher No, Date, Customer, Remarks,
grid: Size/Shade/In Stock/Qty); Return (customer + supplier).

**Phase 6** — Live stock dashboard, stock ledger; chart of accounts, party
ledgers, balances.

**Phase 7** — Sale/Purchase/General reports with date/party/item filters;
one-click backup copying `erp.db` to a chosen folder.

**Phase 8** — Electron Windows build, validation, error handling, QA.

## Decisions / deviations

- Built inside the Lovable environment at the user's explicit request. The
  Express + SQLite code cannot run in Lovable's preview (React/edge runtime);
  it is written to be downloaded and run locally with `npm install && npm start`.
- Git/GitHub commands cannot be run from this environment; connect GitHub from
  the Lovable project menu (GitHub → Connect) and pushes happen automatically.
- Passwords use salted SHA-256 (no bcrypt) to keep the dependency list small and
  fully offline-installable.

## Known gaps

- Only Phase 1 screens exist; every other menu entry shows a "built in Phase N"
  placeholder.
- No native rebuild of better-sqlite3 for Electron has been tested.

## How to run

```bash
cd erp
npm install
npm run init-db
npm start        # http://localhost:3300  (admin / admin)
npm run electron # desktop window
```
