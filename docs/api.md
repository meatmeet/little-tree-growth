# 小树成长 API 设计文档

## 基础信息

- Base URL: `https://api.xiaoshu-growth.com/v1`
- 认证方式: Bearer Token (JWT)
- 响应格式: JSON

```
{
  "code": 0,        // 0=成功, 非0=错误码
  "message": "ok",
  "data": {}
}
```

---

## 一、用户模块

### 1.1 注册/登录

```
POST /auth/register          # 手机号注册
POST /auth/login             # 登录
POST /auth/send-code         # 发送验证码
POST /auth/reset-password    # 重置密码
```

### 1.2 用户信息

```
GET    /user/profile         # 获取个人信息
PUT    /user/profile         # 修改个人信息
GET    /user/vip-status      # 查询会员状态
```

---

## 二、宝宝档案

### 2.1 档案管理

```
POST   /babies               # 添加宝宝
GET    /babies               # 宝宝列表
GET    /babies/:id           # 宝宝详情
PUT    /babies/:id           # 修改档案
DELETE /babies/:id           # 删除宝宝
```

**请求体示例 (POST /babies):**
```json
{
  "name": "小宝",
  "gender": 1,
  "birth_date": "2025-05-10",
  "is_premature": false,
  "avatar_url": "https://..."
}
```

---

## 三、发育评测

### 3.1 评测流程

```
POST   /assessments                     # 创建新评测
GET    /assessments?baby_id=1           # 评测历史列表
GET    /assessments/:id                 # 评测详情（含五大能区结果）
```

### 3.2 评测项目

```
GET    /assessments/items?age_group=12  # 获取某月龄的评测题目
POST   /assessments/:id/items           # 提交评测答案
```

**提交答案示例:**
```json
{
  "results": [
    {"area": "gross_motor", "item_code": "GM-12-1", "passed": true},
    {"area": "gross_motor", "item_code": "GM-12-2", "passed": true},
    {"area": "fine_motor", "item_code": "FM-12-1", "passed": false}
  ]
}
```

### 3.3 评测报告

```
GET    /assessments/:id/report          # 获取完整评测报告
GET    /assessments/:id/radar           # 获取五大能区雷达图数据
```

**报告返回示例:**
```json
{
  "assessment_date": "2026-05-10",
  "actual_age_months": 12.0,
  "overall_dq": 105.2,
  "overall_mental_age": 12.6,
  "dq_level": "中等",
  "areas": [
    {"area": "gross_motor", "mental_age": 13.0, "dq": 108.3, "level": "良好"},
    {"area": "fine_motor", "mental_age": 11.0, "dq": 91.7, "level": "中等"},
    {"area": "language", "mental_age": 13.0, "dq": 108.3, "level": "良好"},
    {"area": "adaptation", "mental_age": 12.5, "dq": 104.2, "level": "中等"},
    {"area": "social", "mental_age": 13.5, "dq": 112.5, "level": "良好"}
  ],
  "highlights": ["语言发展超出同龄水平", "精细动作需加强训练"],
  "suggestions": ["多给宝宝提供捏取小物品的机会"]
}
```

### 3.4 发展趋势

```
GET    /assessments/trend?baby_id=1     # 获取发育趋势数据（多次评测对比）
```

---

## 四、每日任务

### 4.1 任务获取

```
GET    /tasks/daily?baby_id=1&date=2026-05-10   # 获取某天的任务
POST   /tasks/generate                                    # 为宝宝生成下周任务
```

**每日任务返回示例:**
```json
{
  "date": "2026-05-10",
  "weekday": "周一",
  "theme": "运动日",
  "tasks": [
    {
      "id": 101,
      "area": "gross_motor",
      "title": "小树站桩",
      "description": "扶着宝宝站好，慢慢松手让他独立站3-5秒",
      "duration_min": 10,
      "materials_needed": "无",
      "video_url": "https://...",
      "is_completed": false
    },
    {
      "id": 102,
      "area": "fine_motor",
      "title": "捏豆入瓶",
      "description": "...",
      "duration_min": 10,
      "is_completed": false
    }
  ],
  "total_duration_min": 20
}
```

### 4.2 任务操作

```
PUT    /tasks/daily/:id/complete      # 完成任务
PUT    /tasks/daily/:id/skip          # 跳过任务
PUT    /tasks/:id/rating              # 评分
```

---

## 五、打卡与连续记录

### 5.1 打卡

```
POST   /checkin                       # 记录当日打卡
GET    /checkin/calendar?baby_id=1    # 获取打卡日历
```

### 5.2 连续天数

```
GET    /checkin/streak?baby_id=1      # 获取连续打卡天数
```

---

## 六、生长记录

### 6.1 记录管理

```
POST   /growth-records                # 添加生长记录
GET    /growth-records?baby_id=1      # 生长记录列表
PUT    /growth-records/:id            # 修改记录
DELETE /growth-records/:id            # 删除记录
```

### 6.2 生长曲线

```
GET    /growth-records/curve?baby_id=1&type=height   # 获取生长曲线数据
```

**返回示例:**
```json
{
  "records": [
    {"date": "2025-06-10", "age_months": 1, "value": 53.5},
    {"date": "2025-08-10", "age_months": 3, "value": 60.2},
    {"date": "2025-11-10", "age_months": 6, "value": 67.8}
  ],
  "standards": [
    {"age_months": 1, "p3": 47.3, "p50": 53.5, "p97": 59.6},
    {"age_months": 3, "p3": 54.5, "p50": 60.5, "p97": 66.9}
  ]
}
```

---

## 七、里程碑

```
POST   /milestones                    # 记录里程碑事件
GET    /milestones?baby_id=1          # 里程碑列表
DELETE /milestones/:id                # 删除记录
```

---

## 八、成长相册

```
POST   /media                         # 上传照片/视频
GET    /media?baby_id=1&date=2026-05  # 按月查看相册
DELETE /media/:id                     # 删除
```

---

## 九、课程

```
GET    /courses?age_group=12          # 课程列表（按月龄筛选）
GET    /courses/:id                   # 课程详情
GET    /courses/:id/lessons           # 课程章节列表
POST   /courses/:id/purchase          # 购买课程
GET    /courses/:id/progress          # 学习进度
PUT    /courses/:id/progress          # 更新学习进度
```

---

## 十、会员

```
POST   /subscriptions                 # 创建订阅订单
GET    /subscriptions/current         # 当前订阅状态
POST   /subscriptions/cancel          # 取消续费
```

---

## 十一、统计

```
GET    /stats/summary?baby_id=1       # 宝宝成长摘要
GET    /stats/weekly?baby_id=1        # 周报数据
```

**周报返回示例:**
```json
{
  "week_start": "2026-05-04",
  "week_end": "2026-05-10",
  "checkin_days": 6,
  "streak_days": 12,
  "tasks_completed": 11,
  "new_milestones": 0,
  "growth": {"weight_gain": 0.1, "height_gain": 0.5},
  "spotlight_area": "语言",
  "weakness_area": "精细动作"
}
```
