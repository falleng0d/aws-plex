# Parameters
variable "auth_key" {}
variable "auth_secret" {}
variable "endpoint" {}
variable "bucket" {}
variable "private_key_path" {}
variable "host" {}
variable "user" {}

resource "null_resource" "default" {
  provisioner "file" {
    connection {
        type = "ssh"
        user = var.user
        private_key = file(var.private_key_path)
        host = var.host
    }

    source      = "../../modules/services/goofys/scripts/goofys.sh"
    destination = "/tmp/goofys.sh"
  }

  provisioner "remote-exec" {
    connection {
        type = "ssh"
        user = var.user
        private_key = file(var.private_key_path)
        host = var.host
    }

    inline = [
      "sudo chmod a+x /tmp/goofys.sh",
      "sudo mkdir /plexmedia",
      "sudo /tmp/goofys.sh ${var.auth_key} ${var.auth_secret} ${var.endpoint} ${var.bucket}",
      "sudo rm -f /tmp/goofys.sh"
    ]
  }
}
