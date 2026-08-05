import Component from "@glimmer/component";
import { service } from "@ember/service";
import { block } from "discourse/blocks";
import AsyncContent from "discourse/components/async-content";
import { bind } from "discourse/lib/decorators";
import { ajax } from "discourse/lib/ajax";
import dIcon from "discourse/helpers/d-icon";
import { add, concat } from "@ember/helper";
import { getOwner } from "@ember/application";
import { i18n } from "discourse-i18n";

/**
 * YourTongji info rail: CTA, who's online, community pulse, top tags and
 * quick links. Rendered into `sidebar-discovery` via `api.renderBlocks`.
 */
@block("theme:yourtongji:info-rail", {
  description: "YourTongji sidebar rail with CTA, pulse, tags and links",
})
export default class BlockYtInfoRail extends Component {
  @service site;
  @service currentUser;

  get askTitle() {
    return i18n(themePrefix("rail.ask_title"));
  }

  get askBody() {
    return i18n(themePrefix("rail.ask_body"));
  }

  get createTopicLabel() {
    return i18n(themePrefix("rail.create_topic"));
  }

  get onlineTitle() {
    return i18n(themePrefix("rail.online_title"));
  }

  get pulseTitle() {
    return i18n(themePrefix("rail.pulse_title"));
  }

  get tagsTitle() {
    return i18n(themePrefix("rail.tags_title"));
  }

  get hotTitle() {
    return i18n(themePrefix("rail.hot_title"));
  }

  get hotLinkLabel() {
    return i18n(themePrefix("rail.hot_link"));
  }

  get allTagsLabel() {
    return i18n(themePrefix("rail.all_tags"));
  }

  get linksTitle() {
    return i18n(themePrefix("rail.links_title"));
  }

  get railLinks() {
    let configured = [];
    try {
      if (typeof settings !== "undefined") {
        configured = (settings.rail_links || []).filter(
          (link) => link.label && safeHref(link.url)
        );
      }
    } catch {
      configured = [];
    }

    if (configured.length) {
      return configured.map((link) => ({
        label: link.label,
        href: link.url,
      }));
    }

    return [
      { label: i18n(themePrefix("rail.all_categories")), href: "/categories" },
      { label: i18n(themePrefix("rail.about")), href: "/about" },
    ];
  }

  get topTags() {
    const tags =
      this.site?.top_tags || this.site?.navigation_menu_site_top_tags || [];

    return tags
      .map((tag) => {
        const name =
          typeof tag === "string" ? tag : tag?.name || tag?.id || tag?.text;
        return name
          ? { name: `${name}`, href: `/tag/${encodeURIComponent(name)}` }
          : null;
      })
      .filter(Boolean)
      .slice(0, 12);
  }

  get onlineUsers() {
    try {
      const onlineService = getOwner(this).lookup("service:whos-online");
      const users = onlineService?.users || [];
      return users.slice(0, 14).map((user) => ({
        username: user.username,
        avatarSrc: avatarUrl(user.avatar_template, "48"),
      }));
    } catch {
      return [];
    }
  }

  get onlineCount() {
    try {
      const onlineService = getOwner(this).lookup("service:whos-online");
      return onlineService?.count ?? this.onlineUsers.length;
    } catch {
      return this.onlineUsers.length;
    }
  }

  @bind
  async fetchPulse() {
    const data = await ajax("/about.json");
    const stats = data?.about?.stats;
    if (!stats) {
      return [];
    }

    return [
      {
        icon: "fire",
        value: stats.posts_last_day ?? 0,
        label: i18n(themePrefix("rail.posts_today")),
      },
      {
        icon: "plus",
        value: stats.topics_last_day ?? 0,
        label: i18n(themePrefix("rail.topics_today")),
      },
      {
        icon: "users",
        value: stats.active_users_7_days ?? 0,
        label: i18n(themePrefix("rail.active_week")),
      },
    ];
  }

  @bind
  async fetchHotTopics() {
    const data = await ajax("/top.json", { data: { period: "weekly" } });
    const topics = data?.topic_list?.topics || [];
    return topics.slice(0, 5).map((topic) => ({
      title: topic.title,
      href: `/t/${topic.slug}/${topic.id}`,
      heat: topic.like_count ?? topic.posts_count ?? 0,
    }));
  }

  <template>
    <div class="block-rail">
      <div class="block-rail-cta">
        <h4 class="block-rail-cta__title">{{this.askTitle}}</h4>
        <p class="block-rail-cta__body">{{this.askBody}}</p>
        <a class="btn btn-primary" href="/new-topic">
          {{dIcon "plus"}}
          <span>{{this.createTopicLabel}}</span>
        </a>
      </div>

      {{#if this.onlineUsers.length}}
        <div class="block-rail-online">
          <h4 class="block-rail-online__title">
            <span>{{this.onlineTitle}}</span>
            <span class="block-rail-online__count">{{this.onlineCount}}</span>
          </h4>
          <div class="block-rail-online__avatars">
            {{#each this.onlineUsers as |user|}}
              <a
                class="block-rail-online__user"
                href={{concat "/u/" user.username}}
                data-user-card={{user.username}}
                title={{user.username}}
              >
                <img
                  class="avatar"
                  src={{user.avatarSrc}}
                  alt=""
                  width="28"
                  height="28"
                  loading="lazy"
                />
              </a>
            {{/each}}
          </div>
        </div>
      {{/if}}

      <AsyncContent @asyncData={{this.fetchHotTopics}}>
        <:loading><div class="spinner" /></:loading>
        <:empty></:empty>
        <:content as |topics|>
          {{#if topics.length}}
            <div class="block-rail-hot">
              <h4 class="block-rail-hot__title">
                {{dIcon "flame"}}
                <span>{{this.hotTitle}}</span>
              </h4>
              <ol class="block-rail-hot__list">
                {{#each topics as |topic index|}}
                  <li class="block-rail-hot__item">
                    <span class="block-rail-hot__rank">{{add index 1}}</span>
                    <a class="block-rail-hot__topic" href={{topic.href}}>
                      <span class="block-rail-hot__title-text">
                        {{topic.title}}
                      </span>
                      <span class="block-rail-hot__heat">
                        {{dIcon "flame"}}
                        {{topic.heat}}
                      </span>
                    </a>
                  </li>
                {{/each}}
              </ol>
              <a class="block-rail-hot__all" href="/top">
                <span>{{this.hotLinkLabel}}</span>
                {{dIcon "arrow-right"}}
              </a>
            </div>
          {{/if}}
        </:content>
      </AsyncContent>

      <AsyncContent @asyncData={{this.fetchPulse}}>
        <:loading><div class="spinner" /></:loading>
        <:empty></:empty>
        <:content as |items|>
          {{#if items.length}}
            <div class="block-rail-stats">
              <h4 class="block-rail-stats__title">{{this.pulseTitle}}</h4>
              <ul class="block-rail-stats__list">
                {{#each items as |item|}}
                  <li>
                    <span class="block-rail-stats__icon">
                      {{dIcon item.icon}}
                    </span>
                    <span class="block-rail-stats__value">{{item.value}}</span>
                    <span class="block-rail-stats__label">{{item.label}}</span>
                  </li>
                {{/each}}
              </ul>
            </div>
          {{/if}}
        </:content>
      </AsyncContent>

      {{#if this.topTags.length}}
        <div class="block-rail-tags">
          <h4 class="block-rail-tags__title">{{this.tagsTitle}}</h4>
          <div class="block-rail-tags__cloud">
            {{#each this.topTags as |tag|}}
              <a class="block-rail-tags__tag" href={{tag.href}}>
                {{tag.name}}
              </a>
            {{/each}}
          </div>
          <a class="block-rail-tags__all" href="/tags">
            <span>{{this.allTagsLabel}}</span>
            {{dIcon "arrow-right"}}
          </a>
        </div>
      {{/if}}

      <div class="block-rail-links">
        <h4 class="block-rail-links__title">{{this.linksTitle}}</h4>
        <ul class="block-rail-links__list">
          {{#each this.railLinks as |link|}}
            <li>
              <a href={{link.href}}>
                {{dIcon "arrow-right"}}
                <span>{{link.label}}</span>
              </a>
            </li>
          {{/each}}
        </ul>
      </div>
    </div>
  </template>
}

function safeHref(href) {
  return (
    typeof href === "string" &&
    (href.startsWith("/") ||
      href.startsWith("https://") ||
      href.startsWith("http://"))
  );
}

function avatarUrl(avatarTemplate, size = "48") {
  if (!avatarTemplate || typeof avatarTemplate !== "string") {
    return "";
  }
  return avatarTemplate.replace(/\{size\}/g, String(size));
}
