# -----------------------
# 1) Builder-Stage: Klonen der OCA-EDI-Module
# -----------------------
FROM alpine/git:latest AS builder
WORKDIR /src

# Nur die benötigten Module aus dem Repo (Branch 17.0) klonen
RUN git clone --depth 1 --branch 17.0 https://github.com/OCA/edi.git edi \
 && mv edi/account_einvoice_generate    ./account_einvoice_generate \
 && mv edi/base_facturx                  ./base_facturx \
 && mv edi/account_invoice_facturx       ./account_invoice_facturx \
 && rm -rf edi

# -----------------------
# 2) Final-Stage: Bitnami Odoo mit eingebetteten Addons
# -----------------------
FROM docker.io/bitnami/odoo:18

# a) Python-Libs für Factur-X
RUN pip3 install --no-cache-dir factur-x PyPDF2

RUN mkdir -p /bitnami/odoo/addons/

# b) Vorgeklonte Module ins Image-Addon-Verzeichnis kopieren
COPY --from=builder /src/account_einvoice_generate    /bitnami/odoo/addons/account_einvoice_generate
COPY --from=builder /src/base_facturx                  /bitnami/odoo/addons/base_facturx
COPY --from=builder /src/account_invoice_facturx       /bitnami/odoo/addons/account_invoice_facturx

