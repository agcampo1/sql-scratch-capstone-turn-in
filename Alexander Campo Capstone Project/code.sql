
-- Quiz Funnel Question 1
SELECT *
 FROM survey
 LIMIT 10;

-- Quiz Funnel Question 2
SELECT question,
  COUNT(DISTINCT user_id)
FROM survey
GROUP BY question;

--Quiz Funnel Question 4
SELECT *
FROM quiz
LIMIT 5;

SELECT *
FROM home_try_on
LIMIT 5;

SELECT *
FROM purchase
LIMIT 5;

-- Quiz Funnel Question 5
SELECT DISTINCT quiz.user_id,
	CASE
  WHEN home_try_on.user_id IS NOT NULL THEN 'TRUE'
  WHEN home_try_on.user_id IS NULL THEN 'FALSE'
  END AS 'is_home_try_on',
  CASE
  WHEN home_try_on.number_of_pairs = '3 pairs' THEN '3'
  WHEN home_try_on.number_of_pairs = '5 pairs' THEN '5'
  ELSE 'NULL'
  END AS 'number_of_pairs',
  CASE
  WHEN purchase.user_id IS NOT NULL THEN 'TRUE'
  WHEN purchase.user_id IS NULL THEN 'FALSE'
  END AS 'is_purchase'
FROM quiz
LEFT JOIN home_try_on
	ON quiz.user_id = home_try_on.user_id
LEFT JOIN purchase
	ON purchase.user_id = quiz.user_id
LIMIT 10;


-- Overall Conversion Rates
WITH funnels AS(
  SELECT DISTINCT q.user_id,
   h.user_id IS NOT NULL AS 'is_home_try_on',
   h.number_of_pairs,
   p.user_id IS NOT NULL AS 'is_purchase'
FROM quiz q
LEFT JOIN home_try_on h
   ON q.user_id = h.user_id
LEFT JOIN purchase p
   ON p.user_id = q.user_id)
SELECT COUNT(user_id),
SUM(is_home_try_on),
SUM(is_purchase),
  1.0 * SUM(is_home_try_on) / COUNT(user_id) AS 'quiz_to_home_try_on',
  1.0 * SUM(is_purchase) / SUM(is_home_try_on) AS 'home_try_on_to_purchase'
FROM funnels;

-- Conversion Rates Based on Home Try On Number
WITH funnels AS(
  SELECT DISTINCT quiz.user_id,
	CASE
  WHEN home_try_on.user_id IS NOT NULL THEN 'TRUE'
  WHEN home_try_on.user_id IS NULL THEN 'FALSE'
  END AS 'is_home_try_on',
  CASE
  WHEN home_try_on.number_of_pairs = '3 pairs' THEN '3'
  WHEN home_try_on.number_of_pairs = '5 pairs' THEN '5'
  ELSE 'NULL'
  END AS 'number_of_pairs',
  purchase.user_id IS NOT NULL AS 'is_purchase'
FROM quiz
LEFT JOIN home_try_on
	ON quiz.user_id = home_try_on.user_id
LEFT JOIN purchase
	ON purchase.user_id = quiz.user_id)
SELECT number_of_pairs,
COUNT(DISTINCT(user_id)),
SUM(is_purchase),
  ROUND(1.0 * SUM(is_purchase) / COUNT(DISTINCT(user_id)),2) AS 'Purchase Rate'
FROM funnels
WHERE number_of_pairs IS NOT NULL
GROUP BY number_of_pairs;

--Most populat style and products
SELECT DISTINCT(style),
	COUNT(user_id)
FROM quiz
GROUP BY style;

SELECT DISTINCT(style),
	COUNT(user_id)
FROM purchase
GROUP BY style;

SELECT DISTINCT(product_id),
	style,
	COUNT(user_id) AS 'total'
FROM purchase
GROUP BY product_id
ORDER BY total DESC;