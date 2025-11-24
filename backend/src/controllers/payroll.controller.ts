import { Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import getDatabase from '../config/database';
import { usdToSol, usdToUsdc } from '../services/price.service';
import { NotFoundError, ValidationError } from '../utils/errors';
import { isValidWalletAddress } from '../services/wallet.service';
import logger from '../utils/logger';

const MAX_PAYEES = 5;

export const createPayroll = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { payeeName, walletAddress, amount, currency, frequency } = req.body;
    const userId = req.user!.userId;

    if (!payeeName || !walletAddress || !amount || !currency || !frequency) {
      throw new ValidationError('Missing required fields');
    }

    if (!isValidWalletAddress(walletAddress)) {
      throw new ValidationError('Invalid wallet address');
    }

    if (amount <= 0) {
      throw new ValidationError('Amount must be greater than 0');
    }

    if (!['SOL', 'USDC'].includes(currency)) {
      throw new ValidationError('Currency must be SOL or USDC');
    }

    if (!['oneTime', 'weekly'].includes(frequency)) {
      throw new ValidationError('Frequency must be oneTime or weekly');
    }

    // Check max payees limit
    const db = getDatabase();
    const countResultData = await db`
      SELECT COUNT(*) as count FROM payroll
      WHERE user_id = ${userId} AND status IN ('scheduled', 'processing')
    `;
    const countResult = Array.isArray(countResultData) ? countResultData[0] : (countResultData as any);

    if (parseInt(countResult.count) >= MAX_PAYEES) {
      throw new ValidationError(`Maximum ${MAX_PAYEES} active payroll schedules allowed`);
    }

    // Convert USD to SOL/USDC if needed
    let amountSol: number | null = null;
    let amountUsdc: number | null = null;
    const amountUsd = amount;

    if (currency === 'SOL') {
      amountSol = await usdToSol(amountUsd);
    } else {
      amountUsdc = await usdToUsdc(amountUsd);
    }

    // Calculate next payment date
    let nextPaymentDate: Date | null = null;
    if (frequency === 'weekly') {
      nextPaymentDate = new Date();
      nextPaymentDate.setDate(nextPaymentDate.getDate() + 7);
    } else {
      // oneTime - set to tomorrow
      nextPaymentDate = new Date();
      nextPaymentDate.setDate(nextPaymentDate.getDate() + 1);
    }

    // Create payroll
    const payrollResult = await db`
      INSERT INTO payroll (
        user_id, payee_name, payee_wallet_address, amount_usd,
        amount_sol, amount_usdc, currency, frequency, next_payment_date, status
      )
      VALUES (
        ${userId}, ${payeeName}, ${walletAddress}, ${amountUsd},
        ${amountSol}, ${amountUsdc}, ${currency}, ${frequency}, ${nextPaymentDate}, 'scheduled'
      )
      RETURNING *
    `;
    const payroll = Array.isArray(payrollResult) ? payrollResult[0] : (payrollResult as any);

    logger.info(`Payroll created: ${payroll.id}`);

    res.status(201).json({
      payroll: {
        id: payroll.id,
        payeeName: payroll.payee_name,
        walletAddress: payroll.payee_wallet_address,
        amount: payroll.amount_usd,
        amountSol: payroll.amount_sol,
        amountUsdc: payroll.amount_usdc,
        currency: payroll.currency,
        frequency: payroll.frequency,
        status: payroll.status,
        nextPaymentDate: payroll.next_payment_date,
        createdAt: payroll.created_at,
      },
    });
  } catch (error) {
    logger.error('Create payroll error:', error);
    throw error;
  }
};

export const getPayrolls = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { status } = req.query;

    const db = getDatabase();
    let payrolls;

    if (status) {
      payrolls = await db`
        SELECT * FROM payroll
        WHERE user_id = ${userId} AND status = ${status}
        ORDER BY created_at DESC
      `;
    } else {
      payrolls = await db`
        SELECT * FROM payroll
        WHERE user_id = ${userId}
        ORDER BY created_at DESC
      `;
    }

    const payrollArray = Array.isArray(payrolls) ? payrolls : [];

    res.json({
      payrolls: payrollArray.map((p: any) => ({
        id: p.id,
        payeeName: p.payee_name,
        walletAddress: p.payee_wallet_address,
        amount: p.amount_usd,
        amountSol: p.amount_sol,
        amountUsdc: p.amount_usdc,
        currency: p.currency,
        frequency: p.frequency,
        status: p.status,
        nextPaymentDate: p.next_payment_date,
        lastPaymentDate: p.last_payment_date,
        createdAt: p.created_at,
      })),
    });
  } catch (error) {
    logger.error('Get payrolls error:', error);
    throw error;
  }
};

export const getPayroll = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { id } = req.params;

    const db = getDatabase();
    const payrollResult = await db`
      SELECT * FROM payroll
      WHERE id = ${id} AND user_id = ${userId}
    `;
    const payroll = Array.isArray(payrollResult) ? payrollResult[0] : (payrollResult as any);

    if (!payroll) {
      throw new NotFoundError('Payroll');
    }

    res.json({
      payroll: {
        id: payroll.id,
        payeeName: payroll.payee_name,
        walletAddress: payroll.payee_wallet_address,
        amount: payroll.amount_usd,
        amountSol: payroll.amount_sol,
        amountUsdc: payroll.amount_usdc,
        currency: payroll.currency,
        frequency: payroll.frequency,
        status: payroll.status,
        nextPaymentDate: payroll.next_payment_date,
        lastPaymentDate: payroll.last_payment_date,
        createdAt: payroll.created_at,
      },
    });
  } catch (error) {
    logger.error('Get payroll error:', error);
    throw error;
  }
};

export const cancelPayroll = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { id } = req.params;

    const db = getDatabase();
    const payrollResult = await db`
      UPDATE payroll
      SET status = 'cancelled', updated_at = CURRENT_TIMESTAMP
      WHERE id = ${id} AND user_id = ${userId} AND status = 'scheduled'
      RETURNING *
    `;
    const payroll = Array.isArray(payrollResult) ? payrollResult[0] : (payrollResult as any);

    if (!payroll) {
      throw new NotFoundError('Payroll');
    }

    logger.info(`Payroll cancelled: ${id}`);

    res.json({
      message: 'Payroll cancelled successfully',
      payroll: {
        id: payroll.id,
        status: payroll.status,
      },
    });
  } catch (error) {
    logger.error('Cancel payroll error:', error);
    throw error;
  }
};
