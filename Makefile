IMAGE ?= ghcr.io/m4nu5/recon-toolkit
TAG   ?= latest

.PHONY: build run shell lint push

build:
	docker build -t $(IMAGE):$(TAG) .

# Run interactively with ./out mounted at /work for scan outputs.
run:
	docker run --rm -it -v $(PWD)/out:/work -e I_HAVE_AUTHORISATION $(IMAGE):$(TAG)

shell: run

lint:
	@command -v shellcheck >/dev/null 2>&1 || { echo "shellcheck not installed"; exit 1; }
	shellcheck entrypoint.sh scripts/lib/*.sh scripts/recon/*.sh scripts/scan/*.sh
	@command -v hadolint >/dev/null 2>&1 && hadolint Dockerfile || echo "hadolint not installed; skipping Dockerfile lint"

push:
	docker push $(IMAGE):$(TAG)
