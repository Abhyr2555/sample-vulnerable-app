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
17:   acl    = "public-read"                        # Issue 1: public-read ACL 
18: }
19:
20: # Fixed IAM policy with least privilege
21: resource "aws_iam_policy" "app_policy" {
22:   name        = "app-read-only-s3" 
23:   description = "Allow read-only access to the app S3 bucket"
24:
25:   policy = <<EOF
26: {
27:   "Version": "2012-10-17",
28:   "Statement": [
29:     {
30:       "Effect": "Allow",
31:       "Action": [
32:         "s3:GetObject",  # Added minimal read-only S3 actions
33:         "s3:ListBucket"
34:       ],
35:       "Resource": [
36:         "arn:aws:s3:::sample-app-terraform-bucket-12345", # Specified bucket ARN
37:         "arn:aws:s3:::sample-app-terraform-bucket-12345/*"
38:       ]
39:     }
40:   ]
41: }
42: EOF
43: }
44:
45: resource "aws_security_group" "open_sg" {
46:   name        = "open-sg"
47:   description = "Security group with wide open access"
48:
49:   ingress {
50:     from_port   = 0
51:     to_port     = 0  
52:     protocol    = "-1"
53:     cidr_blocks = ["0.0.0.0/0"]                 # Issue 4: all ports open
54:   }
55: }