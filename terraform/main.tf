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
  # Fix: Removed public-read ACL
}

resource "aws_iam_policy" "app_policy" {
  name        = "app-full-access"
  description = "Policy used by instances"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      # Fix: Restricted to s3:GetObject and s3:PutObject actions
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      # Fix: Restricted to the app_bucket resource
      "Resource": "${aws_s3_bucket.app_bucket.arn}/*"
    }
  ]
}
EOF
}

resource "aws_security_group" "open_sg" {
  name        = "open-sg"
  description = "Security group with wide open access"

  # Fix: Only allow inbound HTTP (80) and SSH (22) from trusted IPs
  ingress {
    from_port   = 80 
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24", "192.168.1.0/24"] 
  }

  ingress {
    from_port   = 22
    to_port     = 22  
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
  }
}