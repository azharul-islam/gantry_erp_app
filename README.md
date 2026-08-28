# Gantry Whitelabel

White-label Frappe/ERPNext app for the Gantry demo site: removes the
"Powered by ERPNext" footer text and layers the Gantry brand
(colours/fonts from the landing site design language) over the ERPNext
website and desk. Built for Frappe v16 / ERPNext v16.

## What's in the foundation

- **Powered-by removal (visible footer text)** — `gantry_whitelabel/templates/includes/footer/footer_info.html`
  overrides Frappe's `templates/includes/footer/footer_info.html`. App
  templates load before frappe's, so this file wins and the
  "Built on Frappe / Powered by ERPNext" line is gone from every web
  page (verified on the homepage and the login page).
- **Brand CSS layer** — `gantry_whitelabel/public/css/whitelabel.css`,
  wired into both the desk and the website via hooks.py:
  - `app_include_css` → loaded in the desk (desk.html)
  - `web_include_css` → loaded on every website page
  It carries the Gantry design tokens 1:1 from
  `gantry-landing/src/routes/layout.css` (`--gantry-*` variables, Plus
  Jakarta Sans / JetBrains Mono font stack) plus a deliberately small
  first pass. The deeper styling pass (navbar/button colours, login
  page, desk accents) is itemised in the TODO block at the bottom of
  the CSS file.

## Local development

```bash
cd /Users/azhar/Projects/gantry/gantry-erp   # the bench
bench --site gantry.localhost install-app gantry_whitelabel
bench build --app gantry_whitelabel          # after changing CSS/JS
bench restart                                 # after changing Python/hooks
```

Changes to `public/css/*.css` are picked up by `bench build --app gantry_whitelabel`
(dev: assets are served via `bench watch` / dev mode).

## Deploying to the hosted demo

The app must be a git repo with a remote (bench apps are per-app git
repos — this one lives at `apps/gantry_whitelabel` inside the bench).

1. Create a GitHub repo (e.g. `gantry/gantry_whitelabel`) and push this
   folder to a `version-16` branch.
2. **If the demo runs on Frappe Cloud** — open the site → *Install Apps*
   → paste the GitHub repo URL (install from GitHub, not the
   marketplace). Frappe Cloud clones it, installs it on the site and
   rebuilds assets.
3. **If the demo is self-hosted** — on the demo server's bench:

   ```bash
   bench get-app https://github.com/gantry/gantry_whitelabel.git --branch version-16
   bench --site <demo-site> install-app gantry_whitelabel
   bench build && bench restart
   ```

## Contributing

This app uses `pre-commit` for code formatting and linting. Please
[install pre-commit](https://pre-commit.com/#installation) and enable it:

```bash
cd apps/gantry_whitelabel
pre-commit install
```

Pre-commit is configured to use: ruff, eslint, prettier, pyupgrade.

## Still to do (next iterations)

- Deeper styling pass per the TODO block in `whitelabel.css` (brand
  primary colour, login page, desk accents, real font loading).
- Optional: strip the invisible `<!-- Built on Frappe ... -->` source
  comment emitted by `frappe/templates/base.html` (visible only in
  "view source"; not rendered).
- Decide whether the ury POS frontends (React/Vue, separately bundled)
  need their own brand pass — the ERPNext web/desk layer is covered by
  this app.

## License

MIT
