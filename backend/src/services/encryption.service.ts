import crypto from 'crypto';
import env from '../config/env';
import logger from '../utils/logger';

const ALGORITHM = 'aes-256-gcm';
const IV_LENGTH = 16;
const TAG_LENGTH = 16;
const KEY_LENGTH = 32;

// Derive encryption key from ENCRYPTION_KEY env variable
const getEncryptionKey = (): Buffer => {
  const key = Buffer.from(env.ENCRYPTION_KEY, 'base64');
  if (key.length !== KEY_LENGTH) {
    throw new Error(`Encryption key must be ${KEY_LENGTH} bytes (${KEY_LENGTH * 8} bits)`);
  }
  return key;
};

export const encrypt = (text: string): string => {
  try {
    const key = getEncryptionKey();
    const iv = crypto.randomBytes(IV_LENGTH);
    const cipher = crypto.createCipheriv(ALGORITHM, key, iv);

    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');

    const tag = cipher.getAuthTag();

    // Combine iv + tag + encrypted data
    const result = iv.toString('hex') + tag.toString('hex') + encrypted;

    return result;
  } catch (error) {
    logger.error('Encryption failed:', error);
    throw new Error('Failed to encrypt data');
  }
};

export const decrypt = (encryptedText: string): string => {
  try {
    const key = getEncryptionKey();

    // Extract iv, tag, and encrypted data
    const iv = Buffer.from(encryptedText.slice(0, IV_LENGTH * 2), 'hex');
    const tag = Buffer.from(
      encryptedText.slice(IV_LENGTH * 2, IV_LENGTH * 2 + TAG_LENGTH * 2),
      'hex'
    );
    const encrypted = encryptedText.slice(IV_LENGTH * 2 + TAG_LENGTH * 2);

    const decipher = crypto.createDecipheriv(ALGORITHM, key, iv);
    decipher.setAuthTag(tag);

    let decrypted = decipher.update(encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');

    return decrypted;
  } catch (error) {
    logger.error('Decryption failed:', error);
    throw new Error('Failed to decrypt data');
  }
};
