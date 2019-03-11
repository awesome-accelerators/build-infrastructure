provider "aws" {
  version = "~> 2.1"
  region  = "${var.region}"
}

resource "aws_security_group" "jenkins_master" {
  name        = "jenkins_master_security_group"
  description = "Enabling SSH: 22 and HTTP: 8080 ports"

  tags {
    Author = "Paul Brodner"
    Tool   = "terraform"
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # JNLP port
  ingress {
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # output trafic
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_security_group" "jenkins_slave" {
  name        = "jenkins_slave_security_group"
  description = "Enabling SSH and HTTP ports"

  tags {
    Author = "Paul Brodner"
    Tool   = "terraform"
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # JNLP port
  ingress {
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # output trafic
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_instance" "jenkins_master" {
  key_name        = "${basename("${lookup(var.private_key_file, var.region)}")}"
  ami             = "${lookup(var.amis, var.region)}"
  instance_type   = "${var.jenkins_master_instance_type}"
  security_groups = ["${aws_security_group.jenkins_master.name}"]

  tags {
    Name   = "jenkins-master"
    Author = "Paul Brodner"
    Tool   = "terraform"
  }

  provisioner "file" {
    connection {
      user        = "ec2-user"
      host        = "${aws_instance.jenkins_master.public_ip}"
      timeout     = "1m"
      private_key = "${file("${lookup(var.private_key_file, var.region)}.pem")}"
    }

    source      = "scripts/install-jenkins.sh"
    destination = "/home/ec2-user/install-jenkins.sh"
  }

  provisioner "remote-exec" {
    connection {
      user        = "ec2-user"
      host        = "${aws_instance.jenkins_master.public_ip}"
      timeout     = "15m"
      private_key = "${file("${lookup(var.private_key_file, var.region)}.pem")}"
    }

    inline = [
      "chmod +x /home/ec2-user/install-jenkins.sh",
      "/home/ec2-user/install-jenkins.sh ${join(",", var.jenkins_plugins)}",
    ]
  }
}
