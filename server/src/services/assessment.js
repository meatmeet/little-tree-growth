import { query } from '../config/db.js';

function findAgeGroup(actualMonths) {
  const groups = [1,2,3,4,5,6,7,8,9,10,11,12,15,18,21,24,27,30,33,36,42,48,54,60,66,72,78,84];
  let best = groups[0];
  for (const g of groups) { if (g <= Math.round(actualMonths)) best = g; }
  return best;
}

export async function getAssessmentItems(ageGroup, area) {
  const sql = area
    ? 'SELECT * FROM dev_standards WHERE age_group = ? AND area = ? ORDER BY sort_order'
    : 'SELECT * FROM dev_standards WHERE age_group = ? ORDER BY area, sort_order';
  const result = query(sql, area ? [ageGroup, area] : [ageGroup]);
  return result.rows;
}

export function calculateResults(assessmentId, babyId, actualAgeMonths) {
  const ageGroup = findAgeGroup(actualAgeMonths);
  const areas = ['gross_motor', 'fine_motor', 'language', 'adaptation', 'social'];

  const passedRows = query(
    `SELECT area, SUM(CASE WHEN passed = 1 THEN 1 ELSE 0 END) as passed, COUNT(*) as total
     FROM assessment_item_results WHERE assessment_id = ? GROUP BY area`,
    [assessmentId]
  ).rows;
  const passedMap = {};
  for (const r of passedRows) {
    passedMap[r.area] = { passed: r.passed, total: r.total };
  }

  const allStandards = query(
    'SELECT * FROM dev_standards WHERE age_group <= ? ORDER BY area, age_group, sort_order',
    [ageGroup]
  ).rows;

  const areaResults = [];
  for (const area of areas) {
    const areaItems = allStandards.filter(r => r.area === area);
    const passedCount = passedMap[area]?.passed || 0;
    const totalCount = areaItems.length;
    const baseAge = ageGroup <= 12 ? ageGroup : Math.max(1, ageGroup - getAgeSpan(ageGroup));
    const mentalAge = totalCount > 0 ? baseAge + (passedCount / totalCount) * getAgeSpan(ageGroup) : baseAge;
    const dqScore = actualAgeMonths > 0 ? Math.round((mentalAge / actualAgeMonths) * 100 * 10) / 10 : 0;
    areaResults.push({ area, mental_age: Math.round(mentalAge * 10) / 10, dq_score: dqScore, items_passed: passedCount, items_total: totalCount });
  }

  const overallDq = Math.round(areaResults.reduce((s, r) => s + r.dq_score, 0) / areas.length * 10) / 10;
  const overallMentalAge = Math.round(areaResults.reduce((s, r) => s + r.mental_age, 0) / areas.length * 10) / 10;

  for (const r of areaResults) {
    query(
      `INSERT INTO assessment_results (assessment_id, area, mental_age, dq_score, items_passed, items_total) VALUES (?,?,?,?,?,?)
       ON CONFLICT (assessment_id, area) DO UPDATE SET mental_age=?, dq_score=?, items_passed=?, items_total=?`,
      [assessmentId, r.area, r.mental_age, r.dq_score, r.items_passed, r.items_total,
       r.mental_age, r.dq_score, r.items_passed, r.items_total]
    );
  }

  query("UPDATE assessments SET overall_dq = ?, overall_mental_age = ?, status = 'completed' WHERE id = ?", [overallDq, overallMentalAge, assessmentId]);

  return { overall_dq: overallDq, overall_mental_age: overallMentalAge, areas: areaResults };
}

function getAgeSpan(ageGroup) {
  if (ageGroup <= 12) return 1;
  if (ageGroup <= 36) return 3;
  return 6;
}

export async function generateReport(babyId, assessmentId) {
  const rows = query(
    `SELECT a.*, ar.area, ar.dq_score, ar.mental_age FROM assessments a JOIN assessment_results ar ON ar.assessment_id = a.id WHERE a.id = ?`,
    [assessmentId]
  ).rows;
  if (rows.length === 0) return null;

  const areas = [];
  const areaMap = {};
  for (const row of rows) {
    const item = { area: row.area, dq_score: row.dq_score, mental_age: row.mental_age };
    areas.push(item);
    areaMap[row.area] = item;
  }

  const sorted = [...areas].sort((a, b) => b.dq_score - a.dq_score);
  const best = sorted[0];
  const worst = sorted[sorted.length - 1];
  const names = { gross_motor: '大运动', fine_motor: '精细动作', language: '语言', adaptation: '认知', social: '社交' };

  const highlights = [];
  const suggestions = [];
  if (best && best.dq_score >= 100) highlights.push(`${names[best.area] || best.area}发展超出同龄水平`);
  if (worst && worst.dq_score < 90) {
    highlights.push(`${names[worst.area] || worst.area}需加强训练`);
    suggestions.push(`多关注${names[worst.area] || worst.area}方面的训练，增加相关游戏和互动`);
  }

  return { highlights, suggestions };
}
