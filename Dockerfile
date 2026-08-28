# Gantry demo image — frappe/erpnext + gantry_whitelabel app.
# All ERPNext services in the demo compose run this image, so the
# white-label app (hooks, footer template override, Python) is available
# in every container. Assets are built at runtime by the `init` container
# (`bench build --app gantry_whitelabel`) because the shared `sites/`
# volume shadows anything baked under sites/ at image build time.
FROM frappe/erpnext:v16.32.3

USER root
COPY gantry_whitelabel /home/frappe/frappe-bench/apps/gantry_whitelabel
RUN chown -R frappe:frappe /home/frappe/frappe-bench/apps/gantry_whitelabel

USER frappe
