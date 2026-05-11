-- ============================================================
-- 「小树成长」0-6岁家庭智力发展平台 · 数据库 DDL
-- 基于 PostgreSQL 15+
-- 编码：UTF-8
-- ============================================================

-- ---------------------------
-- 1. 用户表
-- ---------------------------
CREATE TABLE users (
    id              BIGSERIAL PRIMARY KEY,
    phone           VARCHAR(20) UNIQUE NOT NULL,
    email           VARCHAR(100) UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    nickname        VARCHAR(50),
    avatar_url      VARCHAR(500),
    is_vip          BOOLEAN DEFAULT FALSE,
    vip_expire_at   TIMESTAMP,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_phone ON users(phone);

-- ---------------------------
-- 2. 宝宝档案
-- ---------------------------
CREATE TABLE babies (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES users(id),
    name            VARCHAR(50) NOT NULL,
    gender          SMALLINT NOT NULL CHECK (gender IN (0, 1)), -- 0女 1男
    birth_date      DATE NOT NULL,
    is_premature    BOOLEAN DEFAULT FALSE,
    avatar_url      VARCHAR(500),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_babies_user ON babies(user_id);

-- ---------------------------
-- 3. 发育评测主表
-- ---------------------------
CREATE TABLE assessments (
    id                BIGSERIAL PRIMARY KEY,
    baby_id           BIGINT NOT NULL REFERENCES babies(id),
    assessment_date   DATE NOT NULL,
    actual_age_months NUMERIC(4,1) NOT NULL,  -- 实际月龄（精确到0.1）
    overall_dq        NUMERIC(5,1),            -- 发育商总分
    overall_mental_age NUMERIC(4,1),           -- 总智龄（月）
    status            VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'completed')),
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_assessments_baby ON assessments(baby_id);
CREATE INDEX idx_assessments_date ON assessments(assessment_date);

-- ---------------------------
-- 4. 评测结果（五大能区各一条）
-- ---------------------------
CREATE TABLE assessment_results (
    id              BIGSERIAL PRIMARY KEY,
    assessment_id   BIGINT NOT NULL REFERENCES assessments(id),
    area            VARCHAR(20) NOT NULL CHECK (area IN (
                        'gross_motor',      -- 大运动
                        'fine_motor',       -- 精细动作
                        'language',         -- 语言
                        'adaptation',       -- 适应能力（认知）
                        'social'            -- 社会行为
                    )),
    mental_age      NUMERIC(4,1),            -- 该能区智龄（月）
    dq_score        NUMERIC(5,1),            -- 该能区发育商
    items_passed    INT DEFAULT 0,
    items_total     INT DEFAULT 0,
    UNIQUE(assessment_id, area)
);

CREATE INDEX idx_assessment_results_assessment ON assessment_results(assessment_id);

-- ---------------------------
-- 5. 评测单项结果
-- ---------------------------
CREATE TABLE assessment_item_results (
    id              BIGSERIAL PRIMARY KEY,
    assessment_id   BIGINT NOT NULL REFERENCES assessments(id),
    area            VARCHAR(20) NOT NULL,
    item_code       VARCHAR(30) NOT NULL,      -- 如 GM-12-1
    age_group       INT NOT NULL,              -- 月龄组
    passed          BOOLEAN NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_item_results_assessment ON assessment_item_results(assessment_id);

-- ---------------------------
-- 6. 发育标准库（儿心量表-II 数据）
-- ---------------------------
CREATE TABLE dev_standards (
    id              BIGSERIAL PRIMARY KEY,
    age_group       INT NOT NULL,              -- 月龄组 1,2,3,...,12,15,18,...,36,42,48,...,84
    area            VARCHAR(20) NOT NULL,
    item_code       VARCHAR(30) NOT NULL UNIQUE,
    item_name       VARCHAR(200) NOT NULL,     -- 项目名称
    pass_criteria   TEXT,                       -- 通过标准描述
    sort_order      INT DEFAULT 0
);

CREATE INDEX idx_dev_standards_age ON dev_standards(age_group, area);

-- ---------------------------
-- 7. 每日任务模板库
-- ---------------------------
CREATE TABLE task_templates (
    id              BIGSERIAL PRIMARY KEY,
    area            VARCHAR(20) NOT NULL,
    title           VARCHAR(100) NOT NULL,
    description     TEXT,
    purpose         VARCHAR(500),              -- 训练目的
    age_group_min   INT NOT NULL,              -- 适用最小月龄
    age_group_max   INT NOT NULL,              -- 适用最大月龄
    difficulty      SMALLINT DEFAULT 1 CHECK (difficulty IN (1,2,3)),
    duration_min    INT DEFAULT 15,            -- 预计时长（分钟）
    materials_needed VARCHAR(500),             -- 所需材料
    video_url       VARCHAR(500),              -- 示范视频
    icon_url        VARCHAR(500),              -- 任务图标
    tips            TEXT,                       -- 家长注意事项
    is_active       BOOLEAN DEFAULT TRUE,
    sort_order      INT DEFAULT 0,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_tasks_age ON task_templates(age_group_min, age_group_max);

-- ---------------------------
-- 8. 周计划模板
-- ---------------------------
CREATE TABLE weekly_plans (
    id              BIGSERIAL PRIMARY KEY,
    age_group       INT NOT NULL,
    week_offset     INT NOT NULL,              -- 第几周模板（从第1周开始）
    title           VARCHAR(100),
    description     TEXT,
    UNIQUE(age_group, week_offset)
);

-- ---------------------------
-- 9. 周计划-任务关联
-- ---------------------------
CREATE TABLE weekly_plan_tasks (
    id              BIGSERIAL PRIMARY KEY,
    weekly_plan_id  BIGINT NOT NULL REFERENCES weekly_plans(id),
    day_of_week     SMALLINT NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
    task_template_id BIGINT NOT NULL REFERENCES task_templates(id),
    sort_order      INT DEFAULT 0,
    UNIQUE(weekly_plan_id, day_of_week, task_template_id)
);

CREATE INDEX idx_plan_tasks_plan ON weekly_plan_tasks(weekly_plan_id);

-- ---------------------------
-- 10. 宝宝每日任务（实际下发）
-- ---------------------------
CREATE TABLE baby_daily_tasks (
    id              BIGSERIAL PRIMARY KEY,
    baby_id         BIGINT NOT NULL REFERENCES babies(id),
    task_template_id BIGINT NOT NULL REFERENCES task_templates(id),
    assign_date     DATE NOT NULL,
    scheduled_time  TIME DEFAULT '08:00',      -- 建议执行时间
    is_completed    BOOLEAN DEFAULT FALSE,
    completed_at    TIMESTAMP,
    user_rating     SMALLINT CHECK (user_rating BETWEEN 1 AND 5), -- 家长评分（孩子配合度）
    notes           TEXT,
    UNIQUE(baby_id, task_template_id, assign_date)
);

CREATE INDEX idx_daily_tasks_baby_date ON baby_daily_tasks(baby_id, assign_date);

-- ---------------------------
-- 11. 生长记录（身高/体重/头围）
-- ---------------------------
CREATE TABLE growth_records (
    id              BIGSERIAL PRIMARY KEY,
    baby_id         BIGINT NOT NULL REFERENCES babies(id),
    record_date     DATE NOT NULL,
    height_cm       NUMERIC(5,1),
    weight_kg       NUMERIC(5,2),
    head_circ_cm    NUMERIC(4,1),
    notes           TEXT,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(baby_id, record_date)
);

CREATE INDEX idx_growth_baby ON growth_records(baby_id);

-- ---------------------------
-- 12. WHO 生长标准参考表
-- ---------------------------
CREATE TABLE growth_standards (
    id              BIGSERIAL PRIMARY KEY,
    gender          SMALLINT NOT NULL CHECK (gender IN (0, 1)),
    age_months      INT NOT NULL,
    -- 身高百分位 (cm)
    height_p3       NUMERIC(5,1),
    height_p10      NUMERIC(5,1),
    height_p25      NUMERIC(5,1),
    height_p50      NUMERIC(5,1),
    height_p75      NUMERIC(5,1),
    height_p90      NUMERIC(5,1),
    height_p97      NUMERIC(5,1),
    -- 体重百分位 (kg)
    weight_p3       NUMERIC(5,2),
    weight_p10      NUMERIC(5,2),
    weight_p25      NUMERIC(5,2),
    weight_p50      NUMERIC(5,2),
    weight_p75      NUMERIC(5,2),
    weight_p90      NUMERIC(5,2),
    weight_p97      NUMERIC(5,2),
    -- 头围百分位 (cm)
    head_p3         NUMERIC(4,1),
    head_p10        NUMERIC(4,1),
    head_p25        NUMERIC(4,1),
    head_p50        NUMERIC(4,1),
    head_p75        NUMERIC(4,1),
    head_p90        NUMERIC(4,1),
    head_p97        NUMERIC(4,1),
    UNIQUE(gender, age_months)
);

-- ---------------------------
-- 13. 里程碑
-- ---------------------------
CREATE TABLE milestones (
    id              BIGSERIAL PRIMARY KEY,
    baby_id         BIGINT NOT NULL REFERENCES babies(id),
    milestone_type  VARCHAR(50) NOT NULL,      -- first_teeth, first_roll, first_sit, first_crawl, first_stand, first_walk, first_word
    occurred_at     DATE,
    notes           TEXT,
    photo_url       VARCHAR(500),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_milestones_baby ON milestones(baby_id);

-- ---------------------------
-- 14. 成长相册
-- ---------------------------
CREATE TABLE media_albums (
    id              BIGSERIAL PRIMARY KEY,
    baby_id         BIGINT NOT NULL REFERENCES babies(id),
    media_type      VARCHAR(10) NOT NULL CHECK (media_type IN ('photo', 'video')),
    url             VARCHAR(500) NOT NULL,
    thumbnail_url   VARCHAR(500),
    description     TEXT,
    record_date     DATE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_media_baby_date ON media_albums(baby_id, record_date);

-- ---------------------------
-- 15. 家长课程
-- ---------------------------
CREATE TABLE courses (
    id              BIGSERIAL PRIMARY KEY,
    title           VARCHAR(200) NOT NULL,
    description     TEXT,
    cover_url       VARCHAR(500),
    price           NUMERIC(10,2) DEFAULT 0,
    course_type     VARCHAR(20) CHECK (course_type IN ('free', 'paid')),
    age_group_min   INT,
    age_group_max   INT,
    total_lessons   INT DEFAULT 0,
    sort_order      INT DEFAULT 0,
    is_published    BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------
-- 16. 课程章节
-- ---------------------------
CREATE TABLE course_lessons (
    id              BIGSERIAL PRIMARY KEY,
    course_id       BIGINT NOT NULL REFERENCES courses(id),
    title           VARCHAR(200) NOT NULL,
    description     TEXT,
    video_url       VARCHAR(500),
    duration_min    INT,
    is_free_preview BOOLEAN DEFAULT FALSE,
    sort_order      INT DEFAULT 0,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_lessons_course ON course_lessons(course_id);

-- ---------------------------
-- 17. 用户已购课程
-- ---------------------------
CREATE TABLE user_courses (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES users(id),
    course_id       BIGINT NOT NULL REFERENCES courses(id),
    progress        NUMERIC(5,2) DEFAULT 0,    -- 学习进度百分比
    purchased_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, course_id)
);

-- ---------------------------
-- 18. 订阅/会员
-- ---------------------------
CREATE TABLE subscriptions (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES users(id),
    plan_type       VARCHAR(20) NOT NULL CHECK (plan_type IN ('monthly', 'yearly')),
    start_date      DATE NOT NULL,
    end_date        DATE NOT NULL,
    payment_amount  NUMERIC(10,2),
    payment_method  VARCHAR(50),
    status          VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'expired', 'cancelled')),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_subs_user ON subscriptions(user_id);
CREATE INDEX idx_subs_status ON subscriptions(status);

-- ---------------------------
-- 19. 打卡记录
-- ---------------------------
CREATE TABLE checkin_records (
    id              BIGSERIAL PRIMARY KEY,
    baby_id         BIGINT NOT NULL REFERENCES babies(id),
    checkin_date    DATE NOT NULL,
    tasks_completed INT DEFAULT 0,
    is_full_complete BOOLEAN DEFAULT FALSE,
    streak_days     INT DEFAULT 0,
    UNIQUE(baby_id, checkin_date)
);

CREATE INDEX idx_checkin_baby_date ON checkin_records(baby_id, checkin_date);

-- ---------------------------
-- 20. 系统配置表
-- ---------------------------
CREATE TABLE system_configs (
    key             VARCHAR(100) PRIMARY KEY,
    value           TEXT NOT NULL,
    description     VARCHAR(500),
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------
-- 自动更新 updated_at 触发器
-- ---------------------------
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trg_babies_updated_at BEFORE UPDATE ON babies
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trg_courses_updated_at BEFORE UPDATE ON courses
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();
