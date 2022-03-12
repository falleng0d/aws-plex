# Parameters
variable "private_key_path" {}
variable "host" {}
variable "user" {}

resource "null_resource" "default" {
  provisioner "remote-exec" {
    connection {
        type = "ssh"
        user = var.user
        private_key = file(var.private_key_path)
        host = var.host
    }

    inline = [
      "silent(){ sudo DEBIAN_FRONTEND=noninteractive apt-get -qq -o Dpkg::Use-Pty=0 \"$@\" < /dev/null; }",
      "silent update",
      "silent upgrade",
      "sleep 15",
      "silent install software-properties-common aptdaemon"
    ]
  }
}

