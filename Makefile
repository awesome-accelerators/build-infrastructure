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

scp: ## INFRA: copy remote file to local comp
	@read -p "Remote IP:" ipaddress && \
	@read -p "Remote Path:" remotepath && \
	@read -p "Local Path:" localpath && \
	scp -i $(KEY_PAIR) ec2-user@$$ipaddress:$$remotepath $$localpath
