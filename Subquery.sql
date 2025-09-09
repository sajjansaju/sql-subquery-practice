/*
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
*/

-- 1st :List orders with total amount greater than the average order total 
-- (use order_items, subquery for average).
select order_id, sum( unit_price * quantity)
from order_items
group by order_id
having sum( unit_price * quantity) > (select avg(order_total) from 
											(select order_id, sum( unit_price * quantity) as order_total
												from order_items
												group by order_id ) as sub
												) 
;



-- 2nd : For each order item, show rows where the item’s unit_price is 
-- above the average unit_price for that product across all orders.
select *
from order_items ot1
where unit_price > (select avg(unit_price) from order_items ot2
						where ot1.product_id = ot2.product_id);

-- with our data, the query returns no rows because, in this dataset,
-- each product’s unit_price is the same across all orders. 
-- So for every product_id, unit_price = AVG(unit_price), and our > filter excludes everything.




-- 3rd: Find customers who placed more than 1 order (use EXISTS + subquery on orders).
select customer_id , full_name
from customers c
where exists(
			select 1
			from orders o
			where c.customer_id = o.customer_id
			group by customer_id
			having count(*)>1
);



-- 4th: Show products priced above the overall average product price (from products).
select *
from products
where unit_price > (select avg(unit_price)from products)
;



-- 5th For each customer, return their most expensive single order total 
-- (subquery that filters to MAX per customer).

select p.*, customer_id
from payments p
join orders o
on p.order_id = o.order_id
where amount = (select max(p1.amount)
				from payments p1
				join orders o1
				on p1.order_id = o1.order_id
				where o.customer_id = o1.customer_id)
;



-- 6th: List active products that have never been ordered.
select product_name
from products p
where active = 'true' and 
not exists (select 1 from order_items oi 
			where p.product_id = oi.product_id);
-- in this dataset every product has been ordered, so the query will return 0 rows.



-- 7th: Show customers who have at least one paid order in April 2024.
select p.payment_id ,o.order_id ,o.customer_id ,c.full_name,  p.amount, o.status, p.payment_date from payments p
join orders o
on p.order_id = o.order_id
join customers c
on c.customer_id = o.customer_id
where payment_date between '2024-04-01' and '2024-04-30'
and o.status = 'paid'
;



-- 8th:List orders that include any product in the “Accessories” category . 
select *
from order_items
where product_id in 
					(select product_id from products
					 where category_id = (select category_id from categories 
											where category_name like '%Accessories%' ))
;



-- 9th:For each category, show the best-selling product by quantity (break ties arbitrarily).
select (select category_name from categories ct
		where p.category_id = ct.category_id),
		p.product_name, o.product_id, sum(o.quantity) as total_quantity 
from order_items o
join products p
on p.product_id = o.product_id 
group by  p.product_name, o.product_id, p.category_id
having sum(o.quantity) = (select max(total_q)
							from
							(select sum(o1.quantity) as total_q
							from order_items o1
							join products p1
							on p1.product_id = o1.product_id
							where p1.category_id =p.category_id
							group by p1.product_id) as sub )
order by category_id asc, total_quantity desc
;




-- 10th: Show the category name with the highest total revenue across all orders.
select category_name , sum(total) as total_revenue
from (
		select category_name , product_name , (ot.quantity * ot.unit_price ) as total
		from order_items ot
		join products p
		on ot.product_id = p.product_id
		join categories c
		on p.category_id = c.category_id
		) as sub 
group by category_name
order by total_revenue desc
limit 1
;



-- 11th:For each customer, show their average order value and 
-- only return those whose AOV is above the global AOV 
select  c.customer_id, full_name , round(avg(amount),2) as avg_order_value_of_customer
from payments p
join orders o
on p.order_id = o.order_id
join customers c
on o.customer_id = c.customer_id
group by  c.customer_id, full_name 
having round(avg(amount),2) > (select avg(amount) from payments)
;



-- 12th: List customers with no orders( not paid or shipped).
SELECT c.customer_id, c.full_name
FROM customers c
WHERE EXISTS (
  SELECT 1 FROM orders o
  WHERE o.customer_id = c.customer_id
)
AND NOT EXISTS (
  SELECT 1 FROM orders o
  WHERE o.customer_id = c.customer_id
    AND o.status IN ('paid','shipped')
);


-- 13th: Return orders where sum(payments.amount) is less than the sum(order_items quantity*price)
select *
from payments p 
where amount < 
				(select sum(quantity* unit_price) as to_be_paid
				from order_items ot
				where ot.order_id = p.order_id
				group by order_id)
;



-- 14th: Find the top 3 cities by total revenue
select  c.city, sum(p.amount) total_rev
from payments p
join orders o
on p.order_id = o.order_id
join customers c
on o.customer_id = c.customer_id
group by c.city
order by total_rev desc, city asc
limit 3;




-- 15th: For each product, show orders where the quantity is 
-- above that product’s average ordered quantity.
select order_id,product_id ,quantity, (select product_name from products p  where p.product_id = ot.product_id)
from order_items ot
where quantity > (select avg(ot1.quantity) from order_items ot1
					where ot1.product_id = ot.product_id
					)
;




--16th: Show customers who signed up before 2024-03-01 and have at least one order after that singnup date.
select distinct c.full_name
from customers c
join orders o
on o.customer_id = c.customer_id
where signup_date < '2024-03-01'
and order_date > signup_date
;




-- 17th: Show orders whose total equals the maximum order total overall.
WITH order_totals AS (
  SELECT
    oi.order_id,
    SUM(oi.quantity * oi.unit_price) AS order_total
  FROM order_items oi
  GROUP BY oi.order_id
)
SELECT ot.order_id, ot.order_total
FROM order_totals ot
WHERE ot.order_total = (SELECT MAX(order_total) FROM order_totals);


