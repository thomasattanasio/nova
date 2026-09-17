TARGET := x86_64-elf

CC := $(TARGET)-gcc
LD := $(TARGET)-ld
AS := nasm

CFLAGS := -std=c11 -ffreestanding -m32 -fno-stack-protector -fno-pie -fno-pic -fno-asynchronous-unwind-tables -fno-unwind-tables -Wall -Wextra
CPPFLAGS := -Iinclude
LDFLAGS := -m elf_i386

BUILD_DIR := build
ISO_DIR := $(BUILD_DIR)/iso
KERNEL := $(BUILD_DIR)/kernel.bin
ISO := $(BUILD_DIR)/nova.iso

KERNEL_SOURCES := \
	src/kernel/kernel.c \
	src/kernel/terminal.c

KERNEL_OBJECTS := \
	$(BUILD_DIR)/kernel.o \
	$(BUILD_DIR)/terminal.o

.PHONY: all check-toolchain kernel iso run clean

all: iso

check-toolchain:
	@command -v $(CC) >/dev/null || (echo "Error: $(CC) not found."; exit 1)
	@command -v $(LD) >/dev/null || (echo "Error: $(LD) not found."; exit 1)
	@command -v $(AS) >/dev/null || (echo "Error: $(AS) not found."; exit 1)
	@command -v grub-file >/dev/null || (echo "Error: grub-file not found."; exit 1)
	@command -v grub-mkrescue >/dev/null || (echo "Error: grub-mkrescue not found."; exit 1)
	@echo "NOVA toolchain is ready."

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/entry.o: src/arch/x86_64/boot/entry.asm | $(BUILD_DIR)
	$(AS) -f elf32 $< -o $@

$(BUILD_DIR)/kernel.o: src/kernel/kernel.c | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/terminal.o: src/kernel/terminal.c | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(KERNEL): $(BUILD_DIR)/entry.o $(KERNEL_OBJECTS) scripts/linker.ld
	$(LD) $(LDFLAGS) -T scripts/linker.ld -o $@ $(BUILD_DIR)/entry.o $(KERNEL_OBJECTS)

kernel: check-toolchain $(KERNEL)
	grub-file --is-x86-multiboot2 $(KERNEL)

$(ISO): $(KERNEL) boot/grub/grub.cfg
	mkdir -p $(ISO_DIR)/boot/grub
	cp $(KERNEL) $(ISO_DIR)/boot/kernel.bin
	cp boot/grub/grub.cfg $(ISO_DIR)/boot/grub/grub.cfg
	grub-mkrescue -o $@ $(ISO_DIR)

iso: check-toolchain $(ISO)

run: iso
	env -i \
	PATH=/usr/bin:/bin \
	HOME="$(HOME)" \
	DISPLAY="$(DISPLAY)" \
	XAUTHORITY="$(XAUTHORITY)" \
	qemu-system-x86_64 -cdrom "$(ISO)"

clean:
	rm -rf $(BUILD_DIR)