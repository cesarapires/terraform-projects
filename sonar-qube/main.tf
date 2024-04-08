provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "sg_8080" {
  name = "terraform-learn-state-sg-8080"
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "9000"
    to_port     = "9000"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_instance" {
  ami = "ami-080e1f13689e07408"
  instance_type = "t2.medium"
  tags = {
    Name = "sonarqube-instance"
  }
  vpc_security_group_ids = [aws_security_group.sg_8080.id]
  key_name = "deployment-server"
  user_data = file("install_sonar.sh")
}

output "public_ip" {
  value = aws_instance.ec2_instance.public_ip
}
