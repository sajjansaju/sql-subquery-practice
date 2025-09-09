# 🛒 RetailDB SQL Practice Project

This repository contains a fully structured PostgreSQL dataset designed for hands-on practice with SQL concepts such as **joins**, **subqueries (correlated & uncorrelated)**, **aggregations**, and **filtering**. It includes a `RetailDB` schema simulating a simple e-commerce business with customers, orders, products, categories, and payments.

## 📁 Contents

- `retaildb_schema.sql` – SQL script to create and populate the database
- `retaildb_queries.sql` – A set of 17 SQL queries demonstrating advanced SQL techniques
- `retaildb_chen_erd_cardinality.png` – Entity-Relationship Diagram (Chen's Notation with cardinality)
- `README.md` – Project overview and instructions
---

## 🧱 Database Schema

The project includes 6 core tables:

- `customers` – Customer profiles and signup dates
- `categories` – Product categories
- `products` – Products with pricing and category info
- `orders` – Customer orders with status
- `order_items` – Line items in each order
- `payments` – Payment details for orders


## 🧩 Entity-Relationship Diagram (ERD)

The following ERD (Chen's Notation with cardinality) illustrates how the tables in the RetailDB schema are related:

![RetailDB Chen ERD with Cardinality](retaildb_chen_erd_cardinality.png)

### 📝 Diagram Notes:
- A **Customer** can place **many Orders**
- An **Order** can include **many Order Items**
- Each **Order Item** refers to **one Product**
- A **Product** belongs to **one Category**
- Each **Order** is associated with **one Payment**

This visualization helps understand the relationships and cardinalities between entities, which is especially useful when working with joins and subqueries.



## ✅ SQL Challenges Covered

| #   | Description                                                                 |
|-----|-----------------------------------------------------------------------------|
| 1️⃣  | Orders with total amount > average order total                             |
| 2️⃣  | Order items priced above product’s average price                           |
| 3️⃣  | Customers with more than one order                                          |
| 4️⃣  | Products priced above average                                               |
| 5️⃣  | Most expensive order per customer                                           |
| 6️⃣  | Active products never ordered                                               |
| 7️⃣  | Customers with paid orders in April 2024                                    |
| 8️⃣  | Orders including “Accessories” category products                            |
| 9️⃣  | Best-selling product per category                                           |
| 🔟  | Category with the highest total revenue                                     |
| 1️⃣1️⃣ | Customers with AOV > global AOV                                             |
| 1️⃣2️⃣ | Customers with orders but no paid/shipped ones                             |
| 1️⃣3️⃣ | Orders where paid amount < item total                                       |
| 1️⃣4️⃣ | Top 3 cities by total revenue                                               |
| 1️⃣5️⃣ | Orders with quantity > average for product                                  |
| 1️⃣6️⃣ | Customers who signed up before 2024-03-01 and ordered after                 |
| 1️⃣7️⃣ | Orders matching the highest order total                                     |



## 🧠 SQL Queries

### 1️⃣ List orders with total amount greater than the average order total (use order_items, subquery for average).
```sql
select order_id, sum( unit_price * quantity)
from order_items
group by order_id
having sum( unit_price * quantity) > (select avg(order_total) from 
											(select order_id, sum( unit_price * quantity) as order_total
												from order_items
												group by order_id ) as sub
												) 
;
```

### 2️⃣ For each order item, show rows where the item’s unit_price is above the average unit_price for that product across all orders.
```sql
select *
from order_items ot1
where unit_price > (select avg(unit_price) from order_items ot2
						where ot1.product_id = ot2.product_id);

-- with our data, the query returns no rows because, in this dataset,
-- each product’s unit_price is the same across all orders. 
-- So for every product_id, unit_price = AVG(unit_price), and our > filter excludes everything.
```

### 3️⃣Find customers who placed more than 1 order (use EXISTS + subquery on orders).
```sql
select customer_id , full_name
from customers c
where exists(
			select 1
			from orders o
			where c.customer_id = o.customer_id
			group by customer_id
			having count(*)>1
);
```

### 4️⃣Show products priced above the overall average product price (from products).
```sql
select *
from products
where unit_price > (select avg(unit_price)from products)
;
```

### 5️⃣ For each customer, return their most expensive single order total (subquery that filters to MAX per customer).
```sql
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
```

### 6️⃣ List active products that have never been ordered.
```sql
select product_name
from products p
where active = 'true' and 
not exists (select 1 from order_items oi 
			where p.product_id = oi.product_id)
;
-- in this dataset every product has been ordered, so the query will return 0 rows.
```

### 7️⃣ Show customers who have at least one paid order in April 2024.
```sql
select p.payment_id ,o.order_id ,o.customer_id ,c.full_name,  p.amount, o.status, p.payment_date from payments p
join orders o
on p.order_id = o.order_id
join customers c
on c.customer_id = o.customer_id
where payment_date between '2024-04-01' and '2024-04-30'
and o.status = 'paid'
;
```


### 8️⃣ List orders that include any product in the “Accessories” category . 
```sql
select *
from order_items
where product_id in 
					(select product_id from products
					 where category_id = (select category_id from categories 
											where category_name like '%Accessories%' ))
;
```


### 9️⃣ For each category, show the best-selling product by quantity (break ties arbitrarily).
```sql
select (select category_name from categories ct
		    where p.category_id = ct.category_id),
	  	p.product_name,
      o.product_id,
      sum(o.quantity) as total_quantity 
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
```



### 🔟 Show the category name with the highest total revenue across all orders.
```sql
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
```


### 1️⃣1️⃣ For each customer, show their average order value and only return those whose AOV is above the global AOV 
```sql
select  c.customer_id, full_name , round(avg(amount),2) as avg_order_value_of_customer
from payments p
join orders o
on p.order_id = o.order_id
join customers c
on o.customer_id = c.customer_id
group by  c.customer_id, full_name 
having round(avg(amount),2) > (select avg(amount) from payments)
;
```

### 1️⃣2️⃣ List customers with no orders( not paid or shipped).
```sql
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
```

### 1️⃣3️⃣ Return orders where sum(payments.amount) is less than the sum(order_items quantity*price)
```sql
select *
from payments p 
where amount < 
				(select sum(quantity* unit_price) as to_be_paid
				from order_items ot
				where ot.order_id = p.order_id
				group by order_id)
;
```


### 1️⃣4️⃣ Find the top 3 cities by total revenue
```sql
select  c.city, sum(p.amount) total_rev
from payments p
join orders o
on p.order_id = o.order_id
join customers c
on o.customer_id = c.customer_id
group by c.city
order by total_rev desc, city asc
limit 3
;
```


### 1️⃣5️⃣ For each product, show orders where the quantity is above that product’s average ordered quantity.
```sql
select order_id,product_id ,quantity, (select product_name from products p  where p.product_id = ot.product_id)
from order_items ot
where quantity > (select avg(ot1.quantity) from order_items ot1
					where ot1.product_id = ot.product_id
					)
;
```



### 1️⃣6️⃣ Show customers who signed up before 2024-03-01 and have at least one order after that singnup date.
```sql
select distinct c.full_name
from customers c
join orders o
on o.customer_id = c.customer_id
where signup_date < '2024-03-01'
and order_date > signup_date
;
```

### 1️⃣7️⃣ Show orders whose total equals the maximum order total overall.
```sql
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
```

