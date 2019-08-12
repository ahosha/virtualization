
//----------------------------------------------------------------------------
//  Variable definitions
//
//  Defaults may be overridden via -var command line options
//  to terraform, or by environment variables of the form
//  TF_VAR_variable.  For example, to override the vSphere user, set
//  TF_VAR_vsphere_user=anotheruser in the environment.
//
//  Note that no default is provided for vsphere_password -- it can
//  be supplied by a -var argument, but is better passed through the
//  environment.
//----------------------------------------------------------------------------

variable "vsphere_server"   { default = "si-fred-vcsa-01.canlab.ibm.com" }
variable "vsphere_user"     { default = ""}
variable "vsphere_password" { default = "" }

variable "datacenter"       { default = "si-fred-dc" }
variable "resource_pool"    { default = "si-fred-Cluster/Resources" }

//----------------------------------------------------------------------------
//  These resources are shared across Pi and QBert agile teams
variable "datastore"        { default = "QBert_volume_01" }
variable "network_label"    { default = "Lab Vlan 148" }
//----------------------------------------------------------------------------

variable "template"         { default = "Users/pisces/drq_centos75" }

variable "base_name"        { default = "pisces-drq" }
variable "host_id"          { default = "default" }
variable "folder"           { default = "Users/pisces" }

variable "cpus"             { default = 1 }
variable "ram"              { default = 4096 }

variable "domain"           { default = "canlab.ibm.com" }

//----------------------------------------------------------------------------
//  vSphere provider
//----------------------------------------------------------------------------

provider "vsphere" {
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_server}"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

//----------------------------------------------------------------------------
//  vSphere resource references
//----------------------------------------------------------------------------

data "vsphere_datacenter" "dc" {
  name = "${var.datacenter}"
}

data "vsphere_datastore" "datastore" {
  name          = "${var.datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "${var.resource_pool}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "${var.network_label}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "${var.template}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

//----------------------------------------------------------------------------
//  VM definition
//----------------------------------------------------------------------------

resource "vsphere_virtual_machine" "drq-host" {
  name             = "${var.base_name}-${var.host_id}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  folder           = "${var.folder}"

  num_cpus = "${var.cpus}"
  memory   = "${var.ram}"

  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
    # adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "${var.base_name}-${var.host_id}"
        domain    = "${var.domain}"
      }
      network_interface {
      }
    }
  }
}

//----------------------------------------------------------------------------
//  Output variables.  This is how we get the IP assigned by DHCP.
//----------------------------------------------------------------------------

output "ip" {
  value = "${vsphere_virtual_machine.drq-host.guest_ip_addresses[0]}"
}

//----------------------------------------------------------------------------

