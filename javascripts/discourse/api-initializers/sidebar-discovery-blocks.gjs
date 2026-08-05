import { apiInitializer } from "discourse/lib/api";
import BlockYtInfoRail from "../blocks/block-info-rail";

/**
 * Renders the YourTongji info rail (CTA, pulse, tags, links) into the
 * discovery sidebar on list pages.
 */
export default apiInitializer((api) => {
  api.renderBlocks("sidebar-discovery", [
    {
      block: BlockYtInfoRail,
      id: "yourtongji-info-rail",
      conditions: [
        {
          type: "setting",
          source: settings,
          name: "show_info_rail",
          enabled: true,
        },
        { type: "viewport", min: "xl" },
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
