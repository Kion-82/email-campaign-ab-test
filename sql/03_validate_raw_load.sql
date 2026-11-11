-- Reconcile the loaded table against figures computed independently in pandas.

-- 1) Summary figures in a single row
SELECT
    COUNT(*)                         AS n_rows,
    SUM(segment = 'Mens E-Mail')     AS n_mens_arm,
    SUM(segment = 'Womens E-Mail')   AS n_womens_arm,
    SUM(segment = 'No E-Mail')       AS n_control_arm,
    SUM(conversion)                  AS n_conversions,
    SUM(history)                     AS total_history,
    SUM(spend)                       AS total_spend,
    MAX(history)                     AS max_history,
    MAX(spend)                       AS max_spend
FROM campaign_raw;

-- 2) History segments: confirms that values containing commas were parsed correctly
SELECT history_segment, COUNT(*) AS n
FROM campaign_raw
GROUP BY history_segment
ORDER BY history_segment;