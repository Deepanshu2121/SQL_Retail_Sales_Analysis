# Retail Sales Analysis SQL Project

## Project Overview 

**Project Title**: Retail Sales Analysis                                             
**Level**: Beginner                                                 
**DataBase**:`retail_project`

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze retail sales data. The
project involves setting up a retail sales database, performing exploratory data analysis (EDA), and answering specific business questions through SQL
queries. This project is ideal for those who are starting their journey in data analysis and want to build a solid foundation in SQL.

## Objectives
1. To utilize SQL queries for data cleaning and exploratory data analysis to ensure data quality and gain initial insights.
2. To identify high and low sales products to optimize inventory and tailor marketing efforts.
3. To segment customers based on their purchasing behavior for targeted marketing campaigns. Create Customer segments -
Total Quantity of Products Purchased  |  Customer Segment
0                                     |    No Order 
1-10                                  |    Low
10-30                                 |    Mid 
>30                                   |    High 
4. To analyze customer behavior for insights on repeat purchases and loyalty, informing customer retention strategies.

## Project Structure

### 1. Database Setup

- ** Database Creation **: The project starts by creating a database named `retail_project`
- ** Table Importing **: The table names `customer_profiles`, `product_inventory` and `sales_transaction_cdate_nodup`.

### Data Exploration and Cleaning :
- ** Record Count **: Determine the total number of records in the dataset.
- ** Customer Count **: Find out how many unique customers are in the dataset.
- ** Category Count **: Identify all unique product categories in the dataset.
- ** Null Value Check **: Check for any null values in the dataset and delete records with missing data.

```sql
SELECT COUNT(*) FROM sales_transaction_cdate_nodup;
SELECT COUNT(DISTINCT CustomerID) FROM customer_profiles;
SELECT DISTINCT category FROM product_inventory;

SELECT * FROM sales_transaction_cdate_nodup
WHERE
TransactionDate IS NULL OR Price IS NULL OR CustomerID IS NULL OR
QuantityPurchased IS NULL OR ProductID IS NULL;

DELETE FROM sales_transaction_cdate_nodup
WHERE
TransactionDate IS NULL OR Price IS NULL OR CustomerID IS NULL OR
QuantityPurchased IS NULL OR ProductID IS NULL;
-- I do it for all three tables.
```

## Data Analysis and Findings 
The following SQL queries were developed to answer specific business questions:
```sql
-- <1> Business Problem :-
-- To utilize SQL queries for data cleaning and exploratory data analysis to ensure data quality and gain initial insights.

-- Objective :- 
-- Clean and explore the data using SQL to ensure quality and gain initial insights for better business decisions.

-- 1. Remove duplicates :-
SELECT TransactionID ,COUNT(*) AS duplicate_count
FROM sales_transaction_cdate_nodup
group by TransactionID
HAVING duplicate_count > 1;

Create table sales_transaction_Noduplicate as select distinct * from sales_transaction; 

Drop table sales_transaction;


-- 2. identify and Fix incorrect prices in sales_transaction :-
Select PI.ProductID, ST.TransactionID, PI.Price, ST.Price
From product_inventory PI
join sales_transaction_noduplicate ST on PI.ProductID = ST.ProductID 
where PI.Price <> ST.Price ;

-- Now time to correct (update) wrong prices :- 
UPDATE sales_transaction_noduplicate st
JOIN product_inventory pi
    ON st.ProductID = pi.ProductID
SET st.Price = pi.Price
WHERE st.Price <> pi.Price;


-- 3. Take care of missing values :- (To identify the null values in dataset and change it with 'Unknown')
select count(*) as "NULL"
from customer_profiles 
where  Age is null 
or CustomerID is null
or Gender is null
or Location = ""
or JoinDate is null;

-- Find missing values for every or specific columns :- 
SELECT 
    sum(case when CustomerID = "" then 1 else 0 End) as CustomerID_null,
    sum(case when Age = "" then 1 else 0 End) as Age_null,
    sum(case when Gender = "" then 1 else 0 End) as Gender_null,
    Sum(case when Location = "" then 1 else 0 End) as Location_null,
    sum(case when JoinDate = "" then 1 else 0 End) as JoinDate_null
FROM 
    customer_profiles;

-- now fill missing values to "Unknown" :- 
update customer_profiles 
set Location = "Unknown" 
where location = "" or location is null or location = " ";


-- Correcting Date format :-
Select *, cast(TransactionDate as Date) as TransactionDate_Correct 
from sales_transaction_noduplicate;

-- update in dataset :-
Create table sales_transaction_nodup_cDate as 
select  *, cast(TransactionDate as Date) as TransactionDate_Correct 
from sales_transaction_noduplicate;

Drop table sales_transaction_noduplicate;

Alter table sales_transaction_cDate 
rename sales_transaction_Cdate_NoDup;


-- <2> Business Problem :- 
-- Product Performance Variability: Identifying which products are performing well in terms of sales and which are not. 
-- This insight is crucial for inventory management and marketing focus.

-- Objective :- 
-- Identify High & Low Sales Products, which helps in making inventory and marketing decisions.

-- Top sales products :-
select pi.ProductID, pi.ProductName , pi.Category,
sum(st.QuantityPurchased) as Total_quantity, 
Round(sum(st.QuantityPurchased * st.Price),2) as Total_sales
from product_inventory pi
join sales_transaction_cdate_nodup st
on st.ProductID = pi.ProductID
group by pi.ProductID, pi.ProductName, pi.Category
order by Total_sales Desc;


-- Low sales products :- 
select pi.ProductID, pi.ProductName, pi.Category,
sum(st.QuantityPurchased) as Total_quantity, 
Round(sum(st.QuantityPurchased * st.Price),2) as Total_sales
from product_inventory pi
join sales_transaction_cdate_nodup st
on st.ProductID = pi.ProductID
group by pi.ProductID, pi.ProductName, pi.Category
order by Total_sales;


-- <3> Business Problem :- 
-- Customer Segmentation: The company lacks a clear understanding of its customer base segmentation. 
-- Effective segmentation is essential for targeted marketing and enhancing customer satisfaction.

-- Objective :- 
-- To segment customers based on their purchasing behavior for targeted marketing campaigns. Create Customer segments -
-- Total Quantity of Products Purchased  |  Customer Segment
--            O                          |  No Orders
--           1-10                        |  Low Orders
--           10-30                       |  Medium Orders 
--           >30                         |  High Orders 

Select A.CustomerID, Total_quantity ,
CASE 
    WHEN Total_quantity = 0 THEN "No Order"
    WHEN Total_quantity between 1 AND 10 THEN "Low"
    WHEN Total_quantity between 11 AND 30 THEN "Medium"
    WHEN Total_quantity > 30 THEN "High"
    ELSE "None"
END As Customer_segment
from 
( 
Select CustomerID, Sum(QuantityPurchased) as Total_quantity
from sales_transaction_cdate_nodup
group by CustomerID
) A ;


-- <4> Business Problem :- 
-- Customer Behaviour Analysis: Understanding patterns in customer behavior, including repeat purchases and loyalty indicators, 
-- is critical for tailoring, customer engagement strategies and improving retention rates.

-- Objective :- 
-- To analyze customer behavior for insights on repeat purchases and loyalty, informing customer retention strategies.

select CustomerID , count(*) as Frequency 
from sales_transaction_cdate_nodup
group by CustomerID
order by Frequency Desc 
limit 10 ;

```

## Findings

**Data Quality**: Duplicates removed, prices corrected, missing values handled, dates standardized.
**Product Performance**: Top and low-selling products identified for inventory and marketing focus.
**Customer Segmentation**: Customers classified as No, Low, Medium, or High orders.
**Customer Behavior**: Frequent buyers identified for loyalty and retention strategies.

## Reports 

- ** Sales Summary **: A detailed report summarizing total sales, customer demographics, and category performance.
- ** Trend Analysis **: Insights into sales trends across different years and months.
- ** Customer Insights **: Reports on top customers, purchase frequency and loyalty patterns.

## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and
business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and
product performance.

## How to Use

1. ** Clone the Repository **: Clone this project repository from GitHub.
2. ** Set Up the Database **: Run the SQL scripts provided in the `database_setup.sql' file to create and populate the database.
3. ** Run the Queries **: Use the SQL queries provided in the `analysis_queries.sql' file to perform your analysis.
4. ** Explore and Modify **: Feel free to modify the queries to explore different aspects of the dataset or answer additional business questions.

## Author - Zero Analyst

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to

collaborate, feel free to get in touch!
