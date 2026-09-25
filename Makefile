CARGO ?= cargo
WASM_TARGET ?= wasm32-unknown-unknown
WASM_BUILD_FLAGS ?= --target $(WASM_TARGET) --release --no-default-features

.PHONY: all preflight build test fmt fmt-check lint clippy wasm clean install-hooks

all: fmt-check lint test

## Verify the local toolchain can build this crate.
preflight:
	@$(CARGO) --version
	@rustc --version
	@rustup target list --installed | grep -q '$(WASM_TARGET)' \
		&& echo "wasm target: $(WASM_TARGET) installed" \
		|| (echo "missing wasm target: run 'rustup target add $(WASM_TARGET)'" && exit 1)

## Build the contract for the host target.
build:
	$(CARGO) build

## Run the unit test suite.
test:
	$(CARGO) test

## Format the whole workspace.
fmt:
	$(CARGO) fmt --all

## Check formatting without rewriting files.
fmt-check:
	$(CARGO) fmt --all --check

## Lint with warnings denied.
lint clippy:
	$(CARGO) clippy --all-targets --all-features -- -D warnings

## Build the optimized wasm artifact for on-chain deployment.
wasm:
	$(CARGO) build $(WASM_BUILD_FLAGS)

clean:
	$(CARGO) clean

## Install the pre-commit hook that runs fmt and clippy.
install-hooks:
	@mkdir -p .git/hooks
	@cp .hooks/pre-commit .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "installed .git/hooks/pre-commit"
