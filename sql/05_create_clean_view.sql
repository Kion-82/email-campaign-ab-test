-- Cleaned analysis layer built on top of campaign_raw.
-- The raw table is never modified; all fixes and derived fields live here.

CREATE OR REPLACE VIEW campaign_clean AS
SELECT
    customer_id,

    -- Experiment assignment
    CASE segment
        WHEN 'Mens E-Mail'   THEN 'mens'
        WHEN 'Womens E-Mail' THEN 'womens'
        WHEN 'No E-Mail'     THEN 'control'
    END                                          AS arm,
    CASE WHEN segment = 'No E-Mail' THEN 0 ELSE 1 END AS treated,  -- received any email

    -- Pre-experiment customer attributes
    recency,
    history,
    CAST(LEFT(history_segment, 1) AS UNSIGNED)   AS history_bin,     -- ordinal bin 1-7
    mens                                         AS bought_mens,     -- past purchase, not gender
    womens                                       AS bought_womens,   -- past purchase, not gender
    CASE
        WHEN mens = 1 AND womens = 1 THEN 'both'
        WHEN mens = 1                THEN 'mens_only'
        WHEN womens = 1              THEN 'womens_only'
    END                                          AS past_purchase_category,
    CASE zip_code
        WHEN 'Urban'     THEN 'urban'
        WHEN 'Surburban' THEN 'suburban'                             -- fix source misspelling
        WHEN 'Rural'     THEN 'rural'
    END                                          AS area_type,
    newbie                                       AS is_new_customer,
    LOWER(channel)                               AS channel,

    -- Outcomes measured within 2 weeks of the campaign
    visit,
    conversion,
    spend
FROM campaign_raw;