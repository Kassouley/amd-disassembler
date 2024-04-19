
CC		   = gcc
SRC        = amd-disassembler.c
EXEC       = amd-disassembler
ROCM_PATH ?= /opt/rocm
CFLAGS     = -I$(ROCM_PATH)/include/amd_comgr/ -L$(ROCM_PATH)/lib/ -lamd_comgr

$(EXEC) : $(SRC)
	$(CC) -o $@ $^ $(CFLAGS)

clean :
	rm $(EXEC)
