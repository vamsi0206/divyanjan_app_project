USE demoDb;

-- Drop tables if they exist to apply new schema changes
-- (Use with caution in production; this is for development/testing)
DROP TABLE IF EXISTS ApplicationLog;
DROP TABLE IF EXISTS Document;
DROP TABLE IF EXISTS Application;
DROP TABLE IF EXISTS Railwayuser;
DROP TABLE IF EXISTS Applicant;
DROP TABLE IF EXISTS DivisionCity;


-- Applicant table (no station_id)
CREATE TABLE Applicant (
    applicant_id        INT PRIMARY KEY AUTO_INCREMENT,
    name                VARCHAR(80) NOT NULL,
    mobile_number       VARCHAR(10) NOT NULL,
    password            VARCHAR(25) NOT NULL,
    fathers_name        VARCHAR(80),
    email_id            VARCHAR(50) NOT NULL,
    date_of_birth       DATE,
    gender              VARCHAR(6) NOT NULL,
    address             VARCHAR(25),
    pin_code            VARCHAR(6),
    city                VARCHAR(20),
    statename           VARCHAR(20),
    disability_type_id  VARCHAR(100),
    registration_date   DATETIME DEFAULT CURRENT_TIMESTAMP,
    status              ENUM('submitting','draft'),
    validity_id         ENUM('0','1') NOT NULL
);

-- DivisionCity table: maps city to division
CREATE TABLE DivisionCity (
    city VARCHAR(100) PRIMARY KEY,
    division_name VARCHAR(100) NOT NULL
);

-- Populate DivisionCity table
INSERT INTO DivisionCity (city, division_name) VALUES
  ('Hyderabad', 'Secunderabad'),
  ('Secunderabad', 'Secunderabad'),
  ('Warangal', 'Secunderabad'),
  ('Vijayawada', 'Vijayawada'),
  ('Guntur', 'Vijayawada'),
  ('Nellore', 'Vijayawada'),
  ('Chennai', 'Chennai'),
  ('Coimbatore', 'Chennai'),
  ('Madurai', 'Chennai');

-- Railwayuser table (no station_id)
CREATE TABLE Railwayuser (
    user_id        INT PRIMARY KEY AUTO_INCREMENT,
    name           VARCHAR(20) NOT NULL,
    mobile_number  VARCHAR(15) NOT NULL,
    email          VARCHAR(50) NOT NULL,
    password       VARCHAR(25) NOT NULL,
    current_level  ENUM('1','2','3') NOT NULL,
    division_id    VARCHAR(100), -- now references division_name
    statename      VARCHAR(20),
    validity_id    ENUM('0','1') NOT NULL
);

-- Application table (add current_processing_employee)
CREATE TABLE Application (
    application_id      INT PRIMARY KEY AUTO_INCREMENT,
    applicant_id        INT NOT NULL,
    submission_date     DATETIME DEFAULT CURRENT_TIMESTAMP,
    process_date        DATETIME,
    status              ENUM('pending','draft','rejected','assign','card_generated') DEFAULT NULL, -- add card_generated status
    division_id         VARCHAR(100) NOT NULL, -- now references division_name
    card_number         VARCHAR(20),
    card_issue_date     DATE,
    Authorname          VARCHAR(255),
    doctor_name         VARCHAR(100),
    doctor_reg_no       VARCHAR(50),
    hospital_name       VARCHAR(150),
    hospital_city       VARCHAR(100),
    hospital_state      VARCHAR(255),
    certificate_issue_date DATE,
    concession_certificate VARCHAR(255),
    photograph          VARCHAR(255),
    disability_certificate VARCHAR(255),
    disability_cert_no  VARCHAR(100),
    dob_proof_type      VARCHAR(100),
    dob_proof_upload    VARCHAR(255),
    photoId_proof_type  VARCHAR(100),
    photoId_proof_upload VARCHAR(255),
    address_proof_type  VARCHAR(100),
    address_proof_upload VARCHAR(255),
    district            VARCHAR(100),
    validity_id         ENUM('0','1') NOT NULL,
    current_processing_employee INT,
    FOREIGN KEY (applicant_id) REFERENCES Applicant(applicant_id)
);

-- ApplicationLog table (add current_processing_employee)
CREATE TABLE ApplicationLog (
    log_id              INT PRIMARY KEY AUTO_INCREMENT,
    application_id      INT NOT NULL,
    status              ENUM('pending','draft','rejected','assign', 'card_generated') DEFAULT NULL,
    comments            TEXT, 
    current_level       ENUM('0','1','2','3'),
    assign_date         DATETIME,
    level_passed_date   DATETIME,
    generated_card_id   INT,
    validity_id         ENUM('0','1') NOT NULL,
    current_processing_employee INT,
    FOREIGN KEY (application_id) REFERENCES Application(application_id)
);

-- Populate Applicant Table (5 original + 5 new)
INSERT INTO Applicant (
    name, mobile_number, password, fathers_name, email_id, date_of_birth,
    gender, address, pin_code, city, statename,
    disability_type_id, status, validity_id
) VALUES
-- Original 5
 ('Rohan Kumar',   '9876543210','rohan@123','Rajesh Kumar', 'rohan.kumar@example.com','1990-05-15','Male',  '123 Gandhi Nagar','500001','Hyderabad',      'Telangana','Locomotor Disability','submitting','1'),
 ('Priya Sharma',  '9988776655','priya#pass','Ramesh Sharma','priya.sharma@example.com','1988-11-22','Female','45 Nehru Colony',  '500002','Secunderabad',    'Telangana','Visually Impaired',   'draft',    '1'),
 ('Amit Singh',    '9012345678','amitpass$','Suresh Singh', 'amit.singh@example.com',    '1995-03-10','Male',  '78 Patel Road',    '520001','Vijayawada',       'Andhra Pradesh','Hearing Impairment',  'submitting','1'),
 ('Sneha Devi',    '9765432109','sneha@789','Mohan Prasad', 'sneha.devi@example.com',    '1992-07-01','Female','90 Park Street',   '522001','Guntur',           'Andhra Pradesh','Intellectual Disability','draft','1'),
 ('Vikram Raj',    '9321098765','vikram#abc','Prakash Raj',  'vikram.raj@example.com',    '1985-09-28','Male',  '10 MG Road',       '600003','Chennai',          'Tamil Nadu','Multiple Disabilities','submitting','1'),
-- New 5
 ('Sunita Patil',  '9000000021','patil@123','Rajesh Patil', 'sunita.patil@example.com','1991-06-06','Female','12 MG Road',      '600006','Chennai',          'Tamil Nadu','Visually Impaired',    'submitting','1'),
 ('Arjun Kumar',   '9000000022','arjun@234','Mohan Kumar',  'arjun.kumar@example.com','1992-07-07','Male',  '34 Park Lane',     '500003','Hyderabad',        'Telangana','Hearing Impairment',   'submitting','1'),
 ('Latha Reddy',   '9000000023','latha@345','Kiran Reddy',  'latha.reddy@example.com','1993-08-08','Female','56 Nehru Colony',  '520003','Vijayawada',       'Andhra Pradesh','Locomotor Disability', 'submitting','1'),
 ('Deepak Sharma', '9000000024','deepak@456','Sunita Sharma','deepak.sharma@example.com','1994-09-09','Male',  '78 Lake View',     '522003','Guntur',           'Andhra Pradesh','Multiple Disabilities','submitting','1'),
 ('Priyanka Singh','9000000025','priya@567','Anil Singh',   'priyanka.singh@example.com','1995-10-10','Female','90 Hill Top',      '500004','Secunderabad',    'Telangana','Intellectual Disability','submitting','1');

-- Add 10 more applicants (applicant_id 11-20) for the new applications
INSERT INTO Applicant (
    name, mobile_number, password, fathers_name, email_id, date_of_birth,
    gender, address, pin_code, city, statename,
    disability_type_id, status, validity_id
) VALUES
 ('Rahul Verma',    '9000000026','rahul@123','Suresh Verma', 'rahul.verma@example.com','1990-12-01','Male',  '45 Lake Road',     '500005','Hyderabad',      'Telangana','Locomotor Disability','submitting','1'),
 ('Anjali Patel',   '9000000027','anjali@456','Rajesh Patel', 'anjali.patel@example.com','1992-03-15','Female','67 Park Avenue',   '520004','Vijayawada',     'Andhra Pradesh','Visually Impaired','submitting','1'),
 ('Vikrant Singh',  '9000000028','vikrant@789','Amit Singh', 'vikrant.singh@example.com','1988-07-22','Male',  '89 Hill Street',   '600007','Chennai',        'Tamil Nadu','Hearing Impairment','submitting','1'),
 ('Pooja Sharma',   '9000000029','pooja@321','Mohan Sharma', 'pooja.sharma@example.com','1993-09-08','Female','12 River View',    '500006','Secunderabad',   'Telangana','Intellectual Disability','submitting','1'),
 ('Rajiv Kumar',    '9000000030','rajiv@654','Sunil Kumar',  'rajiv.kumar@example.com','1991-11-30','Male',  '34 Beach Road',    '522004','Guntur',         'Andhra Pradesh','Multiple Disabilities','submitting','1'),
 ('Meera Reddy',    '9000000031','meera@987','Krishna Reddy','meera.reddy@example.com','1994-04-12','Female','56 Garden Lane',   '600008','Chennai',        'Tamil Nadu','Locomotor Disability','submitting','1'),
 ('Sandeep Gupta',  '9000000032','sandeep@147','Ramesh Gupta','sandeep.gupta@example.com','1989-06-25','Male','78 Market Street', '500007','Hyderabad',      'Telangana','Visually Impaired','submitting','1'),
 ('Kavita Joshi',   '9000000033','kavita@258','Prakash Joshi','kavita.joshi@example.com','1995-01-18','Female','90 Temple Road',  '520005','Vijayawada',     'Andhra Pradesh','Hearing Impairment','submitting','1'),
 ('Amit Desai',     '9000000034','amit@369','Vijay Desai',   'amit.desai@example.com','1992-08-05','Male',   '23 College Street','600009','Chennai',        'Tamil Nadu','Intellectual Disability','submitting','1'),
 ('Neha Kapoor',    '9000000035','neha@741','Sanjay Kapoor', 'neha.kapoor@example.com','1993-12-14','Female','45 Station Road',  '500008','Secunderabad',   'Telangana','Multiple Disabilities','submitting','1');

-- Populate Railwayuser Table (15 users from 3 divisions)
INSERT INTO Railwayuser (
    name, mobile_number, email, password, current_level, division_id, statename, validity_id
) VALUES
-- Secunderabad
 ('Rajesh Rao',   '9000000001','rajesh.rao@railway.com',   'pass@123', '1','Secunderabad','Telangana','1'),
 ('Meena Iyer',   '9000000002','meena.iyer@railway.com',   'meena#pw', '2','Secunderabad','Telangana','1'),
 ('Kiran Reddy',  '9000000003','kiran.reddy@railway.com',  'kiran@456','2','Secunderabad','Telangana','1'),
 ('Farhan Ali',   '9000000004','farhan.ali@railway.com',   'farhan$12','2','Secunderabad','Telangana','1'),
 ('Sangeeta Das', '9000000005','sangeeta.das@railway.com', 'sangee@789','3','Secunderabad','Telangana','1'),
-- Vijayawada
 ('Ravi Teja',    '9000000006','ravi.teja@railway.com',    'ravi#234','1','Vijayawada',  'Andhra Pradesh','1'),
 ('Deepika Nair', '9000000007','deepika.nair@railway.com', 'deep@567','2','Vijayawada',  'Andhra Pradesh','1'),
 ('Satish Kumar', '9000000008','satish.kumar@railway.com', 'satish@890','2','Vijayawada',  'Andhra Pradesh','1'),
 ('Anusha R',     '9000000009','anusha.r@railway.com',     'anusha#123','2','Vijayawada',  'Andhra Pradesh','1'),
 ('Harsha M',     '9000000010','harsha.m@railway.com',     'harsha@pass','3','Vijayawada',  'Andhra Pradesh','1'),
-- Chennai
 ('Raghav Menon', '9000000011','raghav.m@railway.com',     'raghav@pw','1','Chennai','Tamil Nadu','1'),
 ('Lalitha S',    '9000000012','lalitha.s@railway.com',     'lalitha#pw','2','Chennai','Tamil Nadu','1'),
 ('Naveen Raj',   '9000000013','naveen.raj@railway.com',    'naveen@pass','2','Chennai','Tamil Nadu','1'),
 ('Shweta Rao',   '9000000014','shweta.rao@railway.com',    'shweta@pw','2','Chennai','Tamil Nadu','1'),
 ('Ganesh V',     '9000000015','ganesh.v@railway.com',      'ganesh#321','3','Chennai','Tamil Nadu','1');

-- Fix Application table current_processing_employee assignments
-- Level 1 employees (Rajesh Rao, Ravi Teja, Raghav Menon) should get current_level=0 applications
-- Level 2 employees (Meena Iyer, Kiran Reddy, Farhan Ali, etc.) should get current_level=1 applications
-- Level 3 employees (Sangeeta Das, Harsha M, Ganesh V) should get current_level=2 applications

-- Update Application INSERTs with user_id instead of names for current_processing_employee
INSERT INTO Application (
    applicant_id, submission_date, process_date, status,
    division_id,
    card_number, card_issue_date, Authorname,
    doctor_name, doctor_reg_no,
    hospital_name, hospital_city, hospital_state, certificate_issue_date,
    concession_certificate, photograph, disability_certificate, disability_cert_no,
    dob_proof_type, dob_proof_upload,
    photoId_proof_type, photoId_proof_upload,
    address_proof_type, address_proof_upload,
    district, validity_id, current_processing_employee
) VALUES
-- Original 5 (applications at level 0 - assigned to level 1 employees)
 (1, NOW(), NULL, 'pending', 'Secunderabad', NULL, NULL, 'System', 'Dr. Anil Kumar', 'MCI12345',
  'Apollo Hospital','Hyderabad','Telangana','2023-01-10',
  '/docs/applicant1/railway_concession.pdf','/docs/applicant1/photo.jpg','/docs/applicant1/disability.pdf','CERT001',
  'Birth Certificate','/docs/applicant1/dob.pdf','Aadhar Card','/docs/applicant1/aadhar.pdf',
  'Utility Bill','/docs/applicant1/address.pdf','Hyderabad','1', 2),
 (2, NOW(), NULL, 'pending', 'Secunderabad', NULL, NULL, 'System', 'Dr. Sunita Rao',   'DMC67890',
  'Yashoda Hospital','Secunderabad','Telangana','2023-02-15',
  '/docs/applicant2/railway_concession.pdf','/docs/applicant2/photo.jpg','/docs/applicant2/disability.pdf','CERT002',
  'Birth Certificate','/docs/applicant2/dob.pdf','Aadhar Card','/docs/applicant2/aadhar.pdf',
  'Utility Bill','/docs/applicant2/address.pdf','Secunderabad','1', 1),
 (3, NOW(), NULL, 'pending', 'Vijayawada',   NULL, NULL, 'System', 'Dr. Rajeshwari Devi','APMC11223',
  'Government General Hospital','Vijayawada','Andhra Pradesh','2023-03-20',
  '/docs/applicant3/railway_concession.pdf','/docs/applicant3/photo.jpg','/docs/applicant3/disability.pdf','CERT003',
  'Birth Certificate','/docs/applicant3/dob.pdf','Aadhar Card','/docs/applicant3/aadhar.pdf',
  'Utility Bill','/docs/applicant3/address.pdf','Vijayawada','1', 6),
 (4, NOW(), NULL, 'pending', 'Vijayawada',   NULL, NULL, 'System', 'Dr. Krishna Prasad','KMCI44556',
  'KIMS Hospital','Guntur','Andhra Pradesh','2023-04-05',
  '/docs/applicant4/railway_concession.pdf','/docs/applicant4/photo.jpg','/docs/applicant4/disability.pdf','CERT004',
  'Birth Certificate','/docs/applicant4/dob.pdf','Aadhar Card','/docs/applicant4/aadhar.pdf',
  'Utility Bill','/docs/applicant4/address.pdf','Guntur','1', 6),
 (5, NOW(), NULL, 'pending', 'Chennai',      NULL, NULL, 'System', 'Dr. Lakshmi Narayan','TCMC77889',
  'Stanley Medical College','Chennai','Tamil Nadu','2023-05-12',
  '/docs/applicant5/railway_concession.pdf','/docs/applicant5/photo.jpg','/docs/applicant5/disability.pdf','CERT005',
  'Birth Certificate','/docs/applicant5/dob.pdf','Aadhar Card','/docs/applicant5/aadhar.pdf',
  'Utility Bill','/docs/applicant5/address.pdf','Chennai','1', 11),
-- New 5 (applications at level 0 - assigned to level 1 employees)
 (6, NOW(), NULL, 'pending', 'Chennai',      NULL, NULL, 'System', 'Dr. Sunil Patil','TNMC123',
  'Fortis Chennai','Chennai','Tamil Nadu','2024-06-06',
  '/docs/applicant6/concession.pdf','/docs/applicant6/photo.jpg','/docs/applicant6/disability.pdf','CERT006',
  'Birth Certificate','/docs/applicant6/dob.pdf','Aadhar Card','/docs/applicant6/aadhar.pdf',
  'Utility Bill','/docs/applicant6/address.pdf','Chennai','1', 12),
 (7, NOW(), NULL, 'pending', 'Secunderabad', NULL, NULL, 'System', 'Dr. Mohan Kumar','MCI234',
  'Yashoda Hospital','Hyderabad','Telangana','2024-07-07',
  '/docs/applicant7/concession.pdf','/docs/applicant7/photo.jpg','/docs/applicant7/disability.pdf','CERT007',
  'Birth Certificate','/docs/applicant7/dob.pdf','Aadhar Card','/docs/applicant7/aadhar.pdf',
  'Utility Bill','/docs/applicant7/address.pdf','Hyderabad','1', 5),
 (8, NOW(), NULL, 'pending', 'Vijayawada',   NULL, NULL, 'System', 'Dr. Suresh Reddy','APMC345',
  'Government General Hospital','Vijayawada','Andhra Pradesh','2024-08-08',
  '/docs/applicant8/concession.pdf','/docs/applicant8/photo.jpg','/docs/applicant8/disability.pdf','CERT008',
  'Birth Certificate','/docs/applicant8/dob.pdf','Aadhar Card','/docs/applicant8/aadhar.pdf',
  'Utility Bill','/docs/applicant8/address.pdf','Vijayawada','1', 15),
 (9, NOW(), NULL, 'pending', 'Vijayawada',   NULL, NULL, 'System', 'Dr. Krishna Sharma','KMCI456',
  'KIMS Hospital','Guntur','Andhra Pradesh','2024-09-09',
  '/docs/applicant9/concession.pdf','/docs/applicant9/photo.jpg','/docs/applicant9/disability.pdf','CERT009',
  'Birth Certificate','/docs/applicant9/dob.pdf','Aadhar Card','/docs/applicant9/aadhar.pdf',
  'Utility Bill','/docs/applicant9/address.pdf','Guntur','1', 7),
 (10, NOW(), NULL, 'pending','Secunderabad', NULL, NULL,'System','Dr. Priya Sharma','DMC567',
  'Apollo Secunderabad','Secunderabad','Telangana','2024-10-10',
  '/docs/applicant10/concession.pdf','/docs/applicant10/photo.jpg','/docs/applicant10/disability.pdf','CERT010',
  'Birth Certificate','/docs/applicant10/dob.pdf','Aadhar Card','/docs/applicant10/aadhar.pdf',
  'Utility Bill','/docs/applicant10/address.pdf','Secunderabad','1', 5);

-- Add 10 more applications (applications 11-20) with levels 0, 1, 2 spread across divisions
INSERT INTO Application (
    applicant_id, submission_date, process_date, status,
    division_id,
    card_number, card_issue_date, Authorname,
    doctor_name, doctor_reg_no,
    hospital_name, hospital_city, hospital_state, certificate_issue_date,
    concession_certificate, photograph, disability_certificate, disability_cert_no,
    dob_proof_type, dob_proof_upload,
    photoId_proof_type, photoId_proof_upload,
    address_proof_type, address_proof_upload,
    district, validity_id, current_processing_employee
) VALUES
-- Level 0 applications (new/pending) - assigned to level 1 employees
 (11, NOW(), NULL, 'pending', 'Secunderabad', NULL, NULL, 'System', 'Dr. Rajesh Kumar', 'MCI789',
  'City Hospital','Hyderabad','Telangana','2024-11-11',
  '/docs/applicant11/concession.pdf','/docs/applicant11/photo.jpg','/docs/applicant11/disability.pdf','CERT011',
  'Birth Certificate','/docs/applicant11/dob.pdf','Aadhar Card','/docs/applicant11/aadhar.pdf',
  'Utility Bill','/docs/applicant11/address.pdf','Hyderabad','1', 1),
 (12, NOW(), NULL, 'pending', 'Vijayawada', NULL, NULL, 'System', 'Dr. Lakshmi Devi', 'APMC456',
  'District Hospital','Vijayawada','Andhra Pradesh','2024-11-12',
  '/docs/applicant12/concession.pdf','/docs/applicant12/photo.jpg','/docs/applicant12/disability.pdf','CERT012',
  'Birth Certificate','/docs/applicant12/dob.pdf','Aadhar Card','/docs/applicant12/aadhar.pdf',
  'Utility Bill','/docs/applicant12/address.pdf','Vijayawada','1', 6),
 (13, NOW(), NULL, 'pending', 'Chennai', NULL, NULL, 'System', 'Dr. Suresh Kumar', 'TNMC789',
  'Metro Hospital','Chennai','Tamil Nadu','2024-11-13',
  '/docs/applicant13/concession.pdf','/docs/applicant13/photo.jpg','/docs/applicant13/disability.pdf','CERT013',
  'Birth Certificate','/docs/applicant13/dob.pdf','Aadhar Card','/docs/applicant13/aadhar.pdf',
  'Utility Bill','/docs/applicant13/address.pdf','Chennai','1', 11),

-- Level 1 applications (assigned to level 1) - assigned to level 2 employees
 (14, NOW(), NULL, 'assign', 'Secunderabad', NULL, NULL, 'System', 'Dr. Priya Reddy', 'MCI321',
  'Central Hospital','Secunderabad','Telangana','2024-11-14',
  '/docs/applicant14/concession.pdf','/docs/applicant14/photo.jpg','/docs/applicant14/disability.pdf','CERT014',
  'Birth Certificate','/docs/applicant14/dob.pdf','Aadhar Card','/docs/applicant14/aadhar.pdf',
  'Utility Bill','/docs/applicant14/address.pdf','Secunderabad','1', 2),
 (15, NOW(), NULL, 'assign', 'Vijayawada', NULL, NULL, 'System', 'Dr. Anil Prasad', 'APMC654',
  'Regional Hospital','Guntur','Andhra Pradesh','2024-11-15',
  '/docs/applicant15/concession.pdf','/docs/applicant15/photo.jpg','/docs/applicant15/disability.pdf','CERT015',
  'Birth Certificate','/docs/applicant15/dob.pdf','Aadhar Card','/docs/applicant15/aadhar.pdf',
  'Utility Bill','/docs/applicant15/address.pdf','Guntur','1', 7),
 (16, NOW(), NULL, 'assign', 'Chennai', NULL, NULL, 'System', 'Dr. Geetha Rao', 'TNMC321',
  'Specialty Hospital','Coimbatore','Tamil Nadu','2024-11-16',
  '/docs/applicant16/concession.pdf','/docs/applicant16/photo.jpg','/docs/applicant16/disability.pdf','CERT016',
  'Birth Certificate','/docs/applicant16/dob.pdf','Aadhar Card','/docs/applicant16/aadhar.pdf',
  'Utility Bill','/docs/applicant16/address.pdf','Coimbatore','1', 12),

-- Level 2 applications (assigned to level 2) - assigned to level 3 employees
 (17, NOW(), NULL, 'assign', 'Secunderabad', NULL, NULL, 'System', 'Dr. Krishna Kumar', 'MCI147',
  'Multi-Specialty Hospital','Warangal','Telangana','2024-11-17',
  '/docs/applicant17/concession.pdf','/docs/applicant17/photo.jpg','/docs/applicant17/disability.pdf','CERT017',
  'Birth Certificate','/docs/applicant17/dob.pdf','Aadhar Card','/docs/applicant17/aadhar.pdf',
  'Utility Bill','/docs/applicant17/address.pdf','Warangal','1', 5),
 (18, NOW(), NULL, 'assign', 'Vijayawada', NULL, NULL, 'System', 'Dr. Radha Devi', 'APMC258',
  'Medical College Hospital','Nellore','Andhra Pradesh','2024-11-18',
  '/docs/applicant18/concession.pdf','/docs/applicant18/photo.jpg','/docs/applicant18/disability.pdf','CERT018',
  'Birth Certificate','/docs/applicant18/dob.pdf','Aadhar Card','/docs/applicant18/aadhar.pdf',
  'Utility Bill','/docs/applicant18/address.pdf','Nellore','1', 10),
 (19, NOW(), NULL, 'assign', 'Chennai', NULL, NULL, 'System', 'Dr. Venkat Raman', 'TNMC369',
  'University Hospital','Madurai','Tamil Nadu','2024-11-19',
  '/docs/applicant19/concession.pdf','/docs/applicant19/photo.jpg','/docs/applicant19/disability.pdf','CERT019',
  'Birth Certificate','/docs/applicant19/dob.pdf','Aadhar Card','/docs/applicant19/aadhar.pdf',
  'Utility Bill','/docs/applicant19/address.pdf','Madurai','1', 15),
 (20, NOW(), NULL, 'assign', 'Secunderabad', NULL, NULL, 'System', 'Dr. Meera Singh', 'MCI963',
  'Community Hospital','Hyderabad','Telangana','2024-11-20',
  '/docs/applicant20/concession.pdf','/docs/applicant20/photo.jpg','/docs/applicant20/disability.pdf','CERT020',
  'Birth Certificate','/docs/applicant20/dob.pdf','Aadhar Card','/docs/applicant20/aadhar.pdf',
  'Utility Bill','/docs/applicant20/address.pdf','Hyderabad','1', 5);

-- Fix ApplicationLog INSERTs with user_id instead of names for current_processing_employee
INSERT INTO ApplicationLog (
    application_id, status, comments,
    current_level, assign_date, level_passed_date, generated_card_id, validity_id, current_processing_employee
) VALUES
-- Original logs for applications 1–5 (level 0 applications)
 (1, 'pending', 'Application received',                '0', NOW(), NOW(),    NULL,'0', 1),
 (1, 'assign',  'Assigned to Level 1 for verification','1', NOW(), NULL,    NULL,'1', 2),
 (2, 'pending', 'Application received',                '0', NOW(), NOW(),    NULL,'1', 1),
 (3, 'pending', 'Application received',                '0', NOW(), NOW(),    NULL,'1', 6),
 (4, 'pending', 'Application received',                '0', NOW(), NOW(),    NULL,'1', 6),
 (5, 'pending', 'Application received',                '0', NOW(), NOW(),    NULL,'1', 11),
-- New logs for applications 6–10 (level 0 applications)
 (6, 'assign',  'Assigned to Level 1 for verification','1', NOW(), NULL,    NULL,'1', 12),
 (7, 'assign',  'Assigned to Level 2 for verification','2', NOW(), NULL,    NULL,'1', 5),
 (8, 'assign',  'Assigned to Level 3 for verification','3', NOW(), NULL,    NULL,'1', 15),
 (9, 'assign',  'Assigned to Level 1 for verification','1', NOW(), NULL,    NULL,'1', 7),
 (10,'assign',  'Assigned to Level 2 for verification','2', NOW(), NULL,    NULL,'1', 5);

-- Add ApplicationLog entries for the new applications (11-20)
INSERT INTO ApplicationLog (
    application_id, status, comments,
    current_level, assign_date, level_passed_date, generated_card_id, validity_id, current_processing_employee
) VALUES
-- Level 0 applications (new/pending) - assigned to level 1 employees
 (11, 'pending', 'Application received', '0', NOW(), NOW(), NULL,'1', 1),
 (12, 'pending', 'Application received', '0', NOW(), NOW(), NULL,'1', 6),
 (13, 'pending', 'Application received', '0', NOW(), NOW(), NULL,'1', 11),

-- Level 1 applications (assigned to level 1) - assigned to level 2 employees
 (14, 'assign', 'Assigned to Level 1 for verification','1', NOW(), NULL, NULL,'1', 2),
 (15, 'assign', 'Assigned to Level 1 for verification','1', NOW(), NULL, NULL,'1', 7),
 (16, 'assign', 'Assigned to Level 1 for verification','1', NOW(), NULL, NULL,'1', 12),

-- Level 2 applications (assigned to level 2) - assigned to level 3 employees
 (17, 'assign', 'Assigned to Level 2 for verification','2', NOW(), NULL, NULL,'1', 5),
 (18, 'assign', 'Assigned to Level 2 for verification','2', NOW(), NULL, NULL,'1', 10),
 (19, 'assign', 'Assigned to Level 2 for verification','2', NOW(), NULL, NULL,'1', 15),
 (20, 'assign', 'Assigned to Level 2 for verification','2', NOW(), NULL, NULL,'1', 5);
