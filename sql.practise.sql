SELECT current_database();

-- CREATING TABLES
-- Employees table
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    name VARCHAR(50),
    age INT,
    salary INT,
    dept_id INT
);

-- Departments table
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50)
);

-- Sales table
CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    emp_id INT,
    amount INT
);

-- INSERTING DATA INTO TABLES 
-- departments
INSERT INTO departments VALUES
(101, 'Sales'),
(102, 'HR'),
(103, 'IT'),
(104, 'Finance');

-- Employees
INSERT INTO employees VALUES
(1, 'Amrit', 25, 40000, 101),
(2, 'Neel', 30, 60000, 102),
(3, 'Raj', 28, 50000, 101),
(4, 'Seerat', 35, 70000, NULL),
(5, 'Karan', 27, 45000, 103),
(6, 'Priyam', 32, 65000, 102),
(7, 'Abhimanyu', 29, 48000, 101),
(8, 'Mohak', 26, 42000, 103),
(9, 'Vrinda', 20, 77000, 104);

-- Sales
INSERT INTO sales VALUES
(1, 1, 10000),
(2, 1, 15000),
(3, 2, 20000),
(4, 3, 12000),
(5, 5, 18000),
(6, 6, 22000),
(7, 7, 9000),
(8, 1, 5000),
(9, 9, 7000);

--
SELECT * FROM employees;
SELECT * FROM departments;
SELECT * FROM sales;

 
-- SOME INSIGHTS FROM THE DATA WE HAVE :


-- 1. Total number of employees in company
SELECT COUNT(*) AS total_employees
FROM employees;


-- 2. Check how many departments exist
SELECT COUNT(*) AS departments
FROM departments;


-- 3. Employees without department
SELECT name
FROM employees
WHERE dept_id IS NULL;


-- 4. No of employees in each Dept
SELECT dept_id, COUNT(*) AS emp_count
FROM employees
GROUP BY dept_id;


-- 5. Unique departments present in employee table
SELECT DISTINCT dept_id
FROM employees;


-- 6. Average salary of company 
SELECT AVG(salary) AS avg_sal
FROM employees;


-- 7. Employees earning above average salary 
SELECT name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);


-- 8. Top 3 highest paid employees
SELECT name, salary
FROM employees
ORDER BY salary DESC
LIMIT 3;


-- 9. Second highest salary 
SELECT DISTINCT salary
FROM employees
ORDER BY salary DESC
LIMIT 1 OFFSET 1;


-- 10. Salary range filtering
SELECT name, salary
FROM employees
WHERE salary BETWEEN 40000 AND 60000;


-- 11. Employees whose name starts with 'N'
SELECT name
FROM employees
WHERE name LIKE 'N%';


-- 12. Employees whose name ends with 'a'
SELECT name
FROM employees
WHERE name LIKE '%a';


-- 13. Employees not in Sales or HR
SELECT e.name dept_id
FROM employees e
JOIN departments d
ON e.dept_id = d.dept_id
WHERE d.dept_name NOT IN ('Sales', 'HR');


-- 14. Average salary per department 
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM employees e
JOIN departments d
ON e.dept_id = d.dept_id 
GROUP BY d.dept_name ;


-- 15. Department with highest average salary
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM employees e
JOIN departments d
ON e.dept_id = d.dept_id 
GROUP BY d.dept_name 
ORDER BY avg_salary DESC
LIMIT 1;

-- 16. Departments having more than 2 employees
SELECT d.dept_name, COUNT(e.emp_id) AS emp_count
FROM departments d
JOIN employees e
ON d.dept_id  = e.dept_id 
GROUP BY d.dept_name
HAVING  COUNT(e.emp_id) > 2;


-- 17. Count of employees per department
SELECT d.dept_name, COUNT(e.emp_id)
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;


-- 18. Highest salary in each department
SELECT d.dept_name, MAX(e.salary) AS max_salary
FROM employees e
JOIN departments d
ON e.dept_id = d.dept_id 
GROUP BY d.dept_name; 


-- 19. Total company sales
SELECT SUM(amount) AS total_sales 
FROM Sales;


-- 20. Total sales per employee 
SELECT e.name, SUM(s.amount) AS total_sales
FROM employees e
JOIN Sales s
ON e.emp_id = s.emp_id
GROUP BY e.name;


-- 21. Employees with sales greater than 20000
SELECT e.name, SUM(s.amount) AS total_sales
FROM employees e
JOIN Sales s
ON e.emp_id = s.emp_id
GROUP BY e.name
HAVING SUM(s.amount) > 20000;   
-- prefer using having instead of where, optimises


-- 22. Employee with highest total sales
SELECT e.name, SUM(s.amount) AS total_sales
FROM employees e
JOIN Sales s
ON e.emp_id = s.emp_id
GROUP BY e.name
ORDER  BY total_sales DESC
LIMIT 1;


-- 23. Employees with no sales (inactive performers)
SELECT e.name
FROM employees e
LEFT JOIN sales s ON e.emp_id = s.emp_id
WHERE s.emp_id IS NULL;


-- 24. Department-wise total sales (business contribution)
SELECT d.dept_name, SUM(s.amount) AS total_sales
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
JOIN sales s ON e.emp_id = s.emp_id
GROUP BY d.dept_name;


-- 25. Department generating highest sales
SELECT d.dept_name, SUM(s.amount) AS total_sales
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
JOIN sales s ON e.emp_id = s.emp_id
GROUP BY d.dept_name
ORDER BY total_sales DESC
LIMIT 1;


-- 26. Employees earning highest salary within their department
SELECT e.name, e.salary, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary = (
    SELECT MAX(salary)
    FROM employees
    WHERE dept_id = e.dept_id
);


-- 27. Employees having multiple sales transactions (USING SUB QUERY)
SELECT name, total_transactions
FROM (
    SELECT e.name, COUNT(s.sale_id) AS total_transactions
    FROM employees e
    JOIN sales s ON e.emp_id = s.emp_id
    GROUP BY e.name
) sub
WHERE total_transactions > 1;


-- 28. Rank employees based on salary (window function)
SELECT name, salary,
RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM employees;


-- 29. Top performer employee 
-- First calculate total sales for each employee using a CTE
-- Then select the employee(s) whose total sales is the highest

WITH emp_sales AS (
    SELECT emp_id, SUM(amount) AS total_sales
    FROM sales
    GROUP BY emp_id
)
SELECT emp_id, total_sales
FROM emp_sales
WHERE total_sales = (SELECT MAX(total_sales) FROM emp_sales);


-- 30. Final consolidated report / total sales in ecah dept sorted hightest to lowest
SELECT d.dept_name, SUM(s.amount) AS total_sales
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
JOIN sales s ON e.emp_id = s.emp_id
GROUP BY d.dept_name
ORDER BY total_sales DESC;


-- 31. Rank employees based on total sales
SELECT e.name,
SUM(s.amount) AS total_sales,
RANK() OVER (ORDER BY SUM(s.amount) DESC) AS sales_rank
FROM employees e
JOIN sales s ON e.emp_id = s.emp_id
GROUP BY e.name;


-- 32. Show each employee’s salary vs department average
SELECT e.name, e.salary, e.dept_id,
AVG(e.salary) OVER (PARTITION BY e.dept_id) AS dept_avg_salary
FROM employees e;


-- 33. Categorize employees based on salary
SELECT name, salary,
CASE 
    WHEN salary > 60000 THEN 'High'
    WHEN salary BETWEEN 40000 AND 60000 THEN 'Medium'
    ELSE 'Low'
END AS salary_category
FROM employees;