import cron from 'node-cron';
import getDatabase from '../config/database';
import { transferSol, transferUsdc } from '../services/solana.service';
import { recordPayment } from '../services/payment.service';
import logger from '../utils/logger';

/**
 * Execute payroll payments that are due
 */
const executePayrollPayments = async (): Promise<void> => {
  const db = getDatabase();
  logger.info('Starting payroll execution job');

  try {
    // Find all payrolls that are due
    const duePayrolls = await db`
      SELECT * FROM payroll
      WHERE status = 'scheduled'
        AND next_payment_date IS NOT NULL
        AND next_payment_date <= CURRENT_TIMESTAMP
    `;

    const duePayrollsArray = Array.isArray(duePayrolls) ? duePayrolls : [];

    if (duePayrollsArray.length === 0) {
      logger.info('No payrolls due for execution');
      return;
    }

    logger.info(`Found ${duePayrollsArray.length} payroll(s) due for execution`);

    for (const payroll of duePayrollsArray) {
      try {
        const payrollData = payroll as any;
        // Update status to processing
        await db`
          UPDATE payroll
          SET status = 'processing', updated_at = CURRENT_TIMESTAMP
          WHERE id = ${payrollData.id}
        `;

        logger.info(`Processing payroll ${payrollData.id} for ${payrollData.payee_name}`);

        // Execute payment
        let transferResult;
        const amount = payrollData.currency === 'SOL' ? payrollData.amount_sol : payrollData.amount_usdc;

        if (payrollData.currency === 'SOL') {
          transferResult = await transferSol(
            payrollData.user_id,
            payrollData.payee_wallet_address,
            amount
          );
        } else {
          transferResult = await transferUsdc(
            payrollData.user_id,
            payrollData.payee_wallet_address,
            amount
          );
        }

        // Record payment
        await recordPayment(
          null,
          payrollData.id,
          transferResult.signature,
          payrollData.amount_usd,
          payrollData.currency,
          transferResult.blockTime
        );

        // Update payroll status and dates
        if (payrollData.frequency === 'weekly') {
          // Calculate next payment date (7 days from now)
          const nextPaymentDate = new Date();
          nextPaymentDate.setDate(nextPaymentDate.getDate() + 7);

          await db`
            UPDATE payroll
            SET status = 'scheduled',
                last_payment_date = CURRENT_TIMESTAMP,
                next_payment_date = ${nextPaymentDate},
                updated_at = CURRENT_TIMESTAMP
            WHERE id = ${payrollData.id}
          `;

          logger.info(
            `Payroll ${payrollData.id} executed successfully. Next payment: ${nextPaymentDate}`
          );
        } else {
          // One-time payment - mark as completed
          await db`
            UPDATE payroll
            SET status = 'completed',
                last_payment_date = CURRENT_TIMESTAMP,
                updated_at = CURRENT_TIMESTAMP
            WHERE id = ${payrollData.id}
          `;

          logger.info(`Payroll ${payrollData.id} executed successfully (one-time)`);
        }
      } catch (error) {
        const payrollData = payroll as any;
        logger.error(`Failed to execute payroll ${payrollData.id}:`, error);

        // Mark as failed and keep status as scheduled for retry
        await db`
          UPDATE payroll
          SET status = 'scheduled', updated_at = CURRENT_TIMESTAMP
          WHERE id = ${payrollData.id}
        `;
      }
    }

    logger.info('Payroll execution job completed');
  } catch (error) {
    logger.error('Payroll execution job failed:', error);
  }
};

// Run every hour to check for due payrolls
// Cron format: minute hour day month day-of-week
// '0 * * * *' = every hour at minute 0
cron.schedule('0 * * * *', executePayrollPayments, {
  scheduled: true,
  timezone: 'UTC',
});

logger.info('Payroll cron job scheduled to run every hour');

// Also run immediately on startup (for testing/development)
if (process.env.NODE_ENV === 'development') {
  setTimeout(() => {
    executePayrollPayments();
  }, 5000); // Run after 5 seconds
}

export { executePayrollPayments };

