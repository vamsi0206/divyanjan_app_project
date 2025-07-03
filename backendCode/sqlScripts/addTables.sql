-- Use the database
USE demoDb;

-- Drop tables if they exist to apply new schema changes
-- (Use with caution in production, this is for development/testing)
DROP TABLE IF EXISTS ApplicationLog;
DROP TABLE IF EXISTS Document;
DROP TABLE IF EXISTS Application;
DROP TABLE IF EXISTS Railwayuser;
DROP TABLE IF EXISTS Applicant;
DROP TABLE IF EXISTS StationLocation;
DROP TABLE IF EXISTS DivisionCardSerialNumber;
-- FOR Station detail
CREATE TABLE StationLocation (
    station_id INT PRIMARY KEY,
    stationname VARCHAR(20) NOT NULL,
    statename VARCHAR(20) NOT NULL,
    Divisionname VARCHAR(20) NOT NULL
);
-- division 
--last generated card serial number table
CREATE TABLE DivisionCardSerialNumber
(
    division_id INT PRIMARY KEY,
    Divisionname VARCHAR(20) NOT NULL,
    last_card_id INT 

)
--TODO
-- Applicant table -- CORRECTED ENUM FOR 'status'
CREATE TABLE Applicant (
    applicant_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(80) NOT NULL,
    mobile_number VARCHAR(10) NOT NULL,
    password VARCHAR(25) NOT NULL,
    fathers_name VARCHAR(80),
    email_id VARCHAR(50) NOT NULL,
    date_of_birth DATE,
    gender VARCHAR(6) NOT NULL,
    address VARCHAR(25),
    pin_code VARCHAR(6),
    city VARCHAR(20),
    statename VARCHAR(20),
    station_id INT,
    disability_type_id varchar(100),
    registration_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('submitting', 'draft'),
    validity_id ENUM('0', '1') NOT NULL,
    FOREIGN KEY (station_id) REFERENCES StationLocation(station_id)
);

-- USER (renamed to Railwayuser to avoid conflict with MySQL reserved word USER)
CREATE TABLE Railwayuser (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(20) NOT NULL,
    mobile_number VARCHAR(15) NOT NULL,
    email VARCHAR(50) NOT NULL,
    password VARCHAR(25) NOT NULL,
    current_level ENUM('1', '2', '3') NOT NULL,
    station_id INT,
    --can use sql join(with stationLocationTable) to fetch division_id and statename while registering user to avoid inconsistency
    division_id INT,
    statename VARCHAR(20),
    validity_id ENUM('0', '1') NOT NULL,
    FOREIGN KEY (station_id) REFERENCES StationLocation(station_id)
);

CREATE TABLE Application (
    application_id INT PRIMARY KEY AUTO_INCREMENT,
    applicant_id INT NOT NULL,
    submission_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    process_date DATETIME,
    status ENUM('pending', 'draft', 'rejected', 'assign') DEFAULT NULL,
    station_id ,
    current_division_id INT NOT NULL,
    card_number VARCHAR(20),
    card_issue_date DATE,
    Authorname VARCHAR(255),
    -- Added disability certificate fields
    doctor_name VARCHAR(100),
    doctor_reg_no VARCHAR(50),
    hospital_name VARCHAR(150),
    hospital_city VARCHAR(100),
    hospital_state VARCHAR(255),
    certificate_issue_date DATE,
    -- New document fields
    concession_certificate VARCHAR(255),
    photograph VARCHAR(255),
    disability_certificate VARCHAR(255),
    dob_proof_type VARCHAR(100),
    dob_proof_upload VARCHAR(255),
    photoId_proof_type VARCHAR(100),
    photoId_proof_upload VARCHAR(255),
    address_proof_type VARCHAR(100),
    address_proof_upload VARCHAR(255),
    district VARCHAR(100),
    validity_id ENUM('0', '1') NOT NULL,
    FOREIGN KEY (applicant_id) REFERENCES Applicant(applicant_id)
);

CREATE TABLE ApplicationLog (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    application_id INT NOT NULL,
    status ENUM('pending', 'draft', 'rejected', 'assign') DEFAULT NULL,
    station_id INT DEFAULT NULL,
    comments TEXT,
    validation_id ENUM('0', '1') NOT NULL,
    current_level ENUM('0', '1', '2', '3'), --level 0 is user
    assign_date DATETIME, --recieve
    level_passed_date DATETIME,--process 
    validity_id ENUM('0', '1') NOT NULL,
    generated_card_id, --ADDED , NULLABLE SINCE ONLY APPLICABLE FOR LEVEL3
    FOREIGN KEY (application_id) REFERENCES Application(application_id),
    FOREIGN KEY (station_id) REFERENCES StationLocation(station_id)
);
-- FOR ACCESSING CARD DETAILS
--option1 : use application log table and do sql join to extract details from other tables
--option2 :separate card log table with each field
-- CardLog
-- (
--     card_id PRIMARY KEY,

--     bookingName varchar(20)    ,

--     Name_of_hospital varchar(),
--     Name_of_doctor  varchar(),
--     RegistrationNoOfDoctor varchar(),
--     
--     --Card detail
--     --concession   card_status {enable, disable,block} ,--also delete option
--     card_valid_from DATETIME,
--     card_valid_upto DATETIME,
--     concession_certificate_issue_date DATETIME,
--     -- Card holder detail
--     name varchar(20)        ,
--     applicant_id,
--     date_of_birth DATETIME,
--     -- division/station detail
--     station_id,
--     --Handicap card detail
--     --validity period??
--     -- comments  varchar(20) --(only if adding card status update)
--     --card_status --(only if adding card status update)
-- )

-- Populate StationLocation Table
INSERT INTO StationLocation (station_id, stationname, statename, Divisionname) VALUES
(101, 'Hyderabad Decan', 'Telangana', 'Secunderabad'),
(102, 'Secunderabad Jn', 'Telangana', 'Secunderabad'),
(103, 'Vijayawada Jn', 'Andhra Pradesh', 'Vijayawada'),
(104, 'Guntur Jn', 'Andhra Pradesh', 'Guntur'),
(105, 'Chennai Central', 'Tamil Nadu', 'Chennai');

-- Populate Applicant Table (with random data)
INSERT INTO Applicant (name, mobile_number, password, fathers_name, email_id, date_of_birth, gender, address, pin_code, city, statename, station_id, disability_type_id, status, validity_id) VALUES
('Rohan Kumar', '9876543210', 'rohan@123', 'Rajesh Kumar', 'rohan.kumar@example.com', '1990-05-15', 'Male', '123 Gandhi Nagar', '500001', 'Hyderabad', 'Telangana', 101, 'Locomotor Disability', 'submitting', '1'),
('Priya Sharma', '9988776655', 'priya#pass', 'Ramesh Sharma', 'priya.sharma@example.com', '1988-11-22', 'Female', '45 Nehru Colony', '500002', 'Secunderabad', 'Telangana', 102, 'Visually Impaired', 'draft', '1'),
('Amit Singh', '9012345678', 'amitpass$', 'Suresh Singh', 'amit.singh@example.com', '1995-03-10', 'Male', '78 Patel Road', '520001', 'Vijayawada', 'Andhra Pradesh', 103, 'Hearing Impairment', 'submitting', '1'),
('Sneha Devi', '9765432109', 'sneha@789', 'Mohan Prasad', 'sneha.devi@example.com', '1992-07-01', 'Female', '90 Park Street', '522001', 'Guntur', 'Andhra Pradesh', 104, 'Intellectual Disability', 'draft', '1'),
('Vikram Raj', '9321098765', 'vikram#abc', 'Prakash Raj', 'vikram.raj@example.com', '1985-09-28', 'Male', '10 MG Road', '600003', 'Chennai', 'Tamil Nadu', 105, 'Multiple Disabilities', 'submitting', '1');

-- Populate Railwayuser Table (with random data)
INSERT INTO Railwayuser (name, mobile_number, email, password, current_level, division_id, statename, station_id, validity_id) VALUES
('Divya Reddy', '8765412345', 'divya.r@railway.com', 'divya@123', '1', 10, 'Telangana', 101, '1'),
('Suresh Babu', '8877654321', 'suresh.b@railway.com', 'suresh#pass', '2', 10, 'Telangana', 102, '1'),
('Anjali Verma', '7654321098', 'anjali.v@railway.com', 'anjali$pwd', '3', 11, 'Andhra Pradesh', 103, '1'),
('Rahul Gupta', '7012345678', 'rahul.g@railway.com', 'rahul@pwd', '1', 11, 'Andhra Pradesh', 104, '1'),
('Pooja Singh', '9456789012', 'pooja.s@railway.com', 'pooja@pw', '2', 12, 'Tamil Nadu', 105, '1');

-- Populate Application Table (linking to existing applicants)
INSERT INTO Application (
    applicant_id, submission_date, process_date, status, current_division_id, 
    card_number, card_issue_date, Authorname, doctor_name, doctor_reg_no, 
    hospital_name, hospital_city, hospital_state, certificate_issue_date, 
    concession_certificate, photograph, disability_certificate, dob_proof_type, dob_proof_upload, photoId_proof_type, photoId_proof_upload, address_proof_type, address_proof_upload, district, validity_id
) VALUES
(1, NOW(), NULL, 'pending', 10, NULL, NULL, 'System', 'Dr. Anil Kumar', 'MCI12345', 'Apollo Hospital', 'Hyderabad', 'Telangana', '2023-01-10', '/docs/applicant1/railway_concession.pdf', '/docs/applicant1/photo.jpg', '/docs/applicant1/disability.pdf', 'Birth Certificate', '/docs/applicant1/dob.pdf', 'Aadhar Card', '/docs/applicant1/aadhar.pdf', 'Utility Bill', '/docs/applicant1/address.pdf', 'Hyderabad', '1'),
(2, NOW(), NULL, 'pending', 10, NULL, NULL, 'System', 'Dr. Sunita Rao', 'DMC67890', 'Yashoda Hospital', 'Secunderabad', 'Telangana', '2023-02-15', '/docs/applicant2/railway_concession.pdf', '/docs/applicant2/photo.jpg', '/docs/applicant2/disability.pdf', 'Birth Certificate', '/docs/applicant2/dob.pdf', 'Aadhar Card', '/docs/applicant2/aadhar.pdf', 'Utility Bill', '/docs/applicant2/address.pdf', 'Secunderabad', '1'),
(3, NOW(), NULL, 'pending', 11, NULL, NULL, 'System', 'Dr. Rajeshwari Devi', 'APMC11223', 'Government General Hospital', 'Vijayawada', 'Andhra Pradesh', '2023-03-20', '/docs/applicant3/railway_concession.pdf', '/docs/applicant3/photo.jpg', '/docs/applicant3/disability.pdf', 'Birth Certificate', '/docs/applicant3/dob.pdf', 'Aadhar Card', '/docs/applicant3/aadhar.pdf', 'Utility Bill', '/docs/applicant3/address.pdf', 'Vijayawada', '1'),
(4, NOW(), NULL, 'pending', 11, NULL, NULL, 'System', 'Dr. Krishna Prasad', 'KMCI44556', 'KIMS Hospital', 'Guntur', 'Andhra Pradesh', '2023-04-05', '/docs/applicant4/railway_concession.pdf', '/docs/applicant4/photo.jpg', '/docs/applicant4/disability.pdf', 'Birth Certificate', '/docs/applicant4/dob.pdf', 'Aadhar Card', '/docs/applicant4/aadhar.pdf', 'Utility Bill', '/docs/applicant4/address.pdf', 'Guntur', '1'),
(5, NOW(), NULL, 'pending', 12, NULL, NULL, 'System', 'Dr. Lakshmi Narayan', 'TCMC77889', 'Stanley Medical College', 'Chennai', 'Tamil Nadu', '2023-05-12', '/docs/applicant5/railway_concession.pdf', '/docs/applicant5/photo.jpg', '/docs/applicant5/disability.pdf', 'Birth Certificate', '/docs/applicant5/dob.pdf', 'Aadhar Card', '/docs/applicant5/aadhar.pdf', 'Utility Bill', '/docs/applicant5/address.pdf', 'Chennai', '1');

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