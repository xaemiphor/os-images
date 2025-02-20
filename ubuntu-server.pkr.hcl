packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
  }
}

locals {
  reference = {
    noble = {
      codename = "noble"
      year     = 2024
      name     = "ubuntu-24.04"
    }
    jammy = {
      codename = "jammy"
      year     = 2022
      name     = "ubuntu-22.04"
    }
    focal = {
      codename = "focal"
      year     = 2020
      name     = "ubuntu-20.04"
    }
  }
}

variable "qemu_accelerator" {
  type        = string
  default     = "kvm"
  description = "Qemu accelerator to use. On Linux use kvm and macOS use hvf."
}

variable "vm_base" {
  type    = string
  default = "noble"
}

variable "ssh_password" {
  type = string
  default = "password"
}

source "qemu" "this" {
  iso_checksum = "file:https://cloud-images.ubuntu.com/releases/${local.reference[var.vm_base].codename}/release/SHA256SUMS"
  iso_url      = "https://cloud-images.ubuntu.com/releases/${local.reference[var.vm_base].codename}/release/${local.reference[var.vm_base].name}-server-cloudimg-amd64.img"
  disk_image   = true

  accelerator      = var.qemu_accelerator
  cd_files         = ["./cloud-init/*"]
  cd_label         = "cidata"
  disk_compression = true

  headless         = true
  output_directory = "output-${local.reference[var.vm_base].name}"
  vm_name          = "${local.reference[var.vm_base].name}-server.img"
  shutdown_command = "echo '${var.ssh_password}' | sudo -S shutdown -P now"

  ssh_username = "ubuntu"
  ssh_password = "${var.ssh_password}"
}

build {
  sources = ["source.qemu.this"]
  provisioner "shell" {
    // run scripts with sudo, as the default cloud image user is unprivileged
    execute_command = "echo '${var.ssh_password}' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    // NOTE: cleanup.sh should always be run last, as this performs post-install cleanup tasks
    scripts = [
      "scripts/install.sh",
      "scripts/cleanup.sh"
    ]
  }
}
