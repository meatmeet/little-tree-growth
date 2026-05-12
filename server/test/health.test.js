import { describe, it, before } from 'node:test';
import assert from 'node:assert';

describe('Server Health', () => {
  let queryOne;

  before(async () => {
    const db = await import('../src/config/db.js');
    queryOne = db.queryOne;
  });

  it('should have demo user seeded', () => {
    const user = queryOne('SELECT phone FROM users WHERE id = 1');
    assert.ok(user, 'demo user should exist');
    assert.strictEqual(user.phone, '13800138000');
  });

  it('should have demo baby seeded', () => {
    const baby = queryOne('SELECT name FROM babies WHERE id = 1');
    assert.ok(baby, 'demo baby should exist');
    assert.strictEqual(baby.name, '小树');
  });

  it('should have growth standards seeded', () => {
    const count = queryOne('SELECT COUNT(*) as c FROM growth_standards');
    assert.ok(count.c > 0, 'growth standards should be seeded');
  });
});
