# These represent settings to tune the hub you're creating
locals {
  name = "geeky.jupyter.cybera.ca"

  image_name   = "cybera-jupyterhub"
  network_name = "default"
  public_key   = "${file("../../keys/id_rsa.pub")}"
  zone_id      = "9e2fab89-1e01-4cb1-af20-1b13bbe6fc72"

  create_floating_ip = false
  existing_floating_ip = "162.246.156.94"

  existing_volumes = []
}

data "openstack_images_image_v2" "hub" {
  name        = "${local.image_name}"
  most_recent = true
}

module "settings" {
  source      = "../modules/settings"
  environment = "prod"
}

module "hub" {
  source           = "../modules/hub"
  name             = "${local.name}"
  image_id         = "${data.openstack_images_image_v2.hub.id}"
  flavor_name      = "${module.settings.hub_flavor_name}"
  key_name         = "st2"
  network_name     = "${local.network_name}"
  existing_volumes = "${local.existing_volumes}"
}

resource "openstack_dns_recordset_v2" "hub_ipv6" {
  zone_id = "${local.zone_id}"
  name    = "${local.name}."
  ttl     = 60
  type    = "AAAA"

  records = [
    "${replace(module.hub.access_ip_v6, "/[][]/", "")}",
  ]
}

resource "openstack_networking_floatingip_v2" "hub" {
  count = "${local.create_floating_ip ? 1 : 0}"
  pool  = "public"
}

resource "openstack_compute_floatingip_associate_v2" "hub_new_fip" {
  count       = "${local.create_floating_ip ? 1 : 0}"
  instance_id = "${module.hub.instance_uuid}"
  floating_ip = "${openstack_networking_floatingip_v2.hub.address}"
}

resource "openstack_dns_recordset_v2" "hub_new_fip" {
  count   = "${local.create_floating_ip ? 1 : 0}"
  zone_id = "${local.zone_id}"
  name    = "${local.name}."
  ttl     = 60
  type    = "A"

  records = ["${openstack_compute_floatingip_associate_v2.hub_new_fip.floating_ip}"]
}

resource "openstack_compute_floatingip_associate_v2" "hub_existing_fip" {
  count       = "${local.existing_floating_ip != "" ? 1 : 0}"
  instance_id = "${module.hub.instance_uuid}"
  floating_ip = "${local.existing_floating_ip}"
}

resource "openstack_dns_recordset_v2" "hub_existing_fip" {
  count   = "${local.existing_floating_ip != "" ? 1 : 0}"
  zone_id = "${local.zone_id}"
  name    = "${local.name}."
  ttl     = 60
  type    = "A"

  records = ["${openstack_compute_floatingip_associate_v2.hub_existing_fip.floating_ip}"]
}

locals {
  hub_ip = "${
    coalesce(
      element(concat(openstack_compute_floatingip_associate_v2.hub_new_fip.*.floating_ip, list("")), 0),
      element(concat(openstack_compute_floatingip_associate_v2.hub_existing_fip.*.floating_ip, list("")), 0),
      openstack_dns_recordset_v2.hub_ipv6.records[0]
    )
  }"
}


resource "ansible_group" "hub" {
  inventory_group_name = "hub"
}

resource "ansible_group" "environment" {
  inventory_group_name = "prod"
}

resource "ansible_group" "local_vars" {
  inventory_group_name = "hub-geeky"
}

resource "ansible_host" "hub" {
  inventory_hostname = "${local.name}"

  groups = [
    "all",
    "${ansible_group.hub.inventory_group_name}",
    "${ansible_group.environment.inventory_group_name}",
    "${ansible_group.local_vars.inventory_group_name}",
  ]

  vars {
    ansible_user            = "ptty2u"
    ansible_host            = "${local.hub_ip}"
    ansible_ssh_common_args = "-C -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
  }
}
