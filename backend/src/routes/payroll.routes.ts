import { Router } from 'express';
import {
  createPayroll,
  getPayrolls,
  getPayroll,
  cancelPayroll,
} from '../controllers/payroll.controller';
import { authenticate } from '../middleware/auth.middleware';
import { validate } from '../middleware/validator.middleware';
import { body, param, query } from 'express-validator';

const router: Router = Router();

router.use(authenticate);

/**
 * @swagger
 * /api/payroll:
 *   post:
 *     summary: Create a new payroll schedule
 *     tags: [Payroll]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - payeeName
 *               - walletAddress
 *               - amount
 *               - currency
 *               - frequency
 *             properties:
 *               payeeName:
 *                 type: string
 *                 maxLength: 255
 *                 example: John Doe
 *               walletAddress:
 *                 type: string
 *                 description: Solana wallet address
 *                 example: 7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU
 *               amount:
 *                 type: number
 *                 minimum: 0.01
 *                 example: 1000.00
 *               currency:
 *                 type: string
 *                 enum: [SOL, USDC]
 *                 example: USDC
 *               frequency:
 *                 type: string
 *                 enum: [oneTime, weekly]
 *                 example: weekly
 *     responses:
 *       201:
 *         description: Payroll created successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 payroll:
 *                   $ref: '#/components/schemas/Payroll'
 *       400:
 *         description: Validation error or max payees limit reached
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post(
  '/',
  [
    body('payeeName').notEmpty().isString().isLength({ max: 255 }),
    body('walletAddress').notEmpty().isString(),
    body('amount').isFloat({ min: 0.01 }),
    body('currency').isIn(['SOL', 'USDC']),
    body('frequency').isIn(['oneTime', 'weekly']),
  ],
  validate,
  createPayroll
);

/**
 * @swagger
 * /api/payroll:
 *   get:
 *     summary: Get list of payroll schedules
 *     tags: [Payroll]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [scheduled, processing, completed, cancelled]
 *         description: Filter by payroll status
 *     responses:
 *       200:
 *         description: List of payroll schedules
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 payrolls:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Payroll'
 */
router.get(
  '/',
  [
    query('status').optional().isIn(['scheduled', 'processing', 'completed', 'cancelled']),
  ],
  validate,
  getPayrolls
);

/**
 * @swagger
 * /api/payroll/{id}:
 *   get:
 *     summary: Get payroll schedule by ID
 *     tags: [Payroll]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: Payroll ID
 *     responses:
 *       200:
 *         description: Payroll schedule details
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 payroll:
 *                   $ref: '#/components/schemas/Payroll'
 *       404:
 *         description: Payroll not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/:id', [param('id').isUUID()], validate, getPayroll);

/**
 * @swagger
 * /api/payroll/{id}:
 *   delete:
 *     summary: Cancel a payroll schedule
 *     tags: [Payroll]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: Payroll ID
 *     responses:
 *       200:
 *         description: Payroll cancelled successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 payroll:
 *                   $ref: '#/components/schemas/Payroll'
 *       404:
 *         description: Payroll not found or cannot be cancelled
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.delete('/:id', [param('id').isUUID()], validate, cancelPayroll);

export default router;

