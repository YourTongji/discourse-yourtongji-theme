# Contributing

Thank you for helping improve the YourTongji Discourse theme.

## Development workflow

1. Fork the repository and create a focused branch.
2. Install dependencies with `pnpm install --frozen-lockfile`.
3. Prefer changing design tokens in `stylesheets/brand/tokens.scss` before page-specific overrides.
4. Keep visual language aligned with YourTJ Platform light tokens (teal `#009688`, soft cards, no neon purple/blue).
5. Run `pnpm lint`.
6. Preview affected Discourse pages on desktop and mobile in the light color scheme.
7. Open a pull request describing the behavior change and validation performed.

Do not commit Discourse API keys, local credentials, screenshots containing private data, generated QA artifacts, or editor-specific files.

## Bug reports

Include the Discourse version, browser and device, theme commit, affected URL type, color scheme, authentication state, reproduction steps, and screenshots when appropriate.
