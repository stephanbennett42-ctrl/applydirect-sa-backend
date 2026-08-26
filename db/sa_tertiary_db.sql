CREATE DATABASE IF NOT EXISTS sa_tertiary_db;
USE sa_tertiary_db;

-- 1. Users Table (Customer Authentication)
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(15),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Institutions Table (Products/Services Offered)[cite: 1]
CREATE TABLE institutions (
    institution_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    institution_type ENUM('University', 'TVET College') NOT NULL,
    province VARCHAR(50) NOT NULL,
    application_status ENUM('Open', 'Closed', 'Opening Soon') DEFAULT 'Closed',
    application_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    opening_date DATE,
    closing_date DATE,
    website_url VARCHAR(255)
);

-- 3. Applications Table (Order & Payment Processing)[cite: 1]
CREATE TABLE applications (
    application_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    institution_id INT NOT NULL,
    payment_status ENUM('Pending', 'Completed', 'Failed') DEFAULT 'Pending',
    application_status ENUM('Draft', 'Submitted', 'Under Review', 'Accepted') DEFAULT 'Draft',
    fee_amount DECIMAL(10,2) NOT NULL,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (institution_id) REFERENCES institutions(institution_id) ON DELETE CASCADE
);

CREATE TABLE application_alerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    institution_id INT NOT NULL,
    subscribed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (institution_id) REFERENCES institutions(institution_id) ON DELETE CASCADE,
    UNIQUE (user_id, institution_id)
);

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

CREATE TABLE job_listings (
    job_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    company_name VARCHAR(150) NOT NULL,
    province VARCHAR(50) NOT NULL,
    job_type ENUM('Full-time', 'Internship', 'Learnership') DEFAULT 'Internship',
    field_of_study VARCHAR(100) NOT NULL,
    application_link VARCHAR(255)
);
ALTER TABLE applications 
ADD CONSTRAINT unique_user_institution UNIQUE (user_id, institution_id);

-- 4. Seed Institutions Data[cite: 1]
INSERT INTO institutions (name, institution_type, province, application_status, application_fee, opening_date, closing_date)
VALUES 
('University of Cape Town (UCT)', 'University', 'Western Cape', 'Open', 100.00, '2026-04-01', '2026-09-30'),
('University of the Witwatersrand (Wits)', 'University', 'Gauteng', 'Open', 100.00, '2026-03-01', '2026-09-30'),
('Cape Peninsula University of Technology (CPUT)', 'University', 'Western Cape', 'Closed', 150.00, '2026-05-01', '2026-08-15'),
('False Bay TVET College', 'TVET College', 'Western Cape', 'Open', 0.00, '2026-01-15', '2026-10-31');

-- 5. Insert Test User[cite: 1]
INSERT INTO users (full_name, email, password_hash, phone_number)
VALUES ('Test Student', 'student@example.com', 'hashed_password_123', '0821234567');

-- 6. Insert Test Applications[cite: 1]
INSERT INTO applications (user_id, institution_id, payment_status, application_status, fee_amount)
VALUES 
(1, 1, 'Completed', 'Submitted', 100.00),
(1, 2, 'Pending', 'Draft', 100.00);

-- 7. Test Queries
-- View open institutions
SELECT * FROM institutions WHERE application_status = 'Open' ORDER BY name ASC;

-- View student application dashboard[cite: 1]
SELECT a.application_id, i.name AS institution, a.fee_amount, a.payment_status, a.applied_at
FROM applications a
JOIN institutions i ON a.institution_id = i.institution_id
WHERE a.user_id = 1;

-- 1. Remove existing duplicate records
DELETE FROM applications WHERE application_id > 0;

-- 2. Apply the unique constraint
ALTER TABLE applications 
ADD CONSTRAINT unique_user_institution UNIQUE (user_id, institution_id);