const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
});

pool.connect((err, client, release) => {
  if (err) {
    return console.error('❌ Connection Error:', err.stack);
  }
  console.log('✅ Connected to Neon PostgreSQL Database!');
  release();
});

module.exports = pool;