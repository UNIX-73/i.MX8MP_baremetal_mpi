include make/Folders.mk

OPT_LEVEL   ?= -O2
DEFINES     ?=

MARCH       ?= armv8-a
MCPU        ?= cortex-a53+simd
RS_TARGET	=  aarch64-unknown-none
CSTD		:= gnu23 	# Project uses c23 standard attributes

ASM_FLAGS   = $(DEFINES)
#TODO: delete -mgeneral-regs-only when mmu is implemented
C_FLAGS     = $(OPT_LEVEL) $(DEFINES) -std=$(CSTD) -mgeneral-regs-only -Wall -Wextra -Werror -ffreestanding -nostdlib -nostdinc -nostartfiles -x c -I$(INCLUDE_DIR) -march=$(MARCH) -mcpu=$(MCPU)
LD_FLAGS    = -T linker.ld -Map $(MAP)

$(OBJ_DIR)/drivers/%.o: C_FLAGS += -DDRIVERS
$(OBJ_DIR)/kernel/%.o: C_FLAGS += -DKERNEL
$(OBJ_DIR)/lib/%.o: C_FLAGS += -DLIB
$(OBJ_DIR)/boot/%.o: C_FLAGS += -DBOOT
$(OBJ_DIR)/arm/%.o: C_FLAGS += -DARM