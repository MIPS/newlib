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

include ${MIPS_ELF_ROOT}/share/mips/rules/mipshal.mk

ifeq ($(CORE), P5600)
 DEFINES =  -DC0_CONFIG1_VALUE=0xFEA3519B
 DEFINES += -DC0_CONFIG2_VALUE=0x80000000
 DEFINES += -DC0_CONFIG4_VALUE=0xc01c0000
 DEFINES += -DC0_CONFIG5_VALUE=0x10000038
 DEFINES += -DC0_WATCHHI_VALUE=0x00000000
else
 ifeq ($(CORE), I6400)
  DEFINES =  -DC0_CONFIG1_VALUE=0x9EAB559B
  DEFINES += -DC0_CONFIG2_VALUE=0x80000000
  DEFINES += -DC0_CONFIG4_VALUE=0xD0FC0227
  DEFINES += -DC0_CONFIG5_VALUE=0x00000098
  DEFINES += -DC0_WATCHHI_VALUE=0x80000000
  DEFINES += -DC0_WATCHHI1_VALUE=0x80000000
  DEFINES += -DC0_WATCHHI2_VALUE=0x80000000
  DEFINES += -DC0_WATCHHI3_VALUE=0x00000000
 else
  $(error Please specify a core using CORE=(P5600|I6400))
 endif
endif
OBJS = examplepredef.o reset_predef.o init_caches_predef.o init_cp0_predef.o
OBJS += init_l23caches_predef.o

CFLAGS += -g $(DEFINES)
LDFLAGS += -g

all: examplepredef.elf

examplepredef.elf: $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: $(MIPS_ELF_ROOT)/share/mips/boot/%.S
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean
clean:
	rm -f examplepredef.elf $(OBJS)
