import { Router } from 'express';
import { query, queryOne } from '../config/db.js';
import { authRequired, authOptional } from '../middleware/auth.js';
import { success, fail } from '../utils/response.js';

const router = Router();

router.get('/', authOptional, async (req, res) => {
  try {
    const { age_group, page = '1', limit = '20' } = req.query;
    const offset = (parseInt(page) - 1) * parseInt(limit);
    let sql = 'SELECT * FROM courses WHERE is_published = 1';
    const params = [];
    if (age_group) {
      sql += ' AND age_group_min <= ? AND age_group_max >= ?';
      params.push(parseInt(age_group), parseInt(age_group));
    }
    sql += ' ORDER BY sort_order, created_at DESC LIMIT ? OFFSET ?';
    params.push(parseInt(limit), offset);
    return res.json(success(query(sql, params).rows));
  } catch (err) {
    console.error('[courses/list]', err.message);
    return res.status(500).json(fail('获取课程列表失败'));
  }
});

router.get('/:id', authOptional, async (req, res) => {
  try {
    const course = queryOne('SELECT * FROM courses WHERE id = ?', [req.params.id]);
    if (!course) return res.status(404).json(fail('课程不存在'));

    course.lessons = query('SELECT * FROM course_lessons WHERE course_id = ? ORDER BY sort_order', [req.params.id]).rows;
    course.progress = 0;
    if (req.user) {
      const uc = queryOne('SELECT progress FROM user_courses WHERE user_id = ? AND course_id = ?', [req.user.id, req.params.id]);
      if (uc) course.progress = uc.progress;
    }
    return res.json(success(course));
  } catch (err) {
    console.error('[courses/detail]', err.message);
    return res.status(500).json(fail('获取课程详情失败'));
  }
});

router.get('/:id/lessons', authOptional, async (req, res) => {
  try {
    const rows = query('SELECT * FROM course_lessons WHERE course_id = ? ORDER BY sort_order', [req.params.id]).rows;
    return res.json(success(rows));
  } catch (err) {
    console.error('[courses/lessons]', err.message);
    return res.status(500).json(fail('获取章节列表失败'));
  }
});

router.post('/:id/purchase', authRequired, async (req, res) => {
  try {
    const course = queryOne('SELECT * FROM courses WHERE id = ? AND is_published = 1', [req.params.id]);
    if (!course) return res.status(404).json(fail('课程不存在'));

    if (course.course_type === 'free') {
      query('INSERT OR IGNORE INTO user_courses (user_id, course_id) VALUES (?,?)', [req.user.id, req.params.id]);
      return res.json(success(null, '已加入学习'));
    }
    const existing = queryOne('SELECT id FROM user_courses WHERE user_id = ? AND course_id = ?', [req.user.id, req.params.id]);
    if (existing) return res.json(success(null, '已购买'));
    query('INSERT INTO user_courses (user_id, course_id) VALUES (?,?)', [req.user.id, req.params.id]);
    return res.json(success(null, '购买成功'));
  } catch (err) {
    console.error('[courses/purchase]', err.message);
    return res.status(500).json(fail('购买失败'));
  }
});

router.get('/:id/progress', authRequired, async (req, res) => {
  try {
    const uc = queryOne('SELECT progress FROM user_courses WHERE user_id = ? AND course_id = ?', [req.user.id, req.params.id]);
    return res.json(success({ progress: uc?.progress || 0 }));
  } catch (err) {
    console.error('[courses/progress]', err.message);
    return res.status(500).json(fail('获取进度失败'));
  }
});

router.put('/:id/progress', authRequired, async (req, res) => {
  try {
    const { progress } = req.body;
    if (progress === undefined) return res.status(400).json(fail('缺少 progress'));
    query('INSERT INTO user_courses (user_id, course_id, progress) VALUES (?,?,?) ON CONFLICT (user_id, course_id) DO UPDATE SET progress = ?', [req.user.id, req.params.id, progress, progress]);
    return res.json(success({ progress }, '进度已更新'));
  } catch (err) {
    console.error('[courses/progress/update]', err.message);
    return res.status(500).json(fail('更新进度失败'));
  }
});

export default router;
