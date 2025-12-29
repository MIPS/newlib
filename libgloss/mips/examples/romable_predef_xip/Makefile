# Copyright 2015, Imagination Technologies Limited and/or its
#                 affiliated group companies.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its
# contributors may be used to endorse or promote products derived from this
# software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

# Variables that mipshal.mk will expand to compiler/linker arguments must be
# defined before inclusion of mipshal.mk

# Indicate the application should start via the reset vector
ROMABLE = 1

ifeq ($(CORE), P5600)
 DEFINES =  -DC0_CONFIG0_VALUE=0xB6040483
 DEFINES += -DC0_CONFIG1_VALUE=0xFEA3519B
 DEFINES += -DC0_CONFIG2_VALUE=0x80000000
 DEFINES += -DC0_CONFIG3_VALUE=0xBF8032A8
 DEFINES += -DC0_CONFIG4_VALUE=0xc01c0000
 DEFINES += -DC0_CONFIG5_VALUE=0x10000038
 DEFINES += -DC0_WATCHHI_VALUE=0x00000000
 OBJS += init_l23caches_predef.o
 override ABI = 32
 override ENDIAN = EL
 override MIPS_TOOLCHAIN = mips-mti-elf
 APP_START = 0x80000000
else
 ifeq ($(CORE), I6400)
  DEFINES =  -DC0_CONFIG0_VALUE=0x80004A05
  DEFINES += -DC0_CONFIG1_VALUE=0x9EAB559B
  DEFINES += -DC0_CONFIG2_VALUE=0x80000000
  DEFINES += -DC0_CONFIG3_VALUE=0xFC8031E9
  DEFINES += -DC0_CONFIG4_VALUE=0xD0FC0227
  DEFINES += -DC0_CONFIG5_VALUE=0x00000098
  DEFINES += -DC0_WATCHHI_VALUE=0x80000000
  DEFINES += -DC0_WATCHHI1_VALUE=0x80000000
  DEFINES += -DC0_WATCHHI2_VALUE=0x80000000
  DEFINES += -DC0_WATCHHI3_VALUE=0x00000000
  DEFINES += -DC0_CMGCRBASE_VALUE=0x01fbf800
  DEFINES += -DGCR_L2_CONFIG_VALUE=0x00000000
  OBJS = init_cm3l2_predef.o
  override ABI = 64
  override ENDIAN = EL
  override MIPS_TOOLCHAIN = mips-img-elf
  APP_START = 0xFFFFFFFF80000000
 else
  $(error Please specify a core using CORE=(P5600|I6400))
 endif
endif

include ${MIPS_ELF_ROOT}/share/mips/rules/mipshal.mk

ifeq ($(ENABLE_XPA), 1)
  DEFINES += -DENABLE_XPA=1
endif

OBJS += romable_predef_xip.o reset_predef.o init_caches_predef.o init_cp0_predef.o
OBJS += init_tlb_predef.o corecheck_predef.o
APP = romable_predef_xip.elf

CFLAGS += -g -O1 $(DEFINES)
LDFLAGS += -g -Wl,--defsym,__getargs=0 -Wl,--defsym,__exception_handle_verbose=0
LDFLAGS += -Wl,--defsym,__register_excpt_boot=0 -Wl,--defsym,__exception_entry=0
LDFLAGS += -Wl,--defsym,__register_excpt_handler=0
LDFLAGS += -Wl,--defsym,__isr_vec_007=0 -Wl,--defsym,__uhi_break=0
LDFLAGS += -Wl,--defsym,__ebase_size=0 -Wl,--defsym,__isr_vec_count=0
LDFLAGS += -Wl,--defsym,__xip=1
LDFLAGS += -nostartfiles -nostdlib

all: $(APP)

$(APP): $(OBJS) crt0.o
	$(LD) $(LDFLAGS) $(OBJS) -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $^ -o $@

crt0.o: $(MIPS_ELF_ROOT)/share/mips/hal/minicrt.S
	$(CC) $(CFLAGS) -c $^ -o $@

%.o: $(MIPS_ELF_ROOT)/share/mips/boot/%.S
	$(CC) $(CFLAGS) -c $^ -o $@

.PHONY: clean
clean:
	rm -f $(APP) $(OBJS) crt0.o
