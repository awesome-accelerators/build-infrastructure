KEY_PAIR :=.secrets/paris-secret.pem

help: ## output this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## INFRA: build entire infrastructure
	terraform init
	terraform validate
	terraform apply

destroy: ## INFRA: destroy the infrastructure
	terraform destroy

ssh: ## INFRA: open shell to remote IP	
	@read -p "Remote IP:" ipaddress && ssh -i $(KEY_PAIR) ec2-user@$$ipaddress

scpi: ## INFRA: copy remote file to local - interactive mode
	@read -p "Remote IP:" ip && \
	read -p "Remote Path:" remotepath && \
	read -p "Local Path:" localpath && \
	make scp ip=$$ip remotepath=$$remotepath localpath=$$localpath
	
scp: ## INFRA copy remote file to local: $ make scp ip=35.181.59.71 remotepath=/var/lib/jenkins/config.xml localpath=config.xml
	@scp -i $(KEY_PAIR) -o 'StrictHostKeyChecking no' ec2-user@$$ip:$$remotepath $$localpath

