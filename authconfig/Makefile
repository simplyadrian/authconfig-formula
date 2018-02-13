PWD = $(shell pwd)
GIT_COMMIT=$(shell git rev-parse HEAD)
MY_DIR=$(shell basename "$(CURDIR)")
TEST_LABEL_KEY=salt-state-testing
TEST_TAG=${TEST_LABEL_KEY}

define DOCKER_BODY
ARG TEST_LABEL
ARG TEST_LABEL_KEY
ARG TEST_TAG
ARG GIT_COMMIT=unknown
LABEL $$TEST_LABEL_KEY=$$TEST_LABEL
LABEL git-commit=$$GIT_COMMIT
LABEL TEST_TAG=$$TEST_TAG
ADD tests/ /srv/salt
ADD tests/pillar/ /srv/pillar
ADD . /srv/salt/$$TEST_LABEL
WORKDIR /srv/salt
RUN sed -i "s/#master: salt/master: localhost/g" /etc/salt/minion
endef

export DOCKER_BODY
.PHONY: default
centos_test_build:
	echo 'FROM simplyadrian/allsalt:centos_master_2017.7.2' > tests/Dockerfile
	echo "$$DOCKER_BODY" >> tests/Dockerfile
	docker build --build-arg TEST_LABEL="${MY_DIR}" \
	  --build-arg TEST_LABEL_KEY=${TEST_LABEL_KEY} \
	  --build-arg GIT_COMMIT=${GIT_COMMIT} \
	  --build-arg TEST_TAG=${TEST_TAG} \
	  --force-rm -t "${MY_DIR}":salt-state-testing-centos -f tests/Dockerfile .
	sh tests/pytests/run-tests.sh salt-state-testing-centos

debian_test_build:
	echo 'FROM simplyadrian/allsalt:debian_master_2017.7.2' > tests/Dockerfile
	echo "$$DOCKER_BODY" >> tests/Dockerfile
	docker build --build-arg TEST_LABEL="${MY_DIR}" \
	  --build-arg TEST_LABEL_KEY=${TEST_LABEL_KEY} \
	  --build-arg GIT_COMMIT=${GIT_COMMIT} \
	  --build-arg TEST_TAG=${TEST_TAG} \
	  --force-rm -t "${MY_DIR}":salt-state-testing-debian -f tests/Dockerfile .
	sh tests/pytests/run-tests.sh salt-state-testing-debian with-pip

ubuntu_test_build:
	echo 'FROM simplyadrian/allsalt:ubuntu_master_2017.7.2' > tests/Dockerfile
	echo "$$DOCKER_BODY" >> tests/Dockerfile
	docker build --build-arg TEST_LABEL="${MY_DIR}" \
	  --build-arg TEST_LABEL_KEY=${TEST_LABEL_KEY} \
	  --build-arg GIT_COMMIT=${GIT_COMMIT} \
	  --build-arg TEST_TAG=${TEST_TAG} \
	  --force-rm -t "${MY_DIR}":salt-state-testing-ubuntu -f tests/Dockerfile .
	sh tests/pytests/run-tests.sh salt-state-testing-ubuntu with-pip

ubuntu_2016_test_build:
	echo 'FROM simplyadrian/allsalt:ubuntu_master_2016.11.3' > tests/Dockerfile
	echo "$$DOCKER_BODY" >> tests/Dockerfile
	docker build --build-arg TEST_LABEL="${MY_DIR}" \
	  --build-arg TEST_LABEL_KEY=${TEST_LABEL_KEY} \
	  --build-arg GIT_COMMIT=${GIT_COMMIT} \
	  --build-arg TEST_TAG=${TEST_TAG} \
	  --force-rm -t "${MY_DIR}":salt-state-testing-ubuntu-2016-11-3 -f tests/Dockerfile .
	sh tests/pytests/run-tests.sh salt-state-testing-ubuntu-2016-11-3 with-pip

remove:
	docker rmi $(shell docker images -q --filter label=TEST_TAG=${TEST_TAG} --filter label=${TEST_LABEL_KEY}="${MY_DIR}")
	rm tests/Dockerfile

clean .IGNORE: remove

test_centos: centos_test_build clean

test_debian: debian_test_build clean

test_ubuntu: ubuntu_test_build clean

test_ubuntu_2016: ubuntu_2016_test_build clean

all: test_centos test_debian test_ubuntu test_ubuntu_2016

clean-local:
	find . -name '*.pyc' -exec rm '{}' ';'
	rm -rf tests/pytests/tests/.pytest_cache
	rm -rf tests/pytests/tests/__pycache__
