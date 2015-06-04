/*
 * Copyright 2014-2015, Imagination Technologies Limited and/or its
 *		         affiliated group companies.
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

#include "m32cache.h"

/*
 * static void _size_cache()
 *
 * Internal routine to determine cache sizes by looking at config
 * registers.  Sizes are returned in registers, as follows:
 *
 * Do not use tmp3 (reg a1) and tmp1 (reg v1) in this function.
 */
LEAF(__cache_size_hook)

	# If we are operating with a coherency manager, abort.
	# Check if we have $config,3 register present
	mfc0	tmp, C0_CONFIG4
	ext	tmp, tmp, CFG4_M_SHIFT, 1
	beqz	tmp, 1f

	# Do we have a memory mapped L2 cache config?
	mfc0	tmp, C0_CONFIG5
	ext	tmp, tmp, CFG5_L2C_SHIFT, 1
	beqz	tmp, 2f
	# Save registers we need.
	move	t2, v0
	move	t3, v1
	move	ta1, a0
	move	ta2, a1
	# No CM3 code supplied but we have a memory mapped L2 config
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
	j	1f

2:	mfc0	cfg, C0_CONFIG2

	# Get scache line size (log2)
	ext	tmp, cfg, CFG2_SL_SHIFT, CFG2_SL_BITS
	beqz	tmp, 1f		# no s-cache
	addiu	tmp, tmp, 1

	# Get number of scache ways
	ext	sways, cfg, CFG2_SA_SHIFT, CFG2_SA_BITS
	addiu	sways, sways, 1
	move	scachesize, sways

	# Total scache size = lines/way * linesize * ways
	li	slinesize, 1
	sllv	slinesize, slinesize, tmp
	sllv	scachesize, scachesize, tmp

	# Get scache lines per way
	ext	tmp, cfg, CFG2_SS_SHIFT, CFG2_SS_BITS
	addiu	tmp, tmp, 6
	sllv	scachesize, scachesize, tmp

1:	# Return
	jr	ra
END(__cache_size_hook)
