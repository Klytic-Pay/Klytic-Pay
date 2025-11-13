import { Connection, PublicKey, Cluster } from '@solana/web3.js';
import env from './env';
import logger from '../utils/logger';

let connection: Connection;
let usdcMint: PublicKey | null = null;

export const getConnection = (): Connection => {
  if (!connection) {
    connection = new Connection(env.SOLANA_RPC_URL, 'confirmed');
    logger.info(`Solana connection initialized: ${env.SOLANA_NETWORK}`);
  }
  return connection;
};

export const getUsdcMint = (): PublicKey => {
  if (!usdcMint) {
    if (env.SOLANA_USDC_MINT) {
      usdcMint = new PublicKey(env.SOLANA_USDC_MINT);
    } else {
      // Default USDC mint addresses
      const defaultMints: Record<string, string> = {
        devnet: '4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU', // Devnet USDC
        'mainnet-beta': 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v', // Mainnet USDC
      };
      const mintAddress = defaultMints[env.SOLANA_NETWORK] || defaultMints.devnet;
      usdcMint = new PublicKey(mintAddress);
    }
    logger.info(`USDC Mint: ${usdcMint.toBase58()}`);
  }
  return usdcMint;
};

export const getNetwork = (): Cluster => {
  return env.SOLANA_NETWORK as Cluster;
};

export default getConnection;
