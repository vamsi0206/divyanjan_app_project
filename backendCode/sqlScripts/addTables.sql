-- Use the database
USE demoDb;

-- Drop tables if they exist to apply new schema changes
-- (Use with caution in production, this is for development/testing)
DROP TABLE IF EXISTS ApplicationLog;
DROP TABLE IF EXISTS DisabilityCertificate;
DROP TABLE IF EXISTS Document;
DROP TABLE IF EXISTS Application;
DROP TABLE IF EXISTS Railwayuser;
DROP TABLE IF EXISTS Applicant;
DROP TABLE IF EXISTS StationLocation;

-- FOR Station detail
CREATE TABLE StationLocation (
    station_id INT PRIMARY KEY,
    stationname VARCHAR(20) NOT NULL,
    statename VARCHAR(20) NOT NULL,
    Divisionname VARCHAR(20) NOT NULL
);

-- Applicant table -- CORRECTED ENUM FOR 'status'
CREATE TABLE Applicant (
    applicant_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL,
    mobile_number VARCHAR(10) NOT NULL,
    password VARCHAR(25) NOT NULL,
    email_id VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(6) NOT NULL,
    address VARCHAR(25),
    pin_code VARCHAR(6),
    city VARCHAR(20),
    statename VARCHAR(20),
    station_id INT,
    disability_type_id varchar(100),
    registration_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('submitting', 'draft'), -- CORRECTED HERE
    validity_id ENUM('0', '1') NOT NULL,
    FOREIGN KEY (station_id) REFERENCES StationLocation(station_id)
);

-- USER (renamed to Railwayuser to avoid conflict with MySQL reserved word USER)
CREATE TABLE Railwayuser (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL,
    mobile_number VARCHAR(15) NOT NULL,
    email VARCHAR(50) NOT NULL,
    current_level ENUM('1', '2', '3') NOT NULL,
    division_id INT,
    statename VARCHAR(20),
    station_id INT,
    validity_id ENUM('0', '1') NOT NULL,
    FOREIGN KEY (station_id) REFERENCES StationLocation(station_id)
);

CREATE TABLE Application (
    application_id INT PRIMARY KEY AUTO_INCREMENT,
    applicant_id INT NOT NULL,
    submission_date DATETIME DEFAULT CURRENT_TIMESTAMP, -- or in other words receive date
    process_date  DATETIME ,
    status ENUM('submitted', 'approved', 'assigned', 'rejected'),
    current_division_id INT NOT NULL,
    card_number VARCHAR(20),
    card_issue_date DATE,
    Authorname VARCHAR(255),
    validity_id ENUM('0', '1') NOT NULL,
    FOREIGN KEY (applicant_id) REFERENCES Applicant(applicant_id)
);

-- DOCUMENT
CREATE TABLE Document (
    document_id INT PRIMARY KEY AUTO_INCREMENT,
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
    validity_id ENUM('0', '1') NOT NULL,
    FOREIGN KEY (application_id) REFERENCES Application(application_id),
    FOREIGN KEY (applicant_id) REFERENCES Applicant(applicant_id)
);

-- DISABILITY CERTIFICATE
CREATE TABLE DisabilityCertificate (
    certificate_id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL,
    doctor_name VARCHAR(100),
    doctor_reg_no VARCHAR(50),
    hospital_name VARCHAR(150),
    hospital_city VARCHAR(100),
    Hospital_state VARCHAR(255),
    issue_date DATE NOT NULL,
    validity_id ENUM('0', '1') NOT NULL,
    FOREIGN KEY (application_id) REFERENCES Application(application_id)
);

CREATE TABLE ApplicationLog (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL,
    status ENUM('pending', 'draft', 'rejected', 'assign') DEFAULT NULL,
    station_id INT DEFAULT NULL,
    comments TEXT,
    validation_id ENUM('0', '1') NOT NULL,
    current_level ENUM('0', '1', '2', '3'),
    assign_date DATETIME,
    level_passed_date DATETIME,
    validity_id ENUM('0', '1') NOT NULL,
    FOREIGN KEY (application_id) REFERENCES Application(application_id),
    FOREIGN KEY (station_id) REFERENCES StationLocation(station_id)
);

-- Populate StationLocation Table
INSERT INTO StationLocation (station_id, stationname, statename, Divisionname) VALUES
(101, 'Hyderabad Decan', 'Telangana', 'Secunderabad'),
(102, 'Secunderabad Jn', 'Telangana', 'Secunderabad'),
(103, 'Vijayawada Jn', 'Andhra Pradesh', 'Vijayawada'),
(104, 'Guntur Jn', 'Andhra Pradesh', 'Guntur'),
(105, 'Chennai Central', 'Tamil Nadu', 'Chennai');

-- Populate Applicant Table (with random data)
INSERT INTO Applicant (name, mobile_number, password, email_id, date_of_birth, gender, address, pin_code, city, statename, station_id, disability_type_id, status, validity_id) VALUES
('Rohan Kumar', '9876543210', 'rohan@123', 'rohan.kumar@example.com', '1990-05-15', 'Male', '123 Gandhi Nagar', '500001', 'Hyderabad', 'Telangana', 101, 'Locomotor Disability', 'submitting', '1'),
('Priya Sharma', '9988776655', 'priya#pass', 'priya.sharma@example.com', '1988-11-22', 'Female', '45 Nehru Colony', '500002', 'Secunderabad', 'Telangana', 102, 'Visually Impaired', 'draft', '1'),
('Amit Singh', '9012345678', 'amitpass$', 'amit.singh@example.com', '1995-03-10', 'Male', '78 Patel Road', '520001', 'Vijayawada', 'Andhra Pradesh', 103, 'Hearing Impairment', 'submitting', '1'),
('Sneha Devi', '9765432109', 'sneha@789', 'sneha.devi@example.com', '1992-07-01', 'Female', '90 Park Street', '522001', 'Guntur', 'Andhra Pradesh', 104, 'Intellectual Disability', 'draft', '1'),
('Vikram Raj', '9321098765', 'vikram#abc', 'vikram.raj@example.com', '1985-09-28', 'Male', '10 MG Road', '600003', 'Chennai', 'Tamil Nadu', 105, 'Multiple Disabilities', 'submitting', '1');

-- Populate Railwayuser Table (with random data)
INSERT INTO Railwayuser (name, mobile_number, email, current_level, division_id, statename, station_id, validity_id) VALUES
('Divya Reddy', '8765412345', 'divya.r@railway.com', '1', 10, 'Telangana', 101, '1'),
('Suresh Babu', '8877654321', 'suresh.b@railway.com', '2', 10, 'Telangana', 102, '1'),
('Anjali Verma', '7654321098', 'anjali.v@railway.com', '3', 11, 'Andhra Pradesh', 103, '1'),
('Rahul Gupta', '7012345678', 'rahul.g@railway.com', '1', 11, 'Andhra Pradesh', 104, '1'),
('Pooja Singh', '9456789012', 'pooja.s@railway.com', '2', 12, 'Tamil Nadu', 105, '1');

-- Populate Application Table (linking to existing applicants)
INSERT INTO Application (applicant_id, submission_date, process_date, status, current_division_id, card_number, card_issue_date, Authorname, validity_id) VALUES
(1, NOW(), NULL, 'submitted', 10, NULL, NULL, 'System', '1'),
(2, NOW(), NULL, 'submitted', 10, NULL, NULL, 'System', '1'),
(3, NOW(), NULL, 'submitted', 11, NULL, NULL, 'System', '1'),
(4, NOW(), NULL, 'submitted', 11, NULL, NULL, 'System', '1'),
(5, NOW(), NULL, 'submitted', 12, NULL, NULL, 'System', '1');

-- Populate Document Table (linking to existing applicants and applications)
INSERT INTO Document (applicant_id, application_id, document_type, file_path, upload_date, Authorname, validity_id) VALUES
(1, 1, 'disability_certificate', '/docs/applicant1/disability.pdf', NOW(), 'Rohan Kumar', '1'),
(1, 1, 'photo', '/docs/applicant1/photo.jpg', NOW(), 'Rohan Kumar', '1'),
(2, 2, 'dob_proof', '/docs/applicant2/dob.pdf', NOW(), 'Priya Sharma', '1'),
(3, 3, 'address_proof', '/docs/applicant3/address.pdf', NOW(), 'Amit Singh', '1'),
(4, 4, 'railway_concession_certificate', '/docs/applicant4/railway.pdf', NOW(), 'Sneha Devi', '1');

-- Populate DisabilityCertificate Table (linking to existing applications)
INSERT INTO DisabilityCertificate (application_id, doctor_name, doctor_reg_no, hospital_name, hospital_city, Hospital_state, issue_date, validity_id) VALUES
(1, 'Dr. Anil Kumar', 'MCI12345', 'Apollo Hospital', 'Hyderabad', 'Telangana', '2023-01-10', '1'),
(2, 'Dr. Sunita Rao', 'DMC67890', 'Yashoda Hospital', 'Secunderabad', 'Telangana', '2023-02-15', '1'),
(3, 'Dr. Rajeshwari Devi', 'APMC11223', 'Government General Hospital', 'Vijayawada', 'Andhra Pradesh', '2023-03-20', '1'),
(4, 'Dr. Krishna Prasad', 'KMCI44556', 'KIMS Hospital', 'Guntur', 'Andhra Pradesh', '2023-04-05', '1'),
(5, 'Dr. Lakshmi Narayan', 'TCMC77889', 'Stanley Medical College', 'Chennai', 'Tamil Nadu', '2023-05-12', '1');

-- Populate ApplicationLog Table (simulating application flow with validity_id logic integrated)
INSERT INTO ApplicationLog (application_id, status, station_id, comments, validation_id, current_level, assign_date, level_passed_date, validity_id) VALUES
-- For application_id = 1: '0' level is set to validity_id '0', '1' level is set to validity_id '1'
(1, 'pending', 101, 'Application received', '0', '0', NOW(), NOW(), '0'),
(1, 'assign', 101, 'Assigned to Level 1 for verification', '1', '1', NOW(), NULL, '1'),
-- For other application_ids, only one log entry is created, so validity_id remains '1'
(2, 'pending', 102, 'Application received', '1', '0', NOW(), NOW(), '1'),
(3, 'pending', 103, 'Application received', '1', '0', NOW(), NOW(), '1'),
(4, 'pending', 104, 'Application received', '1', '0', NOW(), NOW(), '1'),
(5, 'pending', 105, 'Application received', '1', '0', NOW(), NOW(), '1');