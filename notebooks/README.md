# AAA ML Models Notebook

This directory contains the Jupyter notebook for training machine learning models that power the AAA Intelligence Agent's predictive capabilities.

## Models

The notebook trains and registers three ML models:

### 1. Service Request Volume Forecasting
- **Model**: `SERVICE_VOLUME_PREDICTOR`
- **Type**: Linear Regression
- **Purpose**: Predicts future monthly service request volume based on historical patterns, seasonality, and weather conditions
- **Features**: Month, unique members/vehicles, service type mix, weather conditions
- **Output**: Predicted number of service requests for future months

### 2. Member Churn Prediction
- **Model**: `MEMBER_CHURN_PREDICTOR`
- **Type**: Random Forest Classifier
- **Purpose**: Identifies members at risk of non-renewal or cancellation
- **Features**: Service usage patterns, satisfaction scores, membership tenure, transaction history
- **Output**: Binary classification (likely to churn: yes/no)

### 3. Roadside Response Success Prediction
- **Model**: `RESPONSE_SUCCESS_PREDICTOR`
- **Type**: Logistic Regression
- **Purpose**: Predicts likelihood of completing service requests within SLA with high satisfaction
- **Features**: Service type, location, weather, time of day, technician skills, regional resources
- **Output**: Probability of successful service completion

## Requirements

- Snowflake account with ML capabilities enabled
- Access to AAA_INTELLIGENCE database
- Snowpark ML packages (installed automatically in Snowflake notebooks)

## Usage

1. Open the notebook in Snowsight (Projects → Notebooks)
2. Run all cells sequentially
3. Models will be registered to the Model Registry
4. Use the wrapper functions in `sql/ml/07_create_model_wrapper_functions.sql` to call these models from the agent

## Integration with Intelligence Agent

After running this notebook:
1. Execute `sql/ml/07_create_model_wrapper_functions.sql` to create callable procedures
2. Execute `sql/agent/08_create_intelligence_agent.sql` to create the agent with ML tools
3. The agent will be able to answer predictive questions like:
   - "Predict service volume for next quarter"
   - "Which members are likely to cancel?"
   - "What's the success probability for emergency towing in bad weather?"
