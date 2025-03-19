packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = "~> 1"
      source = "github.com/hashicorp/ansible"
    }
  }
}

variable "key_path" {
  type    = string
  default = ""
}

source "amazon-ebs" "almalinux9" {
  ami_name         = "almalinux9-wordpress"
  instance_type    = "t2.micro"
  region           = "ap-northeast-1"
  source_ami       = "ami-03ec4a957caaadb88"
  ssh_username     = "ec2-user"
  ssh_keypair_name  = "packer-key"
  ssh_private_key_file  = "${var.key_path}"
  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = 40
    volume_type = "gp2"
    delete_on_termination = true
  }
}

build {
  name = "almalinux9-wordpress"
  sources = [
    "source.amazon-ebs.almalinux9"
  ]

  provisioner "ansible" {
    playbook_file = "../ansible/site.yml"
    extra_arguments = [
        "-e",
        "'ansible_python_interpreter=/usr/bin/python3.9'"
    ]
  }
}
