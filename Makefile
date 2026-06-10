# Convenience targets for lic development and CI slices.
.PHONY: test test-proxy test-proxy-c test-proxy-integration \
        test-proxy-real-site test-proxy-nextjs test-proxy-gitlab test-proxy-lb test-proxy-all

test-proxy:
	sh test/proxy/run-proxy-tests.sh --all

test-proxy-c:
	sh test/proxy/run-proxy-tests.sh --unit

test-proxy-integration:
	sh test/proxy/run-proxy-tests.sh --integration-only --skip-docker

test-proxy-real-site:
	sh test/proxy/run-proxy-tests.sh --real-site

test-proxy-nextjs:
	sh test/proxy/run-proxy-tests.sh --nextjs

test-proxy-gitlab:
	sh test/proxy/run-proxy-tests.sh --gitlab

test-proxy-lb:
	sh test/proxy/run-proxy-tests.sh --lb

test-proxy-all:
	sh test/proxy/run-proxy-tests.sh --all

# Default test entry: fast C proxy gate (no docker).
test: test-proxy-c
