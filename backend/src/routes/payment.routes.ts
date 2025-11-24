import { Router } from 'express';
import {
  getPaymentStatus,
  verifyPaymentTransaction,
} from '../controllers/payment.controller';
import { authenticate } from '../middleware/auth.middleware';
import { validate } from '../middleware/validator.middleware';
import { param, body } from 'express-validator';

const router: Router = Router();

router.use(authenticate);

/**
 * @swagger
 * /api/payments/status/{reference}:
 *   get:
 *     summary: Get payment status by reference
 *     tags: [Payments]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: reference
 *         required: true
 *         schema:
 *           type: string
 *         description: Solana Pay reference public key
 *     responses:
 *       200:
 *         description: Payment status
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/PaymentStatus'
 *       404:
 *         description: Payment reference not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/status/:reference', [param('reference').notEmpty()], validate, getPaymentStatus);

/**
 * @swagger
 * /api/payments/verify:
 *   post:
 *     summary: Verify a payment transaction
 *     tags: [Payments]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - transactionHash
 *             properties:
 *               transactionHash:
 *                 type: string
 *                 description: Solana transaction hash
 *                 example: 5j7s8K9L0mN1oP2qR3sT4uV5wX6yZ7aB8cD9eF0gH1iJ2kL3mN4oP5qR6sT7uV8wX9yZ0aB1cD2eF3gH4iJ5k
 *     responses:
 *       200:
 *         description: Transaction verification result
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 verified:
 *                   type: boolean
 *                 transaction:
 *                   $ref: '#/components/schemas/PaymentStatus'
 *       400:
 *         description: Invalid transaction hash
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post(
  '/verify',
  [body('transactionHash').notEmpty().isString()],
  validate,
  verifyPaymentTransaction
);

export default router;

