# AWS Batch Demo

This provisions an AWS Batch Compute Environment and Job Definition and runs a simple decompress command line tool written in Python in an AWS Batch Job.

## Requirements

- Python 3
- Docker
- Terraform

## Python CLI Installation

```bash
$ pip install git+https://github.com/petedannemann/aws-secrets-manager-cli#egg=aws_secrets_manager_cli
```

## Python CLI Usage

```bash
$ decompress --help
Usage: decompress [OPTIONS]

  Simple program that decompresses an input file and writes it to an output
  file.

Options:
  -i, --input-file-path TEXT   The path of the input file, local or S3
                               (s3://...)
  -o, --output-file-path TEXT  The path of the output file, local or S3
                               (s3://...)
  --help                       Show this message and exit.
```

## Terraform

```bash
# Initialize terraform
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy resources
terraform destroy
```

## Commands

```bash
# Copy local file to S3
make copy-s3

# Build docker image
make build

# Tag docker image
make tag

# Build, tag, and push docker image to ECR
make push

# Submit the job to AWS Batch
make submit-job
```
