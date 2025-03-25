USE datawarehouseanalytics;

-- Age & Gender Distribution of Customers

SELECT 
Gender,
AVG(Purchase_Amount_USD) AS avg_usd_spent,
SUM(Purchase_Amount_USD) AS total_usd_spent
FROM shopping_trends
GROUP BY 1;

select 
CASE WHEN Age BETWEEN 18 AND 35 THEN "Young" 
	 WHEN Age BETWEEN 35 AND 55 THEN "Middle Age"
	 ELSE "Elderly"
END AS age_group,
COUNT(*) AS customer_count,
AVG(Purchase_Amount_USD) AS avg_usd_spent,
SUM(Purchase_Amount_USD) AS total_usd_spent    
from shopping_trends
GROUP BY 1;

-- Customer Purchase Behaviors based on location, gender, and subscription status.

SELECT 
Location,
Gender,
Subscription_Status,
count(*) Customer_Count,
avg(Purchase_Amount_USD) Avg_Dollar_Spent
from shopping_trends
group by 1,2,3
ORDER BY 1 , 2 desc, 3 desc


-- Most Preferred product categories and colors by different age groups

with preferred_product as
(select 
CASE WHEN Age BETWEEN 18 AND 35 THEN "Young" 
	 WHEN Age BETWEEN 35 AND 55 THEN "Middle Age"
	 ELSE "Elderly"
END AS age_group,
Category,
Color,
Count(*) total_purchased_items
from shopping_trends
group by 1,2,3
order by 1,2,4 desc),
ranked as 
(
select 
*,
rank() over(partition by age_group, Category order by total_purchased_items desc) as rnk
from  preferred_product
)
select 
age_group,
Category,
Color,
total_purchased_items
from ranked where rnk = 1;


-- Do customers with higher previous purchases tend to spend more per transaction?

select 
Customer_ID,
avg(Purchase_Amount_USD) avg_dollar_spent_per_transaction,
sum(Previous_Purchases) previous_purchase
from shopping_trends
group by 1
order by 3 desc


-- average purchase amount for each category
-- product type generates the most revenue

select 
Category,
avg(Purchase_Amount_USD) avg_dollar_spent
from shopping_trends
group by 1 
order by 1


select 
Item_Purchased as Product_Type,
sum(Purchase_Amount_USD) Revenue_Generated
from shopping_trends
group by 1 
order by 2 desc

-- impact of purchase frequency on total spending.

select 
Frequency_of_Purchases,
sum(Purchase_Amount_USD) Dollar_Spent
from shopping_trends
group by 1
order by 2 desc; 


-- most preferred payment method and its impact on total spending

select 
Payment_Method,
count(*) count,
sum(Purchase_Amount_USD) Total_Dollars_Spent
from shopping_trends
group by 1
order by 1 desc,2 desc;


-- Seasonal Product Trends 

with trends as 
(select 
Season,
Item_Purchased as Product,
count(*) Items_Purchased
from shopping_trends
group by 1,2
order by 1,3 desc
),
ranked as (
select 
*,
rank() over(PARTITION BY Season order by Items_Purchased desc) as rnk
from trends
)
select Season,Product,Items_Purchased 
from ranked
where rnk between 1 and 3;


-- impact of discounts and promo codes on sales

select 
Discount_Applied,
Promo_Code_Used ,
count(*) Count,
sum(Purchase_Amount_USD) Sales,
avg(Purchase_Amount_USD) Avg_Dollar_Spent
from shopping_trends
GROUP BY 1,2


-- Impact of Subscription Status on Spending Habbit

select 
Subscription_Status, 
Gender,
count(*) Cust_Count,
avg(Purchase_Amount_USD) Avg_Dollar_Spent,
sum(Purchase_Amount_USD) Revenue
from shopping_trends
group by 1,2


-- impact of shipping type on total purchase value

select
Shipping_Type,
count(*) Count,
sum(Purchase_Amount_USD) Total_Purchase_Value,
avg(Purchase_Amount_USD) Avg_Purchase_Value
from shopping_trends
group by 1 
order by 3 desc;


-- correleation between review rating and avg purchase value

select
Category,
Item_Purchased Product,
round(avg(Review_Rating),2) Avg_Review ,
AVG(Purchase_Amount_USD) avg_spent
from shopping_trends
group by 1,2
order by 1,4 desc; 


-- Spending -> Free Shipping vs Express

with shipping as
(select
Shipping_Type,
count(*) Count,
avg(Purchase_Amount_USD) Avg_Purchase_Value
from shopping_trends
group by 1 
order by 3 desc
)
select * from shipping
where Shipping_Type in('Free Shipping','Express')


