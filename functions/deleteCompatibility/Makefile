.PHONY: clean build package deploy logs

PROJECT=compatibility-calculator
ENVIRONMENT=prod
STACK_NAME=delete-compatibility-${ENVIRONMENT}
FUNCTION=DeleteCompatibilityFunction

include ../../properties.mk

CONFIRM_CHANGESET=--confirm-changeset
ifeq ($(CI), true)
	CONFIRM_CHANGESET=--no-confirm-changeset
endif

SAMPACKAGES=compatibility-bucket-test

PACKAGE_TARGET=package
ifeq ($(CI), true)
	PACKAGE_TARGET=
endif

all: clean package deploy

clean:
	rm -rf .aws-sam

build:
	@echo Building with changeset: ${CONFIRM_CHANGESET}
	@echo CI: ${CI}
	sam build --parallel

package: build
	sam package --output-template-file packaged.yaml --s3-bucket ${SAMPACKAGES}

deploy: $(PACKAGE_TARGET)
	sam deploy ${CONFIRM_CHANGESET} \
		--no-fail-on-empty-changeset \
		--no-disable-rollback \
		--template-file packaged.yaml \
		--capabilities CAPABILITY_IAM \
		--stack-name ${STACK_NAME} \
		--region ${REGION} \
		--parameter-overrides Environment=${ENVIRONMENT} \
		--tags Project=${PROJECT} Environment=${ENVIRONMENT}
	@echo Deployed ${STACK_NAME}

logs:
	sam logs --stack-name ${STACK_NAME} -t --name ${FUNCTION}