-- Create the raw table for the Hillstrom email campaign dataset.
-- The raw layer mirrors the source CSV as faithfully as possible;
-- cleaning and validation happen in later steps.

DROP TABLE IF EXISTS campaign_raw;

CREATE TABLE campaign_raw (
    customer_id      INT UNSIGNED     NOT NULL AUTO_INCREMENT,  -- surrogate key (not in source)
    recency          TINYINT UNSIGNED NOT NULL,  -- months since last purchase (1-12)
    history_segment  VARCHAR(32)      NOT NULL,  -- binned history, kept as-is from source
    history          DECIMAL(10, 2)   NOT NULL,  -- actual spend in the past year (USD)
    mens             TINYINT UNSIGNED NOT NULL,  -- 1 = purchased men's merchandise in the past year
    womens           TINYINT UNSIGNED NOT NULL,  -- 1 = purchased women's merchandise in the past year
    zip_code         VARCHAR(32)      NOT NULL,  -- Urban / Surburban (sic) / Rural
    newbie           TINYINT UNSIGNED NOT NULL,  -- 1 = new customer in the past 12 months
    channel          VARCHAR(32)      NOT NULL,  -- purchase channel(s) in the past year
    segment          VARCHAR(32)      NOT NULL,  -- experiment arm: Mens E-Mail / Womens E-Mail / No E-Mail
    visit            TINYINT UNSIGNED NOT NULL,  -- 1 = visited the website within 2 weeks
    conversion       TINYINT UNSIGNED NOT NULL,  -- 1 = purchased within 2 weeks
    spend            DECIMAL(10, 2)   NOT NULL,  -- amount spent within 2 weeks (USD)
    PRIMARY KEY (customer_id)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_0900_ai_ci;