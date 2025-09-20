CREATE SCHEMA pizza_runner;
SET search_path = pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  ;
  
 UPDATE runner_orders
 SET cancellation = NULL
 WHERE cancellation = 'null';


													-- D. Pricing and Ratings
/* 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes -
 how much money has Pizza Runner made so far if there are no delivery fees?
 */
 WITH PROFIT AS
 (
 SELECT co.order_id, customer_id, pizza_id,cancellation,
 CASE
	WHEN cancellation IS NOT NULL THEN 0
	WHEN pizza_id= 1 THEN 12
    WHEN pizza_id =2 THEN 10
 END AS $price
 FROM customer_orders co
 JOIN runner_orders ro
	on co.order_id=ro.order_id
 )
 SELECT sum($price)
 FROM PROFIT
;
 
 
/*2.What if there was an additional $1 charge for any pizza extras?
Add cheese is $1 extra*/
WITH CTE AS
(SELECT co.order_id, customer_id, pizza_id,cancellation, LENGTH(REPLACE(extras,', ','')) as ex_count,
 CASE
	WHEN cancellation IS NOT NULL THEN 0
	WHEN pizza_id= 1 THEN 12 + COALESCE( LENGTH(REPLACE(extras,', ','')),0)
    WHEN pizza_id =2 THEN 10 + COALESCE( LENGTH(REPLACE(extras,', ','')),0) 
 END AS $price_inclusive
 FROM customer_orders CO
 JOIN runner_orders ro
	on co.order_id=ro.order_id
)
SELECT *, SUM($price_inclusive)OVER()
FROM CTE;


/*3.The Pizza Runner team now wants to add an additional ratings system that allows customers to rate 
their runner, how would you design an additional table for this new dataset - generate a schema for 
this new table and insert your own data for ratings for each successful customer order between 1 to 5.*/


CREATE TABLE customer_rating (
order_id INT,
customer_id INT,
runner_id INT,
delivery_speed DECIMAL(10,2),
response_time TIME,
rating INT,
CONSTRAINT check_rating CHECK(rating BETWEEN 1 AND 5)
);
    
 INSERT INTO customer_rating(
	order_id , 
	customer_id , 
	runner_id , 
	delivery_speed , 
	response_time )
SELECT
	CO.order_id, CO.customer_id,
	RO.runner_id,  REPLACE(distance,'km','') / (duration/60) AS delivery_speed,
	TIMEDIFF(pickup_time,order_time) AS response_time
FROM customer_orders CO
JOIN runner_orders RO
	ON CO.order_id=RO.order_id
JOIN runners R
	ON RO.runner_id=R.runner_id;
    
    
				-- SET RATINGS
 UPDATE customer_rating
SET rating=3
WHERE runner_id=1;

UPDATE customer_rating
SET rating=5
WHERE runner_id=2;

UPDATE customer_rating
SET rating=4
WHERE runner_id=3;

UPDATE customer_rating
SET rating= NULL
WHERE runner_id=4;

	SELECT  *
    FROM customer_RATING;
    

/*4.Using your newly generated table - can you join all of the information together to form a table which has the following 
information for successful deliveries?
customer_id
order_id
runner_id
rating
order_time
pickup_time
Time between order and pickup(response time)
Delivery duration
Average speed
Total number of pizzas*/

SELECT* FROM customer_orders;
SELECT* FROM customer_orders;
 


SELECT cr.customer_id, cr.order_id, cr.runner_id, rating ,co.order_time,ro.pickup_time,ro.duration, response_time, 
delivery_speed, COUNT(cr.customer_id) AS total_pizza
FROM customer_rating cr
JOIN customer_orders co
	on cr.order_id =co.order_id
JOIN runner_orders ro
	ON cr.order_id =ro.order_id
GROUP BY cr.customer_id, cr.order_id, cr.runner_id, rating ,co.order_time,ro.pickup_time,ro.duration, response_time, delivery_speed;



/*5.If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner
 is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
*/


WITH CTE AS
(
 SELECT co.order_id, runner_id,distance, 
 CASE
	WHEN pizza_id= 1 THEN 12
    WHEN pizza_id =2 THEN 10
 END AS $price, (distance*0.30)AS rider_margin
 FROM customer_orders co
 JOIN runner_orders ro
	ON 	co.order_id=ro.order_id
), MONEY_LEFT AS
(
SELECT *,  $price -rider_margin AS remainder
FROM CTE
)
SELECT order_id, runner_id, distance, $price, rider_margin, remainder, SUM(remainder)OVER() as Money_left
FROM MONEY_LEFT;