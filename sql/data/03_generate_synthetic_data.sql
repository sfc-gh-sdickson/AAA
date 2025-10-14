-- ============================================================================
-- AAA Intelligence Agent - Synthetic Data Generation
-- ============================================================================
-- Purpose: Generate realistic sample data for AAA roadside assistance operations
-- Volume: ~100K members, 150K vehicles, 2M service requests
-- ============================================================================

USE DATABASE AAA_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE AAA_WH;

-- ============================================================================
-- Step 1: Generate Membership Plans
-- ============================================================================
INSERT INTO MEMBERSHIP_PLANS VALUES
('PLAN001', 'Classic', 'CLASSIC', 64.00, 5, 4, 50, 0, TRUE, TRUE, TRUE, TRUE, CURRENT_TIMESTAMP()),
('PLAN002', 'Plus', 'PLUS', 94.00, 100, 4, 150, 200, TRUE, TRUE, TRUE, TRUE, CURRENT_TIMESTAMP()),
('PLAN003', 'Premier', 'PREMIER', 124.00, 200, 4, 150, 1500, TRUE, TRUE, TRUE, TRUE, CURRENT_TIMESTAMP()),
('PLAN004', 'Plus RV', 'PLUS_RV', 134.00, 100, 4, 150, 200, TRUE, TRUE, TRUE, TRUE, CURRENT_TIMESTAMP()),
('PLAN005', 'Premier RV', 'PREMIER_RV', 164.00, 200, 4, 150, 1500, TRUE, TRUE, TRUE, TRUE, CURRENT_TIMESTAMP());

-- ============================================================================
-- Step 2: Generate Service Regions (California)
-- ============================================================================
INSERT INTO SERVICE_REGIONS VALUES
('REG001', 'Los Angeles Metro', 'LA', 'CA', 4850.0, 10000000, 250, 150, 38.5, 45, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('REG002', 'San Francisco Bay Area', 'SF', 'CA', 7000.0, 7500000, 200, 125, 35.2, 40, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('REG003', 'San Diego County', 'SD', 'CA', 4526.0, 3300000, 120, 75, 32.8, 40, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('REG004', 'Sacramento Valley', 'SAC', 'CA', 3000.0, 2400000, 80, 50, 40.1, 50, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('REG005', 'Inland Empire', 'IE', 'CA', 27000.0, 4600000, 150, 90, 45.3, 55, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('REG006', 'Central Valley', 'CV', 'CA', 22500.0, 4000000, 100, 60, 48.7, 60, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('REG007', 'Orange County', 'OC', 'CA', 948.0, 3200000, 110, 70, 33.5, 40, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('REG008', 'Ventura County', 'VC', 'CA', 2208.0, 850000, 40, 25, 36.2, 45, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('REG009', 'Central Coast', 'CC', 'CA', 5159.0, 780000, 35, 20, 42.1, 50, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('REG010', 'North Coast', 'NC', 'CA', 12000.0, 500000, 30, 20, 55.3, 65, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());

-- ============================================================================
-- Step 3: Generate Members
-- ============================================================================
INSERT INTO MEMBERS
SELECT
    'MEM' || LPAD(SEQ4(), 10, '0') AS member_id,
    'AAA' || LPAD(UNIFORM(10000000, 99999999, RANDOM()), 8, '0') AS member_number,
    CASE 
        WHEN UNIFORM(0, 1, RANDOM()) = 0 
        THEN ARRAY_CONSTRUCT('John', 'Mary', 'Robert', 'Patricia', 'Michael', 'Jennifer', 'David', 'Linda', 'James', 'Elizabeth')[UNIFORM(0, 9, RANDOM())]
        ELSE ARRAY_CONSTRUCT('Johnson', 'Smith', 'Williams', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor', 'Anderson')[UNIFORM(0, 9, RANDOM())]
    END || ' ' ||
    ARRAY_CONSTRUCT('Johnson', 'Smith', 'Williams', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor', 'Anderson', 'Thomas', 'Jackson', 'White', 'Harris', 'Martin')[UNIFORM(0, 14, RANDOM())] AS member_name,
    LOWER(REPLACE(member_name, ' ', '.')) || UNIFORM(100, 999, RANDOM()) || '@' || 
        ARRAY_CONSTRUCT('gmail.com', 'yahoo.com', 'outlook.com', 'aol.com', 'icloud.com')[UNIFORM(0, 4, RANDOM())] AS email,
    CONCAT('+1-', UNIFORM(200, 999, RANDOM()), '-', UNIFORM(200, 999, RANDOM()), '-', UNIFORM(1000, 9999, RANDOM())) AS phone,
    UNIFORM(100, 9999, RANDOM()) || ' ' || 
        ARRAY_CONSTRUCT('Main', 'Oak', 'Pine', 'Maple', 'Cedar', 'Elm', 'Park', 'Washington', 'Lake', 'Hill')[UNIFORM(0, 9, RANDOM())] || ' ' ||
        ARRAY_CONSTRUCT('Street', 'Avenue', 'Road', 'Boulevard', 'Lane', 'Drive', 'Court', 'Place')[UNIFORM(0, 7, RANDOM())] AS address_line1,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN 'Apt ' || UNIFORM(1, 999, RANDOM()) ELSE NULL END AS address_line2,
    ARRAY_CONSTRUCT('Los Angeles', 'San Francisco', 'San Diego', 'Sacramento', 'Riverside', 'Fresno', 'San Jose', 'Oakland', 'Long Beach', 'Anaheim')[UNIFORM(0, 9, RANDOM())] AS city,
    'CA' AS state,
    LPAD(UNIFORM(90001, 96162, RANDOM())::VARCHAR, 5, '0') AS zip_code,
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN 'CLASSIC'
        WHEN UNIFORM(0, 100, RANDOM()) < 85 THEN 'PLUS'
        ELSE 'PREMIER'
    END AS membership_level,
    DATEADD('day', -1 * UNIFORM(1, 3650, RANDOM()), CURRENT_DATE()) AS membership_start_date,
    DATEADD('year', 1, membership_start_date) AS membership_renewal_date,
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 92 THEN 'ACTIVE'
        WHEN UNIFORM(0, 100, RANDOM()) < 97 THEN 'EXPIRED'
        ELSE 'SUSPENDED'
    END AS membership_status,
    (UNIFORM(100, 5000, RANDOM()) / 1.0)::NUMBER(12,2) AS lifetime_value,
    (UNIFORM(10, 90, RANDOM()) / 1.0)::NUMBER(5,2) AS risk_score,
    UNIFORM(0, 100, RANDOM()) < 75 AS is_auto_renew,
    ARRAY_CONSTRUCT('PHONE', 'EMAIL', 'SMS', 'MAIL')[UNIFORM(0, 3, RANDOM())] AS preferred_contact_method,
    DATEADD('day', -1 * UNIFORM(1, 3650, RANDOM()), CURRENT_TIMESTAMP()) AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 100000));

-- ============================================================================
-- Step 4: Generate Vehicles
-- ============================================================================
INSERT INTO VEHICLES
SELECT
    'VEH' || LPAD(SEQ4(), 10, '0') AS vehicle_id,
    m.member_id,
    -- Generate realistic VIN (17 characters)
    UPPER(
        SUBSTR(MD5(RANDOM()::VARCHAR), 1, 1) || 
        SUBSTR(MD5(RANDOM()::VARCHAR), 1, 2) || 
        SUBSTR(MD5(RANDOM()::VARCHAR), 1, 5) || 
        SUBSTR(MD5(RANDOM()::VARCHAR), 1, 1) || 
        LPAD(UNIFORM(10000, 99999, RANDOM())::VARCHAR, 5, '0') || 
        SUBSTR(MD5(RANDOM()::VARCHAR), 1, 3)
    ) AS vin,
    UPPER(SUBSTR(MD5(RANDOM()::VARCHAR), 1, 3)) || UNIFORM(1000, 9999, RANDOM()) AS license_plate,
    ARRAY_CONSTRUCT('Toyota', 'Honda', 'Ford', 'Chevrolet', 'Nissan', 'Hyundai', 'BMW', 'Mercedes-Benz', 'Audi', 'Volkswagen', 'Mazda', 'Subaru', 'Kia', 'Jeep', 'RAM')[UNIFORM(0, 14, RANDOM())] AS make,
    CASE make
        WHEN 'Toyota' THEN ARRAY_CONSTRUCT('Camry', 'Corolla', 'RAV4', 'Highlander', 'Tacoma')[UNIFORM(0, 4, RANDOM())]
        WHEN 'Honda' THEN ARRAY_CONSTRUCT('Civic', 'Accord', 'CR-V', 'Pilot', 'Odyssey')[UNIFORM(0, 4, RANDOM())]
        WHEN 'Ford' THEN ARRAY_CONSTRUCT('F-150', 'Explorer', 'Escape', 'Mustang', 'Edge')[UNIFORM(0, 4, RANDOM())]
        WHEN 'Chevrolet' THEN ARRAY_CONSTRUCT('Silverado', 'Malibu', 'Equinox', 'Tahoe', 'Traverse')[UNIFORM(0, 4, RANDOM())]
        ELSE ARRAY_CONSTRUCT('Model S', 'Model X', 'Model 3', 'Model Y')[UNIFORM(0, 3, RANDOM())]
    END AS model,
    UNIFORM(2010, 2024, RANDOM()) AS year,
    ARRAY_CONSTRUCT('White', 'Black', 'Silver', 'Gray', 'Blue', 'Red', 'Green', 'Beige')[UNIFORM(0, 7, RANDOM())] AS color,
    CASE 
        WHEN model IN ('F-150', 'Silverado', 'Tacoma') THEN 'TRUCK'
        WHEN model IN ('RAV4', 'CR-V', 'Explorer', 'Pilot', 'Tahoe', 'Highlander') THEN 'SUV'
        WHEN model IN ('Odyssey') THEN 'VAN'
        WHEN model IN ('Mustang') THEN 'SPORTS'
        ELSE 'SEDAN'
    END AS vehicle_type,
    UNIFORM(5000, 150000, RANDOM()) AS mileage,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN TRUE ELSE FALSE END AS is_primary_vehicle,
    'CA' AS registration_state,
    DATEADD('day', UNIFORM(30, 365, RANDOM()), CURRENT_DATE()) AS registration_expiration,
    ARRAY_CONSTRUCT('AAA Insurance', 'State Farm', 'Geico', 'Progressive', 'Allstate', 'Farmers', 'USAA')[UNIFORM(0, 6, RANDOM())] AS insurance_carrier,
    'POL' || UNIFORM(100000, 999999, RANDOM()) AS insurance_policy_number,
    DATEADD('day', UNIFORM(30, 365, RANDOM()), CURRENT_DATE()) AS insurance_expiration,
    m.created_at AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM MEMBERS m
CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 2))
WHERE UNIFORM(0, 100, RANDOM()) < 75
LIMIT 150000;

-- ============================================================================
-- Step 5: Generate Service Technicians
-- ============================================================================
INSERT INTO SERVICE_TECHNICIANS
SELECT
    'TEC' || LPAD(SEQ4(), 5, '0') AS technician_id,
    ARRAY_CONSTRUCT('James', 'John', 'Robert', 'Michael', 'William', 'David', 'Richard', 'Joseph', 'Thomas', 'Charles')[UNIFORM(0, 9, RANDOM())] || ' ' ||
    ARRAY_CONSTRUCT('Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez')[UNIFORM(0, 9, RANDOM())] AS technician_name,
    'EMP' || LPAD(UNIFORM(10000, 99999, RANDOM()), 5, '0') AS employee_number,
    LOWER(REPLACE(technician_name, ' ', '.')) || '@aaa-calif.com' AS email,
    CONCAT('+1-', UNIFORM(200, 999, RANDOM()), '-', UNIFORM(200, 999, RANDOM()), '-', UNIFORM(1000, 9999, RANDOM())) AS phone,
    r.region_name AS service_region,
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN 'MASTER'
        WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN 'ADVANCED'
        ELSE 'BASIC'
    END AS certification_level,
    ARRAY_CONSTRUCT('TOWING', 'BATTERY', 'LOCKOUT', 'TIRE_CHANGE', 'FUEL_DELIVERY', 'JUMP_START')[UNIFORM(0, 5, RANDOM())] || ',' ||
    ARRAY_CONSTRUCT('LIGHT_MECHANICAL', 'DIAGNOSTICS', 'WINCHING')[UNIFORM(0, 2, RANDOM())] AS specializations,
    DATEADD('day', -1 * UNIFORM(180, 3650, RANDOM()), CURRENT_DATE()) AS hire_date,
    (UNIFORM(25, 60, RANDOM()) / 1.0)::NUMBER(10,2) AS average_response_time_minutes,
    (UNIFORM(35, 50, RANDOM()) / 10.0)::NUMBER(3,2) AS average_satisfaction_rating,
    UNIFORM(100, 5000, RANDOM()) AS total_services_completed,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 95 THEN 'ACTIVE' ELSE 'INACTIVE' END AS technician_status,
    DATEADD('day', -1 * UNIFORM(180, 3650, RANDOM()), CURRENT_TIMESTAMP()) AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM SERVICE_REGIONS r
CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 50));

-- ============================================================================
-- Step 6: Generate Service Trucks
-- ============================================================================
INSERT INTO SERVICE_TRUCKS
SELECT
    'TRK' || LPAD(SEQ4(), 5, '0') AS truck_id,
    'AAA-' || r.region_code || '-' || LPAD(UNIFORM(100, 999, RANDOM()), 3, '0') AS truck_number,
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN 'STANDARD'
        WHEN UNIFORM(0, 100, RANDOM()) < 85 THEN 'FLATBED'
        WHEN UNIFORM(0, 100, RANDOM()) < 95 THEN 'HEAVY_DUTY'
        ELSE 'MOTORCYCLE'
    END AS truck_type,
    'Jumper Cables, Tool Kit, Jack, Spare Tires, Fuel Can, Lockout Kit, Battery Charger' AS equipment_list,
    r.region_name AS service_region,
    -- Random location within region (simplified - using region center +/- variance)
    CASE r.region_code
        WHEN 'LA' THEN 34.0522 + (UNIFORM(-50, 50, RANDOM()) / 100.0)
        WHEN 'SF' THEN 37.7749 + (UNIFORM(-50, 50, RANDOM()) / 100.0)
        WHEN 'SD' THEN 32.7157 + (UNIFORM(-50, 50, RANDOM()) / 100.0)
        WHEN 'SAC' THEN 38.5816 + (UNIFORM(-50, 50, RANDOM()) / 100.0)
        ELSE 36.7783 + (UNIFORM(-50, 50, RANDOM()) / 100.0)
    END AS current_latitude,
    CASE r.region_code
        WHEN 'LA' THEN -118.2437 + (UNIFORM(-50, 50, RANDOM()) / 100.0)
        WHEN 'SF' THEN -122.4194 + (UNIFORM(-50, 50, RANDOM()) / 100.0)
        WHEN 'SD' THEN -117.1611 + (UNIFORM(-50, 50, RANDOM()) / 100.0)
        WHEN 'SAC' THEN -121.4944 + (UNIFORM(-50, 50, RANDOM()) / 100.0)
        ELSE -119.4179 + (UNIFORM(-50, 50, RANDOM()) / 100.0)
    END AS current_longitude,
    DATEADD('minute', -1 * UNIFORM(1, 120, RANDOM()), CURRENT_TIMESTAMP()) AS last_location_update,
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 60 THEN 'AVAILABLE'
        WHEN UNIFORM(0, 100, RANDOM()) < 85 THEN 'ON_CALL'
        WHEN UNIFORM(0, 100, RANDOM()) < 95 THEN 'RETURNING'
        ELSE 'MAINTENANCE'
    END AS truck_status,
    UNIFORM(10000, 150000, RANDOM()) AS mileage,
    DATEADD('day', -1 * UNIFORM(1, 90, RANDOM()), CURRENT_DATE()) AS last_maintenance_date,
    DATEADD('day', 90, last_maintenance_date) AS next_maintenance_date,
    UNIFORM(25, 100, RANDOM()) AS fuel_level_percent,
    DATEADD('day', -1 * UNIFORM(180, 1095, RANDOM()), CURRENT_TIMESTAMP()) AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM SERVICE_REGIONS r
CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 75));

-- ============================================================================
-- Step 7: Generate Service Requests (2M records)
-- ============================================================================
INSERT INTO SERVICE_REQUESTS
SELECT
    'SVC' || LPAD(SEQ4(), 12, '0') AS service_id,
    m.member_id,
    v.vehicle_id,
    'REQ' || UNIFORM(100000000, 999999999, RANDOM()) AS request_number,
    DATEADD('day', -1 * UNIFORM(0, 730, RANDOM()), 
            DATEADD('hour', UNIFORM(0, 23, RANDOM()),
                    DATEADD('minute', UNIFORM(0, 59, RANDOM()), CURRENT_TIMESTAMP()))) AS request_timestamp,
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 35 THEN 'TOWING'
        WHEN UNIFORM(0, 100, RANDOM()) < 55 THEN 'BATTERY_JUMP'
        WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN 'FLAT_TIRE'
        WHEN UNIFORM(0, 100, RANDOM()) < 85 THEN 'LOCKOUT'
        WHEN UNIFORM(0, 100, RANDOM()) < 95 THEN 'FUEL_DELIVERY'
        ELSE 'OTHER'
    END AS service_type,
    CASE 
        WHEN HOUR(request_timestamp) BETWEEN 22 AND 6 THEN 'EMERGENCY'
        WHEN service_type = 'TOWING' THEN 'EMERGENCY'
        ELSE 'STANDARD'
    END AS service_category,
    CASE 
        WHEN service_category = 'EMERGENCY' THEN 'HIGH'
        WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN 'HIGH'
        WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS priority,
    -- Generate location based on member's region
    CASE SUBSTRING(m.zip_code, 1, 3)
        WHEN '900' THEN 34.0522 + (UNIFORM(-100, 100, RANDOM()) / 100.0)  -- LA area
        WHEN '941' THEN 37.7749 + (UNIFORM(-100, 100, RANDOM()) / 100.0)  -- SF area
        WHEN '921' THEN 32.7157 + (UNIFORM(-100, 100, RANDOM()) / 100.0)  -- SD area
        ELSE 36.7783 + (UNIFORM(-200, 200, RANDOM()) / 100.0)  -- Central CA
    END AS location_latitude,
    CASE SUBSTRING(m.zip_code, 1, 3)
        WHEN '900' THEN -118.2437 + (UNIFORM(-100, 100, RANDOM()) / 100.0)  -- LA area
        WHEN '941' THEN -122.4194 + (UNIFORM(-100, 100, RANDOM()) / 100.0)  -- SF area
        WHEN '921' THEN -117.1611 + (UNIFORM(-100, 100, RANDOM()) / 100.0)  -- SD area
        ELSE -119.4179 + (UNIFORM(-200, 200, RANDOM()) / 100.0)  -- Central CA
    END AS location_longitude,
    m.address_line1 || ', ' || m.city || ', CA ' || m.zip_code AS location_address,
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 40 THEN 'HIGHWAY'
        WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN 'RESIDENTIAL'
        WHEN UNIFORM(0, 100, RANDOM()) < 90 THEN 'PARKING_LOT'
        ELSE 'COMMERCIAL'
    END AS location_type,
    CASE MONTH(request_timestamp)
        WHEN 12 THEN ARRAY_CONSTRUCT('CLEAR', 'RAIN', 'FOG')[UNIFORM(0, 2, RANDOM())]
        WHEN 1 THEN ARRAY_CONSTRUCT('CLEAR', 'RAIN', 'FOG')[UNIFORM(0, 2, RANDOM())]
        WHEN 2 THEN ARRAY_CONSTRUCT('CLEAR', 'RAIN')[UNIFORM(0, 1, RANDOM())]
        WHEN 6 THEN ARRAY_CONSTRUCT('CLEAR', 'HOT')[UNIFORM(0, 1, RANDOM())]
        WHEN 7 THEN ARRAY_CONSTRUCT('CLEAR', 'HOT')[UNIFORM(0, 1, RANDOM())]
        WHEN 8 THEN ARRAY_CONSTRUCT('CLEAR', 'HOT')[UNIFORM(0, 1, RANDOM())]
        ELSE 'CLEAR'
    END AS weather_condition,
    CASE weather_condition
        WHEN 'HOT' THEN UNIFORM(85, 110, RANDOM())
        WHEN 'RAIN' THEN UNIFORM(45, 65, RANDOM())
        WHEN 'FOG' THEN UNIFORM(40, 60, RANDOM())
        ELSE UNIFORM(60, 85, RANDOM())
    END AS temperature_f,
    ARRAY_CONSTRUCT('PHONE', 'MOBILE_APP', 'WEB', 'ALEXA')[UNIFORM(0, 3, RANDOM())] AS channel,
    CASE 
        WHEN location_type = 'HIGHWAY' AND weather_condition IN ('RAIN', 'FOG') THEN 'SAFE_LOCATION'
        WHEN service_type = 'TOWING' THEN 'WITH_VEHICLE'
        ELSE ARRAY_CONSTRUCT('WITH_VEHICLE', 'SAFE_LOCATION', 'LEFT_SCENE')[UNIFORM(0, 2, RANDOM())]
    END AS member_wait_location,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN 'Please hurry - ' || 
        ARRAY_CONSTRUCT('elderly passenger', 'child in vehicle', 'medical condition', 'late for appointment')[UNIFORM(0, 3, RANDOM())]
    ELSE NULL END AS special_instructions,
    request_timestamp AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM MEMBERS m
JOIN VEHICLES v ON m.member_id = v.member_id
CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 20))
WHERE m.membership_status = 'ACTIVE'
    AND UNIFORM(0, 100, RANDOM()) < 15
LIMIT 2000000;

-- ============================================================================
-- Step 8: Generate Service Fulfillment
-- ============================================================================
INSERT INTO SERVICE_FULFILLMENT
SELECT
    'FUL' || sr.service_id AS fulfillment_id,
    sr.service_id,
    'TEC' || LPAD(UNIFORM(1, 500, RANDOM()), 5, '0') AS technician_id,
    'TRK' || LPAD(UNIFORM(1, 750, RANDOM()), 5, '0') AS truck_id,
    DATEADD('minute', UNIFORM(5, 20, RANDOM()), sr.request_timestamp) AS dispatch_timestamp,
    DATEADD('minute', 
        CASE sr.priority
            WHEN 'HIGH' THEN UNIFORM(15, 35, RANDOM())
            WHEN 'MEDIUM' THEN UNIFORM(25, 50, RANDOM())
            ELSE UNIFORM(35, 75, RANDOM())
        END, dispatch_timestamp) AS arrival_timestamp,
    DATEADD('minute',
        CASE sr.service_type
            WHEN 'TOWING' THEN UNIFORM(30, 60, RANDOM())
            WHEN 'BATTERY_JUMP' THEN UNIFORM(10, 20, RANDOM())
            WHEN 'FLAT_TIRE' THEN UNIFORM(15, 30, RANDOM())
            WHEN 'LOCKOUT' THEN UNIFORM(10, 25, RANDOM())
            WHEN 'FUEL_DELIVERY' THEN UNIFORM(10, 20, RANDOM())
            ELSE UNIFORM(20, 40, RANDOM())
        END, arrival_timestamp) AS completion_timestamp,
    DATEDIFF('minute', dispatch_timestamp, arrival_timestamp) AS response_time_minutes,
    DATEDIFF('minute', arrival_timestamp, completion_timestamp) AS service_duration_minutes,
    ROUND(UNIFORM(1, 50, RANDOM()) * 1.0, 1) AS distance_to_member_miles,
    CASE 
        WHEN sr.service_type = 'TOWING' AND UNIFORM(0, 100, RANDOM()) < 90 THEN 'TOWED'
        WHEN UNIFORM(0, 100, RANDOM()) < 95 THEN 'COMPLETED'
        ELSE 'UNABLE_TO_COMPLETE'
    END AS service_outcome,
    CASE WHEN sr.service_type = 'TOWING' THEN 
        ARRAY_CONSTRUCT('Joes Auto Repair', 'AAA Approved Shop', 'Dealer Service Center', 'Members Home')[UNIFORM(0, 3, RANDOM())]
    ELSE NULL END AS towing_destination,
    CASE WHEN sr.service_type = 'TOWING' THEN UNIFORM(5, 50, RANDOM()) ELSE NULL END AS towing_distance_miles,
    CASE sr.service_type
        WHEN 'BATTERY_JUMP' THEN 'Jumper Cables'
        WHEN 'FLAT_TIRE' THEN 'Spare Tire, Jack, Lug Wrench'
        WHEN 'FUEL_DELIVERY' THEN '2 Gallons Gasoline'
        WHEN 'LOCKOUT' THEN 'Lockout Kit'
        ELSE NULL
    END AS parts_used,
    CASE sr.service_type
        WHEN 'TOWING' THEN (75 + (towing_distance_miles * 3.50))::NUMBER(12,2)
        WHEN 'BATTERY_JUMP' THEN 0.00
        WHEN 'FLAT_TIRE' THEN 0.00
        WHEN 'LOCKOUT' THEN 0.00
        WHEN 'FUEL_DELIVERY' THEN 10.00
        ELSE 0.00
    END AS service_cost,
    CASE 
        WHEN response_time_minutes <= 30 AND service_outcome = 'COMPLETED' THEN 5
        WHEN response_time_minutes <= 45 AND service_outcome = 'COMPLETED' THEN 4
        WHEN response_time_minutes <= 60 AND service_outcome = 'COMPLETED' THEN 3
        WHEN service_outcome = 'COMPLETED' THEN 2
        ELSE 1
    END AS member_satisfaction_score,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN 
        ARRAY_CONSTRUCT(
            'Member was very grateful for quick response',
            'Vehicle started on first attempt after jump',
            'Tire change completed safely on highway shoulder',
            'Successfully unlocked vehicle without damage',
            'Member directed to nearest gas station after fuel delivery'
        )[UNIFORM(0, 4, RANDOM())]
    ELSE NULL END AS technician_notes,
    sr.created_at AS created_at
FROM SERVICE_REQUESTS sr;

-- ============================================================================
-- Step 9: Generate Member Transactions
-- ============================================================================
INSERT INTO MEMBER_TRANSACTIONS
SELECT
    'TXN' || LPAD(SEQ4(), 12, '0') AS transaction_id,
    m.member_id,
    CASE 
        WHEN DATEDIFF('day', m.membership_renewal_date, CURRENT_DATE()) BETWEEN -30 AND 30 
        THEN m.membership_renewal_date
        ELSE DATEADD('day', -1 * UNIFORM(0, 365, RANDOM()), CURRENT_TIMESTAMP())
    END AS transaction_date,
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN 'MEMBERSHIP_RENEWAL'
        WHEN UNIFORM(0, 100, RANDOM()) < 90 THEN 'MEMBERSHIP_UPGRADE'
        WHEN UNIFORM(0, 100, RANDOM()) < 95 THEN 'SERVICE_FEE'
        ELSE 'OTHER'
    END AS transaction_type,
    CASE transaction_type
        WHEN 'MEMBERSHIP_RENEWAL' THEN m.membership_level || '_MEMBERSHIP'
        WHEN 'MEMBERSHIP_UPGRADE' THEN 'MEMBERSHIP_UPGRADE'
        WHEN 'SERVICE_FEE' THEN 'TOWING_FEE'
        ELSE 'MISC'
    END AS product_type,
    CASE m.membership_level
        WHEN 'CLASSIC' THEN 64.00
        WHEN 'PLUS' THEN 94.00
        WHEN 'PREMIER' THEN 124.00
    END AS amount,
    ARRAY_CONSTRUCT('CREDIT_CARD', 'DEBIT_CARD', 'BANK_TRANSFER', 'CHECK')[UNIFORM(0, 3, RANDOM())] AS payment_method,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 98 THEN 'COMPLETED' ELSE 'FAILED' END AS payment_status,
    transaction_type = 'MEMBERSHIP_RENEWAL' AS renewal_flag,
    transaction_date AS created_at
FROM MEMBERS m
CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 3))
WHERE UNIFORM(0, 100, RANDOM()) < 40;

-- ============================================================================
-- Step 10: Generate Weather Conditions
-- ============================================================================
INSERT INTO WEATHER_CONDITIONS
SELECT
    'WTH' || LPAD(SEQ4(), 10, '0') AS weather_id,
    r.region_id,
    DATEADD('hour', -1 * h.hour_offset, CURRENT_TIMESTAMP()) AS observation_timestamp,
    CASE 
        WHEN MONTH(observation_timestamp) IN (12, 1, 2) THEN UNIFORM(40, 70, RANDOM())
        WHEN MONTH(observation_timestamp) IN (6, 7, 8) THEN UNIFORM(70, 105, RANDOM())
        ELSE UNIFORM(55, 85, RANDOM())
    END AS temperature_f,
    CASE 
        WHEN MONTH(observation_timestamp) IN (12, 1, 2) AND UNIFORM(0, 100, RANDOM()) < 30 THEN 'RAIN'
        WHEN MONTH(observation_timestamp) IN (11, 12, 1, 2) AND UNIFORM(0, 100, RANDOM()) < 15 THEN 'FOG'
        WHEN MONTH(observation_timestamp) IN (6, 7, 8) AND temperature_f > 95 THEN 'HOT'
        ELSE 'CLEAR'
    END AS condition,
    CASE condition
        WHEN 'RAIN' THEN (UNIFORM(10, 250, RANDOM()) / 100.0)::NUMBER(5,2)
        ELSE 0.00
    END AS precipitation_inches,
    CASE condition
        WHEN 'RAIN' THEN UNIFORM(15, 35, RANDOM())
        WHEN 'FOG' THEN UNIFORM(5, 15, RANDOM())
        ELSE UNIFORM(5, 25, RANDOM())
    END AS wind_speed_mph,
    CASE condition
        WHEN 'FOG' THEN (UNIFORM(1, 5, RANDOM()) / 10.0)::NUMBER(5,1)
        WHEN 'RAIN' THEN UNIFORM(3, 8, RANDOM())
        ELSE 10.0
    END AS visibility_miles,
    CASE condition
        WHEN 'RAIN' THEN 'WET'
        WHEN 'FOG' THEN 'REDUCED_VISIBILITY'
        ELSE 'DRY'
    END AS road_conditions,
    CASE 
        WHEN condition IN ('RAIN', 'FOG') AND UNIFORM(0, 100, RANDOM()) < 20 
        THEN condition || ' Advisory'
        WHEN temperature_f > 100 THEN 'Heat Advisory'
        ELSE NULL
    END AS weather_alert,
    observation_timestamp AS created_at
FROM SERVICE_REGIONS r
CROSS JOIN (SELECT ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1 AS hour_offset FROM TABLE(GENERATOR(ROWCOUNT => 720))) h;

-- ============================================================================
-- Step 11: Generate Predictive Scores
-- ============================================================================
INSERT INTO PREDICTIVE_SCORES
SELECT
    'SCR' || LPAD(SEQ4(), 10, '0') AS score_id,
    m.member_id,
    CURRENT_DATE() AS score_date,
    -- Breakdown risk based on vehicle age, mileage, and service history
    LEAST(100, 
        (CASE WHEN v.year < 2015 THEN 30 ELSE 10 END) +
        (CASE WHEN v.mileage > 100000 THEN 25 ELSE 5 END) +
        (CASE WHEN service_count > 5 THEN 20 ELSE 5 END) +
        UNIFORM(0, 30, RANDOM())
    )::NUMBER(5,2) AS breakdown_risk_score,
    -- Churn risk based on membership level, auto-renew, and satisfaction
    LEAST(100,
        (CASE WHEN m.is_auto_renew = FALSE THEN 40 ELSE 10 END) +
        (CASE WHEN m.membership_level = 'CLASSIC' THEN 20 ELSE 5 END) +
        (CASE WHEN DATEDIFF('day', m.membership_renewal_date, CURRENT_DATE()) < 30 THEN 25 ELSE 5 END) +
        UNIFORM(0, 20, RANDOM())
    )::NUMBER(5,2) AS churn_risk_score,
    (m.lifetime_value * (1 + UNIFORM(-20, 40, RANDOM()) / 100.0))::NUMBER(12,2) AS lifetime_value_prediction,
    GREATEST(7, UNIFORM(30, 180, RANDOM()) - (breakdown_risk_score * 1.5))::NUMBER(10,0) AS next_service_prediction_days,
    CASE 
        WHEN churn_risk_score > 70 THEN 'Urgent renewal outreach needed'
        WHEN breakdown_risk_score > 70 THEN 'Preventive maintenance reminder'
        WHEN m.membership_level = 'CLASSIC' AND service_count > 3 THEN 'Upgrade to Plus recommendation'
        ELSE 'Standard communication'
    END AS recommended_outreach,
    'ML_v2.1' AS model_version,
    CURRENT_TIMESTAMP() AS created_at
FROM MEMBERS m
JOIN VEHICLES v ON m.member_id = v.member_id AND v.is_primary_vehicle = TRUE
LEFT JOIN (
    SELECT member_id, COUNT(*) as service_count
    FROM SERVICE_REQUESTS
    WHERE request_timestamp >= DATEADD('year', -1, CURRENT_DATE())
    GROUP BY member_id
) s ON m.member_id = s.member_id
WHERE m.membership_status = 'ACTIVE';

-- ============================================================================
-- Step 12: Generate Early Warning Alerts
-- ============================================================================
INSERT INTO EARLY_WARNING_ALERTS
SELECT
    'ALT' || LPAD(SEQ4(), 10, '0') AS alert_id,
    alert_type,
    alert_severity,
    region_id,
    alert_title,
    alert_message,
    affected_services,
    metric_value,
    threshold_value,
    alert_timestamp,
    acknowledged_by,
    acknowledged_timestamp,
    resolved_timestamp,
    created_at
FROM (
    -- High demand alerts
    SELECT 
        'HIGH_DEMAND' AS alert_type,
        'HIGH' AS alert_severity,
        r.region_id,
        'High Service Demand Alert - ' || r.region_name AS alert_title,
        'Service requests in ' || r.region_name || ' are ' || demand_ratio || '% above normal. ' ||
        available_trucks || ' trucks available for ' || pending_requests || ' pending requests.' AS alert_message,
        pending_requests AS affected_services,
        current_requests AS metric_value,
        normal_requests AS threshold_value,
        DATEADD('hour', -1 * hour_offset, CURRENT_TIMESTAMP()) AS alert_timestamp,
        CASE WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN 'Dispatch Manager' ELSE NULL END AS acknowledged_by,
        CASE WHEN acknowledged_by IS NOT NULL 
             THEN DATEADD('minute', UNIFORM(5, 30, RANDOM()), alert_timestamp) 
             ELSE NULL END AS acknowledged_timestamp,
        CASE WHEN acknowledged_by IS NOT NULL AND UNIFORM(0, 100, RANDOM()) < 80
             THEN DATEADD('hour', UNIFORM(1, 4, RANDOM()), alert_timestamp)
             ELSE NULL END AS resolved_timestamp,
        alert_timestamp AS created_at
    FROM (
        SELECT 
            r.region_id,
            r.region_name,
            UNIFORM(50, 150, RANDOM()) AS current_requests,
            40 AS normal_requests,
            ROUND((current_requests - normal_requests) * 100.0 / normal_requests) AS demand_ratio,
            UNIFORM(5, 25, RANDOM()) AS available_trucks,
            UNIFORM(10, 40, RANDOM()) AS pending_requests,
            h.hour_offset
        FROM SERVICE_REGIONS r
        CROSS JOIN (SELECT UNIFORM(0, 168, RANDOM()) AS hour_offset FROM TABLE(GENERATOR(ROWCOUNT => 20))) h
        WHERE demand_ratio > 25
    )
    
    UNION ALL
    
    -- Weather alerts
    SELECT
        'WEATHER_IMPACT' AS alert_type,
        CASE WHEN condition IN ('FOG', 'RAIN') THEN 'MEDIUM' ELSE 'LOW' END AS alert_severity,
        r.region_id,
        'Weather Advisory - ' || r.region_name AS alert_title,
        'Current conditions: ' || condition || '. Expected ' || 
        CASE condition 
            WHEN 'RAIN' THEN '30% increase in service calls'
            WHEN 'FOG' THEN '25% increase in highway incidents'
            WHEN 'HOT' THEN '40% increase in battery/cooling issues'
        END AS alert_message,
        0 AS affected_services,
        0 AS metric_value,
        0 AS threshold_value,
        DATEADD('hour', -1 * UNIFORM(0, 48, RANDOM()), CURRENT_TIMESTAMP()) AS alert_timestamp,
        NULL AS acknowledged_by,
        NULL AS acknowledged_timestamp,
        NULL AS resolved_timestamp,
        alert_timestamp AS created_at
    FROM WEATHER_CONDITIONS w
    JOIN SERVICE_REGIONS r ON w.region_id = r.region_id
    WHERE w.weather_alert IS NOT NULL
    AND UNIFORM(0, 100, RANDOM()) < 20
    LIMIT 100
)
WHERE alert_timestamp >= DATEADD('day', -30, CURRENT_DATE());

-- ============================================================================
-- Display summary statistics
-- ============================================================================
SELECT 'Data generation completed successfully' AS status;

SELECT 'MEMBERS' AS table_name, COUNT(*) AS row_count FROM MEMBERS
UNION ALL
SELECT 'VEHICLES', COUNT(*) FROM VEHICLES
UNION ALL
SELECT 'SERVICE_REQUESTS', COUNT(*) FROM SERVICE_REQUESTS
UNION ALL
SELECT 'SERVICE_FULFILLMENT', COUNT(*) FROM SERVICE_FULFILLMENT
UNION ALL
SELECT 'SERVICE_TECHNICIANS', COUNT(*) FROM SERVICE_TECHNICIANS
UNION ALL
SELECT 'SERVICE_TRUCKS', COUNT(*) FROM SERVICE_TRUCKS
UNION ALL
SELECT 'SERVICE_REGIONS', COUNT(*) FROM SERVICE_REGIONS
UNION ALL
SELECT 'MEMBER_TRANSACTIONS', COUNT(*) FROM MEMBER_TRANSACTIONS
UNION ALL
SELECT 'WEATHER_CONDITIONS', COUNT(*) FROM WEATHER_CONDITIONS
UNION ALL
SELECT 'PREDICTIVE_SCORES', COUNT(*) FROM PREDICTIVE_SCORES
UNION ALL
SELECT 'EARLY_WARNING_ALERTS', COUNT(*) FROM EARLY_WARNING_ALERTS
ORDER BY table_name;
