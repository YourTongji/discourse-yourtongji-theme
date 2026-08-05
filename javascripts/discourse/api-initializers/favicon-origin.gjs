import { apiInitializer } from "discourse/lib/api";

/**
 * Rewrite absolute favicon links to same-origin relative paths.
 * Discourse renders them with the configured hostname (dc-dev.yourtj.de);
 * when the site is visited via a raw IP that absolute URL cannot load, so
 * the tab icon stays blank. Rewriting keeps icon + apple-touch-icon working
 * on any origin.
 */
export default apiInitializer((api) => {
  document
    .querySelectorAll('link[rel="icon"], link[rel="apple-touch-icon"]')
    .forEach((link) => {
      try {
        const href = link.getAttribute("href") || "";
        if (href.startsWith("http://") || href.startsWith("https://")) {
          const url = new URL(href);
          link.href = url.pathname + (url.search || "");
        }
      } catch {
        // ignore malformed hrefs
      }
    });
});
