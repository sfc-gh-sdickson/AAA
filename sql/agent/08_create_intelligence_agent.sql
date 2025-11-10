-- ============================================================================
-- ACE Intelligence Agent - Create Snowflake Intelligence Agent
-- ============================================================================
-- Purpose: Create and configure Snowflake Intelligence Agent with:
--          - Cortex Analyst tools (Semantic Views)
--          - Cortex Search tools (Unstructured Data)
--          - ML Model tools (Predictions)
-- Execution: Run this after completing steps 01-07
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE AAA_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE AAA_WH;

-- ============================================================================
-- Step 1: Grant Required Permissions for Cortex Analyst
-- ============================================================================

-- Grant Cortex Analyst user role to your role
-- Replace <your_role> with your actual role name (e.g., SYSADMIN, custom role)
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_ANALYST_USER TO ROLE SYSADMIN;

-- Grant usage on database and schemas
GRANT USAGE ON DATABASE AAA_INTELLIGENCE TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA AAA_INTELLIGENCE.ANALYTICS TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA AAA_INTELLIGENCE.RAW TO ROLE SYSADMIN;

-- Grant privileges on semantic views for Cortex Analyst
GRANT REFERENCES, SELECT ON SEMANTIC VIEW AAA_INTELLIGENCE.ANALYTICS.SV_MEMBER_SERVICE_INTELLIGENCE TO ROLE SYSADMIN;
GRANT REFERENCES, SELECT ON SEMANTIC VIEW AAA_INTELLIGENCE.ANALYTICS.SV_FLEET_OPERATIONS_INTELLIGENCE TO ROLE SYSADMIN;
GRANT REFERENCES, SELECT ON SEMANTIC VIEW AAA_INTELLIGENCE.ANALYTICS.SV_PREDICTIVE_ANALYTICS_INTELLIGENCE TO ROLE SYSADMIN;

-- Grant usage on warehouse
GRANT USAGE ON WAREHOUSE AAA_WH TO ROLE SYSADMIN;

-- Grant usage on Cortex Search services
GRANT USAGE ON CORTEX SEARCH SERVICE AAA_INTELLIGENCE.RAW.SERVICE_NOTES_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE AAA_INTELLIGENCE.RAW.MEMBER_FEEDBACK_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE AAA_INTELLIGENCE.RAW.INCIDENT_REPORTS_SEARCH TO ROLE SYSADMIN;

-- Grant execute on ML model wrapper procedures (if you've created them)
GRANT USAGE ON PROCEDURE AAA_INTELLIGENCE.ANALYTICS.PREDICT_SERVICE_VOLUME(INT) TO ROLE SYSADMIN;
GRANT USAGE ON PROCEDURE AAA_INTELLIGENCE.ANALYTICS.PREDICT_MEMBER_CHURN(VARCHAR) TO ROLE SYSADMIN;
GRANT USAGE ON PROCEDURE AAA_INTELLIGENCE.ANALYTICS.PREDICT_RESPONSE_SUCCESS(VARCHAR) TO ROLE SYSADMIN;

-- ============================================================================
-- Step 2: Create Snowflake Intelligence Agent
-- ============================================================================

CREATE OR REPLACE AGENT AAA_INTELLIGENCE_AGENT
  COMMENT = 'ACE Intelligence Agent for roadside assistance operations and member services analytics'
  PROFILE = '{"display_name": "ACE Intelligence Agent", "avatar": "car-icon.png", "color": "red"}'
  FROM SPECIFICATION
  $$
models:
  orchestration: AUTO

orchestration:
  budget:
    seconds: 60
    tokens: 32000

instructions:
  response: 'You are a specialized analytics assistant for ACE roadside assistance operations. For structured data queries use Cortex Analyst semantic views. For unstructured content use Cortex Search services. For predictions use ML model procedures. Keep responses concise and data-driven.'
  orchestration: 'For metrics and KPIs use Cortex Analyst tools. For service notes, feedback, and incident reports use Cortex Search tools. For forecasting use ML function tools.'
  system: 'You help analyze ACE member data including service requests, fleet operations, predictive analytics, and customer satisfaction using structured and unstructured data sources.'
  sample_questions:
    - question: 'How many active members do we have?'
      answer: 'I will query the member data to count total active members in the system.'
    - question: 'What is our average response time?'
      answer: 'I will use the Fleet Operations Intelligence view to calculate the average response time across all service fulfillments.'
    - question: 'Show me all membership levels available.'
      answer: 'I will query the member service data to list all distinct membership levels offered by ACE.'
    - question: 'How many service trucks are currently available?'
      answer: 'I will use the Fleet Operations Intelligence view to count trucks with available status.'
    - question: 'What is the average member satisfaction score?'
      answer: 'I will query service fulfillment data to calculate the average member satisfaction score across all completed services.'
    - question: 'Analyze service request patterns by type and priority. Show me total requests, breakdown by service type, high priority percentage, and which regions have the highest demand.'
      answer: 'I will use the Member Service Intelligence semantic view to analyze service patterns across different types, priorities, and regional distribution.'
    - question: 'Analyze fleet utilization and technician performance. Show me average response times by region, technician efficiency metrics, and truck utilization rates.'
      answer: 'I will query the Fleet Operations Intelligence data to analyze fleet performance metrics, regional variations, and identify optimization opportunities.'
    - question: 'Analyze member risk profiles and early warning alerts. Show me members with high breakdown risk, active alerts by severity, and recommended preventive outreach.'
      answer: 'I will use the Predictive Analytics Intelligence view to analyze risk scores, early warning alerts, and generate actionable recommendations.'
    - question: 'Analyze correlation between weather conditions and service demand. Show me how rain, snow, and temperature affect request volumes and response times.'
      answer: 'I will analyze weather condition data with service requests to show the impact of weather patterns on ACE operations and member needs.'
    - question: 'Analyze membership value and retention patterns. Show me lifetime value distribution, renewal rates by membership level, and factors affecting member churn.'
      answer: 'I will use member transaction and service data to analyze value metrics, retention patterns, and identify key drivers of member loyalty.'
    - question: 'Predict service request volume for the next 6 months based on historical patterns.'
      answer: 'I will use the Service Volume Forecasting ML model to predict future monthly request volumes for capacity planning.'
    - question: 'Which members are at highest risk of cancellation? Focus on Premier members with upcoming renewals.'
      answer: 'I will use the Member Churn Prediction ML model to identify Premier members likely to cancel and calculate churn probability scores.'
    - question: 'Predict response success rate for towing services during the next storm event.'
      answer: 'I will use the Response Success Prediction ML model to assess likelihood of successful towing service completion during adverse weather conditions.'
    - question: 'Forecast demand for battery jump services for the upcoming winter season.'
      answer: 'I will use the Service Volume Forecasting model with service type filtering to project battery service demand for winter months.'
    - question: 'Identify Classic members who should be upgraded to Plus based on service usage and churn risk.'
      answer: 'I will use the Member Churn Prediction model with service usage analysis to identify Classic members who would benefit from membership upgrades.'

tools:
  - tool_spec:
      type: 'cortex_analyst_text_to_sql'
      name: 'MemberServiceAnalyst'
      description: 'Analyzes member profiles, service requests, vehicle information, and service fulfillment metrics'
  - tool_spec:
      type: 'cortex_analyst_text_to_sql'
      name: 'FleetOperationsAnalyst'
      description: 'Analyzes fleet operations, technician performance, truck utilization, and regional coverage'
  - tool_spec:
      type: 'cortex_analyst_text_to_sql'
      name: 'PredictiveAnalyticsAnalyst'
      description: 'Analyzes risk scores, early warning alerts, weather impacts, and predictive insights'
  - tool_spec:
      type: 'cortex_search'
      name: 'ServiceNotesSearch'
      description: 'Searches 500,000+ technician service notes for repair details, common issues, and service procedures'
  - tool_spec:
      type: 'cortex_search'
      name: 'MemberFeedbackSearch'
      description: 'Searches 100,000+ member feedback entries for satisfaction insights and service quality issues'
  - tool_spec:
      type: 'cortex_search'
      name: 'IncidentReportsSearch'
      description: 'Searches 50,000+ incident reports for safety issues, vehicle problems, and operational challenges'
  - tool_spec:
      type: 'generic'
      name: 'PredictServiceVolume'
      description: 'Predicts future service request volume for capacity planning'
      input_schema:
        type: 'object'
        properties:
          months_ahead:
            type: 'integer'
            description: 'Number of months to forecast (1-12)'
        required: ['months_ahead']
  - tool_spec:
      type: 'generic'
      name: 'PredictMemberChurn'
      description: 'Predicts member churn risk for retention initiatives'
      input_schema:
        type: 'object'
        properties:
          membership_level:
            type: 'string'
            description: 'Filter by membership level (CLASSIC, PLUS, PREMIER) or leave empty for all'
        required: []
  - tool_spec:
      type: 'generic'
      name: 'PredictResponseSuccess'
      description: 'Predicts service response success probability'
      input_schema:
        type: 'object'
        properties:
          service_type:
            type: 'string'
            description: 'Filter by service type (TOWING, TIRE_CHANGE, BATTERY_JUMP, etc.) or leave empty for all'
        required: []

tool_resources:
  MemberServiceAnalyst:
    semantic_view: 'AAA_INTELLIGENCE.ANALYTICS.SV_MEMBER_SERVICE_INTELLIGENCE'
    execution_environment:
      type: 'warehouse'
      warehouse: 'AAA_WH'
      query_timeout: 60
  FleetOperationsAnalyst:
    semantic_view: 'AAA_INTELLIGENCE.ANALYTICS.SV_FLEET_OPERATIONS_INTELLIGENCE'
    execution_environment:
      type: 'warehouse'
      warehouse: 'AAA_WH'
      query_timeout: 60
  PredictiveAnalyticsAnalyst:
    semantic_view: 'AAA_INTELLIGENCE.ANALYTICS.SV_PREDICTIVE_ANALYTICS_INTELLIGENCE'
    execution_environment:
      type: 'warehouse'
      warehouse: 'AAA_WH'
      query_timeout: 60
  ServiceNotesSearch:
    search_service: 'AAA_INTELLIGENCE.RAW.SERVICE_NOTES_SEARCH'
    max_results: 10
    title_column: 'service_id'
    id_column: 'note_id'
  MemberFeedbackSearch:
    search_service: 'AAA_INTELLIGENCE.RAW.MEMBER_FEEDBACK_SEARCH'
    max_results: 10
    title_column: 'member_name'
    id_column: 'feedback_id'
  IncidentReportsSearch:
    search_service: 'AAA_INTELLIGENCE.RAW.INCIDENT_REPORTS_SEARCH'
    max_results: 10
    title_column: 'incident_type'
    id_column: 'incident_id'
  PredictServiceVolume:
    type: 'procedure'
    identifier: 'AAA_INTELLIGENCE.ANALYTICS.PREDICT_SERVICE_VOLUME'
    execution_environment:
      type: 'warehouse'
      warehouse: 'AAA_WH'
      query_timeout: 60
  PredictMemberChurn:
    type: 'procedure'
    identifier: 'AAA_INTELLIGENCE.ANALYTICS.PREDICT_MEMBER_CHURN'
    execution_environment:
      type: 'warehouse'
      warehouse: 'AAA_WH'
      query_timeout: 60
  PredictResponseSuccess:
    type: 'procedure'
    identifier: 'AAA_INTELLIGENCE.ANALYTICS.PREDICT_RESPONSE_SUCCESS'
    execution_environment:
      type: 'warehouse'
      warehouse: 'AAA_WH'
      query_timeout: 60
  $$;

-- ============================================================================
-- Step 3: Verify Agent Creation
-- ============================================================================

-- Show created agent
SHOW AGENTS LIKE 'AAA_INTELLIGENCE_AGENT';

-- Describe agent configuration
DESCRIBE AGENT AAA_INTELLIGENCE_AGENT;

-- Grant usage
GRANT USAGE ON AGENT AAA_INTELLIGENCE_AGENT TO ROLE SYSADMIN;

-- ============================================================================
-- Step 4: Test Agent (Examples)
-- ============================================================================

-- Note: After agent creation, you can test it in Snowsight:
-- 1. Go to AI & ML > Agents
-- 2. Select AAA_INTELLIGENCE_AGENT
-- 3. Click "Chat" to interact with the agent

-- Example test queries:
/*
1. Simple queries:
   - "How many active members do we have?"
   - "What is our average response time?"
   - "Show me all membership levels available."
   - "How many service trucks are currently available?"
   - "What is the average member satisfaction score?"

2. Complex queries:
   - "Analyze service request patterns by type and priority"
   - "Show fleet utilization and technician performance metrics"
   - "Analyze member risk profiles and early warning alerts"
   - "What's the correlation between weather and service demand?"
   - "Analyze membership value and retention patterns"

3. Unstructured queries (Cortex Search):
   - "Search service notes for battery replacement procedures"
   - "Find member feedback about long wait times"
   - "Search incident reports for towing accidents"

4. Predictive queries (ML Models):
   - "Predict service volume for the next 6 months"
   - "Which Premier members are likely to cancel?"
   - "What's the success rate prediction for towing in bad weather?"
   - "Forecast battery jump demand for winter"
   - "Which Classic members should upgrade to Plus?"
*/

-- ============================================================================
-- Step 5: Grant Agent Usage to Other Roles (Already done in Step 3)
-- ============================================================================

-- To grant to additional roles:
-- GRANT USAGE ON AGENT AAA_INTELLIGENCE_AGENT TO ROLE <role_name>;

-- ============================================================================
-- Success Message
-- ============================================================================

SELECT 'ACE Intelligence Agent created successfully! Access it in Snowsight under AI & ML > Agents' AS status;

-- ============================================================================
-- TROUBLESHOOTING
-- ============================================================================

/*
If agent creation fails, verify:

1. Permissions are granted:
   - CORTEX_ANALYST_USER database role
   - REFERENCES and SELECT on all semantic views
   - USAGE on Cortex Search services
   - USAGE on ML procedures (if using)

2. All semantic views exist:
   SHOW SEMANTIC VIEWS IN SCHEMA AAA_INTELLIGENCE.ANALYTICS;

3. All Cortex Search services exist and are ready:
   SHOW CORTEX SEARCH SERVICES IN SCHEMA AAA_INTELLIGENCE.RAW;

4. ML wrapper procedures exist (optional):
   SHOW PROCEDURES IN SCHEMA AAA_INTELLIGENCE.ANALYTICS;

5. Warehouse is running:
   SHOW WAREHOUSES LIKE 'AAA_WH';
*/

-- ============================================================================
-- NOTES
-- ============================================================================

/*
IMPORTANT NOTES:

1. ML Model Tools (OPTIONAL):
   - The agent includes references to ML model procedures
   - If you haven't created the ML models (notebook + wrapper procedures),
     you can either:
     a) Comment out the ML function tools in the agent JSON above
     b) Or create them by running the notebook and wrapper SQL

2. Role Customization:
   - This script grants permissions to SYSADMIN role
   - Adjust role names throughout to match your organization's role structure

3. Agent Model:
   - Using MODEL = AUTO for optimal performance
   - The agent will automatically select the best model for each query

4. Multi-Turn Conversations:
   - The agent maintains context across multiple questions in a chat session
   - You can ask follow-up questions that reference previous responses

5. Performance:
   - First query may take 10-20 seconds as semantic models initialize
   - Subsequent queries are typically faster (2-5 seconds)
   - Cortex Search queries are usually sub-second after index warm-up
*/
