#!/bin/bash
set -euo pipefail

DEFAULT_MODULES="account_payment_method_base,account_payment_mode,account_payment_partner,partner_bank_acc_holder_name,base_unece,account_payment_unece,account_tax_unece,uom_unece,base_facturx,account_einvoice_generate,account_invoice_facturx"

cmd=("$@")

if [[ ${#cmd[@]} -eq 0 ]]; then
    cmd=("odoo")
elif [[ "${cmd[0]}" == -* ]]; then
    cmd=("odoo" "${cmd[@]}")
fi

if [[ "${cmd[0]}" == "odoo" || "${cmd[0]}" == "odoo-bin" ]]; then
    if [[ -n "${ODOO_AUTO_UPGRADE_DB:-}" ]]; then
        modules="${ODOO_AUTO_UPGRADE_MODULES:-$DEFAULT_MODULES}"
        echo "Running startup module upgrade for database '${ODOO_AUTO_UPGRADE_DB}'"
        echo "Modules: ${modules}"
        /entrypoint.sh "${cmd[0]}" -d "${ODOO_AUTO_UPGRADE_DB}" -u "${modules}" --stop-after-init
    fi
fi

exec /entrypoint.sh "${cmd[@]}"
