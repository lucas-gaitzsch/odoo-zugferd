FROM alpine/git:latest AS builder
WORKDIR /src

RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/edi.git edi \
 && mv edi/account_einvoice_generate    ./account_einvoice_generate \
 && mv edi/base_facturx                 ./base_facturx \
 && mv edi/account_invoice_facturx      ./account_invoice_facturx \
 && rm -rf edi

RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/community-data-files.git community-data-files \
 && mv community-data-files/base_unece               ./base_unece \
 && mv community-data-files/account_tax_unece       ./account_tax_unece \
 && mv community-data-files/account_payment_unece   ./account_payment_unece \
 && mv community-data-files/uom_unece               ./uom_unece \
 && rm -rf community-data-files

RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/bank-payment.git bank-payment \
 && mv bank-payment/account_payment_mode       ./account_payment_mode \
 && mv bank-payment/account_payment_partner    ./account_payment_partner \
 && rm -rf bank-payment

RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/account-payment.git account-payment \
 && mv account-payment/account_payment_method_base  ./account_payment_method_base \
 && rm -rf account-payment

RUN git clone --depth 1 --branch 18.0 https://github.com/OCA/partner-contact.git partner-contact \
 && mv partner-contact/partner_bank_acc_holder_name ./partner_bank_acc_holder_name \
 && rm -rf partner-contact


FROM odoo:18.0

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    fontconfig \
    xfonts-75dpi \
    xfonts-base \
    fonts-liberation \
    fonts-urw-base35 \
    fonts-dejavu-core \
    libxrender1 \
    libxext6 \
    libfreetype6 \
    && rm -rf /var/lib/apt/lists/*

# a) Python-Libs für Factur-X / OCA migrations
RUN pip3 install --no-cache-dir --break-system-packages factur-x==6.8 PyPDF2 openupgradelib

# b) Zielpfad für Custom Addons im offiziellen Image
RUN mkdir -p /mnt/extra-addons \
 && chown -R odoo:odoo /mnt/extra-addons

COPY --from=builder /src/base_facturx               /mnt/extra-addons/base_facturx
COPY --from=builder /src/account_einvoice_generate /mnt/extra-addons/account_einvoice_generate
COPY --from=builder /src/account_invoice_facturx   /mnt/extra-addons/account_invoice_facturx

COPY --from=builder /src/base_unece                 /mnt/extra-addons/base_unece
COPY --from=builder /src/account_tax_unece          /mnt/extra-addons/account_tax_unece
COPY --from=builder /src/account_payment_unece      /mnt/extra-addons/account_payment_unece
COPY --from=builder /src/uom_unece                  /mnt/extra-addons/uom_unece

COPY --from=builder /src/account_payment_mode       /mnt/extra-addons/account_payment_mode
COPY --from=builder /src/account_payment_partner    /mnt/extra-addons/account_payment_partner

COPY --from=builder /src/account_payment_method_base /mnt/extra-addons/account_payment_method_base
COPY --from=builder /src/partner_bank_acc_holder_name /mnt/extra-addons/partner_bank_acc_holder_name
COPY odoo-startup.sh /usr/local/bin/odoo-startup.sh

# Sicherheitshalber Ownership für alle kopierten Addons
RUN chown -R odoo:odoo /mnt/extra-addons
RUN chmod +x /usr/local/bin/odoo-startup.sh

USER odoo

ENTRYPOINT ["/usr/local/bin/odoo-startup.sh"]
