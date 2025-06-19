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

-- Create DisabilityType table (referenced but missing)
CREATE TABLE DisabilityType (
    disability_type_id INT PRIMARY KEY,
    disability_name VARCHAR(50) NOT NULL,
    description TEXT
);

-- Applicant table
CREATE TABLE Applicant (
    applicant_id INT PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    phone_number VARCHAR(10) NOT NULL,
    aadhar_id VARCHAR(12),
    date_of_birth DATE NOT NULL,
    gender VARCHAR(6) NOT NULL,
    address VARCHAR(25) NOT NULL,
    pin_code VARCHAR(6) NOT NULL,
    city VARCHAR(20) NOT NULL,
    state_id INT,
    station_id INT,
    disability_type_id INT,
    registration_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (station_id) REFERENCES StationLocation(station_id),
    FOREIGN KEY (disability_type_id) REFERENCES DisabilityType(disability_type_id)
);

-- USER (renamed to Railwayuser to avoid conflict with MySQL reserved word USER)
CREATE TABLE Railwayuser (
    user_id INT PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    email VARCHAR(50) NOT NULL,
    user_role ENUM('division_user', 'cmi', 'cis') NOT NULL,
    division_id INT,
    state_id INT, -- removed invalid comment syntax
    station_id INT,
    status ENUM('Active', 'Inactive') NOT NULL,
    FOREIGN KEY (station_id) REFERENCES StationLocation(station_id)
);

CREATE TABLE Application (
    application_id INT PRIMARY KEY,
    applicant_id INT NOT NULL,
    submission_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('submitted', 'assigned_doctor', 'assigned_station', 'rejected', 'transferred', 'issued') NOT NULL,
    current_division_id INT NOT NULL,
    current_division_user_id INT NOT NULL,
    current_cmi_id INT,
    current_cis_id INT,
    card_number VARCHAR(20),
    card_issue_date DATE,
    Authorname VARCHAR(255),
    FOREIGN KEY (applicant_id) REFERENCES Applicant(applicant_id),
    FOREIGN KEY (current_cmi_id) REFERENCES Railwayuser(user_id),
    FOREIGN KEY (current_cis_id) REFERENCES Railwayuser(user_id)
);

-- DOCUMENT
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

-- DISABILITY CERTIFICATE
CREATE TABLE DisabilityCertificate (
    certificate_id INT PRIMARY KEY,
    application_id INT NOT NULL,
    doctor_name VARCHAR(100) NOT NULL,
    doctor_reg_no VARCHAR(50),
    hospital_name VARCHAR(150),
    hospital_city VARCHAR(100),
    Hospital_state VARCHAR(255),
    issue_date DATE NOT NULL,
    FOREIGN KEY (application_id) REFERENCES Application(application_id)
);

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
