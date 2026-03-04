DOCKER_IMAGE=pinkava/web

templates:
	cp -R .templates/ debian-php-82
	cp -R .templates/ debian-php-83
	cp -R .templates/ debian-php-84
	cp -R .templates/ debian-php-85

_docker-build-%: VERSION=$*
_docker-build-%:
	docker buildx build \
		--pull \
		-t ${DOCKER_IMAGE}:${VERSION} \
		./debian-${VERSION}

docker-build-php-82: _docker-build-php-82
docker-build-php-83: _docker-build-php-83
docker-build-php-84: _docker-build-php-84
docker-build-php-85: _docker-build-php-85

docker-build-all:
	$(MAKE) docker-build-php-82
	$(MAKE) docker-build-php-83
	$(MAKE) docker-build-php-84
	$(MAKE) docker-build-php-85


docker-test-all:
	$(MAKE) _docker-test-php-82
	$(MAKE) _docker-test-php-83
	$(MAKE) _docker-test-php-84
	$(MAKE) _docker-test-php-85

_docker-test-%: VERSION=$*
_docker-test-%:
	docker run --rm -d --name dockette-web-${VERSION} -p 8000:80 ${DOCKER_IMAGE}:${VERSION}
	sleep 5
	curl -f -Li localhost:8000
	docker stop dockette-web-${VERSION}
