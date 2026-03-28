-- Project: Retail Sales Analysis
-- Database: PostgreSQL
-- Last Updated: 2026-03-28
 
-- ============================================================================
-- TABLE CREATION AND SETUP
-- ============================================================================
 
-- Drop existing table if it exists
DROP TABLE IF EXISTS retail_sales CASCADE;
 
-- Create the retail_sales table with proper naming conventions
CREATE TABLE retail_sales (
    transaction_id INT PRIMARY KEY,
    sale_date DATE NOT NULL,
    sale_time TIME NOT NULL,
    customer_id INT NOT NULL,
    gender VARCHAR(15) NOT NULL,
    age INT NOT NULL,
    category VARCHAR(15) NOT NULL,
    quantity INT NOT NULL,
    price_per_unit FLOAT NOT NULL,
    cogs FLOAT NOT NULL,
    total_sale FLOAT NOT NULL
);
 
-- Verify table creation
SELECT * FROM retail_sales LIMIT 5;
 
-- Count total records
SELECT COUNT(*) AS total_records
FROM retail_sales;
 
-- ============================================================================
-- DATA CLEANING
-- ============================================================================
 
-- Remove records with NULL values in any critical column
DELETE FROM retail_sales
WHERE transaction_id IS NULL
   OR sale_date IS NULL
   OR sale_time IS NULL
   OR customer_id IS NULL
   OR gender IS NULL
   OR age IS NULL
   OR category IS NULL
   OR quantity IS NULL
   OR price_per_unit IS NULL
   OR cogs IS NULL
   OR total_sale IS NULL;
 
-- ============================================================================
-- DATA EXPLORATION
-- ============================================================================
 
-- Total sales amount
SELECT SUM(total_sale) AS total_sales_amount
FROM retail_sales;
 
-- Count of unique customers
SELECT COUNT(DISTINCT customer_id) AS total_unique_customers
FROM retail_sales;
 
-- List all distinct categories
SELECT DISTINCT category
FROM retail_sales
ORDER BY category;
 
-- ============================================================================
-- DATA ANALYSIS & BUSINESS QUESTIONS
-- ============================================================================
 
-- Q.1: Retrieve all columns for sales made on '2022-11-05'
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';
 
-- Q.2: Retrieve all transactions where category is 'Clothing' and quantity >= 4 in Nov-2022
SELECT *
FROM retail_sales
WHERE sale_date >= '2022-11-01'
  AND sale_date < '2022-12-01'
  AND category = 'Clothing'
  AND quantity >= 4;
 
-- Q.3: Calculate the total sales for each category
SELECT 
    category,
    SUM(total_sale) AS net_sale,
    COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category
ORDER BY net_sale DESC;
 
-- Q.4: Find the average age of customers who purchased items from the 'Beauty' category
SELECT 
    category,
    ROUND(AVG(age)::NUMERIC, 2) AS average_customer_age
FROM retail_sales
WHERE category = 'Beauty'
GROUP BY category;
 
-- Q.5: Find all transactions where total_sale is greater than 1000
SELECT *
FROM retail_sales
WHERE total_sale > 1000
ORDER BY total_sale DESC;
 
-- Q.6: Find the total number of transactions by each gender in each category
SELECT 
    category,
    gender,
    COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY category, gender;
 
-- Q.7: Calculate the average sale for each month and find the best selling month in each year
WITH monthly_avg_sales AS (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS sale_year,
        EXTRACT(MONTH FROM sale_date) AS sale_month,
        AVG(total_sale) AS avg_monthly_sale
    FROM retail_sales
    GROUP BY 
        EXTRACT(YEAR FROM sale_date),
        EXTRACT(MONTH FROM sale_date)
),
ranked_months AS (
    SELECT 
        sale_year,
        sale_month,
        avg_monthly_sale,
        RANK() OVER (
            PARTITION BY sale_year 
            ORDER BY avg_monthly_sale DESC
        ) AS rank
    FROM monthly_avg_sales
)
SELECT 
    sale_year,
    sale_month,
    ROUND(avg_monthly_sale::NUMERIC, 2) AS avg_monthly_sale
FROM ranked_months
WHERE rank = 1
ORDER BY sale_year;
 
-- Q.8: Find the top 5 customers based on the highest total sales
SELECT 
    customer_id,
    SUM(total_sale) AS total_customer_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_customer_sales DESC
LIMIT 5;
 
-- Q.9: Find the number of unique customers who purchased items from each category
SELECT 
    category,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category
ORDER BY unique_customers DESC;
 
-- Q.10: Create each shift and count the number of orders
-- Morning: 00:00-11:59 | Afternoon: 12:00-16:59 | Evening: 17:00-23:59
SELECT 
    CASE 
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) >= 12 AND EXTRACT(HOUR FROM sale_time) < 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(transaction_id) AS total_transactions
FROM retail_sales
GROUP BY shift
ORDER BY 
    CASE shift
        WHEN 'Morning' THEN 1
        WHEN 'Afternoon' THEN 2
        WHEN 'Evening' THEN 3
    END;
 
-- Q.11: Find customers who purchased from fewer categories than available in the store
SELECT 
    customer_id,
    COUNT(DISTINCT category) AS distinct_categories_purchased
FROM retail_sales
GROUP BY customer_id
HAVING COUNT(DISTINCT category) < 
    (SELECT COUNT(DISTINCT category) FROM retail_sales)
ORDER BY distinct_categories_purchased DESC;
 
-- Q.12: Calculate total sales and percentage contribution by category and gender
WITH category_gender_sales AS (
    SELECT 
        category,
        gender,
        SUM(total_sale) AS category_gender_sales
    FROM retail_sales
    GROUP BY category, gender
),
total_sales AS (
    SELECT 
        SUM(total_sale) AS overall_total_sales
    FROM retail_sales
)
SELECT 
    cgs.category,
    cgs.gender,
    ROUND(cgs.category_gender_sales::NUMERIC, 2) AS category_gender_total_sales,
    ROUND(ts.overall_total_sales::NUMERIC, 2) AS overall_total_sales,
    ROUND((cgs.category_gender_sales * 100.0 / ts.overall_total_sales)::NUMERIC, 2) AS percentage_of_total
FROM category_gender_sales cgs
CROSS JOIN total_sales ts
ORDER BY cgs.category, cgs.gender;
 
-- Q.13: Calculate total sales and month-over-month (MoM) growth percentage
WITH monthly_sales AS (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS sale_year,
        EXTRACT(MONTH FROM sale_date) AS sale_month,
        SUM(total_sale) AS monthly_total_sales
    FROM retail_sales
    GROUP BY 
        EXTRACT(YEAR FROM sale_date),
        EXTRACT(MONTH FROM sale_date)
),
monthly_sales_with_lag AS (
    SELECT 
        sale_year,
        sale_month,
        monthly_total_sales,
        LAG(monthly_total_sales, 1) OVER (
            ORDER BY sale_year, sale_month
        ) AS previous_month_sales
    FROM monthly_sales
)
SELECT 
    sale_year,
    sale_month,
    ROUND(monthly_total_sales::NUMERIC, 2) AS monthly_total_sales,
    ROUND(COALESCE(previous_month_sales, 0)::NUMERIC, 2) AS previous_month_sales,
    ROUND(
        CASE 
            WHEN previous_month_sales IS NULL OR previous_month_sales = 0 THEN NULL
            ELSE ((monthly_total_sales - previous_month_sales)::NUMERIC / previous_month_sales::NUMERIC) * 100
        END, 2
    ) AS mom_growth_percentage
FROM monthly_sales_with_lag
ORDER BY sale_year, sale_month;
 
-- Q.14: For each gender, find the age group with the highest total sales
SELECT 
    gender,
    age,
    ROUND(total_sales::NUMERIC, 2) AS total_sales
FROM (
    SELECT 
        gender,
        age,
        SUM(total_sale) AS total_sales,
        RANK() OVER (
            PARTITION BY gender 
            ORDER BY SUM(total_sale) DESC
        ) AS rank
    FROM retail_sales
    GROUP BY gender, age
) AS ranked_sales
WHERE rank = 1
ORDER BY gender;
 