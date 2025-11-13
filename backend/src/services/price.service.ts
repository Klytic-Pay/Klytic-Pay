import getDatabase from '../config/database';
import env from '../config/env';
import logger from '../utils/logger';
import Big from 'big.js';

const PRICE_CACHE_TTL = env.PRICE_FEED_UPDATE_INTERVAL; // 5 minutes default

interface PriceData {
  sol: number;
  usdc: number;
}

/**
 * Fetch current prices from CoinGecko API
 */
const fetchPricesFromAPI = async (): Promise<PriceData> => {
  const apiUrl = env.PRICE_FEED_API_URL || 'https://api.coingecko.com/api/v3';
  
  try {
    const response = await fetch(
      `${apiUrl}/simple/price?ids=solana,usd-coin&vs_currencies=usd`
    );

    if (!response.ok) {
      throw new Error(`Price API returned ${response.status}`);
    }

    const data = (await response.json()) as {
      solana?: { usd?: number };
      'usd-coin'?: { usd?: number };
    };

    return {
      sol: data.solana?.usd || 0,
      usdc: data['usd-coin']?.usd || 1.0, // Default to $1 if unavailable
    };
  } catch (error) {
    logger.error('Failed to fetch prices from API:', error);
    throw error;
  }
};

/**
 * Get cached prices from database
 */
const getCachedPrices = async (): Promise<PriceData | null> => {
  const db = getDatabase();

  try {
    const solResult = await db`
      SELECT price_usd, updated_at
      FROM price_feeds
      WHERE token = 'SOL'
    `;
    const solPrice = Array.isArray(solResult) ? solResult[0] : (solResult as any);

    const usdcResult = await db`
      SELECT price_usd, updated_at
      FROM price_feeds
      WHERE token = 'USDC'
    `;
    const usdcPrice = Array.isArray(usdcResult) ? usdcResult[0] : (usdcResult as any);

    if (!solPrice || !usdcPrice) {
      return null;
    }

    const now = Date.now();
    const solAge = now - new Date(solPrice.updated_at).getTime();
    const usdcAge = now - new Date(usdcPrice.updated_at).getTime();

    // Check if cache is still valid
    if (solAge > PRICE_CACHE_TTL || usdcAge > PRICE_CACHE_TTL) {
      return null;
    }

    return {
      sol: Number(solPrice.price_usd),
      usdc: Number(usdcPrice.price_usd),
    };
  } catch (error) {
    logger.error('Failed to get cached prices:', error);
    return null;
  }
};

/**
 * Update price cache in database
 */
const updatePriceCache = async (prices: PriceData): Promise<void> => {
  const db = getDatabase();

  try {
    await db`
      INSERT INTO price_feeds (token, price_usd, source, updated_at)
      VALUES ('SOL', ${prices.sol}, 'coingecko', CURRENT_TIMESTAMP)
      ON CONFLICT (token) DO UPDATE
      SET price_usd = ${prices.sol}, source = 'coingecko', updated_at = CURRENT_TIMESTAMP
    `;

    await db`
      INSERT INTO price_feeds (token, price_usd, source, updated_at)
      VALUES ('USDC', ${prices.usdc}, 'coingecko', CURRENT_TIMESTAMP)
      ON CONFLICT (token) DO UPDATE
      SET price_usd = ${prices.usdc}, source = 'coingecko', updated_at = CURRENT_TIMESTAMP
    `;

    logger.info('Price cache updated', prices);
  } catch (error) {
    logger.error('Failed to update price cache:', error);
    throw error;
  }
};

/**
 * Get current prices (from cache or API)
 */
export const getPrices = async (): Promise<PriceData> => {
  // Try cache first
  const cached = await getCachedPrices();
  if (cached) {
    return cached;
  }

  // Fetch from API
  try {
    const prices = await fetchPricesFromAPI();
    await updatePriceCache(prices);
    return prices;
  } catch (error) {
    logger.error('Failed to get prices, using fallback:', error);
    // Fallback to default prices
    return {
      sol: 150.0, // Fallback SOL price
      usdc: 1.0, // USDC is always ~$1
    };
  }
};

/**
 * Convert USD to SOL
 */
export const usdToSol = async (usdAmount: number): Promise<number> => {
  const prices = await getPrices();
  if (prices.sol === 0) {
    throw new Error('SOL price not available');
  }
  return Big(usdAmount).div(prices.sol).toNumber();
};

/**
 * Convert USD to USDC
 */
export const usdToUsdc = async (usdAmount: number): Promise<number> => {
  const prices = await getPrices();
  return Big(usdAmount).div(prices.usdc).toNumber();
};

/**
 * Convert SOL to USD
 */
export const solToUsd = async (solAmount: number): Promise<number> => {
  const prices = await getPrices();
  return Big(solAmount).times(prices.sol).toNumber();
};

/**
 * Convert USDC to USD
 */
export const usdcToUsd = async (usdcAmount: number): Promise<number> => {
  const prices = await getPrices();
  return Big(usdcAmount).times(prices.usdc).toNumber();
};
