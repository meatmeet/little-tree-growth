import { Router } from 'express';
import { query } from '../config/db.js';
import { authRequired } from '../middleware/auth.js';
import { success, fail } from '../utils/response.js';

const router = Router();

router.post('/', authRequired, async (req, res) => {
  try {
    const { baby_id, milestone_type, occurred_at, notes, photo_url } = req.body;
    if (!baby_id || !milestone_type) return res.status(400).json(fail('缺少必填参数'));
    const result = query(
      `INSERT INTO milestones (baby_id, milestone_type, occurred_at, notes, photo_url) VALUES (?,?,?,?,?) RETURNING *`,
      [baby_id, milestone_type, occurred_at || null, notes || null, photo_url || null]
    );
    return res.json(success(result.rows[0], '记录成功'));
  } catch (err) {
    console.error('[milestones/create]', err.message);
    return res.status(500).json(fail('添加里程碑失败'));
  }
});

router.get('/', authRequired, async (req, res) => {
  try {
    const { baby_id } = req.query;
    if (!baby_id) return res.status(400).json(fail('缺少 baby_id'));
    const rows = query("SELECT * FROM milestones WHERE baby_id = ? ORDER BY occurred_at IS NULL, occurred_at DESC, created_at DESC", [baby_id]).rows;
    return res.json(success(rows));
  } catch (err) {
    console.error('[milestones/list]', err.message);
    return res.status(500).json(fail('获取里程碑失败'));
  }
});

router.delete('/:id', authRequired, async (req, res) => {
  try {
    const result = query('DELETE FROM milestones WHERE id = ? RETURNING id', [req.params.id]);
    if (result.rows.length === 0) return res.status(404).json(fail('记录不存在'));
    return res.json(success(null, '删除成功'));
  } catch (err) {
    console.error('[milestones/delete]', err.message);
    return res.status(500).json(fail('删除失败'));
  }
});

export default router;
