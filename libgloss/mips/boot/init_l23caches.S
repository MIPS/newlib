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
.set nomips16

#include <mips/regdef.h>
#include <mips/cpu.h>
#include <mips/asm.h>
    .set	noat	// Don't allow the assembler to use r1(at) for synthetic instr.

LEAF(__init_l23cache)
    // L2 Cache initialization routine
    # Check for memory mapped L2 cache config
    mfc0    a3, C0_CONFIG3
    ext     a3, a3, CFG3_M_SHIFT, 1
    beqz    a3, l23_init
    mfc0    a3, C0_CONFIG4
    ext     a3, a3, CFG4_M_SHIFT, 1
    beqz    a3, l23_init
    mfc0    a3, C0_CONFIG5
    ext     a3, a3, CFG5_L2C_SHIFT, 1
    beqz    a3, l23_init

    # No CM3 code supplied but we have a memory mapped L2 configuration
    # Report a Boot failure through UHI
    li      t9, 23
    # Reason - L2 cache config
    li      a0, 1
    # Trigger the UHI operation
    sdbbp   1
    # In case a debugger corrects this failure
    b       done_l3cache

l23_init:
    // Check L2 cache size
    mfc0    v0, C0_CONFIG2

    // Isolate L2$ Line Size
    ext	    v1, v0, CFG2_SL_SHIFT, CFG2_SL_BITS

    // Skip ahead if No L2$
    beqz    v1, done_l2cache

    li	    a2, 2
    sllv    a1, a2, v1			// Decode L2$ line size in bytes

    // Isolate L2$ Sets per Way
    ext	    a0, v0, CFG2_SS_SHIFT, CFG2_SS_BITS
    li	    a2, 64
    sllv    a0, a2, a0			// L2$ Sets per way

    // Isolate L2$ Associativity
    // L2$ Assoc (-1)
    ext	    v1, v0, CFG2_SA_SHIFT, CFG2_SA_BITS
    addiu   v1, v1, 1

    mul	    a0, a0, v1			// Get total number of sets

l2cache_init:
    lui	    a2, 0x8000			// Get a KSeg0 address for cacheops

    // Clear L23TagLo/L23TagHi registers
    mtc0    zero, C0_TAGLO, 4

    // L2$ Index Store Tag Cache Op
    // Will invalidate the tag entry, clear the lock bit, and clear the LRF bit
next_L2cache_tag:
    cache   Index_Store_Tag_S, 0(a2)	// Write Tag using index store tag
    addiu   a0, a0, -1			// Decrement set counter
    addu    a2, a2, a1			// Get next line address
    bnez    a0, next_L2cache_tag 	// Done yet?

done_l2cache:
    // Isolate L3$ Line Size
    ext	    v1, v0, CFG2_TL_SHIFT, CFG2_TL_BITS

    // Skip ahead if No L3$
    beqz    v1, done_l3cache

    li	    a2, 2
    sllv    a1, a2, v1			// Decode L3$ line size in bytes

    // Isolate L3$ Sets per Way
    ext	    a0, v0, CFG2_TS_SHIFT, CFG2_TS_BITS
    li	    a2, 64
    sllv    a0, a2, a0			// Decode L3 Sets per way

    // Isolate L3$ Associativity
    // L3$ Assoc (-1)
    ext	   v1, v0, CFG2_TA_SHIFT, CFG2_TA_BITS
    addiu  v1, v1, 1			// Decode L3 associativity (number of sets)
    mul	   a0, a0, v1			// Compute total number of sets

l3cache_init:
    lui	    a2, 0x8000		   	// Get a KSeg0 address for cacheops

    // Clear L23Tag register
    mtc0    zero, C0_TAGLO, 4

    // L3$ Index Store Tag Cache Op
    // Will invalidate the tag entry, clear the lock bit, and clear the LRF bit
next_L3cache_tag:
    cache   Index_Store_Tag_T, 0(a2)	// TCIndexStTag
    addiu   a0, a0, -1			// Decrement set counter
    add	    a2, a2, a1			// Get next line address
    bnez    a0, next_L3cache_tag

done_l3cache:
    jr      ra
END(__init_l23cache)
