-- CREATE DATABASE IF NOT EXISTS mydb;
-- USE mydb;
CREATE DATABASE IF NOT EXISTS demoDb;
use demoDb;
-- FOR Station detail
CREATE TABLE StationLocation (
    station_id INT PRIMARY KEY,
    stationname VARCHAR(20) NOT NULL,
    statename VARCHAR(20) NOT NULL,
    Divisionname VARCHAR(20) NOT NULL
);


-- Applicant table
CREATE TABLE Applicant (
    applicant_id INT PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    mobile_number VARCHAR(10) NOT NULL,
    aadhar_id VARCHAR(12),  -- not required, delete
    date_of_birth DATE NOT NULL,
    gender VARCHAR(6) NOT NULL,
    address VARCHAR(25),
    pin_code VARCHAR(6),
    city VARCHAR(20),
    statename VARCHAR(20),
    station_id INT,
    disability_type_id varchar(100),
    registration_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('submitting, draft'),
    FOREIGN KEY (station_id) REFERENCES StationLocation(station_id)
);

-- USER (renamed to Railwayuser to avoid conflict with MySQL reserved word USER)
CREATE TABLE Railwayuser (
    user_id INT PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    mobile_number VARCHAR(15) NOT NULL,
    email VARCHAR(50) NOT NULL,
    user_role ENUM('division_user', 'cmi', 'cis') NOT NULL,
    division_id INT,
    statename VARCHAR(20),
    station_id INT,
    FOREIGN KEY (station_id) REFERENCES StationLocation(station_id)
);

CREATE TABLE Application (
    application_id INT PRIMARY KEY,
    applicant_id INT NOT NULL,
    submission_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('submitted', 'assigned_doctor', 'assigned_station', 'rejected', 'transferred', 'issued'), -- should just be submitted, approved and assigned, rejected
    current_division_id INT NOT NULL,
    current_division_user_id INT NOT NULL, -- not required here, move to applicationlog table
    current_cmi_id INT, -- not required here, move to applicationlog table
    current_cis_id INT, -- not required here, move to applicationlog table
    card_number VARCHAR(20),
    card_issue_date DATE,
    Authorname VARCHAR(255), -- dont remember what this is
    FOREIGN KEY (applicant_id) REFERENCES Applicant(applicant_id),
    FOREIGN KEY (current_cmi_id) REFERENCES Railwayuser(user_id),
    FOREIGN KEY (current_cis_id) REFERENCES Railwayuser(user_id)
);

-- DOCUMENT ------------------------------------------------------------------------------to be implemented at end----------------------------------------------------------------
CREATE TABLE Document (
    document_id INT PRIMARY KEY,
    applicant_id INT NOT NULL,
    application_id INT NOT NULL,
    document_type ENUM(
        'disability_certificate',
        'railway_concession_certificate',
        'photo',
        'dob_proof',
        'photo_id_proof',
        'address_proof'
    ) NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    upload_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    Authorname VARCHAR(255),
    FOREIGN KEY (application_id) REFERENCES Application(application_id),
    FOREIGN KEY (applicant_id) REFERENCES Applicant(applicant_id)
);
-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- DISABILITY CERTIFICATE
CREATE TABLE DisabilityCertificate (
    certificate_id INT PRIMARY KEY,
    application_id INT NOT NULL,
    doctor_name VARCHAR(100),
    doctor_reg_no VARCHAR(50),
    hospital_name VARCHAR(150),
    hospital_city VARCHAR(100),
    Hospital_state VARCHAR(255),
    issue_date DATE NOT NULL,
    FOREIGN KEY (application_id) REFERENCES Application(application_id)
);

-- ========================================================================= needs rework =====================================================================
CREATE TABLE ApplicationLog (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL,
    action_by_user_id INT NOT NULL,
    user_role ENUM('division_user', 'cmi', 'cis') NOT NULL,
    
    action_type ENUM(
        'assign_doctor', 'assign_station', 'transfer_division', 
        'transfer_doctor', 'reject', 'issue_card', 
        'assigned', 'transferred', 'verified', 'approved'
    ) NOT NULL,
    
    status ENUM('pending', 'approved', 'rejected') DEFAULT NULL,
    target_station_id INT DEFAULT NULL,
    comments TEXT,
    action_date DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (application_id) REFERENCES Application(application_id),
    FOREIGN KEY (action_by_user_id) REFERENCES Railwayuser(user_id),
    FOREIGN KEY (target_station_id) REFERENCES StationLocation(station_id)
);
-- ===========================================================================================================================================================