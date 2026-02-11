SELECT COUNT(*) FROM financials;
SELECT 
COUNT(year) AS null_values
FROM financials
WHERE year IS NULL;

DROP VIEW IF EXISTS financial_clean;
CREATE VIEW financial_clean AS
SELECT 
segment,
country,
product,
discount_band,
date,
month_number,
month_name,
year,
CAST(REPLACE(REPLACE(units_sold,'$',''),',','') AS DECIMAL(14,2)) AS units_sold,
CAST(REPLACE(REPLACE(gross_sales,'$',''),',','') AS DECIMAL(14,2)) AS gross_sales,
COALESCE(CAST(NULLIF(TRIM(REPLACE(REPLACE(discounts,'$',''),',','')), '-')AS DECIMAL(14,2)),0) AS discounts,
CAST(REPLACE(REPLACE(sales,'$',''),',','') AS DECIMAL(14,2)) AS sales,
CAST(REPLACE(REPLACE(cogs,'$',''),',','') AS DECIMAL(14,2)) AS cogs,
COALESCE(CAST(NULLIF(TRIM(REPLACE(REPLACE(profit,'$',''),',','')),'-') AS DECIMAL(14,2)),0) AS profit
FROM financials;

SELECT * FROM financial_clean;

SELECT 
SUM(sales) AS total_sales,
SUM(cogs) AS total_cogs,
SUM(profit) AS total_profit
FROM financial_clean;

SELECT 
ROUND(SUM(profit)/SUM(sales) * 100,2) AS profit_margin_percentage
FROM financial_clean;

SELECT
segment,
SUM(sales) AS total_sales,
SUM(profit) AS total_profit,
ROUND(SUM(profit)/SUM(sales) * 100,2) AS profit_margin_percentage
FROM financial_clean
GROUP BY segment
ORDER BY profit_margin_percentage DESC;

SELECT
country,
SUM(sales) AS total_sales,
SUM(profit) AS total_profit,
ROUND(SUM(profit)/SUM(sales) * 100,2) AS profit_margin_percentage
FROM financial_clean
GROUP BY country
ORDER BY total_profit DESC;

SELECT
country,
SUM(sales) AS total_sales,
SUM(profit) AS total_profit,
RANK() OVER(ORDER BY SUM(sales) DESC) AS sales_rank,
RANK() OVER(ORDER BY SUM(profit) DESC) AS profit_rank
FROM financial_clean
GROUP BY country;

SELECT
product,
SUM(sales) AS total_sales,
SUM(profit) AS total_profit,
ROUND(SUM(profit)/SUM(sales) * 100,2) AS profit_margin_percentage,
RANK() OVER(ORDER BY SUM(sales) DESC) AS sales_rank,
RANK() OVER(ORDER BY SUM(profit) DESC) AS profit_rank
FROM financial_clean
GROUP BY product
;

SELECT
month_name,
SUM(sales) AS total_sales,
SUM(profit) AS total_profit
FROM financial_clean
GROUP BY month_name
ORDER BY total_profit DESC;

SELECT
year,
SUM(sales) AS total_sales,
SUM(profit) AS total_profit,
ROUND(SUM(profit)/SUM(sales) * 100,2) AS profit_margin_percentage
FROM financial_clean
GROUP BY year
ORDER BY total_profit DESC;

SELECT 
ROUND(SUM(discounts),2) AS total_discounts,
ROUND(SUM(profit),2) AS total_profit
FROM financial_clean;

SELECT
	CASE
		WHEN discounts = 0 THEN 'No Discount'
		WHEN discounts BETWEEN 1 AND 5000 THEN 'Low Discount'
		WHEN discounts BETWEEN 5001 AND 20000 THEN 'Medium Discount'
		ELSE 'High Discount'
	END AS Discount_Category,
ROUND(SUM(profit)/SUM(sales) * 100,2) AS profit_margin_percentage
FROM financial_clean
GROUP BY Discount_Category
ORDER BY profit_margin_percentage DESC;

SELECT
segment,
REPLACE(country,'United States of America','USA') AS country,
SUM(sales) AS total_sales,
SUM(profit) AS total_profit,
ROUND(SUM(profit)/SUM(sales) * 100,2) AS profit_margin_percentage,
RANK() OVER(ORDER BY SUM(profit) DESC) AS profit_rank,
RANK() OVER(PARTITION BY country ORDER BY ROUND(SUM(profit)/SUM(sales) * 100,2) DESC) AS margin_rank
FROM financial_clean
GROUP BY segment,country
ORDER BY total_profit DESC;

SELECT 
COUNT(*) AS mismatch_count
FROM financial_clean
WHERE profit <> (sales - cogs);

SELECT
    Year,
    SUM(Sales) AS Total_Sales,
    SUM(Sales) - LAG(SUM(Sales)) OVER (ORDER BY Year) AS YoY_Change
FROM financial_clean
GROUP BY Year;

SELECT
    month_number,
    SUM(Sales) AS Total_Sales,
    SUM(Sales) - LAG(SUM(Sales)) OVER (ORDER BY month_number) AS YoY_Change
FROM financial_clean
GROUP BY month_number;
