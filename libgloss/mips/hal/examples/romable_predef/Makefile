
# Copyright Imgination Technologies, 2015
#
# Relevant licensing information. @FINDME 

# Variables that mipsboot.mk will expand to linker arguments *must*
# be defined inclusion of mipsbook.mk . 
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

include ${MIPS_ELF_ROOT}/share/mips/rules/mipshal.mk

ifeq ($(CORE), P5600)
 DEFINES =  -DC0_CONFIG1_VALUE=0xFEA3519B
 DEFINES += -DC0_CONFIG2_VALUE=0x80000000
 DEFINES += -DC0_CONFIG4_VALUE=0xc01c0000
 DEFINES += -DC0_CONFIG5_VALUE=0x10000038
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
OBJS = bootexample.o reset_predef.o init_caches_predef.o init_cp0_predef.o
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
