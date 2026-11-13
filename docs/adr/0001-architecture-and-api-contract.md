# ADR 0001: Architecture and API contract

- **Status:** Proposed (accepted when both leads sign off below)
- **Date:** 2026-11-13
- **Issue:** #13 (T02)
- **Related:** Software Architecture Document, iteration 1

## Context

WE LEAD wants a donation page that is built separately from its Joomla site (joinwelead.org) and linked from it, plus a password-protected admin area with CSV export. The product owners confirmed:

- individual donors only;
- amounts from 5 to 10,000 EUR;
- monthly donors cancel through a self-service link;
- the team hosts the application itself;
- Viva is the payment provider.

Five people in three tracks have to build in parallel from week 6, so the stack, hosting, folder layout and API need to be fixed now.

## Decisions

### 1. Stack

| Part | Choice |
|---|---|
| Front ends | Two React single-page apps in TypeScript (`public-web`, `admin-web`), built with Vite, translated with react-i18next (English now, Greek-ready) |
| Back end | Node.js + Express in TypeScript |
| Database | PostgreSQL, schema and migrations managed with Prisma |
| Payments | Viva Smart Checkout (hosted payment page). No card data reaches our servers |
| E-mail | Nodemailer over SMTP; Mailpit as test inbox in development |
| Tests | Unit tests in each app; Playwright for end-to-end |
| CI | GitHub Actions: lint, test, build on every pull request |

### 2. Staff authentication

- Staff log in with e-mail and password. Passwords are hashed with argon2.
- On login the API sets a signed JWT in an HTTP-only, Secure, `SameSite=Strict` cookie named `wl_session`, valid for 8 hours.
- The token carries the user id and role, `MANAGER` or `REPORTER`.
- Every admin and reporting endpoint checks the token and the role. Login is rate limited.
- There is no public sign-up; staff accounts come from seed data.

### 3. Payments

- The API creates a Viva payment order and returns the checkout URL. The browser goes to Viva and comes back to the public app's result page.
- A donation becomes `PAID` only through Viva's webhook, after the API has fetched the transaction from Viva and checked the order code and amount.
- Notifications are stored once per transaction and event type, so repeated notifications are harmless.
- **Monthly donations:** the first payment is made with recurring enabled. A daily renewal job inside the API charges each due subscription through Viva's API using the first transaction. Viva does not schedule these charges by itself.
- All Viva-specific code lives in `apps/api/src/providers/viva`, behind a `PaymentProvider` interface.

### 4. Hosting

- Everything runs with Docker Compose. There are four containers: `web` (Nginx, static files, `/api` proxy), `api`, `db` (PostgreSQL) and `mail` (test inbox), plus `mock` (Prism) for front-end work.
- The same set-up is used locally and for the demo. The demo runs on a free or student hosting tier with HTTPS and Viva in test mode; the provider is chosen in T25 (#36).
- Configuration comes from environment variables; secrets are never committed.
- Viva's webhook needs a public HTTPS URL, so local testing of payments uses a tunnel or the demo host.

### 5. Folder layout

```
apps/
  public-web/        React donor app
  admin-web/         React staff app
  api/               Express API
    src/
      routes/  middleware/  modules/  providers/viva/  jobs/
    db/              Prisma schema, migrations, seed
packages/
  ui/                shared components and brand tokens
  api-client/        types generated from openapi.yaml (do not edit)
openapi/
  openapi.yaml       API contract v1
e2e/                 Playwright tests
docs/
  adr/               architecture decision records
docker-compose.yml
.github/workflows/
```

Rules:

- Apps never import each other's code; the OpenAPI file is the only thing the front ends and the API share.
- Provider-specific code is allowed only in `providers/viva`.

### 6. API contract

`openapi/openapi.yaml` (OpenAPI 3.1) is the single source of truth between front end and back end. Conventions:

- Base path `/api/v1`, JSON in and out, except the CSV exports.
- Amounts are integer euro cents (`500` to `1000000`); dates are ISO 8601 in UTC.
- Donations are identified publicly by a random `ref`, never by a database id.
- Errors use one shape: `{ "error": { "code", "message", "details" } }`.
- Lists use `page` and `pageSize` (default 25, max 100) and return `{ items, page, pageSize, total }`.
- Endpoints are grouped by tag: Public, Payments, Auth, Admin (`MANAGER`), Reports (`MANAGER`, `REPORTER`), System.
- Reporters get only aggregated figures; their CSV export contains monthly totals, not donor data.

Change rule: any change to `openapi.yaml` is made in a pull request approved by both the back-end lead and the front-end lead. Breaking changes need a new version (`/api/v2`) or a note agreed by both leads.

## Consequences

- The front-end team builds against the mock server (`prism mock openapi/openapi.yaml`) from week 6, before the API is ready (T08, #19).
- One language (TypeScript) across the code base, and API types are generated, so contract drift fails the build.
- Switching from Viva to Stripe touches only the provider module.
- The renewal job adds a scheduled task that must be tested (T12, #23); the assumption in #23 that the provider renews by itself is replaced by this decision.
- Still open, handled later: receipts (#8), newsletter connection (#9), demo host (#36).

## Sign-off

| Role | Name | Date |
|---|---|---|
| Back-end lead | | |
| Front-end lead | | |
