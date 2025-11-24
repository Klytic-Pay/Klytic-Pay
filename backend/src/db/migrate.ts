import { readFileSync } from 'fs';
import { join } from 'path';
import { Pool } from 'pg';
import env from '../config/env';
import logger from '../utils/logger';

const runMigrations = async (): Promise<void> => {
  const pool = new Pool({
    connectionString: env.DATABASE_URL,
  });

  try {
    // Note: For complex migrations, consider using a proper migration tool
    // This is a basic implementation that may need adjustment for multi-statement SQL
    const schemaPath = join(__dirname, 'schema.sql');
    const schema = readFileSync(schemaPath, 'utf-8');

    // Split by semicolons and execute each statement
    const statements = schema
      .split(';')
      .map((s) => s.trim())
      .filter((s) => s.length > 0 && !s.startsWith('--'));

    logger.info(`Running ${statements.length} migration statements...`);

    for (const statement of statements) {
      try {
        // Execute raw SQL using pg Pool
        await pool.query(statement);
        logger.info('Migration statement executed successfully');
      } catch (error: any) {
        // Ignore "already exists" errors
        if (error?.message?.includes('already exists')) {
          logger.warn('Migration statement skipped (already exists)');
          continue;
        }
        throw error;
      }
    }

    logger.info('Migrations completed successfully');
  } catch (error) {
    logger.error('Migration failed:', error);
    throw error;
  } finally {
    await pool.end();
  }
};

if (require.main === module) {
  runMigrations()
    .then(() => {
      logger.info('Migration script completed');
      process.exit(0);
    })
    .catch((error) => {
      logger.error('Migration script failed:', error);
      process.exit(1);
    });
}

export default runMigrations;
