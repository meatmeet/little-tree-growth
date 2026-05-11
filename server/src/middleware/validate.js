import { fail } from '../utils/response.js';

export function validate(schema) {
  return (req, res, next) => {
    const errors = [];
    for (const [field, rules] of Object.entries(schema)) {
      const value = req.body[field];
      if (rules.required && (value === undefined || value === null || value === '')) {
        errors.push(`${field}: ${rules.message || '必填'}`);
        continue;
      }
      if (value !== undefined && value !== null) {
        if (rules.type === 'number' && typeof value !== 'number') {
          errors.push(`${field}: 必须为数字`);
        }
        if (rules.type === 'string' && typeof value !== 'string') {
          errors.push(`${field}: 必须为字符串`);
        }
        if (rules.min !== undefined && value < rules.min) {
          errors.push(`${field}: 不能小于${rules.min}`);
        }
        if (rules.max !== undefined && value > rules.max) {
          errors.push(`${field}: 不能大于${rules.max}`);
        }
        if (rules.enum && !rules.enum.includes(value)) {
          errors.push(`${field}: 无效的值`);
        }
      }
    }
    if (errors.length > 0) {
      return res.status(400).json(fail(errors.join('; ')));
    }
    next();
  };
}
