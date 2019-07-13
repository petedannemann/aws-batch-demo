S3_BUCKET=aws-batch-example
REPO_NAME=aws-batch-demo
AWS_ACCOUNT_NUMBER=301408662608

copy-s3:
	aws s3 cp assets/lorem_ipsum.txt.gz s3://${S3_BUCKET}

build:
	docker build -t ${REPO_NAME} .

tag:
	docker tag ${REPO_NAME}:latest ${AWS_ACCOUNT_NUMBER}.dkr.ecr.us-east-1.amazonaws.com/${REPO_NAME}:latest

push: build tag
	$(aws ecr get-login --no-include-email --region us-east-1)
	docker push ${AWS_ACCOUNT_NUMBER}.dkr.ecr.us-east-1.amazonaws.com/${REPO_NAME}:latest