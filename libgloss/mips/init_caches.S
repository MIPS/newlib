/*
 * init_caches.S
 *
 *  Common Cache initialization
*/
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

#define _BOOTCODE

#include <mips/regdef.h>
#include <mips/cpu.h>
#include <mips/asm.h>

#define LINE_SIZE     v0
#define SET_SIZE      v1
#define ASSOC	      a0
#define TOTAL_BYTES   a1
#define CURRENT_ADDR  a2
#define END_ADDR      a3
#define CONFIG	      t0
#define CONFIG1	      t1
#define TEMP	      t2

    .set    noat                // Don't allow the assembler to use r1(at) for synthetic instr.

/**************************************************************************************
* init_icache invalidates all data cache entries
**************************************************************************************/

LEAF(__init_icache)
    // Determine how big the I$ is
    mfc0  CONFIG1, C0_CONFIG1

    // Isolate I$ Line Size
    ext	  LINE_SIZE, CONFIG1, CFG1_ILSHIFT, 3	  // Extract IL

    // Skip ahead if No I$
    li	  TEMP, 2
    beqz  LINE_SIZE, $Ldone_icache
    sllv  LINE_SIZE, TEMP, LINE_SIZE		  // Now have true I$ line size in bytes

    ext	  SET_SIZE, CONFIG1, CFG1_ISSHIFT, 3	  // Extract IS
    addiu SET_SIZE, SET_SIZE, 1			  // Rotate to account for 7 == 32 sets
    andi  SET_SIZE, SET_SIZE, 7			  // Mask down to 3-bit
    li	  TEMP,	32 
    sllv  SET_SIZE, TEMP, SET_SIZE		  // I$ Sets per way

    // Config1IA == I$ Assoc - 1
    ext	  ASSOC, CONFIG1, CFG1_IASHIFT, 3	  // Extract IA
    addiu ASSOC, ASSOC, 1

    mul	  SET_SIZE, SET_SIZE, ASSOC		  // Total number of sets
    mul	  TOTAL_BYTES, SET_SIZE, LINE_SIZE	  // Total number of bytes

    lui	  CURRENT_ADDR, 0x8000			  // Get a KSeg0 address for cacheops
    addu  END_ADDR, CURRENT_ADDR, TOTAL_BYTES
    subu  END_ADDR, END_ADDR, LINE_SIZE		  // END_ADDR is last line to invalidate

    // Clear TagLo/TagHi registers
    mtc0  zero, C0_TAGLO
    mtc0  zero, C0_TAGHI

$Lnext_icache_tag:
    // Index Store Tag Cache Op
    // Will invalidate the tag entry, clear the lock bit, and clear the LRF bit
    .set push
    .set noreorder
    cache 0x8, 0(CURRENT_ADDR)			  // ICIndexStTag
    bne	  CURRENT_ADDR, END_ADDR, $Lnext_icache_tag // Done yet?
    addu  CURRENT_ADDR, LINE_SIZE		  // Get next line address
    .set pop

$Ldone_icache:
    jr	  ra
END(__init_icache)

/**************************************************************************************
* init_dcache invalidates all data cache entries
**************************************************************************************/

LEAF(__init_dcache)
    mfc0  CONFIG1, C0_CONFIG1

    // Isolate D$ Line Size
    ext	  LINE_SIZE, CONFIG1, CFG1_DLSHIFT, 3	  // extract DL

    // Skip ahead if No D$
    li	  TEMP, 2
    beqz  LINE_SIZE, $Ldone_dcache

    sllv  LINE_SIZE, TEMP, LINE_SIZE		  // Now have true D$ line size in bytes

    ext	  SET_SIZE, CONFIG1, CFG1_DSSHIFT, 3	  // extract DS
    addiu SET_SIZE, SET_SIZE, 1			  // Rotate to account for 7 == 32 sets
    andi  SET_SIZE, SET_SIZE, 7			  // Mask down to 3-bit
    li	  TEMP, 32
    sllv  SET_SIZE, TEMP, SET_SIZE		  // D$ Sets per way

    // Config1.DA == D$ Assoc - 1
    ext	  ASSOC, CONFIG1, CFG1_DASHIFT, 3	  // extract DA
    addiu ASSOC, 1

    mul	  SET_SIZE, SET_SIZE, ASSOC		  // Get total number of sets
    mul	  TOTAL_BYTES, SET_SIZE, LINE_SIZE	  // Total number of bytes

    lui	  CURRENT_ADDR, 0x8000			  // Get a KSeg0 address for cacheops
    addu  END_ADDR, CURRENT_ADDR, TOTAL_BYTES
    subu  END_ADDR, END_ADDR, LINE_SIZE		  // END_ADDR is last line to invalidate

    // Clear TagLo/TagHi registers
    mtc0  zero, C0_TAGLO
    mtc0  zero, C0_TAGHI
    mtc0  zero, C0_TAGLO, 2
    mtc0  zero, C0_TAGHI, 2

$Lnext_dcache_tag:
    // Index Store Tag Cache Op
    // Will invalidate the tag entry, clear the lock bit, and clear the LRF bit

    .set push
    .set noreorder
    cache 0x9, 0(CURRENT_ADDR)			  // DCIndexStTag
    bne	  CURRENT_ADDR, END_ADDR, $Lnext_dcache_tag // Done yet?
    addu  CURRENT_ADDR, LINE_SIZE		  // Get next line address
    .set pop

$Ldone_dcache:
    jr	  ra

END(__init_dcache)

LEAF(__change_k0_cca)
    // NOTE! This code must be executed in KSEG1 (not KSEG0 uncached)
    // Set CCA for kseg0 to cacheable

    mfc0  CONFIG, C0_CONFIG
    li	  TEMP, CFG_C_NONCOHERENT		  // CCA for all others

$Lset_kseg0_cca:
    ins	  CONFIG, TEMP, 0, 3			  // instert K0
    mtc0  CONFIG, C0_CONFIG			  // write C0_Config
    .set push
    .set noreorder
    jr.hb ra					  // Must not fill the delay slot
    nop
    .set pop

END(__change_k0_cca)
