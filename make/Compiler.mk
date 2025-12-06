# Compiler
COMPILER 	= aarch64-none-elf-
CC 			= $(COMPILER)gcc
ASM 		= $(CC)
CPP 		= $(COMPILER)g++
LD 			= $(COMPILER)ld
OBJCOPY 	= $(COMPILER)objcopy
OBJDUMP 	= $(COMPILER)objdump

# Rust
RUST		= cargo