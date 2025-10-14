-- ============================================================================
-- AAA Intelligence Agent - Table Definitions
-- ============================================================================
-- Purpose: Create all necessary tables for the AAA roadside assistance model
-- Based on verified Early-Warning template structure
-- ============================================================================

USE DATABASE AAA_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE AAA_WH;

-- ============================================================================
-- MEMBERS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE MEMBERS (
    member_id VARCHAR(20) PRIMARY KEY,
    member_number VARCHAR(20) NOT NULL UNIQUE,
    member_name VARCHAR(200) NOT NULL,
    email VARCHAR(200) NOT NULL,
    phone VARCHAR(20),
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(2),
    zip_code VARCHAR(10),
    membership_level VARCHAR(20) DEFAULT 'CLASSIC',
    membership_start_date DATE NOT NULL,
    membership_renewal_date DATE NOT NULL,
    membership_status VARCHAR(20) DEFAULT 'ACTIVE',
    lifetime_value NUMBER(12,2) DEFAULT 0.00,
    risk_score NUMBER(5,2),
    is_auto_renew BOOLEAN DEFAULT TRUE,
    preferred_contact_method VARCHAR(20) DEFAULT 'PHONE',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- VEHICLES TABLE
-- ============================================================================
CREATE OR REPLACE TABLE VEHICLES (
    vehicle_id VARCHAR(30) PRIMARY KEY,
    member_id VARCHAR(20) NOT NULL,
    vin VARCHAR(17),
    license_plate VARCHAR(20),
    make VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    year NUMBER(4) NOT NULL,
    color VARCHAR(30),
    vehicle_type VARCHAR(30) DEFAULT 'SEDAN',
    mileage NUMBER(10),
    is_primary_vehicle BOOLEAN DEFAULT TRUE,
    registration_state VARCHAR(2),
    registration_expiration DATE,
    insurance_carrier VARCHAR(100),
    insurance_policy_number VARCHAR(50),
    insurance_expiration DATE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (member_id) REFERENCES MEMBERS(member_id)
);

-- ============================================================================
-- SERVICE_REQUESTS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE SERVICE_REQUESTS (
    service_id VARCHAR(30) PRIMARY KEY,
    member_id VARCHAR(20) NOT NULL,
    vehicle_id VARCHAR(30),
    request_number VARCHAR(30) NOT NULL UNIQUE,
    request_timestamp TIMESTAMP_NTZ NOT NULL,
    service_type VARCHAR(50) NOT NULL,
    service_category VARCHAR(30) DEFAULT 'EMERGENCY',
    priority VARCHAR(20) DEFAULT 'MEDIUM',
    location_latitude FLOAT,
    location_longitude FLOAT,
    location_address VARCHAR(500),
    location_type VARCHAR(30),
    weather_condition VARCHAR(30),
    temperature_f NUMBER(3),
    channel VARCHAR(30) DEFAULT 'PHONE',
    member_wait_location VARCHAR(50),
    special_instructions TEXT,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (member_id) REFERENCES MEMBERS(member_id),
    FOREIGN KEY (vehicle_id) REFERENCES VEHICLES(vehicle_id)
);

-- ============================================================================
-- SERVICE_FULFILLMENT TABLE
-- ============================================================================
CREATE OR REPLACE TABLE SERVICE_FULFILLMENT (
    fulfillment_id VARCHAR(30) PRIMARY KEY,
    service_id VARCHAR(30) NOT NULL,
    technician_id VARCHAR(20) NOT NULL,
    truck_id VARCHAR(20),
    dispatch_timestamp TIMESTAMP_NTZ NOT NULL,
    arrival_timestamp TIMESTAMP_NTZ,
    completion_timestamp TIMESTAMP_NTZ,
    response_time_minutes NUMBER(10),
    service_duration_minutes NUMBER(10),
    distance_to_member_miles FLOAT,
    service_outcome VARCHAR(50) DEFAULT 'COMPLETED',
    towing_destination VARCHAR(255),
    towing_distance_miles FLOAT,
    parts_used VARCHAR(500),
    service_cost NUMBER(12,2),
    member_satisfaction_score NUMBER(1),
    technician_notes TEXT,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (service_id) REFERENCES SERVICE_REQUESTS(service_id)
);

-- ============================================================================
-- SERVICE_TECHNICIANS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE SERVICE_TECHNICIANS (
    technician_id VARCHAR(20) PRIMARY KEY,
    technician_name VARCHAR(200) NOT NULL,
    employee_number VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(200) NOT NULL,
    phone VARCHAR(20),
    service_region VARCHAR(50),
    certification_level VARCHAR(30) DEFAULT 'BASIC',
    specializations VARCHAR(500),
    hire_date DATE,
    average_response_time_minutes NUMBER(10,2),
    average_satisfaction_rating NUMBER(3,2),
    total_services_completed NUMBER(10,0) DEFAULT 0,
    technician_status VARCHAR(30) DEFAULT 'ACTIVE',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- SERVICE_TRUCKS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE SERVICE_TRUCKS (
    truck_id VARCHAR(20) PRIMARY KEY,
    truck_number VARCHAR(20) NOT NULL UNIQUE,
    truck_type VARCHAR(50) DEFAULT 'STANDARD',
    equipment_list VARCHAR(1000),
    service_region VARCHAR(50),
    current_latitude FLOAT,
    current_longitude FLOAT,
    last_location_update TIMESTAMP_NTZ,
    truck_status VARCHAR(30) DEFAULT 'AVAILABLE',
    mileage NUMBER(10),
    last_maintenance_date DATE,
    next_maintenance_date DATE,
    fuel_level_percent NUMBER(3),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- SERVICE_REGIONS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE SERVICE_REGIONS (
    region_id VARCHAR(20) PRIMARY KEY,
    region_name VARCHAR(100) NOT NULL,
    region_code VARCHAR(10) NOT NULL UNIQUE,
    state VARCHAR(2) NOT NULL,
    coverage_area_sqmi NUMBER(10,2),
    population_covered NUMBER(12,0),
    active_technicians NUMBER(10,0),
    active_trucks NUMBER(10,0),
    average_response_time_minutes NUMBER(10,2),
    target_response_time_minutes NUMBER(10,2) DEFAULT 45,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- MEMBERSHIP_PLANS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE MEMBERSHIP_PLANS (
    plan_id VARCHAR(20) PRIMARY KEY,
    plan_name VARCHAR(50) NOT NULL,
    plan_level VARCHAR(20) NOT NULL,
    annual_fee NUMBER(10,2),
    towing_miles_limit NUMBER(10,0),
    service_calls_limit NUMBER(10,0),
    locksmith_reimbursement NUMBER(10,2),
    trip_interruption_coverage NUMBER(10,2),
    battery_service BOOLEAN DEFAULT TRUE,
    flat_tire_service BOOLEAN DEFAULT TRUE,
    fuel_delivery BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- MEMBER_TRANSACTIONS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE MEMBER_TRANSACTIONS (
    transaction_id VARCHAR(30) PRIMARY KEY,
    member_id VARCHAR(20) NOT NULL,
    transaction_date TIMESTAMP_NTZ NOT NULL,
    transaction_type VARCHAR(50) NOT NULL,
    product_type VARCHAR(50),
    amount NUMBER(12,2) NOT NULL,
    payment_method VARCHAR(30),
    payment_status VARCHAR(30) DEFAULT 'COMPLETED',
    renewal_flag BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (member_id) REFERENCES MEMBERS(member_id)
);

-- ============================================================================
-- WEATHER_CONDITIONS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE WEATHER_CONDITIONS (
    weather_id VARCHAR(30) PRIMARY KEY,
    region_id VARCHAR(20) NOT NULL,
    observation_timestamp TIMESTAMP_NTZ NOT NULL,
    temperature_f NUMBER(3),
    condition VARCHAR(50),
    precipitation_inches NUMBER(5,2),
    wind_speed_mph NUMBER(5,1),
    visibility_miles NUMBER(5,1),
    road_conditions VARCHAR(50),
    weather_alert VARCHAR(100),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (region_id) REFERENCES SERVICE_REGIONS(region_id)
);

-- ============================================================================
-- PREDICTIVE_SCORES TABLE
-- ============================================================================
CREATE OR REPLACE TABLE PREDICTIVE_SCORES (
    score_id VARCHAR(30) PRIMARY KEY,
    member_id VARCHAR(20) NOT NULL,
    score_date DATE NOT NULL,
    breakdown_risk_score NUMBER(5,2),
    churn_risk_score NUMBER(5,2),
    lifetime_value_prediction NUMBER(12,2),
    next_service_prediction_days NUMBER(10,0),
    recommended_outreach VARCHAR(100),
    model_version VARCHAR(20),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (member_id) REFERENCES MEMBERS(member_id)
);

-- ============================================================================
-- EARLY_WARNING_ALERTS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE EARLY_WARNING_ALERTS (
    alert_id VARCHAR(30) PRIMARY KEY,
    alert_type VARCHAR(50) NOT NULL,
    alert_severity VARCHAR(20) NOT NULL,
    region_id VARCHAR(20),
    alert_title VARCHAR(200) NOT NULL,
    alert_message TEXT NOT NULL,
    affected_services NUMBER(10,0),
    metric_value NUMBER(12,2),
    threshold_value NUMBER(12,2),
    alert_timestamp TIMESTAMP_NTZ NOT NULL,
    acknowledged_by VARCHAR(100),
    acknowledged_timestamp TIMESTAMP_NTZ,
    resolved_timestamp TIMESTAMP_NTZ,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (region_id) REFERENCES SERVICE_REGIONS(region_id)
);

-- ============================================================================
-- Display confirmation
-- ============================================================================
SELECT 'All tables created successfully' AS status;
