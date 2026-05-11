export function success(data = null, message = 'ok') {
  return { code: 0, message, data };
}

export function fail(message = '请求失败', code = -1) {
  return { code, message, data: null };
}

export function notFound(message = '资源不存在') {
  return { code: 404, message, data: null };
}

export function unauthorized(message = '未登录或登录已过期') {
  return { code: 401, message, data: null };
}

export function forbidden(message = '无权限访问') {
  return { code: 403, message, data: null };
}
