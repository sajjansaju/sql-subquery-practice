-- RetailDB: Sample practice database for joins, subqueries (uncorrelated & correlated)

-- Cleanup (PostgreSQL-friendly; ignore errors if running on MySQL/SQLite)
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS customers;

-- Core tables
CREATE TABLE customers (
    customer_id      INT PRIMARY KEY,
    full_name        VARCHAR(100) NOT NULL,
    email            VARCHAR(120) UNIQUE,
    city             VARCHAR(80),
    signup_date      DATE NOT NULL
);

CREATE TABLE categories (
    category_id      INT PRIMARY KEY,
    category_name    VARCHAR(80) NOT NULL
);

CREATE TABLE products (
    product_id       INT PRIMARY KEY,
    product_name     VARCHAR(120) NOT NULL,
    category_id      INT REFERENCES categories(category_id),
    unit_price       NUMERIC(10,2) NOT NULL,
    active           BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE orders (
    order_id         INT PRIMARY KEY,
    customer_id      INT REFERENCES customers(customer_id),
    order_date       DATE NOT NULL,
    status           VARCHAR(20) NOT NULL CHECK (status IN ('pending','paid','shipped','cancelled','refunded'))
);

CREATE TABLE order_items (
    order_item_id    INT PRIMARY KEY,
    order_id         INT REFERENCES orders(order_id),
    product_id       INT REFERENCES products(product_id),
    quantity         INT NOT NULL CHECK (quantity > 0),
    unit_price       NUMERIC(10,2) NOT NULL
);

CREATE TABLE payments (
    payment_id       INT PRIMARY KEY,
    order_id         INT REFERENCES orders(order_id),
    payment_date     DATE NOT NULL,
    method           VARCHAR(20) NOT NULL CHECK (method IN ('card','paypal','bank','giftcard')),
    amount           NUMERIC(10,2) NOT NULL CHECK (amount >= 0)
);

-- Sample data
INSERT INTO customers (customer_id, full_name, email, city, signup_date) VALUES
(1, 'Alice Nguyen', 'alice@example.com', 'Sydney', '2024-01-05'),
(2, 'Bob Patel', 'bob@example.com', 'Melbourne', '2024-01-12'),
(3, 'Charlie Kim', 'charlie@example.com', 'Brisbane', '2024-02-03'),
(4, 'Daisy Chen', 'daisy@example.com', 'Sydney', '2024-02-20'),
(5, 'Evan Lee', 'evan@example.com', 'Perth', '2024-02-25'),
(6, 'Fatima Khan', 'fatima@example.com', 'Adelaide', '2024-03-01'),
(7, 'George Smith', 'george@example.com', 'Hobart', '2024-03-04'),
(8, 'Hannah Brown', 'hannah@example.com', 'Canberra', '2024-03-10'),
(9, 'Ivan Petrov', 'ivan@example.com', 'Darwin', '2024-03-15'),
(10,'Julia Rossi', 'julia@example.com', 'Sydney', '2024-03-20');

INSERT INTO categories (category_id, category_name) VALUES
(1, 'Laptops'),
(2, 'Phones'),
(3, 'Accessories'),
(4, 'Monitors'),
(5, 'Audio');

INSERT INTO products (product_id, product_name, category_id, unit_price, active) VALUES
(101, 'Ultrabook X1', 1, 1899.00, TRUE),
(102, 'Gaming Laptop Z5', 1, 2299.00, TRUE),
(103, 'Budget Laptop A3', 1, 999.00, TRUE),
(201, 'Smartphone Pro', 2, 1299.00, TRUE),
(202, 'Smartphone Lite', 2, 699.00, TRUE),
(301, 'Wireless Mouse', 3, 49.00, TRUE),
(302, 'Mechanical Keyboard', 3, 129.00, TRUE),
(303, 'USB-C Hub', 3, 79.00, TRUE),
(304, 'Laptop Stand', 3, 59.00, TRUE),
(401, '27" 4K Monitor', 4, 499.00, TRUE),
(402, '34" Ultrawide', 4, 899.00, TRUE),
(501, 'Noise-Cancel Headset', 5, 199.00, TRUE),
(502, 'Bluetooth Speaker', 5, 149.00, TRUE);

-- Orders: spread across customers and months
INSERT INTO orders (order_id, customer_id, order_date, status) VALUES
(1001, 1, '2024-03-01', 'paid'),
(1002, 1, '2024-03-22', 'paid'),
(1003, 2, '2024-03-05', 'paid'),
(1004, 2, '2024-03-30', 'cancelled'),
(1005, 3, '2024-04-02', 'paid'),
(1006, 3, '2024-04-14', 'paid'),
(1007, 4, '2024-04-20', 'pending'),
(1008, 5, '2024-04-25', 'paid'),
(1009, 6, '2024-05-01', 'paid'),
(1010, 6, '2024-05-03', 'refunded'),
(1011, 7, '2024-05-05', 'paid'),
(1012, 8, '2024-05-06', 'shipped'),
(1013, 9, '2024-05-07', 'paid'),
(1014,10, '2024-05-08', 'paid'),
(1015,10, '2024-05-20', 'paid');

-- Order items (note: unit_price is copied at time of sale)
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price) VALUES
(1, 1001, 201, 1, 1299.00),
(2, 1001, 301, 1, 49.00),
(3, 1002, 101, 1, 1899.00),
(4, 1002, 302, 1, 129.00),
(5, 1003, 202, 1, 699.00),
(6, 1003, 303, 2, 79.00),
(7, 1004, 301, 2, 49.00),
(8, 1005, 103, 1, 999.00),
(9, 1005, 304, 1, 59.00),
(10,1006, 401, 2, 499.00),
(11,1007, 302, 1, 129.00),
(12,1008, 402, 1, 899.00),
(13,1008, 501, 1, 199.00),
(14,1009, 201, 1, 1299.00),
(15,1009, 303, 1, 79.00),
(16,1010, 501, 1, 199.00),
(17,1011, 502, 2, 149.00),
(18,1012, 401, 1, 499.00),
(19,1013, 102, 1, 2299.00),
(20,1013, 302, 1, 129.00),
(21,1014, 301, 3, 49.00),
(22,1014, 303, 1, 79.00),
(23,1015, 201, 1, 1299.00),
(24,1015, 501, 1, 199.00);

-- Payments (note: some orders have partial/none based on status)
INSERT INTO payments (payment_id, order_id, payment_date, method, amount) VALUES
(1, 1001, '2024-03-01', 'card', 1348.00),   -- 1299 + 49
(2, 1002, '2024-03-22', 'paypal', 2028.00), -- 1899 + 129
(3, 1003, '2024-03-05', 'card', 857.00),    -- 699 + 79*2
(4, 1005, '2024-04-02', 'bank', 1058.00),   -- 999 + 59
(5, 1006, '2024-04-14', 'card', 998.00),    -- 499*2
(6, 1008, '2024-04-25', 'card', 1098.00),   -- 899 + 199
(7, 1009, '2024-05-01', 'card', 1378.00),   -- 1299 + 79
(8, 1010, '2024-05-03', 'card', 199.00),    -- later refunded
(9, 1011, '2024-05-05', 'giftcard', 298.00),
(10,1012, '2024-05-06', 'card', 499.00),
(11,1013, '2024-05-07', 'paypal', 2428.00), -- 2299 + 129
(12,1014, '2024-05-08', 'card', 226.00),    -- 49*3 + 79
(13,1015, '2024-05-20', 'bank', 1498.00);   -- 1299 + 199
