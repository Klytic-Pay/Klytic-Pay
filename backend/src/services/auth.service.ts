import bcrypt from 'bcrypt';
import { generateToken } from '../config/jwt';
import getDatabase from '../config/database';
import { generateWallet } from './wallet.service';
import logger from '../utils/logger';

const SALT_ROUNDS = 10;

export interface RegisterData {
  email: string;
  password: string;
}

export interface LoginData {
  email: string;
  password: string;
}

export interface AuthResult {
  user: {
    id: string;
    email: string;
    walletPublicKey: string;
  };
  token: string;
}

export const register = async (data: RegisterData): Promise<AuthResult> => {
  const db = getDatabase();

  // Check if user already exists
  const existingUser = await db`
    SELECT id FROM users WHERE email = ${data.email}
  `;

  if (Array.isArray(existingUser) && existingUser.length > 0) {
    throw new Error('User with this email already exists');
  }

  // Hash password
  const passwordHash = await bcrypt.hash(data.password, SALT_ROUNDS);

  // Generate wallet
  const wallet = generateWallet();
  const { encrypt } = await import('./encryption.service');
  const encryptedPrivateKey = encrypt(wallet.privateKey);

  // Create user
  const result = await db`
    INSERT INTO users (email, password_hash, encrypted_wallet_private_key, wallet_public_key)
    VALUES (${data.email}, ${passwordHash}, ${encryptedPrivateKey}, ${wallet.publicKey})
    RETURNING id, email, wallet_public_key
  `;
  const user = Array.isArray(result) ? result[0] : (result as any);

  const token = generateToken({
    userId: user.id,
    email: user.email,
  });

  logger.info(`User registered: ${user.email}`);

  return {
    user: {
      id: user.id,
      email: user.email,
      walletPublicKey: user.wallet_public_key,
    },
    token,
  };
};

export const login = async (data: LoginData): Promise<AuthResult> => {
  const db = getDatabase();

  // Find user
  const result = await db`
    SELECT id, email, password_hash, wallet_public_key
    FROM users
    WHERE email = ${data.email}
  `;
  const user = Array.isArray(result) ? result[0] : (result as any);

  if (!user) {
    throw new Error('Invalid email or password');
  }

  // Verify password
  const isValidPassword = await bcrypt.compare(data.password, user.password_hash);

  if (!isValidPassword) {
    throw new Error('Invalid email or password');
  }

  const token = generateToken({
    userId: user.id,
    email: user.email,
  });

  logger.info(`User logged in: ${user.email}`);

  return {
    user: {
      id: user.id,
      email: user.email,
      walletPublicKey: user.wallet_public_key,
    },
    token,
  };
};

export const getUserById = async (userId: string) => {
  const db = getDatabase();

  const result = await db`
    SELECT id, email, wallet_public_key, created_at
    FROM users
    WHERE id = ${userId}
  `;
  const user = Array.isArray(result) ? result[0] : (result as any);

  return user || null;
};
