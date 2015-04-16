# Copyright 2015, Imagination Technologies Limited and/or its 
#         affiliated group companies.
# 
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted under the terms of the MIPS Free To Use 1.0 
# license that you will have received with this package. If you haven't 
# received this file, please contact Imagination Technologies or see the 
# following URL for details.
# http://codescape-mips-sdk.imgtec.com/license/IMG-free-to-use-on-MIPS-license

# Variables that mipshal.mk will expand to compiler/linker arguments must be 
# defined before inclusion of mipshal.mk

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
