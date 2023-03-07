```sql
CREATE database dannys_diner;
USE dannys_diner;
CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  ----------------
  -- Case Study --
  ----------------
  -- 1. What is the total amount each customer spent at the restaurant?
  
 SELECT s.customer_id, SUM(price) as Total_sales FROM sales s
 JOIN menu m on s.product_id=m.product_id
 Group by s.customer_id;
 
 -- 2. How many days has each customer visited the restaurant?
 SELECT customer_id, COUNT(distinct(order_date)) as Visits from sales 
 GROUP BY customer_id;
 
-- 3. What was the first item from the menu purchased by each customer?
 
 WITH ranked_orders as
	(SELECT s.customer_id, s.order_date, m.product_name, 
		DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) as ranking
	FROM Sales s
	JOIN menu m on s.product_id=m.product_id)
SELECT customer_id, product_name FROM ranked_orders
WHERE ranking = 1
GROUP BY customer_id, product_name;
  
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers? 

 SELECT m.product_name, COUNT(s.product_id) as most_purchased 
 FROM Sales s
 JOIN menu m on s.product_id=m.product_id
 GROUP BY m.product_name
 ORDER BY most_purchased desc
 LIMIT 1;
 
 -- 5. Which item was the most popular for each customer?
 
 WITH most_popular as
	(SELECT s.customer_id, m.product_name, COUNT(s.product_id) as order_count,
		DENSE_RANK() OVER(partition by s.customer_id order by COUNT(s.product_id) DESC) as ranking
	FROM Sales s
	JOIN menu m on s.product_id=m.product_id
	GROUP BY m.product_name, s.customer_id)
SELECT customer_id, product_name, order_count FROM most_popular
WHERE ranking = 1;

-- 6. Which item was purchased first by the customer after they became a member?

WITH first_order_after_member AS
	(SELECT s.customer_id, s.order_date, m.product_name,
		DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) as ranking
	FROM sales s 
	JOIN members mem ON s.customer_id=mem.customer_id
	JOIN menu m ON s.product_id=m.product_id
	WHERE mem.join_date<=s.order_date)
SELECT customer_id, order_date, product_name FROM first_order_after_member
WHERE ranking=1;

-- 7. Which item was purchased just before the customer became a member?

WITH first_order_before_member AS
	(SELECT s.customer_id, s.order_date, mem.join_date, m.product_name,
		DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date desc) as ranking
	FROM sales s 
	JOIN members mem ON s.customer_id=mem.customer_id
	JOIN menu m ON s.product_id=m.product_id
	WHERE mem.join_date>s.order_date)
SELECT customer_id, order_date, product_name FROM first_order_before_member
WHERE ranking=1;

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id, COUNT(DISTINCT(s.product_id)) AS count, SUM(m.price) AS Total_Spent
FROM sales s 
JOIN members mem ON s.customer_id=mem.customer_id
JOIN menu m ON s.product_id=m.product_id
WHERE mem.join_date>s.order_date
GROUP BY s.customer_id;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH product_price_points AS
	(SELECT *,
		CASE WHEN product_name="sushi" THEN price*20
		ELSE price*10 END AS points
	FROM menu)
SELECT s.customer_id, SUM(p.points) as Total_points FROM product_price_points  p 
JOIN sales s on p.product_id=s.product_id
GROUP BY s.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
-- 1. Find member validity date of each customer and get last date of January
-- 2. Use CASE WHEN to allocate points by date and product id
-- 3. SUM price and points

WITH dates AS 
(
	SELECT 
    *, 
    DATE_ADD(join_date, INTERVAL 6 Day) AS valid_date, 
	LAST_DAY('2021-01-31') AS last_date
	FROM members AS m
)

SELECT  
  d.customer_id, s.order_date, d.join_date, d.valid_date, d.last_date, m.product_name, m.price,
SUM(CASE 
		WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price
		WHEN s.order_date BETWEEN d.join_date AND d.valid_date THEN 2 * 10 * m.price
		ELSE 10 * m.price END) AS points
FROM dates AS d
JOIN sales AS s
	ON d.customer_id = s.customer_id
JOIN menu AS m
	ON s.product_id = m.product_id
WHERE s.order_date < d.last_date
GROUP BY d.customer_id, s.order_date, d.join_date, d.valid_date, d.last_date, m.product_name, m.price
```
