-- ============================================================================
-- AAA Intelligence Agent - Analytical Views
-- ============================================================================
-- Purpose: Create curated analytical views for business intelligence
-- ============================================================================

USE DATABASE AAA_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE AAA_WH;

-- ============================================================================
-- Member 360 View
-- ============================================================================
CREATE OR REPLACE VIEW V_MEMBER_360 AS
SELECT
    m.member_id,
    m.member_number,
    m.member_name,
    m.email,
    m.phone,
    m.city,
    m.state,
    m.zip_code,
    m.membership_level,
    m.membership_start_date,
    m.membership_renewal_date,
    DATEDIFF('day', CURRENT_DATE(), m.membership_renewal_date) AS days_until_renewal,
    m.membership_status,
    m.lifetime_value,
    m.risk_score,
    m.is_auto_renew,
    m.preferred_contact_method,
    COUNT(DISTINCT v.vehicle_id) AS total_vehicles,
    COUNT(DISTINCT sr.service_id) AS total_service_requests,
    COUNT(DISTINCT CASE WHEN sr.request_timestamp >= DATEADD('year', -1, CURRENT_DATE()) THEN sr.service_id END) AS services_last_12_months,
    COUNT(DISTINCT CASE WHEN sr.request_timestamp >= DATEADD('day', -30, CURRENT_DATE()) THEN sr.service_id END) AS services_last_30_days,
    MAX(sr.request_timestamp) AS last_service_date,
    AVG(sf.member_satisfaction_score) AS avg_satisfaction_score,
    MAX(ps.breakdown_risk_score) AS current_breakdown_risk,
    MAX(ps.churn_risk_score) AS current_churn_risk,
    MAX(ps.lifetime_value_prediction) AS predicted_ltv,
    m.created_at,
    m.updated_at
FROM RAW.MEMBERS m
LEFT JOIN RAW.VEHICLES v ON m.member_id = v.member_id
LEFT JOIN RAW.SERVICE_REQUESTS sr ON m.member_id = sr.member_id
LEFT JOIN RAW.SERVICE_FULFILLMENT sf ON sr.service_id = sf.service_id
LEFT JOIN RAW.PREDICTIVE_SCORES ps ON m.member_id = ps.member_id 
    AND ps.score_date = (SELECT MAX(score_date) FROM RAW.PREDICTIVE_SCORES WHERE member_id = m.member_id)
GROUP BY
    m.member_id, m.member_number, m.member_name, m.email, m.phone, m.city, m.state, m.zip_code,
    m.membership_level, m.membership_start_date, m.membership_renewal_date, m.membership_status,
    m.lifetime_value, m.risk_score, m.is_auto_renew, m.preferred_contact_method,
    ps.breakdown_risk_score, ps.churn_risk_score, ps.lifetime_value_prediction,
    m.created_at, m.updated_at;

-- ============================================================================
-- Service Performance View
-- ============================================================================
CREATE OR REPLACE VIEW V_SERVICE_PERFORMANCE AS
SELECT
    sr.service_id,
    sr.member_id,
    m.member_name,
    m.membership_level,
    sr.request_number,
    sr.request_timestamp,
    DATE_TRUNC('MONTH', sr.request_timestamp) AS service_month,
    DATE_TRUNC('QUARTER', sr.request_timestamp) AS service_quarter,
    DATE_TRUNC('YEAR', sr.request_timestamp) AS service_year,
    DAYOFWEEK(sr.request_timestamp) AS day_of_week,
    HOUR(sr.request_timestamp) AS hour_of_day,
    sr.service_type,
    sr.service_category,
    sr.priority,
    sr.location_type,
    sr.weather_condition,
    sr.temperature_f,
    sr.channel,
    sf.technician_id,
    t.technician_name,
    t.certification_level,
    sf.truck_id,
    tr.truck_type,
    sf.dispatch_timestamp,
    sf.arrival_timestamp,
    sf.completion_timestamp,
    sf.response_time_minutes,
    sf.service_duration_minutes,
    sf.distance_to_member_miles,
    sf.service_outcome,
    sf.service_cost,
    sf.member_satisfaction_score,
    CASE
        WHEN sf.response_time_minutes <= 30 THEN 'EXCELLENT'
        WHEN sf.response_time_minutes <= 45 THEN 'GOOD'
        WHEN sf.response_time_minutes <= 60 THEN 'FAIR'
        ELSE 'POOR'
    END AS response_time_rating,
    CASE
        WHEN sf.response_time_minutes <= reg.target_response_time_minutes THEN TRUE
        ELSE FALSE
    END AS met_sla,
    sr.created_at
FROM RAW.SERVICE_REQUESTS sr
JOIN RAW.SERVICE_FULFILLMENT sf ON sr.service_id = sf.service_id
JOIN RAW.MEMBERS m ON sr.member_id = m.member_id
LEFT JOIN RAW.SERVICE_TECHNICIANS t ON sf.technician_id = t.technician_id
LEFT JOIN RAW.SERVICE_TRUCKS tr ON sf.truck_id = tr.truck_id
LEFT JOIN RAW.SERVICE_REGIONS reg ON t.service_region = reg.region_name;

-- ============================================================================
-- Fleet Analytics View
-- ============================================================================
CREATE OR REPLACE VIEW V_FLEET_ANALYTICS AS
SELECT
    tr.truck_id,
    tr.truck_number,
    tr.truck_type,
    tr.service_region,
    tr.truck_status,
    tr.current_latitude,
    tr.current_longitude,
    tr.last_location_update,
    tr.mileage,
    tr.last_maintenance_date,
    tr.next_maintenance_date,
    DATEDIFF('day', CURRENT_DATE(), tr.next_maintenance_date) AS days_until_maintenance,
    tr.fuel_level_percent,
    COUNT(DISTINCT sf.service_id) AS total_services_completed,
    COUNT(DISTINCT CASE WHEN sf.completion_timestamp >= DATEADD('day', -30, CURRENT_DATE()) THEN sf.service_id END) AS services_last_30_days,
    COUNT(DISTINCT CASE WHEN sf.completion_timestamp >= DATEADD('day', -7, CURRENT_DATE()) THEN sf.service_id END) AS services_last_7_days,
    AVG(sf.response_time_minutes) AS avg_response_time,
    AVG(sf.distance_to_member_miles) AS avg_distance_to_service,
    SUM(sf.towing_distance_miles) AS total_towing_miles,
    COUNT(DISTINCT DATE(sf.completion_timestamp)) AS days_active,
    tr.created_at,
    tr.updated_at
FROM RAW.SERVICE_TRUCKS tr
LEFT JOIN RAW.SERVICE_FULFILLMENT sf ON tr.truck_id = sf.truck_id
GROUP BY
    tr.truck_id, tr.truck_number, tr.truck_type, tr.service_region, tr.truck_status,
    tr.current_latitude, tr.current_longitude, tr.last_location_update, tr.mileage,
    tr.last_maintenance_date, tr.next_maintenance_date, tr.fuel_level_percent,
    tr.created_at, tr.updated_at;

-- ============================================================================
-- Demand Patterns View
-- ============================================================================
CREATE OR REPLACE VIEW V_DEMAND_PATTERNS AS
WITH hourly_demand AS (
    SELECT
        DATE(sr.request_timestamp) AS service_date,
        HOUR(sr.request_timestamp) AS service_hour,
        t.service_region,
        sr.service_type,
        sr.weather_condition,
        COUNT(DISTINCT sr.service_id) AS service_count,
        AVG(sf.response_time_minutes) AS avg_response_time,
        COUNT(DISTINCT CASE WHEN sf.response_time_minutes <= reg.target_response_time_minutes THEN sr.service_id END) AS services_met_sla
    FROM RAW.SERVICE_REQUESTS sr
    JOIN RAW.SERVICE_FULFILLMENT sf ON sr.service_id = sf.service_id
    JOIN RAW.SERVICE_TECHNICIANS t ON sf.technician_id = t.technician_id
    JOIN RAW.SERVICE_REGIONS reg ON t.service_region = reg.region_name
    GROUP BY 1, 2, 3, 4, 5
)
SELECT
    service_date,
    service_hour,
    service_region,
    service_type,
    weather_condition,
    service_count,
    avg_response_time,
    services_met_sla,
    service_count - AVG(service_count) OVER (
        PARTITION BY service_region, service_type, service_hour 
        ORDER BY service_date 
        ROWS BETWEEN 30 PRECEDING AND 1 PRECEDING
    ) AS demand_vs_30day_avg,
    (services_met_sla::FLOAT / NULLIF(service_count, 0) * 100) AS sla_compliance_rate
FROM hourly_demand;

-- ============================================================================
-- Regional Performance View
-- ============================================================================
CREATE OR REPLACE VIEW V_REGIONAL_PERFORMANCE AS
SELECT
    r.region_id,
    r.region_name,
    r.region_code,
    r.state,
    r.coverage_area_sqmi,
    r.population_covered,
    r.active_technicians,
    r.active_trucks,
    r.target_response_time_minutes,
    COUNT(DISTINCT sr.service_id) AS total_services,
    COUNT(DISTINCT CASE WHEN sr.request_timestamp >= DATEADD('day', -30, CURRENT_DATE()) THEN sr.service_id END) AS services_last_30_days,
    COUNT(DISTINCT CASE WHEN sr.request_timestamp >= DATEADD('day', -7, CURRENT_DATE()) THEN sr.service_id END) AS services_last_7_days,
    AVG(sf.response_time_minutes) AS avg_response_time,
    PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY sf.response_time_minutes) AS p90_response_time,
    COUNT(DISTINCT CASE WHEN sf.response_time_minutes <= r.target_response_time_minutes THEN sr.service_id END)::FLOAT / 
        NULLIF(COUNT(DISTINCT sr.service_id), 0) * 100 AS sla_compliance_rate,
    AVG(sf.member_satisfaction_score) AS avg_satisfaction_score,
    COUNT(DISTINCT m.member_id) AS unique_members_served,
    COUNT(DISTINCT t.technician_id) AS active_technicians_actual,
    COUNT(DISTINCT tr.truck_id) AS active_trucks_actual,
    r.created_at,
    r.updated_at
FROM RAW.SERVICE_REGIONS r
LEFT JOIN RAW.SERVICE_TECHNICIANS t ON r.region_name = t.service_region
LEFT JOIN RAW.SERVICE_FULFILLMENT sf ON t.technician_id = sf.technician_id
LEFT JOIN RAW.SERVICE_REQUESTS sr ON sf.service_id = sr.service_id
LEFT JOIN RAW.MEMBERS m ON sr.member_id = m.member_id
LEFT JOIN RAW.SERVICE_TRUCKS tr ON r.region_name = tr.service_region
GROUP BY
    r.region_id, r.region_name, r.region_code, r.state, r.coverage_area_sqmi,
    r.population_covered, r.active_technicians, r.active_trucks,
    r.target_response_time_minutes, r.created_at, r.updated_at;

-- ============================================================================
-- Predictive Insights View
-- ============================================================================
CREATE OR REPLACE VIEW V_PREDICTIVE_INSIGHTS AS
SELECT
    ps.score_id,
    ps.member_id,
    m.member_name,
    m.membership_level,
    m.membership_status,
    ps.score_date,
    ps.breakdown_risk_score,
    CASE
        WHEN ps.breakdown_risk_score >= 80 THEN 'VERY_HIGH'
        WHEN ps.breakdown_risk_score >= 60 THEN 'HIGH'
        WHEN ps.breakdown_risk_score >= 40 THEN 'MEDIUM'
        WHEN ps.breakdown_risk_score >= 20 THEN 'LOW'
        ELSE 'VERY_LOW'
    END AS breakdown_risk_category,
    ps.churn_risk_score,
    CASE
        WHEN ps.churn_risk_score >= 80 THEN 'VERY_HIGH'
        WHEN ps.churn_risk_score >= 60 THEN 'HIGH'
        WHEN ps.churn_risk_score >= 40 THEN 'MEDIUM'
        WHEN ps.churn_risk_score >= 20 THEN 'LOW'
        ELSE 'VERY_LOW'
    END AS churn_risk_category,
    ps.lifetime_value_prediction,
    ps.next_service_prediction_days,
    ps.recommended_outreach,
    ps.model_version,
    v.make,
    v.model,
    v.year,
    v.mileage,
    YEAR(CURRENT_DATE()) - v.year AS vehicle_age_years,
    m.days_until_renewal,
    m.is_auto_renew,
    ps.created_at
FROM RAW.PREDICTIVE_SCORES ps
JOIN (
    SELECT 
        ps2.member_id,
        MAX(ps2.score_date) AS max_score_date
    FROM RAW.PREDICTIVE_SCORES ps2
    GROUP BY ps2.member_id
) latest ON ps.member_id = latest.member_id AND ps.score_date = latest.max_score_date
JOIN V_MEMBER_360 m ON ps.member_id = m.member_id
LEFT JOIN RAW.VEHICLES v ON m.member_id = v.member_id AND v.is_primary_vehicle = TRUE;

-- ============================================================================
-- Alert Dashboard View
-- ============================================================================
CREATE OR REPLACE VIEW V_ALERT_DASHBOARD AS
SELECT
    a.alert_id,
    a.alert_type,
    a.alert_severity,
    a.region_id,
    r.region_name,
    a.alert_title,
    a.alert_message,
    a.affected_services,
    a.metric_value,
    a.threshold_value,
    a.alert_timestamp,
    DATEDIFF('minute', a.alert_timestamp, CURRENT_TIMESTAMP()) AS alert_age_minutes,
    a.acknowledged_by,
    a.acknowledged_timestamp,
    DATEDIFF('minute', a.alert_timestamp, a.acknowledged_timestamp) AS time_to_acknowledge_minutes,
    a.resolved_timestamp,
    DATEDIFF('minute', a.alert_timestamp, a.resolved_timestamp) AS time_to_resolve_minutes,
    CASE
        WHEN a.resolved_timestamp IS NOT NULL THEN 'RESOLVED'
        WHEN a.acknowledged_timestamp IS NOT NULL THEN 'ACKNOWLEDGED'
        ELSE 'ACTIVE'
    END AS alert_status,
    a.created_at
FROM RAW.EARLY_WARNING_ALERTS a
LEFT JOIN RAW.SERVICE_REGIONS r ON a.region_id = r.region_id
WHERE a.alert_timestamp >= DATEADD('day', -7, CURRENT_DATE());

-- ============================================================================
-- Revenue Impact View
-- ============================================================================
CREATE OR REPLACE VIEW V_REVENUE_IMPACT AS
SELECT
    t.transaction_id,
    t.member_id,
    m.member_name,
    m.membership_level,
    t.transaction_date,
    DATE_TRUNC('MONTH', t.transaction_date) AS transaction_month,
    DATE_TRUNC('QUARTER', t.transaction_date) AS transaction_quarter,
    DATE_TRUNC('YEAR', t.transaction_date) AS transaction_year,
    t.transaction_type,
    t.product_type,
    t.amount,
    t.payment_method,
    t.payment_status,
    t.renewal_flag,
    -- Calculate service-related costs
    COALESCE(service_costs.total_service_cost, 0) AS service_costs_ytd,
    t.amount - COALESCE(service_costs.total_service_cost, 0) AS net_revenue_contribution,
    -- Member engagement metrics
    COALESCE(service_activity.services_ytd, 0) AS services_used_ytd,
    CASE 
        WHEN t.renewal_flag = TRUE AND t.payment_status = 'COMPLETED' THEN 'RENEWED'
        WHEN t.renewal_flag = TRUE AND t.payment_status = 'FAILED' THEN 'RENEWAL_FAILED'
        ELSE 'OTHER'
    END AS renewal_outcome,
    t.created_at
FROM RAW.MEMBER_TRANSACTIONS t
JOIN RAW.MEMBERS m ON t.member_id = m.member_id
LEFT JOIN (
    SELECT 
        sr.member_id,
        SUM(sf.service_cost) AS total_service_cost
    FROM RAW.SERVICE_REQUESTS sr
    JOIN RAW.SERVICE_FULFILLMENT sf ON sr.service_id = sf.service_id
    WHERE sr.request_timestamp >= DATE_TRUNC('year', CURRENT_DATE())
    GROUP BY sr.member_id
) service_costs ON t.member_id = service_costs.member_id
LEFT JOIN (
    SELECT 
        member_id,
        COUNT(DISTINCT service_id) AS services_ytd
    FROM RAW.SERVICE_REQUESTS
    WHERE request_timestamp >= DATE_TRUNC('year', CURRENT_DATE())
    GROUP BY member_id
) service_activity ON t.member_id = service_activity.member_id;

-- ============================================================================
-- Display confirmation
-- ============================================================================
SELECT 'All analytical views created successfully' AS status;

SELECT 
    table_name AS view_name,
    comment AS description
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'ANALYTICS'
  AND table_name LIKE 'V_%'
ORDER BY table_name;
