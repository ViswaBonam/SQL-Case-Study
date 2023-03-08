# A. Customer Nodes Exploration

- How many unique nodes are there on the Data Bank system?
```sql
SELECT COUNT(DISTINCT(node_id)) AS nodes_count FROM customer_nodes;
```
#### Output: ![image](https://user-images.githubusercontent.com/113131386/223725732-3ce6998f-b249-4025-b4a8-3145cda6da26.png)

---------------
- What is the number of nodes per region?
```sql
SELECT c.region_id, r.region_name, COUNT(c.node_id) AS node_count FROM customer_nodes c
JOIN regions r ON c.region_id=r.region_id
GROUP BY c.region_id, r.region_name
ORDER BY node_count DESC;
```
#### Output: ![image](https://user-images.githubusercontent.com/113131386/223727435-a76e3a0e-e92e-4cdc-94c7-00f184551f9a.png)

---------------
- How many customers are allocated to each region?
```sql
SELECT 
  region_id, 
  COUNT(customer_id) AS customer_count 
FROM customer_nodes
GROUP BY region_id
ORDER BY customer_count DESC;
```
#### Output: ![image](https://user-images.githubusercontent.com/113131386/223728444-a1608ecf-1f80-4756-ac82-4fffef5ec9c9.png)

---------------
- How many days on average are customers reallocated to a different node?
```sql

```
#### Output:
---------------
---------------
