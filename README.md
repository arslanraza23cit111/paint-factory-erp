# Paint Factory ERP

AI Coding Tool Build Prompt: Paint Factory ERP (Fully Offline, SQLite)

Use this prompt with Claude Code, Cursor, or any local AI coding tool that can write files and run commands on your computer. Do not use Lovable, bolt.new, or any cloud-only builder — those force a cloud database (Supabase/Firebase) and cannot run fully offline.

PROJECT OVERVIEW

Build a full offline ERP system for a paint manufacturing/trading business, replicating an existing legacy desktop system (Oracle Forms style — see attached screenshots/description). The system must:

Run 100% offline, no internet required, ever.

Store all data in a local SQLite file on the shop's computer.

Work as a web app (open in browser at localhost) AND be packaged as a desktop app (Windows .exe via Electron) from the same codebase.

Tech stack (do not deviate without asking):

Backend: Node.js + Express

Database: SQLite via better-sqlite3 (single local file, e.g. erp.db)

Frontend: HTML/CSS/JS (or React if the tool prefers) — served by the same Express server

Desktop packaging: Electron (wraps the same Express server + frontend in a native window)

No cloud services, no external APIs, no internet dependency of any kind

Visual style: Clean and modern, but keep the same information density as the original (two-panel item lists, dense data grids, red ribbon-style main menu) since staff are used to it.

CORE MODULES (full scope)

Login / Lock screen — local username+password check against local users table

Items Master — Item list (left) + Particulars grid (right): Type, Weight/Unit, Cost Price, W.S. Price, Sale Price, Stock, Min, Max, Formula Code

Formula / BOM — per item-particular: raw material lines (name, value, rate, cost value), auto-calculated totals

Setup / Masters — Employees, Customers, Suppliers, Transporters, Account Chart, Factory Items (raw materials), New Year Posting

Purchase — purchase entry against suppliers, updates raw material stock

Production — consumes raw materials per Formula, produces finished goods, updates stock

Counter Sale — sale entry against customers, deducts stock

Issue Voucher — Voucher No, Date, Customer, Remarks, item lines (Size/Shade/In Stock/Qty)

Return — customer/supplier returns, adjusts stock and accounts

Stock — live stock view + stock ledger (full movement history)

Accounts — chart of accounts, customer/supplier ledgers, balances

Reports — Sale, Purchase, General Reports (filterable by date, party, item)

Backup — one-click copy of the SQLite .db file to a folder chosen by the user (this is the offline equivalent of cloud backup — must be manual, triggered by a button, since there is no internet to auto-sync to)

PHASE PLAN (build strictly in this order — do not skip ahead)

Phase 1 — Foundation

Node.js + Express server scaffold, SQLite database file with FULL schema for all 13 modules (create every table now, even for modules with no UI yet)

Login/lock screen, basic app shell/navigation matching the module list

Phase 2 — Items & Formula

Items Master screen (two-panel layout)

Formula/BOM modal with auto-calculated totals

Phase 3 — Setup / Masters

Employees, Customers, Suppliers, Transporters, Account Chart, Factory Items — full CRUD

Phase 4 — Purchase & Production

Purchase entry (updates raw material stock)

Production entry (consumes raw materials per Formula, produces finished goods)

Phase 5 — Sales & Vouchers

Counter Sale screen

Issue Voucher screen (Voucher No, Date, Customer, Remarks, item grid)

Return screen

Phase 6 — Stock & Accounts

Live stock dashboard + stock ledger

Accounts module: chart of accounts, party ledgers, balances

Phase 7 — Reports & Backup

Sale/Purchase/General Reports with filters

One-click local backup (copy .db file)

Phase 8 — Desktop Packaging & Polish

Wrap the app in Electron for a Windows desktop build

Validation, error handling, responsive layout, final QA pass

CRITICAL INSTRUCTION — CREDIT / PROGRESS TRACKING

Maintain a file in the project root named PROGRESS.md. Update it:

Immediately after completing each phase, or any meaningful chunk of work within a phase

Whenever you sense you are running low on credits/context/response length for the current session, before doing anything else, write to PROGRESS.md:

Which phases are fully complete

Which phase is in progress, and exactly what has been done in it so far

What remains, as a clear checklist, so a fresh session can resume without re-reading the whole codebase

Any decisions, assumptions, or deviations from this prompt, and why

Any known bugs or incomplete features

How to run the project locally (exact commands) so nothing is lost between sessions

Never let a session end silently without updating PROGRESS.md. Always read PROGRESS.md first at the start of a new session before making any changes.

CRITICAL INSTRUCTION — GITHUB

Initialize a git repository at the start of Phase 1 and push to GitHub after every phase is completed, and after any PROGRESS.md update. Use clear commit messages, e.g.: "Phase 2 complete: Items + Formula module" or "Progress update: mid Phase 4, production module in progress".

Important: Add a .gitignore that excludes node_modules/ and the local erp.db database file itself (real business data should not go to a public/shared repo — only code and schema). If a sample/demo database is needed for testing, create a separate erp.sample.db and commit that instead, clearly named.

If GitHub is not yet connected/authenticated in this environment, tell the user exactly what command or step is needed to connect it, and pause until it's done.

BOUNDARIES / WHAT NOT TO DO

Do not use any cloud database, cloud auth, or cloud storage service. Everything must work with no internet connection at all — assume the shop computer may never go online.

Do not invent new modules or rename existing ones without asking.

Do not skip full database schema design in Phase 1, even for modules without UI yet.

Do not silently switch tech stack (e.g. don't swap SQLite for another database).

Do not remove or rewrite PROGRESS.md history — only append/update status.

Do not mark a phase "complete" unless its screens are functional and connected to the real SQLite database (not just static/mock UI).

Ask before making destructive database changes (dropping tables, deleting columns) once real business data may exist in erp.db.

Do not commit the real erp.db file (business data) to git — see .gitignore note above.

FIRST RESPONSE EXPECTED FROM YOU

Confirm the tech stack and phase plan above.

Initialize the project folder, git repo, and PROGRESS.md (Phase 1 marked "in progress", empty checklist for the rest).

Begin Phase 1: Express + SQLite scaffold, full schema, login screen, app shell.

This project was built with [Lovable](https://lovable.dev).

## Build with Lovable

Continue developing this project in the [Lovable editor](https://lovable.dev/projects/2a5b6a40-ec48-4cf1-b052-16c7dcec8b40).

- **Ship faster**: describe what you want to build and Lovable handles the code.
- **Stay in sync**: every change made in Lovable is committed straight to this repository.
- **Full ownership**: this code is yours. Push to `main` on GitHub and your changes sync back into Lovable, ready for your next prompt.

## Development

Prefer working locally? You need Node.js and npm — [install with nvm](https://github.com/nvm-sh/nvm#installing-and-updating).

```sh
git clone <this-repository-url>
cd <repository-name>
npm i
npm run dev
```
