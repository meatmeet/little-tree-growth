import { Router } from 'express';
import { query } from '../config/db.js';
import { authRequired } from '../middleware/auth.js';
import { success, fail } from '../utils/response.js';
import { getDailyTasks, generateDailyTasks } from '../services/task_generator.js';

const router = Router();

router.get('/daily', authRequired, async (req, res) => {
  try {
    const { baby_id, date } = req.query;
    if (!baby_id) return res.status(400).json(fail('缺少 baby_id'));
    const today = new Date().toISOString().split('T')[0];
    const targetDate = date || today;
    let tasks = getDailyTasks(baby_id, targetDate);
    if (tasks.length === 0) {
      generateDailyTasks(baby_id, targetDate);
      tasks = getDailyTasks(baby_id, targetDate);
    }
    const weekdayNames = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    const dayOfWeek = weekdayNames[new Date(targetDate).getDay()];
    const totalDuration = tasks.reduce((s, t) => s + (t.duration_min || 0), 0);
    const streak = query(
      "SELECT streak_days FROM checkin_records WHERE baby_id = ? AND checkin_date = date('now','localtime')",
      [baby_id]
    ).rows[0];
    const completed = query(
      "SELECT COUNT(*) as cnt FROM baby_daily_tasks WHERE baby_id = ? AND assign_date = ? AND is_completed = 1",
      [baby_id, targetDate]
    ).rows[0];
    return res.json(success({
      date: targetDate, weekday: dayOfWeek, streak_days: streak?.streak_days || 0,
      completed_count: completed?.cnt || 0, total_duration_min: totalDuration,
      tasks: tasks.map(t => ({
        id: t.id, template_id: t.task_template_id, area: t.area, title: t.title,
        description: t.description, purpose: t.purpose, difficulty: t.difficulty,
        duration_min: t.duration_min, materials_needed: t.materials_needed,
        video_url: t.video_url, icon_url: t.icon_url, tips: t.tips,
        is_completed: !!t.is_completed, completed_at: t.completed_at, user_rating: t.user_rating,
      })),
    }));
  } catch (err) {
    console.error('[tasks/daily]', err.message);
    return res.status(500).json(fail('获取每日任务失败'));
  }
});

router.post('/generate', authRequired, async (req, res) => {
  try {
    const { baby_id } = req.body;
    if (!baby_id) return res.status(400).json(fail('缺少 baby_id'));
    let generated = 0;
    for (let i = 0; i < 7; i++) {
      const d = new Date();
      d.setDate(d.getDate() + i);
      const ds = d.toISOString().split('T')[0];
      generated += generateDailyTasks(baby_id, ds).length;
    }
    return res.json(success({ generated }, '任务已生成'));
  } catch (err) {
    console.error('[tasks/generate]', err.message);
    return res.status(500).json(fail('生成任务失败'));
  }
});

router.put('/daily/:id/complete', authRequired, async (req, res) => {
  try {
    const result = query(
      "UPDATE baby_daily_tasks SET is_completed = 1, completed_at = datetime('now','localtime') WHERE id = ? RETURNING *",
      [req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json(fail('任务不存在'));
    return res.json(success(result.rows[0], '已完成'));
  } catch (err) {
    console.error('[tasks/complete]', err.message);
    return res.status(500).json(fail('操作失败'));
  }
});

router.put('/daily/:id/skip', authRequired, async (req, res) => {
  try {
    const result = query("UPDATE baby_daily_tasks SET is_completed = 0 WHERE id = ? RETURNING *", [req.params.id]);
    if (result.rows.length === 0) return res.status(404).json(fail('任务不存在'));
    return res.json(success(result.rows[0], '已跳过'));
  } catch (err) {
    console.error('[tasks/skip]', err.message);
    return res.status(500).json(fail('操作失败'));
  }
});

router.put('/:id/rating', authRequired, async (req, res) => {
  try {
    const { rating } = req.body;
    if (!rating || rating < 1 || rating > 5) return res.status(400).json(fail('评分范围为1-5'));
    const result = query('UPDATE baby_daily_tasks SET user_rating = ? WHERE id = ? RETURNING *', [rating, req.params.id]);
    if (result.rows.length === 0) return res.status(404).json(fail('任务不存在'));
    return res.json(success(result.rows[0], '评分成功'));
  } catch (err) {
    console.error('[tasks/rating]', err.message);
    return res.status(500).json(fail('评分失败'));
  }
});

export default router;
