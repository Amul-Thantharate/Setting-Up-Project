data "aws_ami" "ubuntu" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-22.04-amd64-server-*"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

resource "tls_private_key" "project-key" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "local_file" "project-key" {
    filename = "project-key"
    content = tls_private_key.project-key.private_key_pem
    file_permission = "0600"
}

resource "aws_instance" "project-setup" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "c5.xlarge"
    availability_zone = "ap-southeast-1a"
    security_groups = ["sg-08cf820d034078c37"]
    subnet_id = "subnet-08707c6a77604a569"
    connection {
        type        = "ssh"
        user        = "ubuntu"
        private_key = tls_private_key.project-key.private_key_pem
        host        = self.public_ip
    }
    provisioner "remote-exec" {
        inline = <<-EOF
        echo "${tls_private_key.project-key.public_key_openssh}" >> ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
        EOF
        connection {
            type        = "ssh"
            user        = "ubuntu"
            private_key = tls_private_key.project-key.private_key_pem
            host        = self.public_ip
        }
    }

}