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

## Deploying to the demo (demo.gantry.online)

The demo runs as a Coolify compose service (`erpnext-demo`) on
coolify.gantry.online. All ERPNext containers use the stock
`frappe/erpnext:v16.32.3` image; the app is cloned at runtime from this
repo (public: `azharul-islam/gantry_erp_app`, branch `version-16`) into
the shared `sites/` volume and symlinked into `apps/` by the compose
`init` container. `init` then regenerates `apps.txt`, installs the app
if missing, copies its static assets into `sites/assets/`, and re-takes
the clean snapshot — which is what the nightly 03:00 reset restores, so
the white label survives resets by design.

Full cycle for a change:

1. Commit + push to `version-16` (no CI needed — nothing builds).
2. Redeploy the demo compose: `.ssh_demo/deploy-whitelabel.sh` PATCHes
   Coolify with `compose.v20.yaml` (base64 `docker_compose_raw`), then
   restart the service (`coolify service restart`) — the PATCH only
   updates the definition; the restart applies it and re-runs `init`
   (which pulls the latest app code, rebuilds assets, re-snapshots).
3. Verify: `.ssh_demo/verify-whitelabel.sh` + the manual checks below.

Manual notes:

- The compose and deploy tooling live in `gantry-landing/.ssh_demo/`
  (handover + recipe in `gantry-landing/docs/`).
- Coolify quirk: `PATCH + instant_deploy` updates the compose but does
  not recreate containers in this Coolify version — always follow the
  PATCH with a service restart.
- `bench build` does not work in the container (no esbuild), so `init`
  copies `public/` → `sites/assets/gantry_whitelabel/` directly — which
  is all `bench build` would do for this CSS-only app.
- The `Dockerfile` in this repo documents the alternative image-based
  route (useful if the demo ever needs it), but it is not used by the
  current deploy.
- If the demo is ever moved off Coolify: plain bench deploy works too —
  `bench get-app` from this repo, install, build, restart.

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
