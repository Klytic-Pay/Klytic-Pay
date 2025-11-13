# Klytic Pay Backend

Backend API for Klytic Pay - Solana-based payroll and invoicing application.

## Features

- **Custom JWT-based authentication** - Secure user registration and login
- **Solana wallet generation and management** - Automatic wallet creation for users
- **Invoice creation with Solana Pay QR codes** - Generate payment QR codes for invoices
- **Automated payroll scheduling and execution** - Weekly and one-time payroll processing
- **SOL and USDC payment processing** - Support for both native SOL and USDC tokens
- **Real-time price feeds** - CoinGecko integration for SOL/USDC to USD conversion
- **Secure wallet encryption** - AES-256-GCM encryption for private keys
- **Interactive API Documentation** - Swagger/OpenAPI docs at root URL
- **Docker & Docker Compose** - Easy deployment with containerized PostgreSQL

## Tech Stack

- **Runtime**: Node.js 20 with TypeScript
- **Framework**: Express.js
- **Database**: PostgreSQL (Neon or local via Docker)
- **Blockchain**: Solana (@solana/web3.js, @solana/pay, @solana/spl-token)
- **Authentication**: JWT (jsonwebtoken, bcrypt)
- **Scheduler**: node-cron
- **API Documentation**: Swagger UI (swagger-ui-express, swagger-jsdoc)
- **Validation**: express-validator, zod
- **Security**: helmet, cors, express-rate-limit

## Prerequisites

- Node.js 20+
- pnpm (recommended) or npm/yarn
- Docker & Docker Compose (for containerized deployment)
- PostgreSQL database (Neon cloud or local)
- Solana RPC endpoint (defaults to Devnet)

## Quick Start with Docker Compose

The easiest way to get started is using Docker Compose:

1. **Navigate to backend directory**:
   ```bash
   cd backend
   ```

2. **Create `.env` file** (see Environment Variables section below):
   ```bash
   # Copy the example or create from scratch
   # The .env file should contain all required variables
   ```

3. **Start services**:
   ```bash
   docker-compose up -d
   ```

4. **Run database migrations**:
   ```bash
   docker-compose exec backend node dist/db/migrate.js
   ```

5. **Access the API**:
   - **Swagger UI**: http://localhost:3000
   - **Health Check**: http://localhost:3000/health
   - **API Docs JSON**: http://localhost:3000/api-docs.json

## Local Development Setup

1. **Install dependencies**:
   ```bash
   pnpm install
   ```

2. **Configure environment variables**:
   ```bash
   # Create .env file with required variables (see below)
   ```

3. **Generate secure keys**:
   ```bash
   # Generate JWT secret
   openssl rand -base64 32
   
   # Generate encryption key
   openssl rand -base64 32
   ```

4. **Run database migrations**:
   ```bash
   pnpm migrate
   ```

5. **Start development server**:
   ```bash
   pnpm dev
   ```

## Environment Variables

Create a `.env` file in the `backend` directory with the following variables:

```env
# Application
NODE_ENV=development
PORT=3000

# Database (for local PostgreSQL in docker-compose)
POSTGRES_USER=klytic
POSTGRES_PASSWORD=klytic123
POSTGRES_DB=klytic_pay
DATABASE_URL=postgresql://klytic:klytic123@db:5432/klytic_pay
# For Neon: DATABASE_URL=postgresql://user:password@host.neon.tech/dbname

# JWT Authentication (generate with: openssl rand -base64 32)
JWT_SECRET=your-super-secret-jwt-key-min-32-chars
JWT_EXPIRES_IN=7d

# Encryption Key for wallet private keys (generate with: openssl rand -base64 32)
ENCRYPTION_KEY=your-super-secret-encryption-key-min-32-chars

# Solana Configuration
SOLANA_NETWORK=devnet
SOLANA_RPC_URL=https://api.devnet.solana.com
# Optional: Override default USDC mint address
# SOLANA_USDC_MINT=4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU

# Price Feed (CoinGecko)
PRICE_FEED_API_URL=https://api.coingecko.com/api/v3
PRICE_FEED_UPDATE_INTERVAL=300000

# Circle API (for on/off-ramping - optional)
CIRCLE_API_KEY=
CIRCLE_API_URL=https://api-sandbox.circle.com

# CORS
CORS_ORIGIN=*

# Logging
LOG_LEVEL=info
```

## API Documentation

The API is fully documented with Swagger/OpenAPI. Once the server is running:

- **Interactive Swagger UI**: http://localhost:3000
- **OpenAPI JSON Spec**: http://localhost:3000/api-docs.json

The Swagger UI allows you to:
- Browse all available endpoints
- View request/response schemas
- Test endpoints directly from the browser
- Authenticate using JWT tokens

### Using Swagger UI

1. Open http://localhost:3000 in your browser
2. Register or login via `/api/auth/register` or `/api/auth/login`
3. Copy the JWT token from the response
4. Click the "Authorize" button in Swagger UI
5. Enter: `Bearer <your-token>`
6. All authenticated requests will now include your token

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user (creates Solana wallet automatically)
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user info (requires authentication)

### Invoices
- `POST /api/invoices` - Create invoice with Solana Pay QR code
- `GET /api/invoices` - List invoices (with optional status filter)
- `GET /api/invoices/:id` - Get invoice details
- `PATCH /api/invoices/:id/cancel` - Cancel pending invoice

### Payments
- `GET /api/payments/status/:reference` - Check payment status by reference
- `POST /api/payments/verify` - Verify Solana transaction

### Payroll
- `POST /api/payroll` - Schedule payroll (one-time or weekly, max 5 active)
- `GET /api/payroll` - List payroll schedules
- `GET /api/payroll/:id` - Get payroll details
- `DELETE /api/payroll/:id` - Cancel scheduled payroll

### Dashboard
- `GET /api/dashboard/summary` - Get dashboard statistics and recent activity

### Health
- `GET /health` - Health check endpoint (database connection status)

## Docker Deployment

### Using Docker Compose (Recommended)

Docker Compose includes both the backend and PostgreSQL database:

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f backend

# Stop services
docker-compose down

# Rebuild after code changes
docker-compose build backend
docker-compose up -d
```

### Database Migrations in Docker

```bash
# Run migrations
docker-compose exec backend node dist/db/migrate.js

# Or if using ts-node
docker-compose exec backend pnpm migrate
```

### Using Docker directly

```bash
# Build image
docker build -t klytic-pay-backend .

# Run container (requires external PostgreSQL)
docker run -d \
  --name klytic-pay-backend \
  -p 3000:3000 \
  --env-file .env \
  klytic-pay-backend
```

## Development

```bash
# Run in development mode (with hot reload)
pnpm dev

# Build for production
pnpm build

# Run production build
pnpm start

# Run database migrations
pnpm migrate

# Run tests
pnpm test

# Lint code
pnpm lint

# Format code
pnpm format
```

## Database

The application supports both:
- **Neon PostgreSQL** (cloud) - Uses Neon serverless driver
- **Local PostgreSQL** - Uses standard pg driver (auto-detected)

The database connection automatically detects the type based on the `DATABASE_URL`:
- Local: URLs containing `@localhost`, `@db:`, or `@127.0.0.1`
- Neon: URLs containing `neon.tech`

### Schema

The database includes the following tables:
- `users` - User accounts with encrypted wallets
- `invoices` - Invoice records with Solana Pay references
- `payroll` - Scheduled payroll payments
- `payments` - Payment transaction records
- `price_feeds` - Cached cryptocurrency prices

## Payroll Automation

The payroll cron job runs weekly to execute scheduled payments. It:
- Finds all payrolls due for payment
- Executes SOL or USDC transfers via Solana
- Updates payroll status and next payment date
- Records payment transactions in the database

## Security Features

- **Wallet Encryption**: Private keys encrypted with AES-256-GCM
- **JWT Authentication**: Secure token-based auth
- **Rate Limiting**: Protection against brute force attacks
- **Input Validation**: All requests validated with express-validator
- **SQL Injection Prevention**: Parameterized queries
- **CORS Protection**: Configurable CORS policies
- **Helmet**: Security headers middleware

## Testing the API

### Using cURL

```bash
# Register a user
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}'

# Create invoice (replace TOKEN with JWT from login)
curl -X POST http://localhost:3000/api/invoices \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"clientEmail":"client@example.com","amount":100,"currency":"USD"}'
```

### Using Swagger UI

1. Open http://localhost:3000
2. Try endpoints directly in the browser
3. Use "Authorize" button to add JWT token

## Project Structure

```
backend/
├── src/
│   ├── config/          # Configuration (database, JWT, Solana, Swagger)
│   ├── controllers/      # Request handlers
│   ├── db/              # Database schema and migrations
│   ├── jobs/            # Scheduled jobs (payroll cron)
│   ├── middleware/      # Express middleware (auth, validation, error handling)
│   ├── routes/          # API route definitions
│   ├── services/        # Business logic (auth, payments, Solana, etc.)
│   └── utils/           # Utilities (logger, errors)
├── dist/                # Compiled TypeScript output
├── Dockerfile           # Docker image definition
├── docker-compose.yml   # Docker Compose configuration
├── package.json         # Dependencies and scripts
└── tsconfig.json        # TypeScript configuration
```

## Troubleshooting

### Database Connection Issues

- Check that PostgreSQL is running: `docker-compose ps`
- Verify DATABASE_URL in `.env` matches your setup
- For local PostgreSQL, ensure the URL includes `@db:` for Docker Compose

### Bcrypt Build Errors

- The Dockerfile includes build dependencies for native modules
- If issues persist, ensure build tools are installed in the container

### Migration Errors

- Ensure database is running and accessible
- Check that UUID extension is available: `CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`
- Run migrations manually if needed: `docker-compose exec db psql -U klytic -d klytic_pay -f src/db/schema.sql`

## License

MIT
