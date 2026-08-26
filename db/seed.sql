USE sa_tertiary_db;

-- 1. Expand column size to allow longer institution type names
ALTER TABLE institutions MODIFY COLUMN institution_type VARCHAR(50);

-- 2. Temporarily disable foreign key checks
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE institutions;

-- 3. Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO institutions 
  (name, institution_type, province, application_status, application_fee, opening_date, closing_date, website_url)
VALUES 
  -- WESTERN CAPE
  ('University of Cape Town (UCT)', 'University', 'Western Cape', 'Open', 100.00, '2026-04-01', '2026-09-30', 'https://www.uct.ac.za'),
  ('Stellenbosch University (SU)', 'University', 'Western Cape', 'Closed', 100.00, '2026-04-01', '2026-07-31', 'https://www.sun.ac.za'),
  ('Cape Peninsula University of Technology (CPUT)', 'University', 'Western Cape', 'Closed', 150.00, '2026-05-01', '2026-08-31', 'https://www.cput.ac.za'),
  ('False Bay TVET College', 'TVET College', 'Western Cape', 'Open', 0.00, '2026-01-15', '2026-10-31', 'https://www.falsebaycollege.co.za'),
  ('Eduvos (Tyger Valley Campus)', 'Private College', 'Western Cape', 'Open', 0.00, '2026-01-01', '2026-11-30', 'https://www.eduvos.com'),

  -- GAUTENG
  ('University of the Witwatersrand (Wits)', 'University', 'Gauteng', 'Open', 100.00, '2026-03-01', '2026-09-30', 'https://www.wits.ac.za'),
  ('University of Johannesburg (UJ)', 'University', 'Gauteng', 'Open', 0.00, '2026-04-01', '2026-10-31', 'https://www.uj.ac.za'),
  ('Tshwane University of Technology (TUT)', 'University', 'Gauteng', 'Open', 240.00, '2026-04-01', '2026-09-30', 'https://www.tut.ac.za'),
  ('IIE Varsity College (Sandton)', 'Private College', 'Gauteng', 'Open', 400.00, '2026-01-01', '2026-12-15', 'https://www.varsitycollege.co.za'),
  ('MANCOSA (Johannesburg Campus)', 'Private College', 'Gauteng', 'Open', 0.00, '2026-01-01', '2026-11-30', 'https://www.mancosa.co.za'),

  -- KWAZULU-NATAL
  ('University of KwaZulu-Natal (UKZN)', 'University', 'KwaZulu-Natal', 'Open', 210.00, '2026-04-01', '2026-09-30', 'https://www.ukzn.ac.za'),
  ('Durban University of Technology (DUT)', 'University', 'KwaZulu-Natal', 'Open', 220.00, '2026-04-01', '2026-09-30', 'https://www.dut.ac.za'),

  -- EASTERN CAPE
  ('Nelson Mandela University (NMU)', 'University', 'Eastern Cape', 'Open', 0.00, '2026-04-01', '2026-09-30', 'https://www.mandela.ac.za'),

  -- FREE STATE
  ('University of the Free State (UFS)', 'University', 'Free State', 'Open', 0.00, '2026-04-01', '2026-09-30', 'https://www.ufs.ac.za'),

  -- NORTH WEST
  ('North-West University (NWU)', 'University', 'North West', 'Open', 0.00, '2026-04-01', '2026-09-30', 'https://www.nwu.ac.za'),

  -- LIMPOPO
  ('University of Limpopo (UL)', 'University', 'Limpopo', 'Open', 200.00, '2026-04-01', '2026-09-30', 'https://www.ul.ac.za'),

  -- MPUMALANGA
  ('University of Mpumalanga (UMP)', 'University', 'Mpumalanga', 'Open', 150.00, '2026-04-01', '2026-11-30', 'https://www.ump.ac.za'),

  -- NORTHERN CAPE
  ('Sol Plaatje University (SPU)', 'University', 'Northern Cape', 'Open', 100.00, '2026-04-01', '2026-11-30', 'https://www.spu.ac.za');