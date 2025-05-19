# DataAnalytics-Assessment
- DataAnalytics-Assessment

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
 *Challenges : Handling potential division by zero when calculating CLV, which was resolved using `NULLIF`
