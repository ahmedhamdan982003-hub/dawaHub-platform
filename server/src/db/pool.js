const { Pool } = require('pg');

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  throw new Error('DATABASE_URL must be set before starting the server.');
}

const pool = new Pool({ connectionString });

pool.on('error', (error) => {
  console.error('Unexpected PostgreSQL pool error:', error);
});

module.exports = pool;
