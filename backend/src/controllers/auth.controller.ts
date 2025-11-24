import { Response } from 'express';
import { register, login, getUserById } from '../services/auth.service';
import { ValidationError } from '../utils/errors';
import logger from '../utils/logger';
import { AuthRequest } from '../middleware/auth.middleware';

export const registerUser = async (req: any, res: Response): Promise<void> => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      throw new ValidationError('Email and password are required');
    }

    if (password.length < 8) {
      throw new ValidationError('Password must be at least 8 characters');
    }

    const result = await register({ email, password });

    res.status(201).json({
      message: 'User registered successfully',
      user: result.user,
      token: result.token,
    });
  } catch (error) {
    logger.error('Register error:', error);
    throw error;
  }
};

export const loginUser = async (req: any, res: Response): Promise<void> => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      throw new ValidationError('Email and password are required');
    }

    const result = await login({ email, password });

    res.json({
      message: 'Login successful',
      user: result.user,
      token: result.token,
    });
  } catch (error) {
    logger.error('Login error:', error);
    throw error;
  }
};

export const getCurrentUser = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const user = await getUserById(userId);

    if (!user) {
      throw new ValidationError('User not found');
    }

    res.json({
      user: {
        id: user.id,
        email: user.email,
        walletPublicKey: user.wallet_public_key,
        createdAt: user.created_at,
      },
    });
  } catch (error) {
    logger.error('Get current user error:', error);
    throw error;
  }
};
