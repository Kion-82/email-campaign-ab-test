-- CUPED variance reduction for spend per customer, using past-year spend (history)
-- as the pre-experiment covariate.
--   spend_cuped = spend - theta * (history - mean(history))
--   theta = cov(spend, history) / var(history), estimated on all customers pooled
-- Because history is measured before the campaign and is balanced across arms,
-- the adjustment leaves the expected treatment effect unchanged and only reduces variance.

WITH base AS (
    SELECT
        arm,
        CAST(spend   AS DOUBLE) AS y,
        CAST(history AS DOUBLE) AS x
    FROM campaign_clean
),
params AS (
    -- Population covariance and variance, pooled across all arms
    SELECT
        AVG(x)                                                          AS mean_x,
        (AVG(x * y) - AVG(x) * AVG(y)) / VAR_POP(x)                     AS theta,
        (AVG(x * y) - AVG(x) * AVG(y)) / (STDDEV_POP(x) * STDDEV_POP(y)) AS rho
    FROM base
),
adjusted AS (
    SELECT
        b.arm,
        b.y,
        b.y - p.theta * (b.x - p.mean_x) AS y_cuped
    FROM base AS b
    CROSS JOIN params AS p
)
SELECT
    a.arm,
    COUNT(*)              AS n,
    AVG(a.y)              AS spend_mean,
    VAR_SAMP(a.y)         AS spend_var,
    AVG(a.y_cuped)        AS spend_cuped_mean,
    VAR_SAMP(a.y_cuped)   AS spend_cuped_var,
    -- theta and rho are the same for every arm; MAX() is needed only because of GROUP BY
    MAX(p.theta)          AS theta,
    MAX(p.rho)            AS rho
FROM adjusted AS a
CROSS JOIN params AS p
GROUP BY a.arm
ORDER BY a.arm;