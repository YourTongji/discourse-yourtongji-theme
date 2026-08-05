import { apiInitializer } from "discourse/lib/api";

/**
 * Expand pinned/excerpt rows when the theme setting is on.
 * Defensive: registerValueTransformer exists on Discourse 3.2+;
 * if unavailable, serialize_topic_excerpts modifier + CSS still show excerpts.
 */
export default apiInitializer((api) => {
  try {
    if (!settings.show_topic_excerpts) {
      return;
    }
  } catch {
    return;
  }

  if (typeof api.registerValueTransformer === "function") {
    api.registerValueTransformer("topic-list-item-expand-pinned", () => true);
  }
});
