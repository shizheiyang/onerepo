variable "version" {
  type    = string
  default = "1.0.0"
}

locals {
  cpu_cores         = "4"
  ram               = "4192"
  disk_size         = "40960M"
  name              = "rockylinux9"
  iso_checksum_type = "sha256"
  iso_url           = "Rocky-9.1-x86_64-minimal.iso"
  iso_checksum      = "md5:88ad1a0d11003fdd3da5cca0efc37eb2"
  headless          = "true"
  ks_config_file    = "ks.cfg"
  output_dir        = "output"
  ssh_username      = "vagrant"
  ssh_password      = "vagrant"
}

source "qemu" "rockylinux9" {
  format         = "qcow2"
  accelerator    = "kvm"
  qemu_binary    = "/usr/libexec/qemu-kvm"
  machine_type   = "q35"
  vm_name        = "${local.name}.qcow2"
  memory         = "${local.ram}"
  net_device     = "virtio-net"
  disk_interface = "virtio"
  disk_cache     = "none"
  qemuargs = [
    ["-m", "${local.ram}M"],
    ["-smp", "${local.cpu_cores}"],
    ["-cpu", "host"]
  ]
  ssh_wait_timeout = "30m"
  http_directory   = "./http"
  ssh_username     = "${local.ssh_username}"
  ssh_password     = "${local.ssh_password}"
  iso_url          = "${local.iso_url}"
  iso_checksum     = "${local.iso_checksum}"
  boot_wait        = "20s"
  boot_command     = ["<up><tab><wait><bs><bs><bs><bs><bs>inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${local.ks_config_file}<enter><wait>"]
  disk_size        = "${local.disk_size}"
  disk_discard     = "unmap"
  disk_compression = true
  headless         = "${local.headless}"
  shutdown_command = "sudo /usr/sbin/shutdown -h now"
  output_directory = "${local.output_dir}"
}

build {
  sources = ["source.qemu.rockylinux9"]

  provisioner "shell" {
    script = "provision.sh"
  }

  post-processors {

    post-processor "vagrant" {
      keep_input_artifact = true
      provider_override   = "libvirt"
      output              = "${local.output_dir}/{{.Provider}}-${local.name}.box"
    }

    post-processor "vagrant-cloud" {
      keep_input_artifact = true
      box_tag             = "shizheiyang/${local.name}"
      version             = "${var.version}"
    }
  }
}
