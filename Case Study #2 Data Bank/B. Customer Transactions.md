# B. Customer Transactions

* What is the unique count and total amount for each transaction type?
```sql
SELECT 
  txn_type, 
  COUNT(txn_type) AS count, 
  SUM(txn_amount) AS total_amount 
FROM customer_transactions
GROUP BY txn_type
ORDER BY total_amount DESC;	
```
Output: ![image](https://user-images.githubusercontent.com/113131386/224016030-55827bff-ac22-498f-a56b-f347cf18bd98.png)

------------

* What is the average total historical deposit counts and amounts for all customers?
```sql
WITH deposit AS 
  (SELECT 
    customer_id, 
    txn_type, COUNT(*) AS txn_count, 
    AVG(txn_amount) AS avg_amount 
  FROM customer_transactions 
  GROUP BY customer_id, txn_type) 
SELECT 
  ROUND(AVG(txn_count), 0) AS avg_deposit, 
  ROUND(AVG(avg_amount), 3) AS avg_amount 
FROM deposit
WHERE txn_type = 'deposit';
```
Output: ![image](https://user-images.githubusercontent.com/113131386/224020708-9a7352c0-cfa3-4492-a114-7f7bedcaef04.png)

-----------
* For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
```sql
WITH txn_monthly AS
	(SELECT 
		customer_id, 
		EXTRACT(month FROM txn_date) AS month,
		SUM(CASE WHEN txn_type = 'deposit' THEN 0 ELSE 1 END) AS deposit_count,
		SUM(CASE WHEN txn_type = 'purchase' THEN 0 ELSE 1 END) AS purchase_count,
		SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal_count
	  FROM data_bank.customer_transactions
	  GROUP BY customer_id, month)
SELECT month, COUNT(DISTINCT customer_id) AS customer_count FROM txn_monthly
WHERE deposit_count>1
	AND (purchase_count>=1 OR withdrawal_count>=1)
GROUP BY month;
```
Output: ![image](https://user-images.githubusercontent.com/113131386/224025035-a1a01343-a5c0-4c4f-876a-34ecab285d5e.png)
