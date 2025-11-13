import { Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import getDatabase from '../config/database';
import { generatePaymentQR } from '../services/payment.service';
import { usdToSol, usdToUsdc } from '../services/price.service';
import { NotFoundError, ValidationError } from '../utils/errors';
import logger from '../utils/logger';
import { getUserById } from '../services/auth.service';

export const createInvoice = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { clientEmail, amount, currency, description } = req.body;
    const userId = req.user!.userId;

    if (!clientEmail || !amount || !currency) {
      throw new ValidationError('Missing required fields: clientEmail, amount, currency');
    }

    if (amount <= 0) {
      throw new ValidationError('Amount must be greater than 0');
    }

    const db = getDatabase();
    const user = await getUserById(userId);
    if (!user) {
      throw new NotFoundError('User');
    }

    let amountSol: number | null = null;
    let amountUsdc: number | null = null;

    // Convert USD to SOL/USDC if needed
    if (currency === 'USD' || currency === 'SOL') {
      amountSol = await usdToSol(amount);
    }
    if (currency === 'USD' || currency === 'USDC') {
      amountUsdc = await usdToUsdc(amount);
    }

    // Generate reference keypair for payment tracking
    const { Keypair } = await import('@solana/web3.js');
    const referenceKeypair = Keypair.generate();
    const referencePublicKey = referenceKeypair.publicKey.toBase58();

    // Create invoice
    const invoiceResult = await db`
      INSERT INTO invoices (
        user_id, client_email, amount_usd, amount_sol, amount_usdc,
        currency, description, reference_public_key, status
      )
      VALUES (
        ${userId}, ${clientEmail}, ${amount}, ${amountSol}, ${amountUsdc},
        ${currency}, ${description || null}, ${referencePublicKey}, 'pending'
      )
      RETURNING *
    `;
    const invoice = Array.isArray(invoiceResult) ? invoiceResult[0] : (invoiceResult as any);

    // Generate payment QR code
    const paymentCurrency = currency === 'USD' ? 'SOL' : (currency as 'SOL' | 'USDC');
    const paymentAmount = currency === 'USD' ? amountSol! : amount;

    const qrData = await generatePaymentQR(
      user.wallet_public_key,
      paymentAmount,
      paymentCurrency,
      'Klytic Pay Invoice',
      `Invoice #${invoice.id.substring(0, 8)}`,
      `Invoice-${invoice.id}`
    );

    logger.info(`Invoice created: ${invoice.id}`);

    res.status(201).json({
      invoice: {
        id: invoice.id,
        clientEmail: invoice.client_email,
        amount: invoice.amount_usd,
        amountSol: invoice.amount_sol,
        amountUsdc: invoice.amount_usdc,
        currency: invoice.currency,
        description: invoice.description,
        status: invoice.status,
        referencePublicKey: invoice.reference_public_key,
        createdAt: invoice.created_at,
      },
      qrCode: {
        url: qrData.url,
        reference: qrData.reference,
      },
    });
  } catch (error) {
    logger.error('Create invoice error:', error);
    throw error;
  }
};

export const getInvoices = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { status, limit = '50', offset = '0' } = req.query;

    const db = getDatabase();
    let query = db`
      SELECT * FROM invoices
      WHERE user_id = ${userId}
    `;

    if (status) {
      query = db`
        SELECT * FROM invoices
        WHERE user_id = ${userId} AND status = ${status}
      `;
    }

    const invoices = await db`
      ${query}
      ORDER BY created_at DESC
      LIMIT ${parseInt(limit as string)}
      OFFSET ${parseInt(offset as string)}
    `;

    const invoiceArray = Array.isArray(invoices) ? invoices : [];

    res.json({
      invoices: invoiceArray.map((inv: any) => ({
        id: inv.id,
        clientEmail: inv.client_email,
        amount: inv.amount_usd,
        amountSol: inv.amount_sol,
        amountUsdc: inv.amount_usdc,
        currency: inv.currency,
        description: inv.description,
        status: inv.status,
        transactionHash: inv.transaction_hash,
        referencePublicKey: inv.reference_public_key,
        createdAt: inv.created_at,
        paidAt: inv.paid_at,
      })),
    });
  } catch (error) {
    logger.error('Get invoices error:', error);
    throw error;
  }
};

export const getInvoice = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { id } = req.params;

    const db = getDatabase();
    const invoiceResult = await db`
      SELECT * FROM invoices
      WHERE id = ${id} AND user_id = ${userId}
    `;
    const invoice = Array.isArray(invoiceResult) ? invoiceResult[0] : (invoiceResult as any);

    if (!invoice) {
      throw new NotFoundError('Invoice');
    }

    res.json({
      invoice: {
        id: invoice.id,
        clientEmail: invoice.client_email,
        amount: invoice.amount_usd,
        amountSol: invoice.amount_sol,
        amountUsdc: invoice.amount_usdc,
        currency: invoice.currency,
        description: invoice.description,
        status: invoice.status,
        transactionHash: invoice.transaction_hash,
        referencePublicKey: invoice.reference_public_key,
        createdAt: invoice.created_at,
        paidAt: invoice.paid_at,
      },
    });
  } catch (error) {
    logger.error('Get invoice error:', error);
    throw error;
  }
};

export const cancelInvoice = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { id } = req.params;

    const db = getDatabase();
    const invoiceResult = await db`
      UPDATE invoices
      SET status = 'cancelled', updated_at = CURRENT_TIMESTAMP
      WHERE id = ${id} AND user_id = ${userId} AND status = 'pending'
      RETURNING *
    `;
    const invoice = Array.isArray(invoiceResult) ? invoiceResult[0] : (invoiceResult as any);

    if (!invoice) {
      throw new NotFoundError('Invoice');
    }

    logger.info(`Invoice cancelled: ${id}`);

    res.json({
      message: 'Invoice cancelled successfully',
      invoice: {
        id: invoice.id,
        status: invoice.status,
      },
    });
  } catch (error) {
    logger.error('Cancel invoice error:', error);
    throw error;
  }
};
