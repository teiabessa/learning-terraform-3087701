data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }
   filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}
 
data "aws_vpc" "default"{
    default = true
 }


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"
  #zone brasil - sp
  azs             = ["sa-east-1a", "sa-east-1b", "sa-east-1c"]
  
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_instance" "blog" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  vpc_security_group_ids = [module.blog_sg.security_group_id]

  subnet_id = module.blog_vpc.public_subnet[0]

  tags = {
    Name = "Learning Terraform"
  }
}


module "blog_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"
  name    = "blog_new" 

  vpc_id        = data.aws_vpc.default.id
  ingress_rules = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  #all http protocol
  egress_rules = [ "all-all" ]
  egress_cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "blog" {
  name          = "blog"
  description   = "Allow http and https in. Allow everything out"

  vpc_id        = module.blog_vpc.vpc_id

}

#http protocol
resource "aws_security_group_rule" "blog_http_in" {
  type= "ingress"
  from_port          = 80
  to_port            = 80
  protocol           = "tcp"
  cidr_blocks         =["0.0.0.0/0"]

  security_group_id   = aws_security_group.blog.id
}
#https protocol
resource "aws_security_group_rule" "blog_https_in" {
  type               = "ingress"
  from_port          = 443
  to_port             =443
  protocol           = "tcp"
  cidr_blocks         =["0.0.0.0/0"]

  security_group_id   = aws_security_group.blog.id
}


resource "aws_security_group_rule" "blog_everything_out" {
  type= "egress"
  from_port          = 0
  to_port            = 0
  protocol           = "-1"
  cidr_blocks         =["0.0.0.0/0"]

  security_group_id   = aws_security_group.blog.id
}

variable "AWS_ACCESS_KEY_ID" {
  description = "ID da AWS"
  type        = string
}
variable "AWS_SECRET_ACCESS_KEY" {
  description = "SECRET_ACCESS_KEY da AWS"
  type        = string
}
