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


/*
 * mips_xxtlb_ops.S: Generic MIPS TLB support functions
 *
 */
#include <mips/m32c0.h>
#include <mips/asm.h>
#include <mips/regdef.h>


/*
 * int m64_tlb_size();
 * int mips_tlb_size();
 *
 * Return number of entries in TLB.
 *
 */
LEAF(mips_tlb_size)
AENT(m64_tlb_size)
	/* first see if we've got a TLB */
	mfc0	t0, C0_CONFIG
	mfc0	t1, C0_CONFIG1
	move	v0, zero

	ext	t0, t0, CFG0_MT_SHIFT, CFG0_MT_BITS
	#No MMU test, 0 entries
	beq	t0, zero, 9f		

	# Fixed Address Translation, 0 entries
	li	t3, (CFG0_MT_FIXED >> CFG0_MT_SHIFT)
	beq	t0, t3, 9f

	# Block Address Translator, 0 entries
	li	t3, (CFG0_MT_BAT >> CFG0_MT_SHIFT)
	beq	t0, t3, 9f

	# As per PRA, field holds No. of entries -1
	# Standard TLBs and Dual TLBs have
	# extension fields.
	ext	v0, t1,CFG1_MMUS_SHIFT, CFG1_MMUS_BITS
	addiu	v0, 1

	# Compute VTLB size	
	# If not using a TLB or VFTLB
	mfc0	t1, C0_CONFIG4
	ext	t2, t0, CFG0_MT_SHIFT, CFG0_MT_BITS
	li	t3, (CFG0_MT_TLB | CFG0_MT_DUAL) >> CFG0_MT_SHIFT
	and	t2, t0, t3			#ConfigMT 1 or 4
	beq	t2, zero, 9f

#if __mips_isa_rev < 6
	ext	t3, t1, CFG4_MMUED_SHIFT, CFG4_MMUED_BITS

	li	t2, (CFG4_MMUED_FTLBVEXT >> CFG4_MMUED_SHIFT)
	beq	t3, t2, 8f			# FTLB + VTLBExt

	li	t2, (CFG4_MMUED_SIZEEXT >> CFG4_MMUED_SHIFT)
	beq	t3, t2, 7f			# SizeExt for VTLBEXT

	beq	t3, zero, 9f			# Reserved, nothing more to do

	b	10f				# FTLB Size
7:
	ext	t3, t1, CFG4_MMUSE_SHIFT, CFG4_MMUSE_BITS
	sll	t2, t3, CFG1_MMUS_BITS
	add	v0, v0, t2
	b	9f
#endif /* __mips_isa_rev < 6 */
8:
	ext	t2, t1, CFG4_VTLBSEXT_SHIFT, CFG4_VTLBSEXT_BITS
	srl     t2, t2, CFG1_MMUS_BITS
	add	v0, v0, t2
10:
	# Skip FTLB size calc if Config MT != 4
	li	t3, (CFG0_MT_DUAL >> CFG0_MT_SHIFT)
	bne	t0, t3, 9f
	
	# Ways
	li	t2, 2
	ext	t3, t1, CFG4_FTLBW_SHIFT, CFG4_FTLBW_BITS
	add	t2, t3

	# Sets per way
	ext	t3, t1, CFG4_FTLBS_SHIFT, CFG4_FTLBS_BITS
	sll	t2, t3
	add	v0, v0, t2

9:	jr	ra
END(mips_tlb_size)

/*
 * void m64_tlbinval()
 * void mips_tlbinval()
 *
 * Invalidate the TLB.
 */
LEAF(mips_tlbinvalall)
AENT(m64_tlbinvalall)
	
	mfc0	t0, C0_CONFIG
	ext	t1, t0, CFG0_MT_SHIFT, CFG0_MT_BITS
	li	t2, ((CFG0_MT_TLB | CFG0_MT_DUAL) >> CFG0_MT_SHIFT)
	and     t1, t0, t2				# Config[MT] 1 or 4
	beq	t1, zero, 11f				# Not sTLB or DTLB.

	PTR_MTC0 zero, C0_ENTRYLO0
	PTR_MTC0 zero, C0_ENTRYLO1
	PTR_MTC0 zero, C0_PAGEMASK

	mfc0	t0, C0_CONFIG4			# Config4[IE] = 0, do old method for
						# invalidation
	ext	t2, t0, CFG4_IE_SHIFT, CFG4_IE_BITS
	and	t2, t0, (CFG4_IE_MASK >> CFG4_IE_SHIFT)
	beq	t2, zero, 9f

	li	t0, CFG0_MT_TLB			# Config[MT] = 1, one instruction required
	beq	t1, t0, 7f

	mfc0	t0, C0_CONFIG4			# Config4[IE] = 3, one instruction required
	ext	t1, t0, CFG4_IE_SHIFT, CFG4_IE_BITS
	li	t2, (CFG4_IE_MASK >> CFG4_IE_SHIFT)
	beq	t1, t2, 7f

	b	8f				# Config4[IE] = 2

7:	# TLB walk done by hardware, Config4[IE] = 3 or Config[MT] = 1
	li	t1, C0_ENTRYHI_EHINV_MASK
	mtc0	t1, C0_ENTRYHI
	mtc0	zero, C0_INDEX
	ehb
	.set	push
	.set	mips32r3
	tlbinvf
	.set	pop
	b	11f

8:	/* TLB walk done by software, Config4[IE] = 2, Config[MT] = 4
	 *
	 * one TLBINVF is executed with an index in VTLB range to
	 * invalidate all VTLB entries.
	 *
	 * One TLBINVF is executed per FTLB set with the appropriate
	 * index to invalidate the corresponding set.
	 *
	 * We'll clean out the TLB by computing the Size of the VTLB
	 * but not add the 1. This will give us a finger that points
	 * at the last VTLB entry.
	 * 
	 * The end pointer will be VTLB SIZE + number of FTLB sets.
	 * Flush, increment, repeat while finger != end pointer.
	 */
	
	mfc0	t0, C0_CONFIG4
	ext	t1, t0, CFG4_FTLBS_SHIFT, CFG4_FTLBS_BITS
	li	t2, 1
	sll	t2, t2, t1				# FTLB Sets

	ext	t3, t0, CFG4_VTLBSEXT_SHIFT, CFG4_VTLBSEXT_BITS
	sll	t3, CFG1_MMUS_BITS
	
	mfc0	t0, C0_CONFIG1
	ext	t1, t0, CFG1_MMUS_SHIFT, CFG1_MMUS_BITS
	or	t1, t1, t3			# VTLB Size, set ptr

	addiu	t2, t2, 1
	addu	t2, t2, t1			# VTLB Size + FTLB Sets, end ptr
	
	mtc0	zero, C0_INDEX
	li	t0, C0_ENTRYHI_EHINV_MASK
	mtc0	t0, C0_ENTRYHI
	ehb
	.set	push	
	.set	mips32r3
	tlbinvf
	.set	pop

12:	mtc0	t1, C0_INDEX
	ehb					# mtc0, hazard on tlbinvf
	.set	push
	.set	mips32r3
	tlbinvf
	.set	pop
	addiu	t1, t1, 1
	bne	t1, t2, 12b
	
	b	11f	

9:	/* Clean invalidate TLB for R1 onwards by loading 
	 * 0x(FFFFFFFF)KSEG0_BASE into EntryHi and writing it into index 0
	 * incrementing by a pagesize, writing into index 1, etc.
	 */
	move	t8, ra
	jal	mips_tlb_size
	move	ra, t8

	# If large physical addressing is enabled, load 0xFFFFFFFF
	# into the top half of EntryHi.
	mfc0	t1, C0_CONFIG3
	and	t1, t1, CFG3_LPA
	beq	t1, zero, 10f

	mfc0	t1, C0_PAGEGRAIN
	ext	t1, t1, PAGEGRAIN_ELPA_SHIFT, PAGEGRAIN_ELPA_BITS
	bne	t1, zero, 10f

	li	t0, -1
	.set	push
	.set	nomicromips
	mthc0	t0, C0_ENTRYHI
	mthc0	zero, C0_ENTRYLO0
	mthc0	zero, C0_ENTRYLO1
	mthc0	zero, C0_PAGEMASK
	.set	pop

10:	li	t1, KSEG0_BASE

12:	PTR_MTC0 t1, C0_ENTRYHI
	addu	v0, v0, -1
	mtc0	v0, C0_INDEX
	ehb					# mtc0, hazard on tlbwi
	
	tlbwi
	addu	t1, t1, (2<<13)
	bne	v0, zero, 12b

11:	mtc0	zero, C0_ENTRYHI			# Unset EntryHI
	jr.hb	ra
END(mips_tlbinvalall)
