-- Value distribution of every categorical field in campaign_clean.
-- Any NULL value would indicate an unmapped source value.

SELECT 'arm' AS field, arm AS value, COUNT(*) AS n
FROM campaign_clean GROUP BY arm

UNION ALL
SELECT 'treated', CAST(treated AS CHAR), COUNT(*)
FROM campaign_clean GROUP BY treated

UNION ALL
SELECT 'past_purchase_category', past_purchase_category, COUNT(*)
FROM campaign_clean GROUP BY past_purchase_category

UNION ALL
SELECT 'area_type', area_type, COUNT(*)
FROM campaign_clean GROUP BY area_type

UNION ALL
SELECT 'channel', channel, COUNT(*)
FROM campaign_clean GROUP BY channel

ORDER BY field, value;