FROM alpine/git:latest AS builder
WORKDIR /src

RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/edi.git edi \
 && mv edi/account_einvoice_generate    ./account_einvoice_generate \
 && mv edi/base_facturx                  ./base_facturx \
 && mv edi/account_invoice_facturx       ./account_invoice_facturx \
 && rm -rf edi

RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/community-data-files.git community-data-files \
 && mv community-data-files/base_unece                  ./base_unece \
 && mv community-data-files/account_tax_unece    ./account_tax_unece \
 && rm -rf community-data-files


FROM docker.io/bitnami/odoo:18

# a) Python-Libs für Factur-X
RUN pip3 install --no-cache-dir factur-x PyPDF2

RUN mkdir -p /bitnami/odoo/addons/

COPY --from=builder /src/base_facturx                  /bitnami/odoo/addons/base_facturx
COPY --from=builder /src/account_einvoice_generate    /bitnami/odoo/addons/account_einvoice_generate
COPY --from=builder /src/account_invoice_facturx       /bitnami/odoo/addons/account_invoice_facturx
COPY --from=builder /src/account_invoice_facturx       /bitnami/odoo/addons/base_unece
COPY --from=builder /src/account_invoice_facturx       /bitnami/odoo/addons/account_tax_unece

