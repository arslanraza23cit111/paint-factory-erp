-- Paint Factory ERP - full schema (all modules created in Phase 1)
PRAGMA foreign_keys = ON;

-- ========== 1. USERS / LOGIN ==========
CREATE TABLE IF NOT EXISTS users (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  username    TEXT NOT NULL UNIQUE,
  password    TEXT NOT NULL,              -- salted sha256 hash (hex)
  salt        TEXT NOT NULL,
  full_name   TEXT,
  role        TEXT NOT NULL DEFAULT 'user', -- admin | user
  active      INTEGER NOT NULL DEFAULT 1,
  created_at  TEXT NOT NULL DEFAULT (datetime('now','localtime'))
);

-- ========== 2. SETUP / MASTERS ==========
CREATE TABLE IF NOT EXISTS employees (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  code       TEXT UNIQUE,
  name       TEXT NOT NULL,
  father_name TEXT,
  designation TEXT,
  cnic       TEXT,
  phone      TEXT,
  address    TEXT,
  salary     REAL DEFAULT 0,
  join_date  TEXT,
  active     INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS customers (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  code         TEXT UNIQUE,
  name         TEXT NOT NULL,
  contact_person TEXT,
  phone        TEXT,
  mobile       TEXT,
  city         TEXT,
  address      TEXT,
  opening_balance REAL NOT NULL DEFAULT 0,
  credit_limit REAL NOT NULL DEFAULT 0,
  account_id   INTEGER REFERENCES accounts(id),
  active       INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS suppliers (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  code         TEXT UNIQUE,
  name         TEXT NOT NULL,
  contact_person TEXT,
  phone        TEXT,
  mobile       TEXT,
  city         TEXT,
  address      TEXT,
  opening_balance REAL NOT NULL DEFAULT 0,
  account_id   INTEGER REFERENCES accounts(id),
  active       INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS transporters (
  id       INTEGER PRIMARY KEY AUTOINCREMENT,
  code     TEXT UNIQUE,
  name     TEXT NOT NULL,
  phone    TEXT,
  city     TEXT,
  address  TEXT,
  active   INTEGER NOT NULL DEFAULT 1
);

-- Chart of accounts (self referencing tree)
CREATE TABLE IF NOT EXISTS accounts (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  code        TEXT UNIQUE,
  name        TEXT NOT NULL,
  type        TEXT NOT NULL DEFAULT 'ASSET', -- ASSET|LIABILITY|EQUITY|INCOME|EXPENSE
  parent_id   INTEGER REFERENCES accounts(id),
  opening_balance REAL NOT NULL DEFAULT 0,
  active      INTEGER NOT NULL DEFAULT 1
);

-- Factory items = raw materials
CREATE TABLE IF NOT EXISTS factory_items (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  code        TEXT UNIQUE,
  name        TEXT NOT NULL,
  unit        TEXT DEFAULT 'KG',
  rate        REAL NOT NULL DEFAULT 0,     -- current cost rate
  stock       REAL NOT NULL DEFAULT 0,
  min_stock   REAL NOT NULL DEFAULT 0,
  max_stock   REAL NOT NULL DEFAULT 0,
  active      INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS year_postings (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  from_year  TEXT NOT NULL,
  to_year    TEXT NOT NULL,
  posted_at  TEXT NOT NULL DEFAULT (datetime('now','localtime')),
  remarks    TEXT
);

-- ========== 3. ITEMS MASTER ==========
CREATE TABLE IF NOT EXISTS items (
  id      INTEGER PRIMARY KEY AUTOINCREMENT,
  code    TEXT UNIQUE,
  name    TEXT NOT NULL,
  active  INTEGER NOT NULL DEFAULT 1
);

-- "Particulars" grid rows for each item (shade/type + packing)
CREATE TABLE IF NOT EXISTS item_particulars (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  item_id      INTEGER NOT NULL REFERENCES items(id) ON DELETE CASCADE,
  sr           INTEGER NOT NULL DEFAULT 1,
  type         TEXT,            -- shade / type e.g. WHITE
  weight_unit  TEXT,            -- GALLON, DRUM, QRT ...
  cost_price   REAL NOT NULL DEFAULT 0,
  ws_price     REAL NOT NULL DEFAULT 0,
  sale_price   REAL NOT NULL DEFAULT 0,
  stock        REAL NOT NULL DEFAULT 0,
  min_stock    REAL NOT NULL DEFAULT 0,
  max_stock    REAL NOT NULL DEFAULT 0,
  formula_code TEXT
);
CREATE INDEX IF NOT EXISTS idx_particulars_item ON item_particulars(item_id);

-- ========== 4. FORMULA / BOM ==========
CREATE TABLE IF NOT EXISTS formulas (
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  particular_id  INTEGER NOT NULL REFERENCES item_particulars(id) ON DELETE CASCADE,
  code           TEXT,
  batch_size     REAL NOT NULL DEFAULT 1,
  remarks        TEXT,
  updated_at     TEXT NOT NULL DEFAULT (datetime('now','localtime'))
);

CREATE TABLE IF NOT EXISTS formula_lines (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  formula_id      INTEGER NOT NULL REFERENCES formulas(id) ON DELETE CASCADE,
  sr              INTEGER NOT NULL DEFAULT 1,
  factory_item_id INTEGER REFERENCES factory_items(id),
  material_name   TEXT,
  value           REAL NOT NULL DEFAULT 0,   -- quantity
  rate            REAL NOT NULL DEFAULT 0,
  cost_value      REAL NOT NULL DEFAULT 0    -- value * rate
);
CREATE INDEX IF NOT EXISTS idx_formula_lines ON formula_lines(formula_id);

-- ========== 5. PURCHASE ==========
CREATE TABLE IF NOT EXISTS purchases (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  voucher_no    TEXT UNIQUE,
  date          TEXT NOT NULL,
  supplier_id   INTEGER REFERENCES suppliers(id),
  bill_no       TEXT,
  transporter_id INTEGER REFERENCES transporters(id),
  remarks       TEXT,
  gross_total   REAL NOT NULL DEFAULT 0,
  discount      REAL NOT NULL DEFAULT 0,
  expenses      REAL NOT NULL DEFAULT 0,
  net_total     REAL NOT NULL DEFAULT 0,
  paid          REAL NOT NULL DEFAULT 0,
  created_at    TEXT NOT NULL DEFAULT (datetime('now','localtime'))
);

CREATE TABLE IF NOT EXISTS purchase_lines (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  purchase_id     INTEGER NOT NULL REFERENCES purchases(id) ON DELETE CASCADE,
  sr              INTEGER NOT NULL DEFAULT 1,
  factory_item_id INTEGER REFERENCES factory_items(id),
  particular_id   INTEGER REFERENCES item_particulars(id),
  description     TEXT,
  qty             REAL NOT NULL DEFAULT 0,
  rate            REAL NOT NULL DEFAULT 0,
  amount          REAL NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_purchase_lines ON purchase_lines(purchase_id);

-- ========== 6. PRODUCTION ==========
CREATE TABLE IF NOT EXISTS productions (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  voucher_no    TEXT UNIQUE,
  date          TEXT NOT NULL,
  particular_id INTEGER REFERENCES item_particulars(id),
  qty_produced  REAL NOT NULL DEFAULT 0,
  total_cost    REAL NOT NULL DEFAULT 0,
  employee_id   INTEGER REFERENCES employees(id),
  remarks       TEXT,
  created_at    TEXT NOT NULL DEFAULT (datetime('now','localtime'))
);

CREATE TABLE IF NOT EXISTS production_consumption (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  production_id   INTEGER NOT NULL REFERENCES productions(id) ON DELETE CASCADE,
  factory_item_id INTEGER REFERENCES factory_items(id),
  material_name   TEXT,
  qty             REAL NOT NULL DEFAULT 0,
  rate            REAL NOT NULL DEFAULT 0,
  cost_value      REAL NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_prod_cons ON production_consumption(production_id);

-- ========== 7. COUNTER SALE ==========
CREATE TABLE IF NOT EXISTS sales (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  voucher_no   TEXT UNIQUE,
  date         TEXT NOT NULL,
  customer_id  INTEGER REFERENCES customers(id),
  sale_type    TEXT NOT NULL DEFAULT 'COUNTER', -- COUNTER | WHOLESALE
  transporter_id INTEGER REFERENCES transporters(id),
  remarks      TEXT,
  gross_total  REAL NOT NULL DEFAULT 0,
  discount     REAL NOT NULL DEFAULT 0,
  net_total    REAL NOT NULL DEFAULT 0,
  received     REAL NOT NULL DEFAULT 0,
  created_at   TEXT NOT NULL DEFAULT (datetime('now','localtime'))
);

CREATE TABLE IF NOT EXISTS sale_lines (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  sale_id       INTEGER NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
  sr            INTEGER NOT NULL DEFAULT 1,
  particular_id INTEGER REFERENCES item_particulars(id),
  description   TEXT,
  size          TEXT,
  shade         TEXT,
  qty           REAL NOT NULL DEFAULT 0,
  rate          REAL NOT NULL DEFAULT 0,
  amount        REAL NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_sale_lines ON sale_lines(sale_id);

-- ========== 8. ISSUE VOUCHER ==========
CREATE TABLE IF NOT EXISTS issue_vouchers (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  voucher_no  TEXT UNIQUE,
  date        TEXT NOT NULL,
  customer_id INTEGER REFERENCES customers(id),
  remarks     TEXT,
  created_at  TEXT NOT NULL DEFAULT (datetime('now','localtime'))
);

CREATE TABLE IF NOT EXISTS issue_voucher_lines (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  voucher_id    INTEGER NOT NULL REFERENCES issue_vouchers(id) ON DELETE CASCADE,
  sr            INTEGER NOT NULL DEFAULT 1,
  particular_id INTEGER REFERENCES item_particulars(id),
  size          TEXT,
  shade         TEXT,
  in_stock      REAL NOT NULL DEFAULT 0,
  qty           REAL NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_iv_lines ON issue_voucher_lines(voucher_id);

-- ========== 9. RETURNS ==========
CREATE TABLE IF NOT EXISTS returns (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  voucher_no  TEXT UNIQUE,
  date        TEXT NOT NULL,
  kind        TEXT NOT NULL DEFAULT 'SALE',  -- SALE (customer return) | PURCHASE (to supplier)
  customer_id INTEGER REFERENCES customers(id),
  supplier_id INTEGER REFERENCES suppliers(id),
  remarks     TEXT,
  net_total   REAL NOT NULL DEFAULT 0,
  created_at  TEXT NOT NULL DEFAULT (datetime('now','localtime'))
);

CREATE TABLE IF NOT EXISTS return_lines (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  return_id       INTEGER NOT NULL REFERENCES returns(id) ON DELETE CASCADE,
  sr              INTEGER NOT NULL DEFAULT 1,
  particular_id   INTEGER REFERENCES item_particulars(id),
  factory_item_id INTEGER REFERENCES factory_items(id),
  description     TEXT,
  qty             REAL NOT NULL DEFAULT 0,
  rate            REAL NOT NULL DEFAULT 0,
  amount          REAL NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_return_lines ON return_lines(return_id);

-- ========== 10. STOCK LEDGER ==========
CREATE TABLE IF NOT EXISTS stock_ledger (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  date            TEXT NOT NULL,
  particular_id   INTEGER REFERENCES item_particulars(id),
  factory_item_id INTEGER REFERENCES factory_items(id),
  doc_type        TEXT NOT NULL,   -- PURCHASE|PRODUCTION|SALE|ISSUE|RETURN|OPENING|ADJUST
  doc_id          INTEGER,
  doc_no          TEXT,
  qty_in          REAL NOT NULL DEFAULT 0,
  qty_out         REAL NOT NULL DEFAULT 0,
  rate            REAL NOT NULL DEFAULT 0,
  balance         REAL NOT NULL DEFAULT 0,
  remarks         TEXT,
  created_at      TEXT NOT NULL DEFAULT (datetime('now','localtime'))
);
CREATE INDEX IF NOT EXISTS idx_stock_particular ON stock_ledger(particular_id);
CREATE INDEX IF NOT EXISTS idx_stock_factory ON stock_ledger(factory_item_id);

-- ========== 11. ACCOUNTS / LEDGER ==========
CREATE TABLE IF NOT EXISTS vouchers (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  voucher_no  TEXT UNIQUE,
  date        TEXT NOT NULL,
  type        TEXT NOT NULL,  -- CASH_RECEIPT|CASH_PAYMENT|JOURNAL|BANK
  remarks     TEXT,
  created_at  TEXT NOT NULL DEFAULT (datetime('now','localtime'))
);

CREATE TABLE IF NOT EXISTS ledger_entries (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  date        TEXT NOT NULL,
  account_id  INTEGER REFERENCES accounts(id),
  customer_id INTEGER REFERENCES customers(id),
  supplier_id INTEGER REFERENCES suppliers(id),
  doc_type    TEXT NOT NULL,
  doc_id      INTEGER,
  doc_no      TEXT,
  description TEXT,
  debit       REAL NOT NULL DEFAULT 0,
  credit      REAL NOT NULL DEFAULT 0,
  created_at  TEXT NOT NULL DEFAULT (datetime('now','localtime'))
);
CREATE INDEX IF NOT EXISTS idx_ledger_account ON ledger_entries(account_id);
CREATE INDEX IF NOT EXISTS idx_ledger_customer ON ledger_entries(customer_id);
CREATE INDEX IF NOT EXISTS idx_ledger_supplier ON ledger_entries(supplier_id);

-- ========== 12. BACKUP LOG ==========
CREATE TABLE IF NOT EXISTS backups (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  path       TEXT NOT NULL,
  size_bytes INTEGER,
  created_at TEXT NOT NULL DEFAULT (datetime('now','localtime'))
);

-- ========== 13. SETTINGS ==========
CREATE TABLE IF NOT EXISTS settings (
  key   TEXT PRIMARY KEY,
  value TEXT
);
