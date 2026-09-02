-- ==========================================================================
-- 1. DATABASE SETUP
-- ==========================================================================
CREATE DATABASE IF NOT EXISTS sa_tertiary_db;
USE sa_tertiary_db;

-- Drop tables in reverse order of dependencies to allow clean re-runs
DROP TABLE IF EXISTS job_listings;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS application_alerts;
DROP TABLE IF EXISTS applications;
DROP TABLE IF EXISTS institutions;
DROP TABLE IF EXISTS users;

-- ==========================================================================
-- 2. TABLE CREATION
-- ==========================================================================

-- 2.1 Users Table
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(15),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2.2 Institutions Table
CREATE TABLE institutions (
    institution_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    institution_type ENUM('University', 'TVET College', 'Private College') NOT NULL,
    province VARCHAR(50) NOT NULL,
    application_status ENUM('Open', 'Closed', 'Opening Soon') DEFAULT 'Closed',
    application_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    opening_date DATE,
    closing_date DATE,
    website_url VARCHAR(255),
    application_url VARCHAR(255) DEFAULT NULL,
    status_portal_url VARCHAR(255) DEFAULT NULL
);

-- 2.3 Applications Table
CREATE TABLE applications (
    application_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    institution_id INT NOT NULL,
    payment_status ENUM('Pending', 'Completed', 'Failed') DEFAULT 'Pending',
    application_status ENUM('Draft', 'Submitted', 'Under Review', 'Accepted') DEFAULT 'Draft',
    fee_amount DECIMAL(10,2) NOT NULL,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (institution_id) REFERENCES institutions(institution_id) ON DELETE CASCADE,
    CONSTRAINT unique_user_institution UNIQUE (user_id, institution_id)
);

-- 2.4 Application Alerts Table
CREATE TABLE application_alerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    institution_id INT NOT NULL,
    subscribed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (institution_id) REFERENCES institutions(institution_id) ON DELETE CASCADE,
    UNIQUE (user_id, institution_id)
);

-- 2.5 Payments Table
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    application_id INT NOT NULL,
    user_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('Card', 'EFT', 'PayFast', 'Simulated') DEFAULT 'Simulated',
    transaction_ref VARCHAR(100) UNIQUE NOT NULL,
    payment_status ENUM('Completed', 'Failed', 'Pending') DEFAULT 'Completed',
    paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (application_id) REFERENCES applications(application_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 2.6 Job Listings Table
CREATE TABLE job_listings (
    job_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    company_name VARCHAR(150) NOT NULL,
    province VARCHAR(50) NOT NULL,
    job_type ENUM('Full-time', 'Internship', 'Learnership') DEFAULT 'Internship',
    field_of_study VARCHAR(100) NOT NULL,
    application_link VARCHAR(255)
);

-- ==========================================================================
-- 3. DATA POPULATION (SEED DATA)
-- ==========================================================================

-- 3.1 Insert Tertiary Institutions with Direct Portal URLs
INSERT INTO institutions (
    name, institution_type, province, application_status, application_fee, 
    opening_date, closing_date, website_url, application_url
)
VALUES 
(
    'University of Cape Town (UCT)', 'University', 'Western Cape', 'Open', 100.00, 
    '2026-04-01', '2026-09-30', 'https://www.uct.ac.za', 'https://applyonline.uct.ac.za/'
),
(
    'Stellenbosch University (SU)', 'University', 'Western Cape', 'Open', 100.00, 
    '2026-04-01', '2026-08-31', 'https://www.sun.ac.za', 'https://www.sun.ac.za/english/matries/apply'
),
(
    'Cape Peninsula University of Technology (CPUT)', 'University', 'Western Cape', 'Open', 150.00, 
    '2026-05-01', '2026-09-30', 'https://www.cput.ac.za', 'https://www.cput.ac.za/study/apply'
),
(
    'False Bay TVET College', 'TVET College', 'Western Cape', 'Open', 0.00, 
    '2026-01-15', '2026-10-31', 'https://www.falsebaycollege.co.za', 'https://www.falsebaycollege.co.za/apply'
),
(
    'Eduvos (Tyger Valley Campus)', 'Private College', 'Western Cape', 'Open', 0.00, 
    '2026-01-01', '2026-12-31', 'https://www.eduvos.com', 'https://www.eduvos.com/apply/'
),
(
    'University of the Witwatersrand (Wits)', 'University', 'Gauteng', 'Open', 100.00, 
    '2026-03-01', '2026-09-30', 'https://www.wits.ac.za', 'https://www.wits.ac.za/undergraduate/apply-to-wits/'
),
(
    'University of Johannesburg (UJ)', 'University', 'Gauteng', 'Open', 0.00, 
    '2026-04-01', '2026-10-31', 'https://www.uj.ac.za', 'https://www.uj.ac.za/admission-aid/undergraduate/'
),
(
    'Tshwane University of Technology (TUT)', 'University', 'Gauteng', 'Open', 240.00, 
    '2026-04-01', '2026-09-30', 'https://www.tut.ac.za', 'https://www.tut.ac.za/study-at-tut/apply'
),
(
    'IIE Varsity College (Sandton)', 'Private College', 'Gauteng', 'Open', 400.00, 
    '2026-01-01', '2026-12-31', 'https://www.varsitycollege.co.za', 'https://www.varsitycollege.co.za/apply'
);

-- 3.2 Insert Test User
INSERT INTO users (full_name, email, password_hash, phone_number)
VALUES ('Test Student', 'student@example.com', 'hashed_password_123', '0821234567');

-- 3.3 Insert Test Applications
INSERT INTO applications (user_id, institution_id, payment_status, application_status, fee_amount)
VALUES 
(1, 1, 'Completed', 'Submitted', 100.00),
(1, 6, 'Pending', 'Draft', 100.00);

-- ==========================================================================
-- 4. VERIFICATION QUERIES
-- ==========================================================================

-- View all institutions with their application portal links
SELECT institution_id, name, province, application_fee, application_url 
FROM institutions 
ORDER BY name ASC;

-- View user application status summary
SELECT a.application_id, u.full_name, i.name AS institution, a.fee_amount, a.payment_status, a.application_status
FROM applications a
JOIN users u ON a.user_id = u.user_id
JOIN institutions i ON a.institution_id = i.institution_id;

INSERT INTO institutions (
    name, 
    institution_type, 
    province, 
    application_status, 
    application_fee, 
    opening_date, 
    closing_date, 
    website_url, 
    application_url
) VALUES 
-- Eastern Cape Institutions
('Rhodes University (RU)', 'University', 'Eastern Cape', 'Open', 100.00, '2026-04-01', '2026-09-30', 'https://www.ru.ac.za', 'https://ross.ru.ac.za/'),
('Nelson Mandela University (NMU)', 'University', 'Eastern Cape', 'Open', 0.00, '2026-04-01', '2026-09-30', 'https://www.mandela.ac.za', 'https://applyonline.mandela.ac.za/'),
('University of Fort Hare (UFH)', 'University', 'Eastern Cape', 'Open', 0.00, '2026-04-01', '2026-10-31', 'https://www.ufh.ac.za', 'https://www.ufh.ac.za/apply/'),
('Walter Sisulu University (WSU)', 'University', 'Eastern Cape', 'Open', 0.00, '2026-04-01', '2026-09-30', 'https://www.wsu.ac.za', 'https://connect.wsu.ac.za/'),

-- KwaZulu-Natal
('University of KwaZulu-Natal (UKZN)', 'University', 'KwaZulu-Natal', 'Open', 210.00, '2026-04-01', '2026-09-30', 'https://www.ukzn.ac.za', 'https://cao.ac.za/'),
('Durban University of Technology (DUT)', 'University', 'KwaZulu-Natal', 'Open', 220.00, '2026-04-01', '2026-09-30', 'https://www.dut.ac.za', 'https://cao.ac.za/'),

-- Free State
('University of the Free State (UFS)', 'University', 'Free State', 'Open', 0.00, '2026-04-01', '2026-09-30', 'https://www.ufs.ac.za', 'https://apply.ufs.ac.za/'),

-- Limpopo & Mpumalanga
('University of Limpopo (UL)', 'University', 'Limpopo', 'Open', 200.00, '2026-04-01', '2026-09-30', 'https://www.ul.ac.za', 'https://www.ul.ac.za/index.php?entity=apply'),
('University of Mpumalanga (UMP)', 'University', 'Mpumalanga', 'Open', 150.00, '2026-04-01', '2026-11-30', 'https://www.ump.ac.za', 'https://www.ump.ac.za/apply-now');