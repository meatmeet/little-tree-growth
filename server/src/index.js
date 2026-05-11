import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import path, { dirname } from 'path';
import { fileURLToPath } from 'url';
import { initDb } from './config/db.js';
import authRoutes from './routes/auth.js';
import userRoutes from './routes/users.js';
import babyRoutes from './routes/babies.js';
import assessmentRoutes from './routes/assessments.js';
import taskRoutes from './routes/tasks.js';
import checkinRoutes from './routes/checkin.js';
import growthRoutes from './routes/growth.js';
import milestoneRoutes from './routes/milestones.js';
import courseRoutes from './routes/courses.js';
import subscriptionRoutes from './routes/subscriptions.js';
import statsRoutes from './routes/stats.js';

const __dirname = dirname(fileURLToPath(import.meta.url));
const app = express();
const PORT = parseInt(process.env.PORT || '8000');

// Init SQLite DB
initDb();

// Middleware
app.use(helmet({ crossOriginResourcePolicy: false }));
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Request logging
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const elapsed = Date.now() - start;
    if (elapsed > 500) console.warn(`[SLOW] ${req.method} ${req.path} ${res.statusCode} ${elapsed}ms`);
  });
  next();
});

// Serve prototype frontend
const prototypeDir = path.join(__dirname, '../../prototype');
app.use(express.static(prototypeDir));

// Health check
app.get('/api/health', (req, res) => {
  res.json({ code: 0, message: 'ok', data: { status: 'running', version: '1.0.0', time: new Date().toISOString() } });
});

// API v1 routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/user', userRoutes);
app.use('/api/v1/babies', babyRoutes);
app.use('/api/v1/assessments', assessmentRoutes);
app.use('/api/v1/tasks', taskRoutes);
app.use('/api/v1/checkin', checkinRoutes);
app.use('/api/v1/growth-records', growthRoutes);
app.use('/api/v1/milestones', milestoneRoutes);
app.use('/api/v1/courses', courseRoutes);
app.use('/api/v1/subscriptions', subscriptionRoutes);
app.use('/api/v1/stats', statsRoutes);

// 404 for API
app.use('/api/*', (req, res) => {
  res.status(404).json({ code: 404, message: '接口不存在', data: null });
});

// Serve frontend for non-API routes
app.get('*', (req, res) => {
  res.sendFile(path.join(prototypeDir, 'screens_v2.html'));
});

// Error handler
app.use((err, req, res, _next) => {
  console.error('[ERROR]', err.message);
  const status = err.statusCode || 500;
  res.status(status).json({ code: status, message: err.message || '服务器内部错误', data: null });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🌱 小树成长 已启动`);
  console.log(`   💻 本地:   http://localhost:${PORT}`);
  console.log(`   🔗 API:    http://localhost:${PORT}/api/health`);
  console.log(`   📱 手机访问: http://<本机IP>:${PORT}`);
});

export default app;
