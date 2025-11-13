import { Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import getDatabase from '../config/database';
import logger from '../utils/logger';

export const getDashboardSummary = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const db = getDatabase();

    // Get invoice statistics
    const invoiceStatsResult = await db`
      SELECT 
        COUNT(*) as total_invoices,
        COUNT(*) FILTER (WHERE status = 'pending') as pending_invoices,
        COUNT(*) FILTER (WHERE status = 'paid') as paid_invoices,
        COALESCE(SUM(amount_usd) FILTER (WHERE status = 'paid'), 0) as total_paid_amount
      FROM invoices
      WHERE user_id = ${userId}
    `;
    const invoiceStats = Array.isArray(invoiceStatsResult) ? invoiceStatsResult[0] : (invoiceStatsResult as any);

    // Get payroll statistics
    const payrollStatsResult = await db`
      SELECT 
        COUNT(*) FILTER (WHERE status = 'scheduled') as scheduled_payrolls,
        COUNT(*) FILTER (WHERE status = 'processing') as processing_payrolls
      FROM payroll
      WHERE user_id = ${userId}
    `;
    const payrollStats = Array.isArray(payrollStatsResult) ? payrollStatsResult[0] : (payrollStatsResult as any);

    // Get recent invoices
    const recentInvoices = await db`
      SELECT id, client_email, amount_usd, currency, status, created_at
      FROM invoices
      WHERE user_id = ${userId}
      ORDER BY created_at DESC
      LIMIT 5
    `;

    // Get upcoming payrolls
    const upcomingPayrolls = await db`
      SELECT id, payee_name, amount_usd, currency, next_payment_date
      FROM payroll
      WHERE user_id = ${userId} 
        AND status = 'scheduled'
        AND next_payment_date IS NOT NULL
      ORDER BY next_payment_date ASC
      LIMIT 5
    `;

    const recentInvoicesArray = Array.isArray(recentInvoices) ? recentInvoices : [];
    const upcomingPayrollsArray = Array.isArray(upcomingPayrolls) ? upcomingPayrolls : [];

    res.json({
      summary: {
        invoices: {
          total: parseInt(invoiceStats.total_invoices),
          pending: parseInt(invoiceStats.pending_invoices),
          paid: parseInt(invoiceStats.paid_invoices),
          totalPaidAmount: parseFloat(invoiceStats.total_paid_amount),
        },
        payroll: {
          scheduled: parseInt(payrollStats.scheduled_payrolls),
          processing: parseInt(payrollStats.processing_payrolls),
        },
      },
      recentActivity: {
        invoices: recentInvoicesArray.map((inv: any) => ({
          id: inv.id,
          clientEmail: inv.client_email,
          amount: inv.amount_usd,
          currency: inv.currency,
          status: inv.status,
          createdAt: inv.created_at,
        })),
        upcomingPayrolls: upcomingPayrollsArray.map((p: any) => ({
          id: p.id,
          payeeName: p.payee_name,
          amount: p.amount_usd,
          currency: p.currency,
          nextPaymentDate: p.next_payment_date,
        })),
      },
    });
  } catch (error) {
    logger.error('Get dashboard summary error:', error);
    throw error;
  }
};
