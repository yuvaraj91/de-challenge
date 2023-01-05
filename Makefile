REPO_ROOT ?= $(shell git rev-parse --show-toplevel)
AIRFLOW_WEBSERVER_CONTAINER = airflow-webserver
AIRFLOW_SCHEDULER_CONTAINER = airflow-scheduler
VENV = ./venv

BOLD=$(shell tput bold)
RED=$(shell tput setaf 1)
GREEN=$(shell tput setaf 2)
YELLOW=$(shell tput setaf 3)
RESET=$(shell tput sgr0)

.PHONY: default build clean-venv init-venv airflow-down airflow-up isort-fix flake8 pytest test database-up

AIRFLOW_MESSAGE = "Login to Airflow at $(GREEN)http://localhost:8080$(RESET)\
\nUsername: $(GREEN)airflow$(RESET)\
\nPassword: $(GREEN)airflow$(RESET)\
\nWhen running for the first time, it can take up to 3 minutes before the user is available.\
\nYou can run $(BOLD)docker logs --follow data-airflow-init-1$(RESET) to see if the user is being created."

default:
	@echo "The following commands are available:"
	@echo " init-venv - initialize a virtual environment"
	@echo " airflow-up - bring airflow up"
	@echo " airflow-down - bring airflow down"
	@echo " airflow-webserver-logs - print airflow webserver logs continuously"
	@echo " airflow-scheduler-logs - print airflow scheduler logs continuously"
	@echo " airflow-webserver-shell - attach to the webserver container running airflow"
	@echo " airflow-scheduler-shell - attach to the scheduler container running airflow"
	@echo " isort-fix - fix the imports in Python files"
	@echo " flake8 - Check python code formatting based on flake8"
	@echo " pytest - Run unit tests"
	@echo " test - Fix imports, code style, and run unit tests"

.PHONY: activate
activate:
ifneq (,$(wildcard $(VENV)))
	. $(VENV)/bin/activate
else
	@echo "Run $(BOLD)make init-venv $(RESET) to initialize a venv"
endif

.PHONY: build
build:
	@docker-compose build

.PHONY: airflow-up
airflow-up: airflow-down build
	@docker-compose up -d
	@docker exec -it ${AIRFLOW_WEBSERVER_CONTAINER} airflow users create --username airflow --password airflow --firstname admin --lastname admin --role Admin --email airflow@admin.org
	@echo $(AIRFLOW_MESSAGE)

.PHONY: airflow-down
airflow-down:
	@docker-compose down

.PHONY: airflow-webserver-logs
airflow-webserver-logs:
	@docker logs --follow $(AIRFLOW_WEBSERVER_CONTAINER)

.PHONY: airflow-scheduler-logs
airflow-scheduler-logs:
	@docker logs --follow $(AIRFLOW_SCHEDULER_CONTAINER)

.PHONY: airflow-webserver-shell
airflow-webserver-shell:
	@docker exec -it $(AIRFLOW_WEBSERVER_CONTAINER) /bin/bash

.PHONY: airflow-scheduler-shell
airflow-scheduler-shell:
	@docker exec -it $(AIRFLOW_SCHEDULER_CONTAINER) /bin/bash

.PHONY: clean-local
clean-local:
	@rm -rf logs
	@rm -f airflow.cfg
	@rm -f airflow.db
	@rm -f webserver_config.py

.PHONY: clean-metadata-db
clean-metadata-db: airflow-down
	@rm -rf postgres_data
	@echo "Folder $(BOLD)postgres_data$(RESET) was removed!"

.PHONY: clean-venv
clean-venv:
	@rm -rf venv

.PHONY: init-venv
init-venv: clean-venv
	pip3 install virtualenv; \
	virtualenv venv --python=python3.9; \
	. ./venv/bin/activate; \
	pip3 install -r requirements-dev.txt; \
	pip3 install -r requirements-providers.txt; \
	pip3 install -r requirements.txt;

.PHONY: init-local
init-local: clean-local
	. ./venv/bin/activate; \
	./.local/init

.PHONY: flake8
flake8:
	. ./venv/bin/activate; \
	python3 -m flake8 .

.PHONY: isort-fix
isort-fix:
	. ./venv/bin/activate; \
	python3 -m isort . --skip venv --skip logs

.PHONY: pytest
pytest:
	. ./venv/bin/activate; \
	AIRFLOW_HOME=$(REPO_ROOT) python3 -m pytest tests -vv --disable-pytest-warnings

.PHONY: test
test: isort-fix flake8 pytest
