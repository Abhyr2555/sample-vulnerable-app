# Remediated terraform/main.tf file with fixes for finding CWE-285

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
17:   # Fix 1: Remove public-read ACL
18:   # acl    = "public-read"
19: }
20: 
21: resource "aws_iam_policy" "app_policy" {
22:   name        = "app-restricted-access"
23:   description = "Policy used by instances with restricted access"
24: 
25:   policy = <<EOF
26: {
27:   "Version": "2012-10-17",
28:   "Statement": [
29:     {
30:       "Effect": "Allow",
31:       # Fix 2: Specify required actions instead of wildcard
32:       "Action": [
33:         "s3:GetObject",
34:         "s3:PutObject",
35:         "s3:DeleteObject"
36:       ],
37:       # Fix 3: Specify required resources instead of wildcard 
38:       "Resource": [
39:         "arn:aws:s3:::sample-app-terraform-bucket-12345/*"
40:       ]
41:     }
42:   ]
43: }
44: EOF
45: }
46: 
47: resource "aws_security_group" "restricted_sg" {
48:   name        = "restricted-sg"
49:   description = "Security group with restricted access"
50: 
51:   # Fix 4: Only allow required ports/protocols
52:   ingress {
53:     from_port   = 80
54:     to_port     = 80
55:     protocol    = "tcp"
56:     cidr_blocks = ["0.0.0.0/0"]
57:   }
58: 
59:   ingress {
60:     from_port   = 443  
61:     to_port     = 443
62:     protocol    = "tcp"
63:     cidr_blocks = ["0.0.0.0/0"]
64:   }
65: }