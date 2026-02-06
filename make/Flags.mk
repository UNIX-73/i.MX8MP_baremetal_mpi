include make/Folders.mk

OPT_LEVEL   ?= -O2
DEFINES     ?=

MARCH       ?= armv8-a
MCPU        ?= cortex-a53+simd
RS_TARGET	=  aarch64-unknown-none
CSTD		:= gnu23 	# Project uses c23 standard attributes
CPPSTD		:= gnu++20 

ASM_FLAGS   = $(DEFINES) -I$(INCLUDE_DIR)

#TODO: delete -mgeneral-regs-only when mmu is implemented
CX_FLAGS 	= $(OPT_LEVEL) $(DEFINES) -mgeneral-regs-only -Wall -Wextra -Werror -ffreestanding -nostdlib -nostdinc -nostartfiles -I$(INCLUDE_DIR) -march=$(MARCH) -mcpu=$(MCPU)

C_FLAGS     = $(CX_FLAGS) -x c -std=$(CSTD)
CPP_FLAGS   = $(CX_FLAGS) -x c++ -std=$(CPPSTD)

LD_FLAGS    = -T linker.ld -Map $(MAP)

$(OBJ_DIR)/drivers/%.o: C_FLAGS += -DDRIVERS
$(OBJ_DIR)/kernel/%.o: C_FLAGS += -DKERNEL
$(OBJ_DIR)/lib/%.o: C_FLAGS += -DLIB
$(OBJ_DIR)/boot/%.o: C_FLAGS += -DBOOT
$(OBJ_DIR)/arm/%.o: C_FLAGS += -DARM