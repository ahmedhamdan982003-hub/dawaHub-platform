require('dotenv').config();

const app = require('./app');
const pool = require('./db/pool');

const port = Number(process.env.PORT) || 3000;
const server = app.listen(port, () => {
  console.log(`Dawahub is listening on http://localhost:${port}`);
});

function shutdown(signal) {
  console.log(`${signal} received; closing server.`);
  server.close(async (error) => {
    if (error) {
      console.error('Failed to close the HTTP server cleanly:', error);
      process.exitCode = 1;
    }

    try {
      await pool.end();
    } catch (poolError) {
      console.error('Failed to close the PostgreSQL pool cleanly:', poolError);
      process.exitCode = 1;
    }
  });
}

process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));
