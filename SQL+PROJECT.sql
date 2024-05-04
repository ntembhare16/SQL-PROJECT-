# QUESTIONS RELATED TO CUSTOMERS
#[Q1] What is the distribution of customers across states?
#Hint: For each state, count the number of customers.*/
	USE NEW_WHEELS;
  SELECT
    state,
    COUNT(customer_id) AS customer_count
FROM
    customer_t
GROUP BY
    state;
  
    
#[Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

#Hint: Use a common table expression and in that CTE, assign numbers to the different customer ratings. 
# Now average the feedback for each quarter. 
use new_wheels;
WITH customer_feedback AS (
    SELECT
        quarter_number,
        AVG(CASE customer_feedback
            WHEN 'Very Bad' THEN 1
            WHEN 'Bad' THEN 2
            WHEN 'Okay' THEN 3
            WHEN 'Good' THEN 4
            WHEN 'Very Good' THEN 5
            ELSE NULL
        END) AS average_rating
    FROM
        order_t
    GROUP BY
        quarter_number
)

SELECT
    quarter_number,
    ROUND(average_rating, 2) AS average_rating
FROM
    customer_feedback;




# [Q3] Are customers getting more dissatisfied over time?

#Hint: Need the percentage of different types of customer feedback in each quarter. Use a common table expression and
	#determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	 # Now use that common table expression to find out the percentage of different types of customer feedback in each quarter.
    #  Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.

    WITH customer_feedback AS (
    SELECT
        quarter_number,
        (COUNT(CASE WHEN customer_feedback = 'Very Bad' THEN 1 END) / COUNT(*) * 100) AS very_bad_percentage,
        (COUNT(CASE WHEN customer_feedback = 'Bad' THEN 1 END) / COUNT(*) * 100) AS bad_percentage,
        (COUNT(CASE WHEN customer_feedback = 'Okay' THEN 1 END) / COUNT(*) * 100) AS okay_percentage,
        (COUNT(CASE WHEN customer_feedback = 'Good' THEN 1 END) / COUNT(*) * 100) AS good_percentage,
        (COUNT(CASE WHEN customer_feedback = 'Very Good' THEN 1 END) / COUNT(*) * 100) AS very_good_percentage
    FROM
        order_t
    GROUP BY
        quarter_number
)

SELECT
    quarter_number,
    very_bad_percentage,
    bad_percentage,
    okay_percentage,
    good_percentage,
    very_good_percentage
FROM
customer_feedback;


#*[Q4] Which are the top 5 vehicle makers preferred by the customer.
#Hint: For each vehicle make what is the count of the customers.*/

SELECT
   vehicle_maker,
    COUNT(product_id) AS customer_count
FROM
    product_t
GROUP BY
    vehicle_maker
ORDER BY
    customer_count DESC
LIMIT 5;

SELECT vehicle_maker,count(product_id) as top5
from new_wheels.product_t
group by vehicle_maker
order by top5 desc
limit 5;

#*[Q5] What is the most preferred vehicle make in each state?

#Hint: Use the window function RANK() to rank based on the count of customers for each state and vehicle maker. 
#After ranking, take the vehicle maker whose rank is 1.*/


WITH RankedVehicleMakes AS (
    SELECT
        c.state,
        p.vehicle_maker,
        RANK() OVER (PARTITION BY c.state ORDER BY COUNT(c.customer_id) DESC) AS preference_rank
    FROM
        customer_t c
    JOIN
        new_wheels.order_t o ON c.customer_id = o.customer_id
    JOIN
        new_wheels.product_t p ON o.product_id = p.product_id
    GROUP BY
        c.state,
        p.vehicle_maker
)

SELECT
    state,
    vehicle_maker
FROM
    RankedVehicleMakes
WHERE
    preference_rank = 1;

-- [Q6] What is the trend of number of orders by quarters?

#Hint: Count the number of orders for each quarter.*/
-- Second SELECT statement

SELECT
    quarter_number,
    COUNT(order_id) AS order_count
FROM
    new_wheels.order_t
GROUP BY
    quarter_number
ORDER BY
    quarter_number;


 #[Q7] What is the quarter over quarter % change in revenue? 

#Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
      #To calculate you need to use the common table expression to find out the sum of revenue for each quarter.
    #  Then use that CTE along with the LAG function to calculate the QoQ percentage change in revenue.
    

 
WITH RevenueByQuarter AS (
    SELECT
        quarter_number,
        SUM(vehicle_price) AS total_revenue
    FROM
        new_wheels.order_t
    GROUP BY
        quarter_number
)

SELECT
    quarter_number,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY quarter_number) AS previous_quarter_revenue,
    ROUND((total_revenue - LAG(total_revenue) OVER (ORDER BY quarter_number)) / LAG(total_revenue) OVER (ORDER BY quarter_number) * 100, 2) AS qoq_percentage_change
FROM
    RevenueByQuarter
ORDER BY
    quarter_number;


#* [Q8] What is the trend of revenue and orders by quarters?

#Hint: Find out the sum of revenue and count the number of orders for each quarter.*/

    SELECT
    quarter_number,
    SUM(vehicle_price) AS total_revenue,
    COUNT(order_id) AS order_count
FROM
    order_t
GROUP BY
    quarter_number
ORDER BY
    quarter_number;
    
    
    
   # * QUESTIONS RELATED TO SHIPPING 
   # [Q9] What is the average discount offered for different types of credit cards?

#Hint: Find out the average of discount for each credit card type.*/




SELECT
    c.credit_card_type,
    AVG(o.discount) AS average_discount
FROM
    customer_t c
JOIN
    order_t o ON c.customer_id = o.customer_id
GROUP BY
    c.credit_card_type;
    
    
    # [Q10] What is the average time taken to ship the placed orders for each quarters?
	#Hint: Use the dateiff function to find the difference between the ship date and the order date.

SELECT
    quarter_number,
    AVG(DATEDIFF(ship_date, order_date)) AS average_shipping_time
FROM
    order_t
GROUP BY
    quarter_number;

