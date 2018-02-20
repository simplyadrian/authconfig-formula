test-setup:
	# this should be run in a virtualenv
	pip install Jinja2

test_centos_master_2017.7.2:
	cd authconfig && \
	  python tests/filltmpl.py centos_master_2017.7.2 && \
	  docker build --force-rm -t "authconfig:salt-state-testing-centos_master_2017.7.2" -f "tests/Dockerfile.centos_master_2017.7.2" . && \
	  cd tests && ./run-tests.sh centos_master_2017.7.2

test_debian_master_2017.7.2:
	cd authconfig && \
	  python tests/filltmpl.py debian_master_2017.7.2 && \
	  docker build --force-rm -t "authconfig:salt-state-testing-debian_master_2017.7.2" -f "tests/Dockerfile.debian_master_2017.7.2" . && \
	  cd tests && ./run-tests.sh debian_master_2017.7.2

test_ubuntu_master_2017.7.2:
	cd authconfig && \
	  python tests/filltmpl.py ubuntu_master_2017.7.2 && \
	  docker build --force-rm -t "authconfig:salt-state-testing-ubuntu_master_2017.7.2" -f "tests/Dockerfile.ubuntu_master_2017.7.2" . && \
	  cd tests && ./run-tests.sh ubuntu_master_2017.7.2

test_ubuntu_master_2016.11.3:
	cd authconfig && \
	  python tests/filltmpl.py ubuntu_master_2016.11.3 && \
	  docker build --force-rm -t "authconfig:salt-state-testing-ubuntu_master_2016.11.3" -f "tests/Dockerfile.ubuntu_master_2016.11.3" . && \
	  cd tests && ./run-tests.sh ubuntu_master_2016.11.3

clean-local:
	find . -name '*.pyc' -exec rm '{}' ';'
	rm -rf authconfig/tests/Dockerfile*
	rm -rf authconfig/tests/pytests/tests/.pytest_cache
	rm -rf authconfig/tests/pytests/tests/__pycache__
