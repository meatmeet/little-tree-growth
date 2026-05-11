import { Router } from 'express';
import { query, queryOne } from '../config/db.js';
import { authRequired } from '../middleware/auth.js';
import { success, fail } from '../utils/response.js';

const router = Router();

router.post('/', authRequired, async (req, res) => {
  try {
    const { baby_id, record_date, height_cm, weight_kg, head_circ_cm, notes } = req.body;
    if (!baby_id) return res.status(400).json(fail('缺少 baby_id'));
    const result = query(
      `INSERT INTO growth_records (baby_id, record_date, height_cm, weight_kg, head_circ_cm, notes) VALUES (?,?,?,?,?,?)
       ON CONFLICT (baby_id, record_date) DO UPDATE SET height_cm=COALESCE(?,height_cm), weight_kg=COALESCE(?,weight_kg), head_circ_cm=COALESCE(?,head_circ_cm), notes=COALESCE(?,notes)
       RETURNING *`,
      [baby_id, record_date, height_cm || null, weight_kg || null, head_circ_cm || null, notes || null,
       height_cm || null, weight_kg || null, head_circ_cm || null, notes || null]
    );
    return res.json(success(result.rows[0], '记录成功'));
  } catch (err) {
    console.error('[growth/create]', err.message);
    return res.status(500).json(fail('记录失败'));
  }
});

router.get('/', authRequired, async (req, res) => {
  try {
    const { baby_id, limit = '20' } = req.query;
    if (!baby_id) return res.status(400).json(fail('缺少 baby_id'));
    const rows = query('SELECT * FROM growth_records WHERE baby_id = ? ORDER BY record_date DESC LIMIT ?', [baby_id, parseInt(limit)]).rows;
    return res.json(success(rows));
  } catch (err) {
    console.error('[growth/list]', err.message);
    return res.status(500).json(fail('获取记录失败'));
  }
});

router.put('/:id', authRequired, async (req, res) => {
  try {
    const { height_cm, weight_kg, head_circ_cm, notes } = req.body;
    const result = query(
      `UPDATE growth_records SET height_cm=COALESCE(?,height_cm), weight_kg=COALESCE(?,weight_kg), head_circ_cm=COALESCE(?,head_circ_cm), notes=COALESCE(?,notes) WHERE id=? RETURNING *`,
      [height_cm, weight_kg, head_circ_cm, notes, req.params.id]
    );
    if (result.rows.length === 0) return res.status(404).json(fail('记录不存在'));
    return res.json(success(result.rows[0], '更新成功'));
  } catch (err) {
    console.error('[growth/update]', err.message);
    return res.status(500).json(fail('更新失败'));
  }
});

router.delete('/:id', authRequired, async (req, res) => {
  try {
    const result = query('DELETE FROM growth_records WHERE id = ? RETURNING id', [req.params.id]);
    if (result.rows.length === 0) return res.status(404).json(fail('记录不存在'));
    return res.json(success(null, '删除成功'));
  } catch (err) {
    console.error('[growth/delete]', err.message);
    return res.status(500).json(fail('删除失败'));
  }
});

router.get('/curve', authRequired, async (req, res) => {
  try {
    const { baby_id, type } = req.query;
    if (!baby_id || !type) return res.status(400).json(fail('缺少参数'));

    const baby = queryOne('SELECT gender, birth_date FROM babies WHERE id = ?', [baby_id]);
    if (!baby) return res.status(404).json(fail('宝宝不存在'));

    const colMap = { height: 'height_cm', weight: 'weight_kg', head: 'head_circ_cm' };
    const col = colMap[type];
    if (!col) return res.status(400).json(fail('无效的测量类型'));

    const records = query(`SELECT record_date, ${col} as val FROM growth_records WHERE baby_id = ? AND ${col} IS NOT NULL ORDER BY record_date ASC`, [baby_id]).rows;
    const recordsOut = records.map(r => ({
      date: r.record_date,
      age_months: calcMonths(baby.birth_date, r.record_date),
      value: r.val,
    }));

    const prefix = type === 'height' ? 'height' : type === 'weight' ? 'weight' : 'head';
    const standards = query(`SELECT age_months, ${prefix}_p3 as p3, ${prefix}_p50 as p50, ${prefix}_p97 as p97 FROM growth_standards WHERE gender = ? ORDER BY age_months`, [baby.gender]).rows;

    return res.json(success({ records: recordsOut, standards }));
  } catch (err) {
    console.error('[growth/curve]', err.message);
    return res.status(500).json(fail('获取生长曲线失败'));
  }
});

function calcMonths(birthDate, targetDate) {
  const b = new Date(birthDate);
  const t = new Date(targetDate);
  const m = (t.getFullYear() - b.getFullYear()) * 12 + (t.getMonth() - b.getMonth());
  return t.getDate() < b.getDate() ? m - 1 : m;
}

export default router;
