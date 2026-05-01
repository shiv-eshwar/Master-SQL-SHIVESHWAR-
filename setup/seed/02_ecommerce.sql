DROP SCHEMA IF EXISTS ecommerce CASCADE;
CREATE SCHEMA ecommerce;

CREATE TABLE ecommerce.customers (
    customer_id integer PRIMARY KEY,
    signup_date date NOT NULL,
    country text NOT NULL,
    acquisition_channel text NOT NULL,
    device_type text NOT NULL,
    is_premium boolean NOT NULL DEFAULT false
);

CREATE TABLE ecommerce.products (
    product_id integer PRIMARY KEY,
    category text NOT NULL,
    brand text NOT NULL,
    product_name text NOT NULL,
    unit_price numeric(10, 2) NOT NULL CHECK (unit_price > 0)
);

CREATE TABLE ecommerce.orders (
    order_id bigint PRIMARY KEY,
    customer_id integer NOT NULL REFERENCES ecommerce.customers(customer_id),
    order_ts timestamptz NOT NULL,
    status text NOT NULL CHECK (status IN ('placed', 'shipped', 'delivered', 'cancelled', 'refunded')),
    payment_method text NOT NULL,
    shipping_fee numeric(10, 2) NOT NULL DEFAULT 0,
    discount_amount numeric(10, 2) NOT NULL DEFAULT 0
);

CREATE TABLE ecommerce.order_items (
    order_id bigint NOT NULL REFERENCES ecommerce.orders(order_id),
    line_number integer NOT NULL,
    product_id integer NOT NULL REFERENCES ecommerce.products(product_id),
    quantity integer NOT NULL CHECK (quantity > 0),
    unit_price numeric(10, 2) NOT NULL CHECK (unit_price > 0),
    PRIMARY KEY (order_id, line_number)
);

CREATE TABLE ecommerce.events (
    event_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id integer NOT NULL REFERENCES ecommerce.customers(customer_id),
    event_ts timestamptz NOT NULL,
    session_id text NOT NULL,
    event_name text NOT NULL,
    page_name text,
    order_id bigint
);

INSERT INTO ecommerce.customers (customer_id, signup_date, country, acquisition_channel, device_type, is_premium) VALUES
(1, DATE '2023-01-04', 'India', 'Organic', 'mobile', false),
(2, DATE '2023-01-07', 'India', 'Paid Search', 'desktop', true),
(3, DATE '2023-01-13', 'India', 'Referral', 'mobile', false),
(4, DATE '2023-02-02', 'UAE', 'Organic', 'mobile', false),
(5, DATE '2023-02-17', 'India', 'Affiliate', 'desktop', true),
(6, DATE '2023-03-03', 'Singapore', 'Paid Social', 'mobile', false),
(7, DATE '2023-03-25', 'India', 'Organic', 'tablet', false),
(8, DATE '2023-04-11', 'US', 'Referral', 'desktop', true),
(9, DATE '2023-04-19', 'India', 'Paid Search', 'mobile', false),
(10, DATE '2023-05-06', 'India', 'Organic', 'desktop', true),
(11, DATE '2023-06-01', 'UK', 'Organic', 'mobile', false),
(12, DATE '2023-06-21', 'India', 'Affiliate', 'mobile', false);

INSERT INTO ecommerce.products (product_id, category, brand, product_name, unit_price) VALUES
(101, 'Laptop', 'Acme', 'Acme Air 13', 85000),
(102, 'Laptop', 'Acme', 'Acme Pro 15', 125000),
(103, 'Phone', 'Nova', 'Nova X', 65000),
(104, 'Phone', 'Nova', 'Nova Mini', 42000),
(105, 'Accessory', 'Acme', 'Acme Wireless Mouse', 2200),
(106, 'Accessory', 'SoundMax', 'SoundMax Headphones', 4800),
(107, 'Tablet', 'Nova', 'Nova Tab 11', 37000),
(108, 'Accessory', 'Acme', 'USB-C Hub', 3200);

INSERT INTO ecommerce.orders (order_id, customer_id, order_ts, status, payment_method, shipping_fee, discount_amount) VALUES
(10001, 1, TIMESTAMPTZ '2023-01-10 10:15:00+05:30', 'delivered', 'card', 99, 0),
(10002, 2, TIMESTAMPTZ '2023-01-11 12:30:00+05:30', 'delivered', 'upi', 0, 5000),
(10003, 3, TIMESTAMPTZ '2023-01-20 17:40:00+05:30', 'cancelled', 'card', 0, 0),
(10004, 2, TIMESTAMPTZ '2023-02-14 14:00:00+05:30', 'refunded', 'upi', 0, 3000),
(10005, 4, TIMESTAMPTZ '2023-02-21 20:05:00+05:30', 'delivered', 'card', 199, 0),
(10006, 5, TIMESTAMPTZ '2023-03-02 09:10:00+05:30', 'delivered', 'card', 0, 2500),
(10007, 6, TIMESTAMPTZ '2023-03-09 11:50:00+05:30', 'shipped', 'wallet', 149, 0),
(10008, 7, TIMESTAMPTZ '2023-03-27 16:20:00+05:30', 'delivered', 'upi', 0, 500),
(10009, 8, TIMESTAMPTZ '2023-04-14 19:25:00+05:30', 'delivered', 'card', 0, 7000),
(10010, 9, TIMESTAMPTZ '2023-04-22 08:45:00+05:30', 'delivered', 'upi', 99, 0),
(10011, 10, TIMESTAMPTZ '2023-05-08 21:00:00+05:30', 'placed', 'card', 0, 1500),
(10012, 10, TIMESTAMPTZ '2023-06-01 10:00:00+05:30', 'delivered', 'card', 0, 0),
(10013, 11, TIMESTAMPTZ '2023-06-15 13:35:00+05:30', 'delivered', 'card', 199, 1200),
(10014, 12, TIMESTAMPTZ '2023-07-03 15:10:00+05:30', 'delivered', 'upi', 99, 0);

INSERT INTO ecommerce.order_items (order_id, line_number, product_id, quantity, unit_price) VALUES
(10001, 1, 105, 1, 2200),
(10001, 2, 106, 1, 4800),
(10002, 1, 101, 1, 85000),
(10003, 1, 104, 1, 42000),
(10004, 1, 103, 1, 65000),
(10005, 1, 107, 1, 37000),
(10005, 2, 108, 1, 3200),
(10006, 1, 102, 1, 125000),
(10006, 2, 105, 2, 2200),
(10007, 1, 106, 1, 4800),
(10008, 1, 104, 1, 42000),
(10008, 2, 108, 1, 3200),
(10009, 1, 102, 1, 125000),
(10009, 2, 106, 1, 4800),
(10010, 1, 105, 3, 2200),
(10011, 1, 103, 1, 65000),
(10012, 1, 107, 1, 37000),
(10013, 1, 104, 1, 42000),
(10013, 2, 105, 1, 2200),
(10014, 1, 101, 1, 85000);

INSERT INTO ecommerce.events (customer_id, event_ts, session_id, event_name, page_name, order_id) VALUES
(1, TIMESTAMPTZ '2023-01-10 09:58:00+05:30', 's1', 'page_view', 'home', NULL),
(1, TIMESTAMPTZ '2023-01-10 10:01:00+05:30', 's1', 'page_view', 'product', NULL),
(1, TIMESTAMPTZ '2023-01-10 10:05:00+05:30', 's1', 'add_to_cart', 'cart', NULL),
(1, TIMESTAMPTZ '2023-01-10 10:15:00+05:30', 's1', 'purchase', 'checkout', 10001),
(2, TIMESTAMPTZ '2023-01-11 12:00:00+05:30', 's2', 'page_view', 'home', NULL),
(2, TIMESTAMPTZ '2023-01-11 12:08:00+05:30', 's2', 'page_view', 'product', NULL),
(2, TIMESTAMPTZ '2023-01-11 12:18:00+05:30', 's2', 'purchase', 'checkout', 10002),
(4, TIMESTAMPTZ '2023-02-21 19:40:00+05:30', 's4', 'page_view', 'landing', NULL),
(4, TIMESTAMPTZ '2023-02-21 19:50:00+05:30', 's4', 'add_to_cart', 'cart', NULL),
(4, TIMESTAMPTZ '2023-02-21 20:05:00+05:30', 's4', 'purchase', 'checkout', 10005),
(5, TIMESTAMPTZ '2023-03-02 08:30:00+05:30', 's5', 'page_view', 'home', NULL),
(5, TIMESTAMPTZ '2023-03-02 08:42:00+05:30', 's5', 'page_view', 'product', NULL),
(5, TIMESTAMPTZ '2023-03-02 09:10:00+05:30', 's5', 'purchase', 'checkout', 10006),
(10, TIMESTAMPTZ '2023-06-01 09:15:00+05:30', 's10', 'page_view', 'home', NULL),
(10, TIMESTAMPTZ '2023-06-01 09:20:00+05:30', 's10', 'page_view', 'search', NULL),
(10, TIMESTAMPTZ '2023-06-01 10:00:00+05:30', 's10', 'purchase', 'checkout', 10012);
