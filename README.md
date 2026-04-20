# 🛒 Pwnshop — Intentionally Vulnerable E-Commerce Application

> ⚠️ **FOR AUTHORIZED SECURITY TRAINING USE ONLY**
> This application contains **deliberate, known vulnerabilities**. Never deploy it on a public-facing server or production environment. Keep your repository **private**.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation (Without Docker)](#installation-without-docker)
- [Installation (With Docker)](#installation-with-docker)
- [Environment Variables](#environment-variables)
- [Database Setup](#database-setup)
- [Running the Application](#running-the-application)
- [Default Accounts](#default-accounts)
- [Application Features](#application-features)
- [Vulnerability Index](#vulnerability-index)
- [Team Workflow](#team-workflow)
- [Resetting the Lab](#resetting-the-lab)
- [FAQ](#faq)

---

## Overview

Pwnshop is a fully functional Nigerian e-commerce platform built with deliberate security flaws for hands-on web application penetration testing training. It covers **41 vulnerabilities** across the OWASP Top 10 (2025) and OWASP LLM Top 10, including SQL injection, XSS, SSRF, SSTI leading to RCE, prototype pollution, and AI/LLM-specific attack vectors.

The application simulates a real-world shopping platform with:
- User registration, login with 2FA (OTP via in-app mail)
- Product listings, cart, checkout with wallet payments
- Seller dashboard with storefront customisation
- AI-powered support chatbot (Pwnie, powered by Groq/LLaMA)
- Admin panel with full user, order, and product management
- Order tracking with live map

---

## Tech Stack

| Layer | Technology |
|---|---|
| Runtime | Node.js |
| Framework | Express.js |
| Templating | EJS |
| Database | MySQL |
| Authentication | bcryptjs + express-session |
| File Uploads | Multer |
| PDF Generation | PDFKit |
| AI Chatbot | Groq API (LLaMA 3.3 70B) |
| Utility | Lodash 4.17.4 (intentionally vulnerable) |
| Containerisation | Docker + Docker Compose |

---

## Project Structure

```
pwnshop/
├── docker/                   # Docker configuration files
│   └── docker-compose.yml
├── public/                   # Static assets
│   ├── uploads/              # User-uploaded files (avatars, product images)
│   ├── storage/              # Invoice PDFs
│   └── images/               # Default product images
├── src/
│   ├── app.js                # Main Express application (all routes)
│   └── views/                # EJS templates
│       ├── home.ejs
│       ├── login.ejs
│       ├── register.ejs
│       ├── profile.ejs
│       ├── product-details.ejs
│       ├── cart.ejs
│       ├── checkout.ejs
│       ├── order-details.ejs
│       ├── track.ejs
│       ├── track-result.ejs
│       ├── seller-dashboard.ejs
│       ├── preview.ejs       # SSTI endpoint
│       ├── admin.ejs
│       ├── admin-login.ejs
│       ├── mail.ejs          # In-app inbox (OTPs, resets)
│       ├── invoice.ejs
│       ├── chat-widget.ejs   # AI chatbot widget
│       ├── vulnerabilities.ejs
│       └── ...
├── pwnshop.sql               # Full database schema + seed data
├── package.json
├── package-lock.json
├── .env.example
└── README.md
```

---

## Prerequisites

### Without Docker
- **Node.js** v16 or higher
- **MySQL** 5.7 or 8.x
- **npm** v8 or higher
- A **Groq API key** (free at [console.groq.com](https://console.groq.com)) — required only for the AI chatbot

### With Docker
- **Docker** v20+
- **Docker Compose** v2+
- A **Groq API key** (optional, chatbot won't work without it)

---

## Installation (Without Docker)

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/pwnshop.git
cd pwnshop
```

### 2. Install dependencies

```bash
npm install
```

### 3. Set up environment variables

```bash
cp .env.example .env
```

Edit `.env` and fill in your values (see [Environment Variables](#environment-variables)).

### 4. Set up the database

```bash
# Create the database
mysql -u root -p -e "CREATE DATABASE pwnshop;"

# Import schema and seed data
mysql -u root -p pwnshop < pwnshop.sql
```

### 5. Start the application

```bash
# Production
npm start

# Development (auto-restart on file changes)
npm run dev
```

The app will be available at **http://localhost:3000**

---

## Installation (With Docker)

### Should you include the `docker/` folder in GitHub?

**Yes, include it.** The Docker setup lets teammates spin up the full environment (app + MySQL) with a single command — no manual MySQL installation needed. It's the easiest onboarding path.

### Steps

```bash
git clone https://github.com/YOUR_USERNAME/pwnshop.git
cd pwnshop

# Copy environment file
cp .env.example .env
# Edit .env and add your GROQ_API_KEY

# Start everything (app + database)
docker compose -f docker/docker-compose.yml up -d

# On first run, wait ~15 seconds for MySQL to initialise, then check:
docker compose -f docker/docker-compose.yml logs -f
```

The app will be available at **http://localhost:3000**

To stop:
```bash
docker compose -f docker/docker-compose.yml down
```

To stop and wipe the database volume (full reset):
```bash
docker compose -f docker/docker-compose.yml down -v
```

---

## Environment Variables

Create a `.env` file in the project root based on `.env.example`:

```env
# Required for AI chatbot (get free key at https://console.groq.com)
GROQ_API_KEY=your_groq_api_key_here

# Server port (default: 3000)
PORT=3000
```

> **Note:** Database credentials (`host`, `user`, `password`, `database`) are currently hardcoded in `src/app.js` as `root / root / pwnshop`. This is intentional for the lab environment. The hardcoded credentials are themselves a training finding.

---

## Database Setup

The `pwnshop.sql` file contains:
- Full schema (all tables)
- Seed data: 5 demo users, 11 demo products, 5 demo coupons
- Pre-created admin account

### Seed User IDs (preserved on lab reset): 1–5
### Seed Product IDs (preserved on lab reset): 1–11
### Seed Coupon IDs (preserved on lab reset): 1–5

If you need to re-import from scratch:
```bash
mysql -u root -p -e "DROP DATABASE IF EXISTS pwnshop; CREATE DATABASE pwnshop;"
mysql -u root -p pwnshop < pwnshop.sql
```

---

## Running the Application

| Command | Description |
|---|---|
| `npm start` | Start in production mode |
| `npm run dev` | Start with nodemon (auto-restart) |

### Key URLs

| URL | Description |
|---|---|
| `http://localhost:3000/` | Homepage |
| `http://localhost:3000/login` | User login |
| `http://localhost:3000/register` | User registration |
| `http://localhost:3000/admin/login` | Admin login |
| `http://localhost:3000/vulnerabilities` | Full vulnerability index |
| `http://localhost:3000/reset` | Lab reset tool (instructor use) |
| `http://localhost:3000/debug/info` | Debug endpoint (intentionally public — a vulnerability) |
| `http://localhost:3000/api/v1/events` | Public audit log (intentionally unauthed — a vulnerability) |

---

## Default Accounts

> These are seeded accounts preserved across lab resets. Actual passwords are in `pwnshop.sql`.

| Role | Username | Notes |
|---|---|---|
| Admin | `admin` | Full admin panel access |
| Seller | `alice` | Has active product listings |
| Seller | `bob` | Has active product listings |
| User | `charlie` | Regular buyer account |
| User | `diana` | Regular buyer account |

All seed users start with **₦10,000** wallet balance.

To find the admin password, check `pwnshop.sql` or use the SQL injection vulnerability at `/admin/login` 😉

---

## Application Features

### For Buyers
- Browse products by category with sort options
- Product search (vulnerable to SQLi)
- Add to cart, update quantities, remove items
- Apply coupon codes at checkout
- Wallet-based payment system
- Order history and status tracking with live map
- Wishlist with shareable links
- Product reviews (vulnerable to stored XSS)
- In-app mail inbox (PwnMail) for OTPs and notifications
- AI chatbot support (Pwnie)

### For Sellers
- Register as a seller from any user account
- Add and edit product listings with image upload
- Storefront description editor with live preview (vulnerable to SSTI → RCE)
- Earnings dashboard with platform fee breakdown

### For Admins
- User management (promote to seller, top up wallets, delete users)
- Order management with status updates and tracking notes
- Product visibility toggle
- Review moderation
- Coupon creation and management
- Security audit log viewer
- CSV order export
- Stats dashboard

---

## Vulnerability Index

The application contains **41 known vulnerabilities**. A full interactive index is available in-app at `/vulnerabilities`.

### Quick Reference

| ID | Vulnerability | Severity | OWASP |
|---|---|---|---|
| PWN-001 | IDOR — Order Details | High | A01:2025 |
| PWN-002 | IDOR — Order Tracking (No Auth) | High | A01:2025 |
| PWN-003 | IDOR — Wishlist | Medium | A01:2025 |
| PWN-004 | IDOR — PwnMail Inbox | High | A01:2025 |
| PWN-005 | Public Audit Log | Info | A01:2025 |
| PWN-006 | Weak Session Secret (Hardcoded + Exposed) | Critical | A04:2025 |
| PWN-007 | Session Cookie Missing HttpOnly/Secure | Medium | A04:2025 |
| PWN-008 | SQL Injection — Login | Critical | A05:2025 |
| PWN-009 | SQL Injection — Admin Login | Critical | A05:2025 |
| PWN-010 | SQL Injection — Product Search | High | A05:2025 |
| PWN-011 | Stored XSS — Product Reviews | High | A05:2025 |
| PWN-012 | Stored XSS via SVG Avatar Upload | Medium | A05:2025 |
| PWN-013 | CSV Injection — Order Export | Medium | A05:2025 |
| PWN-014 | Second-Order SQLi — Audit Log Search | Medium | A05:2025 |
| PWN-015 | Predictable OTP — Brute-Forceable 2FA | High | A06:2025 |
| PWN-016 | Coupon Category Restriction Bypass | Medium | A06:2025 |
| PWN-017 | Open Redirect — Login & Register | Medium | A06:2025 |
| PWN-018 | Debug Endpoint — Credentials Exposed | Critical | A02:2025 |
| PWN-019 | Verbose Error Stack Traces | Medium | A02:2025 |
| PWN-020 | No Security Headers | Info | A02:2025 |
| PWN-021 | Mass Assignment — Self-Assigned Admin Role | High | A07:2025 |
| PWN-022 | No Account Lockout or Rate Limiting | Medium | A07:2025 |
| PWN-023 | No Password Policy | Info | A07:2025 |
| PWN-024 | OTP Not Invalidated on New Request | Medium | A07:2025 |
| PWN-025 | File Upload — MIME Type Spoofing | High | A08:2025 |
| PWN-026 | CSRF — Account Self-Deletion | Medium | A08:2025 |
| PWN-027 | Plaintext Passwords in Audit Log | Medium | A09:2025 |
| PWN-028 | Spoofable IP Addresses in Audit Log | Info | A09:2025 |
| PWN-029 | SSRF — Avatar URL Fetched Server-Side | High | A10:2025 |
| PWN-030 | Seller Earnings Logic Bug (Fixed) | Medium | Logic |
| PWN-031 | Direct Prompt Injection — System Prompt Extraction | Critical | LLM01 |
| PWN-032 | Indirect Prompt Injection via Product Descriptions | High | LLM01 |
| PWN-033 | Sensitive User Data in System Prompt | High | LLM02 |
| PWN-034 | DOM XSS via Unsanitised AI Response | High | LLM05 |
| PWN-035 | IDOR via AI Order Lookup Tool | Medium | LLM06 |
| PWN-036 | No Rate Limiting on AI Endpoint | Medium | LLM10 |
| PWN-037 | Username Enumeration | Medium | A07:2025 |
| PWN-038 | Path Traversal — Invoice Download | High | A02:2025 |
| PWN-039 | HTTP Parameter Pollution — Coupon Bypass | Medium | A06:2025 |
| PWN-040 | SSTI → RCE — Seller Storefront Preview | **Critical** | A05:2025 |
| PWN-041 | Prototype Pollution — Lodash Dependency | High | A03:2025 |

### Highlighted Chains

**Full Account Takeover Chain:**
`PWN-018` (debug endpoint leaks session secret) → `PWN-006` (forge session cookie) → any account

**RCE Chain:**
Register account → `/register-seller` → `/seller/preview?template=<%= global.process.mainModule.require('child_process').execSync('id').toString() %>`

**AI XSS Chain:**
Seller adds XSS payload to product description → `PWN-032` (indirect injection into chatbot context) → `PWN-034` (DOM XSS via innerHTML) → victim's session hijacked

**Privilege Escalation:**
`POST /register` with `role=admin` in body (`PWN-021`) → admin account without any SQL injection

---

## Team Workflow

### For the instructor / repo owner
```bash
# After setting up the repo privately on GitHub
# Go to: Settings → Collaborators → Add people
# Add teammates by GitHub username or email
# Assign "Write" role for contributors, "Read" for observers
```

### For teammates (first time)
```bash
git clone https://github.com/YOUR_USERNAME/pwnshop.git
cd pwnshop
npm install
cp .env.example .env
# Edit .env — add GROQ_API_KEY
mysql -u root -p -e "CREATE DATABASE pwnshop;"
mysql -u root -p pwnshop < pwnshop.sql
npm run dev
```

### Daily workflow
```bash
git pull origin main          # Always pull before starting work
git checkout -b your-branch   # Work on your own branch
# ... make changes ...
git add .
git commit -m "Describe what you changed"
git push origin your-branch
# Open a Pull Request on GitHub to merge into main
```

---

## Resetting the Lab

The lab reset tool at `http://localhost:3000/reset` wipes all student-created data while preserving seed accounts and demo products. Use this between student cohorts or practice sessions.

**What gets deleted:**
- All non-seed user accounts
- All orders, order items, tracking events
- All cart items, wishlists
- All reviews
- All OTP codes and PwnMail messages
- All password reset tokens
- All non-seed products
- All coupon usage records and non-seed coupons
- Seller earnings

**What is preserved:**
- Admin account
- Seed users (IDs 1–5)
- Seed products (IDs 1–11)
- Seed coupons (IDs 1–5)
- Seed wallet balances

You can also reset via SQL directly:
```bash
mysql -u root -p -e "DROP DATABASE pwnshop; CREATE DATABASE pwnshop;"
mysql -u root -p pwnshop < pwnshop.sql
```

---

## FAQ

**Q: Do I need the Groq API key?**
A: Only for the AI chatbot (Pwnie). All other features work without it. Get a free key at [console.groq.com](https://console.groq.com).

**Q: Should I upload the `docker/` folder to GitHub?**
A: Yes. It's not sensitive and makes it dramatically easier for teammates to set up — one command instead of manually installing and configuring MySQL.

**Q: Should I upload `pwnshop.sql` to GitHub?**
A: Yes. It only contains demo/fictional data and is required for setup. Do not put it in `.gitignore`.

**Q: Why is Lodash pinned to `4.17.4` specifically?**
A: It's intentionally outdated to demonstrate CVE-2019-10744 (prototype pollution via `_.merge()`). Do not upgrade it.

**Q: The chatbot returns "AI assistant is not configured"?**
A: Your `GROQ_API_KEY` in `.env` is missing or incorrect. Check [console.groq.com](https://console.groq.com) for your key.

**Q: I see "Database connection failed" on startup?**
A: MySQL is not running, or the database `pwnshop` doesn't exist yet. Run the database setup steps above.

**Q: Can I change the database password?**
A: Yes — update the `db` config at the top of `src/app.js`. The hardcoded `root/root` credentials are themselves a training vulnerability (PWN-018).

**Q: How do I access the admin panel?**
A: Go to `/admin/login`. Use the admin credentials from `pwnshop.sql`, or exploit PWN-009 (SQL injection) or PWN-021 (mass assignment) to get admin access.

---

## ⚠️ Legal Disclaimer

Pwnshop is designed exclusively for security education in controlled environments. Exploiting vulnerabilities in systems you do not own or have explicit permission to test is illegal. The authors accept no liability for misuse.

---

*Built for the CTF Security training programme.*
