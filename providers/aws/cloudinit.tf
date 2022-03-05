// Define the machine initialization configuration of the EC2 machine
data "template_file" "instance-cloudinit" {
  template = file("scripts/init.cfg")
}

data "template_file" "instance-sh" {
  template = file("scripts/init.sh")
  vars = {
    GROUP = aws_cloudwatch_log_group.default.name
    STREAM_NAME = "${var.project}Instance"
  }
}

data "template_cloudinit_config" "default" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.instance-cloudinit.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.instance-sh.rendered
  }
}

