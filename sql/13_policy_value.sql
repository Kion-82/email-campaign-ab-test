-- Incremental spend (vs sending no email) under alternative targeting policies,
-- using past purchase category as the targeting dimension.
-- Policy value = sum over segments of (segment size x uplift of the email it receives).

WITH segment_arm AS (
    SELECT
        past_purchase_category      AS segment,
        arm,
        COUNT(*)                    AS n,
        AVG(CAST(spend AS DOUBLE))  AS spend_mean
    FROM campaign_clean
    GROUP BY past_purchase_category, arm
),
segment_wide AS (
    -- Pivot arms into columns with conditional aggregation (MySQL has no PIVOT clause)
    SELECT
        segment,
        SUM(n)                                              AS n_customers,
        MAX(CASE WHEN arm = 'control' THEN spend_mean END)  AS control_mean,
        MAX(CASE WHEN arm = 'mens'    THEN spend_mean END)  AS mens_mean,
        MAX(CASE WHEN arm = 'womens'  THEN spend_mean END)  AS womens_mean
    FROM segment_arm
    GROUP BY segment
)
SELECT
    segment,
    n_customers,
    mens_mean   - control_mean                                  AS mens_uplift,
    womens_mean - control_mean                                  AS womens_uplift,
    CASE WHEN mens_mean >= womens_mean THEN 'mens' ELSE 'womens' END AS best_email,
    n_customers * (mens_mean   - control_mean)                  AS incremental_spend_all_mens,
    n_customers * (womens_mean - control_mean)                  AS incremental_spend_all_womens,
    n_customers * (GREATEST(mens_mean, womens_mean) - control_mean) AS incremental_spend_targeted
FROM segment_wide
ORDER BY segment;