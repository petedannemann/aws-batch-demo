# AWS Batch Demo

This provisions an AWS Batch Compute Environment and Job Definition and runs a simple decompress and decrypt command line tool written in Python in an AWS Batch Job. Airflow has two simple dags that runs this process for two files.

## Requirements

- Python 3
- Docker
- Terraform

## Python CLI Installation

```bash
$ pip install git+https://github.com/petedannemann/aws-batch-demo#egg=decompress-decrypt
```

## Python CLI Usage

```bash
$ decompress-decrypt --help
Usage: decompress-decrypt [OPTIONS] COMMAND [ARGS]...

  Comand line tool to decompress and decrypt files.

Options:
  --help  Show this message and exit.

Commands:
  decompress  Simple program that decompresses an input file and writes it...
  decrypt     Simple program that decrypts an input file and writes it to
              an...

$ decompress-decrypt decompress --help
Usage: decompress-decrypt decompress [OPTIONS]

  Simple program that decompresses an input file and writes it to an output
  file.

Options:
  -i, --input-file-path TEXT   The path of the input file, local or S3
                               (s3://...)
  -o, --output-file-path TEXT  The path of the output file, local or S3
                               (s3://...)
  --help                       Show this message and exit.

$ decompress-decrypt decrypt --help
Usage: decompress-decrypt decrypt [OPTIONS]

  Simple program that decrypts an input file and writes it to an output
  file.

Options:
  -i, --input-file-path TEXT   The path of the input file, local or S3
                               (s3://...)
  -o, --output-file-path TEXT  The path of the output file, local or S3
                               (s3://...)
  -f, --fernet-key TEXT        The decrpytion key.
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

# Launch airflow
docker-compose up
```
