const path = require('path');
const express = require('express');
const helmet = require('helmet');
const healthRouter = require('./routes/health');

const app = express();
const clientDirectory = path.resolve(__dirname, '../../client/public');

app.use(helmet());
app.use(express.json({ limit: '1mb' }));

app.use(
  '/vendor/angular',
  express.static(path.dirname(require.resolve('angular')))
);
app.use('/api/v1/health', healthRouter);
app.use('/api', (req, res) => {
  res.status(404).json({ error: 'API route not found.' });
});
app.use(express.static(clientDirectory));

app.use((error, req, res, next) => {
  console.error(error);
  if (res.headersSent) {
    return next(error);
  }

  res.status(503).json({ error: 'The service is temporarily unavailable.' });
});

module.exports = app;
