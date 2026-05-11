import { query, queryOne } from '../config/db.js';

export function generateDailyTasks(babyId, date) {
  const baby = queryOne('SELECT id, birth_date FROM babies WHERE id = ?', [babyId]);
  if (!baby) return [];
  const ageMonths = calcMonths(baby.birth_date, date);
  const ageGroup = findAgeGroup(ageMonths);
  const dayOfWeek = new Date(date).getDay() || 7;

  // Try weekly plan first
  const planRows = query(
    `SELECT wpt.task_template_id FROM weekly_plan_tasks wpt
     JOIN weekly_plans wp ON wp.id = wpt.weekly_plan_id
     WHERE wp.age_group = ? AND wpt.day_of_week = ? ORDER BY wpt.sort_order LIMIT 4`,
    [ageGroup, dayOfWeek]
  ).rows;

  let tasks = [];
  if (planRows.length > 0) {
    for (const p of planRows) {
      const t = queryOne('SELECT * FROM task_templates WHERE id = ?', [p.task_template_id]);
      if (t) tasks.push(t);
    }
  }

  // Fallback: random by area
  if (tasks.length === 0) {
    const areas = ['gross_motor', 'fine_motor', 'language', 'adaptation', 'social'];
    for (const area of areas) {
      const t = queryOne(
        'SELECT * FROM task_templates WHERE area = ? AND age_group_min <= ? AND age_group_max >= ? AND is_active = 1 ORDER BY RANDOM() LIMIT 1',
        [area, ageMonths, ageMonths]
      );
      if (t) tasks.push(t);
    }
  }

  const assigned = [];
  for (let i = 0; i < Math.min(tasks.length, 4); i++) {
    const task = tasks[i];
    try {
      query(
        `INSERT OR IGNORE INTO baby_daily_tasks (baby_id, task_template_id, assign_date, scheduled_time, sort_order) VALUES (?,?,?,'08:00',?)`,
        [babyId, task.id, date, i]
      );
      assigned.push(task);
    } catch { /* skip duplicate */ }
  }
  return assigned;
}

export function getDailyTasks(babyId, date) {
  return query(
    `SELECT bdt.*, tt.title, tt.description, tt.area, tt.difficulty, tt.duration_min,
            tt.materials_needed, tt.video_url, tt.icon_url, tt.purpose, tt.tips
     FROM baby_daily_tasks bdt
     JOIN task_templates tt ON tt.id = bdt.task_template_id
     WHERE bdt.baby_id = ? AND bdt.assign_date = ?
     ORDER BY bdt.sort_order, bdt.id`,
    [babyId, date]
  ).rows;
}

function calcMonths(birthDate, refDate) {
  const b = new Date(birthDate);
  const r = new Date(refDate);
  const m = (r.getFullYear() - b.getFullYear()) * 12 + (r.getMonth() - b.getMonth());
  return r.getDate() < b.getDate() ? m - 1 : m;
}

function findAgeGroup(months) {
  const groups = [1,2,3,4,5,6,7,8,9,10,11,12,15,18,21,24,27,30,33,36,42,48,54,60,66,72,78,84];
  let best = groups[0];
  for (const g of groups) { if (g <= Math.round(months)) best = g; }
  return best;
}
