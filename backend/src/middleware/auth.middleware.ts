import { Request, Response, NextFunction } from 'express';
import { verifyToken } from '../config/jwt';
import logger from '../utils/logger';

export interface AuthRequest extends Request {
  user?: {
    userId: string;
    email: string;
  };
}

export const authenticate = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      res.status(401).json({ error: 'No token provided' });
      return;
    }

    const token = authHeader.substring(7); // Remove 'Bearer ' prefix

    try {
      const payload = verifyToken(token);
      req.user = {
        userId: payload.userId,
        email: payload.email,
      };
      next();
    } catch (error) {
      logger.warn('Token verification failed:', error);
      res.status(401).json({ error: 'Invalid or expired token' });
      return;
    }
  } catch (error) {
    logger.error('Authentication middleware error:', error);
    res.status(500).json({ error: 'Authentication failed' });
    return;
  }
};
