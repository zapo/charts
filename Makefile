UPSTREAM_GIT_URL = git@github.com:zapo/charts.git
CHARTS_URL = https://zapo.github.io/charts
COMMIT = $(shell git rev-parse --short HEAD)

.PHONY: all clean build release
all: clean build release

clean:
	rm -rf dist-repo

dist-repo:
	git clone --quiet --single-branch -b gh-pages "${UPSTREAM_GIT_URL}" dist-repo

# Build all Helm packages into dist-repo and regenerate the chart index
build: dist-repo
	cd package && \
		docker-compose build && \
		docker-compose run --rm package package.sh "${CHARTS_URL}" dist-repo && \
		cd ../dist-repo && \
		echo "--- Diff" && \
		git diff --stat

# Commit and push the chart index
release:
	cd dist-repo && \
		git add *.tgz index.yaml && \
		git commit --message "Update to zapo/charts@${COMMIT}" && \
		git push origin gh-pages
