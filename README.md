# Dawahub starter

A three-tier starter for the near-expiry pharmacy and cosmetics marketplace:

- **Client:** AngularJS 1.8 single-page application
- **API:** Express.js REST API
- **Database:** PostgreSQL

The client and API are served from the same Express origin. The browser only
calls the API; database access stays on the server. This is a modular monolith,
which keeps the initial project simple while leaving room to grow.

> AngularJS 1.x is end-of-life. It is included to match the requested stack;
> consider a supported Angular release for a new production system.

## Requirements

- Node.js 22 or newer
- PostgreSQL 14 or newer

## Run locally

1. Install dependencies:

   ```sh
   npm install
   ```

2. Create a local environment file:

   ```sh
   cp .env.example .env
   ```

3. As a PostgreSQL administrator, create the application user:

   ```sh
   psql -d postgres -c "CREATE ROLE dawahub WITH LOGIN PASSWORD 'dawahub';"
   ```

4. Create the database owned by that user, then apply the initial schema:

   ```sh
   createdb --owner=dawahub dawahub
   psql "postgresql://postgres:password@localhost:5432/dawahub" \
     -f server/src/db/migrations/001_initial_schema.sql
   ```

   `.env.example` contains the matching `DATABASE_URL`. These credentials are
   for local development only; use a strong password outside local development.

5. Start the server:

   ```sh
   npm start
   ```

5. Open <http://localhost:3000>. The database-backed readiness endpoint is
   available at <http://localhost:3000/api/v1/health>.

Run `npm run check` to check JavaScript syntax.

## Project layout

```text
client/public/          AngularJS app and static assets
server/src/
  app.js                 Express application and middleware
  server.js              HTTP server startup and shutdown
  db/
    pool.js              PostgreSQL connection pool
    migrations/          SQL schema migrations
  routes/                API route modules
```

As the application grows, add feature modules under `server/src/modules/`
(`auth`, `products`, `inventory`, `orders`, and `admin`). Keep routes thin and
put validation, business rules, and persistence in their respective layers.

## Initial data model

The initial migration separates shared `products` from seller-owned
`inventory_batches`. A product may have several batches with distinct expiry
dates and quantities. Order items reference the batch and preserve the
product, price, and discount snapshots used at checkout.

The migration creates the foundational users, seller profiles, roles, catalog,
inventory, orders, and payments tables. It does not create default accounts or
implement checkout, authentication, payment processing, or expiry jobs.
