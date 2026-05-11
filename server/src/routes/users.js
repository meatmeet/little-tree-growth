import { Router } from 'express';
import { query, queryOne } from '../config/db.js';
import { authRequired } from '../middleware/auth.js';
import { success, fail } from '../utils/response.js';

const router = Router();

router.get('/profile', authRequired, async (req, res) => {
  try {
    const user = queryOne('SELECT id, phone, email, nickname, avatar_url, is_vip, vip_expire_at, created_at FROM users WHERE id = ?', [req.user.id]);
    if (!user) return res.status(404).json(fail('用户不存在'));
    return res.json(success(user));
  } catch (err) {
    console.error('[user/profile]', err.message);
    return res.status(500).json(fail('获取用户信息失败'));
  }
});

router.put('/profile', authRequired, async (req, res) => {
  try {
    const { nickname, email, avatar_url } = req.body;
    const result = query(
      `UPDATE users SET nickname = COALESCE(?, nickname), email = COALESCE(?, email), avatar_url = COALESCE(?, avatar_url) WHERE id = ? RETURNING id, phone, email, nickname, avatar_url, is_vip, vip_expire_at`,
      [nickname, email, avatar_url, req.user.id]
    );
    return res.json(success(result.rows[0], '更新成功'));
  } catch (err) {
    console.error('[user/profile/update]', err.message);
    return res.status(500).json(fail('更新失败'));
  }
});

router.get('/vip-status', authRequired, async (req, res) => {
  try {
    const user = queryOne('SELECT is_vip, vip_expire_at FROM users WHERE id = ?', [req.user.id]);
    if (!user) return res.status(404).json(fail('用户不存在'));
    const daysRemaining = user.is_vip && user.vip_expire_at
      ? Math.max(0, Math.ceil((new Date(user.vip_expire_at) - new Date()) / 86400000))
      : 0;
    return res.json(success({ is_vip: !!user.is_vip, vip_expire_at: user.vip_expire_at, days_remaining: daysRemaining }));
  } catch (err) {
    console.error('[user/vip-status]', err.message);
    return res.status(500).json(fail('获取会员信息失败'));
  }
});

export default router;
