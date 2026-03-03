-- ============================================================
-- Cleanup: Remove duplicate REQUEST_NUMBERs from SERVICE_REQUESTS
-- Keeps the OLDEST record (earliest CREATED_AT) for each duplicate
-- ============================================================

-- Step 1: Preview duplicates to be deleted (DRY RUN)
SELECT 
    sr.REQUEST_NUMBER,
    sr.SERVICE_ID,
    sr.CREATED_AT,
    sr.REQUEST_TIMESTAMP,
    'TO_DELETE' AS action
FROM AAA_INTELLIGENCE.RAW.SERVICE_REQUESTS sr
INNER JOIN (
    SELECT REQUEST_NUMBER, MIN(CREATED_AT) AS min_created
    FROM AAA_INTELLIGENCE.RAW.SERVICE_REQUESTS
    GROUP BY REQUEST_NUMBER
    HAVING COUNT(*) > 1
) dups ON sr.REQUEST_NUMBER = dups.REQUEST_NUMBER 
       AND sr.CREATED_AT > dups.min_created
ORDER BY sr.REQUEST_NUMBER;

-- Step 2: Count records to be deleted
SELECT COUNT(*) AS records_to_delete
FROM AAA_INTELLIGENCE.RAW.SERVICE_REQUESTS sr
INNER JOIN (
    SELECT REQUEST_NUMBER, MIN(CREATED_AT) AS min_created
    FROM AAA_INTELLIGENCE.RAW.SERVICE_REQUESTS
    GROUP BY REQUEST_NUMBER
    HAVING COUNT(*) > 1
) dups ON sr.REQUEST_NUMBER = dups.REQUEST_NUMBER 
       AND sr.CREATED_AT > dups.min_created;

-- Step 3: Delete duplicates (KEEP OLDEST)
DELETE FROM AAA_INTELLIGENCE.RAW.SERVICE_REQUESTS
WHERE SERVICE_ID IN (
    SELECT sr.SERVICE_ID
    FROM AAA_INTELLIGENCE.RAW.SERVICE_REQUESTS sr
    INNER JOIN (
        SELECT REQUEST_NUMBER, MIN(CREATED_AT) AS min_created
        FROM AAA_INTELLIGENCE.RAW.SERVICE_REQUESTS
        GROUP BY REQUEST_NUMBER
        HAVING COUNT(*) > 1
    ) dups ON sr.REQUEST_NUMBER = dups.REQUEST_NUMBER 
           AND sr.CREATED_AT > dups.min_created
);

-- Step 4: Verify no duplicates remain
SELECT COUNT(*) AS remaining_duplicates
FROM (
    SELECT REQUEST_NUMBER
    FROM AAA_INTELLIGENCE.RAW.SERVICE_REQUESTS
    GROUP BY REQUEST_NUMBER
    HAVING COUNT(*) > 1
);
