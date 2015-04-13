
# Copyright Imgination Technologies, 2015
#
# Relevant licensing information. @FINDME 

# Variables that mipsboot.mk will expand to linker arguments *must*
# be defined and exported before inclusion of mipsbook.mk . 
#
# make will take the value of variables defined in the environment
# rather than the export lines here.

# Define flash start and the entry point.
ROMABLE = 1
ifeq ($(ABI), 64)
FLASH_START = 0xFFFFFFFFBFC00000
APP_START = 0xFFFFFFFF80000000
else
FLASH_START = 0xBFC00000
APP_START = 0x80000000
endif

ABI ?= 32

include ${MIPS_ELF_ROOT}/share/mips/rules/mipshal.mk

CFLAGS += -g
LDFLAGS += -g
OBJS = bootexample.o

all: bootexample.elf

bootexample.elf: $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@


.PHONY: clean
clean:
	rm -f bootexample.elf $(OBJS)
