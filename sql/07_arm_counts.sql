-- Number of customers per experiment arm, used for the sample ratio mismatch (SRM) test.

SELECT arm, COUNT(*) AS n
FROM campaign_clean
GROUP BY arm
ORDER BY arm;