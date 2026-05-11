-- ============================================================
-- 种子数据：每日任务模板库
-- 覆盖 1-36 月龄，五大能区
-- ============================================================

-- ========== 1岁（12-14月龄）任务 ==========

-- 大运动
INSERT INTO task_templates (area, title, description, purpose, age_group_min, age_group_max, difficulty, duration_min, materials_needed, tips, sort_order) VALUES
('gross_motor', '小树站桩', '扶着宝宝站好，慢慢松手让他独立站3-5秒，逐渐延长时间', '训练独站能力和平衡感', 12, 14, 1, 10, '无', '在软垫上进行，旁边放他喜欢的玩具吸引注意力', 1),
('gross_motor', '扶走小勇士', '让宝宝扶着沙发或茶几边缘走，你在另一侧张开手臂迎接他', '锻炼扶走能力和下肢力量', 12, 14, 2, 15, '无', '把家具摆成一条通路，确保没有尖角', 2),
('gross_motor', '蹲下捡宝', '把玩具放在地上，鼓励宝宝从站立姿势蹲下捡起玩具再站起', '训练蹲起动作和下肢力量', 12, 14, 2, 10, '宝宝喜欢的玩具', '刚开始可以扶着大人的手完成蹲起', 3),
-- 精细动作
('fine_motor', '捏豆入瓶', '准备一个大口瓶和小豆子，示范用拇指和食指捏起豆子放入瓶口', '训练拇指食指捏取精细动作', 12, 14, 2, 10, '大口瓶、大粒豆子或葡萄干', '全程看护防止误吞，可用磨牙饼干代替豆子', 1),
('fine_motor', '积木对对碰', '给宝宝两块积木，示范两手各拿一块互相敲击，让他模仿', '训练双手协调和敲击动作', 12, 14, 1, 8, '两块小积木或木制敲击玩具', '选择边缘圆润的积木', 2),
('fine_motor', '翻书小达人', '和宝宝一起看布书或硬纸板书，引导他自己翻页', '训练手指灵活度和手眼协调', 12, 14, 1, 10, '布书或厚纸板书', '选择色彩鲜艳、每页内容简单的书', 3),
-- 语言
('language', '这是什么？', '指着家里的常见物品（灯、门、杯子），清晰地说出名称，反复指认', '积累词汇理解能力', 12, 14, 1, 8, '家里常见物品', '每天重复同样的物品，不要一次性教太多', 1),
('language', '宝宝在哪里？', '问"宝宝在哪里"然后指着他回答"在这里！"，引导他模仿', '训练自我认知和发音', 12, 14, 1, 5, '无', '夸张的表情和语调会让宝宝更感兴趣', 2),
('language', '模仿动物叫', '拿出动物卡片或玩具，模仿动物叫声（汪汪、喵喵、嘎嘎）', '激发发音兴趣和模仿能力', 12, 14, 2, 8, '动物卡片或玩具', '每次只模仿1-2种动物，反复重复', 3),
-- 认知
('adaptation', '躲猫猫', '用手或手帕挡住脸，然后突然打开说"喵——！"，反复几次', '建立物体恒存概念', 12, 14, 1, 5, '手帕或薄布', '也可以把玩具藏在手帕下面让他掀开找', 1),
('adaptation', '模仿拍手', '一边唱"如果感到快乐你就拍拍手"，一边做拍手动作，鼓励宝宝模仿', '训练模仿能力和节奏感', 12, 14, 1, 5, '无', '放慢动作让宝宝看清你的手', 2),
('adaptation', '按铃铛', '给宝宝一个有按钮的玩具，示范按按钮会发出声音，鼓励他自己按', '建立因果关系认知', 12, 14, 2, 8, '有按钮的发声玩具', '也可以用家里安全的有按钮的物品替代', 3),
-- 社交
('social', '再见挥手', '每次出门或家人离开时，抱着宝宝的手做"再见"挥手动作', '学习社交礼仪动作', 12, 14, 1, 3, '无', '在真实场景中做效果最好，不要刻意训练', 1),
('social', '表情模仿', '对宝宝做夸张的表情（开心大笑、惊讶张嘴、皱眉），鼓励他模仿', '识别和模仿情绪表达', 12, 14, 1, 5, '无', '配合镜子效果更好，让宝宝看到自己的表情', 2),
('social', '分享美食', '给宝宝一块饼干或水果，让他"喂"给你吃，然后开心地说"谢谢宝宝"', '培养分享意识和互动乐趣', 12, 14, 2, 5, '安全的食物', '他喂你的时候一定要表现出很好吃的样子', 3);

-- ========== 1.5岁（18-20月龄）任务 ==========
INSERT INTO task_templates (area, title, description, purpose, age_group_min, age_group_max, difficulty, duration_min, materials_needed, tips, sort_order) VALUES
('gross_motor', '上楼梯小达人', '扶着宝宝的手，鼓励他一步一阶上楼梯', '训练腿部力量和上下楼梯协调', 18, 20, 2, 15, '安全的楼梯', '从2-3级台阶开始，逐渐增加', 1),
('gross_motor', '捡球游戏', '把球滚到远处，鼓励宝宝走过去捡起来再走回来', '训练行走稳定性和目标导向', 18, 20, 1, 10, '软球', '距离由近到远逐步增加', 2),
('gross_motor', '跨过小障碍', '在地板上放一根绳子或矮障碍物，牵着宝宝的手跨过去', '训练抬腿跨步和身体协调', 18, 20, 2, 10, '绳子或矮纸盒', '障碍物高度不超过5cm', 3),
('fine_motor', '拧瓶盖', '准备一个空塑料瓶，示范拧开和拧紧瓶盖的动作', '训练手腕旋转和手指力量', 18, 20, 2, 8, '空塑料瓶', '瓶盖不要拧太紧，让宝宝能成功拧开获得成就感', 1),
('fine_motor', '搭高高', '用积木示范搭高塔，鼓励宝宝模仿搭3-4块', '训练手眼协调和空间感知', 18, 20, 2, 10, '大块积木', '用大块积木降低难度，成功后拍手鼓励', 2),
('language', '身体部位歌', '唱"头发肩膀膝盖脚"并指出对应部位，鼓励宝宝跟指', '学习身体部位名称', 18, 20, 1, 5, '无', '每天只学2-3个部位，反复巩固', 1),
('language', '小动物叫什么', '拿出动物卡片问"这是什么？"，鼓励宝宝说出名称', '扩展词汇量和发音能力', 18, 20, 2, 8, '动物卡片', '他发音不准也没关系，你重复正确的发音即可', 2),
('adaptation', '配对游戏', '准备两双袜子或两个杯子，混在一起让宝宝找到一样的', '训练观察力和分类能力', 18, 20, 2, 10, '成对的物品', '用颜色鲜艳、差异大的物品开始', 1),
('adaptation', '小帮手', '让宝宝帮忙把玩具"放回去"，把积木放进盒子，把书放回书架', '训练分类整理和执行力', 18, 20, 1, 8, '收纳盒', '边说"积木回家啦"边做，增加趣味性', 2),
('social', '一起玩球', '和宝宝面对面坐着，把球滚给他，鼓励他再滚回来', '训练轮流和互动游戏', 18, 20, 1, 8, '软球', '他滚回来时大声说"谢谢"，建立社交反馈', 1),
('social', '照顾娃娃', '给宝宝一个娃娃，示范给娃娃"喂饭""盖被子"，鼓励他模仿', '培养同理心和照顾意识', 18, 20, 2, 10, '娃娃或玩偶', '男宝女宝都适合玩这个游戏', 2);

-- ========== 2岁（24-27月龄）任务 ==========
INSERT INTO task_templates (area, title, description, purpose, age_group_min, age_group_max, difficulty, duration_min, materials_needed, tips, sort_order) VALUES
('gross_motor', '小兔子跳跳', '示范双脚同时离地跳起，鼓励宝宝模仿，从原地跳到向前跳', '训练双脚跳跃能力', 24, 27, 2, 10, '无', '先原地跳再向前跳，做好防护', 1),
('gross_motor', '踢球进门', '用两个小凳子当球门，示范踢球进门，鼓励宝宝踢', '训练踢球和下肢控制', 24, 27, 2, 10, '软球', '球门要足够大，让宝宝有成就感', 2),
('gross_motor', '过独木桥', '在地板上贴一条胶带当"独木桥"，鼓励宝宝在上面走', '训练平衡能力和专注力', 24, 27, 2, 10, '胶带', '开始宽一些，逐步变窄', 3),
('fine_motor', '穿珠子', '用大孔珠子和绳子示范穿珠子，鼓励宝宝自己穿', '训练手眼协调和专注力', 24, 27, 3, 10, '大孔珠子、绳子', '从2-3颗开始，成功后逐步增加数量', 1),
('fine_motor', '撕纸艺术', '给宝宝彩色纸，示范撕出形状，然后一起把碎纸贴到白纸上', '训练手指力量和控制力', 24, 27, 1, 10, '彩色纸、胶棒、白纸', '不要追求形状，享受过程', 2),
('language', '我来回答', '在日常生活中问简单问题：谁来了？我们去哪？这是什么？', '训练语言表达和回答能力', 24, 27, 2, 5, '无', '等3-5秒让宝宝回答，不要急着替他说', 1),
('language', '说一说今天', '睡前和宝宝回顾今天做了什么，用简单句子描述', '训练叙述能力和记忆力', 24, 27, 1, 8, '无', '用"早上我们去了...然后..."的结构', 2),
('adaptation', '假装打电话', '用玩具手机或积木当电话，和宝宝玩假装打电话的游戏', '发展想象力和假装游戏能力', 24, 27, 2, 10, '玩具手机', '怎么说都行，享受他的想象力', 1),
('social', '有礼貌的宝宝', '需要帮忙时说"请"，得到后说"谢谢"，帮宝宝养成习惯', '礼貌用语和社交技能', 24, 27, 1, 3, '无', '你自己先做到，宝宝会模仿你', 1),
('social', '我的和你的', '用实物做"我的积木""你的积木"轮流玩，引导理解物权概念', '理解归属和轮流', 24, 27, 2, 8, '积木或玩具', '先理解"我的"，再说"你的"，分开教', 2);

-- ========== 3岁（36-42月龄）任务 ==========
INSERT INTO task_templates (area, title, description, purpose, age_group_min, age_group_max, difficulty, duration_min, materials_needed, tips, sort_order) VALUES
('gross_motor', '金鸡独立', '示范单脚站立，从5秒开始，逐步延长时间', '训练单脚平衡能力', 36, 42, 2, 8, '无', '先扶着墙练习，慢慢松手', 1),
('gross_motor', '骑小车', '鼓励宝宝骑三轮童车或平衡车', '训练下肢协调和平衡', 36, 42, 3, 15, '三轮车或平衡车', '佩戴护具，选择平坦的安全场地', 2),
('fine_motor', '串珠比赛', '用绳子穿小珠子，看谁穿得多', '训练精细操作和专注力', 36, 42, 2, 10, '小珠子、绳子', '大人和孩子比赛，适当让让孩子', 1),
('fine_motor', '画个圆', '在纸上示范画圆形，让宝宝模仿画封闭的圆', '训练握笔和图形绘制', 36, 42, 3, 10, '纸、蜡笔或彩笔', '先画大圆，能画封闭就大大鼓励', 2),
('language', '讲故事比赛', '给宝宝看绘本，鼓励他自己讲出故事内容或编故事', '培养语言组织和表达能力', 36, 42, 3, 10, '绘本', '讲多少算多少，不要打断和纠正', 1),
('language', '今天和明天', '在睡前聊"今天做了什么"和"明天计划做什么"', '理解时间概念', 36, 42, 2, 5, '无', '用具体事件标注时间，如"午睡后就是下午"', 2),
('adaptation', '数一数', '在生活中数物品：几个苹果？几级台阶？几块积木？', '建立数概念和数量对应', 36, 42, 2, 5, '生活中的物品', '从1-3开始，逐步增加到1-10', 1),
('social', '自己穿衣', '鼓励宝宝自己穿袜子和鞋子，从简单的开始', '培养自理能力和独立性', 36, 42, 2, 15, '衣物', '选择宽松易穿的衣物，留够时间不要催', 1),
('social', '分享时光', '和小朋友一起玩时，引导宝宝分享玩具和轮流玩', '培养社交技能和分享意识', 36, 42, 3, 15, '玩具', '先和自己的家人练习分享，再扩展到其他孩子', 2);

-- ========== 周计划模板 ==========
-- 1岁组 第1周
INSERT INTO weekly_plans (age_group, week_offset, title, description) VALUES
(12, 1, '1岁第1周：站稳第一步', '本周重点训练站立和精细抓握能力');

INSERT INTO weekly_plan_tasks (weekly_plan_id, day_of_week, task_template_id, sort_order)
SELECT 1, 1, id, 1 FROM task_templates WHERE title = '小树站桩' AND age_group_min = 12;
INSERT INTO weekly_plan_tasks (weekly_plan_id, day_of_week, task_template_id, sort_order)
SELECT 1, 1, id, 2 FROM task_templates WHERE title = '捏豆入瓶' AND age_group_min = 12;
INSERT INTO weekly_plan_tasks (weekly_plan_id, day_of_week, task_template_id, sort_order)
SELECT 1, 2, id, 1 FROM task_templates WHERE title = '扶走小勇士' AND age_group_min = 12;
INSERT INTO weekly_plan_tasks (weekly_plan_id, day_of_week, task_template_id, sort_order)
SELECT 1, 2, id, 2 FROM task_templates WHERE title = '这是什么？' AND age_group_min = 12;
INSERT INTO weekly_plan_tasks (weekly_plan_id, day_of_week, task_template_id, sort_order)
SELECT 1, 3, id, 1 FROM task_templates WHERE title = '躲猫猫' AND age_group_min = 12;
INSERT INTO weekly_plan_tasks (weekly_plan_id, day_of_week, task_template_id, sort_order)
SELECT 1, 3, id, 2 FROM task_templates WHERE title = '积木对对碰' AND age_group_min = 12;
INSERT INTO weekly_plan_tasks (weekly_plan_id, day_of_week, task_template_id, sort_order)
SELECT 1, 4, id, 1 FROM task_templates WHERE title = '小树站桩' AND age_group_min = 12;
INSERT INTO weekly_plan_tasks (weekly_plan_id, day_of_week, task_template_id, sort_order)
SELECT 1, 4, id, 2 FROM task_templates WHERE title = '模仿动物叫' AND age_group_min = 12;
INSERT INTO weekly_plan_tasks (weekly_plan_id, day_of_week, task_template_id, sort_order)
SELECT 1, 5, id, 1 FROM task_templates WHERE title = '再见挥手' AND age_group_min = 12;
INSERT INTO weekly_plan_tasks (weekly_plan_id, day_of_week, task_template_id, sort_order)
SELECT 1, 5, id, 2 FROM task_templates WHERE title = '模仿拍手' AND age_group_min = 12;
INSERT INTO weekly_plan_tasks (weekly_plan_id, day_of_week, task_template_id, sort_order)
SELECT 1, 6, id, 1 FROM task_templates WHERE title = '扶走小勇士' AND age_group_min = 12;
INSERT INTO weekly_plan_tasks (weekly_plan_id, day_of_week, task_template_id, sort_order)
SELECT 1, 6, id, 2 FROM task_templates WHERE title = '翻书小达人' AND age_group_min = 12;
INSERT INTO weekly_plan_tasks (weekly_plan_id, day_of_week, task_template_id, sort_order)
SELECT 1, 7, id, 1 FROM task_templates WHERE title = '宝宝在哪里？' AND age_group_min = 12;
INSERT INTO weekly_plan_tasks (weekly_plan_id, day_of_week, task_template_id, sort_order)
SELECT 1, 7, id, 2 FROM task_templates WHERE title = '表情模仿' AND age_group_min = 12;

-- 插入系统配置
INSERT INTO system_configs (key, value, description) VALUES
('app_name', '小树成长', '应用名称'),
('app_version', '1.0.0', '当前版本号'),
('default_checkin_time', '08:00', '默认每日任务推送时间'),
('free_trial_days', '7', '新用户免费试用天数'),
('monthly_price', '29', '月度会员价格（元）'),
('yearly_price', '299', '年度会员价格（元）'),
('max_baby_count', '5', '单个用户最多可添加宝宝数量');
