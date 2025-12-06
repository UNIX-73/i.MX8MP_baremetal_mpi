SRC_S   = $(shell find $(SRC_DIR) -name '*.S')
SRC_C   = $(shell find $(SRC_DIR) -name '*.c')
SRC_CPP = $(shell find $(SRC_DIR) -name '*.cpp')
SRC_RS	= $(shell find $(SRC_DIR) -name '*.rs')
OBJ 	= $(patsubst $(SRC_DIR)/%, $(OBJ_DIR)/%, \
       	  $(SRC_S:.S=.o) $(SRC_C:.c=.o) $(SRC_CPP:.cpp=.o) )
DISASM 	= $(shell find $(OBJ_DIR) -name '*.S')


# --- Output ---
KERNEL_FILE = kernel
TARGET      = $(BIN_DIR)/$(KERNEL_FILE).elf
BIN         = $(BIN_DIR)/$(KERNEL_FILE).bin
MAP         = $(MAP_DIR)/$(KERNEL_FILE).map
