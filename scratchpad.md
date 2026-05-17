
## 2026-05-15 Session Notes

### z1_mobile 项目关键点
- **后端 API 格式**: 返回 `{code, res: {token}}` 而非 `{access_token}`，需要在前端手动映射
- **路由**: 使用 `go_router` 而非 Navigator，导航用 `context.go('/path')`
- **iOS 图标**: 必须用 sips 工具生成正确尺寸的 PNG（sips -z W H source --out dest）
- **登录成功处理**: AuthBloc.emit(AuthAuthenticated) 后，LoginPage 需要在 BlocListener 中处理跳转

### 用户信息
- 用户: 李英俊
- 项目: z1-nextapp/z1_mobile (掌上高远)
