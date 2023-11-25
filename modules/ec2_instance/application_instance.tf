resource "aws_instance" "application_instance" {
  ami           = "ami-0361bbf2b99f46c1d"  
  instance_type = "t2.micro"  

  tags = {
    Name = "Application Server"
  }

  vpc_security_group_ids = [aws_security_group.application_sg.id]
  key_name               = "brian_omen"  

  user_data = <<-EOF
#!/bin/bash
#Update and install initial software
dnf -y update 
dnf -y install docker tcpdump
systemctl enable --now docker
#Setup OWASP juice-shop
docker pull bkimminich/juice-shop
docker run -d -p 80:3000 bkimminich/juice-shop
#Setup wazuh agent
rpm --import https://packages.wazuh.com/key/GPG-KEY-WAZUH

cat <<REPO > /etc/yum.repos.d/wazuh.repo
[wazuh_repo]
gpgcheck=1
gpgkey=https://packages.wazuh.com/key/GPG-KEY-WAZUH
enabled=1
name=EL-\$releasever - Wazuh
baseurl=https://packages.wazuh.com/4.x/yum/
protect=1
REPO

WAZUH_MANAGER="${aws_instance.monitoring_instance.public_ip}" dnf -y install wazuh-agent
systemctl daemon-reload
systemctl enable --now wazuh-agent
sed -i "s/^enabled=1/enabled=0/" /etc/yum.repos.d/wazuh.repo
EOF

}

resource "aws_security_group" "application_sg" {
  name        = "application_sg"
  description = "Security group for Application Instance"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
	  cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
	  cidr_blocks = ["${aws_instance.monitoring_instance.public_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
  }
}

