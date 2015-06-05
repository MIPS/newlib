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

/*
 * init_tlb.S: Initialization of the TLB.
 *
 */
#define _BOOTCODE
#include <mips/m32c0.h>
#include <mips/asm.h>
#include <mips/regdef.h>

/*
 * int, int __tlb_size();
 *
 * Return number of entries in TLB.
 * Entries in v0, number of sets in v1.
 * Must not use registers a0 or a3
 *
 */
SLEAF(__tlb_size)
	/* first see if we've got a TLB */
	mfc0	t0, C0_CONFIG
	mfc0	t1, C0_CONFIG1
	move	v0, zero

	ext	t0, t0, CFG0_MT_SHIFT, CFG0_MT_BITS
	# No MMU test, 0 entries
	beqz	t0, 9f

	# Fixed Address Translation, 0 entries
	li	t2, (CFG0_MT_FIXED >> CFG0_MT_SHIFT)
	beq	t0, t2, 9f

	# Block Address Translator, 0 entries
	li	t2, (CFG0_MT_BAT >> CFG0_MT_SHIFT)
	beq	t0, t2, 9f

	# (D)TLB or not ?
	andi	t2, t0, (CFG0_MT_TLB | CFG0_MT_DUAL) >> CFG0_MT_SHIFT
	beqz	t2, 9f

	# As per PRA, field holds No. of entries -1
	# Standard TLBs and Dual TLBs have extension fields.
	ext	v0, t1, CFG1_MMUS_SHIFT, CFG1_MMUS_BITS
	addiu	v0, v0, 1

	mfc0	t1, C0_CONFIG4
#if __mips_isa_rev < 6
	ext	t3, t1, CFG4_MMUED_SHIFT, CFG4_MMUED_BITS

	li	t2, (CFG4_MMUED_FTLBVEXT >> CFG4_MMUED_SHIFT)
	beq	t3, t2, 8f			# FTLB + VTLBExt

	li	t2, (CFG4_MMUED_SIZEEXT >> CFG4_MMUED_SHIFT)
	beq	t3, t2, 7f			# SizeExt for VTLBEXT

	li	t2, (CFG4_MMUED_FTLB >> CFG4_MMUED_SHIFT)
	beq	t3, t2, 10f			# FTLB Size

	# CFG4_MMUED == 0, Reserved.
	# Reserved value in CFG4_MMUED, report a boot failure
	li	t9, 29
	# Reason - Core configuration reports impossible values
	li	a0, 3
	# Trigger the UHI operation
	sdbbp	1

7:
	ext	t3, t1, CFG4_MMUSE_SHIFT, CFG4_MMUSE_BITS
	sll	t2, t3, CFG1_MMUS_BITS
	addu	v0, v0, t2
	b	9f
#endif /* __mips_isa_rev < 6 */
8:
	ext	t2, t1, CFG4_VTLBSEXT_SHIFT, CFG4_VTLBSEXT_BITS
	sll	t2, t2, CFG1_MMUS_BITS
	addu	v0, v0, t2
10:
	# Skip FTLB size calc if Config MT != 4
	li	t3, (CFG0_MT_DUAL >> CFG0_MT_SHIFT)
	bne	t3, t0, 9f

	# Ways
	li	t2, 2
	ext	t3, t1, CFG4_FTLBW_SHIFT, CFG4_FTLBW_BITS
	addu	t2, t2, t3

	# Sets per way
	ext	v1, t1, CFG4_FTLBS_SHIFT, CFG4_FTLBS_BITS
	sllv	t2, t2, v1
	addu	v0, v0, v1

9:	jr	ra
SEND(__tlb_size)

/*
 * void __tlbinvalall()
 *
 * Invalidate the TLB.
 * Must not use register a3
 */
SLEAF(__tlbinvalall)

	mfc0	t0, C0_CONFIG
	ext	t3, t0, CFG0_MT_SHIFT, CFG0_MT_BITS
	andi	t1, t3, ((CFG0_MT_TLB | CFG0_MT_DUAL) >> CFG0_MT_SHIFT)

	beqz	t1, 11f			# Config[MT] test, return if no TLB.

	PTR_MTC0 zero, C0_ENTRYLO0
	PTR_MTC0 zero, C0_ENTRYLO1
	PTR_MTC0 zero, C0_PAGEMASK

	// If Config4[IE] = 0, use old method for invalidation
	mfc0	t9, C0_CONFIG4
	ext     t2, t9, CFG4_IE_SHIFT, CFG4_IE_BITS
	beqz	t2, 9f

	// If Config[MT] = 1,  one instruction required
	li	t0, (CFG0_MT_TLB >> CFG0_MT_SHIFT)
	beq	t3, t0, 7f

	// If Config[IE] = 3, one instruction required
	li	t1, (CFG4_IE_INVALL >> CFG4_IE_SHIFT)
	beq	t1, t2, 7f

	// If Config4[IE] = 2, many instructions required
	// No other options
	b	8f

7:	# TLB walk done by hardware, Config4[IE] = 3 or Config[MT] = 1
	mtc0	zero, C0_INDEX
	ehb
	.set	push
	.set	mips32r3
	.set	eva
	tlbinvf
	.set	pop
	b	11f

8:	/* TLB walk done by software, Config4[IE] = 2, Config[MT] = 4
	 *
	 * one TLBINVF is executed with an index in VTLB range to
	 * invalidate all VTLB entries.
	 *
	 * One TLBINVF is executed per FTLB set.
	 *
	 * We'll clean out the TLB by computing the Size of the VTLB
	 * but not add the 1. This will give us a finger that points
	 * at the last VTLB entry.
	 */

	move	a0, ra
	jal	__tlb_size
	move	ra, a0

	# Clear VTLB
	mtc0	zero, C0_INDEX
	ehb
	.set	push
	.set	mips32r3
	.set	eva
	tlbinvf
	.set	pop

	# v0 contains number of TLB entries
	# v1 contains number of sets per way
	lui	t9, %hi(__tlb_stride_length)	# Fetch the tlb stride for
	addiu	t9, %lo(__tlb_stride_length)	# stepping through FTLB sets.
	mul	v1, v1, t9
	subu	t2, v0, t9			# End pointer


12:	subu	v0, v0, t0
	mtc0	v0, C0_INDEX
	ehb					# mtc0, hazard on tlbinvf
	.set	push
	.set	mips32r3
	.set	eva
	tlbinvf
	.set	pop
	bne	v0, t2, 12b

	b	11f

9:	# Clean invalidate TLB for R1 onwards by loading
	# 0x(FFFFFFFF)KSEG0_BASE into EntryHi and writing it into index 0
	# incrementing by a pagesize, writing into index 1, etc.
	move	t8, ra
	jal	__tlb_size
	move	ra, t8

#if ENABLE_LPA
	# If large physical addressing is enabled, load 0xFFFFFFFF
	# into the top half of EntryHi.
	move	t0, zero			# t0 == 0 if XPA disabled
	mfc0	t9, C0_CONFIG3			# or not present.
	and	t9, t1, CFG3_LPA
	beqz	t9, 10f

	mfc0	t9, C0_PAGEGRAIN
	and	t9, t1, PAGEGRAIN_ELPA
	bnez	t9, 10f

	li	t0, -1				# t0 == 0xFFFFFFFF if XPA
						# is used.
#endif

10:	li	t1, (KSEG0_BASE - 2<<13)
	move	v1, zero
12:	addiu	t1, t1, (2<<13)
	PTR_MTC0 t1, C0_ENTRYHI

#if ENABLE_LPA
	beqz	t0, 13f
	mthc0   t0, C0_ENTRYHI		# Store 0xFFFFFFFF to upper half of EntryHI
#endif

13:	ehb				# mtc0, hazard on tlbp

	tlbp				# Probe for a match.
	ehb				# tlbp, Hazard on mfc0

	mfc0	t8, C0_INDEX
	bgez	t8, 12b			# Skip this address if it exists.

	mtc0	v0, C0_INDEX
	ehb				# mtc0, hazard on tlbwi

	tlbwi
	addiu	v1, v1, 1
	bne	v0, v1, 12b

11:	PTR_MTC0 zero,C0_ENTRYHI	# Unset EntryHI, upper half is cleared
					# autmatically as mtc0 writes zeroes
	.set	push
	.set	noreorder
	jr.hb	ra
	nop
	.set	pop
SEND(__tlbinvalall)

LEAF(__init_tlb)

	mfc0	t0, C0_CONFIG
	and	t2, t0, (CFG0_MT_TLB | CFG0_MT_DUAL)
	beqz	t2, 1f			# return if no tlb present.

#if ENABLE_LPA
	mfc0	t0, C0_CONFIG3
	and	t0, t0, CFG3_LPA
	beqz	t0, 1f

	li	t1, 1
	mfc0	t0, PAGEGRAIN_ELPA
	ins	t0, t1, PAGEGRAIN_ELPA_SHIFT, PAGEGRAIN_ELPA_BITS
	mtc0	t0, C0_PAGEGRAIN
#endif
	move	a3, ra
	jal	__tlbinvalall
	move	ra, a3

	mtc0	zero, C0_PAGEMASK
1:	jr	ra
END(__init_tlb)
