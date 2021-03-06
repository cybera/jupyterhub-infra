variable "image_id" {}

variable "flavor_name" {}

variable "key_name" {}

variable "network_name" {}

variable "name" {
  default = ""
}

variable "vol_zfs_size" {
  default = 10
}

variable "existing_volumes" {
  type = "list"

  default = []
}

locals {
  cloudconfig = <<EOF
    #cloud-config
    preserve_hostname: true
    runcmd:
      - sed -i '/\/dev\/sdb/d' /etc/fstab
      - sed -i '/\/dev\/sdc/d' /etc/fstab
      - swaplabel -L swap0 /dev/sdb
      - echo "LABEL=swap0 none  swap  defaults  0  0" >> /etc/fstab
    system_info:
      default_user:
        name: ptty2u
  EOF
}
