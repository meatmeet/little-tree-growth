import { Router } from 'express';
import { query, queryOne } from '../config/db.js';
import { authRequired } from '../middleware/auth.js';
import { success, fail } from '../utils/response.js';

const router = Router();

router.get('/summary', authRequired, async (req, res) => {
  try {
    const { baby_id } = req.query;
    if (!baby_id) return res.status(400).json(fail('缺少 baby_id'));

    const latestGrowth = queryOne('SELECT * FROM growth_records WHERE baby_id = ? ORDER BY record_date DESC LIMIT 1', [baby_id]);
    const latestAssess = queryOne("SELECT overall_dq FROM assessments WHERE baby_id = ? AND status = 'completed' ORDER BY assessment_date DESC LIMIT 1", [baby_id]);
    const latestCheckin = queryOne('SELECT streak_days FROM checkin_records WHERE baby_id = ? ORDER BY checkin_date DESC LIMIT 1', [baby_id]);
    const milestoneCount = queryOne('SELECT COUNT(*) as cnt FROM milestones WHERE baby_id = ?', [baby_id]);

    const today = new Date().toISOString().split('T')[0];
    const taskStats = queryOne('SELECT COUNT(*) as total, SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) as done FROM baby_daily_tasks WHERE baby_id = ? AND assign_date = ?', [baby_id, today]);

    return res.json(success({
      latest_growth: latestGrowth || null,
      latest_dq: latestAssess?.overall_dq || null,
      streak_days: latestCheckin?.streak_days || 0,
      milestone_count: milestoneCount?.cnt || 0,
      today_tasks: { total: taskStats?.total || 0, completed: taskStats?.done || 0 },
    }));
  } catch (err) {
    console.error('[stats/summary]', err.message);
    return res.status(500).json(fail('获取摘要失败'));
  }
});

router.get('/weekly', authRequired, async (req, res) => {
  try {
    const { baby_id } = req.query;
    if (!baby_id) return res.status(400).json(fail('缺少 baby_id'));

    const now = new Date();
    const weekStart = new Date(now);
    weekStart.setDate(now.getDate() - now.getDay() + 1);
    const weekEnd = new Date(weekStart);
    weekEnd.setDate(weekStart.getDate() + 6);
    const fmt = (d) => d.toISOString().split('T')[0];
    const ws = fmt(weekStart), we = fmt(weekEnd);

    const checkinDays = queryOne('SELECT COUNT(*) as cnt FROM checkin_records WHERE baby_id = ? AND checkin_date >= ? AND checkin_date <= ?', [baby_id, ws, we]);
    const latestCheckin = queryOne('SELECT streak_days FROM checkin_records WHERE baby_id = ? ORDER BY checkin_date DESC LIMIT 1', [baby_id]);
    const tasksDone = queryOne('SELECT COUNT(*) as done FROM baby_daily_tasks WHERE baby_id = ? AND assign_date >= ? AND assign_date <= ? AND is_completed = 1', [baby_id, ws, we]);
    const newMilestones = queryOne('SELECT COUNT(*) as cnt FROM milestones WHERE baby_id = ? AND created_at >= ?', [baby_id, ws]);

    const growthRows = query('SELECT height_cm, weight_kg FROM growth_records WHERE baby_id = ? ORDER BY record_date DESC LIMIT 2', [baby_id]).rows;
    let heightGain = null, weightGain = null;
    if (growthRows.length >= 2) {
      if (growthRows[0].height_cm && growthRows[1].height_cm) heightGain = parseFloat((growthRows[0].height_cm - growthRows[1].height_cm).toFixed(1));
      if (growthRows[0].weight_kg && growthRows[1].weight_kg) weightGain = parseFloat((growthRows[0].weight_kg - growthRows[1].weight_kg).toFixed(2));
    }

    const areaRows = query(`SELECT ar.* FROM assessment_results ar JOIN assessments a ON a.id = ar.assessment_id WHERE a.baby_id = ? AND a.status = 'completed' ORDER BY a.assessment_date DESC LIMIT 5`, [baby_id]).rows;
    let spotlightArea = null, weaknessArea = null;
    if (areaRows.length > 0) {
      const sorted = [...areaRows].sort((a, b) => b.dq_score - a.dq_score);
      const names = { gross_motor: '大运动', fine_motor: '精细动作', language: '语言', adaptation: '认知', social: '社交' };
      spotlightArea = names[sorted[0].area] || sorted[0].area;
      weaknessArea = names[sorted[sorted.length - 1].area] || sorted[sorted.length - 1].area;
    }

    return res.json(success({
      week_start: ws, week_end: we,
      checkin_days: checkinDays?.cnt || 0,
      streak_days: latestCheckin?.streak_days || 0,
      tasks_completed: tasksDone?.done || 0,
      new_milestones: newMilestones?.cnt || 0,
      growth: { weight_gain: weightGain, height_gain: heightGain },
      spotlight_area: spotlightArea,
      weakness_area: weaknessArea,
    }));
  } catch (err) {
    console.error('[stats/weekly]', err.message);
    return res.status(500).json(fail('获取周报失败'));
  }
});

export default router;
