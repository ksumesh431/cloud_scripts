module "local_vpc_module" {
  source = "./modules/vpc"

  vpc_cidr_block = "10.2.0.0/16"
  pub_1_cidr     = "10.2.0.0/24"
  pub_2_cidr     = "10.2.1.0/24"
  priv_1_cidr    = "10.2.16.0/20"
  priv_2_cidr    = "10.2.32.0/20"

}



resource "aws_flow_log" "example" {
  log_destination      = "arn:aws:s3:::eg-dev-cluster-unique-name/flow-logs"
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = module.local_vpc_module.vpc_id
}



# ec2 instance for logs testing

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "skp-test"
  subnet_id     = module.local_vpc_module.pub_sub_1_id

  tags = {
    Name = "HelloWorld"
  }
}