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


FROM odoo:18

USER root

# Installiere venv + minimal build-essentials (falls native libs kompiliert werden müssen)
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    python3-venv python3-pip build-essential libxml2-dev libxslt1-dev libjpeg-dev zlib1g-dev \
 && rm -rf /var/lib/apt/lists/*

# Erstelle eine virtualenv für zusätzliche Python-Pakete und installiere dort die Pakete
RUN python3 -m venv /opt/odoo/venv \
 && /opt/odoo/venv/bin/pip install --upgrade pip setuptools wheel \
 && /opt/odoo/venv/bin/pip install --no-cache-dir factur-x PyPDF2

# Damit Odoo beim Start die venv-Python-Version verwendet, venv bin in PATH voranstellen
ENV PATH="/opt/odoo/venv/bin:${PATH}"

# Addons-Verzeichnis (offizielles Image nutzt /mnt/extra-addons für Drittanbieter-Addons)
RUN mkdir -p /mnt/extra-addons \
 && chown -R odoo:odoo /mnt/extra-addons

COPY --from=builder /src/base_facturx                  /mnt/extra-addons/base_facturx
COPY --from=builder /src/account_einvoice_generate    /mnt/extra-addons/account_einvoice_generate
COPY --from=builder /src/account_invoice_facturx       /mnt/extra-addons/account_invoice_facturx

COPY --from=builder /src/base_unece              /mnt/extra-addons/base_unece
COPY --from=builder /src/account_tax_unece       /mnt/extra-addons/account_tax_unece
COPY --from=builder /src/account_payment_unece       /mnt/extra-addons/account_payment_unece
COPY --from=builder /src/uom_unece       /mnt/extra-addons/uom_unece

COPY --from=builder /src/account_payment_mode       /mnt/extra-addons/account_payment_mode
COPY --from=builder /src/account_payment_partner       /mnt/extra-addons/account_payment_partner
COPY --from=builder /src/account_payment_method_base       /mnt/extra-addons/account_payment_method_base

RUN chown -R odoo:odoo /mnt/extra-addons

USER odoo