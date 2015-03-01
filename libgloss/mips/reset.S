/*
Copyright (c) 2015, Imagination Technologies Limited and/or its affiliated group companies

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are
permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of
conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list
of conditions and the following disclaimer in the documentation and/or other materials
provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be
used to endorse or promote products derived from this software without specific prior
written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#define _RESETCODE
#define COPY_TO_RAM

#include <mips/regdef.h>
#include <mips/cpu.h>
#include <mips/asm.h>

    .set nomips16
    #undef gp
    .set gp=32
    .set push
    .set nomicromips
LEAF(__reset_vector)
    la    a2, __cpu_init
    mtc0  $0, C0_COUNT		  # Clear cp0 Count (Used to measure boot time.)
    jr    a2
    .space 32			  # Just to cope with a quirk of MIPS malta boards
				  # this can be deleted for anything else.
END(__reset_vector)
    .set pop

LEAF(__cpu_init)

    # Verify the code is here due to a reset and not NMI. If this is an NMI then trigger
    # a debugger breakpoint using a sdbp instruction.

    mfc0  s1, C0_STATUS		  # Read CP0 Status
    ext	  s1, s1, SR_NMISHIFT, 1  # extract NMI
    beqz  s1, init_resources	  # Branch if this is NOT an NMI exception.
    sdbbp			  # Failed assertion: NMI.

init_resources:

    # Init CP0 Status, Count, Compare, Watch*, and Cause.
    jal	  __init_cp0

    # Initialize the L1 instruction cache. (Executing using I$ on return.)
    jal	  __init_icache

    # The changing of Kernel mode cacheability must be done from KSEG1
    # Since the code is executing from KSEG0 It needs to do a jump to KSEG1 change K0
    # and jump back to KSEG0

    la	  a2, __change_k0_cca
    li	  a1, 0xf
    ins	  a2, a1, 29, 1		      # changed to KSEG1 address by setting bit 29
    jalr  a2

    # Initialize the L1 data cache
    jal	  __init_dcache 

    # Allow everything else to be initialized via a hook.
    .weak __boot_init_hook
    la	  a2, __boot_init_hook
    beqz  a0, 1f
    jalr  a2
1:
    # Copy "C" code (main.c) and data to RAM and zero bss
    jal  copy_c2_ram

    # Prepare for eret to _start
    la      ra, $Lall_done		# If main returns then go to all_done:.
    la      v0, _start			# Load the address of the _start entry piint
    mtc0    v0, C0_ERRPC		# Write ErrorEPC with the address of _start
    ehb					# Clear hazards (makes sure write to ErrorPC has completed)
    li	    a0, 0			# UHI compliant null argument setup

    # Return from exception will now execute the application startup code
    eret

$Lall_done:
    # If main returns it will return to this point.  Just spin here.
    b       $Lall_done

END(__cpu_init)

# Inline the code fill the rest of
# space between here and the next exception vector address.

#ifdef C0_CONFIG1_VALUE
#include "init_caches_predef.S"
#endif

/**************************************************************************************
    B O O T   E X C E P T I O N   H A N D L E R S (CP0 Status[BEV] = 1)
**************************************************************************************/
/* NOTE: the linker script must insure that this code starts at start + 0x200 so the exception */
/* vectors will be addressed properly. All .org assume this! */
/* TLB refill, 32 bit task. */
.org 0x200				# TLB refill, 32 bit task.
    sdbbp				# This has the effect of starting the debugger
    nop

#ifdef COPY_TO_RAM
# define s1_all_ones     s1   /* at Will hold 0xffffffff to simplify bit insertion of 1's. */
# define a0_temp_data    a0   /* a0 data to be moved */
# define a1_temp_addr    a1   /* from address */
# define a2_temp_dest    a2   /* to address */
# define a3_temp_mark    a3   /* ending address */

LEAF(copy_c2_ram)

    li      s1_all_ones, 0xffffffff

    # Copy code and read-only/initialized data from FLASH to (uncached) RAM.
    la      a1_temp_addr, __flash_app_start
    ins     a1_temp_addr, s1_all_ones, 29, 1
    la      a2_temp_dest, __app_start
    ins     a2_temp_dest, s1_all_ones, 29, 1
    la      a3_temp_mark, _edata
    ins     a3_temp_mark, s1_all_ones, 29, 1
    beq     a2_temp_dest, a3_temp_mark, $Lcopy_c2_ram_done
$Lnext_ram_word:
    lw      a0_temp_data, 0(a1_temp_addr)
    sw      a0_temp_data, 0(a2_temp_dest)
    addiu   a2_temp_dest, 4
    addiu   a1_temp_addr, 4
    bne     a3_temp_mark, a2_temp_dest, $Lnext_ram_word

$Lcopy_c2_ram_done:
    jr	  ra

END(copy_c2_ram)
#endif

.org 0x280				# XTLB refill, 64 bit task. start + 0x280
    sdbbp				# This has the effect of starting the debugger
    nop

#ifdef C0_CONFIG1_VALUE
#include "init_cp0_predef.S"
#endif

.org 0x300				# Cache error exception. start + 0x300
    sdbbp				# This has the effect of starting the debugger
    nop

.org 0x380
1:
    b	1b

# If you want the above code to fit into 1k flash you will need to leave out the
# code below. This is the code that covers the debug exception which you normally will not get.

.org 0x480 				# EJTAG Debug (with ProbEn = 0 in the EJTAG Control Register)
1:  b   1b  /* Stay here */
