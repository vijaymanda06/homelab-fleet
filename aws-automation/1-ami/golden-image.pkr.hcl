packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "golden-image-ubuntu-22.04-{{timestamp}}"
  instance_type = "t3.micro"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] # Canonical
  }
  ssh_username = "ubuntu"
}

build {
  name    = "learn-packer"
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    inline = [
      "echo 'Waiting for cloud-init...'",
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 1; done",

      "echo 'Removing pre-installed Snap conflict...'",
      "sudo snap remove amazon-ssm-agent",  # <--- THIS IS THE FIX 🔧

      "echo 'Updating system...'",
      "sudo apt-get update",

      "echo 'Installing SSM Agent (Debian Method)...'",
      "wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb",
      "sudo dpkg -i amazon-ssm-agent.deb",

      "echo 'Enabling SSM Agent...'",
      "sudo systemctl enable amazon-ssm-agent",
      "sudo systemctl start amazon-ssm-agent",
      
      "echo 'Cleanup...'",
      "rm amazon-ssm-agent.deb"
    ]
  }
}