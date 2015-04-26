# Copyright 2015, Imagination Technologies Limited and/or its
#                 affiliated group companies.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted under the terms of the MIPS Free To Use 1.0
# license that you will have received with this package. If you haven't
# received this file, please contact Imagination Technologies or see the
# following URL for details.
# http://codescape-mips-sdk.imgtec.com/license/IMG-free-to-use-on-MIPS-license

# Variables that mipshal.mk will expand to compiler/linker arguments must be
# defined before inclusion of mipshal.mk

# Indicate the application should start via the reset vector
ROMABLE = 1
# Default to o32 ABI
ABI ?= 32

# Set up a 1:1 mapping for physical to virtual addresses
ifeq ($(ABI), 64)
  FLASH_START = 0xFFFFFFFFBFC00000
  APP_START = 0xFFFFFFFF80000000
  LDSCRIPT = minimal64_64.ld
else
  FLASH_START = 0xBFC00000
  APP_START = 0x80000000
  LDSCRIPT = minimal32.ld
endif

include ${MIPS_ELF_ROOT}/share/mips/rules/mipshal.mk

CFLAGS += -g
LDFLAGS += -g
OBJS = romable_minimal.o
APP = romable_minimal.elf

all: $(APP)

$(APP): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean
clean:
	rm -f $(APP) $(OBJS)
