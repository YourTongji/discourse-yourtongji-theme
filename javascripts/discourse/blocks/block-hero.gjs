import Component from "@glimmer/component";
import { block } from "discourse/blocks";
import dIcon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";

/**
 * YourTongji discovery search — a single centered search field, matching the
 * YourTJ-Platform header search: rounded input with a leading magnifier icon,
 * submits to /search on Enter. Rendered into `main-outlet-blocks` on
 * discovery/category/tag pages via `api.renderBlocks` (Discourse 2026 Blocks API).
 */
@block("theme:yourtongji:hero", {
  description: "YourTongji centered search bar",
})
export default class BlockYtHero extends Component {
  get searchPlaceholder() {
    return i18n(themePrefix("hero.search_placeholder"));
  }

  get searchLabel() {
    return i18n(themePrefix("hero.search_label"));
  }

  <template>
    <section class="block-hero">
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
      </form>
    </section>
  </template>
}
