# NOTE: contains intentional security test patterns for SAST/SCA/IaC scanning.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "sample-app-terraform-bucket-12345"
  acl    = "private"                            # Fix: changed from public-read to private
}

# Fix CWE-285 (TASK-35478e3d4eb6 / TASK-fcae5742293d): Replace wildcard actions with least-privilege
# ARN: arn:aws:inspector2:us-west-2:381492157536:finding/a15e4d9c987a434919ce5c9980d3afd7
# ARN: arn:aws:inspector2:us-west-2:381492157536:finding/c5dccdeb49ee5e6538b4512cc7fcd95a
resource "aws_iam_policy" "app_policy" {
  name        = "app-full-access"
  description = "Policy used by instances"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::sample-app-terraform-bucket-12345",
        "arn:aws:s3:::sample-app-terraform-bucket-12345/*"
      ]
    }
  ]
}
EOF
}

resource "aws_security_group" "open_sg" {
  name        = "open-sg"
  description = "Security group with restricted access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]               # Fix: restrict SSH to internal network only
  }
}
