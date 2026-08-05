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

## 用户卡片背景（已知坑位，修复记录）

Discourse 的用户卡片背景由 core 在**卡片根元素的内联 `background-image`** 上设置，
主题必须满足三个条件背景图才可见：

1. **匿名可见性**：`UserCardSerializer` 默认对 TL0 / 新用户（`hide_new_user_profiles`
   开启时发帖少的用户）隐藏 `card_background_upload_url`。若发现"设置了背景但卡片
   不显示"，先检查：
   - 站点设置 `hide_new_user_profiles`（新用户对匿名隐藏资料）——私人论坛可关闭；
   - 用户 `trust_level`；
   - `allow_users_to_hide_profile` 与用户自身的隐藏资料选项。
   - 若需对所有用户放开（含 TL0 匿名可见），可在服务器容器内给
     `app/serializers/user_card_serializer.rb` 打最小补丁（参考仓库
     `docs/server-patch` 与 runit 持久化脚本，容器重建后自动重打）。
2. **不要用 `background` 简写 + `!important` 覆盖卡片根元素**：主题曾写
   `background: var(--yt-popover) !important`，简写会重置 `background-image`
   并把 core 的内联图覆盖为 `none`。现在只设 `background-color`。
3. **内容区 scrim 不能太厚**：`.card-content` 曾用 70% 白（88% 更甚），背景图
   几乎不可见；现为 **45%** 白，图片清晰可见且文字仍可读。

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
