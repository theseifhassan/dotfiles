.DEFAULT_GOAL := help

help:            ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*##"}; {printf "  %-15s %s\n", $$1, $$2}'

bootstrap:       ## Full setup from scratch (fresh machine)
	./bootstrap.sh

apply:           ## Run full Ansible playbook
	ansible-playbook playbook.yml

apply-%:         ## Run a single role (e.g., make apply-git)
	ansible-playbook playbook.yml -t $*

lint:            ## Lint all roles with ansible-lint
	ansible-lint playbook.yml
