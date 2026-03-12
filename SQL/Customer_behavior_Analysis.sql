SELECT * FROM customer_behavior;

-- Q1 what is the total revenue genrated by male vs female customers ?

SELECT gender , SUM(purchased_amount) AS revenue 
FROM customer
GROUP BY gender;  -- Male 1,57,890 & Female 75,191

-- Q2 which Consumer used a discount but still spent more then the average purchase amount ?

SELECT customer_id, purchased_amount 
FROM customer
WHERE discount_applied = 'Yes' AND purchased_amount >= (
select AVG(purchased_amount) FROM customer
);
 
-- Q3 which are the top 5 products with the highest average review rating?

SELECT item_purchased , ROUND(AVG(review_rating),1) AS "Average Product Rating"
FROM customer
GROUP BY item_purchased
ORDER BY AVG(review_rating) DESC 
LIMIT 5;

-- Q4 Compare the avearage purchase Amount between Stander and Express Shipping?
SELECT shipping_type, ROUND(AVG(purchased_amount),2)
FROM customer
WHERE shipping_type in ('Standard', 'Express')
GROUP BY shipping_type;

-- Q5 Do Suscribed customers spend more? comapre average spend and total revenue between suscribers and un-suscribers?

SELECT subscription_status, 
COUNT(customer_id) as Total_customers ,
ROUND(AVG(purchased_amount),2) as avg_spend,
ROUND(SUM(purchased_amount),2) as total_revenue
FROM customer
GROUP BY subscription_status 
ORDER BY total_revenue,avg_spend DESC;

-- Q6 which 5 Product have the Highest Percentage of Purchase with Discount applied?

SELECT item_purchased,
ROUND(100*SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)/count(*),2) AS discount_rate
FROM customer
GROUP BY item_purchased 
ORDER BY  discount_rate DESC 
LIMit 5;
  
  -- Q7. Segment customers into New, Returning, and Loyal Based on their Total
  -- number of privious purchases , and show the count of each segment .
  
WITH customer_type as (
SELECT customer_id , previous_purchases,
CASE
	WHEN previous_purchases = 1 THEN 'New'
	WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
	ELSE 'Loyal'
	END AS customer_segment
FROM customer)

SELECT customer_segment, COUNT(*) AS 'Number of customer'
FROM customer_type
GROUP BY customer_segment;

-- Q8 what are the top 3 most purchased products within each category?

WITH item_counts as(
SELECT category,
item_purchased,
COUNT(customer_id) as total_orders,
ROW_number() OVER(PARTITION BY category ORDER BY COUNT(customer_id) DESC) AS item_rank
FROM customer
GROUP BY category, item_purchased
)

SELECT item_rank, category, item_purchased, total_orders
FROM item_counts
WHERE item_rank <= 3;

-- Q9 Are customers who are repeat buyer (more than 5 previous purchases) also likely to suscribe?

SELECT subscription_status,
COUNT(customer_id) AS repeat_buyers
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;

-- Q10 what is the revenue contribution of each age group?

SELECT age_group,
SUM(purchased_amount) AS total_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue DESC;
