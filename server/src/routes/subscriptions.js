import { Router } from 'express';
import { query, queryOne } from '../config/db.js';
import { authRequired } from '../middleware/auth.js';
import { success, fail } from '../utils/response.js';

const router = Router();

router.post('/', authRequired, async (req, res) => {
  try {
    const { plan_type, payment_method } = req.body;
    if (!['monthly', 'yearly'].includes(plan_type)) return res.status(400).json(fail('无效的套餐类型'));

    const amount = plan_type === 'monthly' ? 29.0 : 299.0;
    const startDate = new Date().toISOString().split('T')[0];
    const endDate = new Date();
    endDate.setMonth(endDate.getMonth() + (plan_type === 'monthly' ? 1 : 12));
    const endDateStr = endDate.toISOString().split('T')[0];

    const result = query(
      `INSERT INTO subscriptions (user_id, plan_type, start_date, end_date, payment_amount, payment_method, status) VALUES (?,?,?,?,?,?,'active') RETURNING *`,
      [req.user.id, plan_type, startDate, endDateStr, amount, payment_method || 'apple_pay']
    );
    query('UPDATE users SET is_vip = 1, vip_expire_at = ? WHERE id = ?', [endDateStr, req.user.id]);
    return res.json(success(result.rows[0], '开通成功'));
  } catch (err) {
    console.error('[subscriptions/create]', err.message);
    return res.status(500).json(fail('开通会员失败'));
  }
});

router.get('/current', authRequired, async (req, res) => {
  try {
    const sub = queryOne(
      "SELECT * FROM subscriptions WHERE user_id = ? AND status = 'active' ORDER BY created_at DESC LIMIT 1",
      [req.user.id]
    );
    if (!sub) return res.json(success({ has_subscription: false }));
    return res.json(success({
      has_subscription: true, plan_type: sub.plan_type, start_date: sub.start_date, end_date: sub.end_date,
      days_remaining: Math.max(0, Math.ceil((new Date(sub.end_date) - new Date()) / 86400000)),
      status: sub.status,
    }));
  } catch (err) {
    console.error('[subscriptions/current]', err.message);
    return res.status(500).json(fail('获取订阅信息失败'));
  }
});

router.post('/cancel', authRequired, async (req, res) => {
  try {
    query("UPDATE subscriptions SET status = 'cancelled' WHERE user_id = ? AND status = 'active'", [req.user.id]);
    return res.json(success(null, '已取消续费'));
  } catch (err) {
    console.error('[subscriptions/cancel]', err.message);
    return res.status(500).json(fail('取消失败'));
  }
});

export default router;
