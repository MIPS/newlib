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

#define _BOOTCODE

#include <mips/m32c0.h>
#include <mips/asm.h>
#include <mips/regdef.h>
#include "predef.h"

/*
 * void __tlbinvalall()
 *
 * Invalidate the TLB.
 */

LEAF(__init_tlb)	
#if HAVE_LPA
	li	t0, PAGEGRAIN_ELPA
	PTR_MTC0 t0, C0_PAGEGRAIN
#endif
#if HAVE_LPA && _MIPS_SIM==_ABIO32
	mthc0	zero, C0_PAGEMASK
#endif /* _MIPS_SIM==_ABIO32 */
	PTR_MTC0 zero, C0_PAGEMASK
	PTR_MTC0 zero, C0_ENTRYLO0
	PTR_MTC0 zero, C0_ENTRYLO1

#if HAVE_HW_TLB_WALK
7:	# TLB walk done by hardware, Config4[IE] = 3 or Config[MT] = 1
	li	t1, C0_ENTRYHI_EHINV_MASK
	mtc0	t1, C0_ENTRYHI
	mtc0	zero, C0_INDEX
	ehb
	.set	push
	.set	mips32r3
	tlbinvf
	.set	pop
#endif 


#if HAVE_SW_TLB_WALK
8:	/* TLB walk done by software, Config4[IE] = 2, Config[MT] = 4
	 *
	 * one TLBINVF is executed with an index in VTLB range to
	 * invalidate all VTLB entries.
	 *
	 * One TLBINVF is executed per FTLB set with the appropriate
	 * index to invalidate the corresponding set.
	 *
	 */
#if TLB_DUAL	
	li	t2, 1<<(C0_CONFIG4_VALUE & CFG4_FTLBS_MASK)
#else
	li	t2, 0
#endif
	li	t1, ((C0_CONFIG4_VALUE & CFG4_VTLBSEXT_MASK) << \
	(CFG4_VTLBSEXT_SHIFT - CFG1_MMUS_BITS)) +\
	 ((C0_CONFIG1_VALUE & CFG1_MMUS_MASK) >>CFG1_MMUS_SHIFT)
	

	addu	t2, t2, t1			
	addu	t2, t2, 1			# VTLB Size + FTLB Sets, end ptr
	
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
#endif 

#if HAVE_NO_INV
9:	# Clean invalidate TLB for R1 onwards by loading 
	# 0x(FFFFFFFF)KSEG0_BASE into EntryHi and writing it into index MAX
	# incrementing EntryHi by a pagesize, writing into index MAX-1, etc.
	li	v0, MMU_SIZE
	
	# If large physical addressing is enabled, load 0xFFFFFFFF
	# into the top half of EntryHi.
#if HAVE_LPA
	PTR_MFC0 t1, C0_PAGEGRAIN
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
#endif
10:	li	t1, KSEG0_BASE

12:	PTR_MTC0 t1,C0_ENTRYHI
	addu	v0, v0, -1
	mtc0	v0,C0_INDEX
	ehb					# mtc0, hazard on tlbwi
	tlbwi
	addu	t1, t1, (2<<13)
	bnez	v0, 12b
#endif

11:	PTR_MTC0 zero,C0_ENTRYHI			# Unset EntryHI
	jr.hb	ra
END(__init_tlb)
