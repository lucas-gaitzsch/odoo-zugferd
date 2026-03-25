# odoo-zugferd

Odoo 18 image for Factur-X/ZUGFeRD using OCA addons.

## Included addons

- `account_einvoice_generate`
- `account_invoice_facturx`
- `base_facturx`
- `base_unece`
- `account_tax_unece`
- `account_payment_unece`
- `uom_unece`
- `account_payment_mode`
- `account_payment_partner`
- `account_payment_method_base`

## Startup migration

The container can upgrade the OCA module stack automatically before the normal Odoo server starts.

Set:

- `ODOO_AUTO_UPGRADE_DB`: target database name
- `ODOO_AUTO_UPGRADE_MODULES`: optional comma-separated module list

If `ODOO_AUTO_UPGRADE_MODULES` is not set, the image upgrades this default list:

```text
account_payment_method_base,account_payment_mode,account_payment_partner,base_unece,account_payment_unece,account_tax_unece,uom_unece,base_facturx,account_einvoice_generate,account_invoice_facturx
```

Example:

```bash
docker run \
  -e ODOO_AUTO_UPGRADE_DB=mydb \
  your-image
```

This is intended for startup schema alignment on an existing database. Keep it pointed at a specific database; do not enable it without setting `ODOO_AUTO_UPGRADE_DB`.

The image also includes `openupgradelib`, because some OCA module upgrades ship Python migration scripts that require it during `-u`.

## Important installation note

Before installing `account_einvoice_generate` / `account_invoice_facturx` on a database, uninstall Odoo's standard module `account_edi` (`Import/Export Invoices From XML/PDF`).

On Odoo 18, `account_edi` is typically auto-installed. Keeping it installed alongside the OCA Factur-X stack can lead to broken invoice XML/PDF integration and secondary errors during rendering or settings access.

## Troubleshooting

If you see a traceback ending with:

```text
psycopg2.errors.InFailedSqlTransaction: current transaction is aborted
```

that is usually not the root cause. In Odoo this means an earlier SQL/XML/view error already failed inside the same transaction. Check the log lines above that stack trace for the first exception.

For this image, the first thing to verify is:

1. `account_edi` is uninstalled.
2. All addons from `/mnt/extra-addons` are available in the server addons path.
3. The modules were installed in Odoo after the image was rebuilt.
