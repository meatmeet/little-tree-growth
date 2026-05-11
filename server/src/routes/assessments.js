import { Router } from 'express';
import { query, queryOne } from '../config/db.js';
import { authRequired } from '../middleware/auth.js';
import { success, fail } from '../utils/response.js';
import { getAssessmentItems, calculateResults, generateReport } from '../services/assessment.js';

const router = Router();

// POST /assessments - 创建新评测
router.post('/', authRequired, async (req, res) => {
  try {
    const { baby_id, actual_age_months } = req.body;
    const baby = queryOne('SELECT id FROM babies WHERE id = ? AND user_id = ?', [baby_id, req.user.id]);
    if (!baby) return res.status(404).json(fail('宝宝不存在'));

    const today = new Date().toISOString().split('T')[0];
    const result = query(
      `INSERT INTO assessments (baby_id, assessment_date, actual_age_months, status) VALUES (?,?,?,'draft') RETURNING *`,
      [baby_id, today, actual_age_months]
    );
    return res.json(success(result.rows[0], '评测已创建'));
  } catch (err) {
    console.error('[assessments/create]', err.message);
    return res.status(500).json(fail('创建评测失败'));
  }
});

// GET /assessments - 评测历史列表
router.get('/', authRequired, async (req, res) => {
  try {
    const { baby_id } = req.query;
    if (!baby_id) return res.status(400).json(fail('缺少 baby_id'));

    const assessments = query(
      'SELECT * FROM assessments WHERE baby_id = ? ORDER BY assessment_date DESC',
      [baby_id]
    ).rows;

    // Load areas for each assessment (replaces json_agg)
    for (const a of assessments) {
      a.areas = query('SELECT * FROM assessment_results WHERE assessment_id = ?', [a.id]).rows;
    }
    return res.json(success(assessments));
  } catch (err) {
    console.error('[assessments/list]', err.message);
    return res.status(500).json(fail('获取评测列表失败'));
  }
});

// GET /assessments/items - 获取某月龄的评测题目
router.get('/items', authRequired, async (req, res) => {
  try {
    const { age_group, area } = req.query;
    if (!age_group) return res.status(400).json(fail('缺少 age_group'));
    const items = await getAssessmentItems(parseInt(age_group), area || null);
    return res.json(success(items));
  } catch (err) {
    console.error('[assessments/items]', err.message);
    return res.status(500).json(fail('获取评测题目失败'));
  }
});

// POST /assessments/:id/items - 提交评测答案
router.post('/:id/items', authRequired, async (req, res) => {
  try {
    const { id } = req.params;
    const { results } = req.body;
    if (!results || !Array.isArray(results) || results.length === 0) {
      return res.status(400).json(fail('请提供评测答案'));
    }

    const assessment = queryOne(
      `SELECT a.* FROM assessments a JOIN babies b ON b.id = a.baby_id WHERE a.id = ? AND b.user_id = ?`,
      [id, req.user.id]
    );
    if (!assessment) return res.status(404).json(fail('评测不存在'));

    for (const r of results) {
      query(
        `INSERT INTO assessment_item_results (assessment_id, area, item_code, age_group, passed) VALUES (?,?,?,?,?)`,
        [id, r.area, r.item_code, r.age_group || Math.round(assessment.actual_age_months), r.passed ? 1 : 0]
      );
    }

    const calcResult = calculateResults(parseInt(id), assessment.baby_id, parseFloat(assessment.actual_age_months));
    return res.json(success(calcResult, '评测完成'));
  } catch (err) {
    console.error('[assessments/submit]', err.message);
    return res.status(500).json(fail('提交评测失败'));
  }
});

// GET /assessments/:id - 评测详情
router.get('/:id', authRequired, async (req, res) => {
  try {
    const assessment = queryOne('SELECT * FROM assessments WHERE id = ?', [req.params.id]);
    if (!assessment) return res.status(404).json(fail('评测不存在'));

    assessment.areas = query('SELECT * FROM assessment_results WHERE assessment_id = ?', [req.params.id]).rows;

    const report = await generateReport(null, parseInt(req.params.id));
    return res.json(success({ ...assessment, ...report }));
  } catch (err) {
    console.error('[assessments/detail]', err.message);
    return res.status(500).json(fail('获取评测详情失败'));
  }
});

// GET /assessments/:id/report - 完整评测报告
router.get('/:id/report', authRequired, async (req, res) => {
  try {
    const assessment = queryOne('SELECT * FROM assessments WHERE id = ?', [req.params.id]);
    if (!assessment) return res.status(404).json(fail('评测不存在'));

    const areas = query('SELECT * FROM assessment_results WHERE assessment_id = ?', [req.params.id]).rows;
    const report = await generateReport(null, parseInt(req.params.id));

    const dq = assessment.overall_dq;
    const dqLevel = dq >= 130 ? '优秀' : dq >= 110 ? '良好' : dq >= 80 ? '中等' : dq >= 70 ? '临界偏低' : '需就医';

    return res.json(success({
      assessment_date: assessment.assessment_date,
      actual_age_months: assessment.actual_age_months,
      overall_dq: assessment.overall_dq,
      overall_mental_age: assessment.overall_mental_age,
      dq_level: dqLevel,
      areas: areas.map(a => ({
        area: a.area, mental_age: a.mental_age, dq_score: a.dq_score,
        items_passed: a.items_passed, items_total: a.items_total,
      })),
      highlights: report?.highlights || [],
      suggestions: report?.suggestions || [],
    }));
  } catch (err) {
    console.error('[assessments/report]', err.message);
    return res.status(500).json(fail('获取评测报告失败'));
  }
});

// GET /assessments/:id/radar
router.get('/:id/radar', authRequired, async (req, res) => {
  try {
    const rows = query('SELECT area, dq_score FROM assessment_results WHERE assessment_id = ?', [req.params.id]).rows;
    return res.json(success({ labels: rows.map(r => r.area), values: rows.map(r => r.dq_score || 0) }));
  } catch (err) {
    console.error('[assessments/radar]', err.message);
    return res.status(500).json(fail('获取雷达图数据失败'));
  }
});

// GET /assessments/trend - 发育趋势
router.get('/trend', authRequired, async (req, res) => {
  try {
    const { baby_id } = req.query;
    if (!baby_id) return res.status(400).json(fail('缺少 baby_id'));

    const rows = query(
      `SELECT id, assessment_date, actual_age_months, overall_dq, overall_mental_age FROM assessments WHERE baby_id = ? AND status = 'completed' ORDER BY assessment_date ASC`,
      [baby_id]
    ).rows;
    return res.json(success(rows));
  } catch (err) {
    console.error('[assessments/trend]', err.message);
    return res.status(500).json(fail('获取发展趋势失败'));
  }
});

export default router;
