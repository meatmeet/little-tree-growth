import { Router } from 'express';
import { query, queryOne } from '../config/db.js';
import { authRequired } from '../middleware/auth.js';
import { validate } from '../middleware/validate.js';
import { success, fail } from '../utils/response.js';

const router = Router();

router.post('/', authRequired, validate({
  name: { required: true }, gender: { required: true, type: 'number', enum: [0, 1] }, birth_date: { required: true },
}), async (req, res) => {
  try {
    const { name, gender, birth_date, is_premature, avatar_url } = req.body;
    const count = queryOne('SELECT COUNT(*) as cnt FROM babies WHERE user_id = ?', [req.user.id]);
    if (count.cnt >= 5) return res.status(400).json(fail('最多添加5个宝宝'));

    const result = query(
      `INSERT INTO babies (user_id, name, gender, birth_date, is_premature, avatar_url) VALUES (?,?,?,?,?,?) RETURNING *`,
      [req.user.id, name, gender, birth_date, is_premature ? 1 : 0, avatar_url || null]
    );
    return res.json(success(result.rows[0], '添加成功'));
  } catch (err) {
    console.error('[babies/create]', err.message);
    return res.status(500).json(fail('添加宝宝失败'));
  }
});

router.get('/', authRequired, async (req, res) => {
  try {
    const result = query('SELECT * FROM babies WHERE user_id = ? ORDER BY created_at DESC', [req.user.id]);
    return res.json(success(result.rows));
  } catch (err) {
    console.error('[babies/list]', err.message);
    return res.status(500).json(fail('获取宝宝列表失败'));
  }
});

router.get('/:id', authRequired, async (req, res) => {
  try {
    const baby = queryOne('SELECT * FROM babies WHERE id = ? AND user_id = ?', [req.params.id, req.user.id]);
    if (!baby) return res.status(404).json(fail('宝宝不存在'));
    return res.json(success(baby));
  } catch (err) {
    console.error('[babies/detail]', err.message);
    return res.status(500).json(fail('获取宝宝信息失败'));
  }
});

router.put('/:id', authRequired, async (req, res) => {
  try {
    const { name, gender, birth_date, is_premature, avatar_url } = req.body;
    const result = query(
      `UPDATE babies SET name=COALESCE(?,name), gender=COALESCE(?,gender), birth_date=COALESCE(?,birth_date), is_premature=COALESCE(?,is_premature), avatar_url=COALESCE(?,avatar_url) WHERE id=? AND user_id=? RETURNING *`,
      [name, gender, birth_date, is_premature, avatar_url, req.params.id, req.user.id]
    );
    if (result.rows.length === 0) return res.status(404).json(fail('宝宝不存在'));
    return res.json(success(result.rows[0], '更新成功'));
  } catch (err) {
    console.error('[babies/update]', err.message);
    return res.status(500).json(fail('更新失败'));
  }
});

router.delete('/:id', authRequired, async (req, res) => {
  try {
    const result = query('DELETE FROM babies WHERE id=? AND user_id=? RETURNING id', [req.params.id, req.user.id]);
    if (result.rows.length === 0) return res.status(404).json(fail('宝宝不存在'));
    return res.json(success(null, '删除成功'));
  } catch (err) {
    console.error('[babies/delete]', err.message);
    return res.status(500).json(fail('删除失败'));
  }
});

export default router;
