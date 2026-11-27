-- seed data (fake, for local development and demos). Run after schema.sql.
 
-- users (password for all: admin-demo-pw)
 
INSERT INTO users (id, email, password_hash, role, active, last_login_at) VALUES
('55555555-5555-5555-5555-555555555551', 'admin@example.org',  '$2b$12$CmUQjbIUs36FZjRKQjCzxeZ9SjgrhAhedg92LHboaoIN0yVA4ktpe', 'admin',  true,  '2026-11-24 09:00:00'),
('55555555-5555-5555-5555-555555555552', 'editor@example.org', '$2b$12$CmUQjbIUs36FZjRKQjCzxeZ9SjgrhAhedg92LHboaoIN0yVA4ktpe', 'editor', true,  NULL),
('55555555-5555-5555-5555-555555555553', 'former@example.org', '$2b$12$CmUQjbIUs36FZjRKQjCzxeZ9SjgrhAhedg92LHboaoIN0yVA4ktpe', 'editor', false, '2026-08-01 12:00:00');
 
-- content_blocks
 
INSERT INTO content_blocks (key, locale, value, updated_by, updated_at) VALUES
('home.hero_title',    'en', 'Help a young leader take the next step', '55555555-5555-5555-5555-555555555551', '2026-11-10 10:00:00'),
('home.hero_title',    'el', 'Βοήθησε έναν νέο ηγέτη να κάνει το επόμενο βήμα', '55555555-5555-5555-5555-555555555551', '2026-11-10 10:00:00'),
('home.hero_subtitle', 'en', 'Every donation funds mentoring and training.', '55555555-5555-5555-5555-555555555552', '2026-11-12 10:00:00'),
('donate.thank_you',   'en', 'Thank you for your generosity!', NULL, '2026-11-01 10:00:00'),
('newsletter.consent', 'en', 'I agree to receive occasional email updates and can unsubscribe at any time.', '55555555-5555-5555-5555-555555555551', '2026-10-15 10:00:00');
 
-- donors
 
INSERT INTO donors (id, full_name, email, newsletter_opt_in, opt_in_at, consent_text_version, created_at) VALUES
('11111111-1111-1111-1111-111111111111', 'Maria Papadaki', 'maria@example.org', true,  '2026-09-25 10:00:00', 'v1', '2026-09-25 10:00:00'),
('11111111-1111-1111-1111-111111111112', 'John Smith',     'john@example.org',  false, NULL,                  NULL, '2026-10-10 10:00:00'),
('11111111-1111-1111-1111-111111111113', 'Eleni Georgiou', 'eleni@example.org', true,  '2026-11-05 10:00:00', 'v1', '2026-11-05 10:00:00'),
('11111111-1111-1111-1111-111111111114', 'Amara Okafor',   'amara@example.org', false, NULL,                  NULL, '2026-11-20 10:00:00');
 
-- subscriptions (Maria: active monthly, John: cancelled, Eleni: active yearly)
 
INSERT INTO subscriptions (id, donor_id, amount_cents, currency, billing_interval, status, initial_transaction_id, next_charge_on, cancel_token_hash, created_at, cancelled_at) VALUES
('22222222-2222-2222-2222-222222222221', '11111111-1111-1111-1111-111111111111', 1500,  'EUR', 'monthly', 'active',    'TX-INIT-0001', '2026-12-25', 'demo-cancel-hash-1', '2026-09-25 10:00:00', NULL),
('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111112', 1000,  'EUR', 'monthly', 'cancelled', 'TX-INIT-0002', NULL,         'demo-cancel-hash-2', '2026-10-10 10:00:00', '2026-11-15 10:00:00'),
('22222222-2222-2222-2222-222222222223', '11111111-1111-1111-1111-111111111113', 12000, 'EUR', 'yearly',  'active',    'TX-INIT-0003', '2027-11-05', 'demo-cancel-hash-3', '2026-11-05 10:00:00', NULL);
 
-- donations (one-off: paid, pending, failed; then recurring payments)
 
INSERT INTO donations (id, public_ref, donor_id, subscription_id, amount_cents, currency, type, status, provider_order_code, provider_transaction_id, locale, created_at, paid_at) VALUES
('33333333-3333-3333-3333-333333333331', 'DON-2026-0001', '11111111-1111-1111-1111-111111111112', NULL, 2500, 'EUR', 'one_off', 'paid',    'ORDER-1001', 'TX-1001', 'en', '2026-10-11 10:00:00', '2026-10-11 10:01:00'),
('33333333-3333-3333-3333-333333333332', 'DON-2026-0002', '11111111-1111-1111-1111-111111111114', NULL, 5000, 'EUR', 'one_off', 'pending', 'ORDER-1002', NULL,      'en', '2026-11-25 12:00:00', NULL),
('33333333-3333-3333-3333-333333333333', 'DON-2026-0003', '11111111-1111-1111-1111-111111111114', NULL, 5000, 'EUR', 'one_off', 'failed',  'ORDER-1003', NULL,      'en', '2026-11-20 10:00:00', NULL),
('33333333-3333-3333-3333-333333333334', 'DON-2026-0004', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222221', 1500,  'EUR', 'recurring_initial', 'paid', 'ORDER-1004', 'TX-INIT-0001', 'el', '2026-09-25 10:00:00', '2026-09-25 10:01:00'),
('33333333-3333-3333-3333-333333333335', 'DON-2026-0005', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222221', 1500,  'EUR', 'recurring_renewal', 'paid', 'ORDER-1005', 'TX-1005',      'el', '2026-10-25 10:00:00', '2026-10-25 10:01:00'),
('33333333-3333-3333-3333-333333333336', 'DON-2026-0006', '11111111-1111-1111-1111-111111111112', '22222222-2222-2222-2222-222222222222', 1000,  'EUR', 'recurring_initial', 'paid', 'ORDER-1006', 'TX-INIT-0002', 'en', '2026-10-10 10:00:00', '2026-10-10 10:01:00'),
('33333333-3333-3333-3333-333333333337', 'DON-2026-0007', '11111111-1111-1111-1111-111111111113', '22222222-2222-2222-2222-222222222223', 12000, 'EUR', 'recurring_initial', 'paid', 'ORDER-1007', 'TX-INIT-0003', 'el', '2026-11-05 10:00:00', '2026-11-05 10:01:00');
 
-- payment_events (the last one is not matched to a donation or processed yet)
 
INSERT INTO payment_events (id, donation_id, provider_order_code, event_type, provider_transaction_id, payload, received_at, processed_at) VALUES
('44444444-4444-4444-4444-444444444441', '33333333-3333-3333-3333-333333333331', 'ORDER-1001', 'transaction.completed', 'TX-1001', '{"orderCode": "ORDER-1001", "status": "F", "amount": 2500}', '2026-10-11 10:01:00', '2026-10-11 10:01:05'),
('44444444-4444-4444-4444-444444444442', '33333333-3333-3333-3333-333333333333', 'ORDER-1003', 'transaction.failed',    NULL,      '{"orderCode": "ORDER-1003", "status": "E", "reason": "card_declined"}', '2026-11-20 10:01:00', '2026-11-20 10:01:05'),
('44444444-4444-4444-4444-444444444443', '33333333-3333-3333-3333-333333333335', 'ORDER-1005', 'transaction.completed', 'TX-1005', '{"orderCode": "ORDER-1005", "status": "F", "amount": 1500}', '2026-10-25 10:01:00', '2026-10-25 10:01:05'),
('44444444-4444-4444-4444-444444444444', NULL, 'ORDER-9999', 'transaction.completed', 'TX-9999', '{"orderCode": "ORDER-9999", "status": "F", "amount": 700}', '2026-11-25 12:30:00', NULL);
