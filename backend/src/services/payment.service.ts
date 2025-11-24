import { encodeURL, findReference, FindReferenceError } from '@solana/pay';
import { PublicKey, Keypair } from '@solana/web3.js';
import BigNumber from 'bignumber.js';
import getConnection from '../config/solana';
import { getUsdcMint } from '../config/solana';
import getDatabase from '../config/database';
import logger from '../utils/logger';

export interface QRCodeData {
  url: string;
  reference: string;
}

export interface PaymentVerification {
  confirmed: boolean;
  transactionHash: string | null;
  blockTime: number | null;
}

/**
 * Generate Solana Pay QR code URL for invoice payment
 */
export const generatePaymentQR = async (
  recipientAddress: string,
  amount: number,
  currency: 'SOL' | 'USDC',
  label: string,
  message: string,
  memo?: string
): Promise<QRCodeData> => {
  // Generate unique reference keypair for tracking
  const reference = Keypair.generate();
  const referencePubkey = reference.publicKey;

  const recipient = new PublicKey(recipientAddress);
  const amountBN = new BigNumber(amount.toString());

  let url: URL;

  if (currency === 'USDC') {
    const usdcMint = getUsdcMint();
    url = encodeURL({
      recipient,
      amount: amountBN,
      splToken: usdcMint,
      reference: referencePubkey,
      label,
      message,
      memo,
    });
  } else {
    url = encodeURL({
      recipient,
      amount: amountBN,
      reference: referencePubkey,
      label,
      message,
      memo,
    });
  }

  return {
    url: url.toString(),
    reference: referencePubkey.toBase58(),
  };
};

/**
 * Monitor payment using reference public key
 */
export const monitorPayment = async (
  referencePublicKey: string,
  timeout: number = 60000 // 60 seconds default
): Promise<PaymentVerification> => {
  const connection = getConnection();
  const reference = new PublicKey(referencePublicKey);

  const startTime = Date.now();

  while (Date.now() - startTime < timeout) {
    try {
      const signatureInfo = await findReference(connection, reference, {
        finality: 'confirmed',
      });

      if (signatureInfo) {
        const transaction = await connection.getTransaction(signatureInfo.signature, {
          commitment: 'confirmed',
        });

        logger.info(`Payment confirmed: ${signatureInfo.signature}`);

        return {
          confirmed: true,
          transactionHash: signatureInfo.signature,
          blockTime: transaction?.blockTime || null,
        };
      }
    } catch (error) {
      if (error instanceof FindReferenceError) {
        // Reference not found yet, continue polling
        await new Promise((resolve) => setTimeout(resolve, 1000)); // Wait 1 second
        continue;
      }
      logger.error('Payment monitoring error:', error);
      throw error;
    }
  }

  // Timeout reached
  return {
    confirmed: false,
    transactionHash: null,
    blockTime: null,
  };
};

/**
 * Verify payment transaction
 */
export const verifyPayment = async (
  transactionHash: string
): Promise<PaymentVerification> => {
  const connection = getConnection();

  try {
    const transaction = await connection.getTransaction(transactionHash, {
      commitment: 'confirmed',
    });

    if (!transaction) {
      return {
        confirmed: false,
        transactionHash: null,
        blockTime: null,
      };
    }

    return {
      confirmed: true,
      transactionHash,
      blockTime: transaction.blockTime || null,
    };
  } catch (error) {
    logger.error('Payment verification failed:', error);
    return {
      confirmed: false,
      transactionHash: null,
      blockTime: null,
    };
  }
};

/**
 * Record payment in database
 */
export const recordPayment = async (
  invoiceId: string | null,
  payrollId: string | null,
  transactionHash: string,
  amount: number,
  currency: string,
  blockTime: number | null
): Promise<void> => {
  const db = getDatabase();

  try {
    await db`
      INSERT INTO payments (invoice_id, payroll_id, transaction_hash, amount, currency, status, block_time)
      VALUES (${invoiceId || null}, ${payrollId || null}, ${transactionHash}, ${amount}, ${currency}, 'confirmed', ${blockTime})
      ON CONFLICT (transaction_hash) DO UPDATE
      SET status = 'confirmed', block_time = ${blockTime}, updated_at = CURRENT_TIMESTAMP
    `;

    logger.info(`Payment recorded: ${transactionHash}`);
  } catch (error) {
    logger.error('Failed to record payment:', error);
    throw error;
  }
};
