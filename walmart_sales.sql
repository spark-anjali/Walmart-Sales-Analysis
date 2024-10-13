CREATE DATABASE walmart_sales;
	
CREATE TABLE sales (
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    vat DECIMAL(6, 4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10, 2) NOT NULL,
    gross_margin_pct DECIMAL(5, 2),
    gross_income DECIMAL(12, 4),
    rating DECIMAL(3, 1) 
);

-- csv files imported

SELECT * FROM SALES  

--------------------------------------------------------------------------------
------------------------Feature engineering-------------------------------------
--1. time_of_day

SELECT time,
(CASE 
	WHEN "time" BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
	WHEN "time" BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
	ELSE 'Evening'
END) AS time_of_day
FROM sales;

--ADDING NEW COLUMN 
ALTER TABLE sales 
	ADD COLUMN time_of_day VARCHAR(20);

--UPDATING DATA
UPDATE sales
SET time_of_day = (
	CASE 
		WHEN "time" BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
	    WHEN "time" BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
	    ELSE 'Evening' 
	END
);


--2. day_name

SELECT date,
       TO_CHAR(date, 'Day') AS day_name
FROM sales;

--ADDING NEW COLUMN 
ALTER TABlE SALES
	ADD COLUMN day_name varchar(10);

-- UPDATING DATA
UPDATE sales
SET day_name = TO_CHAR(date, 'Day');

--month_name
SELECT date,
       TO_CHAR(date, 'Month') AS month_name
FROM sales;

--ADDING NEW COLUMN 
ALTER TABLE SALES
	ADD COLUMN month_name varchar(10);

--UPDATING DATA
UPDATE sales
SET month_name = TO_CHAR(date, 'Month');

----------------------------EXPLORATORY DATA ANALYSIS (EDA)-------------------------

SELECT * FROM SALES

-- 1.How many distinct cities are present in the dataset?
SELECT DISTINCT city FROM sales;

-- 2.In which city is each branch situated?
SELECT DISTINCT branch, city FROM sales;

--------------------------------------------------------------------------------------
--PRODUCT ANALYSIS

--1.How many distinct product lines are there in the dataset?
SELECT COUNT(DISTINCT product_line) FROM SALES

-- 2.What is the most common payment method?
SELECT payment, COUNT(payment) as common_payment_method FROM SALES
GROUP BY payment 
ORDER BY common_payment_method DESC
LIMIT 1

--3.What is the most selling product line?
SELECT product_line As Most_selling_product_line FROM SALES
GROUP BY product_line
ORDER BY Count(*) DESC
LIMIT 1

--4.What is the total revenue by month?
SELECT month_name, sum(total) as total_revenue
FROM SALES
GROUP BY month_name
ORDER BY total_revenue DESC

--5.Which month recorded the highest Cost of Goods Sold (COGS)?
SELECT month_name, SUM(cogs) AS HIGHEST_COGS FROM SALES
GROUP BY month_name
ORDER BY HIGHEST_COGS DESC

-- 6.Which product line generated the highest revenue?
SELECT product_line, sum(total) AS HIGHEST_REVENUE
FROM SALES 
GROUP BY product_line
ORDER BY HIGHEST_REVENUE DESC


-- 7.Which city has the highest revenue?
SELECT city, sum(total) AS HIGHEST_REVENUE FROM SALES
GROUP BY city
order by HIGHEST_REVENUE DESC
LIMIT 1

-- 8.Which product line incurred the highest VAT?
SELECT product_line, SUM(vat) as VAT 
FROM sales 
GROUP BY product_line 
ORDER BY VAT DESC 
LIMIT 1;

-- 9.Retrieve each product line and add a column product_category, indicating 'Good' or 'Bad,'based on whether its sales are above the average.
ALTER TABLE sales 
	ADD COLUMN product_category VARCHAR(20);

UPDATE sales 
SET product_category= 
(CASE 
	WHEN total >= (SELECT AVG(total) FROM sales) THEN 'Good'
    ELSE 'Bad'
END);

-- 10.Which branch sold more products than average product sold?
SELECT branch,SUM(quantity) as quantity FROM SALES
GROUP BY branch
HAVING SUM(quantity)>AVG(QUANTITY)
ORDER BY quantity DESC
LIMIT 1

--11.What is the most common product line by gender?
SELECT gender, product_line,count(gender) as total_count FROM SALES
GROUP BY gender, product_line
ORDER BY total_count DESC

-- 12.What is the average rating of each product line?
SELECT product_line, AVG(rating) AS AVERAGE_RATING FROM SALES
GROUP BY product_line
ORDER BY AVERAGE_RATING DESC

-------------------------------------------------------------------------------------------------
--SALES ANALYSIS

SELECT * FROM SALES	
	
-- 1.Number of sales made in each time of the day per weekday
SELECT day_name, time_of_day, COUNT(*) AS total_sales
FROM sales 
GROUP BY day_name, time_of_day 
HAVING day_name NOT IN ('Sunday','Saturday')

-- 2.Identify the customer type that generates the highest revenue.
SELECT customer_type, SUM(total) AS total_sales
FROM sales 
GROUP BY customer_type 
ORDER BY total_sales DESC 
LIMIT 1

-- 3.Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT city, SUM(VAT) AS total_VAT
FROM sales 
GROUP BY city 
ORDER BY total_VAT DESC 
LIMIT 1

-- 4.Which customer type pays the most in VAT?
SELECT customer_type, SUM(VAT) AS total_VAT
FROM sales 
GROUP BY customer_type 
ORDER BY total_VAT DESC 
LIMIT 1

-------------------------------------------------------------------------------------------------
--CUSTOMER ANALYSIS

SELECT * FROM SALES

-- 1.How many unique customer types does the data have?
SELECT COUNT(DISTINCT customer_type) FROM SALES

-- 2.How many unique payment methods does the data have?
SELECT COUNT(DISTINCT payment) FROM SALES

--3.Which is the most common customer type?
SELECT customer_type, COUNT(customer_type) AS common_customer
FROM sales 
GROUP BY customer_type 
ORDER BY common_customer DESC 
LIMIT 1;

-- 4.Which customer type buys the most?
SELECT customer_type, COUNT(*) AS most_buyer
FROM sales 
GROUP BY customer_type 
ORDER BY most_buyer DESC 
LIMIT 1;

-- 5.What is the gender of most of the customers?
SELECT gender, COUNT(*) AS all_genders 
FROM sales 
GROUP BY gender 
ORDER BY all_genders DESC 
LIMIT 1;

-- 6.What is the gender distribution per branch?
SELECT branch, gender, COUNT(gender) AS gender_distribution
FROM sales 
GROUP BY branch, gender 
ORDER BY branch;

-- 7.Which time of the day do customers give most ratings?
SELECT time_of_day, AVG(rating) AS average_rating
FROM sales 
GROUP BY time_of_day 
ORDER BY average_rating DESC 
LIMIT 1;

-- 8.Which time of the day do customers give most ratings per branch?
SELECT branch, time_of_day, AVG(rating) AS average_rating
FROM sales 
GROUP BY branch, time_of_day 
ORDER BY average_rating DESC;

-- 9.Which day of the week has the best avg ratings?
SELECT day_name, AVG(rating) AS average_rating
FROM sales 
GROUP BY day_name 
ORDER BY average_rating DESC 
LIMIT 1;

-- 10.Which day of the week has the best average ratings per branch?
SELECT  branch, day_name, AVG(rating) AS average_rating
FROM sales 
GROUP BY day_name, branch 
ORDER BY average_rating DESC;

