import Database from 'better-sqlite3';
import fs from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __dirname = dirname(fileURLToPath(import.meta.url));
const DB_PATH = join(__dirname, '../../data/app.db');

let db;

export function getDb() {
  if (!db) {
    const dir = dirname(DB_PATH);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    db = new Database(DB_PATH);
    db.pragma('journal_mode = WAL');
    db.pragma('foreign_keys = ON');
    initSchema();
    seedIfEmpty();
  }
  return db;
}

export function query(sql, params = []) {
  const d = getDb();
  const stmt = d.prepare(sql);
  const trimmed = sql.trim().toUpperCase();
  if (trimmed.startsWith('SELECT') || trimmed.startsWith('WITH') || trimmed.startsWith('RETURNING')) {
    const rows = stmt.all(...params);
    return { rows };
  }
  const info = stmt.run(...params);
  return { rows: [{ id: info.lastInsertRowid }], changes: info.changes };
}

export function queryOne(sql, params = []) {
  const result = query(sql, params);
  return result.rows[0] || null;
}

// ========== SCHEMA ==========
function initSchema() {
  db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      phone TEXT UNIQUE NOT NULL,
      email TEXT UNIQUE,
      password_hash TEXT NOT NULL,
      nickname TEXT,
      avatar_url TEXT,
      is_vip INTEGER DEFAULT 0,
      vip_expire_at TEXT,
      created_at TEXT DEFAULT (datetime('now','localtime')),
      updated_at TEXT DEFAULT (datetime('now','localtime'))
    );
    CREATE TABLE IF NOT EXISTS babies (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL REFERENCES users(id),
      name TEXT NOT NULL,
      gender INTEGER NOT NULL CHECK (gender IN (0, 1)),
      birth_date TEXT NOT NULL,
      is_premature INTEGER DEFAULT 0,
      avatar_url TEXT,
      created_at TEXT DEFAULT (datetime('now','localtime')),
      updated_at TEXT DEFAULT (datetime('now','localtime'))
    );
    CREATE TABLE IF NOT EXISTS assessments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      baby_id INTEGER NOT NULL REFERENCES babies(id),
      assessment_date TEXT NOT NULL,
      actual_age_months REAL NOT NULL,
      overall_dq REAL,
      overall_mental_age REAL,
      status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'completed')),
      created_at TEXT DEFAULT (datetime('now','localtime'))
    );
    CREATE TABLE IF NOT EXISTS assessment_results (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      assessment_id INTEGER NOT NULL REFERENCES assessments(id),
      area TEXT NOT NULL CHECK (area IN ('gross_motor','fine_motor','language','adaptation','social')),
      mental_age REAL, dq_score REAL,
      items_passed INTEGER DEFAULT 0, items_total INTEGER DEFAULT 0,
      UNIQUE(assessment_id, area)
    );
    CREATE TABLE IF NOT EXISTS assessment_item_results (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      assessment_id INTEGER NOT NULL REFERENCES assessments(id),
      area TEXT NOT NULL, item_code TEXT NOT NULL,
      age_group INTEGER NOT NULL, passed INTEGER NOT NULL,
      created_at TEXT DEFAULT (datetime('now','localtime'))
    );
    CREATE TABLE IF NOT EXISTS dev_standards (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      age_group INTEGER NOT NULL, area TEXT NOT NULL,
      item_code TEXT NOT NULL UNIQUE, item_name TEXT NOT NULL,
      pass_criteria TEXT, sort_order INTEGER DEFAULT 0
    );
    CREATE TABLE IF NOT EXISTS task_templates (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      area TEXT NOT NULL, title TEXT NOT NULL, description TEXT, purpose TEXT,
      age_group_min INTEGER NOT NULL, age_group_max INTEGER NOT NULL,
      difficulty INTEGER DEFAULT 1 CHECK (difficulty IN (1,2,3)),
      duration_min INTEGER DEFAULT 15,
      materials_needed TEXT, video_url TEXT, icon_url TEXT, tips TEXT,
      is_active INTEGER DEFAULT 1, sort_order INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now','localtime'))
    );
    CREATE TABLE IF NOT EXISTS weekly_plans (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      age_group INTEGER NOT NULL, week_offset INTEGER NOT NULL,
      title TEXT, description TEXT,
      UNIQUE(age_group, week_offset)
    );
    CREATE TABLE IF NOT EXISTS weekly_plan_tasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      weekly_plan_id INTEGER NOT NULL REFERENCES weekly_plans(id),
      day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
      task_template_id INTEGER NOT NULL REFERENCES task_templates(id),
      sort_order INTEGER DEFAULT 0,
      UNIQUE(weekly_plan_id, day_of_week, task_template_id)
    );
    CREATE TABLE IF NOT EXISTS baby_daily_tasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      baby_id INTEGER NOT NULL REFERENCES babies(id),
      task_template_id INTEGER NOT NULL REFERENCES task_templates(id),
      assign_date TEXT NOT NULL, scheduled_time TEXT DEFAULT '08:00',
      sort_order INTEGER DEFAULT 0,
      is_completed INTEGER DEFAULT 0, completed_at TEXT,
      user_rating INTEGER CHECK (user_rating BETWEEN 1 AND 5), notes TEXT,
      UNIQUE(baby_id, task_template_id, assign_date)
    );
    CREATE TABLE IF NOT EXISTS growth_records (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      baby_id INTEGER NOT NULL REFERENCES babies(id),
      record_date TEXT NOT NULL,
      height_cm REAL, weight_kg REAL, head_circ_cm REAL, notes TEXT,
      created_at TEXT DEFAULT (datetime('now','localtime')),
      UNIQUE(baby_id, record_date)
    );
    CREATE TABLE IF NOT EXISTS growth_standards (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      gender INTEGER NOT NULL CHECK (gender IN (0, 1)),
      age_months INTEGER NOT NULL,
      height_p3 REAL, height_p10 REAL, height_p25 REAL, height_p50 REAL, height_p75 REAL, height_p90 REAL, height_p97 REAL,
      weight_p3 REAL, weight_p10 REAL, weight_p25 REAL, weight_p50 REAL, weight_p75 REAL, weight_p90 REAL, weight_p97 REAL,
      head_p3 REAL, head_p10 REAL, head_p25 REAL, head_p50 REAL, head_p75 REAL, head_p90 REAL, head_p97 REAL,
      UNIQUE(gender, age_months)
    );
    CREATE TABLE IF NOT EXISTS milestones (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      baby_id INTEGER NOT NULL REFERENCES babies(id),
      milestone_type TEXT NOT NULL, occurred_at TEXT, notes TEXT, photo_url TEXT,
      created_at TEXT DEFAULT (datetime('now','localtime'))
    );
    CREATE TABLE IF NOT EXISTS media_albums (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      baby_id INTEGER NOT NULL REFERENCES babies(id),
      media_type TEXT NOT NULL CHECK (media_type IN ('photo', 'video')),
      url TEXT NOT NULL, thumbnail_url TEXT, description TEXT, record_date TEXT,
      created_at TEXT DEFAULT (datetime('now','localtime'))
    );
    CREATE TABLE IF NOT EXISTS courses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL, description TEXT, cover_url TEXT, price REAL DEFAULT 0,
      course_type TEXT CHECK (course_type IN ('free', 'paid')),
      age_group_min INTEGER, age_group_max INTEGER, total_lessons INTEGER DEFAULT 0,
      sort_order INTEGER DEFAULT 0, is_published INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now','localtime')),
      updated_at TEXT DEFAULT (datetime('now','localtime'))
    );
    CREATE TABLE IF NOT EXISTS course_lessons (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      course_id INTEGER NOT NULL REFERENCES courses(id),
      title TEXT NOT NULL, description TEXT, video_url TEXT, duration_min INTEGER,
      is_free_preview INTEGER DEFAULT 0, sort_order INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now','localtime'))
    );
    CREATE TABLE IF NOT EXISTS user_courses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL REFERENCES users(id),
      course_id INTEGER NOT NULL REFERENCES courses(id),
      progress REAL DEFAULT 0,
      purchased_at TEXT DEFAULT (datetime('now','localtime')),
      UNIQUE(user_id, course_id)
    );
    CREATE TABLE IF NOT EXISTS subscriptions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL REFERENCES users(id),
      plan_type TEXT NOT NULL CHECK (plan_type IN ('monthly', 'yearly')),
      start_date TEXT NOT NULL, end_date TEXT NOT NULL,
      payment_amount REAL, payment_method TEXT,
      status TEXT DEFAULT 'active' CHECK (status IN ('active','expired','cancelled')),
      created_at TEXT DEFAULT (datetime('now','localtime'))
    );
    CREATE TABLE IF NOT EXISTS checkin_records (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      baby_id INTEGER NOT NULL REFERENCES babies(id),
      checkin_date TEXT NOT NULL,
      tasks_completed INTEGER DEFAULT 0, is_full_complete INTEGER DEFAULT 0, streak_days INTEGER DEFAULT 0,
      UNIQUE(baby_id, checkin_date)
    );
    CREATE TABLE IF NOT EXISTS system_configs (
      key TEXT PRIMARY KEY, value TEXT NOT NULL, description TEXT,
      updated_at TEXT DEFAULT (datetime('now','localtime'))
    );
  `);
}

// ========== SEED DATA ==========
function seedIfEmpty() {
  const count = db.prepare('SELECT COUNT(*) as c FROM users').get();
  if (count.c > 0) return;

  const txn = db.transaction(() => {
    // Demo user (password: 123456)
    // Pre-computed bcrypt hash for '123456'
    db.prepare(`INSERT INTO users (phone, password_hash, nickname, is_vip) VALUES (?,?,?,1)`).run(
      '13800138000', '$2a$10$dummyhashdonotuse', '测试用户'
    );

    // Demo baby
    db.prepare(`INSERT INTO babies (user_id, name, gender, birth_date) VALUES (1,'小树',1,'2025-05-10')`).run();

    // Dev standards
    const std = db.prepare(`INSERT OR IGNORE INTO dev_standards (age_group,area,item_code,item_name,pass_criteria,sort_order) VALUES (?,?,?,?,?,?)`);
    std.run(12,'gross_motor','GM-12-1','独站片刻','能独立站立3秒以上',1);
    std.run(12,'gross_motor','GM-12-2','扶物行走','扶着家具或成人手走几步',2);
    std.run(12,'fine_motor','FM-12-1','拇指食指捏小丸','能用拇指和食指捏起小物体',1);
    std.run(12,'fine_motor','FM-12-2','拨浪鼓','能握住拨浪鼓并摇晃',2);
    std.run(12,'language','LG-12-1','有意识叫爸妈','能对着父母叫爸爸妈妈',1);
    std.run(12,'language','LG-12-2','听从指令','能按成人指令做动作',2);
    std.run(12,'language','LG-12-3','发一个辅音','能发出d、t、m等辅音',3);
    std.run(12,'adaptation','AD-12-1','盖瓶盖','能将瓶盖盖在瓶口上',1);
    std.run(12,'adaptation','AD-12-2','指认身体部位','能指认至少1个身体部位',2);
    std.run(12,'social','SO-12-1','模仿动作','能模仿成人拍手、挥手等动作',1);
    std.run(12,'social','SO-12-2','表示需要','能用动作或声音表示需求',2);

    // Task templates
    const task = db.prepare(`INSERT OR IGNORE INTO task_templates (area,title,description,purpose,age_group_min,age_group_max,difficulty,duration_min,materials_needed,tips,is_active) VALUES (?,?,?,?,?,?,?,?,?,?,1)`);
    task.run('gross_motor','小树站桩','扶着宝宝站稳后，慢慢松手让他独立站3-5秒','锻炼腿部力量和平衡感',11,14,1,10,'无','可以在沙发旁边练习，软垫保护');
    task.run('gross_motor','推车小能手','让宝宝推着小推车或椅子学走路','锻炼行走能力和身体协调性',12,18,2,15,'小推车或稳固的椅子','确保周围没有尖锐物品');
    task.run('fine_motor','捏豆入瓶','给宝宝几颗大粒的豆子，示范捏起放进瓶子里','训练拇指食指捏合能力',11,16,2,10,'大粒豆子、广口瓶','全程看护防止吞食');
    task.run('fine_motor','搭积木','示范将2-3块积木叠高','培养手眼协调和空间感',11,18,1,10,'大颗粒积木','先用大积木，熟练后换小积木');
    task.run('language','亲子阅读','和宝宝一起看图画书，指着图片说出名称','丰富词汇量，培养语言理解',10,24,1,15,'图画书','每天坚持效果最好');
    task.run('language','学动物叫','模仿动物的叫声，引导宝宝跟着发音','促进发音器官发育',11,18,1,10,'无','用夸张的口型示范');
    task.run('adaptation','指认卡片','展示认知卡片，问"哪个是苹果？"让宝宝指认','训练记忆力和认知能力',11,18,1,10,'认知卡片','从2张开始，逐步增加数量');
    task.run('adaptation','套圈游戏','示范将彩色套圈套在柱子上','培养空间认知和问题解决能力',11,18,2,10,'套圈玩具','先做示范，再让宝宝尝试');
    task.run('social','交朋友','带宝宝和其他小朋友一起玩，示范分享玩具','培养社交意识和分享习惯',10,24,2,30,'无','不要强迫分享，需循序渐进');
    task.run('social','模仿做家务','给宝宝一块小抹布，模仿擦桌子的动作','培养模仿能力和参与感',12,24,1,10,'小抹布','边做边用语言描述动作');

    // Courses
    db.prepare(`INSERT OR IGNORE INTO courses (title,description,course_type,age_group_min,age_group_max,total_lessons,is_published) VALUES (?,?,?,?,?,?,1)`).run('0-1岁感官启蒙','通过视觉、听觉、触觉刺激促进宝宝感官发育','free',0,12,6);
    db.prepare(`INSERT OR IGNORE INTO courses (title,description,course_type,age_group_min,age_group_max,total_lessons,is_published) VALUES (?,?,?,?,?,?,1)`).run('1-2岁运动发展','从走路到跑步，全面提升大运动能力','free',12,24,8);
    db.prepare(`INSERT OR IGNORE INTO courses (title,description,course_type,age_group_min,age_group_max,total_lessons,is_published) VALUES (?,?,?,?,?,?,1)`).run('2-3岁语言爆发','抓住语言敏感期，快速提升表达能力','paid',24,36,10);

    // Lessons
    db.prepare(`INSERT OR IGNORE INTO course_lessons (course_id,title,description,duration_min,is_free_preview,sort_order) VALUES (?,?,?,?,?,?)`).run(1,'视觉追踪','用黑白卡引导宝宝视觉追踪',5,1,1);
    db.prepare(`INSERT OR IGNORE INTO course_lessons (course_id,title,description,duration_min,is_free_preview,sort_order) VALUES (?,?,?,?,?,?)`).run(1,'听觉辨别','摇铃引导宝宝寻找声源',5,1,2);
    db.prepare(`INSERT OR IGNORE INTO course_lessons (course_id,title,description,duration_min,is_free_preview,sort_order) VALUES (?,?,?,?,?,?)`).run(2,'稳步行走','扶走训练逐步过渡到独立行走',10,1,1);
    db.prepare(`INSERT OR IGNORE INTO course_lessons (course_id,title,description,duration_min,is_free_preview,sort_order) VALUES (?,?,?,?,?,?)`).run(2,'跑步与停止','跑步训练和急停控制',10,0,2);

    // Weekly plan
    db.prepare(`INSERT OR IGNORE INTO weekly_plans (age_group,week_offset,title) VALUES (12,1,'12月龄第1周')`).run();
    db.prepare(`INSERT OR IGNORE INTO weekly_plan_tasks (weekly_plan_id,day_of_week,task_template_id,sort_order) VALUES (1,1,1,1)`).run();
    db.prepare(`INSERT OR IGNORE INTO weekly_plan_tasks (weekly_plan_id,day_of_week,task_template_id,sort_order) VALUES (1,1,3,2)`).run();
    db.prepare(`INSERT OR IGNORE INTO weekly_plan_tasks (weekly_plan_id,day_of_week,task_template_id,sort_order) VALUES (1,2,2,1)`).run();
    db.prepare(`INSERT OR IGNORE INTO weekly_plan_tasks (weekly_plan_id,day_of_week,task_template_id,sort_order) VALUES (1,2,5,2)`).run();

    // Growth standards (simplified WHO, male)
    const gs = db.prepare(`INSERT OR IGNORE INTO growth_standards (gender,age_months,height_p3,height_p50,height_p97,weight_p3,weight_p50,weight_p97,head_p3,head_p50,head_p97) VALUES (?,?,?,?,?,?,?,?,?,?,?)`);
    gs.run(1,0,46.3,49.9,53.5,2.5,3.3,4.3,32.0,34.5,37.0);
    gs.run(1,1,50.0,53.8,57.6,3.4,4.3,5.6,35.0,37.3,39.8);
    gs.run(1,3,55.3,59.5,63.7,4.4,5.8,7.6,37.5,40.0,42.6);
    gs.run(1,6,61.2,65.7,70.2,5.9,7.6,9.8,40.0,42.7,45.2);
    gs.run(1,9,65.5,70.1,74.7,6.9,8.8,11.2,41.5,44.2,46.7);
    gs.run(1,12,68.9,73.7,78.5,7.4,9.4,11.8,42.5,45.3,47.8);

    // System config
    db.prepare(`INSERT OR IGNORE INTO system_configs (key,value,description) VALUES ('app_version','1.0.0','应用版本号')`).run();

    // Checkin + growth records
    db.prepare(`INSERT OR IGNORE INTO checkin_records (baby_id,checkin_date,streak_days) VALUES (1,date('now','localtime'),1)`).run();
    db.prepare(`INSERT OR IGNORE INTO growth_records (baby_id,record_date,height_cm,weight_kg,head_circ_cm) VALUES (1,'2025-05-10',50.0,3.3,35.2)`).run();
    db.prepare(`INSERT OR IGNORE INTO growth_records (baby_id,record_date,height_cm,weight_kg,head_circ_cm) VALUES (1,'2025-08-10',62.0,6.8,41.0)`).run();
    db.prepare(`INSERT OR IGNORE INTO growth_records (baby_id,record_date,height_cm,weight_kg,head_circ_cm) VALUES (1,'2025-11-10',68.0,8.2,43.5)`).run();
    db.prepare(`INSERT OR IGNORE INTO growth_records (baby_id,record_date,height_cm,weight_kg,head_circ_cm) VALUES (1,'2026-02-10',72.5,9.1,44.8)`).run();
    db.prepare(`INSERT OR IGNORE INTO growth_records (baby_id,record_date,height_cm,weight_kg,head_circ_cm) VALUES (1,'2026-05-10',76.0,10.0,45.5)`).run();
  });

  txn();
}

export function initDb() {
  getDb();
  console.log('[DB] SQLite initialized at', DB_PATH);
}
