.PHONY: build run check

clean: 
	cd kernel && cargo clean
	cd image-builder && cargo clean

build:
	cd kernel && cargo build
	cd image-builder && cargo build

check:
	cd kernel && cargo check
	cd image-builder && cargo check

run: build
	cd image-builder && cargo
	./image-builder/qemu-run.sh