# YourTongji Discourse Theme

基于 [YourTJ Platform](https://github.com/YourTongji/YourTJ-Platform) 浅色设计语言的 Discourse 全主题。

结构与工程脚手架参考 [0niel/discourse-flat-theme](https://github.com/0niel/discourse-flat-theme)（MIT），视觉与组件映射对齐 Platform Web（茶绿主色、卡片信息流、顶栏/侧栏/帖子卡/个人页）。

> **本阶段交付范围**：仓库与浅色主题代码。安装到生产/开发 Discourse 实例需另行操作。深色 scheme 暂未提供。

## 设计对照（Platform → Discourse）

| Platform | 值 / 组件 | Discourse |
| --- | --- | --- |
| primary | `#009688` | tertiary / accent |
| background | `#f8faf8` | page background |
| card | `#f2f4f2` | topic cards / surfaces |
| border | `#e1e3e1` | hairlines |
| radius | `0.75rem` | `ui_radius` + card radius |
| AppLayout header | h-16, blur, pill search | `header.scss` |
| CommunityFeed card | rounded-xl, hover `#eef1ef` | `topic-list.scss` |
| SiteSidebar active | muted + primary text | `sidebar.scss` |
| profile / thread | cards + teal avatar ring | `profile` / `posts` / `topic` |

未在 Platform 出现的页面（Admin、Chat、Review 等）沿用同一 token 与 design-taste 约束补全，不引入紫蓝霓虹风。

## 安装

在 Discourse：**管理 → 外观 → 主题 → 安装**，Git 地址：

```text
https://github.com/YourTongji/discourse-yourtongji-theme
```

或使用官方 [`discourse_theme`](https://meta.discourse.org/t/install-the-discourse-theme-cli-console-app-to-help-you-build-themes/82950) CLI。

启用后选择 color scheme **YourTongji Light**。

### 兼容性说明

- 目标运行时：**Discourse 2026.6+**（官方 `discourse/discourse` 镜像，已实测 2026.7.1）。
- `about.json` 中 `minimum_discourse_version` 为 **2026.6.0**；`theme_version` 当前 **1.2.0**。
- 使用官方 **Blocks API**（`api.renderBlocks` / `discourse/blocks` / `@block` 装饰器）：
  - Hero（居中搜索框）渲染到 `main-outlet-blocks`
  - 信息侧栏（发帖 CTA / 今日热榜 / 社区动态 / 热门标签 / 快捷链接）渲染到 `sidebar-discovery`
- 布局通过官方 `discovery-layout__content` 双栏 + `viewport` 条件（侧栏仅在 ≥1280px 显示）。
- 页面级 `overflow-x: clip` 兜底，避免任何瞬时超宽元素产生横向滚动条。

## 主题设置

| Setting | 说明 |
| --- | --- |
| `show_hero` | 发现页居中搜索框 |
| `show_info_rail` | 宽屏（≥1280px）信息侧栏 |
| `rail_links` | 侧栏快捷链接 |
| `show_topic_excerpts` | 列表摘要 |
| `accent_color` | 强调色覆盖（默认 `#009688`） |
| `content_max_width` | 主栏最大宽度（默认 1280） |
| `ui_radius` | 圆角倍率（默认 1.05） |

## 开发

```bash
pnpm install --frozen-lockfile
pnpm lint
discourse_theme watch .
```

```text
about.json
settings.yml
common/common.scss          # 入口
stylesheets/brand/tokens.scss
stylesheets/app/
stylesheets/blocks/
javascripts/discourse/
locales/zh_CN.yml
locales/en.yml
assets/icon.png
```

## 人工预览清单

- [ ] `/latest` 卡片列表与 hover
- [ ] `/categories`
- [ ] 话题详情与 composer
- [ ] 用户主页 / 用户卡片
- [ ] 搜索、通知、登录
- [ ] 移动端 DOM（`mobile/mobile.scss`）
- [ ] `/safe-mode` 回退

## License

[MIT](LICENSE) — YourTongji；衍生自 Oniel's Flat Theme（MIT）。
