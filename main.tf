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

resource "aws_instance" "blog" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instace_type

  tags = {
    Name = "Learning Terraform"
  }
}
resource "aws_security_group" "blog" {
  name          = "blog"
  description   = "Allow http and https in. Allow everything out"
  vpc_id        = data.aws_vpc.default_id
}

resource "aws_security_group_rule" "blog_http_in" {
  type= "ingress"
  from_port          = 80
  to_port            =80
  protocol           = "tcp"
  cidr_bloks         =["0.0.0.0/0"]

  security_group_id   = aws_security_group_blog.id
}

variable "AWS_ACCESS_KEY_ID" {
  description = "ID da AWS"
  type        = string
}
