# 小树成长 — 全功能设计方案

## 现状概览

### ✅ 已完成功能
| 模块 | 内容 | 状态 |
|------|------|------|
| 认证 | 手机号+验证码登录、Token 持久化、Auth Gate | 完成 |
| 宝宝管理 | 添加/编辑/选择/删除、最多5个限制、SharedPreferences 持久化 | 完成 |
| 每日任务 | 加载当日任务、切换完成状态、签到打卡、连续天数 | 完成 |
| 生长记录 | 记录身高/体重/头围、历史列表、折线图(fl_chart) | 完成 |
| 里程碑 | 7种类型选择、时间线展示 | 完成 |
| 评测 | 创建评测、DQ评分展示、五大能区分解 | 完成 |
| 课程列表 | 月龄筛选、推荐课程、课程详情与课时列表 | 完成 |
| 离线缓存 | 所有 Provider 均有 SharedPreferences 降级 | 完成 |
| 下拉刷新 | 所有列表页均支持 RefreshIndicator | 完成 |

### ⏳ 待开发功能
| 模块 | 具体缺失 | 优先级 |
|------|----------|--------|
| 评测流程 | 缺少逐题问答界面，只有创建和结果页 | P0 |
| 会员购买 | 整个支付/订阅流程未实现 | P0 |
| 个人页面 | 退出登录、头像编辑、资料修改 | P1 |
| 设置页 | 通知、同步、隐私均为空壳 | P1 |
| 通知系统 | 首页通知图标无内容 | P2 |
| 课程购买 | 详情页锁图标无实际购买逻辑 | P2 |
| 里程碑拍照 | 缺少拍照/相册选择 | P2 |
| 宝宝头像 | BabyFormScreen 缺少头像选择 | P2 |
| 数据趋势 | 评测历史趋势图、WHO生长标准叠加 | P2 |
| 打卡日历 | 服务端有接口但客户端未使用 | P3 |
| 任务评分 | 完成后的用户评分未实现 | P3 |
| 统计看板 | 服务端有统计接口客户端未用 | P3 |

### 未使用的服务端接口
```
评测:   GET /assessments/items, POST /:id/items, GET /:id/report, GET /trend
课程:   POST /:id/purchase, GET /:id/progress, PUT /:id/progress
打卡:   GET /checkin/calendar, GET /streak
统计:   GET /stats/summary, GET /stats/weekly
订阅:   POST /subscriptions, GET /current, POST /cancel
用户:   GET /profile, GET /vip-status
任务:   PUT /:id/rating
生长:   GET /growth/curve
```

---

## 阶段一：核心交互补全（P0）

### 1.1 评测答题流程

**现状**: 点击"开始新评测"→ 创建 assessment → 直接跳到结果页（空数据）

**设计**:
1. 新增 `AssessmentQuizScreen` — 基于 `dev_standards` 逐项问答
2. 服务端 `/assessments/:id/items` 获取当前月龄组的标准项目
3. 每题展示：项目名称 + 通过标准描述 + 通过/不通过按钮
4. 全部答完后调用 `/assessments/:id/submit` 提交
5. 完成后跳转 `AssessmentDetailScreen` 显示真实评分

**涉及文件**:
- 新增 `lib/screens/assessment_quiz_screen.dart`
- 修改 `lib/screens/assessment_screen.dart` (创建后跳转到答题页而非结果页)
- 修改 `lib/providers/assessment_provider.dart` (增加 `loadItems`, `submitItem` 方法)
- 服务端 `routes/assessments.js` GET `/items` 和 POST `/:id/items` 已有

### 1.2 会员购买流程

**现状**: 点击"开通"→ SnackBar "会员功能开发中"

**设计**:
1. 新增 `VipPurchaseScreen` — 展示月卡/年卡选项
2. 调用服务端 `POST /subscriptions` 创建订阅
3. 调起微信/支付宝支付（先使用模拟支付回调）
4. 购买成功后刷新用户 VIP 状态（`GET /users/vip-status`）
5. VIP 卡面更新显示会员权益

**涉及文件**:
- 新增 `lib/screens/vip_purchase_screen.dart`
- 修改 `lib/widgets/vip_card.dart` (激活回调跳转购买页)
- 修改 `lib/providers/auth_provider.dart` (增加 `refreshVipStatus`)
- 修改 `lib/services/auth_service.dart` (增加 `getVipStatus`)

---

## 阶段二：个人中心完善（P1）

### 2.1 退出登录

**现状**: 个人页无退出登录按钮

**设计**:
1. 在设置列表底部添加"退出登录"红字按钮
2. 弹出确认对话框
3. 调用 `AuthProvider.logout()` → 清除 Token + 用户数据 → 回到登录页

### 2.2 用户资料编辑

**现状**: 头像区域只读，不能修改昵称和头像

**设计**:
1. 点击头像区域跳转 `ProfileEditScreen`
2. 可编辑：昵称（TextField）、头像（从相册选择）
3. 调用 `PUT /users/profile` 保存

**涉及文件**:
- 新增 `lib/screens/profile_edit_screen.dart`
- 修改 `lib/screens/profile_screen.dart` (头像区域点击跳转)

### 2.3 设置功能实现

**现状**: 4个设置项全部是"开发中"

**设计**:
1. **消息通知** → 通知开关页 `NotificationSettingsScreen`
   - 开关：每日任务提醒、成长提醒、课程更新提醒
   - 存储在 SharedPreferences
2. **数据同步** → 同步状态页 `DataSyncScreen`
   - 显示最后同步时间
   - 手动同步按钮
   - 当前使用离线缓存，云端同步状态显示
3. **隐私设置** → `PrivacySettingsScreen`
   - 开关：允许数据分析、显示在排行榜
4. **关于我们** → 完善为 `AboutScreen`
   - 版本号、功能介绍、用户协议链接、隐私政策链接

**涉及文件**:
- 新增 `lib/screens/notification_settings_screen.dart`
- 新增 `lib/screens/data_sync_screen.dart`
- 新增 `lib/screens/privacy_settings_screen.dart`
- 新增 `lib/screens/about_screen.dart`
- 修改 `lib/screens/profile_screen.dart` (替换回调)

---

## 阶段三：功能增强（P2）

### 3.1 课程购买与学习进度

**现状**: 课程详情页锁图标无实际功能，进度始终为0

**设计**:
1. 课程详情页判断是否已购
2. 未购 → 显示购买按钮，调用 `POST /courses/:id/purchase`
3. 已购 → 解锁课时列表，可逐节标记完成
4. 调用 `PUT /courses/:id/progress` 同步进度

**涉及文件**:
- 修改 `lib/screens/course_detail_screen.dart` (购买/解锁逻辑)
- 修改 `lib/providers/course_provider.dart` (增加购买和进度方法)

### 3.2 里程碑拍照

**现状**: Milestone 模型有 `photoUrl` 表单但没有拍照入口

**设计**:
1. `MilestoneFormScreen` 增加拍照/相册按钮
2. 使用 `image_picker` 插件
3. 拍照后上传到服务器（或先存为本地路径）
4. 时间线页面显示缩略图

**涉及文件**:
- 修改 `lib/screens/milestone_form_screen.dart` (增加拍照入口)
- 修改 `pubspec.yaml` (添加 `image_picker` 依赖)
- 修改 `lib/widgets/timeline_item.dart` (支持图片展示)

### 3.3 宝宝头像选择

**现状**: `BabyFormScreen` 没有头像选择

**设计**:
1. 在姓名输入下方增加头像选择区域
2. 使用预设头像列表（emoji/插图）或拍照
3. 编辑时显示当前头像

**涉及文件**:
- 修改 `lib/screens/baby_form_screen.dart`

### 3.4 评测历史趋势

**现状**: 服务端有 `GET /assessments/trend`，客户端未调用

**设计**:
1. `AssessmentDetailScreen` 增加趋势 Tab
2. 调用 `/assessments/trend` 获取历史 DQ 数据
3. 使用 fl_chart 绘制 DQ 变化折线图
4. 显示各能区得分变化

**涉及文件**:
- 修改 `lib/screens/assessment_detail_screen.dart` (增加趋势图)
- 修改 `lib/providers/assessment_provider.dart` (增加 `loadTrend` 方法)

### 3.5 生长曲线叠加 WHO 标准

**现状**: 生长曲线只有宝宝自己的数据，没有参考线

**设计**:
1. 调用 `GET /growth/curve` 获取 WHO 标准百分位数据（p3/p50/p97）
2. 在图表中叠加三条灰色参考线
3. 宝宝数据以彩色粗线叠加显示

**涉及文件**:
- 修改 `lib/screens/growth_screen.dart` (图表区)
- 修改 `lib/providers/growth_provider.dart` (增加 `loadGrowthStandards`)

---

## 阶段四：增值功能（P3）

### 4.1 打卡日历

**现状**: 签到按钮只增加连续天数，无日历展示

**设计**:
1. 点击 StreakCard 进入打卡日历页
2. 调用 `GET /checkin/calendar` 获取月度打卡数据
3. 月视图展示已打卡/未打卡日期
4. 调用 `GET /checkin/streak` 获取连续天数详情

**涉及文件**:
- 新增 `lib/screens/checkin_calendar_screen.dart`
- 修改 `lib/widgets/streak_card.dart` (签到按钮跳转到日历页)
- 修改 `lib/providers/task_provider.dart` (增加日历方法)

### 4.2 任务评分

**现状**: 完成任务后无评分入口

**设计**:
1. 任务完成弹窗增加 1-5 星评分
2. 调用 `PUT /tasks/:id/rating` 提交评分
3. 评分数据用于后续任务推荐优化

**涉及文件**:
- 修改 `lib/screens/task_detail_screen.dart` (增加评分)

### 4.3 统计看板

**现状**: 无数据汇总页面

**设计**:
1. 新增 `StatsScreen`（可从个人页或首页进入）
2. 调用 `GET /stats/summary` 展示概览
3. 调用 `GET /stats/weekly` 展示周趋势
4. 显示：总任务完成数、评测次数、生长趋势、课程学习时长

**涉及文件**:
- 新增 `lib/screens/stats_screen.dart`
- 修改 `lib/screens/profile_screen.dart` (增加统计入口)

### 4.4 通知列表页

**现状**: 通知图标无内容

**设计**:
1. 新增 `NotificationListScreen`
2. 显示系统通知：任务提醒、成长提醒、课程更新、活动推送
3. 目前先使用本地 Mock 数据（服务端暂无通知接口）

**涉及文件**:
- 新增 `lib/screens/notification_list_screen.dart`
- 修改 `lib/screens/home_screen.dart` (通知图标跳转)

---

## 技术架构建议

### 新增依赖
```yaml
dependencies:
  image_picker: ^1.0.0    # 拍照/相册选择
  cached_network_image: ^3.3.0  # 头像缓存
```

### 代码规范
- 所有新 Screen 放在 `lib/screens/` 目录
- 所有新 Provider 放在 `lib/providers/` 目录
- Provider 命名统一：`loadXxx`（加载）、`addXxx`（新增）、`updateXxx`（更新）
- API 调用统一走 `ApiService` 单例

### 响应格式约定
```json
// 成功
{"code": 0, "message": "ok", "data": {...}}
// 失败
{"code": -1, "message": "错误描述", "data": null}
```

---

## 实施路线图

```
阶段一（P0）: 评测答题 + 会员购买       → 2-3天
阶段二（P1）: 退出登录 + 资料编辑 + 设置  → 2-3天
阶段三（P2）: 课程购买 + 里程碑拍照 + 
              宝宝头像 + 趋势图 + WHO曲线 → 3-4天
阶段四（P3）: 打卡日历 + 任务评分 + 
              统计看板 + 通知列表        → 2-3天
```

每个阶段完成后提交代码并打包 APK 部署测试。
