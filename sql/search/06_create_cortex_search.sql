-- ============================================================================
-- AAA Intelligence Agent - Cortex Search Service Setup
-- ============================================================================
-- Purpose: Create unstructured data tables and Cortex Search services for
--          service notes, member feedback, and incident reports
-- Syntax verified against: https://docs.snowflake.com/en/sql-reference/sql/create-cortex-search
-- ============================================================================

USE DATABASE AAA_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE AAA_WH;

-- ============================================================================
-- Step 1: Create table for service notes (unstructured text data)
-- ============================================================================
CREATE OR REPLACE TABLE SERVICE_NOTES (
    note_id VARCHAR(30) PRIMARY KEY,
    service_id VARCHAR(30),
    technician_id VARCHAR(20),
    member_id VARCHAR(20),
    note_text VARCHAR(16777216) NOT NULL,
    note_type VARCHAR(50),
    service_type VARCHAR(50),
    note_date TIMESTAMP_NTZ NOT NULL,
    severity VARCHAR(20),
    vehicle_make VARCHAR(50),
    vehicle_model VARCHAR(50),
    location_type VARCHAR(30),
    weather_condition VARCHAR(30),
    keywords VARCHAR(500),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (service_id) REFERENCES SERVICE_REQUESTS(service_id),
    FOREIGN KEY (technician_id) REFERENCES SERVICE_TECHNICIANS(technician_id),
    FOREIGN KEY (member_id) REFERENCES MEMBERS(member_id)
);

-- ============================================================================
-- Step 2: Create table for member feedback
-- ============================================================================
CREATE OR REPLACE TABLE MEMBER_FEEDBACK (
    feedback_id VARCHAR(30) PRIMARY KEY,
    member_id VARCHAR(20),
    service_id VARCHAR(30),
    feedback_text VARCHAR(16777216) NOT NULL,
    satisfaction_score NUMBER(1),
    feedback_category VARCHAR(50),
    feedback_date TIMESTAMP_NTZ NOT NULL,
    service_type VARCHAR(50),
    technician_id VARCHAR(20),
    response_time_rating VARCHAR(20),
    would_recommend BOOLEAN,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (member_id) REFERENCES MEMBERS(member_id),
    FOREIGN KEY (service_id) REFERENCES SERVICE_REQUESTS(service_id)
);

-- ============================================================================
-- Step 3: Create table for incident reports
-- ============================================================================
CREATE OR REPLACE TABLE INCIDENT_REPORTS (
    incident_id VARCHAR(30) PRIMARY KEY,
    incident_description VARCHAR(16777216) NOT NULL,
    incident_type VARCHAR(50),
    severity VARCHAR(20),
    service_region VARCHAR(50),
    incident_date TIMESTAMP_NTZ NOT NULL,
    location_description VARCHAR(500),
    weather_conditions VARCHAR(100),
    vehicles_involved NUMBER(3),
    injuries_reported BOOLEAN,
    police_report_number VARCHAR(50),
    insurance_claim_number VARCHAR(50),
    resolution_status VARCHAR(30),
    created_by VARCHAR(100),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- Step 4: Enable change tracking (required for Cortex Search)
-- ============================================================================
ALTER TABLE SERVICE_NOTES SET CHANGE_TRACKING = TRUE;
ALTER TABLE MEMBER_FEEDBACK SET CHANGE_TRACKING = TRUE;
ALTER TABLE INCIDENT_REPORTS SET CHANGE_TRACKING = TRUE;

-- ============================================================================
-- Step 5: Generate sample service notes
-- ============================================================================
INSERT INTO SERVICE_NOTES
SELECT
    'NOTE' || LPAD(SEQ4(), 10, '0') AS note_id,
    sf.service_id,
    sf.technician_id,
    sr.member_id,
    CASE (ABS(RANDOM()) % 20)
        WHEN 0 THEN 'Arrived at scene. Member waiting safely in vehicle. ' || v.year || ' ' || v.make || ' ' || v.model || ' with dead battery. Performed jump start procedure. Battery tested at 11.2V, below minimum threshold. Recommended battery replacement within 30 days. Vehicle started successfully after jump. Member advised to drive for at least 20 minutes to charge battery. Provided list of AAA approved battery service centers.'
        WHEN 1 THEN 'Highway shoulder assistance. Member had blowout on front passenger tire. Safely positioned service truck with emergency lights. Used safety cones to secure work area. Tire sidewall completely separated - not repairable. Installed spare tire (compact donut type). Advised member that spare is rated for 50mph maximum and should be replaced with full-size tire immediately. Checked other tires - all showing normal wear.'
        WHEN 2 THEN 'Lockout service completed. Member locked keys in ' || v.year || ' ' || v.make || ' ' || v.model || '. Used wedge and long reach tool to unlock driver door. No damage to weather stripping or door frame. Verified all doors now functioning properly. Suggested member consider hide-a-key or spare key service. Vehicle alarm did not activate during service.'
        WHEN 3 THEN 'Towing service. Vehicle would not start - appears to be starter motor failure based on clicking sound. Member opted for tow to dealer service department (15.3 miles). Secured vehicle on flatbed using 4-point tie-down system. No visible damage to vehicle. Member rode in tow truck to destination. Dealer confirmed receipt of vehicle.'
        WHEN 4 THEN 'Fuel delivery completed. Member ran out of gas on city street. Delivered 2 gallons of regular unleaded gasoline. Vehicle started immediately after refueling. Escorted member to nearest gas station (1.2 miles) to ensure safe arrival. Reminded member about AAA mobile app feature for locating gas stations.'
        WHEN 5 THEN 'Battery service on ' || v.make || ' ' || v.model || '. Battery tested at 10.8V and failed load test. Symptoms: slow cranking for past week, dashboard lights dimming. Replaced with new battery (Group Size ' || ARRAY_CONSTRUCT('24F', '35', '48', '65')[UNIFORM(0, 3, RANDOM())] || '). Properly disposed of old battery. Reset radio presets and clock for member. Battery registration completed for vehicle computer.'
        WHEN 6 THEN 'Tire change in parking garage. Limited clearance made positioning difficult. Member had picked up nail in rear driver tire - slow leak. Installed full-size spare from trunk. Inspected punctured tire - nail in tread area, repairable. Recommended tire repair shop 2 miles away. Checked tire pressure in all tires including spare.'
        WHEN 7 THEN 'Emergency towing from accident scene. Minor rear-end collision, vehicle driveable but member uncomfortable driving with damaged bumper. No injuries reported. Police report #' || UNIFORM(100000, 999999, RANDOM()) || ' filed. Towed to member preferred body shop. Took photos of damage for member insurance claim. Advised member to contact insurance immediately.'
        WHEN 8 THEN 'Jump start attempt unsuccessful. ' || v.year || ' ' || v.make || ' ' || v.model || ' would not start even with jump. Suspected alternator failure - battery not holding charge. Member approved tow to AAA approved repair facility. Shop later confirmed alternator replacement needed. Member grateful for diagnosis assistance.'
        WHEN 9 THEN 'Lockout service - keys visible on driver seat. Used lockout tool kit to gain entry through passenger window. Slight gap in window seal allowed tool insertion. Successfully retrieved keys without any damage. Member mentioned this was second lockout this year - suggested keyless entry upgrade options.'
        WHEN 10 THEN 'Flat tire service on freeway. Safely moved vehicle to wide shoulder. Used electronic arrow board on service truck for traffic safety. Front driver tire had large sidewall bubble - unsafe to drive. Installed compact spare. Escorted member to next exit for safety. Tire shop found internal belt separation - warranty replacement qualified.'
        WHEN 11 THEN 'Responded to overheating vehicle. ' || v.make || ' ' || v.model || ' with steam from hood. Let engine cool for 20 minutes before inspection. Found coolant reservoir empty and radiator low. Small leak visible at lower radiator hose. Added coolant and stop-leak as temporary measure. Followed member to repair shop (3 miles) - vehicle temperature remained normal.'
        WHEN 12 THEN 'Battery jump in shopping center parking lot. Interior lights left on for approximately 4 hours. Battery voltage at 11.5V. Successfully jump started on first attempt. Let vehicle run for 10 minutes to ensure stable charge. Tested battery - showing good health just discharged. No replacement needed at this time.'
        WHEN 13 THEN 'Towing service for transmission failure. Member reported vehicle stuck in park. Unable to shift even with override. Loaded onto flatbed using winch due to locked wheels. Transported to transmission specialist shop. Member mentioned hearing grinding noises for past week. Provided receipt for insurance purposes.'
        WHEN 14 THEN 'Lockout at members residence. Keys locked in running vehicle with AC on. Pet (small dog) inside vehicle. Expedited service due to animal safety. Successfully unlocked through rear passenger window. No damage to vehicle. Pet was alert and healthy. Member very appreciative of quick response.'
        WHEN 15 THEN 'Tire change service - multiple tire damage. Member hit debris on highway causing damage to both driver side tires. Only one spare available. Installed spare on front, moved rear tire to front position. Arranged secondary tow truck for transport to tire shop. Coordinated with dispatch for priority service. Member safely transported.'
        WHEN 16 THEN 'Fuel system issue - bad gas suspected. Vehicle running rough after recent fill-up. Added fuel system cleaner and premium gas to dilute potential water contamination. Engine smoothed out after 10 minutes. Recommended fuel filter replacement and tank inspection. Provided receipt from gas station for member reference.'
        WHEN 17 THEN 'Jump start in residential area. ' || v.year || ' ' || v.make || ' ' || v.model || ' with aftermarket alarm system. Alarm draining battery when armed. Successfully jumped vehicle but alarm immediately activated. Used master reset procedure to disable alarm. Recommended alarm system inspection by installer. Battery tested good once alarm disabled.'
        WHEN 18 THEN 'Complex lockout - electronic locks malfunctioned. Key fob not working and physical key would not turn in door lock. Gained entry through rear hatch manual release. Found main battery terminal loose causing electrical issues. Tightened terminal and all systems restored. Key fob programmed successfully. Advised battery terminal inspection at next service.'
        WHEN 19 THEN 'Off-road recovery service. Member stuck in soft sand attempting to reach beach parking. Used traction boards and winch for recovery. No damage to vehicle undercarriage inspected. Aired down tires to 20PSI for better traction. Escorted member back to paved road. Re-inflated tires to proper pressure. Provided tips for beach driving.'
    END AS note_text,
    ARRAY_CONSTRUCT('SERVICE_COMPLETION', 'TECHNICAL_OBSERVATION', 'SAFETY_NOTE', 'FOLLOW_UP_NEEDED', 'INCIDENT_DETAIL')[UNIFORM(0, 4, RANDOM())] AS note_type,
    sr.service_type,
    sf.arrival_timestamp AS note_date,
    CASE 
        WHEN sr.priority = 'HIGH' OR sr.location_type = 'HIGHWAY' THEN 'HIGH'
        WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS severity,
    v.make AS vehicle_make,
    v.model AS vehicle_model,
    sr.location_type,
    sr.weather_condition,
    CASE sr.service_type
        WHEN 'BATTERY_JUMP' THEN 'battery,jump start,electrical'
        WHEN 'FLAT_TIRE' THEN 'tire,flat,spare,puncture'
        WHEN 'LOCKOUT' THEN 'keys,locked,entry,locksmith'
        WHEN 'TOWING' THEN 'tow,breakdown,transport'
        WHEN 'FUEL_DELIVERY' THEN 'gas,fuel,empty,delivery'
        ELSE 'service,assistance,help'
    END AS keywords,
    sf.arrival_timestamp AS created_at
FROM RAW.SERVICE_FULFILLMENT sf
JOIN RAW.SERVICE_REQUESTS sr ON sf.service_id = sr.service_id
JOIN RAW.VEHICLES v ON sr.vehicle_id = v.vehicle_id
WHERE sf.technician_notes IS NOT NULL OR UNIFORM(0, 100, RANDOM()) < 25
LIMIT 500000;

-- ============================================================================
-- Step 6: Generate sample member feedback
-- ============================================================================
INSERT INTO MEMBER_FEEDBACK
SELECT
    'FDBK' || LPAD(SEQ4(), 10, '0') AS feedback_id,
    sr.member_id,
    sr.service_id,
    CASE (ABS(RANDOM()) % 20)
        WHEN 0 THEN 'Excellent service! The technician arrived in under 30 minutes and was very professional. He explained everything he was doing and made sure my car was running properly before leaving. This is why I maintain my AAA membership year after year. Thank you!'
        WHEN 1 THEN 'Good response time but the technician seemed rushed. He got my tire changed quickly but did not check the pressure in my other tires or offer any advice about where to get the flat repaired. Service was adequate but could have been more thorough.'
        WHEN 2 THEN 'Outstanding experience from start to finish. The dispatcher was helpful and kept me informed of the technician arrival time. The driver was courteous, knowledgeable, and went above and beyond by following me to the tire shop to make sure I arrived safely. Five stars!'
        WHEN 3 THEN 'Waited over an hour for service on a busy Friday night. I understand delays happen but better communication about wait times would have been appreciated. The technician was apologetic and did a good job once he arrived. Battery jump was successful.'
        WHEN 4 THEN 'This is the third time I have used AAA this year and each experience has been positive. Today lockout service was completed in 20 minutes. The technician was careful not to damage my car and even showed me how to use the hide-a-key box he recommended.'
        WHEN 5 THEN 'Disappointed with the service. Technician arrived late and seemed unfamiliar with my vehicle make. Took three attempts to jump start the battery. Eventually successful but the whole experience took much longer than necessary. Hope for better service next time.'
        WHEN 6 THEN 'Cannot say enough good things about your technician Mike. He was professional, friendly, and really knew his stuff. Fixed my flat tire in the rain without complaint and made sure I knew where to go for a replacement. AAA is lucky to have employees like him!'
        WHEN 7 THEN 'Service was fine but I was charged for towing beyond my coverage limit. The dispatcher did not make this clear when I called. The driver was helpful but the unexpected charge was frustrating. Please improve communication about coverage limits upfront.'
        WHEN 8 THEN 'Impressed by the quick response time - only 18 minutes! The fuel delivery service saved my day. Driver was professional and reminded me about keeping an emergency gas can. Will definitely recommend AAA to friends and family. Worth every penny of membership.'
        WHEN 9 THEN 'Mixed experience today. Technician was 45 minutes late but called to update me. Once arrived, lockout service was completed quickly and professionally. I appreciate the communication but wish the initial time estimate had been more accurate. Overall satisfied.'
        WHEN 10 THEN 'Exceptional service during a stressful situation. My car broke down on the highway at night. The technician arrived quickly, made sure I was safe, and efficiently towed my car to the repair shop. His calm demeanor really helped reduce my anxiety. Thank you AAA!'
        WHEN 11 THEN 'Basic service, nothing special. Tire was changed, spare was installed, job done. Technician was quiet and did not offer any advice about tire repair options. Would have appreciated more interaction and guidance, especially since I am not car-savvy.'
        WHEN 12 THEN 'Five star experience! Technician diagnosed the problem (alternator not battery) and saved me from buying unnecessary new battery. Towed to reliable repair shop he recommended. This kind of honest, knowledgeable service is why I have been AAA member for 20 years.'
        WHEN 13 THEN 'Service completed but technician left a mess. Oil spots on my driveway from his equipment and did not clean up packaging from new battery. Battery installation was done correctly but attention to detail was lacking. Please remind technicians to clean up after service.'
        WHEN 14 THEN 'Wonderful experience with AAA today. Elderly mother locked keys in car at doctors office. Dispatcher marked as priority due to her age. Technician arrived in 15 minutes, was respectful and patient with her. Opened car without any damage. Grateful for compassionate service.'
        WHEN 15 THEN 'Frustrated with repeated issues. This is second time needing jump start this month. Technician suggested battery replacement last time but did not have right size. Today different technician said battery is fine. Getting conflicting information. Need consistent diagnosis please.'
        WHEN 16 THEN 'Above and beyond service! Technician noticed my brake lights were not working while loading car for tow. He checked and replaced the fuse at no charge. This prevented potential safety issue and traffic ticket. Extremely grateful for his attention to detail!'
        WHEN 17 THEN 'Long wait time (90 minutes) but understood due to bad weather causing many accidents. Technician apologized for delay and was very thorough with service. Changed tire in heavy rain, checked all other tires, and made sure spare was secure. Professional despite conditions.'
        WHEN 18 THEN 'Quick and efficient service. Fuel delivery completed in under 25 minutes from call time. Driver was friendly and provided tips about fuel gauge accuracy in older vehicles. Followed me to gas station to ensure no further issues. Excellent customer service throughout.'
        WHEN 19 THEN 'Disappointed that technician could not fix the problem. Jump start attempts failed and had to tow. However, he explained likely causes and recommended good repair shop. While not the outcome I wanted, I appreciated his honesty and expertise. Will use AAA again.'
    END AS feedback_text,
    sf.member_satisfaction_score AS satisfaction_score,
    CASE 
        WHEN sf.member_satisfaction_score >= 4 THEN 'POSITIVE'
        WHEN sf.member_satisfaction_score >= 3 THEN 'NEUTRAL'
        ELSE 'NEGATIVE'
    END AS feedback_category,
    DATEADD('day', UNIFORM(1, 7, RANDOM()), sf.completion_timestamp) AS feedback_date,
    sr.service_type,
    sf.technician_id,
    CASE 
        WHEN sf.response_time_minutes <= 30 THEN 'EXCELLENT'
        WHEN sf.response_time_minutes <= 45 THEN 'GOOD'
        WHEN sf.response_time_minutes <= 60 THEN 'FAIR'
        ELSE 'POOR'
    END AS response_time_rating,
    sf.member_satisfaction_score >= 4 AS would_recommend,
    feedback_date AS created_at
FROM RAW.SERVICE_REQUESTS sr
JOIN RAW.SERVICE_FULFILLMENT sf ON sr.service_id = sf.service_id
WHERE sf.member_satisfaction_score IS NOT NULL
    AND UNIFORM(0, 100, RANDOM()) < 20
LIMIT 100000;

-- ============================================================================
-- Step 7: Generate sample incident reports
-- ============================================================================
INSERT INTO INCIDENT_REPORTS
SELECT
    'INC' || LPAD(SEQ4(), 10, '0') AS incident_id,
    CASE (ABS(RANDOM()) % 15)
        WHEN 0 THEN 'Multi-vehicle accident on I-5 southbound near Exit 142. Heavy fog conditions with visibility under 100 feet. Responded to assist 3 AAA members involved. Vehicles included 2018 Honda Civic (member 1), 2020 Toyota Camry (member 2), and 2019 Ford F-150 (member 3). CHP on scene handling traffic control. All vehicles required towing. No major injuries reported but member 2 complained of neck pain and was transported by ambulance for evaluation. Coordinated with three different tow trucks for simultaneous removal. Scene cleared after 2 hours.'
        WHEN 1 THEN 'Service truck accident while responding to call. Technician hydroplaned on wet road during heavy rain storm. Truck slid into guardrail causing minor damage to front bumper and right fender. No injuries to technician. Truck driveable but removed from service for inspection. Member call reassigned to another unit. Incident reported to fleet management and insurance. Drug/alcohol test completed per company policy - negative results. Technician reminded about safe driving in adverse weather conditions.'
        WHEN 2 THEN 'Member vehicle caught fire during jump start attempt. 2015 BMW 328i with aftermarket electronics. When jumper cables connected, sparks observed near battery terminal followed by smoke from engine compartment. Technician immediately disconnected cables and used fire extinguisher to suppress small electrical fire. Fire department responded as precaution. No injuries but vehicle electrical system damaged. Insurance claim initiated. Investigation revealed improper installation of aftermarket amplifier causing short circuit.'
        WHEN 3 THEN 'Technician injured during tire change. While removing lug nuts, wrench slipped causing technician to fall backward and strike head on pavement. Technician experienced dizziness and was transported to urgent care. Diagnosed with mild concussion. Workers compensation claim filed. Review of incident revealed lug nuts were over-torqued and wrench was worn. Safety reminder issued about proper tool inspection and body positioning. Technician returned to work after 3 days rest.'
        WHEN 4 THEN 'Vehicle rolled off flatbed during loading. 2019 Tesla Model 3 with dead battery being loaded for tow. Parking brake apparently not fully engaged. Vehicle rolled backward off ramp causing damage to rear bumper and quarter panel. No injuries occurred as area was cleared. Member understandably upset. Full documentation provided for insurance claim. Tow truck driver retrained on proper securing procedures especially for electric vehicles with electronic parking brakes.'
        WHEN 5 THEN 'Confrontation with aggressive member during service. Member became verbally abusive when informed vehicle needed towing instead of jump start. Threatened technician and threw tools from truck. Police called to scene. Member calmed down when officers arrived. Service completed under police supervision. Incident reported to management. Members account flagged for review. Technician offered counseling support. Body camera footage saved for documentation.'
        WHEN 6 THEN 'Fuel spill during delivery service. While dispensing fuel, member grabbed nozzle causing approximately 1 gallon of gasoline to spill on roadway. Technician immediately deployed absorbent materials and contacted hazmat for cleanup. Area cordoned off to prevent ignition sources. Fire department responded and supervised cleanup. No injuries or environmental damage. Member educated about safety procedures during fuel delivery. Incident reported to environmental compliance.'
        WHEN 7 THEN 'Wrong vehicle towed from apartment complex. Dispatcher provided incorrect apartment number. Technician towed silver Honda Accord as directed but belonged to different resident. Error discovered when correct member called asking about service. Vehicle immediately returned to apartment complex. Apology issued to vehicle owner. No damage occurred. Dispatcher counseled on importance of verifying complete address information. Process updated to require license plate confirmation.'
        WHEN 8 THEN 'Service truck struck by passing vehicle. Technician changing tire on highway shoulder when drunk driver sideswiped truck. Technician jumped to safety avoiding injury. Significant damage to truck and equipment. Member vehicle undamaged. Police arrested other driver for DUI. Technician treated for minor scrapes and shock. Truck totaled and replaced. Safety review emphasized importance of proper positioning and emergency lighting. Technician commended for quick reflexes.'
        WHEN 9 THEN 'Battery explosion during installation. Technician installing new battery in 2016 Chevrolet Malibu. When connecting positive terminal, battery exploded sending acid spray. Technician wearing safety glasses avoided eye injury but suffered minor burns on hands. Immediately flushed with water from truck. Transported to ER for treatment. Investigation found defective battery with internal short. Battery manufacturer accepted liability. Technician fully recovered and returned to work.'
        WHEN 10 THEN 'Member medical emergency during service. While waiting for tire change, elderly member complained of chest pain and shortness of breath. Technician immediately called 911 and kept member calm. Administered oxygen from truck emergency kit. Paramedics arrived and transported member to hospital. Family later reported member had mild heart attack but recovered. Technician quick action praised by family and medical staff. Commendation added to employee file.'
        WHEN 11 THEN 'Tow truck rollover accident. Technician transporting vehicle on winding mountain road. Took curve too fast causing truck and towed vehicle to overturn. Technician sustained broken ribs and lacerations. Airlifted to trauma center. Towed vehicle total loss. Investigation revealed speed was factor along with improperly secured load. Technician recovered after surgery. Mandatory retraining implemented for all drivers on mountain driving and load securing procedures.'
        WHEN 12 THEN 'Dog bite incident during lockout service. Member failed to mention aggressive dog in vehicle. When door opened, German Shepherd bit technician on forearm causing deep puncture wounds. Technician received immediate medical treatment and tetanus shot. Dog quarantined for rabies observation. Workers comp claim filed. New policy implemented requiring members to disclose presence of animals in vehicle. Technician returned to work with no complications.'
        WHEN 13 THEN 'Carbon monoxide exposure in parking garage. Technician performing jump start in underground parking with poor ventilation. After 20 minutes began feeling dizzy and nauseous. Recognized symptoms and immediately exited garage. Called for backup and medical evaluation. Diagnosed with mild CO poisoning. Treated with oxygen and released. Safety bulletin issued about ventilation awareness. CO detectors now standard equipment on all service trucks.'
        WHEN 14 THEN 'Equipment failure caused vehicle damage. Hydraulic failure on flatbed caused vehicle to slide sideways into truck rail. 2021 Mercedes-Benz C300 suffered scratches and dent on passenger door. Member extremely upset about damage to new vehicle. Full photo documentation taken. Insurance claim processed immediately. Member provided rental car at company expense. Vehicle repaired at authorized dealer. Flatbed truck removed from service pending hydraulic system overhaul. Preventive maintenance schedule reviewed.'
    END AS incident_description,
    ARRAY_CONSTRUCT('ACCIDENT', 'INJURY', 'EQUIPMENT_FAILURE', 'CUSTOMER_COMPLAINT', 'VEHICLE_DAMAGE', 'SAFETY_VIOLATION', 'ENVIRONMENTAL')[UNIFORM(0, 6, RANDOM())] AS incident_type,
    ARRAY_CONSTRUCT('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')[UNIFORM(0, 3, RANDOM())] AS severity,
    reg.region_name AS service_region,
    DATEADD('day', -1 * UNIFORM(0, 365, RANDOM()), CURRENT_TIMESTAMP()) AS incident_date,
    CASE (ABS(RANDOM()) % 5)
        WHEN 0 THEN 'Highway ' || UNIFORM(1, 999, RANDOM()) || ' near mile marker ' || UNIFORM(1, 200, RANDOM())
        WHEN 1 THEN 'Parking lot at ' || UNIFORM(100, 9999, RANDOM()) || ' Main Street'
        WHEN 2 THEN 'Residential area - ' || UNIFORM(100, 9999, RANDOM()) || ' Oak Avenue'
        WHEN 3 THEN 'Downtown ' || reg.region_name || ' business district'
        ELSE 'Rural road - County Route ' || UNIFORM(1, 99, RANDOM())
    END AS location_description,
    ARRAY_CONSTRUCT('Clear', 'Rain', 'Fog', 'Snow', 'High winds')[UNIFORM(0, 4, RANDOM())] AS weather_conditions,
    CASE incident_type 
        WHEN 'ACCIDENT' THEN UNIFORM(2, 5, RANDOM())
        ELSE 1
    END AS vehicles_involved,
    UNIFORM(0, 100, RANDOM()) < 15 AS injuries_reported,
    CASE WHEN incident_type = 'ACCIDENT' THEN 'CHP-' || UNIFORM(100000, 999999, RANDOM()) ELSE NULL END AS police_report_number,
    CASE WHEN severity IN ('HIGH', 'CRITICAL') THEN 'CLM-' || UNIFORM(100000, 999999, RANDOM()) ELSE NULL END AS insurance_claim_number,
    CASE 
        WHEN UNIFORM(0, 100, RANDOM()) < 70 THEN 'RESOLVED'
        WHEN UNIFORM(0, 100, RANDOM()) < 90 THEN 'PENDING'
        ELSE 'UNDER_INVESTIGATION'
    END AS resolution_status,
    'Safety Manager' AS created_by,
    incident_date AS created_at
FROM RAW.SERVICE_REGIONS reg
CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 5000));

-- ============================================================================
-- Step 8: Create Cortex Search Service for Service Notes
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE SERVICE_NOTES_SEARCH
  ON note_text
  ATTRIBUTES note_id, service_id, technician_id, member_id, note_type, service_type, note_date, severity
  WAREHOUSE = AAA_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Cortex Search service for service technician notes - enables semantic search across service documentation'
AS
  SELECT
    note_id,
    note_text,
    service_id,
    technician_id,
    member_id,
    note_type,
    service_type,
    note_date,
    severity,
    vehicle_make,
    vehicle_model,
    location_type,
    weather_condition,
    keywords,
    created_at
  FROM RAW.SERVICE_NOTES;

-- ============================================================================
-- Step 9: Create Cortex Search Service for Member Feedback
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE MEMBER_FEEDBACK_SEARCH
  ON feedback_text
  ATTRIBUTES feedback_id, member_id, service_id, satisfaction_score, feedback_category, feedback_date
  WAREHOUSE = AAA_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Cortex Search service for member feedback - enables semantic search across customer feedback and reviews'
AS
  SELECT
    feedback_id,
    feedback_text,
    member_id,
    service_id,
    satisfaction_score,
    feedback_category,
    feedback_date,
    service_type,
    technician_id,
    response_time_rating,
    would_recommend,
    created_at
  FROM RAW.MEMBER_FEEDBACK;

-- ============================================================================
-- Step 10: Create Cortex Search Service for Incident Reports
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE INCIDENT_REPORTS_SEARCH
  ON incident_description
  ATTRIBUTES incident_id, incident_type, severity, service_region, incident_date, resolution_status
  WAREHOUSE = AAA_WH
  TARGET_LAG = '24 hours'
  COMMENT = 'Cortex Search service for incident reports - enables semantic search across safety incidents and accident reports'
AS
  SELECT
    incident_id,
    incident_description,
    incident_type,
    severity,
    service_region,
    incident_date,
    location_description,
    weather_conditions,
    vehicles_involved,
    injuries_reported,
    police_report_number,
    insurance_claim_number,
    resolution_status,
    created_by,
    created_at
  FROM RAW.INCIDENT_REPORTS;

-- ============================================================================
-- Step 11: Verify Cortex Search Services Created
-- ============================================================================
SHOW CORTEX SEARCH SERVICES IN SCHEMA RAW;

-- ============================================================================
-- Display success message
-- ============================================================================
SELECT 'Cortex Search services created successfully' AS status,
       COUNT(*) AS service_count
FROM (
  SELECT 'SERVICE_NOTES_SEARCH' AS service_name
  UNION ALL
  SELECT 'MEMBER_FEEDBACK_SEARCH'
  UNION ALL
  SELECT 'INCIDENT_REPORTS_SEARCH'
);

-- ============================================================================
-- Display data counts
-- ============================================================================
SELECT 'SERVICE_NOTES' AS table_name, COUNT(*) AS row_count FROM SERVICE_NOTES
UNION ALL
SELECT 'MEMBER_FEEDBACK', COUNT(*) FROM MEMBER_FEEDBACK
UNION ALL
SELECT 'INCIDENT_REPORTS', COUNT(*) FROM INCIDENT_REPORTS
ORDER BY table_name;
