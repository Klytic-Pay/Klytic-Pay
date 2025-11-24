import {
  PublicKey,
  SystemProgram,
  Transaction,
  sendAndConfirmTransaction,
  LAMPORTS_PER_SOL,
} from '@solana/web3.js';
import {
  getAssociatedTokenAddress,
  createTransferCheckedInstruction,
  getAccount,
  getMint,
} from '@solana/spl-token';
import getConnection, { getUsdcMint } from '../config/solana';
import { getKeypair } from './wallet.service';
import logger from '../utils/logger';
import Big from 'big.js';

export interface TransferResult {
  signature: string;
  blockTime: number | null;
}

/**
 * Transfer SOL from user's wallet to recipient
 */
export const transferSol = async (
  userId: string,
  recipientAddress: string,
  amountSol: number
): Promise<TransferResult> => {
  const connection = getConnection();
  const senderKeypair = await getKeypair(userId);

  if (!senderKeypair) {
    throw new Error('User wallet not found');
  }

  const recipient = new PublicKey(recipientAddress);
  const lamports = Math.floor(amountSol * LAMPORTS_PER_SOL);

  const transaction = new Transaction().add(
    SystemProgram.transfer({
      fromPubkey: senderKeypair.publicKey,
      toPubkey: recipient,
      lamports,
    })
  );

  try {
    const signature = await sendAndConfirmTransaction(
      connection,
      transaction,
      [senderKeypair],
      {
        commitment: 'confirmed',
        maxRetries: 3,
      }
    );

    const transactionDetails = await connection.getTransaction(signature, {
      commitment: 'confirmed',
    });

    logger.info(`SOL transfer completed: ${signature}`);

    return {
      signature,
      blockTime: transactionDetails?.blockTime || null,
    };
  } catch (error) {
    logger.error('SOL transfer failed:', error);
    throw new Error('Failed to transfer SOL');
  }
};

/**
 * Transfer USDC (SPL token) from user's wallet to recipient
 */
export const transferUsdc = async (
  userId: string,
  recipientAddress: string,
  amountUsdc: number
): Promise<TransferResult> => {
  const connection = getConnection();
  const senderKeypair = await getKeypair(userId);
  const usdcMint = getUsdcMint();

  if (!senderKeypair) {
    throw new Error('User wallet not found');
  }

  const recipient = new PublicKey(recipientAddress);

  // Get mint info for decimals
  const mintInfo = await getMint(connection, usdcMint);
  const decimals = mintInfo.decimals;

  // Convert amount to token units
  const amount = Big(amountUsdc)
    .times(Big(10).pow(decimals))
    .toFixed(0);

  // Get associated token addresses
  const senderATA = await getAssociatedTokenAddress(
    usdcMint,
    senderKeypair.publicKey
  );
  const recipientATA = await getAssociatedTokenAddress(usdcMint, recipient);

  // Check sender has tokens
  try {
    const senderAccount = await getAccount(connection, senderATA);
    if (BigInt(amount) > senderAccount.amount) {
      throw new Error('Insufficient USDC balance');
    }
  } catch (error) {
    if (error instanceof Error && error.message.includes('could not find account')) {
      throw new Error('Sender USDC account not found');
    }
    throw error;
  }

  // Create transfer instruction
  const transferInstruction = createTransferCheckedInstruction(
    senderATA,
    usdcMint,
    recipientATA,
    senderKeypair.publicKey,
    BigInt(amount),
    decimals
  );

  const transaction = new Transaction().add(transferInstruction);

  try {
    const signature = await sendAndConfirmTransaction(
      connection,
      transaction,
      [senderKeypair],
      {
        commitment: 'confirmed',
        maxRetries: 3,
      }
    );

    const transactionDetails = await connection.getTransaction(signature, {
      commitment: 'confirmed',
    });

    logger.info(`USDC transfer completed: ${signature}`);

    return {
      signature,
      blockTime: transactionDetails?.blockTime || null,
    };
  } catch (error) {
    logger.error('USDC transfer failed:', error);
    throw new Error('Failed to transfer USDC');
  }
};

/**
 * Get SOL balance for a wallet
 */
export const getSolBalance = async (walletAddress: string): Promise<number> => {
  const connection = getConnection();
  const publicKey = new PublicKey(walletAddress);
  const balance = await connection.getBalance(publicKey);
  return balance / LAMPORTS_PER_SOL;
};

/**
 * Get USDC balance for a wallet
 */
export const getUsdcBalance = async (walletAddress: string): Promise<number> => {
  const connection = getConnection();
  const usdcMint = getUsdcMint();
  const publicKey = new PublicKey(walletAddress);

  try {
    const ata = await getAssociatedTokenAddress(usdcMint, publicKey);
    const account = await getAccount(connection, ata);
    const mintInfo = await getMint(connection, usdcMint);

    return Number(account.amount) / Math.pow(10, mintInfo.decimals);
  } catch (error) {
    // Account doesn't exist or has no balance
    return 0;
  }
};

/**
 * Verify a transaction signature
 */
export const verifyTransaction = async (
  signature: string
): Promise<{ confirmed: boolean; blockTime: number | null }> => {
  const connection = getConnection();

  try {
    const transaction = await connection.getTransaction(signature, {
      commitment: 'confirmed',
    });

    return {
      confirmed: transaction !== null,
      blockTime: transaction?.blockTime || null,
    };
  } catch (error) {
    logger.error('Transaction verification failed:', error);
    return {
      confirmed: false,
      blockTime: null,
    };
  }
};
