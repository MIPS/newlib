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

ISR_VEC_SPACE = 64
include ${MIPS_ELF_ROOT}/share/mips/rules/mipshal.mk

CFLAGS += -g -DISR_VEC_SPACE=$(ISR_VEC_SPACE)
LDFLAGS += -g

OBJS = isr_vector_space.o excpt_isr.o
APP = isr_vector_space.elf

all: $(APP)

$(APP): $(OBJS)
	$(LD) $(LDFLAGS) $^ -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $^ -o $@

%.o: %.S
	$(CC) $(CFLAGS) -c $^ -o $@

.PHONY: clean
clean:
	rm -f $(APP) $(OBJS)
