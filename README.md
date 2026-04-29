# Vulnerable E-Commerce Application

This is a deliberately vulnerable e-commerce web application designed for security testing, learning, and Capture The Flag (CTF) challenges. The application is built using Node.js, Express, and MySQL, and is containerized using Docker.

## Project Structure

```
vulnerable-ecommerce-app
├── src
│   ├── app.js
│   ├── config
│   │   └── db.js
│   ├── controllers
│   │   └── userController.js
│   ├── models
│   │   └── user.js
│   ├── routes
│   │   └── userRoutes.js
│   ├── middlewares
│   │   └── auth.js
│   ├── utils
│   │   └── helpers.js
│   └── views
│       └── index.ejs
├── docker
│   ├── Dockerfile
│   └── docker-compose.yml
├── .env.example
├── package.json
├── package-lock.json
└── README.md
```

## Features

- User registration and login functionality with intentional vulnerabilities.
- User profile management with insecure session handling.
- Vulnerable routes that can be exploited for learning purposes.
- Dockerized setup for easy deployment and testing.

## Setup Instructions

1. **Clone the repository:**
   ```
   git clone <repository-url>
   cd vulnerable-ecommerce-app
   ```

2. **Create a `.env` file:**
   Copy the `.env.example` to `.env` and fill in the required environment variables.

3. **Build and run the application using Docker:**
   ```
   docker-compose up --build
   ```

4. **Access the application:**
   Open your browser and navigate to `http://localhost:3000`.

## Known Vulnerabilities

- **Broken Authentication:** The application has weak session management and does not properly validate user sessions.
- **Insecure Direct Object References:** Users can access resources they should not have permission to.
- **Cross-Site Scripting (XSS):** The application may render user input without proper sanitization.
- **Weak JWT Implementation:** The application uses a weak method for generating and validating JWTs.

## Disclaimer

This application is intended for educational purposes only. Use it responsibly and only in controlled environments.