module "ec2_instance" {
  source = "./modules/ec2_instance"
}

# module "waf" {
#   source = "./modules/waf"
#   # Configure variables specific to WAF
# }