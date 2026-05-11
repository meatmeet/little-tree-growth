import jwt from 'jsonwebtoken';
import { unauthorized } from '../utils/response.js';

const JWT_SECRET = process.env.JWT_SECRET || 'little-tree-growth-secret-key-2026';

export function generateToken(payload) {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: '30d' });
}

export function authRequired(req, res, next) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json(unauthorized());
  }

  try {
    const token = header.split(' ')[1];
    req.user = jwt.verify(token, JWT_SECRET);
    next();
  } catch {
    return res.status(401).json(unauthorized('登录已过期，请重新登录'));
  }
}

export function authOptional(req, res, next) {
  const header = req.headers.authorization;
  if (header && header.startsWith('Bearer ')) {
    try {
      const token = header.split(' ')[1];
      req.user = jwt.verify(token, JWT_SECRET);
    } catch {
      // Token invalid, continue without user
    }
  }
  next();
}
