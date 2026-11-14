-- Each row reports how many records violate one check.
--   rule:  hard data-quality rules, expected to return 0
--   logic: business-logic checks; non-zero results need investigation, not necessarily errors

SELECT 'rule: binary flag outside {0, 1}' AS check_name, COUNT(*) AS n_violations
FROM campaign_raw
WHERE mens NOT IN (0, 1) OR womens NOT IN (0, 1) OR newbie NOT IN (0, 1)
   OR visit NOT IN (0, 1) OR conversion NOT IN (0, 1)

UNION ALL
SELECT 'rule: recency outside 1-12', COUNT(*)
FROM campaign_raw
WHERE recency NOT BETWEEN 1 AND 12

UNION ALL
SELECT 'rule: negative history or spend', COUNT(*)
FROM campaign_raw
WHERE history < 0 OR spend < 0

UNION ALL
SELECT 'rule: unexpected segment value', COUNT(*)
FROM campaign_raw
WHERE segment COLLATE utf8mb4_bin NOT IN ('Mens E-Mail', 'Womens E-Mail', 'No E-Mail')v

UNION ALL
SELECT 'rule: unexpected zip_code value', COUNT(*)
FROM campaign_raw
WHERE zip_code COLLATE utf8mb4_bin NOT IN ('Urban', 'Surburban', 'Rural')

UNION ALL
SELECT 'rule: unexpected channel value', COUNT(*)
FROM campaign_raw
WHERE channel COLLATE utf8mb4_bin NOT IN ('Web', 'Phone', 'Multichannel')

UNION ALL
SELECT 'logic: converted without a visit', COUNT(*)
FROM campaign_raw
WHERE conversion = 1 AND visit = 0

UNION ALL
SELECT 'logic: converted with zero spend', COUNT(*)
FROM campaign_raw
WHERE conversion = 1 AND spend = 0

UNION ALL
SELECT 'logic: spend without conversion', COUNT(*)
FROM campaign_raw
WHERE conversion = 0 AND spend > 0

UNION ALL
SELECT 'logic: no past purchase in either category', COUNT(*)
FROM campaign_raw
WHERE mens = 0 AND womens = 0

UNION ALL
SELECT 'logic: history_segment inconsistent with history', COUNT(*)
FROM campaign_raw
WHERE CAST(LEFT(history_segment, 1) AS UNSIGNED) <>
      CASE
          WHEN history <  100 THEN 1
          WHEN history <  200 THEN 2
          WHEN history <  350 THEN 3
          WHEN history <  500 THEN 4
          WHEN history <  750 THEN 5
          WHEN history < 1000 THEN 6
          ELSE 7
      END;