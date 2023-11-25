data "http" "myip" {
  url = "https://ifconfig.me"
}

resource "aws_instance" "monitoring_instance" {
  ami           = "ami-09a4be16fc35fa7cc"  
  instance_type = "c5a.xlarge"  

  tags = {
    Name = "Monitoring Server"
  }

  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]
  key_name               = "brian_omen"  

root_block_device {
    volume_type = "gp3"
    volume_size = 100
    iops        = 3000 
    throughput  = 125  
    delete_on_termination = true
  }
}

resource "aws_security_group" "monitoring_sg" {
  name        = "monitoring_sg"
  description = "Security group for Monitoring Instance"

  ingress {
    from_port   = 1515
    to_port     = 1515
    protocol    = "tcp"
	  cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
	  cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    from_port   = 514
    to_port     = 514
    protocol    = "tcp"
	  cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    from_port   = 1516
    to_port     = 1516
    protocol    = "tcp"
	  cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    from_port   = 9300
    to_port     = 9400
    protocol    = "tcp"
	  cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    from_port   = 1514
    to_port     = 1514
    protocol    = "tcp"
	  cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
	  cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    from_port   = 1514
    to_port     = 1514
    protocol    = "udp"
	  cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    from_port   = 55000
    to_port     = 55000
    protocol    = "tcp"
	  cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
	  cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
	  cidr_blocks = ["172.31.16.0/20"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] 
  }
}