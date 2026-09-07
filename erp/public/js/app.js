/* Paint Factory ERP - frontend shell (Phase 1) */

const api = {
  async post(url, body) {
    const r = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body || {}),
    });
    const data = await r.json().catch(() => ({}));
    if (!r.ok) throw new Error(data.error || 'Request failed');
    return data;
  },
  async get(url) {
    const r = await fetch(url);
    const data = await r.json().catch(() => ({}));
    if (!r.ok) throw new Error(data.error || 'Request failed');
    return data;
  },
};

// Menu mirrors the legacy main menu exactly.
const MENU = [
  { key: 'counter-sale', label: 'Counter Sale', phase: 5 },
  { key: 'purchase', label: 'Purchase', phase: 4 },
  { key: 'production', label: 'Production', phase: 4 },
  { key: 'return', label: 'Return', phase: 5 },
  { key: 'stock', label: 'Stock', phase: 6 },
  { key: 'accounts', label: 'Accounts', phase: 6 },
  { key: 'sale-reports', label: 'Sale Reports', phase: 7 },
  { key: 'purchase-reports', label: 'Purchase Reports', phase: 7 },
  { key: 'general-reports', label: 'General Reports', phase: 7 },
  { key: 'setup', label: 'Setup', sub: [
      { key: 'items-all', label: 'Items All', phase: 2 },
      { key: 'items', label: 'Items', phase: 2 },
      { key: 'employees', label: 'Employees', phase: 3 },
      { key: 'customers', label: 'Customers', phase: 3 },
      { key: 'suppliers', label: 'Suppliers', phase: 3 },
      { key: 'transporters', label: 'Transporters', phase: 3 },
      { key: 'account-chart', label: 'Account Chart', phase: 3 },
      { key: 'factory-items', label: 'Factory Items', phase: 3 },
      { key: 'new-year-posting', label: 'New Year Posting', phase: 3 },
    ] },
  { key: 'issue-voucher', label: 'Issue Voucher', phase: 5 },
  { key: 'backup', label: 'Backup', phase: 7 },
  { key: 'exit', label: 'Exit' },
];

let openSetup = false;
let current = null;

function el(id) { return document.getElementById(id); }

function renderRibbon() {
  const nav = el('ribbon');
  nav.innerHTML = '';
  MENU.forEach((m) => {
    const b = document.createElement('button');
    b.className = 'ribbon-item' + (current === m.key ? ' active' : '');
    b.textContent = m.label;
    b.onclick = () => {
      if (m.key === 'setup') { openSetup = !openSetup; renderRibbon(); return; }
      if (m.key === 'exit') { logout(); return; }
      openScreen(m);
    };
    nav.appendChild(b);
    if (m.key === 'setup' && openSetup && m.sub) {
      m.sub.forEach((s) => {
        const sb = document.createElement('button');
        sb.className = 'ribbon-item ribbon-sub' + (current === s.key ? ' active' : '');
        sb.textContent = s.label;
        sb.onclick = () => openScreen(s);
        nav.appendChild(sb);
      });
    }
  });
}

function openScreen(m) {
  current = m.key;
  el('screen-title').textContent = m.label;
  renderRibbon();
  el('content').innerHTML =
    '<div class="panel"><div class="panel-head">' + m.label + '</div>' +
    '<div class="placeholder"><h2>' + m.label.toUpperCase() + '</h2>' +
    '<p>This screen is built in Phase ' + (m.phase || '?') + '.</p></div></div>';
  el('status-left').textContent = m.label;
}

function showMainMenu() {
  current = null;
  el('screen-title').textContent = 'Main Menu';
  renderRibbon();
  el('content').innerHTML =
    '<div class="panel"><div class="panel-head">System</div><div class="panel-body">' +
    '<div id="info"></div></div></div>';
  api.get('/api/info').then((info) => {
    el('info').innerHTML =
      '<table class="grid"><tr><th>Company</th><td>' + info.company + '</td></tr>' +
      '<tr><th>Database file</th><td>' + info.dbPath + '</td></tr>' +
      '<tr><th>Tables created</th><td>' + info.tables.length + '</td></tr></table>' +
      '<p style="font-size:11px;color:#6a6459">Offline system. All data stays in the local database file above.</p>';
    el('status-right').textContent = 'DB: ' + info.dbPath;
  });
}

async function logout() {
  await api.post('/api/logout');
  el('app').classList.add('hidden');
  el('login-screen').classList.remove('hidden');
  el('login-pass').value = '';
  el('login-user').focus();
}

function enterApp(user) {
  el('login-screen').classList.add('hidden');
  el('app').classList.remove('hidden');
  el('user-label').textContent = user.name || user.username;
  showMainMenu();
}

el('login-form').addEventListener('submit', async (e) => {
  e.preventDefault();
  el('login-error').textContent = '';
  try {
    const res = await api.post('/api/login', {
      username: el('login-user').value,
      password: el('login-pass').value,
    });
    enterApp(res.user);
  } catch (err) {
    el('login-error').textContent = err.message;
  }
});

el('btn-logout').addEventListener('click', logout);

// resume an existing session
api.get('/api/me').then((r) => enterApp(r.user)).catch(() => {});
