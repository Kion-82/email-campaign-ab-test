-- Core outcome metrics per experiment arm, with absolute and relative differences vs control.
-- All rate metrics use every customer in the arm as the denominator (the randomization unit).

WITH arm_metrics AS (
    SELECT
        arm,
        COUNT(*)                                        AS n_customers,
        -- Cast to DOUBLE: AVG over integers keeps only 4 decimal places by default
        AVG(CAST(visit      AS DOUBLE))                 AS visit_rate,
        AVG(CAST(conversion AS DOUBLE))                 AS conversion_rate,
        AVG(CAST(spend      AS DOUBLE))                 AS spend_per_customer,
        -- Descriptive only: conditions on a post-treatment outcome (who converted)
        SUM(spend) / NULLIF(SUM(conversion), 0)         AS avg_order_value
    FROM campaign_clean
    GROUP BY arm
),
control AS (
    SELECT
        visit_rate         AS control_visit_rate,
        conversion_rate    AS control_conversion_rate,
        spend_per_customer AS control_spend_per_customer
    FROM arm_metrics
    WHERE arm = 'control'
)
SELECT
    m.arm,
    m.n_customers,

    ROUND(m.visit_rate, 5)                                          AS visit_rate,
    ROUND(m.visit_rate - c.control_visit_rate, 5)                   AS visit_rate_diff,
    ROUND(m.visit_rate / c.control_visit_rate - 1, 4)               AS visit_rate_lift,

    ROUND(m.conversion_rate, 5)                                     AS conversion_rate,
    ROUND(m.conversion_rate - c.control_conversion_rate, 5)         AS conversion_rate_diff,
    ROUND(m.conversion_rate / c.control_conversion_rate - 1, 4)     AS conversion_rate_lift,

    ROUND(m.spend_per_customer, 4)                                  AS spend_per_customer,
    ROUND(m.spend_per_customer - c.control_spend_per_customer, 4)   AS spend_per_customer_diff,
    ROUND(m.spend_per_customer / c.control_spend_per_customer - 1, 4) AS spend_per_customer_lift,

    ROUND(m.avg_order_value, 2)                                     AS avg_order_value
FROM arm_metrics AS m
CROSS JOIN control AS c
ORDER BY FIELD(m.arm, 'control', 'mens', 'womens');