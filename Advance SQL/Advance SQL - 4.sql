/*************************** 21- When to use which Algorithms? *************************/
/*
			********* B-TREE ***********
			Default Algorithm
			Best Used for COMPARISONS with
				<, >
				<=, >=
				=
				BETWEEN
				IN
				IS NULL
				IS NOT NULL
				
				
			**********  HASH **********
			Can only handle Equality = Operations.	
			
			
			*********** GIN (Generalized Inverted Index) ************
			Best used when Multiple Values are stored in a Single Field.
			
			
			*********** GIST (Generalized Search Tree) ***********
			Useful in Indexing Geometric Data and Full-Text Search.
*/

-- testing for HASH
EXPLAIN ANALYZE
SELECT "name", district, countrycode
FROM city
WHERE countrycode='BEL' OR countrycode='TUN' OR countrycode='NL';


/* ----------------------------------------------------------------------------------------------------------- */

/********************** 22) Subqueries ************************/
/*
	Subqueries can be used in SELECT, FROM, HAVING, WHERE.
	
	For HAVING and WHERE clause, subquery must return SINGLE value record.
*/

SELECT 
	title, price, 
	(SELECT AVG(price) FROM products) AS "global average price"
FROM products;


-- Subquery can returns A Single Result or Row Sets
SELECT 
	title, price, 
	(SELECT AVG(price) FROM products) AS "global average price" -- return single result
FROM (
	SELECT * FROM products -- return row sets
) AS "products_sub";

/************ 23) Types of Subqueries *************/
/*
	Single Row
	Multiple Row
	Multiple Column
	Correlated
	Nested
*/

-- Single Row: returns Zero or One Row
SELECT emp_no, salary
FROM salaries
WHERE salary > (
	SELECT AVG(salary) FROM salaries
);

-- Multiple Row: returns One or More Rows
SELECT title, price, category
FROM products
WHERE category IN (
	SELECT category FROM categories
	WHERE categoryname IN ('Comedy', 'Family', 'Classics')
);

-- Multiple Columns: returns ONE or More columns
SELECT emp_no, salary, dea.avg AS "Department average salary"
FROM salaries s
JOIN dept_emp as de USING(emp_no)
JOIN(
	SELECT dept_no, AVG(salary) FROM salaries AS s2
	JOIN dept_emp AS de2 USING(emp_no)
	GROUP BY dept_no
) AS dea USING (dept_no)
WHERE salary > dea.avg;


-- Correlated: Reference ONE or More columns in the OUTER statement - Runs against Each Row
/* Get the most recent salary of employee */
SELECT emp_no, salary AS "most recent salary", from_date
FROM salaries AS s
WHERE from_date = (
	SELECT MAX(s2.from_date) AS max
	FROM salaries AS s2
	WHERE s2.emp_no = s.emp_no
)
ORDER BY emp_no;


-- Nested : Subquery in Subquery
SELECT orderlineid, prod_id, quantity
FROM orderlines
JOIN(
	SELECT prod_id
	FROM products
	WHERE category IN(
		SELECT category FROM categories
		WHERE categoryname IN('Comedy', 'Family', 'Classics')
	)
) AS limited USING(prod_id);

/*************** 24) Using Subqueries ************/
SELECT 
	first_name,
	last_name,
	birth_date,
	AGE(birth_date)
FROM employees
WHERE AGE(birth_date) > (SELECT AVG(AGE(birth_date)) FROM employees);


/* Show the salary with title of the employee using Subquery, instead of JOIN */
SELECT emp_no, salary, from_date,
	(SELECT title FROM titles AS t 
	 WHERE t.emp_no=s.emp_no AND t.from_date=s.from_date)	
FROM salaries s
ORDER BY emp_no;

EXPLAIN ANALYZE
SELECT emp_no, salary AS "most recent salary", from_date
FROM salaries AS s
WHERE from_date = (
	SELECT MAX(s2.from_date) AS max
	FROM salaries AS s2
	WHERE s2.emp_no = s.emp_no
)
ORDER BY emp_no;


/********************** 25) Subqueries Operators *******************/
/*
		EXISTS : Check if the subquery returns any rows
*/
SELECT firstname, lastname, income
FROM customers AS c
WHERE EXISTS(
	SELECT * FROM orders as o
	WHERE c.customerid = o.customerid AND totalamount > 400
) AND income > 90000

/* 
	IN : Check if the value is equal to any of the rows in the return (NULL yields NULL)
	NOT IN : Check if the value is NOT equal to any of the rows in the return (NULL yields NULL)
*/
SELECT prod_id
FROM products
WHERE category IN(
	SELECT category FROM categories
	WHERE categoryname IN ('Comedy', 'Family', 'Classics')
);


SELECT prod_id
FROM products
WHERE category IN(
	SELECT category FROM categories
	WHERE categoryname NOT IN ('Comedy', 'Family', 'Classics')
);

/*
		ANY / SOME : check each row against the operator and if any comparison matches, return TRUE.
*/

SELECT prod_id
FROM products
WHERE category = ANY(
	SELECT category FROM categories
	WHERE categoryname IN ('Comedy', 'Family', 'Classics')
);

/*
			ALL : check each row against the operator and if all comparisions match, return true.
*/
SELECT prod_id, title, sales
FROM products
JOIN inventory as i USING(prod_id)
WHERE i.sales > ALL(
	SELECT AVG(sales) FROM inventory
	JOIN products as p1 USING(prod_id)
	GROUP BY p1.category
);

/*
	Single Value Comparison
*/
SELECT prod_id
FROM products
WHERE category = (
	SELECT category FROM categories
	WHERE categoryname IN ('Comedy')
);