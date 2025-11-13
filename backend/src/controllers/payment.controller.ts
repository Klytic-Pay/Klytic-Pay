import { Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { monitorPayment, verifyPayment, recordPayment } from '../services/payment.service';
import { NotFoundError, ValidationError } from '../utils/errors';
import getDatabase from '../config/database';
import logger from '../utils/logger';

export const getPaymentStatus = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { reference } = req.params;

    if (!reference) {
      throw new ValidationError('Reference is required');
    }

    // Try to find payment by reference in invoices
    const db = getDatabase();
    const invoiceResult = await db`
      SELECT * FROM invoices
      WHERE reference_public_key = ${reference}
    `;
    const invoice = Array.isArray(invoiceResult) ? invoiceResult[0] : (invoiceResult as any);

    if (!invoice) {
      throw new NotFoundError('Payment reference');
    }

    // Check if payment is already confirmed
    if (invoice.status === 'paid' && invoice.transaction_hash) {
      const verification = await verifyPayment(invoice.transaction_hash);
      res.json({
        confirmed: verification.confirmed,
        transactionHash: verification.transactionHash,
        blockTime: verification.blockTime,
        invoiceId: invoice.id,
      });
      return;
    }

    // Monitor for new payment
    const verification = await monitorPayment(reference, 5000); // 5 second timeout for API call

    if (verification.confirmed && verification.transactionHash) {
      // Update invoice status
      await db`
        UPDATE invoices
        SET status = 'paid',
            transaction_hash = ${verification.transactionHash},
            paid_at = CURRENT_TIMESTAMP,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = ${invoice.id}
      `;

      // Record payment
      await recordPayment(
        invoice.id,
        null,
        verification.transactionHash,
        invoice.amount_usd,
        invoice.currency,
        verification.blockTime
      );
    }

    res.json({
      confirmed: verification.confirmed,
      transactionHash: verification.transactionHash,
      blockTime: verification.blockTime,
      invoiceId: invoice.id,
    });
  } catch (error) {
    logger.error('Get payment status error:', error);
    throw error;
  }
};

export const verifyPaymentTransaction = async (
  req: AuthRequest,
  res: Response
): Promise<void> => {
  try {
    const { transactionHash } = req.body;

    if (!transactionHash) {
      throw new ValidationError('Transaction hash is required');
    }

    const verification = await verifyPayment(transactionHash);

    res.json({
      confirmed: verification.confirmed,
      transactionHash: verification.transactionHash,
      blockTime: verification.blockTime,
    });
  } catch (error) {
    logger.error('Verify payment error:', error);
    throw error;
  }
};
