import { Router } from 'express';
import {
  createInvoice,
  getInvoices,
  getInvoice,
  cancelInvoice,
} from '../controllers/invoice.controller';
import { authenticate } from '../middleware/auth.middleware';
import { validate } from '../middleware/validator.middleware';
import { body, param, query } from 'express-validator';

const router: Router = Router();

router.use(authenticate);

/**
 * @swagger
 * /api/invoices:
 *   post:
 *     summary: Create a new invoice
 *     tags: [Invoices]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - clientEmail
 *               - amount
 *               - currency
 *             properties:
 *               clientEmail:
 *                 type: string
 *                 format: email
 *                 example: client@example.com
 *               amount:
 *                 type: number
 *                 minimum: 0.01
 *                 example: 100.50
 *               currency:
 *                 type: string
 *                 enum: [USD, SOL, USDC]
 *                 example: USD
 *               description:
 *                 type: string
 *                 maxLength: 500
 *                 example: Payment for services rendered
 *     responses:
 *       201:
 *         description: Invoice created successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 invoice:
 *                   $ref: '#/components/schemas/Invoice'
 *       400:
 *         description: Validation error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post(
  '/',
  [
    body('clientEmail').isEmail().normalizeEmail(),
    body('amount').isFloat({ min: 0.01 }),
    body('currency').isIn(['USD', 'SOL', 'USDC']),
    body('description').optional().isString().isLength({ max: 500 }),
  ],
  validate,
  createInvoice
);

/**
 * @swagger
 * /api/invoices:
 *   get:
 *     summary: Get list of invoices
 *     tags: [Invoices]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [pending, paid, overdue, cancelled]
 *         description: Filter by invoice status
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 100
 *           default: 20
 *         description: Number of invoices to return
 *       - in: query
 *         name: offset
 *         schema:
 *           type: integer
 *           minimum: 0
 *           default: 0
 *         description: Number of invoices to skip
 *     responses:
 *       200:
 *         description: List of invoices
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 invoices:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Invoice'
 *                 total:
 *                   type: number
 */
router.get(
  '/',
  [
    query('status').optional().isIn(['pending', 'paid', 'overdue', 'cancelled']),
    query('limit').optional().isInt({ min: 1, max: 100 }),
    query('offset').optional().isInt({ min: 0 }),
  ],
  validate,
  getInvoices
);

/**
 * @swagger
 * /api/invoices/{id}:
 *   get:
 *     summary: Get invoice by ID
 *     tags: [Invoices]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: Invoice ID
 *     responses:
 *       200:
 *         description: Invoice details
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 invoice:
 *                   $ref: '#/components/schemas/Invoice'
 *       404:
 *         description: Invoice not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/:id', [param('id').isUUID()], validate, getInvoice);

/**
 * @swagger
 * /api/invoices/{id}/cancel:
 *   patch:
 *     summary: Cancel an invoice
 *     tags: [Invoices]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *         description: Invoice ID
 *     responses:
 *       200:
 *         description: Invoice cancelled successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 invoice:
 *                   $ref: '#/components/schemas/Invoice'
 *       404:
 *         description: Invoice not found or cannot be cancelled
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.patch('/:id/cancel', [param('id').isUUID()], validate, cancelInvoice);

export default router;

