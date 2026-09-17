TARGET := x86_64-elf

CC := $(TARGET)-gcc
LD := $(TARGET)-ld
AS := nasm

CFLAGS := -std=c11 -ffreestanding -fno-stack-protector -Wall -Wextra
LDFLAGS :=

BUILD_DIR := build

.PHONY: all check-toolchain clean

all: check-toolchain

check-toolchain:
	@command -v $(CC) >/dev/null || (echo "Error: $(CC) not found."; exit 1)
	@command -v $(LD) >/dev/null || (echo "Error: $(LD) not found."; exit 1)
	@command -v $(AS) >/dev/null || (echo "Error: $(AS) not found."; exit 1)
	@echo "NOVA toolchain is ready."

clean:
	rm -rf $(BUILD_DIR)