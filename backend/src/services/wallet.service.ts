import { Keypair } from '@solana/web3.js';
import { encrypt, decrypt } from './encryption.service';
import getDatabase from '../config/database';
import logger from '../utils/logger';

export interface WalletData {
  publicKey: string;
  privateKey: string; // Base58 encoded
}

/**
 * Generate a new Solana wallet keypair
 */
export const generateWallet = (): WalletData => {
  const keypair = Keypair.generate();
  return {
    publicKey: keypair.publicKey.toBase58(),
    privateKey: Buffer.from(keypair.secretKey).toString('base64'),
  };
};

/**
 * Encrypt and store wallet for a user
 */
export const storeWallet = async (
  userId: string,
  wallet: WalletData
): Promise<void> => {
  const db = getDatabase();

  const encryptedPrivateKey = encrypt(wallet.privateKey);

  await db`
    UPDATE users
    SET encrypted_wallet_private_key = ${encryptedPrivateKey},
        wallet_public_key = ${wallet.publicKey},
        updated_at = CURRENT_TIMESTAMP
    WHERE id = ${userId}
  `;

  logger.info(`Wallet stored for user: ${userId}`);
};

/**
 * Retrieve and decrypt wallet for a user
 */
export const getWallet = async (userId: string): Promise<WalletData | null> => {
  const db = getDatabase();

  const result = await db`
    SELECT encrypted_wallet_private_key, wallet_public_key
    FROM users
    WHERE id = ${userId}
  `;

  const userArray = Array.isArray(result) ? result : [];
  const user = (userArray[0] || null) as any;

  if (!user) {
    return null;
  }

  try {
    const decryptedPrivateKey = decrypt(user.encrypted_wallet_private_key);
    return {
      publicKey: user.wallet_public_key,
      privateKey: decryptedPrivateKey,
    };
  } catch (error) {
    logger.error(`Failed to decrypt wallet for user ${userId}:`, error);
    throw new Error('Failed to retrieve wallet');
  }
};

/**
 * Get Keypair object from stored wallet
 */
export const getKeypair = async (userId: string): Promise<Keypair | null> => {
  const wallet = await getWallet(userId);
  if (!wallet) {
    return null;
  }

  try {
    const secretKey = Buffer.from(wallet.privateKey, 'base64');
    return Keypair.fromSecretKey(secretKey);
  } catch (error) {
    logger.error(`Failed to create keypair for user ${userId}:`, error);
    throw new Error('Failed to create keypair');
  }
};

/**
 * Validate a Solana wallet address
 */
export const isValidWalletAddress = (address: string): boolean => {
  try {
    // Solana addresses are base58 encoded and typically 32-44 characters
    if (address.length < 32 || address.length > 44) {
      return false;
    }
    // Basic validation - could be enhanced with actual base58 decoding
    return /^[1-9A-HJ-NP-Za-km-z]+$/.test(address);
  } catch {
    return false;
  }
};
