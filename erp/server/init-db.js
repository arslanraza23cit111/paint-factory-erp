// Creates / migrates the local SQLite database file and seeds defaults.
const { initSchema, DB_PATH } = require('./db');

initSchema();
console.log('Database ready at: ' + DB_PATH);
console.log('Default login -> username: admin   password: admin');
