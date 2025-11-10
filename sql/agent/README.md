# ACE Intelligence Agent Configuration

This directory contains the SQL script to create and configure the ACE Intelligence Agent.

## File

### 08_create_intelligence_agent.sql
Creates the Snowflake Intelligence Agent with:
- **3 Cortex Analyst Tools**: For querying semantic views (structured data)
- **3 Cortex Search Tools**: For searching unstructured text data
- **3 ML Model Tools**: For making predictions

## Agent Configuration

### Model Setting
- **Model**: AUTO (automatically selects the best model for each query)

### Question Categories

#### Simple Questions (5)
1. How many active members do we have?
2. What is our average response time?
3. Show me all membership levels available.
4. How many service trucks are currently available?
5. What is the average member satisfaction score?

#### Complex Questions (5)
1. Analyze service request patterns by type and priority
2. Show fleet utilization and technician performance metrics
3. Analyze member risk profiles and early warning alerts
4. What's the correlation between weather and service demand?
5. Analyze membership value and retention patterns

#### ML Model Questions (5)
1. Predict service volume for the next 6 months
2. Which Premier members are likely to cancel?
3. What's the success rate prediction for towing in bad weather?
4. Forecast battery jump demand for winter
5. Which Classic members should upgrade to Plus?

## Prerequisites

Before running the agent creation script:
1. Complete all setup steps (01-07)
2. Ensure all semantic views are created
3. Ensure all Cortex Search services are ready
4. (Optional) Run ML notebook and create wrapper procedures

## Usage

1. Execute `08_create_intelligence_agent.sql` in Snowsight
2. Navigate to AI & ML → Agents
3. Select AAA_INTELLIGENCE_AGENT
4. Click "Chat" to start interacting

## Permissions

The script grants necessary permissions to SYSADMIN role. Adjust if using different roles in your organization.
