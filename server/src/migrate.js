import fs from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { query } from './config/db.js';

const __dirname = dirname(fileURLToPath(import.meta.url));

async function migrate() {
  console.log('🔄 开始数据库迁移...');

  // Read and execute schema
  const schemaPath = join(__dirname, '../../database/schema.sql');
  const schema = fs.readFileSync(schemaPath, 'utf-8');

  // Split by semicolons and execute each statement
  const statements = schema
    .split(';')
    .map(s => s.trim())
    .filter(s => s.length > 0 && !s.startsWith('--'));

  for (const stmt of statements) {
    try {
      await query(stmt);
      console.log('  ✓ 执行成功');
    } catch (err) {
      if (err.message.includes('already exists')) {
        console.log('  - 已存在，跳过');
      } else {
        console.error(`  ✗ 失败: ${err.message}`);
        console.error(`     SQL: ${stmt.substring(0, 100)}...`);
      }
    }
  }

  console.log('✅ 数据库迁移完成');
  process.exit(0);
}

migrate().catch(err => {
  console.error('❌ 迁移失败:', err.message);
  process.exit(1);
});
