/*
* Copyright 2015, Imagination Technologies Limited and/or its
*                 affiliated group companies.
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
#include <mips/cm3.h>
#include "predef.h"

#define CM3_BASE	a3
LEAF(__init_l23cache)
	li	CM3_BASE, C0_CMGCRBASE_ADDR
	# Disable L2 cache
	PTR_L	v0, GCR_L2_CONFIG(CM3_BASE)
	li	a2, 1
	ins	v0, a2, GCR_L2_BYPASS_SHIFT, GCR_L2_BYPASS_BITS
	PTR_S	v0, GCR_L2_CONFIG(CM3_BASE)

	jr	ra
END(__init_l23cache)

LEAF(__init_l23cache_cached)
	li	CM3_BASE, C0_CMGCRBASE_ADDR

#if SLINE_ENC != 0
	# Unusual case, hardware cache initialization support & init finished.
	PTR_L	t1, GCR_L2_RAM_CONFIG(CM3_BASE)
	ext	t0, t1, GCR_L2_RAM_HCIS_SHIFT, (GCR_L2_RAM_HCID_BITS +\
						GCR_L2_RAM_HCIS_BITS)
	li	t1, 3
	beq	t0, t1, done_cm3l2cache

	# Compute L2 cache size
	li	a1, SLINE_SIZE
	li	a0, SSET_SIZE

	sw	zero, GCR_TAG_ADDR(CM3_BASE)
	sw	zero, (GCR_TAG_ADDR+4)(CM3_BASE)
	sw	zero, GCR_TAG_STATE(CM3_BASE)
	sw	zero, (GCR_TAG_STATE+4)(CM3_BASE)
	sw	zero, GCR_TAG_DATA(CM3_BASE)
	sw	zero, (GCR_TAG_DATA+4)(CM3_BASE)

	li	t0, 0x8000FFFF			# Reg exists, L2 cache does
						# TAG/DATA ECC.
	and	v0, v0, t0
	li	t0, (1<<GCR_L2_LRU_WE_SHIFT)	# LRU is updated on store tag
						# operation
	or	v0, v0, t0
	sw	v0, GCR_L2_CONFIG(CM3_BASE)
	sync					# Memory hazard

	lui	a2, 0x8000
next_cm3l2cache_tag:
	cache	Index_Store_Tag_S, 0(a2)
	addiu	a0, a0, -1
	addu	a2, a2, a1
	bnez	a0, next_cm3l2cache_tag
#endif /* SLINE_ENC != 0 */

done_cm3l2cache:
	move	a2, zero
	PTR_L	v0, GCR_L2_CONFIG(CM3_BASE)
	ins	v0, a2, GCR_L2_BYPASS_SHIFT, GCR_L2_BYPASS_BITS
	PTR_S	v0, GCR_L2_CONFIG(CM3_BASE)

	# Return
	jr	ra
END(__init_l23cache_cached)
