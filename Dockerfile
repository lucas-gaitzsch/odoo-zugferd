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
 && mv community-data-files/account_payment_unece    ./account_payment_unece \
 && mv community-data-files/uom_unece    ./uom_unece \
 && rm -rf community-data-files

RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/bank-payment.git bank-payment \
 && mv bank-payment/account_payment_mode       ./account_payment_mode \
 && mv bank-payment/account_payment_partner    ./account_payment_partner \
 && rm -rf bank-payment

RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/account-payment.git account-payment \
 && mv account-payment/account_payment_method_base       ./account_payment_method_base \
 && rm -rf account-payment


FROM docker.io/bitnami/odoo:18

# a) Python-Libs für Factur-X
RUN /opt/bitnami/odoo/venv/bin/pip install --no-cache-dir factur-x PyPDF2

RUN mkdir -p /bitnami/odoo/addons/

COPY --from=builder /src/base_facturx                  /bitnami/odoo/addons/base_facturx
COPY --from=builder /src/account_einvoice_generate    /bitnami/odoo/addons/account_einvoice_generate
COPY --from=builder /src/account_invoice_facturx       /bitnami/odoo/addons/account_invoice_facturx

COPY --from=builder /src/base_unece              /bitnami/odoo/addons/base_unece
COPY --from=builder /src/account_tax_unece       /bitnami/odoo/addons/account_tax_unece
COPY --from=builder /src/account_payment_unece       /bitnami/odoo/addons/account_payment_unece
COPY --from=builder /src/uom_unece       /bitnami/odoo/addons/uom_unece

COPY --from=builder /src/account_payment_mode       /bitnami/odoo/addons/account_payment_mode
COPY --from=builder /src/account_payment_partner       /bitnami/odoo/addons/account_payment_partner

COPY --from=builder /src/account_payment_method_base       /bitnami/odoo/addons/account_payment_method_base
