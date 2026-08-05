import { apiInitializer } from "discourse/lib/api";
import BlockYtHero from "../blocks/block-hero";

/**
 * Renders the YourTongji hero into the discovery main outlet
 * (homepage, latest/top/new/unread, categories and tags).
 */
export default apiInitializer((api) => {
  api.renderBlocks("main-outlet-blocks", [
    {
      block: BlockYtHero,
      id: "yourtongji-hero",
      conditions: [
        {
          type: "setting",
          source: settings,
          name: "show_hero",
          enabled: true,
        },
        {
          any: [
            { type: "route", pages: ["HOMEPAGE"] },
            { type: "route", pages: ["DISCOVERY_PAGES"] },
            { type: "route", pages: ["CATEGORY_PAGES"] },
            { type: "route", pages: ["TAG_PAGES"] },
          ],
        },
      ],
    },
  ]);
});
