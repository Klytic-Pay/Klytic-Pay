import { neon, neonConfig, NeonQueryFunction } from '@neondatabase/serverless';
import { Pool } from 'pg';
import env from './env';
import logger from '../utils/logger';

neonConfig.fetchConnectionCache = true;

// Check if using local PostgreSQL (not Neon)
const isLocalPostgres = env.DATABASE_URL.includes('@localhost') || 
                        env.DATABASE_URL.includes('@db:') || 
                        env.DATABASE_URL.includes('@127.0.0.1') ||
                        (!env.DATABASE_URL.includes('neon.tech'));

let neonDb: NeonQueryFunction<boolean, boolean> | null = null;
let pgPool: Pool | null = null;

// Unified database interface that works with both Neon and pg Pool
type DatabaseQuery = {
  (strings: TemplateStringsArray, ...values: any[]): Promise<any>;
};

const createDatabaseQuery = (): DatabaseQuery => {
  if (isLocalPostgres) {
    // For local PostgreSQL, convert template literals to parameterized queries
    return async (strings: TemplateStringsArray, ...values: any[]): Promise<any> => {
      if (!pgPool) {
        pgPool = new Pool({
          connectionString: env.DATABASE_URL,
        });
        logger.info('Local PostgreSQL connection initialized');
      }

      // Convert template literal to parameterized query
      let queryText = '';
      const queryParams: any[] = [];
      let paramIndex = 1;

      for (let i = 0; i < strings.length; i++) {
        queryText += strings[i];
        if (i < values.length) {
          queryText += `$${paramIndex}`;
          queryParams.push(values[i]);
          paramIndex++;
        }
      }

      const result = await pgPool.query(queryText, queryParams);
      return result.rows;
    };
  } else {
    // For Neon, use template literals directly
    if (!neonDb) {
      neonDb = neon(env.DATABASE_URL);
      logger.info('Neon database connection initialized');
    }
    return neonDb as DatabaseQuery;
  }
};

let db: DatabaseQuery;

export const getDatabase = (): DatabaseQuery => {
  if (!db) {
    try {
      db = createDatabaseQuery();
    } catch (error) {
      logger.error('Failed to initialize database connection:', error);
      throw error;
    }
  }
  return db;
};

export const testConnection = async (): Promise<boolean> => {
  try {
    const database = getDatabase();
    await database`SELECT 1`;
    logger.info('Database connection test successful');
    return true;
  } catch (error) {
    logger.error('Database connection test failed:', error);
    return false;
  }
};

export default getDatabase;
