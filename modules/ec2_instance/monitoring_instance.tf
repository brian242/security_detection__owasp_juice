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
}

#Using seperate aws_security_group_rule resources instead of aws_security_group to avoid terraform cyclic issue https://github.com/hashicorp/terraform-provider-aws/issues/6015)
resource "aws_security_group_rule" "monitoring_sg_all_traffic_from_application_server" {
  security_group_id = "${aws_security_group.monitoring_sg.id}"
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["${aws_instance.application_instance.public_ip}/32"]
}

resource "aws_security_group_rule" "monitoring_sg_ssh_from_home" {
  security_group_id = "${aws_security_group.monitoring_sg.id}"
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
}

resource "aws_security_group_rule" "monitoring_sg_server_rest_api_from_home" {
  security_group_id = "${aws_security_group.monitoring_sg.id}"
  type        = "ingress"
  from_port   = 55000
  to_port     = 55000
  protocol    = "tcp"
  cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
}

resource "aws_security_group_rule" "monitoring_sg_indexer_rest_api_from_home" {
  security_group_id = "${aws_security_group.monitoring_sg.id}"
  type        = "ingress"
  from_port   = 9200
  to_port     = 9200
  protocol    = "tcp"
  cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
}

resource "aws_security_group_rule" "monitoring_sg_web_interface_from_home" {
  security_group_id = "${aws_security_group.monitoring_sg.id}"
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
}

resource "aws_security_group_rule" "monitoring_sg_all_traffice_to_internet" {
  security_group_id = "${aws_security_group.monitoring_sg.id}"
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"] 
}