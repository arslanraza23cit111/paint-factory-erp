const path = require('path');
const express = require('express');
const session = require('express-session');
const { db, DB_PATH, initSchema, hashPassword } = require('./db');

initSchema();

const app = express();
app.use(express.json({ limit: '5mb' }));
app.use(
  session({
    secret: 'paint-erp-local-session',
    resave: false,
    saveUninitialized: false,
    cookie: { maxAge: 1000 * 60 * 60 * 12 },
  })
);

// ---------- auth ----------
function requireAuth(req, res, next) {
  if (req.session && req.session.user) return next();
  return res.status(401).json({ error: 'Not logged in' });
}

app.post('/api/login', (req, res) => {
  const { username, password } = req.body || {};
  const user = db
    .prepare('SELECT * FROM users WHERE username = ? AND active = 1')
    .get(String(username || '').trim());
  if (!user || user.password !== hashPassword(String(password || ''), user.salt)) {
    return res.status(401).json({ error: 'Invalid username or password' });
  }
  req.session.user = { id: user.id, username: user.username, name: user.full_name, role: user.role };
  res.json({ user: req.session.user });
});

app.post('/api/logout', (req, res) => {
  req.session.destroy(() => res.json({ ok: true }));
});

app.get('/api/me', (req, res) => {
  if (!req.session || !req.session.user) return res.status(401).json({ error: 'Not logged in' });
  res.json({ user: req.session.user });
});

app.get('/api/info', requireAuth, (req, res) => {
  const setting = db.prepare('SELECT value FROM settings WHERE key = ?').get('company_name');
  const tables = db
    .prepare("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name")
    .all()
    .map((r) => r.name);
  res.json({ company: setting ? setting.value : 'Paint Factory', dbPath: DB_PATH, tables });
});

// ---------- static frontend ----------
app.use(express.static(path.join(__dirname, '..', 'public')));

const PORT = process.env.PORT || 3300;
if (require.main === module) {
  app.listen(PORT, () => console.log('Paint ERP running at http://localhost:' + PORT));
}

module.exports = { app, PORT, requireAuth };
