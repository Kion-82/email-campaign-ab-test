-- Sufficient statistics per arm for hypothesis testing in Python.
-- Proportion tests need counts; Welch's t-test needs the mean and variance.

SELECT
    arm,
    COUNT(*)                          AS n,
    SUM(visit)                        AS visits,
    SUM(conversion)                   AS conversions,
    AVG(CAST(spend AS DOUBLE))        AS spend_mean,
    VAR_SAMP(CAST(spend AS DOUBLE))   AS spend_var
FROM campaign_clean
GROUP BY arm
ORDER BY arm;