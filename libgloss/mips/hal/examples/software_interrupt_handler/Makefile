# Copyright Imagination Technologies, 2015
#
# Relevant licensing information. @FINDME

# Variables that mipshal.mk will expand to linker arguments must be defined
# before inclusion of mipshal.mk

include ${MIPS_ELF_ROOT}/share/mips/rules/mipshal.mk

CFLAGS += -g
LDFLAGS += -g

OBJS = swtest.o

swtest.elf: $(OBJS)
	$(LD) $^ $(LDFLAGS) -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $^ -o $@

.PHONY: clean
clean:
	rm -f swtest.elf $(OBJS)
