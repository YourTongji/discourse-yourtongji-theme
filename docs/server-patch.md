# 服务器端补丁：卡片背景匿名可见（runit 持久化）

## 背景

Discourse `UserCardSerializer` 的 `untrusted_attributes` 机制会把
`card_background_upload_url` 对 **TL0 / 新用户 + 匿名访问者**隐藏
（防止新注册用户被游客人肉）。对私人论坛，这表现为"上传了卡片背景却不显示"。

两个更轻量的替代方案（优先使用，无需打补丁）：

1. 关闭站点设置 **`hide_new_user_profiles`**（新用户资料对匿名可见）；
2. 把需要展示背景的用户 trust level 提升到 TL1 及以上（后台可操作）。

如果仍希望**所有用户**（含 TL0）的背景对匿名可见，才需要下面的补丁。

## 补丁内容

在容器内 `app/serializers/user_card_serializer.rb` 末尾（class `end` 之前）追加：

```ruby
# YourTongji theme patch: expose card backgrounds to anonymous viewers
def include_card_background_upload_url?
  card_background_upload_url.present?
end
```

该方法**后定义覆盖** `untrusted_attributes` 宏生成的同名条件方法；
只放开背景图一个字段，`bio_excerpt`、`website`、`location` 等隐私字段保持隐藏。

## 持久化（容器重建自动重打）

官方镜像 `discourse/discourse` 用 runit 管理进程，`/etc/runit/1` 会执行
`/etc/runit/1.d/*`（`run-parts`）。把脚本挂载进该目录，容器每次启动自动重打：

1. 主机放脚本 `data/shared/patch/card-bg-patch`（**文件名不能带 `.` 扩展名**，
   `run-parts` 默认跳过带点的文件）：

```bash
#!/bin/bash
LOG=/var/log/card-bg-patch.log
PATCH_FILE=/var/www/discourse/app/serializers/user_card_serializer.rb
if [ -f "$PATCH_FILE" ] && grep -q "def include_card_background_upload_url?" "$PATCH_FILE"; then
  exit 0
fi
/usr/local/bin/ruby -e '
path = "/var/www/discourse/app/serializers/user_card_serializer.rb"
c = File.read(path)
marker = "    User.allowed_user_custom_fields(scope)\n  end\nend"
override = "  def include_card_background_upload_url?\n    card_background_upload_url.present?\n  end\n"
raise "marker not found" unless c.include?(marker)
c.sub!(marker, marker.sub("\nend", "\n" + override + "end"))
File.write(path, c)
puts "[card-bg-patch] patched"
' >> "$LOG" 2>&1 || echo "[card-bg-patch] FAILED — marker changed in new image" >> "$LOG"
exit 0
```

2. compose 里给 discourse 服务挂载（只读）：

```yaml
volumes:
  - ./data/shared/patch/card-bg-patch:/etc/runit/1.d/99-card-bg-patch:ro
```

3. 升级镜像后如果 serializer 结构变化导致 marker 匹配失败，脚本会记录
   `FAILED` 到 `/var/log/card-bg-patch.log` 而不阻塞启动，需要人工更新脚本。

## 验证

```bash
docker exec Discourse bash -c "grep -n include_card_background_upload_url? /var/www/discourse/app/serializers/user_card_serializer.rb"
curl -s http://<host>:<port>/u/<username>/card.json | python3 -c "import json,sys; print(json.load(sys.stdin)['user'].get('card_background_upload_url'))"
```

（注意 card.json 的字段在 `user` 对象内，不在顶层。）

## 注意事项

- 修改核心代码会随镜像升级丢失，**必须保留 runit 脚本**；
- 只放开背景图字段，不影响其他 untrusted 属性的隐私保护。
