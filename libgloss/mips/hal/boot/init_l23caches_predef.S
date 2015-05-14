/*
 * Copyright 2014-2015, Imagination Technologies Limited and/or its
 *                      affiliated group companies.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of its
 * contributors may be used to endorse or promote products derived from this
 * software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
*/

#define _BOOTCODE

#include <mips/regdef.h>
#include <mips/cpu.h>
#include <mips/asm.h>
#include <mipsm64r6cm3.h>
#include "predef.h"

// Depending on the range of the displacement field of the CACHE instruction
// we can do multiple cacheops per interation.  With a cache present there
// is a guarantee of 32 lines minimum so a power of 2 less than or equal
// to 32 means there is no postamble to mop up remaining lines.
// The maximum number of lines per iteration is the range of the CACHE
// displacement divided by the line_size.  We cap this at 8 as a sensible
// bound.

#if __mips_isa_rev < 6
// MicroMIPS Release 3 has a 12-bit displacement for CACHE
# define SLINES_PER_ITER 8
# define TLINES_PER_ITER 8
#else
// MIPS Release 6 has a 9-bit signed displacement for CACHE
#if SLINE_SIZE == 128
# define SLINES_PER_ITER 4 // Requires use of both positive and negative disp
#else
# define SLINES_PER_ITER 8
#endif
#if TLINE_SIZE == 128
# define TLINES_PER_ITER 4 // Requires use of both positive and negative disp
#else
# define TLINES_PER_ITER 8
#endif
#endif

// Start off pointing to one block below where we want to invalidate the cache
// as the pointer is moved on at the start of the loop. Also offset the start
// address for each set of cache lines so that the positive and negative
// displacements from the CACHE ops can be used.

#define SCACHE_START (0x80000000 - (SLINE_SIZE * SLINES_PER_ITER / 2))
#define SCACHE_END (0x80000000 + STOTAL_BYTES - (SLINE_SIZE * SLINES_PER_ITER / 2))
#define TCACHE_START (0x80000000 - (TLINE_SIZE * TLINES_PER_ITER / 2))
#define TCACHE_END (0x80000000 + TTOTAL_BYTES - (TLINE_SIZE * TLINES_PER_ITER / 2))

#define CURRENT_ADDR  a0
#define END_ADDR      a1
#define CONFIG	      a2
#define TEMP	      a3

    .set    noat  // Don't allow the assembler to use r1(at) for synthetic instr.

/**************************************************************************************
* __init_l23cache invalidates all secondary/tertiary data cache entries
**************************************************************************************/

#if defined(SLINE_ENC) && SLINE_ENC != 0
LEAF(__init_l23cache)
    // Use KSEG0 base address
    lui	  CURRENT_ADDR, %hi(SCACHE_START)
    addiu CURRENT_ADDR, %lo(SCACHE_START)
    // Get the address of the last batch of lines
    lui	  END_ADDR, %hi(SCACHE_END)
    addiu END_ADDR, %lo(SCACHE_END)

    // Clear TagLo/TagHi registers
    mtc0    zero, C0_TAGLO, 4

    // Index Store Tag Cache Op
    // Will invalidate the tag entry, clear the lock bit, and clear the LRF bit
$Lnext_scache_tag:
    addu  CURRENT_ADDR, (SLINE_SIZE * SLINES_PER_ITER)	// Get next group address
    cache Index_Store_Tag_S, (SLINE_SIZE*-2)(CURRENT_ADDR)
    cache Index_Store_Tag_S, (SLINE_SIZE*-1)(CURRENT_ADDR)
    cache Index_Store_Tag_S, (SLINE_SIZE*0)(CURRENT_ADDR)
    cache Index_Store_Tag_S, (SLINE_SIZE*1)(CURRENT_ADDR)
#if SLINES_PER_ITER == 8
    cache Index_Store_Tag_S, (SLINE_SIZE*-4)(CURRENT_ADDR)
    cache Index_Store_Tag_S, (SLINE_SIZE*-3)(CURRENT_ADDR)
    cache Index_Store_Tag_S, (SLINE_SIZE*2)(CURRENT_ADDR)
    cache Index_Store_Tag_S, (SLINE_SIZE*3)(CURRENT_ADDR)
#endif
    bne	  CURRENT_ADDR, END_ADDR, $Lnext_scache_tag	// Done yet?

$Ldone_scache:

#if defined(TLINE_ENC) && TLINE_ENC != 0

    // Use KSEG0 base address
    lui	  CURRENT_ADDR, %hi(TCACHE_START)
    addiu CURRENT_ADDR, %lo(TCACHE_START)
    // Get the address of the last batch of lines
    lui	  END_ADDR, %hi(TCACHE_END)
    addiu END_ADDR, %lo(TCACHE_END)

    // Clear TagLo/TagHi registers
    mtc0    zero, C0_TAGLO, 4

    // Index Store Tag Cache Op
    // Will invalidate the tag entry, clear the lock bit, and clear the LRF bit
$Lnext_tcache_tag:
    addu  CURRENT_ADDR, (TLINE_SIZE * TLINES_PER_ITER)	// Get next address
    cache Index_Store_Tag_T, (TLINE_SIZE*-2)(CURRENT_ADDR)
    cache Index_Store_Tag_T, (TLINE_SIZE*-1)(CURRENT_ADDR)
    cache Index_Store_Tag_T, (TLINE_SIZE*0)(CURRENT_ADDR)
    cache Index_Store_Tag_T, (TLINE_SIZE*1)(CURRENT_ADDR)
#if TLINES_PER_ITER == 8
    cache Index_Store_Tag_T, (TLINE_SIZE*-4)(CURRENT_ADDR)
    cache Index_Store_Tag_T, (TLINE_SIZE*-3)(CURRENT_ADDR)
    cache Index_Store_Tag_T, (TLINE_SIZE*2)(CURRENT_ADDR)
    cache Index_Store_Tag_T, (TLINE_SIZE*3)(CURRENT_ADDR)
#endif
    bne	  CURRENT_ADDR, END_ADDR, $Lnext_tcache_tag	// Done yet?

$Ldone_tcache:

#endif // TLINE_ENC != 0
    jr	  ra
END(__init_l23cache)

#endif // SLINE_ENC != 0

#ifdef MEM_MAPPED_L2C
#define CM3_BASE	v0
WLEAF(__init_cm3l2)

        # Read CMGCRBase to find CMGCR_BASE_ADDR
        PTR_MFC0 v1,C0_CMGCRBASE
	sll	v1, 4
        lui     CM3_BASE, 0xb000     			# Make it virtual
        or      CM3_BASE, v1

        # Read GCR_L2_CONFIG
        PTR_L   v0, GCR_L2_CONFIG(CM3_BASE)
	ext	v1, v0, GCR_L2_SL_SHIFT, GCR_L2_SL_BITS
	beqz	v1, done_cm3l2cache		# No L2 cache

	# Unusual case, hardware cache initialization support & finished.
	PTR_L	t1, GCR_L2_RAM_CONFIG(CM3_BASE)
	ext	t0, t1, GCR_L2_RAM_HCIS_SHIFT, 2
	li	t1, 3
	beq	t0, t1, done_cm3l2cache

        li      a2, 2
        sllv    a1, a2, v1      		# Now have true L2 line size

	ext	a0, v0, GCR_L2_SS_SHIFT, GCR_L2_SS_BITS
        li      a2, 64
        sllv    a0, a2, a0			# Now we have true L2 sets/way
	
	ext	v1, v0, GCR_L2_SA_SHIFT, GCR_L2_SA_BITS
        addiu   v1, v1, 1			# Set associativity
        mul     a0, v1, a0			# Get total number of sets

	sd	zero, GCR_TAG_ADDR(CM3_BASE)
	sd	zero, GCR_TAG_STATE(CM3_BASE)
	sd	zero, GCR_TAG_DATA(CM3_BASE)
	
	li	t0, 0x8000FFFF			# Reg exists, L2 cache does
						# TAG/DATA ECC.
	and	v0, t0
	li	t0, 0x04000000			# LRU is updated on store tag
						# operation
	or	v0, t0
	sd	v0, GCR_L2_CONFIG(CM3_BASE)
	sync					# Memory hazard

	lui	a2, 0x8000
	
next_cm3l2cache_tag:
	cache	Index_Store_Tag_S, 0(a2)
	addiu	a0, -1
	addu	a2, a1
	bne	a0, zero, next_cm3l2cache_tag
	
done_cm3l2cache:

	# Return
	jr	ra
WEND(__init_cm3l2)
#endif // CM3_BASE

