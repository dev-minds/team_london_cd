data "aws_ami" "mgmnt_ami_choice" {
  most_recent = true
  owners      = ["self"]
  name_regex  = "^FrontendAmi.*"

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Server Definition
provider "aws" {
  profile = var.profile_name
  region  = var.aws_region
  version = "~> 2.7"
}

terraform {
  required_version = ">= 0.12.12"

  backend "s3" {
    bucket  = "dm-vpc-states"
    key     = "live_fe_state/frontendenv.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
  }
}

// data "terraform_remote_state" "dm_vpc_state_ds" {
//   backend = "s3"

//   config = {
//     bucket = "state-centrale-tg-global-org-state-eu-west-1"
//     key    = "aws-centrale-acct/eu-west-1/management/tf_vpc_svc/terraform.tfstate"
//     region = "${var.aws_region}"
//   }
// }

resource "aws_instance" "dm_bastion_inst_res" {
  ami                    = data.aws_ami.mgmnt_ami_choice.id
  instance_type          = var.server_type 
  vpc_security_group_ids = ["${aws_security_group.dm_management_sg_res.id}", ]
  key_name               = var.target_keypairs
  subnet_id              = var.target_subnet

  tags = {
    Name = "${var.app_name_bastion}-Server"
  }
}

resource "aws_security_group" "dm_management_sg_res" {
  name_prefix = "Management SG"
  description = "Port Numbers On Management VPC"
  vpc_id      = "vpc-0d2db05d2e7a6a1ae"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "Frontend Port Numbers"
  }
}

resource "aws_security_group_rule" "dm_management_sg_ssh_res" {
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.dm_management_sg_res.id
}

resource "aws_security_group_rule" "dm_management_sg_http_res" {
  type              = "ingress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.dm_management_sg_res.id
}

resource "aws_security_group_rule" "dm_management_egress_res" {
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.dm_management_sg_res.id
}


output "pub_ip" {
  value = ["${aws_instance.dm_bastion_inst_res.public_ip}"]
}