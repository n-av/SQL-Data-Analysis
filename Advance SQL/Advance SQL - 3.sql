
/******************* 14) NULL IF *******************/
/*
	Use NULLIF to fill in empty spots with a NULL value to avoid divide by zero issues
	
	NULLIF(val1, val2)
	
	if value 1 is equal to value 2, return NULL
*/

SELECT NULLIF(0, 0); -- returns null

SELECT NULLIF('ABC', 'DEF'); -- returns ABC


/* ----------------------------------------------------------------------------------------------------------- */


/******************** 15) VIEWS *********************/
/*
	Views allow you to store the results and query of previously run queries.
	
	There are 2 types of views: 1) Materialized and 2) Non-Materialized Views.
	
	1) Materialzed View - stores the data PHYSICIALLY AND PERIODICALLY UPDATES it when tables change.
	2) Non-Materialized View - Query gets RE-RUN each time the view is called on.
	
*/

/*************** 	16) VIEW syntax **************/
/*
	+ views are OUTPUT of query we ran.
	+ views act like TABLES you can query them.
	+ (Non-Materialized View): views tak VERY LITTLE SPACE to store. We only store the definition of the view, NOT ALL the data that it returns.	
*/

-- Create a view
CREATE VIEW view_name 
AS query;

-- Update a view
CREATE OR REPLACE view_name
AS query;

-- Rename a view
ALTER VIEW exisitng_view_name RENAME TO new_view_name;

-- Delete a view
DROP VIEW IF EXISTS view_name;

/*************** 17) Using VIEWS ******************/

-- get the last salary change of each employee
CREATE VIEW last_salary_change AS
	SELECT e.emp_no,
		MAX(s.from_date)
	FROM salaries s
	JOIN employees e USING(emp_no)
	JOIN dept_emp de USING(emp_no)
	JOIN departments d USING(dept_no)
	GROUP BY e.emp_no
	ORDER BY e.emp_no;

-- query entire data from that view
SELECT * FROM last_salary_change;

-- combine with view to get the latest salary of each employee
SELECT 
	s.emp_no, d.dept_name, s.from_date, s.salary
FROM last_salary_change lsc
JOIN salaries s USING(emp_no)
JOIN dept_emp de USING(emp_no)
JOIN departments d USING(dept_no)
WHERE s.from_date = lsc.max
ORDER BY s.emp_no;

/*--------------------------------------------------------------------------------------------------------------*/

/**************** 18) Indexes ****************/
/*
	Index is the construct to improve Querying Performance.
	
	Think of it like a table of contents, it helps you find where a piece of data is.
	
	Pros: Speed up querying
	Cons: Slows down data Insertion and Updates
	
	***** Types of Indexes *****
	- Single Column
	- Multi Column
	- Unique
	- Partial
	- Implicit Indexes (done by default)
*/

-- Create an index
CREATE UNIQUE INDEX idx_name
ON table_name(column1, column2, ...);

-- Delete an index
DELETE INDEX idx_name;

/*
	 **** When to Use Indexes *****
	 - Index Foreign Keys
	 - Index Primary Keys and Unique Columns
	 - Index on Columns that end up in the ORDER BY/WHERE clause VERY OFTEN.
	 
	 ***** When NOT to use Indexes ******
	 - Don't add Index just to add Index
	 - Don't use Index on Small Table
	 - Don't use on Tables that are UPDATED FREQUENTLY.
	 - Don't use on Columns that can contain NULL values
	 - Don't use on Columns that have Large Values.
*/


/***************** 19) Indexes Types ******************/

/*

	Single Column Index 	: 	retrieving data that satisfies ONE condition.
	Multi Column Index		:	retrieving data that satisfies MULIPLE Conditions.
	UNIQUE					: 	For Speed and Integrity
	PARTIAL					: 	Index Over a SUBSET of a Table (CREATE INDEX name ON table (<expression);)
	IMPLICIT				: 	Automatically creaed by the database: (Primary Key, Unique Key)

*/

EXPLAIN ANALYZE
SELECT "name", district, countrycode
FROM city
WHERE countrycode IN ('TUN', 'BE', 'NL');

-- Single Index
CREATE INDEX idx_countrycode
ON city(countrycode);


-- Partial Index
CREATE INDEX idx_countrycode
ON city(countrycode) WHERE countrycode IN ('TUN', 'BE', 'NL');

EXPLAIN ANALYZE
SELECT "name", district, countrycode
FROM city
WHERE countrycode IN ('PSE', 'ZWE', 'USA');


/************************** 20) Index Algorithms *********************/
/*
	POSTGRESQL provides Several types of indexes:
		B-TREE
		HASH
		GIN
		GIST
	Each Index types use different algorithms.
*/

-- we can extend which algorithm to use while creating index
CREATE UNIQUE INDEX idx_name
ON tbl_name USING <method> (column1, column2, ...)


-- by default, it is created using B-TREE
CREATE INDEX idx_countrycode
ON city(countrycode);

-- but we can specify which algorithm to use (example: HASH)
CREATE INDEX idx_countrycode
ON city USING HASH (countrycode);