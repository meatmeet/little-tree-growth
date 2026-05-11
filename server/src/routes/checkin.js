import { Router } from 'express';
import { query, queryOne } from '../config/db.js';
import { authRequired } from '../middleware/auth.js';
import { success, fail } from '../utils/response.js';

const router = Router();

router.post('/', authRequired, async (req, res) => {
  try {
    const { baby_id } = req.body;
    if (!baby_id) return res.status(400).json(fail('缺少 baby_id'));
    const today = new Date().toISOString().split('T')[0];
    const existing = queryOne('SELECT id, streak_days FROM checkin_records WHERE baby_id = ? AND checkin_date = ?', [baby_id, today]);
    if (existing) return res.json(success({ streak_days: existing.streak_days }, '今日已打卡'));

    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const ys = yesterday.toISOString().split('T')[0];
    const prev = queryOne('SELECT streak_days FROM checkin_records WHERE baby_id = ? AND checkin_date = ?', [baby_id, ys]);
    const newStreak = (prev?.streak_days || 0) + 1;

    const cnt = queryOne("SELECT COUNT(*) as cnt FROM baby_daily_tasks WHERE baby_id = ? AND assign_date = ? AND is_completed = 1", [baby_id, today]);
    const total = queryOne("SELECT COUNT(*) as cnt FROM baby_daily_tasks WHERE baby_id = ? AND assign_date = ?", [baby_id, today]);
    const isFull = total.cnt > 0 && cnt.cnt >= total.cnt;

    query(
      `INSERT INTO checkin_records (baby_id, checkin_date, tasks_completed, is_full_complete, streak_days) VALUES (?,?,?,?,?)`,
      [baby_id, today, cnt.cnt || 0, isFull ? 1 : 0, newStreak]
    );
    return res.json(success({ streak_days: newStreak }, '打卡成功'));
  } catch (err) {
    console.error('[checkin]', err.message);
    return res.status(500).json(fail('打卡失败'));
  }
});

router.get('/calendar', authRequired, async (req, res) => {
  try {
    const { baby_id, month } = req.query;
    if (!baby_id || !month) return res.status(400).json(fail('缺少参数'));
    const rows = query(
      `SELECT checkin_date, is_full_complete, streak_days FROM checkin_records WHERE baby_id = ? AND strftime('%Y-%m', checkin_date) = ? ORDER BY checkin_date`,
      [baby_id, month]
    ).rows;
    return res.json(success(rows));
  } catch (err) {
    console.error('[checkin/calendar]', err.message);
    return res.status(500).json(fail('获取打卡日历失败'));
  }
});

router.get('/streak', authRequired, async (req, res) => {
  try {
    const { baby_id } = req.query;
    if (!baby_id) return res.status(400).json(fail('缺少 baby_id'));
    const today = queryOne("SELECT streak_days FROM checkin_records WHERE baby_id = ? AND checkin_date = date('now','localtime')", [baby_id]);
    const total = queryOne('SELECT COUNT(*) as cnt FROM checkin_records WHERE baby_id = ?', [baby_id]);
    return res.json(success({ streak_days: today?.streak_days || 0, total_days: total.cnt }));
  } catch (err) {
    console.error('[checkin/streak]', err.message);
    return res.status(500).json(fail('获取连续天数失败'));
  }
});

export default router;
