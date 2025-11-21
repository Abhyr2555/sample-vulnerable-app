1: # NOTE: contains intentional security test patterns for SAST/SCA/IaC scanning.
2: terraform {
3:   required_providers {
4:     aws = {
5:       source  = "hashicorp/aws"
6:       version = "~> 4.0"
7:     }
8:   }
9: }
10:
11: provider "aws" {
12:   region = "us-east-1"
13: }
14:
15: resource "aws_s3_bucket" "app_bucket" {
16:   bucket = "sample-app-terraform-bucket-12345"
17:   # Fix: Removed public-read ACL
18: }
19:
20: resource "aws_iam_policy" "app_policy" {
21:   name        = "app-full-access"
22:   description = "Policy used by instances"
23:
24:   policy = <<EOF
25: {
26:   "Version": "2012-10-17",
27:   "Statement": [
28:     {
29:       "Effect": "Allow",
30:       # Fix: Specified minimum required actions instead of wildcard
31:       "Action": ["s3:GetObject", "s3:PutObject"],  
32:       # Fix: Specified bucket resource instead of wildcard
33:       "Resource": "arn:aws:s3:::sample-app-terraform-bucket-12345/*"
34:     }
35:   ]
36: }
37: EOF
38: }
39:
40: resource "aws_security_group" "open_sg" {
41:   name        = "open-sg"
42:   description = "Security group with wide open access"
43:
44:   # Fix: Restricted ingress to only required ports/IPs
45:   ingress {
46:     from_port   = 80 
47:     to_port     = 80
48:     protocol    = "tcp"
49:     cidr_blocks = ["10.0.0.0/24"] # Example private subnet
50:   }
51: }