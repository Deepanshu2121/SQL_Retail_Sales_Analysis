-- <1> Business Problems :-
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







