-- ------------------------------------------------------------
-- PAYMENTS
-- ------------------------------------------------------------
 
-- People who donate.
CREATE TABLE donors (
    id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name            text NOT NULL,
    email                text NOT NULL UNIQUE,      -- no two donors can share an email
    newsletter_opt_in    boolean NOT NULL DEFAULT false,
    opt_in_at            timestamptz,               -- when they agreed to the newsletter
    consent_text_version text,                      -- which wording they agreed to
    created_at           timestamptz NOT NULL DEFAULT now()
);
 
-- Recurring donations (for example 15 EUR every month).
-- One donor can have many subscriptions.
CREATE TABLE subscriptions (
    id                     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    donor_id               uuid NOT NULL REFERENCES donors (id),
    amount_cents           integer NOT NULL,        -- 1500 means 15.00
    currency               char(3) NOT NULL,        -- for example EUR
    billing_interval       text NOT NULL,           -- monthly or yearly
    status                 text NOT NULL,           -- active or cancelled
    initial_transaction_id text,
    next_charge_on         date,                    -- when the next payment is due
    cancel_token_hash      text,                    -- used by the "cancel" link
    created_at             timestamptz NOT NULL DEFAULT now(),
    cancelled_at           timestamptz
);
 
-- Every payment: one-off, or one charge from a subscription.
-- One donor can make many donations.
CREATE TABLE donations (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    public_ref              text NOT NULL UNIQUE,   -- short code shown to the donor
    donor_id                uuid NOT NULL REFERENCES donors (id),
    subscription_id         uuid REFERENCES subscriptions (id),  -- empty for one-off donations
    amount_cents            integer NOT NULL,
    currency                char(3) NOT NULL,
    type                    text NOT NULL,          -- one_off, recurring_initial or recurring_renewal
    status                  text NOT NULL,          -- pending, paid or failed
    provider_order_code     text NOT NULL UNIQUE,   -- order ID from the payment provider
    provider_transaction_id text,
    locale                  text,                   -- language, for example en or el
    created_at              timestamptz NOT NULL DEFAULT now(),
    paid_at                 timestamptz
);
 
-- Messages the payment provider sends us about a payment.
-- One donation can have many events.
CREATE TABLE payment_events (
    id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    donation_id             uuid REFERENCES donations (id),  -- can be empty if we can't match it yet
    provider_order_code     text NOT NULL,
    event_type              text NOT NULL,
    provider_transaction_id text,
    payload                 jsonb NOT NULL,         -- the full message, saved as JSON
    received_at             timestamptz NOT NULL DEFAULT now(),
    processed_at            timestamptz             -- empty until we have handled it
);
 
 
-- ------------------------------------------------------------
-- ADMIN
-- ------------------------------------------------------------
 
-- People who log in to manage the website.
CREATE TABLE users (
    id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    email         text NOT NULL UNIQUE,
    password_hash text NOT NULL,                    -- scrambled password, never the real one
    role          text NOT NULL,                    -- admin or editor
    active        boolean NOT NULL,
    last_login_at timestamptz
);
 
-- Text on the website that admins can edit.
-- The same key can exist once per language.
CREATE TABLE content_blocks (
    key        text NOT NULL,                       -- for example home.hero_title
    locale     text NOT NULL,                       -- for example en or el
    value      text NOT NULL,                       -- the actual text
    updated_by uuid REFERENCES users (id),          -- who edited it last
    updated_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (key, locale)
);