import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { concat } from "@ember/helper";
import { getOwner } from "@ember/application";
import { ajax } from "discourse/lib/ajax";
import dIcon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";

/**
 * Discourse 3.5-compatible discovery chrome (hero + info rail).
 * Replaces the 2026.6+ Blocks API path that crashes on Bitnami Discourse 3.5.0.
 *
 * `settings` and `themePrefix` are injected by the Discourse theme JS compiler.
 */

function themeKey(key) {
  try {
    if (typeof themePrefix === "function") {
      return themePrefix(key);
    }
  } catch {
    // themePrefix unavailable during local tooling
  }
  return key;
}

function translate(key) {
  return i18n(themeKey(key));
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

export default class YtDiscoveryChrome extends Component {
  static shouldRender(_args, context) {
    try {
      // Prefer settings when available; always allow render otherwise.
      if (typeof settings !== "undefined") {
        return !!(settings.show_hero || settings.show_info_rail);
      }
    } catch {
      // ignore
    }
    return true;
  }

  @service currentUser;
  @service site;
  @service siteSettings;
  @service router;

  @tracked pulseItems = [];

  constructor() {
    super(...arguments);
    try {
      if (typeof settings !== "undefined" && settings.show_info_rail) {
        this.loadPulseStats();
      }
    } catch {
      // settings may be unavailable outside theme runtime
    }
  }

  get showHero() {
    try {
      if (typeof settings !== "undefined" && !settings.show_hero) {
        return false;
      }
    } catch {
      // continue
    }
    return this.isDiscoveryList;
  }

  get showRail() {
    try {
      if (typeof settings !== "undefined" && !settings.show_info_rail) {
        return false;
      }
    } catch {
      return false;
    }
    return this.isDiscoveryList;
  }

  get isDiscoveryList() {
    const currentUrl = this.router?.currentURL || "";
    if (currentUrl.startsWith("/categories")) {
      return false;
    }
    return (
      currentUrl === "/" ||
      currentUrl === "" ||
      currentUrl.startsWith("/latest") ||
      currentUrl.startsWith("/top") ||
      currentUrl.startsWith("/new") ||
      currentUrl.startsWith("/unread") ||
      currentUrl.startsWith("/hot") ||
      currentUrl.startsWith("/c/") ||
      currentUrl.startsWith("/tag/")
    );
  }

  get heroTitle() {
    return this.siteSettings?.title || this.site?.title || "YourTJ Community";
  }

  get heroDescription() {
    try {
      if (typeof settings !== "undefined") {
        const configured = settings.hero_subtitle;
        if (typeof configured === "string" && configured.trim().length > 0) {
          return configured;
        }
      }
    } catch {
      // fall through
    }
    return translate("hero.default_subtitle");
  }

  get heroEyebrow() {
    return translate("hero.eyebrow");
  }

  get searchPlaceholder() {
    return translate("hero.search_placeholder");
  }

  get searchLabel() {
    return translate("hero.search_label");
  }

  get searchAction() {
    return translate("hero.search_action");
  }

  get filtersLabel() {
    return translate("hero.filters_label");
  }

  get askTitle() {
    return translate("rail.ask_title");
  }

  get askBody() {
    return translate("rail.ask_body");
  }

  get createTopicLabel() {
    return translate("rail.create_topic");
  }

  get onlineTitle() {
    return translate("rail.online_title");
  }

  get pulseTitle() {
    return translate("rail.pulse_title");
  }

  get tagsTitle() {
    return translate("rail.tags_title");
  }

  get allTagsLabel() {
    return translate("rail.all_tags");
  }

  get linksTitle() {
    return translate("rail.links_title");
  }

  get quickFilters() {
    const filters = [
      { href: "/top?period=weekly", label: translate("hero.top_week") },
      { href: "/latest?max_posts=1", label: translate("hero.unanswered") },
    ];

    if (this.currentUser) {
      filters.unshift(
        { href: "/unread", label: translate("hero.unread") },
        { href: "/new", label: translate("hero.new_topics") }
      );
    }

    return filters;
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
      {
        label: translate("rail.all_categories"),
        href: "/categories",
      },
      {
        label: translate("rail.about"),
        href: "/about",
      },
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

  async loadPulseStats() {
    try {
      const data = await ajax("/about.json");
      const stats = data?.about?.stats;
      if (!stats) {
        this.pulseItems = [];
        return;
      }

      this.pulseItems = [
        {
          icon: "fire",
          value: stats.posts_last_day ?? 0,
          label: translate("rail.posts_today"),
        },
        {
          icon: "plus",
          value: stats.topics_last_day ?? 0,
          label: translate("rail.topics_today"),
        },
        {
          icon: "users",
          value: stats.active_users_7_days ?? 0,
          label: translate("rail.active_week"),
        },
      ];
    } catch {
      this.pulseItems = [];
    }
  }

  <template>
    <div class="yt-discovery-chrome">
      {{#if this.showHero}}
        <section class="yt-hero block-hero">
          <div class="yt-hero__inner block-hero__inner">
            <div class="yt-hero__copy block-hero__copy">
              <span class="yt-hero__eyebrow block-hero__eyebrow">
                {{this.heroEyebrow}}
              </span>
              <h1 class="yt-hero__title block-hero__title">
                {{this.heroTitle}}
              </h1>
              <p class="yt-hero__subtitle block-hero__subtitle">
                {{this.heroDescription}}
              </p>
            </div>

            <div class="yt-hero__discovery block-hero__discovery">
              <form
                class="yt-hero__search block-hero__search"
                action="/search"
                method="get"
                role="search"
              >
                {{dIcon "magnifying-glass"}}
                <input
                  type="search"
                  name="q"
                  placeholder={{this.searchPlaceholder}}
                  aria-label={{this.searchLabel}}
                  autocomplete="off"
                />
                <button type="submit" class="btn btn-primary">
                  {{this.searchAction}}
                </button>
              </form>

              <nav
                class="yt-hero__chips block-hero__chips"
                aria-label={{this.filtersLabel}}
              >
                {{#each this.quickFilters as |filter|}}
                  <a
                    class="yt-hero__chip block-hero__chip"
                    href={{filter.href}}
                  >
                    {{filter.label}}
                  </a>
                {{/each}}
              </nav>
            </div>
          </div>
        </section>
      {{/if}}

      {{#if this.showRail}}
        <aside class="yt-info-rail" aria-label={{this.linksTitle}}>
          <div class="yt-info-rail__inner">
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
                  <span class="block-rail-online__count">
                    {{this.onlineCount}}
                  </span>
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

            {{#if this.pulseItems.length}}
              <div class="block-rail-stats">
                <h4 class="block-rail-stats__title">{{this.pulseTitle}}</h4>
                <ul class="block-rail-stats__list">
                  {{#each this.pulseItems as |item|}}
                    <li>
                      <span class="block-rail-stats__icon">
                        {{dIcon item.icon}}
                      </span>
                      <span class="block-rail-stats__value">
                        {{item.value}}
                      </span>
                      <span class="block-rail-stats__label">
                        {{item.label}}
                      </span>
                    </li>
                  {{/each}}
                </ul>
              </div>
            {{/if}}

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
        </aside>
      {{/if}}
    </div>
  </template>
}
