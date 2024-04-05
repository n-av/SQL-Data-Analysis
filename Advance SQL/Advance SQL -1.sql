/******** 1) GROUP BY  **********/
/*
	When we group by, we apply the function PER GROUP,	NOT on the ENTIRE DATA SET.
	Group by use Split, Apply, Combine strategry.
*/

/* How many employees worked in each department ? */
SELECT d.dept_name AS "Department Name" ,COUNT(e.emp_no) AS "Number Of Employee"
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON d.dept_no = de.dept_no
GROUP BY d.dept_no
ORDER BY 1;

/*------------------------------------------------------------------------------------------------------------*/

/************ 2) HAVING Keyword *************/
/*
	"Having" applies filters to a group as a whole
	
	**** Order of Operations ****
		FROM
		WHERE
		GROUP BY
		HAVING
		SELECT
		ORDER
*/

/* How many employees worked in each department, but with employees more than 25000 ? */
SELECT d.dept_name AS "Department Name" ,COUNT(e.emp_no) AS "Number Of Employee"
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON d.dept_no = de.dept_no
GROUP BY d.dept_name
HAVING COUNT(e.emp_no) > 25000
ORDER BY 1;

/* How many Female employees worked in each department, but with employees more than 25000 ? */
SELECT d.dept_name AS "Department Name" ,COUNT(e.emp_no) AS "Number Of Employee"
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON d.dept_no = de.dept_no
WHERE e.gender='F'
GROUP BY d.dept_name
HAVING COUNT(e.emp_no) > 25000
ORDER BY 1;

/*------------------------------------------------------------------------------------------------------------*/

/********** 3) Ordering Group Data **********/
SELECT d.dept_name AS "Department Name" ,COUNT(e.emp_no) AS "Number Of Employee"
FROM employees e
JOIN dept_emp de ON e.emp_no = de.emp_no
JOIN departments d ON d.dept_no = de.dept_no
GROUP BY d.dept_name
HAVING COUNT(e.emp_no) > 25000
ORDER BY 2 DESC;


/********* 4) GROUP BY Mental Model ***********/

/* What are the 8 employees who got the most salary bumps? */
-- SELECT e.emp_no, CONCAT(e.first_name, e.last_name) AS "Name", s.salary, s.from_date, s.to_date
SELECT emp_no, MAX(from_date)
FROM salaries
GROUP BY emp_no;


/*------------------------------------------------------------------------------------------------------------*/


/******* UNION / UNION ALL *********/
/*
	SELECT col1, SUM(col2)
	FROM table
	GROUP BY col1
	
	UNION / UNION ALL
	
	SELECT SUM(col2)
	FROM table
	
	
 	UNION ALL doesn't remove DUPLICATE Records.
*/
SELECT NULL AS "prod_id", sum(ol.quantity)
FROM orderlines AS ol

UNION

SELECT prod_id AS "prod_id", sum(ol.quantity)
FROM orderlines AS ol
GROUP BY prod_id
ORDER BY prod_id DESC;

/*------------------------------------------------------------------------------------------------------------*/



/************			5) ROLLUP			***************/

/* roll up can provide a very similar result as above using grouping sets, but with less code */
SELECT
	EXTRACT(YEAR FROM orderdate) AS "YEAR",
	EXTRACT(MONTH FROM orderdate) AS "MONTH",
	EXTRACT(DAY FROM orderdate) AS "DAY",
	SUM(quantity)AS "TOTAL QUANTITY"
FROM orderlines
GROUP BY 
	ROLLUP(
		EXTRACT(YEAR FROM orderdate),
		EXTRACT(MONTH FROM orderdate),
		EXTRACT(DAY FROM orderdate)
	)
ORDER BY 1,2,3;

/*------------------------------------------------------------------------------------------------------------*/

/******************** 6/7) WINDOW Functions ******************/
/*
	Window functions CREATE a NEW COLUMN based on functions performed on a SUBSET or "WINDOW" of the data.
	
	window_function(agr1, agr2) OVER(
		[PARTITION BY partition_expression]
		[ORDER BY sort_expression [ASC | DESC] [NULLS {FIRST | LAST}]]
	)
*/

-- Here we can see in the result that max salary is 158,220. Because query returns all data, then LIMIT say cut it off for 100 rows only. 
-- That's why OVER() is calculated on the window or subset of data (in this case the entire data were returned).
SELECT *,
	MAX(salary) OVER()
FROM salaries
LIMIT 100;

-- in this case, the maximum salary is 69,999. Because of WHERE conditions, the data were filtered out.
-- and OVER() is using on that subset or window of the returned data (in this case the results of WHERE filtered data).
SELECT 
	*,
	MAX(salary) OVER() 
FROM salaries
WHERE salary < 70000
ORDER BY salary DESC;


/******************** 8) PARTITON BY ******************/
/*
	Divide Rows into Groups to apply the function against (Optional)
*/

/* Employee salary compairing average salary of departments */
SELECT 
	s.emp_no, s.salary,d.dept_name,
	AVG(s.salary)
	OVER(
		PARTITION BY(d.dept_name)
	)
FROM salaries s
JOIN dept_emp de ON s.emp_no = de.emp_no
JOIN departments d ON d.dept_no = de.dept_no;


/******************** 9) ORDER BY ******************/
/*
	ORDER BY changes the FRAME of the window
	It tells SQL to take into account of everything before up until to this point (becoming Cumulative)
*/
-- against the window of entire data
SELECT emp_no,
	COUNT(salary) OVER()
FROM salaries;

-- using PARTION BY
-- Counting salary by each unique emp_no partion
SELECT emp_no,
	COUNT(salary) OVER(
		PARTITION BY(emp_no)
	)
FROM salaries;


-- using ORDER BY
-- Count number are becoming Cumulative
SELECT emp_no,
	COUNT(salary) OVER(
		ORDER BY emp_no
	)
FROM salaries;
