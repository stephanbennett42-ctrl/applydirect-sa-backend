USE sa_tertiary_db;

INSERT INTO institutions 
  (name, institution_type, province, application_status, application_fee, opening_date, closing_date, website_url)
VALUES 
  ('Stellenbosch University (SU)', 'University', 'Western Cape', 'Closed', 100.00, '2026-04-01', '2026-07-31', 'https://www.sun.ac.za'),
  ('University of Johannesburg (UJ)', 'University', 'Gauteng', 'Open', 0.00, '2026-04-01', '2026-09-30', 'https://www.uj.ac.za'),
  ('North-West University (NWU)', 'University', 'North West', 'Open', 0.00, '2026-04-01', '2026-09-30', 'https://www.nwu.ac.za');