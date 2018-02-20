#!/bin/bash
set -ev

test -z $1 && echo "Usage: ${0} OS_ID" && exit 1

export OS_ID=$1

cd ..

docker run --rm \
  -v $(pwd)/tests/pytests/tests:/opt/tests \
  -h "salt-state-testing-${OS_ID}" \
  --name "salt-state-testing-${OS_ID}" \
  -it authconfig:"salt-state-testing-${OS_ID}" \
  pytest -s /opt/tests
