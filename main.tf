# Variables
variable "name" {
  default = "aws-batch-example"
}

data "aws_caller_identity" "current" {}

variable "input_file" {
  default = "lorem_ipsum.txt.gz"
}

variable "output_file" {
  default = "lorem_ipsum.txt"
}

# Provider
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# Networking
resource "aws_vpc" "this" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "${var.name}"
  }
}

resource "aws_subnet" "this" {
  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = "${aws_vpc.this.id}"

  tags = {
    Name = "${var.name}"
  }
}

# Security
resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs_instance_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
        "Service": "ec2.amazonaws.com"
        }
    }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role" {
  role = "${aws_iam_role.ecs_instance_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_role" {
  name = "ecs_instance_role"
  role = "${aws_iam_role.ecs_instance_role.name}"
}

resource "aws_iam_role" "aws_batch_service_role" {
  name = "aws_batch_service_role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
        "Service": "batch.amazonaws.com"
        }
    }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "aws_batch_service_role" {
  role       = "${aws_iam_role.aws_batch_service_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

resource "aws_iam_role_policy" "s3_policy" {
  name = "s3_policy"
  role = "${aws_iam_role.ecs_instance_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.this.bucket}/*"
    }
  ]
}
EOF
}

resource "aws_security_group" "this" {
  name = "aws_batch_compute_environment_security_group"
  description = "Allow Internet access"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}"
  }
}

# S3
resource "aws_s3_bucket" "this" {
  bucket = "${var.name}"
  acl = "private"

  tags = {
    Name = "${var.name}"
    Environment = "Dev"
  }
}

# ECR
resource "aws_ecr_repository" "this" {
  name = "${var.name}"
}

# Batch
resource "aws_batch_compute_environment" "this" {
  compute_environment_name = "${var.name}"

  compute_resources {
    instance_role = "${aws_iam_instance_profile.ecs_instance_role.arn}"
    ec2_key_pair = "MyEC2KeyPair"

    instance_type = [
      "optimal",
    ]

    max_vcpus = 2
    min_vcpus = 0

    security_group_ids = [
      "${aws_security_group.this.id}",
    ]

    subnets = [
      "${aws_subnet.this.id}",
    ]

    type = "EC2"

    tags = {
      "Name" = "aws-batch-job"
    }
  }

  service_role = "${aws_iam_role.aws_batch_service_role.arn}"
  type = "MANAGED"
  depends_on = ["aws_iam_role_policy_attachment.aws_batch_service_role"]

}

resource "aws_batch_job_queue" "this" {
  name = "${var.name}"
  state = "ENABLED"
  priority = 1
  compute_environments = ["${aws_batch_compute_environment.this.arn}"]
}

resource "aws_batch_job_definition" "decompress" {
  name = "${var.name}"
  type = "container"

  container_properties = <<CONTAINER_PROPERTIES
{
    "command": [
        "decompress-decrypt",
        "decompress", 
        "--input-file-path",
        "s3://${aws_s3_bucket.this.bucket}/${var.input_file}",
        "--output-file-path",
        "s3://${aws_s3_bucket.this.bucket}/${var.output_file}"
    ],
    "image": "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/${aws_ecr_repository.this.name}:latest",
    "memory": 1024,
    "vcpus": 1
}
CONTAINER_PROPERTIES
}

resource "aws_batch_job_definition" "decrypt" {
  name = "${var.name}"
  type = "container"

  container_properties = <<CONTAINER_PROPERTIES
{
    "command": [
        "decompress-decrypt",
        "decrypt", 
        "--input-file-path",
        "s3://${aws_s3_bucket.this.bucket}/${var.input_file}",
        "--output-file-path",
        "s3://${aws_s3_bucket.this.bucket}/${var.output_file}"
    ],
    "image": "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/${aws_ecr_repository.this.name}:latest",
    "memory": 1024,
    "vcpus": 1
}
CONTAINER_PROPERTIES
}
