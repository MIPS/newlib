/*
 * Copyright 2014-2015, Imagination Technologies Limited and/or its
 *                      affiliated group companies.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted under the terms of the MIPS Free To Use 1.0
 * license that you will have received with this package. If you haven't
 * received this file, please contact Imagination Technologies or see the
 * following URL for details.
 * http://codescape-mips-sdk.imgtec.com/license/IMG-free-to-use-on-MIPS-license
 *
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
 * int __tlb_size();
 *
 * Return number of entries in TLB.
 *
 */
SLEAF(__tlb_size)
	/* first see if we've got a TLB */
	mfc0	t0, C0_CONFIG
	mfc0	t1, C0_CONFIG1
	move	v0,zero

	and	t0,CFG0_MT_MASK
	#No MMU test, 0 entries
	beqz	t0,9f		

	# Fixed Address Translation, 0 entries
beq	t0, CFG0_MT_FIXED, 9f

	# Block Address Translator, 0 entries
	beq	t0,CFG0_MT_BAT,9f

	# As per PRA, field holds No. of entries -1
	# Standard TLBs and Dual TLBs have
	# extension fields.
	and	v0,t1,CFG1_MMUS_MASK
	srl	v0,CFG1_MMUS_SHIFT
	addiu	v0,1

	# Compute VTLB size	
	# If not using a TLB or VFTLB
	mfc0	t1, C0_CONFIG4
	and	t2, t0, (CFG0_MT_TLB | CFG0_MT_DUAL) #ConfigMT 1 or 4
	beqz	t2, 9f

#if __mips_isa_rev < 6
	and     t3, t1, CFG4_MMUED
	beq	t3, CFG4_MMUED_FTLBVEXT, 8f	# FTLB + VTLBExt
	beq	t3, CFG4_MMUED_SIZEEXT, 7f	# SizeExt for VTLBEXT
	beq	t3, 0, 9f			# Reserved, nothing more to do
	b	10f				# FTLB Size
7:
	and	t3, t1, CFG4_MMUSE_MASK
	sll	t2, t3, CFG1_MMUS_BITS
	add	v0, v0, t2
	b	9f
#endif /* __mips_isa_rev < 6 */
8:
	and	t2, t3, CFG4_VTLBSEXT_MASK
	srl     t2, t2, CFG4_VTLBSEXT_SHIFT - CFG1_MMUS_BITS
	add	v0, v0, t2
10:
	# Skip FTLB size calc if Config MT != 4
	and	t2, t0, CFG0_MT_DUAL
	beqz	t2, 9f
	
	# Ways
	li	t2, 2
	and	t3, t1, CFG4_FTLBW_MASK
	srl	t3, CFG4_FTLBW_SHIFT
	add	t2, t3

	# Sets per way
	and	t3, t1, CFG4_FTLBS_MASK
	sll	t2, t3
	add	v0, v0, t2

9:	jr	ra
SEND(__tlb_size)

/*
 * void m64_tlbinval()
 *
 * Invalidate the TLB.
 */
SLEAF(__tlbinvalall)
	
	mfc0	t0, C0_CONFIG
	and     t1, t0, (CFG0_MT_TLB | CFG0_MT_DUAL) 	# Config[MT] 1 or 4
	beqz	t1, 11f					# Not sTLB or DTLB.

	PTR_MTC0 zero, C0_ENTRYLO0
	PTR_MTC0 zero, C0_ENTRYLO1
	PTR_MTC0 zero, C0_PAGEMASK

	mfc0	t0, C0_CONFIG4			# Config4[IE] = 0, do old method
	and	t2, t0, CFG4_IE_MASK		# for invalidation
	beqz	t2, 9f


	li	t0, CFG0_MT_TLB			#Config[MT] = 1, one instruction required
	beq	t1, t0, 7f

	mfc0	t0, C0_CONFIG4			#Config4[IE] = 3, one instruction required
	and	t1, t0, CFG4_IE_MASK
	beq	t1, CFG4_IE_INVALL, 7f

	b	8f				#Config4[IE] = 2

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
	 */
	
	mfc0	t0, C0_CONFIG4
	ext	t1, t0, CFG4_FTLBS_SHIFT, CFG4_FTLBS_BITS
	li	t2, 1
	sll	t2, t2, t1				# FTLB Sets

	and	t3, t0, CFG4_VTLBSEXT_MASK
	srl	t3, CFG4_VTLBSEXT_SHIFT - CFG1_MMUS_BITS
	
	mfc0	t0, C0_CONFIG1
	and	t1, t0, CFG1_MMUS_MASK
	srl	t1, CFG1_MMUS_SHIFT
	or	t1, t1, t3			# VTLB Size, set ptr

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
	addu	t1, t1, 1
	bne	t1, t2, 12b
	
	b	11f	

9:	# Clean invalidate TLB for R1 onwards by loading 
	# 0x(FFFFFFFF)KSEG0_BASE into EntryHi and writing it into index 0
	# incrementing by a pagesize, writing into index 1, etc.
	move	t8, ra
	jal	__tlb_size
	move	ra, t8

	# If large physical addressing is enabled, load 0xFFFFFFFF
	# into the top half of EntryHi.
	mfc0	t1, C0_CONFIG3
	and	t1, t1, CFG3_LPA
	beqz	t1, 10f

	mfc0	t1, C0_PAGEGRAIN
	and	t1, t1, PAGEGRAIN_ELPA
	bnez	t1, 10f

	li	t0, -1
	.set	push
	.set	nomicromips
	mthc0	t0, C0_ENTRYHI
	mthc0	zero, C0_ENTRYLO0
	mthc0	zero, C0_ENTRYLO1
	mthc0	zero, C0_PAGEMASK
	.set	pop

10:	li	t1, KSEG0_BASE

12:	PTR_MTC0 t1,C0_ENTRYHI
	addu	v0, v0, -1
	mtc0	v0,C0_INDEX
	ehb					# mtc0, hazard on tlbwi
	tlbwi
	addu	t1, t1, (2<<13)
	bnez	v0, 12b

11:	PTR_MTC0 zero,C0_ENTRYHI			# Unset EntryHI
	jr.hb	ra
SEND(__tlbinvalall)

LEAF(__init_tlb)

	mfc0	t0, C0_CONFIG
	and	t2, t0, (CFG0_MT_TLB | CFG0_MT_DUAL) #ConfigMT 1 or 4
	beqz	t2, 1f

	move	v1, ra
	jal	__tlbinvalall
	move	ra, v1 
	
	mfc0	t0, C0_CONFIG3
	and	t0, t0, CFG3_LPA
	beqz	t0, 1f
	
	li	t0, PAGEGRAIN_ELPA
	mtc0	t0, C0_PAGEGRAIN
#if _MIPS_SIM==_ABIO32
	.set	push
	.set	nomicromips
	mthc0	zero, C0_PAGEMASK
	.set	pop
#endif 
	PTR_MTC0 zero, C0_PAGEMASK
1:	jr	ra
END(__init_tlb)
