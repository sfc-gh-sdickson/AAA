-- ============================================================================
-- ACE Intelligence Agent - Model Registry Wrapper Functions
-- ============================================================================
-- Purpose: Create SQL procedures that wrap Model Registry models
--          so they can be added as tools to the Intelligence Agent
-- Based on: Model Registry integration pattern
-- ============================================================================

USE DATABASE AAA_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE AAA_WH;

-- ============================================================================
-- Procedure 1: Service Request Volume Forecast Wrapper
-- ============================================================================

-- Drop if exists (in case it was created as FUNCTION before)
DROP FUNCTION IF EXISTS PREDICT_SERVICE_VOLUME(INT);

CREATE OR REPLACE PROCEDURE PREDICT_SERVICE_VOLUME(
    MONTHS_AHEAD INT
)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-ml-python', 'scikit-learn')
HANDLER = 'predict_service_volume'
COMMENT = 'Calls SERVICE_VOLUME_PREDICTOR model from Model Registry to forecast service request volume'
AS
$$
def predict_service_volume(session, months_ahead):
    from snowflake.ml.registry import Registry
    import json
    
    # Get model from registry
    reg = Registry(session)
    model = reg.get_model("SERVICE_VOLUME_PREDICTOR").default
    
    # Get recent service data for prediction
    recent_data_query = f"""
    SELECT
        MONTH(DATEADD('month', {months_ahead}, CURRENT_DATE())) AS month_num,
        YEAR(DATEADD('month', {months_ahead}, CURRENT_DATE())) AS year_num,
        AVG(unique_members)::FLOAT AS unique_members,
        AVG(unique_vehicles)::FLOAT AS unique_vehicles,
        AVG(high_priority_ratio)::FLOAT AS high_priority_ratio,
        AVG(towing_count)::FLOAT AS towing_count,
        AVG(tire_count)::FLOAT AS tire_count,
        AVG(battery_count)::FLOAT AS battery_count,
        AVG(bad_weather_ratio)::FLOAT AS bad_weather_ratio
    FROM (
        SELECT
            COUNT(DISTINCT member_id)::FLOAT AS unique_members,
            COUNT(DISTINCT vehicle_id)::FLOAT AS unique_vehicles,
            AVG(CASE WHEN priority = 'HIGH' THEN 1.0 ELSE 0.0 END)::FLOAT AS high_priority_ratio,
            COUNT(DISTINCT CASE WHEN service_type = 'TOWING' THEN service_id END)::FLOAT AS towing_count,
            COUNT(DISTINCT CASE WHEN service_type = 'TIRE_CHANGE' THEN service_id END)::FLOAT AS tire_count,
            COUNT(DISTINCT CASE WHEN service_type = 'BATTERY_JUMP' THEN service_id END)::FLOAT AS battery_count,
            AVG(CASE WHEN weather_condition IN ('RAIN', 'SNOW', 'ICE') THEN 1.0 ELSE 0.0 END)::FLOAT AS bad_weather_ratio
        FROM RAW.SERVICE_REQUESTS
        WHERE request_timestamp >= DATEADD('month', -6, CURRENT_DATE())
        GROUP BY DATE_TRUNC('month', request_timestamp)
    )
    """
    
    input_df = session.sql(recent_data_query)
    
    # Get predictions
    predictions = model.run(input_df, function_name="predict")
    
    # Convert to pandas and format as JSON string
    result = predictions.select("PREDICTED_SERVICE_REQUESTS").to_pandas()
    
    return json.dumps({
        "months_ahead": months_ahead,
        "predicted_service_requests": int(result['PREDICTED_SERVICE_REQUESTS'].iloc[0])
    })
$$;

-- ============================================================================
-- Procedure 2: Member Churn Prediction Wrapper
-- ============================================================================

-- Drop if exists (in case it was created as FUNCTION before)
DROP FUNCTION IF EXISTS PREDICT_MEMBER_CHURN(STRING);

CREATE OR REPLACE PROCEDURE PREDICT_MEMBER_CHURN(
    MEMBERSHIP_LEVEL_FILTER STRING
)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-ml-python', 'scikit-learn')
HANDLER = 'predict_churn'
COMMENT = 'Calls MEMBER_CHURN_PREDICTOR model from Model Registry to identify at-risk members'
AS
$$
def predict_churn(session, membership_level_filter):
    from snowflake.ml.registry import Registry
    import json
    
    # Get model
    reg = Registry(session)
    model = reg.get_model("MEMBER_CHURN_PREDICTOR").default
    
    # Build query with optional filter
    level_filter = f"AND m.membership_level = '{membership_level_filter}'" if membership_level_filter else ""
    
    query = f"""
    SELECT
        m.membership_level,
        m.risk_score::FLOAT AS risk_score,
        m.lifetime_value::FLOAT AS lifetime_value,
        DATEDIFF('day', m.membership_start_date, CURRENT_DATE())::FLOAT AS membership_days,
        DATEDIFF('day', CURRENT_DATE(), m.membership_renewal_date)::FLOAT AS days_to_renewal,
        m.is_auto_renew::BOOLEAN AS is_auto_renew,
        COUNT(DISTINCT sr.service_id)::FLOAT AS service_requests_6m,
        COUNT(DISTINCT CASE WHEN sr.service_type = 'TOWING' THEN sr.service_id END)::FLOAT AS towing_requests_6m,
        AVG(sf.response_time_minutes)::FLOAT AS avg_response_time,
        AVG(sf.member_satisfaction_score)::FLOAT AS avg_satisfaction_score,
        COUNT(DISTINCT CASE WHEN sf.member_satisfaction_score <= 2 THEN sf.service_id END)::FLOAT AS low_satisfaction_count,
        COUNT(DISTINCT mt.transaction_id)::FLOAT AS total_transactions,
        SUM(CASE WHEN mt.transaction_type = 'RENEWAL' THEN 1 ELSE 0 END)::FLOAT AS renewal_count,
        AVG(ps.churn_risk_score)::FLOAT AS avg_churn_risk_score,
        FALSE::BOOLEAN AS is_churned
    FROM RAW.MEMBERS m
    LEFT JOIN RAW.SERVICE_REQUESTS sr ON m.member_id = sr.member_id 
        AND sr.request_timestamp >= DATEADD('month', -6, CURRENT_DATE())
    LEFT JOIN RAW.SERVICE_FULFILLMENT sf ON sr.service_id = sf.service_id
    LEFT JOIN RAW.MEMBER_TRANSACTIONS mt ON m.member_id = mt.member_id
    LEFT JOIN RAW.PREDICTIVE_SCORES ps ON m.member_id = ps.member_id
    WHERE m.membership_status = 'ACTIVE' {level_filter}
    GROUP BY m.member_id, m.membership_level, m.risk_score, m.lifetime_value, 
             m.membership_start_date, m.membership_renewal_date, m.is_auto_renew
    LIMIT 100
    """
    
    input_df = session.sql(query)
    
    # Get predictions
    predictions = model.run(input_df, function_name="predict")
    
    # Count high-risk members (assuming 1 = churned)
    result = predictions.select("CHURN_PREDICTION").to_pandas()
    churn_count = int(result['CHURN_PREDICTION'].sum())
    total_count = len(result)
    
    return json.dumps({
        "membership_level_filter": membership_level_filter or "ALL",
        "total_members_analyzed": total_count,
        "predicted_to_churn": churn_count,
        "churn_rate_pct": round(churn_count / total_count * 100, 2) if total_count > 0 else 0
    })
$$;

-- ============================================================================
-- Procedure 3: Roadside Response Success Prediction Wrapper
-- ============================================================================

-- Drop if exists (in case it was created as FUNCTION before)
DROP FUNCTION IF EXISTS PREDICT_RESPONSE_SUCCESS(STRING);

CREATE OR REPLACE PROCEDURE PREDICT_RESPONSE_SUCCESS(
    SERVICE_TYPE_FILTER STRING
)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-ml-python', 'scikit-learn')
HANDLER = 'predict_success'
COMMENT = 'Calls RESPONSE_SUCCESS_PREDICTOR model to predict service completion success probability'
AS
$$
def predict_success(session, service_type_filter):
    from snowflake.ml.registry import Registry
    import json
    
    # Get model
    reg = Registry(session)
    model = reg.get_model("RESPONSE_SUCCESS_PREDICTOR").default
    
    # Build query
    type_filter = f"AND sr.service_type = '{service_type_filter}'" if service_type_filter else ""
    
    query = f"""
    SELECT
        sr.service_type,
        sr.service_category,
        sr.priority,
        sr.location_type,
        sr.weather_condition,
        sr.temperature_f::FLOAT AS temperature_f,
        sr.channel,
        HOUR(sr.request_timestamp)::INT AS request_hour,
        DAYOFWEEK(sr.request_timestamp)::INT AS request_dow,
        reg.average_response_time_minutes::FLOAT AS region_avg_response,
        reg.active_technicians::FLOAT AS region_technicians,
        reg.active_trucks::FLOAT AS region_trucks,
        m.membership_level,
        v.vehicle_type,
        t.certification_level,
        t.average_response_time_minutes::FLOAT AS tech_avg_response,
        TRUE::BOOLEAN AS response_successful
    FROM RAW.SERVICE_REQUESTS sr
    JOIN RAW.SERVICE_FULFILLMENT sf ON sr.service_id = sf.service_id
    JOIN RAW.SERVICE_TECHNICIANS t ON sf.technician_id = t.technician_id
    JOIN RAW.MEMBERS m ON sr.member_id = m.member_id
    LEFT JOIN RAW.VEHICLES v ON sr.vehicle_id = v.vehicle_id
    LEFT JOIN RAW.SERVICE_REGIONS reg ON t.service_region = reg.region_name
    WHERE sr.request_timestamp >= DATEADD('month', -1, CURRENT_DATE()) {type_filter}
    LIMIT 50
    """
    
    input_df = session.sql(query)
    
    # Get predictions
    predictions = model.run(input_df, function_name="predict")
    
    # Calculate success rate
    result = predictions.select("SUCCESS_PREDICTION").to_pandas()
    likely_successful = int(result['SUCCESS_PREDICTION'].sum())
    total_requests = len(result)
    
    return json.dumps({
        "service_type_filter": service_type_filter or "ALL",
        "total_requests_analyzed": total_requests,
        "predicted_successful": likely_successful,
        "success_rate_pct": round(likely_successful / total_requests * 100, 2) if total_requests > 0 else 0
    })
$$;

-- ============================================================================
-- Display confirmation
-- ============================================================================

SELECT 'ML model wrapper functions created successfully' AS status;

-- ============================================================================
-- Test the wrapper procedures (uncomment after models are registered via notebook)
-- ============================================================================
/*
CALL PREDICT_SERVICE_VOLUME(6);
CALL PREDICT_MEMBER_CHURN('PREMIER');
CALL PREDICT_RESPONSE_SUCCESS('TOWING');
*/

SELECT 'Execute notebook first to register models, then uncomment tests above' AS instruction;
