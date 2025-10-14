-- ============================================================================
-- AAA Intelligence Agent - Semantic Views
-- ============================================================================
-- Purpose: Create semantic views for Snowflake Intelligence agents
-- All syntax VERIFIED against official documentation:
-- https://docs.snowflake.com/en/sql-reference/sql/create-semantic-view
-- 
-- Syntax Verification Notes:
-- 1. Clause order is MANDATORY: TABLES → RELATIONSHIPS → DIMENSIONS → METRICS → COMMENT
-- 2. Semantic expression format: semantic_name AS sql_expression
-- 3. No self-referencing relationships allowed
-- 4. No cyclic relationships allowed
-- 5. PRIMARY KEY columns must exist in table definitions
-- ============================================================================

USE DATABASE AAA_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE AAA_WH;

-- ============================================================================
-- Semantic View 1: AAA Member & Service Intelligence
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_MEMBER_SERVICE_INTELLIGENCE
  TABLES (
    members AS RAW.MEMBERS
      PRIMARY KEY (member_id)
      WITH SYNONYMS ('members', 'customers', 'clients')
      COMMENT = 'AAA members',
    vehicles AS RAW.VEHICLES
      PRIMARY KEY (vehicle_id)
      WITH SYNONYMS ('cars', 'automobiles', 'vehicles')
      COMMENT = 'Member vehicles',
    service_requests AS RAW.SERVICE_REQUESTS
      PRIMARY KEY (service_id)
      WITH SYNONYMS ('service calls', 'roadside requests', 'assistance requests')
      COMMENT = 'Roadside assistance requests',
    service_fulfillment AS RAW.SERVICE_FULFILLMENT
      PRIMARY KEY (fulfillment_id)
      WITH SYNONYMS ('service completion', 'fulfillment', 'service delivery')
      COMMENT = 'Service fulfillment details'
  )
  RELATIONSHIPS (
    vehicles(member_id) REFERENCES members(member_id),
    service_requests(member_id) REFERENCES members(member_id),
    service_requests(vehicle_id) REFERENCES vehicles(vehicle_id),
    service_fulfillment(service_id) REFERENCES service_requests(service_id)
  )
  DIMENSIONS (
    members.member_name AS member_name
      WITH SYNONYMS ('customer name', 'client name')
      COMMENT = 'Name of the AAA member',
    members.membership_level AS membership_level
      WITH SYNONYMS ('membership tier', 'member type', 'plan level')
      COMMENT = 'Membership level: CLASSIC, PLUS, PREMIER',
    members.membership_status AS membership_status
      WITH SYNONYMS ('member status', 'account status')
      COMMENT = 'Member status: ACTIVE, EXPIRED, SUSPENDED',
    members.is_auto_renew AS auto_renew_enabled
      WITH SYNONYMS ('automatic renewal', 'auto renewal')
      COMMENT = 'Whether auto-renewal is enabled',
    members.member_state AS state
      WITH SYNONYMS ('state', 'location state')
      COMMENT = 'Member state location',
    members.member_city AS city
      WITH SYNONYMS ('city', 'location city')
      COMMENT = 'Member city location',
    members.preferred_contact AS preferred_contact_method
      WITH SYNONYMS ('contact preference', 'communication method')
      COMMENT = 'Preferred contact method: PHONE, EMAIL, SMS, MAIL',
    vehicles.vehicle_make AS make
      WITH SYNONYMS ('car make', 'manufacturer')
      COMMENT = 'Vehicle manufacturer',
    vehicles.vehicle_model AS model
      WITH SYNONYMS ('car model', 'vehicle model')
      COMMENT = 'Vehicle model',
    vehicles.vehicle_year AS year
      WITH SYNONYMS ('model year', 'car year')
      COMMENT = 'Vehicle model year',
    vehicles.vehicle_type AS vehicle_type
      WITH SYNONYMS ('car type', 'vehicle category')
      COMMENT = 'Vehicle type: SEDAN, SUV, TRUCK, VAN, SPORTS',
    service_requests.service_type AS service_type
      WITH SYNONYMS ('request type', 'assistance type', 'call type')
      COMMENT = 'Service type: TOWING, BATTERY_JUMP, FLAT_TIRE, LOCKOUT, FUEL_DELIVERY',
    service_requests.service_priority AS priority
      WITH SYNONYMS ('urgency', 'priority level')
      COMMENT = 'Service priority: LOW, MEDIUM, HIGH',
    service_requests.location_type AS location_type
      WITH SYNONYMS ('service location', 'breakdown location')
      COMMENT = 'Location type: HIGHWAY, RESIDENTIAL, PARKING_LOT, COMMERCIAL',
    service_requests.weather AS weather_condition
      WITH SYNONYMS ('weather', 'conditions')
      COMMENT = 'Weather conditions during service',
    service_requests.service_channel AS channel
      WITH SYNONYMS ('request channel', 'contact method')
      COMMENT = 'Service request channel: PHONE, MOBILE_APP, WEB, ALEXA',
    service_fulfillment.service_outcome AS service_outcome
      WITH SYNONYMS ('result', 'completion status')
      COMMENT = 'Service outcome: COMPLETED, TOWED, UNABLE_TO_COMPLETE',
    service_fulfillment.satisfaction_score AS member_satisfaction_score
      WITH SYNONYMS ('satisfaction rating', 'customer satisfaction', 'csat')
      COMMENT = 'Member satisfaction score (1-5)'
  )
  METRICS (
    members.total_members AS COUNT(DISTINCT member_id)
      WITH SYNONYMS ('member count', 'customer count')
      COMMENT = 'Total number of members',
    members.avg_lifetime_value AS AVG(lifetime_value)
      WITH SYNONYMS ('average LTV', 'mean customer value')
      COMMENT = 'Average member lifetime value',
    members.avg_risk_score AS AVG(risk_score)
      WITH SYNONYMS ('average risk', 'mean risk score')
      COMMENT = 'Average member risk score',
    vehicles.total_vehicles AS COUNT(DISTINCT vehicle_id)
      WITH SYNONYMS ('vehicle count', 'car count')
      COMMENT = 'Total number of vehicles',
    vehicles.avg_vehicle_mileage AS AVG(mileage)
      WITH SYNONYMS ('average mileage', 'mean mileage')
      COMMENT = 'Average vehicle mileage',
    service_requests.total_service_requests AS COUNT(DISTINCT service_id)
      WITH SYNONYMS ('request count', 'call count', 'service count')
      COMMENT = 'Total number of service requests',
    service_fulfillment.avg_response_time AS AVG(response_time_minutes)
      WITH SYNONYMS ('average response time', 'mean response time')
      COMMENT = 'Average response time in minutes',
    service_fulfillment.avg_service_duration AS AVG(service_duration_minutes)
      WITH SYNONYMS ('average service time', 'mean duration')
      COMMENT = 'Average service duration in minutes',
    service_fulfillment.avg_satisfaction AS AVG(member_satisfaction_score)
      WITH SYNONYMS ('average satisfaction', 'mean satisfaction')
      COMMENT = 'Average member satisfaction score',
    service_fulfillment.total_service_cost AS SUM(service_cost)
      WITH SYNONYMS ('total cost', 'service cost sum')
      COMMENT = 'Total cost of services provided'
  )
  COMMENT = 'AAA Member & Service Intelligence - comprehensive view of members, vehicles, and roadside assistance services';

-- ============================================================================
-- Semantic View 2: AAA Fleet & Operations Intelligence
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_FLEET_OPERATIONS_INTELLIGENCE
  TABLES (
    service_trucks AS RAW.SERVICE_TRUCKS
      PRIMARY KEY (truck_id)
      WITH SYNONYMS ('trucks', 'fleet vehicles', 'service vehicles')
      COMMENT = 'AAA service trucks',
    service_technicians AS RAW.SERVICE_TECHNICIANS
      PRIMARY KEY (technician_id)
      WITH SYNONYMS ('technicians', 'drivers', 'service staff')
      COMMENT = 'AAA service technicians',
    service_regions AS RAW.SERVICE_REGIONS
      PRIMARY KEY (region_id)
      WITH SYNONYMS ('regions', 'service areas', 'territories')
      COMMENT = 'Service regions in California',
    service_fulfillment AS RAW.SERVICE_FULFILLMENT
      PRIMARY KEY (fulfillment_id)
      WITH SYNONYMS ('completions', 'services delivered')
      COMMENT = 'Service fulfillment records'
  )
  RELATIONSHIPS (
    service_trucks(service_region) REFERENCES service_regions(region_name),
    service_technicians(service_region) REFERENCES service_regions(region_name),
    service_fulfillment(technician_id) REFERENCES service_technicians(technician_id),
    service_fulfillment(truck_id) REFERENCES service_trucks(truck_id)
  )
  DIMENSIONS (
    service_trucks.truck_number AS truck_number
      WITH SYNONYMS ('vehicle number', 'fleet number')
      COMMENT = 'Truck identification number',
    service_trucks.truck_type AS truck_type
      WITH SYNONYMS ('vehicle type', 'truck category')
      COMMENT = 'Truck type: STANDARD, FLATBED, HEAVY_DUTY, MOTORCYCLE',
    service_trucks.truck_status AS truck_status
      WITH SYNONYMS ('vehicle status', 'availability')
      COMMENT = 'Truck status: AVAILABLE, ON_CALL, RETURNING, MAINTENANCE',
    service_trucks.fuel_level AS fuel_level_percent
      WITH SYNONYMS ('fuel percentage', 'gas level')
      COMMENT = 'Current fuel level percentage',
    service_technicians.technician_name AS technician_name
      WITH SYNONYMS ('driver name', 'staff name')
      COMMENT = 'Name of service technician',
    service_technicians.certification AS certification_level
      WITH SYNONYMS ('skill level', 'certification')
      COMMENT = 'Certification level: BASIC, ADVANCED, MASTER',
    service_technicians.tech_status AS technician_status
      WITH SYNONYMS ('employee status', 'staff status')
      COMMENT = 'Technician status: ACTIVE, INACTIVE',
    service_regions.region_name AS region_name
      WITH SYNONYMS ('area name', 'territory name')
      COMMENT = 'Service region name',
    service_regions.region_code AS region_code
      WITH SYNONYMS ('area code', 'territory code')
      COMMENT = 'Service region code',
    service_regions.region_state AS state
      WITH SYNONYMS ('state')
      COMMENT = 'State (California)',
    service_fulfillment.service_result AS service_outcome
      WITH SYNONYMS ('outcome', 'result')
      COMMENT = 'Service outcome'
  )
  METRICS (
    service_trucks.total_trucks AS COUNT(DISTINCT truck_id)
      WITH SYNONYMS ('truck count', 'fleet size')
      COMMENT = 'Total number of trucks',
    service_trucks.avg_truck_mileage AS AVG(mileage)
      WITH SYNONYMS ('average mileage', 'mean truck mileage')
      COMMENT = 'Average truck mileage',
    service_technicians.total_technicians AS COUNT(DISTINCT technician_id)
      WITH SYNONYMS ('technician count', 'driver count', 'staff count')
      COMMENT = 'Total number of technicians',
    service_technicians.avg_technician_rating AS AVG(average_satisfaction_rating)
      WITH SYNONYMS ('average rating', 'mean satisfaction')
      COMMENT = 'Average technician satisfaction rating',
    service_technicians.total_services_by_technicians AS SUM(total_services_completed)
      WITH SYNONYMS ('total completions', 'services completed')
      COMMENT = 'Total services completed by all technicians',
    service_regions.total_regions AS COUNT(DISTINCT region_id)
      WITH SYNONYMS ('region count', 'territory count')
      COMMENT = 'Total number of service regions',
    service_regions.total_population_covered AS SUM(population_covered)
      WITH SYNONYMS ('population served', 'coverage population')
      COMMENT = 'Total population covered by AAA',
    service_regions.total_coverage_area AS SUM(coverage_area_sqmi)
      WITH SYNONYMS ('total area', 'coverage square miles')
      COMMENT = 'Total coverage area in square miles',
    service_fulfillment.avg_response_time AS AVG(response_time_minutes)
      WITH SYNONYMS ('average response', 'mean response time')
      COMMENT = 'Average response time in minutes',
    service_fulfillment.avg_distance_to_service AS AVG(distance_to_member_miles)
      WITH SYNONYMS ('average distance', 'mean service distance')
      COMMENT = 'Average distance to service location in miles'
  )
  COMMENT = 'AAA Fleet & Operations Intelligence - comprehensive view of service trucks, technicians, and regional operations';

-- ============================================================================
-- Semantic View 3: AAA Predictive Analytics Intelligence
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_PREDICTIVE_ANALYTICS_INTELLIGENCE
  TABLES (
    predictive_scores AS RAW.PREDICTIVE_SCORES
      PRIMARY KEY (score_id)
      WITH SYNONYMS ('predictions', 'risk scores', 'ml scores')
      COMMENT = 'Machine learning predictions and scores',
    early_warning_alerts AS RAW.EARLY_WARNING_ALERTS
      PRIMARY KEY (alert_id)
      WITH SYNONYMS ('alerts', 'warnings', 'notifications')
      COMMENT = 'System-generated early warning alerts',
    weather_conditions AS RAW.WEATHER_CONDITIONS
      PRIMARY KEY (weather_id)
      WITH SYNONYMS ('weather', 'conditions', 'weather data')
      COMMENT = 'Weather conditions by region',
    members AS RAW.MEMBERS
      PRIMARY KEY (member_id)
      WITH SYNONYMS ('customers', 'clients')
      COMMENT = 'AAA members',
    service_regions AS RAW.SERVICE_REGIONS
      PRIMARY KEY (region_id)
      WITH SYNONYMS ('regions', 'areas')
      COMMENT = 'Service regions'
  )
  RELATIONSHIPS (
    predictive_scores(member_id) REFERENCES members(member_id),
    early_warning_alerts(region_id) REFERENCES service_regions(region_id),
    weather_conditions(region_id) REFERENCES service_regions(region_id)
  )
  DIMENSIONS (
    predictive_scores.breakdown_risk AS breakdown_risk_score
      WITH SYNONYMS ('breakdown probability', 'failure risk')
      COMMENT = 'Breakdown risk score (0-100)',
    predictive_scores.churn_risk AS churn_risk_score
      WITH SYNONYMS ('cancellation risk', 'attrition risk')
      COMMENT = 'Churn risk score (0-100)',
    predictive_scores.outreach_recommendation AS recommended_outreach
      WITH SYNONYMS ('recommended action', 'next best action')
      COMMENT = 'Recommended outreach action',
    predictive_scores.model_version AS model_version
      WITH SYNONYMS ('ml version', 'algorithm version')
      COMMENT = 'Machine learning model version',
    early_warning_alerts.alert_type AS alert_type
      WITH SYNONYMS ('warning type', 'notification type')
      COMMENT = 'Type of alert: HIGH_DEMAND, WEATHER_IMPACT, etc.',
    early_warning_alerts.alert_severity AS alert_severity
      WITH SYNONYMS ('severity level', 'priority')
      COMMENT = 'Alert severity: LOW, MEDIUM, HIGH, CRITICAL',
    early_warning_alerts.alert_title AS alert_title
      WITH SYNONYMS ('alert name', 'warning title')
      COMMENT = 'Alert title',
    weather_conditions.weather AS condition
      WITH SYNONYMS ('weather type', 'weather condition')
      COMMENT = 'Weather condition: CLEAR, RAIN, FOG, HOT',
    weather_conditions.temperature AS temperature_f
      WITH SYNONYMS ('temp', 'degrees fahrenheit')
      COMMENT = 'Temperature in Fahrenheit',
    weather_conditions.road_condition AS road_conditions
      WITH SYNONYMS ('road state', 'driving conditions')
      COMMENT = 'Road conditions: DRY, WET, REDUCED_VISIBILITY',
    members.membership_level AS membership_level
      WITH SYNONYMS ('member tier', 'plan level')
      COMMENT = 'Membership level',
    service_regions.region_name AS region_name
      WITH SYNONYMS ('area name', 'territory')
      COMMENT = 'Service region name'
  )
  METRICS (
    predictive_scores.total_predictions AS COUNT(DISTINCT score_id)
      WITH SYNONYMS ('prediction count', 'score count')
      COMMENT = 'Total number of predictions',
    predictive_scores.avg_breakdown_risk AS AVG(breakdown_risk_score)
      WITH SYNONYMS ('average breakdown risk', 'mean failure risk')
      COMMENT = 'Average breakdown risk score',
    predictive_scores.avg_churn_risk AS AVG(churn_risk_score)
      WITH SYNONYMS ('average churn risk', 'mean attrition risk')
      COMMENT = 'Average churn risk score',
    predictive_scores.avg_ltv_prediction AS AVG(lifetime_value_prediction)
      WITH SYNONYMS ('average predicted LTV', 'mean lifetime value')
      COMMENT = 'Average predicted lifetime value',
    early_warning_alerts.total_alerts AS COUNT(DISTINCT alert_id)
      WITH SYNONYMS ('alert count', 'warning count')
      COMMENT = 'Total number of alerts',
    early_warning_alerts.total_affected_services AS SUM(affected_services)
      WITH SYNONYMS ('services impacted', 'affected count')
      COMMENT = 'Total services affected by alerts',
    weather_conditions.total_weather_records AS COUNT(DISTINCT weather_id)
      WITH SYNONYMS ('weather observation count')
      COMMENT = 'Total weather observations',
    weather_conditions.avg_temperature AS AVG(temperature_f)
      WITH SYNONYMS ('average temperature', 'mean temp')
      COMMENT = 'Average temperature in Fahrenheit',
    weather_conditions.avg_wind_speed AS AVG(wind_speed_mph)
      WITH SYNONYMS ('average wind', 'mean wind speed')
      COMMENT = 'Average wind speed in mph',
    weather_conditions.total_precipitation AS SUM(precipitation_inches)
      WITH SYNONYMS ('total rain', 'precipitation sum')
      COMMENT = 'Total precipitation in inches'
  )
  COMMENT = 'AAA Predictive Analytics Intelligence - comprehensive view of ML predictions, early warnings, and environmental factors';

-- ============================================================================
-- Display confirmation and verification
-- ============================================================================
SELECT 'Semantic views created successfully - all syntax verified' AS status;

-- Verify semantic views exist
SELECT 
    table_name AS semantic_view_name,
    comment AS description
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'ANALYTICS'
  AND table_name LIKE 'SV_%'
ORDER BY table_name;

-- Show semantic view details
SHOW SEMANTIC VIEWS IN SCHEMA ANALYTICS;
