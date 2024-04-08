provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "ec2_instance" {
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "sonarqube-instance"
  }

  key_name = "nome-da-chave-ssh"

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install -y openjdk-11-jdk
    wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-88267.zip
    sudo unzip sonarqube-88267.zip -d /opt
    sudo mv /opt/sonarqube-88267 /opt/sonarqube
    sudo /opt/sonarqube/bin/linux-x86-64/sonar.sh start
    EOF
}

output "public_ip" {
  value = aws_instance.ec2_instance.public_ip
}
