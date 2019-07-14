# All aws assets are named the same thing
AWS_ASSETS_NAME=aws-batch-example
AWS_ACCOUNT_NUMBER=301408662608

copy-s3:
	aws s3 cp assets s3://${AWS_ASSETS_NAME} --recursive

build:
	docker build -t ${AWS_ASSETS_NAME} -f Dockerfile.worker .

tag:
	docker tag ${AWS_ASSETS_NAME}:latest ${AWS_ACCOUNT_NUMBER}.dkr.ecr.us-east-1.amazonaws.com/${AWS_ASSETS_NAME}:latest

push: build tag
	$(aws ecr get-login --no-include-email --region us-east-1)
	docker push ${AWS_ACCOUNT_NUMBER}.dkr.ecr.us-east-1.amazonaws.com/${AWS_ASSETS_NAME}:latest

submit-job:
	aws batch submit-job \
	--job-name ${AWS_ASSETS_NAME} \
	--job-queue ${AWS_ASSETS_NAME} \
	--job-definition ${AWS_ASSETS_NAME}
