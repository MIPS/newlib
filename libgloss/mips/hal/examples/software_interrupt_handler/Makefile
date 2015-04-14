
# Copyright Imgination Technologies, 2015
#
# Relevant licensing information. @FINDME 

# Variables that mipshal.mk will expand to linker arguments must
# be defined before inclusion of mipsbook.mk . 
#
# make will take the value of variables defined in the environment
# rather than the lines here.

include ${MIPS_ELF_ROOT}/share/mips/rules/mipshal.mk

CFLAGS += -g
LD_FLAGS += -g

OBJS = swtest.o

swtest.elf: $(OBJS)
	$(LD) $^ $(LDFLAGS) -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $^ -o $@

.PHONY: clean
clean:
	rm -f swtest.elf $(OBJS)
