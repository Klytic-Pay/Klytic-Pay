// Optional seed file for development
// This can be used to populate the database with test data

import logger from '../utils/logger';

const seed = async (): Promise<void> => {
  logger.info('Seeding database...');
  // Add seed data here if needed
  logger.info('Database seeding completed');
};

if (require.main === module) {
  seed()
    .then(() => {
      logger.info('Seed script completed');
      process.exit(0);
    })
    .catch((error) => {
      logger.error('Seed script failed:', error);
      process.exit(1);
    });
}

export default seed;

