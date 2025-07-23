
  USE gl_db;
  
  
 
  -- View Creation for veh_ord_cust_v

CREATE VIEW ord_cust_v AS 
SELECT o.order_id, o.shipper_id, o.customer_id, o. product_id, o.order_date, o.ship_date,
o.ship_mode, o.shipping, o.discount, o.vehicle_price, o.quantity, o.customer_feedback, o.quarter_number,
 c.customer_name, c.gender, c.job_title, c.phone_number, c.email_address, c.city, c.country, c.state, c.customer_address, 
 c.postal_code, c.credit_card_type, c.credit_card_number 
FROM order_t AS o 
INNER JOIN customer_t AS c ON o.customer_id= c.customer_id;

-- View Creation for veh_prod_cust_v

CREATE VIEW prod_cust_v AS 
SELECT c.customer_name, c.gender, c.job_title, c.phone_number, c.email_address, c.city, c.country, c.state, 
c.customer_address, c.postal_code, c.credit_card_type, c.credit_card_number, p.product_id, p.vehicle_maker, 
p.vehicle_model, p.vehicle_color, p.vehicle_model_year, p.vehicle_price 
FROM order_t AS o 
INNER JOIN customer_t AS c 
ON o.customer_id= c.customer_id
 INNER JOIN product_t p 
 ON o.product_id= p.product_id;
  
  
  
  
/*-- QUESTIONS RELATED TO CUSTOMERS
     [Q1] What is the distribution of customers across states?
     Hint: For each state, count the number of customers.*/
SELECT state, Count(*) as  count
  FROM customer_t
  GROUP BY state;
 


  

/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

Hint: Use a common table expression and in that CTE, assign numbers to the different customer ratings. 
      Now average the feedback for each quarter. */
 SELECT quarter_number,avg( CASE customer_feedback 
  WHEN 'Bad' THEN 2
  WHEN 'Very Bad' THEN 1
  WHEN 'Okay' THEN 3
  WHEN 'Good' THEN 4
  ELSE 5 end ) AS Average_rating from order_t
  GROUP BY quarter_number
  ORDER BY quarter_number;
  
  
/* [Q3] Are customers getting more dissatisfied over time?

Hint: Need the percentage of different types of customer feedback in each quarter. Use a common table expression and
	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	  Now use that common table expression to find out the percentage of different types of customer feedback in each quarter.
      Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.
      */
      WITH feedback_bucket AS 
      ( SELECT customer_id, quarter_number, 
      CASE customer_feedback 
      WHEN 'Very Bad' THEN 1 
      WHEN 'Bad' THEN 2 
      WHEN 'Okay' THEN 3 
      WHEN 'Good' THEN 4
      WHEN 'Very Good' THEN 5 
      END AS feedback 
      FROM order_t ) 
      SELECT SUM(feedback) AS total_feedback, COUNT(feedback), quarter_number 
      FROM feedback_bucket 
      GROUP BY 3
      ORDER BY quarter_number;
      /* Yes, customers are more dissatisfied over time. */
      

/*[Q4] Which are the top 5 vehicle makers preferred by the customer.

Hint: For each vehicle make what is the count of the customers.*/

SELECT vehicle_maker, SUM(quantity) as count_cust FROM order_t
JOIN product_t p
ON p.product_id = order_t.product_id
GROUP BY vehicle_maker
ORDER BY count_cust desc
LIMIT 5;

/*[Q5] What is the most preferred vehicle make in each state?

Hint: Use the window function RANK() to rank based on the count of customers for each state and vehicle maker. 
After ranking, take the vehicle maker whose rank is 1.*/
SELECT COUNT(customer_id) AS cust_count, 
p.vehicle_maker, o.state, 
RANK() OVER(PARTITION BY o.state ORDER BY p.vehicle_maker) Vehicle_rank
FROM ord_cust_v o 
INNER JOIN prod_cust_v AS p 
ON o.product_id=p.product_id 
GROUP BY o.state,p.vehicle_maker
;

/*QUESTIONS RELATED TO REVENUE and ORDERS 

-- [Q6] What is the trend of number of orders by quarters?

Hint: Count the number of orders for each quarter.*/

SELECT COUNT(order_id) AS orders_count, quarter_number 
FROM ord_cust_v GROUP BY quarter_number;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q7] What is the quarter over quarter % change in revenue? 

Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
      To calculate you need to use the common table expression to find out the sum of revenue for each quarter.
      Then use that CTE along with the LAG function to calculate the QoQ percentage change in revenue.
*/
      
      

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q8] What is the trend of revenue and orders by quarters?

Hint: Find out the sum of revenue and count the number of orders for each quarter.*/
SELECT  count(customer_id) as total_orders,quarter_number ,sum(vehicle_price - vehicle_price*discount) as revenue
FROM ord_cust_v 
GROUP BY quarter_number
ORDER BY quarter_number;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* QUESTIONS RELATED TO SHIPPING 
    [Q9] What is the average discount offered for different types of credit cards?

Hint: Find out the average of discount for each credit card type.*/

SELECT AVG(discount) AS avg_discount, credit_card_type 
FROM ord_cust_v 
GROUP BY credit_card_type;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q10] What is the average time taken to ship the placed orders for each quarters?
	Hint: Use the dateiff function to find the difference between the ship date and the order date.
*/
SELECT quarter_number, AVG(datediff(ship_date, order_date)) AS days 
FROM ord_cust_v 
GROUP BY quarter_number 
ORDER BY quarter_number;

-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------



