.PHONY: validate build
IMAGE_NAME ?= mtls-transmitter
IMAGE_TAG ?= $(shell git rev-parse HEAD)

validate: format
	#==> Verify modules.
	go mod verify
	#==> It's worth running 'go test' to make sure things compile correctly.
	go test -race ./...

format:
	#==> Verify and update formatting, don't forget to commit on changes.
	go fmt ./...

build:
	go build -o mtls-transmitter ./cmd/transmitter

image: validate
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) -f Dockerfile .
	docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(IMAGE_NAME):latest

up-d: ## Up all or c=<name> containers in background
	docker-compose -f $(or $(DOCKER_COMPOSE_FILE), docker-compose.yaml) up -d $(c)


