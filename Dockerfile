# -----------------------
# 1) Builder-Stage: Klonen der OCA-EDI-Module
# -----------------------
FROM alpine/git:latest AS builder
WORKDIR /src

# Nur die benötigten Module aus dem Repo (Branch 17.0) klonen
RUN git clone --depth 1 --branch 17.0 https://github.com/OCA/edi.git edi
RUN mv edi/account_einvoice_generate    ./account_einvoice_generate
RUN mv edi/base_facturx                  ./base_facturx
RUN mv edi/account_invoice_facturx       ./account_invoice_facturx
RUN rm -rf edi

# -----------------------
# 2) Final-Stage: Bitnami Odoo
# -----------------------
FROM docker.io/bitnami/odoo:18

USER root

# a) Python-Libraries für Factur-X
RUN pip3 install --no-cache-dir factur-x PyPDF2

# b) Vorgeklonte Module in den Addons-Pfad kopieren
COPY --from=builder /src/account_einvoice_generate    /bitnami/odoo/addons/account_einvoice_generate
COPY --from=builder /src/base_facturx                  /bitnami/odoo/addons/base_facturx
COPY --from=builder /src/account_invoice_facturx       /bitnami/odoo/addons/account_invoice_facturx

# c) Rechte setzen, damit der unprivilegierte Odoo-User (1001) darauf zugreifen kann
RUN chown -R 1001:1001 /bitnami/odoo/addons/* \
 && chmod -R g+rwX     /bitnami/odoo/addons/*

USER 1001
