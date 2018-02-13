#!/bin/bash
set -ev

test -z $1 && echo "Usage: ${0} CONTAINER_NAME" && exit 1

export CONTAINER_NAME=$1
export MY_DIR="authconfig"
export TEST_PATH="/opt/tests"

docker run -d --rm \
  -v $(pwd)/tests/pytests/tests:${TEST_PATH} \
  -h ${CONTAINER_NAME} \
  --name ${CONTAINER_NAME} \
  -it ${MY_DIR}:${CONTAINER_NAME}


if [[ ! -z "${2}" && "${2}"="with-pip" ]]; then
    docker exec ${CONTAINER_NAME} salt-call --local pkg.install python-pip refresh=True
fi

docker exec ${CONTAINER_NAME} salt-call --local pip.install pytest
docker exec ${CONTAINER_NAME} salt-call --local cmd.run "pytest -s ${TEST_PATH}"
docker kill ${CONTAINER_NAME}
