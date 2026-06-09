# Convenience targets for lic development and CI slices.
.PHONY: test test-proxy test-proxy-c test-proxy-integration

test-proxy:
	sh test/proxy/run-proxy-tests.sh

test-proxy-c:
	sh test/proxy/run-proxy-tests.sh --c-only

test-proxy-integration:
	sh test/proxy/run-proxy-tests.sh --integration-only --skip-docker

# Default test entry: fast C proxy gate (no docker).
test: test-proxy-c
