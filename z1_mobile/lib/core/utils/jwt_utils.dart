import 'dart:convert';

/// 解码 JWT 的 payload 段（不校验签名，仅用于读取本地已持有 token 的声明）。
///
/// z1 后端的 access token payload 形如：
/// `{ "iss": "z1-deno", "exp": ..., "user": "999999999", "deptID": 35 }`
/// 解析失败返回 null。
Map<String, dynamic>? decodeJwtPayload(String? token) {
  if (token == null || token.isEmpty) return null;
  var raw = token;
  // 容错：去掉可能的 "Bearer " 前缀
  if (raw.startsWith('Bearer ')) raw = raw.substring(7);
  final parts = raw.split('.');
  if (parts.length != 3) return null;
  try {
    var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
    // base64 补齐
    payload = payload.padRight((payload.length + 3) ~/ 4 * 4, '=');
    final decoded = utf8.decode(base64.decode(payload));
    final map = jsonDecode(decoded);
    return map is Map<String, dynamic> ? map : null;
  } catch (_) {
    return null;
  }
}

/// 从 access token 中读取员工主部门 ID（payload.deptID）。
int? deptIDFromToken(String? token) {
  final payload = decodeJwtPayload(token);
  final v = payload?['deptID'];
  if (v is int) return v;
  if (v is String) return int.tryParse(v);
  return null;
}
