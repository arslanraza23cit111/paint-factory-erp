const path = require('path');
const fs = require('fs');
const crypto = require('crypto');
const Database = require('better-sqlite3');

// Database file lives next to the app. Override with ERP_DB_PATH if needed
// (Electron sets it to the user data folder).
const DB_PATH = process.env.ERP_DB_PATH || path.join(__dirname, '..', 'erp.db');

const db = new Database(DB_PATH);
db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');

function hashPassword(password, salt) {
  return crypto.createHash('sha256').update(salt + password).digest('hex');
}

function initSchema() {
  const sql = fs.readFileSync(path.join(__dirname, 'schema.sql'), 'utf8');
  db.exec(sql);
  seed();
}

function seed() {
  const userCount = db.prepare('SELECT COUNT(*) c FROM users').get().c;
  if (userCount === 0) {
    const salt = crypto.randomBytes(8).toString('hex');
    db.prepare(
      'INSERT INTO users (username, password, salt, full_name, role) VALUES (?,?,?,?,?)'
    ).run('admin', hashPassword('admin', salt), salt, 'Administrator', 'admin');
  }

  const accCount = db.prepare('SELECT COUNT(*) c FROM accounts').get().c;
  if (accCount === 0) {
    const ins = db.prepare(
      'INSERT INTO accounts (code, name, type) VALUES (?,?,?)'
    );
    [
      ['1000', 'Cash In Hand', 'ASSET'],
      ['1010', 'Bank', 'ASSET'],
      ['1100', 'Accounts Receivable', 'ASSET'],
      ['1200', 'Raw Material Stock', 'ASSET'],
      ['1210', 'Finished Goods Stock', 'ASSET'],
      ['2000', 'Accounts Payable', 'LIABILITY'],
      ['3000', 'Capital', 'EQUITY'],
      ['4000', 'Sales', 'INCOME'],
      ['5000', 'Purchases', 'EXPENSE'],
      ['5100', 'Production Cost', 'EXPENSE'],
      ['5200', 'Salaries', 'EXPENSE'],
      ['5300', 'General Expenses', 'EXPENSE'],
    ].forEach((r) => ins.run(...r));
  }

  db.prepare('INSERT OR IGNORE INTO settings (key,value) VALUES (?,?)').run(
    'company_name',
    'Paint Factory'
  );
}

module.exports = { db, DB_PATH, initSchema, hashPassword };
