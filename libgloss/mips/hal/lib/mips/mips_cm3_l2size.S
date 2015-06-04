/*
 * Copyright 2014-2015, Imagination Technologies Limited and/or its
 *				affiliated group companies.
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

#include <mips/asm.h>
#include <mips/regdef.h>
#include <mips/cm3.h>
#include <mips/m32c0.h>

#define tmp		t0
#define cfg		t1
#define icachesize	t2
#define ilinesize	t3
#define iways		ta0
#define dcachesize	ta1
#define dlinesize	ta2
#define dways		ta3
#define scachesize	t8
#define slinesize	t9
#define sways		v0
#define tmp1		v1
#define tmp2		a0
#define tmp3		a1
#define tmp4		a2
#define tmp5		a3
/*
 * __cache_size_hook
 *
 * Store the size of the l2 cache to the global variables when
 * using a CM3
 *
 */

LEAF(__cache_size_hook)
	# Check if Coherency Manager memory-mapped
	# Global Configuration Register Space is implemented.
	mfc0	tmp, C0_CONFIG4
	ext	tmp, tmp, CFG4_M_SHIFT, 1
	beqz	tmp, 9f		# Return if not implemented

	# Do we have a memory mapped L2 cache config?
	mfc0	tmp, C0_CONFIG5
	ext	tmp, tmp, CFG5_L2C_SHIFT, 1
	bnez	tmp, 8f

	# Memory mapped L2 cache config
	mfc0	tmp, C0_CONFIG2
	ext	tmp, tmp, CFG2_SL_SHIFT, CFG2_SL_BITS
	# Return if there's no L2 cache config in CONFIG2
	beqz	tmp, 9f

	# Save registers we need.
	move	t2, v0
	move	t3, v1
	move	ta1, a0
	move	ta2, a1
	# CM3 L2 code supplied but we have a L2 config stored in
	# C0_CONFIG2
	# Report a Boot failure through UHI
	li	t9, 23
	# Reason - L2 cache config
	li	v0, 1
	# Trigger the UHI operation
	syscall	1
	# Restore registers
	move	v0, t2
	move	v1, t3
	move	a0, ta1
	move	t1, ta2
	# Fallthrough if we somehow recover.
	j	9f
8:
	# Read CMGCRBase to find CMGCR_BASE_ADDR
	PTR_MFC0 tmp,C0_CMGCRBASE
	sll	tmp, tmp, 4
	lui	tmp2, 0xb000	 # Make it virtual
	or	tmp, tmp, tmp2

	# Read GCR_L2_CONFIG
	PTR_L	tmp, GCR_L2_CONFIG(tmp)
	# Extract line size
	ext	slinesize, tmp, GCR_L2_SL_SHIFT, GCR_L2_SL_BITS
	li	tmp2, 2
	sllv	slinesize, tmp2, slinesize	# Now have true L2 line size
	# Extract sets/way
	ext	sways, tmp, GCR_L2_SS_SHIFT, GCR_L2_SS_BITS
	li	tmp2, 64
	sllv	sways, tmp2, sways		# Now we have true L2 sets/way
	# Extract L2 associativity
	ext	tmp, tmp, GCR_L2_SA_SHIFT, GCR_L2_SA_BITS
	addiu	tmp, tmp, 1
	mul	tmp, tmp, sways			# Get total number of sets
	mul	scachesize, slinesize, tmp	# L2 cache size
	
9:	# Return
	jr	ra
END(__cache_size_hook)
