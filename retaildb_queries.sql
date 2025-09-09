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


