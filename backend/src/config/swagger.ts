import swaggerJsdoc from 'swagger-jsdoc';
import env from './env';

const options: swaggerJsdoc.Options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Klytic Pay API',
      version: '1.0.0',
      description: 'API documentation for Klytic Pay - Solana-based payroll and invoicing platform',
      contact: {
        name: 'Klytic Pay Support',
      },
    },
    servers: [
      {
        url: `http://localhost:${env.PORT}`,
        description: 'Development server',
      },
      {
        url: 'https://api.klyticpay.com',
        description: 'Production server',
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          description: 'JWT token obtained from /api/auth/login or /api/auth/register',
        },
      },
      schemas: {
        Error: {
          type: 'object',
          properties: {
            error: {
              type: 'string',
              description: 'Error message',
            },
          },
        },
        User: {
          type: 'object',
          properties: {
            id: {
              type: 'string',
              format: 'uuid',
            },
            email: {
              type: 'string',
              format: 'email',
            },
            walletPublicKey: {
              type: 'string',
              description: 'Solana wallet public key',
            },
          },
        },
        AuthResponse: {
          type: 'object',
          properties: {
            user: {
              $ref: '#/components/schemas/User',
            },
            token: {
              type: 'string',
              description: 'JWT authentication token',
            },
          },
        },
        Invoice: {
          type: 'object',
          properties: {
            id: {
              type: 'string',
              format: 'uuid',
            },
            clientEmail: {
              type: 'string',
              format: 'email',
            },
            amountUsd: {
              type: 'number',
            },
            amountSol: {
              type: 'number',
              nullable: true,
            },
            amountUsdc: {
              type: 'number',
              nullable: true,
            },
            currency: {
              type: 'string',
              enum: ['USD', 'SOL', 'USDC'],
            },
            description: {
              type: 'string',
              nullable: true,
            },
            status: {
              type: 'string',
              enum: ['pending', 'paid', 'cancelled'],
            },
            referencePublicKey: {
              type: 'string',
              description: 'Solana Pay reference public key',
            },
            qrCodeUrl: {
              type: 'string',
              format: 'uri',
              description: 'Solana Pay QR code URL',
            },
            createdAt: {
              type: 'string',
              format: 'date-time',
            },
            updatedAt: {
              type: 'string',
              format: 'date-time',
            },
          },
        },
        Payroll: {
          type: 'object',
          properties: {
            id: {
              type: 'string',
              format: 'uuid',
            },
            payeeName: {
              type: 'string',
            },
            payeeWalletAddress: {
              type: 'string',
              description: 'Solana wallet address',
            },
            amountUsd: {
              type: 'number',
            },
            amountSol: {
              type: 'number',
              nullable: true,
            },
            amountUsdc: {
              type: 'number',
              nullable: true,
            },
            currency: {
              type: 'string',
              enum: ['SOL', 'USDC'],
            },
            frequency: {
              type: 'string',
              enum: ['oneTime', 'weekly'],
            },
            nextPaymentDate: {
              type: 'string',
              format: 'date-time',
            },
            status: {
              type: 'string',
              enum: ['scheduled', 'processing', 'completed', 'cancelled'],
            },
            createdAt: {
              type: 'string',
              format: 'date-time',
            },
            updatedAt: {
              type: 'string',
              format: 'date-time',
            },
          },
        },
        DashboardSummary: {
          type: 'object',
          properties: {
            invoices: {
              type: 'object',
              properties: {
                total: {
                  type: 'number',
                },
                pending: {
                  type: 'number',
                },
                paid: {
                  type: 'number',
                },
                totalPaidAmount: {
                  type: 'number',
                },
              },
            },
            payroll: {
              type: 'object',
              properties: {
                scheduled: {
                  type: 'number',
                },
                processing: {
                  type: 'number',
                },
              },
            },
            recentInvoices: {
              type: 'array',
              items: {
                $ref: '#/components/schemas/Invoice',
              },
            },
          },
        },
        PaymentStatus: {
          type: 'object',
          properties: {
            status: {
              type: 'string',
              enum: ['pending', 'paid', 'cancelled'],
            },
            transactionHash: {
              type: 'string',
              nullable: true,
            },
            blockTime: {
              type: 'number',
              nullable: true,
            },
          },
        },
      },
    },
    tags: [
      {
        name: 'Authentication',
        description: 'User registration and authentication endpoints',
      },
      {
        name: 'Invoices',
        description: 'Invoice creation and management',
      },
      {
        name: 'Payments',
        description: 'Payment verification and status',
      },
      {
        name: 'Payroll',
        description: 'Payroll scheduling and management',
      },
      {
        name: 'Dashboard',
        description: 'Dashboard statistics and summaries',
      },
    ],
  },
  apis: ['./src/routes/*.ts', './src/controllers/*.ts'],
};

export const swaggerSpec = swaggerJsdoc(options);

