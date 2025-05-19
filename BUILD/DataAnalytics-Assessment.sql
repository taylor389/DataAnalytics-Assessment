Assessment_Q1.sql
-- High-Value customers with Multiple products
-- Scenario:The business wants to identify customers who have both a savings and an investment plan
-- (cross-selling opportunity).
Task: Write a query to find customers with at least one funded savings plan AND one funded investment plan,sorted by total_deposits
Explanation:
1.Join: I join users_customers with savings_savingsaccount and plans_plan to link customers with thier accounts 
and plans
2.Aggregation:I counted the distinct savings and investment plans and sum the deposits
3.Ensure only users with both products:it only includes those who appear in both subqueries
(have at least one savings and one  investment plan)
4.Order by highest total deposits:(order by total_deposits desc)-shows the most valuable customers first,
based on how much they have  deposited

SELECT                                                              
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    savings.savings_count,
    investments.investment_count,
    ROUND(IFNULL(total.total_deposits, 0) / 100, 2) AS total_deposits  -- in Naira
FROM 
    users_customuser u
JOIN (
    SELECT owner_id, COUNT(DISTINCT id) AS savings_count
    FROM plans_plan
    WHERE is_regular_savings = 1
    GROUP BY owner_id
) AS savings ON u.id = savings.owner_id
JOIN (
    SELECT owner_id, COUNT(DISTINCT id) AS investment_count
    FROM plans_plan
    WHERE is_a_fund = 1
    GROUP BY owner_id
) AS investments ON u.id = investments.owner_id
LEFT JOIN (
    SELECT owner_id, SUM(confirmed_amount) AS total_deposits
    FROM savings_savingsaccount
    WHERE confirmed_amount > 0
    GROUP BY owner_id
) AS total ON u.id = total.owner_id
ORDER BY total_deposits DESC;



Assessment_Q2.sql
 -- Transaction Frequency Analysis
 -- Scenario: The finance team wants to analyze how often customers transact to segment 
them (e.g., frequent vs. occasional users). 
-- Task: Calculate the average number of transactions per customer per month and 
categorize them: 
● "High Frequency" (≥10 transactions/month) 
● "Medium Frequency" (3-9 transactions/month) 
● "Low Frequency" (≤2 transactions/month) 

Explanation:
1.Subquery:I first summarize the number of transactions per customer over the last month
2.Case Statement:Categorize customer into frequency categories based on average transactions per month:
  * >=10: High Frequency
  * 3-9: Medium Frequency
  * <= 2: Low Frequency
3.Join: i left join back to users_customuser to count customers in each category
4.Aggregation: i calculated the average tranction per month for each frequency cateory

WITH Transactioncounts AS (
    SELECT 
        u.id AS customer_id,
        COUNT(s.id) AS total_transactions,
        GREATEST(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 1) AS tenure_months,
        ROUND(COUNT(s.id) / GREATEST(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 1), 2) AS avg_tx_per_month
    FROM users_customuser u
    LEFT JOIN savings_savingsaccount s ON u.id = s.owner_id
    GROUP BY u.id
),
categorized AS (
    SELECT 
        customer_id,
        avg_tx_per_month,
        CASE
            WHEN avg_tx_per_month >= 10 THEN 'High Frequency'
            WHEN avg_tx_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM Transactioncounts
)
SELECT 
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_tx_per_month), 2) AS avg_transactions_per_month
FROM categorized
GROUP BY frequency_category
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');





   Assessment_Q3.sql     
 -- Account Inactivity Alert
   -- Scenario:The ops team wants to flag accounts with no inflow transactions for over one year
  --  Task:Find all active account(savings or investments) with no transactions in the last 1 year(365 days)
   
   Explanation:
   1.Joins:I used left join to connect plans_plan with savings_savingsaccount  table based on the  related column (owner_id and confirmed
   inflow transactions)
   2.Conditions:I Filtered for active savings plans
   3.Aggregation:I find the maximum transaction date for each account to determine the last_transaction date.
   4.Inactivity calculation:I calculated inactivity days using DATEDIFF
   5.Having clause: I Filtered the accounts with inactivity greater than 365days
   
select 
    p.id as plan_id,
    p.owner_id,
    'savings' as type,
    MAX(s.transaction_date) as last_transaction_date,
       DATEDIFF(CURDATE(),MAX(s.transaction_date)) as inactivity_days
from  
     plans_plan p
left join
     savings_savingsaccount s on p.id = s.plan_id
where 
     p.is_deleted = FALSE AND
     p.is_archived = FALSE 
GROUP BY 
     p.id, p.owner_id
having 
     last_transaction_date is null
     or DATEDIFF(CURDATE(),last_transaction_date) > 365
     
     
     
 Assessment_Q4.sql
-- Customer Lifetime Value(CLV) ESTIMATED
 -- Scenario:Marketing wants to estimated CLV based on account tenure and transaction volume(simplified model)
  -- Task:For each customer,assuming the profit_per_profit_transaction is 0.1% of the transaction value,calculate:
  -- .Account tenure(months since signup)
  -- .Total transaction
  -- .Estimated clv(Assume:CLV =(total_transaction/tenure)*12* avg_profit_per_transaction)
  -- .Order by estimated CLV from highest to lowest
  Explanation:
  1.Join:I join  users_customuser with savings_savingsaccount to link customers with
  their transactions.
  2.Tenure Calculation:I calculated account tenure in months using TIMESTAMPDIFF
  3.Total_Transactions:i count the number of transactions for each customer
  4.Estimated CLV Calculation:I calcualated CLV using the formular provided,ensuring to 
  handle division by zero with NULLIF
   Order by:The resultsbare ordered by estimated CLV in descending order
	
SELECT 
    u.id AS customer_id,
    u.name,
    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,
    COUNT(s.id) AS total_transactions,
    ROUND((COUNT(s.id) / NULLIF(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 0)) * 12 * (AVG(s.confirmed_amount) * 0.001 / 100), 2) AS estimated_clv
FROM 
    users_customuser u
JOIN 
    savings_savingsaccount s ON u.id = s.owner_id
WHERE 
    s.confirmed_amount > 0  
GROUP BY 
    u.id, u.name, tenure_months
ORDER BY 
    estimated_clv DESC;
    
    
    
    
    
-- DataAnalytics-Assessment

-- Per-Question Explanations

--  Question 1: High-Value Customers with Multiple Products
 * Approach: I used JOINs to link customers with their savings and investment plans, filtered for funded products, and aggregated the
 results to count products and sum deposits.
 * Challenges: Ensuring accurate counting of distinct plans while filtering for the correct statuses.

--  Question 2: Transaction Frequency Analysis
 * Approach : I created a subquery to count transactions per customer over the last month, then categorized them using
 a CASE statement based on average transaction counts.
 * Challenges : Determining the correct date range for transactions and ensuring accurate categorization.
 
 --  Question 3: Account Inactivity Alert
 *  Approach: I used a LEFT JOIN to find accounts with no inflow transactions in the last year. The inactivity
 days were calculated using `DATEDIFF`.
 * Challenges: Ensuring that only active accounts were considered while handling cases with no transactions.

-- Question 4: Customer Lifetime Value (CLV) Estimation
 *Approach : I joined the users table with transaction records, calculated tenure, total transactions,
 and estimated CLV based on the provided formula.
 *Challenges : Handling potential division by zero when calculating CLV, which was resolved using `NULLIF`.



