---
name: data-quality
description: Use for data quality checks, data validation, null analysis, duplicate detection, freshness checks, or anomaly detection on AAA_INTELLIGENCE.RAW tables
---

# Data Quality Checks for AAA_INTELLIGENCE.RAW

## Tables in Scope
| Table | Description |
|-------|-------------|
| EARLY_WARNING_ALERTS | Early warning system alerts |
| INCIDENT_REPORTS | Incident tracking records |
| MEMBERS | Member master data |
| MEMBERSHIP_PLANS | Plan configurations |
| MEMBER_FEEDBACK | Customer feedback records |
| MEMBER_TRANSACTIONS | Financial transactions |
| PREDICTIVE_SCORES | ML prediction outputs |
| SERVICE_FULFILLMENT | Service completion records |
| SERVICE_NOTES | Technician notes |
| SERVICE_REGIONS | Geographic regions |
| SERVICE_REQUESTS | Service request tickets |
| SERVICE_TECHNICIANS | Technician master data |
| SERVICE_TRUCKS | Fleet inventory |
| VEHICLES | Vehicle master data |
| WEATHER_CONDITIONS | Weather data |

## Instructions

### 1. Completeness Check (Null Analysis)
Run null percentage analysis on critical columns:
```sql
SELECT 
    '{TABLE_NAME}' AS table_name,
    COUNT(*) AS total_rows,
    SUM(CASE WHEN {COLUMN} IS NULL THEN 1 ELSE 0 END) AS null_count,
    ROUND(100.0 * SUM(CASE WHEN {COLUMN} IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS null_pct
FROM AAA_INTELLIGENCE.RAW.{TABLE_NAME};
```

### 2. Uniqueness Check (Duplicate Detection)
Check for duplicate primary keys:
```sql
SELECT {PK_COLUMN}, COUNT(*) AS cnt
FROM AAA_INTELLIGENCE.RAW.{TABLE_NAME}
GROUP BY {PK_COLUMN}
HAVING COUNT(*) > 1;
```

### 3. Freshness Check
Check data recency for tables with timestamps:
```sql
SELECT 
    MAX({DATE_COLUMN}) AS latest_record,
    DATEDIFF('day', MAX({DATE_COLUMN}), CURRENT_DATE()) AS days_stale
FROM AAA_INTELLIGENCE.RAW.{TABLE_NAME};
```

### 4. Referential Integrity Check
Validate foreign key relationships:
```sql
SELECT COUNT(*) AS orphan_records
FROM AAA_INTELLIGENCE.RAW.{CHILD_TABLE} c
LEFT JOIN AAA_INTELLIGENCE.RAW.{PARENT_TABLE} p ON c.{FK_COLUMN} = p.{PK_COLUMN}
WHERE p.{PK_COLUMN} IS NULL;
```

### 5. Value Distribution Check
Identify outliers and anomalies:
```sql
SELECT 
    MIN({NUMERIC_COLUMN}) AS min_val,
    MAX({NUMERIC_COLUMN}) AS max_val,
    AVG({NUMERIC_COLUMN}) AS avg_val,
    STDDEV({NUMERIC_COLUMN}) AS std_dev
FROM AAA_INTELLIGENCE.RAW.{TABLE_NAME};
```

### 6. Row Count Trend
Monitor for unexpected data volume changes:
```sql
SELECT TABLE_NAME, ROW_COUNT, BYTES
FROM AAA_INTELLIGENCE.INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'RAW' AND TABLE_TYPE = 'BASE TABLE'
ORDER BY ROW_COUNT DESC;
```

## Key Relationships
- MEMBERS.MEMBER_ID → MEMBER_TRANSACTIONS, MEMBER_FEEDBACK, SERVICE_REQUESTS, VEHICLES
- SERVICE_REQUESTS.REQUEST_ID → SERVICE_FULFILLMENT, SERVICE_NOTES
- SERVICE_TECHNICIANS.TECHNICIAN_ID → SERVICE_FULFILLMENT
- SERVICE_TRUCKS.TRUCK_ID → SERVICE_FULFILLMENT
- SERVICE_REGIONS.REGION_ID → SERVICE_REQUESTS
- VEHICLES.VEHICLE_ID → SERVICE_REQUESTS, INCIDENT_REPORTS
- MEMBERSHIP_PLANS.PLAN_ID → MEMBERS

## Common Quality Issues to Check
1. **Members**: Validate email format, phone numbers, active status consistency
2. **Transactions**: Check for negative amounts, future dates, orphan member IDs
3. **Service Requests**: Validate status transitions, SLA compliance
4. **Predictive Scores**: Scores should be between 0-1, check for stale predictions
5. **Weather Conditions**: Validate temperature ranges, check for gaps in time series
