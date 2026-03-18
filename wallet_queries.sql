Customer Lifetime and Spend Summary
SELECT
  COUNT ("Customer_ID") AS TotalCustomers,
  ROUND(AVG("Age")::numeric,1) AS Average_age,
  ROUND(AVG("LTV")::numeric,2) AS Average_LTV,
  SUM("Total_Spent") AS Total_Platform_Value
FROM digital_wallet_data

Preferred Payment Method Usage
Select
  "Preferred_Payment_Method",
   COUNT("Customer_ID") AS Total_Users,
   ROUND(AVG("Total_Spent"),2)
 From digital_wallet_data
 GROUP BY "Preferred_Payment_Method"
 ORDER BY Total_Users desc

Customer Lifetime Value by Location and Income
SELECT
   "Location",
   "Income_Level",
   COUNT("Customer_ID") AS Total_Customers,
   ROUND(AVG("LTV"::numeric),2) AS AVG_LTV
FROM digital_wallet_data
GROUP BY "Location","Income_Level"
ORDER BY AVG_LTV desc

Top 100 Customers by LTV
SELECT
  "Customer_ID",
  "Age",
  "Location",
  "Total_Spent",
  "LTV"
from digital_wallet_data
order by "LTV" desc
limit 100

Customer Activity Segments
select
  case
    when "Last_Transaction_Days_Ago" <= 30 then 'Active'
    when "Last_Transaction_Days_Ago" <= 90 then 'At Risk'
    else 'Dormant (90+ days)'
  end as User_Status,
  count ("Customer_ID") as Total_Customers
from digital_wallet_data
group by User_Status

Customer Satisfaction Summary by Score
select
  "Customer_Satisfaction_Score",
  ROUND(AVG("Support_Tickets_Raised"),2) AS AVG_Ticket_Raise,
  ROUND(AVG("Issue_Resolution_Time"::numeric),2) AS Avg_ResolutionTime_hours
  FROM digital_wallet_data
  group BY "Customer_Satisfaction_Score"
  order BY "Customer_Satisfaction_Score" desc

Top Spenders By Location
WITH RankedCustomer AS ( 
select
  "Customer_ID",
  "Location",
  "Total_Spent",
  DENSE_RANK() OVER (partition BY "Location" order BY "Total_Spent" desc) AS Spend_Rank
from digital_wallet_data
)
select * 
from RankedCustomer
where Spend_Rank <=5

Revenue Share By Income Segment
With TotalRevenue AS (
  select sum("Total_Spent") as Global_Revenue FROM digital_wallet_data
)
SELECT
  d."Income_Level",
  SUM(d."Total_Spent") as Segment_Revenue,
  Round((Sum(d."Total_Spent") / t.Global_Revenue)*100,2) AS revenue_percentage
from digital_wallet_data d
CROSS JOIN TotalRevenue t
group by d."Income_Level", t.Global_Revenue
order by revenue_percentage desc

Customer Revenue By Age Group
SELECT 
    CASE 
        WHEN "Age" < 25 THEN 'Gen Z (<25)'
        WHEN "Age" >= 25 AND "Age" <= 40 THEN 'Millennials (25-40)'
        WHEN "Age" >= 41 AND "Age" <= 56 THEN 'Gen X (41-56)'
        ELSE 'Boomers (56+)'
    END AS Age_Group,
    SUM("Total_Spent") as Total_Revenue,
    ROUND(AVG("Total_Transactions"), 0) as Avg_Transactions
FROM digital_wallet_data
GROUP BY Age_Group
ORDER BY Total_Revenue DESC

Cashback Tier Aggregation
SELECT 
    CASE 
        WHEN "Cashback_Received" > 3000 THEN 'High Cashback (>3000)'
        ELSE 'Low Cashback (<=3000)'
    END AS Cashback_Tier,
    COUNT("Customer_ID") AS Total_users,
    ROUND(AVG("Total_Spent"),2) AS AVG_Total_Spent,
    ROUND(AVG("LTV"::numeric),2) AS AVG_LifetimeValue
  from digital_wallet_data
  group by Cashback_Tier
