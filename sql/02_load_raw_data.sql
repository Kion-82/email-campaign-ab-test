-- Bulk-load the raw CSV into campaign_raw.
-- Run from the project root so that the relative file path resolves correctly.

TRUNCATE TABLE campaign_raw;  -- makes the script re-runnable and resets AUTO_INCREMENT

LOAD DATA LOCAL INFILE 'data/raw/hillstrom.csv'
INTO TABLE campaign_raw
FIELDS TERMINATED BY ','
       OPTIONALLY ENCLOSED BY '"'      -- handles commas inside quoted values, e.g. "6) $750 - $1,000"
LINES TERMINATED BY '\n'
IGNORE 1 LINES                          -- skip the header row
(recency, history_segment, history, mens, womens, zip_code, newbie,
 channel, segment, visit, conversion, @spend)
SET spend = TRIM(TRAILING '\r' FROM @spend);  -- strip a trailing CR if the file uses Windows line endings

-- LOCAL loads downgrade data errors to warnings, so check them explicitly
SHOW COUNT(*) WARNINGS;
SHOW WARNINGS LIMIT 10;