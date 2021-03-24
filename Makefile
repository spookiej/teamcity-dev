DOCKER_COMPOSE_FILE ?= docker-compose.yml

OS_TYPE ?= $(shell uname -s | awk '{print tolower($$0)}')
OS_ARCHITECTURE ?= amd64

TEAMCITY_TF_PLUGIN_VERSION=1.0.1
TEAMCITY_TF_PLUGIN_NAME=terraform-provider-teamcity_$(TEAMCITY_TF_PLUGIN_VERSION)_$(OS_TYPE)_$(OS_ARCHITECTURE)

TF_PLUGIN_DIR=~/.terraform.d/plugins/$(OS_TYPE)_$(OS_ARCHITECTURE)

.PHONY=up
up: dirs
	@docker-compose -f $(DOCKER_COMPOSE_FILE) up -d

.PHONY=down
down:
	@docker-compose -f $(DOCKER_COMPOSE_FILE) down

.PHONY=dirs
dirs:
	@mkdir -p data/server/data
	@mkdir -p data/server/logs
	@mkdir -p data/buildagent/conf
	@mkdir -p data/buildagent/work
	@mkdir -p data/buildagent/system/git
	@mkdir -p data/buildagent/temp

.PHONY=clean
clean: check-clean
	@rm -r ./data/

.PHONY=check-clean
check-clean:
	@printf "Are you sure? [y/N]: " && read ans && [ $${ans:-N} = y ]

.PHONY=install-tf
install-tf:
	@cd terraform && asdf install

.PHONY=install-plugins
install-plugins: unzip-plugins

$(TF_PLUGIN_DIR):
	@mkdir -p $(TF_PLUGIN_DIR)

.PHONY=download-plugins
download-plugins:
	curl -L https://github.com/cvbarros/terraform-provider-teamcity/releases/download/\
	v$(TEAMCITY_TF_PLUGIN_VERSION)/$(TEAMCITY_TF_PLUGIN_NAME).zip \
	-o $(TEAMCITY_TF_PLUGIN_NAME).zip

.PHONY=unzip-plugins
unzip-plugins: download-plugins $(TF_PLUGIN_DIR)
	unzip -j $(TEAMCITY_TF_PLUGIN_NAME).zip \
	terraform-provider-teamcity_v$(TEAMCITY_TF_PLUGIN_VERSION) \
	-d $(TF_PLUGIN_DIR) && \
	rm $(TEAMCITY_TF_PLUGIN_NAME).zip
