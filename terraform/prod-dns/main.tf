// This is set by direnv.
variable "PROD_CALLYSTO_ZONE_ID" {}

resource "openstack_dns_recordset_v2" "hub_jupyter_cybera_ca" {
  zone_id = "${var.PROD_CALLYSTO_ZONE_ID}"
  name    = "hub.jupyter.cybera.ca."
  type    = "A"

  records = [
    "162.246.156.157",
  ]
}
