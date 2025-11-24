import express, { Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import swaggerUi from 'swagger-ui-express';
import env from './config/env';
import logger from './utils/logger';
import { errorHandler } from './middleware/errorHandler.middleware';
import { apiLimiter } from './middleware/rateLimit.middleware';
import { testConnection } from './config/database';
import { swaggerSpec } from './config/swagger';

// Routes
import authRoutes from './routes/auth.routes';
import invoiceRoutes from './routes/invoice.routes';
import paymentRoutes from './routes/payment.routes';
import payrollRoutes from './routes/payroll.routes';
import dashboardRoutes from './routes/dashboard.routes';

// Import payroll job to start cron scheduler
import './jobs/payroll.job';
import { Express } from 'express';

const app: Express = express();

// Security middleware
app.use(helmet());
app.use(
  cors({
    origin: env.CORS_ORIGIN === '*' ? true : env.CORS_ORIGIN.split(','),
    credentials: true,
  })
);

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Rate limiting
app.use('/api', apiLimiter);

// Swagger API Documentation
app.use('/', swaggerUi.serve);
app.get('/', swaggerUi.setup(swaggerSpec, {
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'Klytic Pay API Documentation',
}));
// OpenAPI JSON spec endpoint
app.get('/api-docs.json', (_req: Request, res: Response) => {
  res.setHeader('Content-Type', 'application/json');
  res.send(swaggerSpec);
});

// Health check
app.get('/health', async (_req: Request, res: Response) => {
  const dbHealthy = await testConnection();
  res.status(dbHealthy ? 200 : 503).json({
    status: dbHealthy ? 'healthy' : 'unhealthy',
    timestamp: new Date().toISOString(),
    database: dbHealthy ? 'connected' : 'disconnected',
  });
});

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/invoices', invoiceRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/payroll', payrollRoutes);
app.use('/api/dashboard', dashboardRoutes);

// 404 handler
app.use((_req: Request, res: Response) => {
  res.status(404).json({ error: 'Route not found' });
});

// Error handler (must be last)
app.use(errorHandler);

// Start server
const PORT = env.PORT;

app.listen(PORT, () => {
  logger.info(`Server running on port ${PORT}`);
  logger.info(`Environment: ${env.NODE_ENV}`);
  logger.info(`Solana Network: ${env.SOLANA_NETWORK}`);
});

export default app;

