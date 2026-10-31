BEGIN;

CREATE TABLE roles (
  id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name text NOT NULL UNIQUE
);

INSERT INTO roles (name) VALUES ('buyer'), ('seller'), ('admin');

CREATE TABLE users (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  email text NOT NULL UNIQUE,
  password_hash text NOT NULL,
  full_name text NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE user_roles (
  user_id bigint NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role_id integer NOT NULL REFERENCES roles(id),
  PRIMARY KEY (user_id, role_id)
);

CREATE TABLE seller_profiles (
  user_id bigint PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  pharmacy_name text NOT NULL,
  registration_number text UNIQUE,
  address text NOT NULL,
  approved_at timestamptz
);

CREATE TABLE categories (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name text NOT NULL UNIQUE
);

CREATE TABLE products (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  category_id bigint REFERENCES categories(id),
  name text NOT NULL,
  description text NOT NULL DEFAULT '',
  product_code text UNIQUE,
  is_otc boolean NOT NULL DEFAULT true,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE inventory_batches (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  seller_id bigint NOT NULL REFERENCES seller_profiles(user_id),
  product_id bigint NOT NULL REFERENCES products(id),
  batch_number text NOT NULL,
  expires_on date NOT NULL,
  quantity_available integer NOT NULL CHECK (quantity_available >= 0),
  unit_price numeric(12, 2) NOT NULL CHECK (unit_price >= 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (seller_id, product_id, batch_number)
);

CREATE TABLE orders (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  buyer_id bigint NOT NULL REFERENCES users(id),
  status text NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'confirmed', 'fulfilled', 'cancelled')),
  subtotal numeric(12, 2) NOT NULL DEFAULT 0 CHECK (subtotal >= 0),
  discount_total numeric(12, 2) NOT NULL DEFAULT 0 CHECK (discount_total >= 0),
  total numeric(12, 2) NOT NULL DEFAULT 0 CHECK (total >= 0),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE order_items (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  order_id bigint NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  inventory_batch_id bigint NOT NULL REFERENCES inventory_batches(id),
  product_name_snapshot text NOT NULL,
  quantity integer NOT NULL CHECK (quantity > 0),
  unit_price numeric(12, 2) NOT NULL CHECK (unit_price >= 0),
  discount_amount numeric(12, 2) NOT NULL DEFAULT 0
    CHECK (discount_amount >= 0),
  line_total numeric(12, 2) NOT NULL CHECK (line_total >= 0)
);

CREATE TABLE payments (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  order_id bigint NOT NULL REFERENCES orders(id),
  status text NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'authorized', 'paid', 'failed', 'refunded')),
  amount numeric(12, 2) NOT NULL CHECK (amount >= 0),
  provider text,
  provider_reference text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX products_category_id_idx ON products(category_id);
CREATE INDEX inventory_batches_expiry_idx ON inventory_batches(expires_on);
CREATE INDEX inventory_batches_seller_product_idx
  ON inventory_batches(seller_id, product_id);
CREATE INDEX orders_buyer_created_idx ON orders(buyer_id, created_at DESC);
CREATE INDEX order_items_order_id_idx ON order_items(order_id);
CREATE INDEX payments_order_id_idx ON payments(order_id);

COMMIT;
