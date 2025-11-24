-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    encrypted_wallet_private_key TEXT NOT NULL,
    wallet_public_key VARCHAR(44) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_wallet_public_key ON users(wallet_public_key);

-- Invoices table
CREATE TABLE IF NOT EXISTS invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    client_email VARCHAR(255) NOT NULL,
    amount_usd DECIMAL(18, 8) NOT NULL,
    amount_sol DECIMAL(18, 8),
    amount_usdc DECIMAL(18, 8),
    currency VARCHAR(10) NOT NULL CHECK (currency IN ('USD', 'SOL', 'USDC')),
    description TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'overdue', 'cancelled')),
    transaction_hash VARCHAR(88),
    reference_public_key VARCHAR(44) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    paid_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_invoices_user_id ON invoices(user_id);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_invoices_transaction_hash ON invoices(transaction_hash);
CREATE INDEX idx_invoices_reference_public_key ON invoices(reference_public_key);
CREATE INDEX idx_invoices_created_at ON invoices(created_at);

-- Payroll table
CREATE TABLE IF NOT EXISTS payroll (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    payee_name VARCHAR(255) NOT NULL,
    payee_wallet_address VARCHAR(44) NOT NULL,
    amount_usd DECIMAL(18, 8) NOT NULL,
    amount_sol DECIMAL(18, 8),
    amount_usdc DECIMAL(18, 8),
    currency VARCHAR(10) NOT NULL CHECK (currency IN ('SOL', 'USDC')),
    frequency VARCHAR(20) NOT NULL CHECK (frequency IN ('oneTime', 'weekly')),
    status VARCHAR(20) NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'processing', 'completed', 'cancelled')),
    next_payment_date TIMESTAMP WITH TIME ZONE,
    last_payment_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payroll_user_id ON payroll(user_id);
CREATE INDEX idx_payroll_status ON payroll(status);
CREATE INDEX idx_payroll_next_payment_date ON payroll(next_payment_date);

-- Payments table
CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id UUID REFERENCES invoices(id) ON DELETE SET NULL,
    payroll_id UUID REFERENCES payroll(id) ON DELETE SET NULL,
    transaction_hash VARCHAR(88) UNIQUE NOT NULL,
    amount DECIMAL(18, 8) NOT NULL,
    currency VARCHAR(10) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'failed')),
    block_time BIGINT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payments_invoice_id ON payments(invoice_id);
CREATE INDEX idx_payments_payroll_id ON payments(payroll_id);
CREATE INDEX idx_payments_transaction_hash ON payments(transaction_hash);
CREATE INDEX idx_payments_status ON payments(status);

-- Price feeds cache table
CREATE TABLE IF NOT EXISTS price_feeds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    token VARCHAR(10) UNIQUE NOT NULL CHECK (token IN ('SOL', 'USDC')),
    price_usd DECIMAL(18, 8) NOT NULL,
    source VARCHAR(100) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_price_feeds_token ON price_feeds(token);
CREATE INDEX idx_price_feeds_updated_at ON price_feeds(updated_at);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers to auto-update updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_invoices_updated_at BEFORE UPDATE ON invoices
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payroll_updated_at BEFORE UPDATE ON payroll
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
