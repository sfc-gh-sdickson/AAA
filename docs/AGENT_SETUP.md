<img src="../../Snowflake_Logo.svg" width="200">

# AAA Intelligence Agent - Setup Guide

This guide walks through configuring a Snowflake Intelligence agent for AAA's roadside assistance and member intelligence solution.

---

## Prerequisites

1. **Snowflake Account** with:
   - Snowflake Intelligence (Cortex) enabled
   - Appropriate warehouse size (recommended: X-SMALL or larger)
   - Permissions to create databases, schemas, tables, and semantic views

2. **Roles and Permissions**:
   - `ACCOUNTADMIN` role or equivalent for initial setup
   - `CREATE DATABASE` privilege
   - `CREATE SEMANTIC VIEW` privilege
   - `CREATE CORTEX SEARCH SERVICE` privilege
   - `USAGE` on warehouses

---

## Step 1: Execute SQL Scripts in Order

Execute the SQL files in the following sequence:

### 1.1 Database Setup
```sql
-- Execute: sql/setup/01_database_and_schema.sql
-- Creates database, schemas (RAW, ANALYTICS), and warehouse
-- Execution time: < 1 second
```

### 1.2 Create Tables
```sql
-- Execute: sql/setup/02_create_tables.sql
-- Creates all table structures with proper relationships
-- Tables: MEMBERS, VEHICLES, SERVICE_REQUESTS, SERVICE_FULFILLMENT,
--         SERVICE_TECHNICIANS, SERVICE_TRUCKS, SERVICE_REGIONS,
--         WEATHER_CONDITIONS, PREDICTIVE_SCORES, EARLY_WARNING_ALERTS, etc.
-- Execution time: < 5 seconds
```

### 1.3 Generate Sample Data
```sql
-- Execute: sql/data/03_generate_synthetic_data.sql
-- Generates realistic sample data:
--   - 100,000 members
--   - 150,000 vehicles
--   - 2,000,000 service requests
--   - 2,000,000 service fulfillments
--   - 500 technicians
--   - 750 trucks
--   - Weather and predictive data
-- Execution time: 10-20 minutes (depending on warehouse size)
```

### 1.4 Create Analytical Views
```sql
-- Execute: sql/views/04_create_views.sql
-- Creates curated analytical views:
--   - V_MEMBER_360
--   - V_SERVICE_PERFORMANCE
--   - V_FLEET_ANALYTICS
--   - V_DEMAND_PATTERNS
--   - V_REGIONAL_PERFORMANCE
--   - V_PREDICTIVE_INSIGHTS
--   - V_ALERT_DASHBOARD
--   - V_REVENUE_IMPACT
-- Execution time: < 5 seconds
```

### 1.5 Create Semantic Views
```sql
-- Execute: sql/views/05_create_semantic_views.sql
-- Creates semantic views for AI agents (VERIFIED SYNTAX):
--   - SV_MEMBER_SERVICE_INTELLIGENCE
--   - SV_FLEET_OPERATIONS_INTELLIGENCE
--   - SV_PREDICTIVE_ANALYTICS_INTELLIGENCE
-- Execution time: < 5 seconds
```

### 1.6 Create Cortex Search Services
```sql
-- Execute: sql/search/06_create_cortex_search.sql
-- Creates tables for unstructured text data:
--   - SERVICE_NOTES (500,000 technician notes)
--   - MEMBER_FEEDBACK (100,000 feedback entries)
--   - INCIDENT_REPORTS (50,000 incident reports)
-- Creates Cortex Search services for semantic search:
--   - SERVICE_NOTES_SEARCH
--   - MEMBER_FEEDBACK_SEARCH
--   - INCIDENT_REPORTS_SEARCH
-- Execution time: 5-10 minutes (data generation + index building)
```

---

## Step 2: Create Snowflake Intelligence Agent

### 2.1 Via Snowsight UI

1. Navigate to **Snowsight** (Snowflake Web UI)
2. Go to **AI & ML** → **Agents**
3. Click **Create Agent**
4. Configure the agent:

**Basic Settings:**
```yaml
Name: AAA_Intelligence_Agent
Description: AI agent for analyzing AAA roadside assistance operations, member services, and fleet management
```

**Data Sources (Semantic Views):**
Add the following semantic views:
- `AAA_INTELLIGENCE.ANALYTICS.SV_MEMBER_SERVICE_INTELLIGENCE`
- `AAA_INTELLIGENCE.ANALYTICS.SV_FLEET_OPERATIONS_INTELLIGENCE`
- `AAA_INTELLIGENCE.ANALYTICS.SV_PREDICTIVE_ANALYTICS_INTELLIGENCE`

**Warehouse:**
- Select: `AAA_WH`

**Instructions (System Prompt):**
```
You are an AI intelligence agent for AAA (American Automobile Association), California's largest roadside assistance provider.

Your role is to analyze:
1. Member Services: Roadside assistance requests, response times, satisfaction scores
2. Fleet Operations: Truck availability, technician performance, regional coverage
3. Predictive Analytics: Breakdown risks, churn predictions, demand forecasting
4. Early Warnings: High demand alerts, weather impacts, resource shortages
5. Financial Impact: Lifetime value, service costs, revenue optimization

When answering questions:
- Provide specific metrics and data-driven insights
- Compare performance across regions and time periods
- Identify members at risk and recommend proactive outreach
- Analyze service patterns and operational efficiency
- Calculate SLA compliance and response time metrics
- Suggest fleet optimization and resource allocation

Data Context:
- Service Types: TOWING, BATTERY_JUMP, FLAT_TIRE, LOCKOUT, FUEL_DELIVERY
- Membership Levels: CLASSIC, PLUS, PREMIER
- California Regions: Los Angeles, San Francisco, San Diego, Sacramento, Inland Empire, Central Valley
- Priority Levels: LOW, MEDIUM, HIGH
- Key Metrics: Response time, satisfaction score, breakdown risk, churn risk
```

5. Click **Create Agent**

---

## Step 3: Add Cortex Search Services to Agent

### 3.1 Add Service Notes Search

1. In Agent settings, click **Tools**
2. Find **Cortex Search** and click **+ Add**
3. Configure:
   - **Name**: Service Notes Search
   - **Search service**: `AAA_INTELLIGENCE.RAW.SERVICE_NOTES_SEARCH`
   - **Warehouse**: `AAA_WH`
   - **Description**:
     ```
     Search 500,000 technician service notes to find similar vehicle issues,
     repair procedures, and technical solutions. Use for questions about
     common problems, best practices, and service techniques.
     ```

### 3.2 Add Member Feedback Search

1. Click **+ Add** again for Cortex Search
2. Configure:
   - **Name**: Member Feedback Search
   - **Search service**: `AAA_INTELLIGENCE.RAW.MEMBER_FEEDBACK_SEARCH`
   - **Warehouse**: `AAA_WH`
   - **Description**:
     ```
     Search 100,000 member feedback entries to understand satisfaction drivers,
     service quality issues, and member preferences. Use for questions about
     customer experience and service improvements.
     ```

### 3.3 Add Incident Reports Search

1. Click **+ Add** again for Cortex Search
2. Configure:
   - **Name**: Incident Reports Search
   - **Search service**: `AAA_INTELLIGENCE.RAW.INCIDENT_REPORTS_SEARCH`
   - **Warehouse**: `AAA_WH`
   - **Description**:
     ```
     Search 50,000 incident reports for safety issues, accident patterns,
     and emergency procedures. Use for questions about safety protocols,
     risk prevention, and incident management.
     ```

---

## Step 4: Test the Agent

### 4.1 Simple Test Questions

Start with simple questions to verify connectivity:

1. **"How many AAA members do we have?"**
   - Should query SV_MEMBER_SERVICE_INTELLIGENCE
   - Expected: ~100,000 members

2. **"What is the average response time for service requests?"**
   - Should query SV_MEMBER_SERVICE_INTELLIGENCE
   - Expected: Average in minutes

3. **"How many service trucks are currently available?"**
   - Should query SV_FLEET_OPERATIONS_INTELLIGENCE
   - Expected: Count of trucks with status = 'AVAILABLE'

### 4.2 Complex Test Questions

Test with the 10 complex questions provided in `docs/questions.md`, including:

1. High-Risk Member Identification for Proactive Outreach
2. Fleet Optimization During Peak Demand Periods
3. Service Level Agreement (SLA) Performance Analysis
4. Weather Impact on Service Demand Prediction
5. Member Lifetime Value and Retention Analysis
6. Regional Resource Allocation Optimization
7. Technician Performance and Training Needs
8. Vehicle Breakdown Pattern Recognition
9. Revenue Impact of Service Delays
10. Seasonal Demand Forecasting Accuracy

### 4.3 Cortex Search Test Questions

Test unstructured data search:

1. **"Search service notes for battery problems in cold weather"**
2. **"Find member feedback about exceptional technicians"**
3. **"What do incident reports say about highway safety procedures?"**

---

## Step 5: Query Cortex Search Services Directly

You can also query Cortex Search services directly using SQL:

### Query Service Notes
```sql
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
      'AAA_INTELLIGENCE.RAW.SERVICE_NOTES_SEARCH',
      '{
        "query": "battery jump start procedures cold weather",
        "columns":["note_text", "service_type", "severity"],
        "limit":10
      }'
  )
)['results'] as results;
```

### Query Member Feedback
```sql
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
      'AAA_INTELLIGENCE.RAW.MEMBER_FEEDBACK_SEARCH',
      '{
        "query": "excellent service quick response",
        "columns":["feedback_text", "satisfaction_score"],
        "limit":10
      }'
  )
)['results'] as results;
```

### Query Incident Reports
```sql
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
      'AAA_INTELLIGENCE.RAW.INCIDENT_REPORTS_SEARCH',
      '{
        "query": "highway accident safety procedures",
        "columns":["incident_description", "severity"],
        "limit":5
      }'
  )
)['results'] as results;
```

---

## Step 6: Access Control

### Create Role for Agent Users
```sql
CREATE ROLE IF NOT EXISTS AAA_AGENT_USER;

-- Grant necessary privileges
GRANT USAGE ON DATABASE AAA_INTELLIGENCE TO ROLE AAA_AGENT_USER;
GRANT USAGE ON SCHEMA AAA_INTELLIGENCE.ANALYTICS TO ROLE AAA_AGENT_USER;
GRANT USAGE ON SCHEMA AAA_INTELLIGENCE.RAW TO ROLE AAA_AGENT_USER;
GRANT SELECT ON ALL VIEWS IN SCHEMA AAA_INTELLIGENCE.ANALYTICS TO ROLE AAA_AGENT_USER;
GRANT USAGE ON WAREHOUSE AAA_WH TO ROLE AAA_AGENT_USER;

-- Grant Cortex Search usage
GRANT USAGE ON CORTEX SEARCH SERVICE AAA_INTELLIGENCE.RAW.SERVICE_NOTES_SEARCH TO ROLE AAA_AGENT_USER;
GRANT USAGE ON CORTEX SEARCH SERVICE AAA_INTELLIGENCE.RAW.MEMBER_FEEDBACK_SEARCH TO ROLE AAA_AGENT_USER;
GRANT USAGE ON CORTEX SEARCH SERVICE AAA_INTELLIGENCE.RAW.INCIDENT_REPORTS_SEARCH TO ROLE AAA_AGENT_USER;

-- Grant to specific user
GRANT ROLE AAA_AGENT_USER TO USER your_username;
```

---

## Troubleshooting

### Issue: Semantic views not found

**Solution:**
```sql
-- Verify semantic views exist
SHOW SEMANTIC VIEWS IN SCHEMA AAA_INTELLIGENCE.ANALYTICS;

-- Check permissions
SHOW GRANTS ON SEMANTIC VIEW SV_MEMBER_SERVICE_INTELLIGENCE;
```

### Issue: Cortex Search returns no results

**Solution:**
```sql
-- Verify service exists and is populated
SHOW CORTEX SEARCH SERVICES IN SCHEMA RAW;

-- Check data in source table
SELECT COUNT(*) FROM RAW.SERVICE_NOTES;

-- Verify change tracking is enabled
SHOW TABLES LIKE 'SERVICE_NOTES';
```

### Issue: Slow query performance

**Solution:**
- Increase warehouse size (MEDIUM or LARGE)
- Check for missing filters on date columns
- Review query execution plan
- Consider materializing frequently-used aggregations

---

## Success Metrics

Your agent is successfully configured when:

✅ All 6 SQL scripts execute without errors  
✅ All semantic views are created and validated  
✅ All 3 Cortex Search services are created and indexed  
✅ Agent can answer simple test questions  
✅ Agent can answer complex analytical questions  
✅ Cortex Search returns relevant results  
✅ Query performance is acceptable (< 30 seconds for complex queries)  
✅ Results are accurate and match expected business logic  

---

## Support Resources

- **Snowflake Documentation**: https://docs.snowflake.com/en/sql-reference/sql/create-semantic-view
- **AAA Website**: https://www.aaa.com
- **Snowflake Community**: https://community.snowflake.com

---

**Version:** 1.0  
**Created:** October 2025  
**Based on:** Early-Warning Intelligence Template
