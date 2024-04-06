/************************************	 WINDOW FUNCTIONS 	****************************************************/
/*
	---------------------------------------------------------------------------------------------------------------------
	|	Function				|		Purpose																			|
	----------------------------|---------------------------------------------------------------------------------------|
	|	SUM / MIN / MAX / AVG	|	Get the sum, min, .. of all the records in the partition							|
	|	FIRST_VALUE				|	Return the value evaluated against the first row within the partition.				|
	|	LAST_VALUE				|	Return the value evaluated against the last row within the partition.				|
	|	NTH_VALUE				| 	Return the value evaluated against the nth row in ordered partition.				|
	| 	PERCENT_RANK			|	Return the relative rank of the current row (rank-1) / (total rows - 1)				|
	|	RANK					|	Rank the current row within its partition with gaps.								|
	|	ROW_NUMBER				|	Number the current row within its partition starting from 1. (regardelss of framing)|
	|	LAG / LEAD				|	Access the values from the previous or next row.									|
	--------------------------------------------------------------------------------------------------------------------
*/

/************* 10) FIRST_VALUE ***********/

/* I want to know how my price compares to the item with the LOWEST price in the SAME category */
SELECT 
	prod_id, price, category,
	FIRST_VALUE(price) OVER(
		PARTITION BY category
		ORDER BY price
	) AS "Cheapest in the category"
FROM products
ORDER BY category, prod_id;

-- getting the same result using MIN which is easier, not needing ORDER BY too.
SELECT 
	prod_id, price, category,
	MIN(price) OVER(
		PARTITION BY category
	) AS "Cheapest in the category"
FROM products
ORDER BY category, prod_id;


/************* 11) LAST VALUE ****************/

/* I want to know how my price to the item with the HIGHEST PRICE in the SAME category */
SELECT 
	prod_id, price, category,
	LAST_VALUE(price) OVER(
		PARTITION BY category
		ORDER BY price
		RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
	) AS "Most Expensive Price in Category"
FROM products
ORDER BY category, prod_id;

-- using MAX
SELECT 
	prod_id, price, category,
	MAX(price) OVER(
		PARTITION BY category
	) AS "Highest Price in Category"
FROM products
ORDER BY category, prod_id;


/****************** 12) SUM ************************/

/* I want to see how much Cumulatively a customer has ordered at our store */
SELECT 
	customerid, orderid, orderdate, netamount,
	SUM(netamount) OVER(
		PARTITION BY customerid
		ORDER BY orderid
	) AS "Cumulative Spending"
FROM orders
ORDER BY customerid, orderid;


/**************** 13) ROW_NUMBER ****************/
-- ROW_NUMBER ignores the framing
-- no need to put parameters in ROW_NUMBER() function

/* I want to know where my product is positioned in the category by price */
SELECT 
	category, prod_id, price,
	ROW_NUMBER() OVER(
		PARTITION BY category
		ORDER BY price
	) AS "Position in category by price"
FROM products
ORDER BY category
/*------------------------------------------------------------------------------------------------------------*/

/********************* 13) Conditional Statements ***********************/

/********** CASE ************/
/*
	SELECT a,
		CASE
			WHEN a=1 THEN 'one'
			WHEN a=2 THEN 'two'
			ELSE 'other'
		END
	FROM test;
*/

-- 1) CASE statement can be used anywhere
SELECT 
	orderid, customerid,
	CASE
		WHEN customerid=1 THEN 'my first customer'
		ELSE 'not my first customer'
	END AS "customer status",
	netamount
FROM orders
ORDER BY customerid;

-- 2) using CASE in combination with WHERE
SELECT
	orderid, customerid, netamount
FROM orders
WHERE
	CASE
		WHEN customerid > 10 THEN netamount < 100
		ELSE netamount > 100
	END
ORDER BY customerid;


-- 3) using CASE statement with Aggregate function

/* doing gesture of good faith, refunding 100$ for that order where spending is less than 100$ */
SELECT
	SUM(
		CASE
			WHEN netamount < 100 THEN -100
			ELSE netamount
		END
	) AS "Returns",
	SUM(netamount) AS "Normal Total",
FROM orders;

/* ----------------------------------------------------------------------------------------------------------- */
