FROM docker.io/bitnami/odoo:18
USER root

RUN pip3 install --no-cache-dir factur-x PyPDF2

RUN git clone --depth 1 https://github.com/OCA/edi.git /tmp/edi \
 && cp -a /tmp/edi/account_einvoice_generate /opt/bitnami/odoo/addons/ \
 && cp -a /tmp/edi/base_factur_x         /opt/bitnami/odoo/addons/ \
 && cp -a /tmp/edi/account_invoice_facturx /opt/bitnami/odoo/addons/ \
 && rm -rf /tmp/edi

# 3) Dateirechte anpassen (optional, wenn du auf Probleme stößt)
# RUN chown -R 1001:0 /opt/bitnami/odoo/addons/account_* \
#  && chmod -R g+rwX /opt/bitnami/odoo/addons/account_*

USER 1001