import Component from "@glimmer/component";
import { service } from "@ember/service";
import { block } from "discourse/blocks";
import dIcon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";

/**
 * YourTongji discovery hero.
 * Rendered into `main-outlet-blocks` on discovery/category/tag pages via
 * `api.renderBlocks` (Discourse 2026 Blocks API). Replaces the 3.5
 * connector-based chrome that predated the blocks system.
 */
@block("theme:yourtongji:hero", {
  description:
    "YourTongji hero banner with branding, search, and quick filters",
})
export default class BlockYtHero extends Component {
  @service currentUser;
  @service site;
  @service siteSettings;

  get heroTitle() {
    return this.siteSettings?.title || this.site?.title || "YourTJ Community";
  }

  get heroEyebrow() {
    return i18n(themePrefix("hero.eyebrow"));
  }

  get heroDescription() {
    try {
      if (
        typeof settings !== "undefined" &&
        typeof settings.hero_subtitle === "string" &&
        settings.hero_subtitle.trim().length > 0
      ) {
        return settings.hero_subtitle;
      }
    } catch {
      // settings unavailable outside theme runtime
    }
    return i18n(themePrefix("hero.default_subtitle"));
  }

  get searchPlaceholder() {
    return i18n(themePrefix("hero.search_placeholder"));
  }

  get searchLabel() {
    return i18n(themePrefix("hero.search_label"));
  }

  get searchAction() {
    return i18n(themePrefix("hero.search_action"));
  }

  get filtersLabel() {
    return i18n(themePrefix("hero.filters_label"));
  }

  get quickFilters() {
    const filters = [
      { href: "/top?period=weekly", label: i18n(themePrefix("hero.top_week")) },
      {
        href: "/latest?max_posts=1",
        label: i18n(themePrefix("hero.unanswered")),
      },
    ];

    if (this.currentUser) {
      filters.unshift(
        { href: "/unread", label: i18n(themePrefix("hero.unread")) },
        { href: "/new", label: i18n(themePrefix("hero.new_topics")) }
      );
    }

    return filters;
  }

  <template>
    <section class="block-hero">
      <div class="block-hero__inner">
        <div class="block-hero__copy">
          <span class="block-hero__eyebrow">{{this.heroEyebrow}}</span>
          <h1 class="block-hero__title">{{this.heroTitle}}</h1>
          <p class="block-hero__subtitle">{{this.heroDescription}}</p>
        </div>

        <div class="block-hero__discovery">
          <form
            class="block-hero__search"
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

          <nav class="block-hero__chips" aria-label={{this.filtersLabel}}>
            {{#each this.quickFilters as |filter|}}
              <a class="block-hero__chip" href={{filter.href}}>
                {{filter.label}}
              </a>
            {{/each}}
          </nav>
        </div>
      </div>
    </section>
  </template>
}
