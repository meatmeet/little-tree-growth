import { Router } from 'express';
import bcrypt from 'bcryptjs';
import { query, queryOne } from '../config/db.js';
import { generateToken } from '../middleware/auth.js';
import { validate } from '../middleware/validate.js';
import { success, fail } from '../utils/response.js';

const router = Router();

router.post('/register', validate({
  phone: { required: true, message: '手机号必填' },
  password: { required: true, message: '密码必填' },
}), async (req, res) => {
  try {
    const { phone, password, nickname } = req.body;
    const existing = queryOne('SELECT id FROM users WHERE phone = ?', [phone]);
    if (existing) return res.status(400).json(fail('该手机号已注册'));

    const hash = await bcrypt.hash(password, 10);
    const result = query('INSERT INTO users (phone, password_hash, nickname) VALUES (?,?,?) RETURNING id', [phone, hash, nickname || null]);
    const user = result.rows[0];
    const token = generateToken({ id: user.id, phone });
    return res.json(success({ token, user_id: user.id }, '注册成功'));
  } catch (err) {
    console.error('[auth/register]', err.message);
    return res.status(500).json(fail('注册失败'));
  }
});

router.post('/login', validate({
  phone: { required: true }, password: { required: true },
}), async (req, res) => {
  try {
    const { phone, password } = req.body;
    const user = queryOne('SELECT * FROM users WHERE phone = ?', [phone]);
    if (!user) return res.status(400).json(fail('手机号未注册'));

    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) return res.status(400).json(fail('密码错误'));

    const token = generateToken({ id: user.id, phone: user.phone });
    const { password_hash, ...safe } = user;
    return res.json(success({ token, user: safe }));
  } catch (err) {
    console.error('[auth/login]', err.message);
    return res.status(500).json(fail('登录失败'));
  }
});

router.post('/send-code', validate({ phone: { required: true } }), (req, res) => {
  console.log(`[SMS] Verification code for ${req.body.phone}: 123456`);
  return res.json(success(null, '验证码已发送'));
});

export default router;
