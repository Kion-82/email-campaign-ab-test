-- Sufficient statistics per segment and arm, for subgroup (heterogeneous) treatment effects.
-- Segments are defined only by pre-experiment attributes, so randomization holds within each segment.
-- Column names match those expected by compare_arms() in src/stats.py.

WITH segments_long AS (
    -- Stack each segmentation dimension into one long table
    SELECT 'past_purchase_category' AS dimension, past_purchase_category AS segment,
           arm, visit, conversion, spend
    FROM campaign_clean
    UNION ALL
    SELECT 'area_type', area_type, arm, visit, conversion, spend
    FROM campaign_clean
    UNION ALL
    SELECT 'channel', channel, arm, visit, conversion, spend
    FROM campaign_clean
    UNION ALL
    SELECT 'customer_type',
           CASE is_new_customer WHEN 1 THEN 'new' ELSE 'existing' END,
           arm, visit, conversion, spend
    FROM campaign_clean
)
SELECT
    dimension,
    segment,
    arm,
    COUNT(*)                                                       AS n,
    -- Share of the arm that falls into this segment (window function over an aggregate)
    COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY dimension, arm)    AS segment_share,
    SUM(visit)                                                     AS visits,
    SUM(conversion)                                                AS conversions,
    AVG(CAST(spend AS DOUBLE))                                     AS spend_mean,
    VAR_SAMP(CAST(spend AS DOUBLE))                                AS spend_var
FROM segments_long
GROUP BY dimension, segment, arm
ORDER BY dimension, segment, arm;