NAME := webhook-hugo
TAG := v1.0.0
IMAGE_NAME := steffenblake/$(NAME)

.PHONY: help build push clean

help:
	@printf "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)\n"

build: ## Builds docker image latest
	docker build --pull -t $(IMAGE_NAME):latest .

push: ## Pushes the docker image to hub.docker.com
	# Don't --pull here, we don't want any last minute upsteam changes
	docker build -t $(IMAGE_NAME):$(TAG) .
	docker tag $(IMAGE_NAME):$(TAG) $(IMAGE_NAME):latest
	docker push $(IMAGE_NAME):$(TAG)
	docker push $(IMAGE_NAME):latest

clean: ## Remove built images
	-docker rmi $(IMAGE_NAME):latest
	-docker rmi $(IMAGE_NAME):$(TAG)

bash: ## Run bash in the container
	docker run --rm -it $(IMAGE_NAME):latest bash
