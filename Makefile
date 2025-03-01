lint:
	@$(MAKE) lint-ruff
	@$(MAKE) lint-format
	@$(MAKE) lint-mypy

test:
	pytest -vvv -n 7

lint-mypy:
	@mypy .

lint-ruff:
	@ruff check .

lint-format:
	@ruff format --check --quiet

fmt:
	@ruff format
	@ruff check --fix

patch:
	@bumpversion --commit --tag version

build-status:
	@curl -L \
		-H "Accept: application/vnd.github+json" \
		-H "X-GitHub-Api-Version: 2022-11-28" \
		https://api.github.com/repos/kunansy/TrackerSpeechRecognizer/actions/runs \
		| jq '[.workflow_runs | .[] | select(.name == "Build docker image")] | .[0] | .name,.display_title,.status,.conclusion'

CURRENT_TAG := $(shell git describe --tags --abbrev=0)
LAST_TAG := $(shell git describe --tags --abbrev=0 HEAD^)
IMAGE_LINE := $(shell cat docker-compose.yml | grep -n "image: kunansy/tracker_speech_recognizer" | cut -f1 -d:)

deploy:
	@echo "${LAST_TAG} -> ${CURRENT_TAG}"
	@ssh tracker "cd tracker; sed -i -E '${IMAGE_LINE} s/:[0-9]+/:${CURRENT_TAG}/' docker-compose.yml; docker compose up -d --build --force-recreate tracker-speech-recognizer; sleep 2; docker ps --filter name=tracker-speech-recognizer --format json | jq '.Image,.State,.Status'"

run:
	PYTHONPATH=. uvicorn speech_recognizer.main:app --host 127.0.0.1 --port 9998 --reload --loop uvloop

.PHONY: all
all: lint test lint-format lint-mypy lint-ruff fmt patch run
