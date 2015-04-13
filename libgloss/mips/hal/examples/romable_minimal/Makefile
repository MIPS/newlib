
# Copyright Imagination Technologies, 2015
#
# Relevant licensing information. @FINDME 

# Variables that mipsboot.mk will expand to linker arguments *must*
# be defined and exported before inclusion of mipsbook.mk . 
#
# make will take the value of variables defined in the environment
# rather than the export lines here.

# Define flash start as the uncached reset vector address
ROMABLE = 1
ifeq ($(ABI), 64)
  FLASH_START = 0xFFFFFFFFBFC00000
  APP_START = 0xFFFFFFFF80000000
  LDSCRIPT = minimal64_64.ld
else
  FLASH_START = 0xBFC00000
  APP_START = 0x80000000
  LDSCRIPT = minimal32.ld
endif

# Set default ABI to o32
ABI ?= 32

include ${MIPS_ELF_ROOT}/share/mips/rules/mipshal.mk

CFLAGS += -g
LDFLAGS += -g
OBJS = minimal.o

all: minimal.elf

minimal.elf: $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@


.PHONY: clean
clean:
	rm -f minimal.elf $(OBJS)
