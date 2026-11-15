-- Standardized mean difference (SMD) of pre-experiment covariates,
-- comparing each email arm against the control arm.
-- SMD = (mean_treatment - mean_control) / sqrt((var_treatment + var_control) / 2)

WITH covariates_long AS (
    -- Unpivot covariates into long format, one row per customer per covariate.
    -- Boolean expressions evaluate to 1/0 in MySQL, giving dummy variables.
    SELECT arm, 'recency'              AS covariate, recency                    AS value FROM campaign_clean
    UNION ALL SELECT arm, 'history',              history                    FROM campaign_clean
    UNION ALL SELECT arm, 'bought_mens',          bought_mens                FROM campaign_clean
    UNION ALL SELECT arm, 'bought_womens',        bought_womens              FROM campaign_clean
    UNION ALL SELECT arm, 'is_new_customer',      is_new_customer            FROM campaign_clean
    UNION ALL SELECT arm, 'area_urban',           area_type = 'urban'        FROM campaign_clean
    UNION ALL SELECT arm, 'area_suburban',        area_type = 'suburban'     FROM campaign_clean
    UNION ALL SELECT arm, 'area_rural',           area_type = 'rural'        FROM campaign_clean
    UNION ALL SELECT arm, 'channel_web',          channel = 'web'            FROM campaign_clean
    UNION ALL SELECT arm, 'channel_phone',        channel = 'phone'          FROM campaign_clean
    UNION ALL SELECT arm, 'channel_multichannel', channel = 'multichannel'   FROM campaign_clean
),
arm_stats AS (
    -- Mean and sample variance of each covariate within each arm
    SELECT
        arm,
        covariate,
        AVG(value)      AS mean_value,
        VAR_SAMP(value) AS var_value
    FROM covariates_long
    GROUP BY arm, covariate
)
SELECT
    t.covariate,
    t.arm                                     AS treatment_arm,
    ROUND(c.mean_value, 4)                    AS control_mean,
    ROUND(t.mean_value, 4)                    AS treatment_mean,
    ROUND(
        (t.mean_value - c.mean_value)
        / SQRT((t.var_value + c.var_value) / 2),
        4
    )                                         AS smd
FROM arm_stats AS t
JOIN arm_stats AS c
    ON  c.covariate = t.covariate
    AND c.arm = 'control'          -- pair every arm with the control arm for the same covariate
WHERE t.arm <> 'control'
ORDER BY t.covariate, t.arm;