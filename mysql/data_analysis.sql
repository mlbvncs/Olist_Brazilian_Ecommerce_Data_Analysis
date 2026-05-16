-- 1. What is the overall rate of delays and how has it evolved over time?
CREATE VIEW q_1 AS
SELECT purchase_year_month, 
	   ROUND(((COUNT(CASE WHEN delivery_delay_days > 0 THEN 1 END)/COUNT(delivery_delay_days))*100.0), 2) AS delay_fee_percent
FROM orders 
GROUP BY purchase_year_month
ORDER BY purchase_year_month;

-- 2. Which states have the longest average delivery time and the highest delay rate?
CREATE VIEW q_2 AS
SELECT c.customer_state AS state, 
       ROUND(AVG(o.delivery_delay_days), 2) AS avg_delivery_time,
       ROUND(((COUNT(CASE WHEN o.delivery_delay_days > 0 THEN 1 END)/COUNT(o.delivery_delay_days))*100.0), 2) AS delay_fee_percent
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY delay_fee_percent DESC;

-- 3. Which product categories experience the most delivery delays?
CREATE VIEW q_3 AS
SELECT p.product_category_name, 
       ROUND((COUNT(CASE WHEN o.delivery_delay_days > 0 THEN 1 END)/COUNT(o.delivery_delay_days)*100.0), 2) AS delivery_delay_percent
FROM products p
INNER JOIN order_items ot ON p.product_id = ot.product_id
INNER JOIN orders o ON ot.order_id = o.order_id
GROUP BY p.product_category_name
ORDER BY delivery_delay_percent DESC;

-- 4. Is there a correlation between shipping cost and delivery time?
CREATE VIEW q_4 AS
SELECT o.delivery_time_days AS delivery_time,
       ot.freight_value
FROM orders o
INNER JOIN order_items ot ON o.order_id = ot.order_id
ORDER BY delivery_time DESC;

-- 5. What is the average time between order approval and shipment by the seller?
-- and which sellers take the longest?
CREATE VIEW q_5 AS
SELECT s.seller_id, 
       ROUND(AVG(o.approval_to_carrier_days), 2) AS avg_time
FROM sellers s
INNER JOIN order_items ot ON s.seller_id = ot.seller_id
INNER JOIN orders o ON ot.order_id = o.order_id
GROUP BY s.seller_id
ORDER BY avg_time DESC;

-- 6. How has the volume of orders and revenue evolved over time?
CREATE VIEW q_6 AS
SELECT o.purchase_year_month,
	   COUNT(o.order_id) AS orders,
	   ROUND(SUM(op.payment_value), 2) AS revenue
FROM orders o
INNER JOIN order_payments op ON o.order_id = op.order_id
GROUP BY o.purchase_year_month
ORDER BY o.purchase_year_month;

-- 7. Which product categories generate the most revenue, and what is the average order value per category?
CREATE VIEW q_7 AS
SELECT p.product_category_name, 
	   ROUND(SUM(op.payment_value), 2) AS renevue,
       ROUND(AVG(op.payment_value), 2) AS avg_payment_value
FROM products p
INNER JOIN order_items ot ON p.product_id = ot.product_id
INNER JOIN orders o ON ot.order_id = o.order_id
INNER JOIN order_payments op ON ot.order_id = op.order_id
GROUP BY p.product_category_name
ORDER BY renevue DESC;

-- 8. Which states generate the most orders and the most revenue?
CREATE VIEW q_8 AS
SELECT c.customer_state AS state,
	   COUNT(o.order_id) AS orders,
       ROUND(SUM(op.payment_value), 2) AS renevue
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN order_payments op ON o.order_id = op.order_id 
GROUP BY c.customer_state
ORDER BY orders DESC, renevue DESC;

-- 9. What is the most commonly used payment method and which one generates the highest average order value?
CREATE VIEW q_9 AS
SELECT op.payment_type,
       COUNT(op.order_id) AS orders,
       ROUND(AVG(op.payment_value), 2) AS avg_payment_value
FROM order_payments op
GROUP BY op.payment_type
ORDER BY orders DESC, avg_payment_value DESC;

-- 10. Do installment orders have a higher average order value than cash orders?
CREATE VIEW q_10 AS
SELECT op.payment_method,
       ROUND(AVG(op.payment_value), 2) AS avg_payment_value
FROM order_payments op
GROUP BY payment_method
ORDER BY avg_payment_value DESC;

-- 11. What is the distribution of evaluations and how has the average grade evolved over time?
CREATE VIEW q_11 AS
SELECT o.purchase_year_month,
       ROUND(AVG(ow.review_score), 2) AS avg_grade
FROM order_reviews ow
INNER JOIN orders o ON ow.order_id = o.order_id
GROUP BY o.purchase_year_month
ORDER BY o.purchase_year_month;

-- 12. Is there a correlation between late delivery and evaluation grades?
CREATE VIEW q_12 AS
SELECT  o.delivery_delay_days, ow.review_score
FROM order_reviews ow
INNER JOIN orders o ON ow.order_id = o.order_id
WHERE o.delivery_delay_days > 0
ORDER BY o.delivery_delay_days DESC;

-- 13. Which product categories receive the worst ratings?
CREATE VIEW q_13 AS
SELECT p.product_category_name, 
	   ROUND(AVG(ow.review_score), 2) AS avg_score,
       COUNT(ow.review_id) AS total_reviews
FROM products p
INNER JOIN order_items oi ON p.product_id = oi.product_id
INNER JOIN order_reviews ow ON oi.order_id = ow.order_id
GROUP BY p.product_category_name
ORDER BY avg_score ASC;

-- 14. Do sellers with longer shipping times receive worse ratings?
CREATE VIEW q_14 AS
SELECT oi.seller_id, 
       ROUND(AVG(o.full_delivery_days), 2) AS avg_shipping_days,
       ROUND(AVG(ow.review_score), 2) AS avg_review_score,
       COUNT(DISTINCT o.order_id) AS total_orders
FROM order_items oi
INNER JOIN orders o ON oi.order_id = o.order_id
INNER JOIN order_reviews ow ON o.order_id = ow.order_id
GROUP BY oi.seller_id
ORDER BY avg_shipping_days DESC;

-- 15. Which salespeople concentrate the most orders and the most revenue?
CREATE VIEW q_15 AS
SELECT oi.seller_id,
       ROUND(COUNT(DISTINCT oi.order_id), 2) AS total_orders,
	   ROUND(SUM(oi.total_item_value), 2) AS total_revenue
FROM order_items oi
GROUP BY oi.seller_id
ORDER BY total_revenue DESC, total_orders DESC;

-- 16. Is there a correlation between the seller's location and the delivery time?
CREATE VIEW q_16 AS
SELECT s.seller_state,
	   c.customer_state,
       ROUND(AVG(o.estimated_vs_carrier_days), 2) as avg_delivery_time,
       COUNT(o.order_id) AS total_orders
FROM sellers s
INNER JOIN order_items oi ON s.seller_id = oi.seller_id
INNER JOIN orders o ON oi.order_id = o.order_id
INNER JOIN customers c ON o.customer_id = c.customer_id
GROUP BY s.seller_state, c.customer_state
ORDER BY avg_delivery_time DESC;