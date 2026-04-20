# Pwnshop

> **Authorized security training use only.**
> This application contains deliberate, known vulnerabilities. Do not deploy it on a public-facing or production server. Keep your repository private.

Pwnshop is an intentionally vulnerable Nigerian e-commerce platform built for hands-on web application penetration testing training. It covers 41 vulnerabilities mapped to the OWASP Top 10 (2025) and OWASP LLM Top 10, including SQL injection, stored XSS, SSRF, SSTI leading to RCE, prototype pollution, path traversal, and AI/LLM-specific attack chains.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Runtime | Node.js 14+ |
| Framework | Express.js |
| Templating | EJS |
| Database | MySQL 5.7 |
| Authentication | bcryptjs + express-session |
| File Uploads | Multer |
| PDF Generation | PDFKit |
| AI Chatbot | Groq API (LLaMA 3.3 70B) |
| Utility | Lodash 4.17.4 (intentionally outdated - CVE-2019-10744) |
| Containerisation | Docker + Docker Compose |

---

## Project Structure

```
pwnshop/
├── docker/
│   ├── Dockerfile
│   └── docker-compose.yml
├── public/
│   ├── uploads/          # User-uploaded files (avatars, product images)
│   ├── storage/          # Invoice PDFs
│   └── images/           # Default product images
├── src/
│   ├── app.js            # Main Express application (all routes)
│   └── views/            # EJS templates
├── pwnshop.sql           # Full schema + seed data
├── package.json
├── .env.example
└── README.md
```

---

## Prerequisites

### Without Docker
- Node.js v16 or higher
- MySQL 5.7 or 8.x
- npm v8 or higher
- Groq API key - required only for the AI chatbot (free at [console.groq.com](https://console.groq.com))

### With Docker
- Docker v20+
- Docker Compose v2+
- Groq API key (optional - chatbot will not function without it)

---

## Installation

### Without Docker

```bash
# 1. Clone the repository
git clone https://github.com/r007sec/pwnshop.git
cd pwnshop

# 2. Install dependencies
npm install

# 3. Configure environment
cp .env.example .env
# Edit .env and add your GROQ_API_KEY

# 4. Create database and import schema
mysql -u root -p -e "CREATE DATABASE pwnshop;"
mysql -u root -p pwnshop < pwnshop.sql

# 5. Start the application
npm start          # production
npm run dev        # development (auto-restart via nodemon)
```

### With Docker

```bash
git clone https://github.com/r007sec/pwnshop.git
cd pwnshop

cp .env.example .env
# Edit .env and add your GROQ_API_KEY

# Start app + database (schema is imported automatically on first run)
docker compose -f docker/docker-compose.yml up -d

# Follow logs
docker compose -f docker/docker-compose.yml logs -f
```

> On first boot, wait approximately 15–20 seconds for MySQL to initialise before the app connects successfully.

To stop:
```bash
docker compose -f docker/docker-compose.yml down
```

To stop and wipe the database volume entirely:
```bash
docker compose -f docker/docker-compose.yml down -v
```

The application is available at `http://localhost:3000` in both setups.

---

## Environment Variables

```env
# Required for AI chatbot - get a free key at https://console.groq.com
GROQ_API_KEY=your_groq_api_key_here

# Server port (default: 3000)
PORT=3000
```

> Database credentials are read from environment variables (`DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`). They fall back to `localhost / root / root / pwnshop` when running without Docker. The hardcoded fallback values are themselves a training vulnerability (PWN-018).

---

## Default Accounts

These accounts are seeded and preserved across lab resets. Passwords are in `pwnshop.sql`.

| Role | Username | Notes |
|---|---|---|
| Admin | `admin` | Full admin panel access |
| Seller | `alice` | Active product listings |
| Seller | `bob` | Active product listings |
| User | `charlie` | Regular buyer account |
| User | `diana` | Regular buyer account |

All seed users start with a wallet balance of ₦10,000.

To obtain admin credentials without checking the SQL file, exploit PWN-009 (SQL injection on `/admin/login`) or PWN-021 (mass assignment on `/register`).

---

## Key URLs

| URL | Description |
|---|---|
| `/` | Homepage |
| `/login` | User login |
| `/register` | Registration |
| `/admin/login` | Admin panel login |
| `/vulnerabilities` | Full interactive vulnerability index |
| `/reset` | Lab reset tool (instructor use) |
| `/debug/info` | Debug endpoint - intentionally public (PWN-018) |
| `/api/v1/events` | Audit log - unauthenticated JSON (PWN-005) |

---

## Application Features

**Buyers** can browse and search products (search is SQLi-vulnerable), manage a cart, apply coupons, pay via wallet, track orders with a live map, maintain a wishlist, write reviews (stored XSS vector), and use the in-app mail inbox (PwnMail) for OTPs and notifications.

**Sellers** can register from any user account, manage product listings with file upload, and customise a storefront description with a live preview (SSTI → RCE vector).

**Admins** have a full management panel covering users, orders, products, reviews, coupons, audit logs, CSV export, and platform statistics.

---

## Vulnerability Index

41 vulnerabilities are documented in-app at `/vulnerabilities`. A summary is below.

| ID | Title | Severity | Category |
|---|---|---|---|
| PWN-001 | IDOR - Order Details | High | A01:2025 |
| PWN-002 | IDOR - Order Tracking (No Auth) | High | A01:2025 |
| PWN-003 | IDOR - Wishlist | Medium | A01:2025 |
| PWN-004 | IDOR - PwnMail Inbox | High | A01:2025 |
| PWN-005 | Public Audit Log - No Authentication | Info | A01:2025 |
| PWN-006 | Weak Session Secret (Hardcoded + Exposed) | Critical | A04:2025 |
| PWN-007 | Session Cookie Missing HttpOnly / Secure Flags | Medium | A04:2025 |
| PWN-008 | SQL Injection - Login (Authentication Bypass) | Critical | A05:2025 |
| PWN-009 | SQL Injection - Admin Login | Critical | A05:2025 |
| PWN-010 | SQL Injection - Product Search | High | A05:2025 |
| PWN-011 | Stored XSS - Product Reviews | High | A05:2025 |
| PWN-012 | Stored XSS via SVG Avatar Upload | Medium | A05:2025 |
| PWN-013 | CSV Injection - Order Export | Medium | A05:2025 |
| PWN-014 | Second-Order SQLi - Audit Log Search | Medium | A05:2025 |
| PWN-015 | Predictable OTP - Brute-Forceable 2FA | High | A06:2025 |
| PWN-016 | Coupon Category Restriction Bypass | Medium | A06:2025 |
| PWN-017 | Open Redirect - Login & Register | Medium | A06:2025 |
| PWN-018 | Debug Endpoint - Credentials Exposed Publicly | Critical | A02:2025 |
| PWN-019 | Verbose Error Stack Traces in Responses | Medium | A02:2025 |
| PWN-020 | No Security Headers | Info | A02:2025 |
| PWN-021 | Mass Assignment - Self-Assigned Admin Role | High | A07:2025 |
| PWN-022 | No Account Lockout or Rate Limiting | Medium | A07:2025 |
| PWN-023 | No Password Policy | Info | A07:2025 |
| PWN-024 | OTP Not Invalidated on New Request | Medium | A07:2025 |
| PWN-025 | File Upload - MIME Type Spoofing | High | A08:2025 |
| PWN-026 | CSRF - Account Self-Deletion | Medium | A08:2025 |
| PWN-027 | Plaintext Passwords Written to Audit Log | Medium | A09:2025 |
| PWN-028 | Spoofable IP Addresses in Audit Log | Info | A09:2025 |
| PWN-029 | SSRF - Avatar URL Fetched Server-Side | High | A10:2025 |
| PWN-030 | Seller Earnings Logic Bug | Medium | Logic |
| PWN-031 | Direct Prompt Injection - System Prompt Extraction | Critical | LLM01 |
| PWN-032 | Indirect Prompt Injection via Product Descriptions | High | LLM01 |
| PWN-033 | Sensitive User Data Injected into System Prompt | High | LLM02 |
| PWN-034 | DOM XSS via Unsanitised AI Response | High | LLM05 |
| PWN-035 | IDOR via AI Order Lookup Tool | Medium | LLM06 |
| PWN-036 | No Rate Limiting on AI Endpoint | Medium | LLM10 |
| PWN-037 | Username Enumeration | Medium | A07:2025 |
| PWN-038 | Path Traversal - Invoice Download | High | A02:2025 |
| PWN-039 | HTTP Parameter Pollution - Coupon Bypass | Medium | A06:2025 |
| PWN-040 | SSTI → RCE - Seller Storefront Preview | **Critical** | A05:2025 |
| PWN-041 | Prototype Pollution - Lodash Dependency | High | A03:2025 |

### Notable Attack Chains

**Full account takeover**
`PWN-018` (debug endpoint leaks session secret) → `PWN-006` (forge session cookie) → impersonate any user

**Remote code execution**
Register any account → visit `/register-seller` → submit to `/seller/preview?template=` with a Node.js `child_process` payload

**AI-assisted XSS**
Seller embeds payload in product description → `PWN-032` (indirect prompt injection into chatbot) → `PWN-034` (DOM XSS via `innerHTML`) → victim session exfiltrated

**Privilege escalation without SQLi**
`POST /register` with `role=admin` in the request body (`PWN-021`) → instant admin account

---

## Resetting the Lab

The reset tool at `/reset` wipes all student-created data while preserving seed accounts, demo products, and demo coupons. Use it between cohorts or practice sessions.

Deleted on reset: all non-seed user accounts, orders, order items, tracking events, cart items, wishlists, reviews, OTP codes, PwnMail messages, password reset tokens, non-seed products, non-seed coupons, coupon usage records, and seller earnings.

Preserved on reset: admin account, seed users (IDs 1–5), seed products (IDs 1–11), seed coupons (IDs 1–5), seed wallet balances.

To reset the database from the command line:

```bash
mysql -u root -p -e "DROP DATABASE pwnshop; CREATE DATABASE pwnshop;"
mysql -u root -p pwnshop < pwnshop.sql
```

---

## Common Issues

**"Database connection failed" on startup** - MySQL is not running, or the `pwnshop` database does not exist. Run the database setup steps above.

**"AI assistant is not configured"** - `GROQ_API_KEY` in `.env` is missing or incorrect. Obtain a free key at [console.groq.com](https://console.groq.com).

**Docker: app exits immediately after start** - MySQL takes 15–20 seconds to initialise. The updated `docker-compose.yml` includes a healthcheck that prevents the app container from starting until MySQL is ready. Pull the latest compose file if you see this.

**Why is Lodash pinned to `4.17.4`?** - It is intentionally outdated to demonstrate CVE-2019-10744 (prototype pollution via `_.merge()`). Do not upgrade it.

---

## Legal Notice

Pwnshop is designed exclusively for security education in controlled lab environments. Testing vulnerabilities against systems you do not own or have explicit written permission to assess is illegal. The authors accept no liability for misuse.

---

*Built for the CTF Security training programme.*
