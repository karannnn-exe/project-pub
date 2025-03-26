############################ vpc #######################################

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  name               = join("_", ["project", local.env_name])
  cidr               = var.cidr
  azs                = var.azs
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  database_subnets   = var.database_subnets
  enable_nat_gateway = true
  single_nat_gateway = true
  tags               = merge(var.tags, { environment = "${local.env_name}", module = "landingzone", role = "network", backup = "false" })
}

########################################## jenkins policy with ssm,ecr full access ##########################################################



##################################################### Jenkins Role ###########################################################################

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = join("_", ["project", local.env_name, "profile", "uw2", "jenkins_profile"])
  role = aws_iam_role.jenkins_role.name
}

resource "aws_iam_role" "jenkins_role" {
  name = join("_", ["project", local.env_name, "role", "uw2", "jenkins_role"])

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

########################################## Jenkins Policy with SSM, ECR Full Access ##########################################################

resource "aws_iam_role_policy" "jenkins_policy" {
  name = join("_", ["project", local.env_name, "policy", "uw2", "jenkins"])
  role = aws_iam_role.jenkins_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "ds:CreateComputer",
                "ds:DescribeDirectories",
                "ec2:DescribeInstanceStatus",
                "ec2:*",
                "ecs:*",
                "logs:*",
                "ecr:*",
                "cloudtrail:LookupEvents",
                "ssm:*",
                "ec2messages:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "arn:aws:iam::*:role/aws-service-role/ssm.amazonaws.com/AWSServiceRoleForAmazonSSM*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": [
                        "replication.ecr.amazonaws.com",
                        "ssm.amazonaws.com"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:DeleteServiceLinkedRole",
                "iam:GetServiceLinkedRoleDeletionStatus"
            ],
            "Resource": "arn:aws:iam::*:role/aws-service-role/ssm.amazonaws.com/AWSServiceRoleForAmazonSSM*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

########################################################## jenkins server ####################################################################



module "jenkins" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  name                        = join("_", ["project", local.env_name, "ec2", "uw1", "jenkins"])
  ami                         = "ami-04f7a54071e74f488"
  instance_type               = var.jenkins_instance_type
  key_name                    = local.env_name
  iam_instance_profile        = aws_iam_instance_profile.jenkins_profile.name
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.jenkins_ec2_sg.id]
  subnet_id                   = module.vpc.public_subnets[0]
  tags                        = merge(local.tags, { backup = "true" })
  enable_volume_tags          = true
  volume_tags                 = local.tags
  associate_public_ip_address = true

  root_block_device = [
    {
      volume_type           = "gp3"
      volume_size           = var.jenkins_vol_size
      delete_on_termination = true
    }
  ]
}



resource "aws_security_group" "jenkins_ec2_sg" {
  name        = join("_", ["project", local.env_name, "sg", "uw1", "jenkins"])
  description = "Security Group For jenkins"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = join("_", ["project", local.env_name, "sg", "uw1", "jenkins"]) })
}

####################################################### ecs cluster ##########################################################################


resource "aws_ecs_cluster" "cluster" {
  name = join("_", ["project", local.env_name, "cluster", "uw1"])
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.tags
}

# -------------------------------------------------------------------
# AWS ECR Repositories for Backend & Frontend
# -------------------------------------------------------------------

#  Create ECR Repository for Backend
resource "aws_ecr_repository" "backend_repo" {
  name                 = "backend-app"
  image_tag_mutability = "MUTABLE"
}

#  Create ECR Repository for Frontend
resource "aws_ecr_repository" "frontend_repo" {
  name                 = "frontend-app"
  image_tag_mutability = "MUTABLE"
}

