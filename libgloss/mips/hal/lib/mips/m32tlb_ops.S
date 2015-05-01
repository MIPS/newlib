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
 * m32tlb_ops.sx: MIPS32 TLB support functions
 */

#include <mips/asm.h>
#include <mips/regdef.h>
#include <mips/m32c0.h>
#include <mips/m32tlb.h>

/*
 * void mips_tlbwi2(tlbhi_t hi, tlblo_t lo0, tlblo_t lo1, unsigned mask,
 *			unsigned idx)
 */
LEAF(mips_tlbwi2)
#if _MIPS_SIM==_ABIN32 || _MIPS_SIM==_ABI64
	rmtc0	a0,$entryhi
	mtc0	a1,$entrylo0
	mtc0	a2,$entrylo1
	mtc0	a3,$pagemask
#elif _MIPS_SIM==_ABIO64
	ld	ta0,32(sp)	# index
	dmtc0	a0,$entryhi
	mtc0	a1,$entrylo0
	mtc0	a2,$entrylo1
	mtc0	a3,$pagemask
#else /* abi(32) */
	lw	ta0,16(sp)	# index
	rmtc0	a0,$entryhi
	mtc0	a1,$entrylo0
	mtc0	a2,$entrylo1
	mtc0	a3,$pagemask
#endif
	mtc0	ta0,$index
	ssnop
	ehb
	tlbwi
	.set push
	.set	noreorder
	jr.hb	ra
	nop
	.set pop
END(mips_tlbwi2)


/*
 * void mips_tlbwr2(tlbhi_t hi, tlblo_t lo0, tlblo_t lo1, unsigned mask)
 */
LEAF(mips_tlbwr2)
	rmtc0	a0,$entryhi
	mtc0	a1,$entrylo0
	mtc0	a2,$entrylo1
	mtc0	a3,$pagemask
	ssnop
	ehb
	tlbwr
	.set push
	.set noreorder
	jr.hb	ra
	nop
	.set pop
END(mips_tlbwr2)

/*
 * int mips_tlbrwr2(tlbhi_t hi, tlblo_t lo0, tlblo_t lo1, unsigned mask)
 *
 * like tlbwr BUT if the entry exists rewrite that entry instead;
 * the safest way to update the tlb returns probe result
 *
 * NOTE has side effect of setting entryhi
 */
LEAF(mips_tlbrwr2)
	rmtc0	a0,$entryhi
	ssnop
	ehb

	tlbp
	ssnop
	ehb

	mfc0	v0,$index
	mtc0	a1,$entrylo0
	mtc0	a2,$entrylo1
	mtc0	a3,$pagemask
	ssnop
	ehb
	bltz	v0,1f		/* doesnt exist */

	tlbwi
	.set push
	.set noreorder
	jr.hb	ra
	nop
	.set pop

1:	tlbwr
	.set push
	.set noreorder
	jr.hb	ra
	nop
	.set pop
END(mips_tlbrwr2)


/*
 * void mips_tlbri2(tlbhi_t *hi, tlblo_t *lo0, tlblo_t *lo1, unsigned *mask,
 *		unsigned index)
 */
LEAF(mips_tlbri2)
	lw	t0,16(sp)
	mtc0	t0,$index
	ssnop
	ehb

	tlbr
	ssnop; ssnop
	ehb

	rmfc0	t0,$entryhi
	mfc0	t1,$entrylo0
	mfc0	t2,$entrylo1
	mfc0	t3,$pagemask
	sr	t0,0(a0)
	sw	t1,0(a1)
	sw	t2,0(a2)
	sw	t3,0(a3)
	jr	ra
END(mips_tlbri2)


/*
 * int mips_tlbprobe2(tlbhi_t hi, tlblo_t *lo0, tlblo_t *lo1,
 *			unsigned int *mask)
 * look for entry entryhi not zapped
 */
LEAF(mips_tlbprobe2)
	rmfc0	t0,$entryhi
	rmtc0	a0,$entryhi
	ssnop
	ehb

	tlbp
	ssnop
	ehb

	mfc0	v0,$index
	bltz	v0,1f

	tlbr
	ssnop; ssnop
	ehb

	mfc0	v1,$entrylo0
	mfc0	t1,$entrylo1
	mfc0	t2,$pagemask

	rmtc0	t0,$entryhi	/* restore entry hi */

	sw	v1,0(a1)
	sw	t1,0(a2)
	sw	t2,0(a3)
	jr.hb	ra

1:	rmtc0	t0,$entryhi	/* restore entry hi */
	li	v0,-1
	jr.hb	ra
END(mips_tlbprobe2)


/*
 * void mips_tlbinval(tlbhi_t a0)
 * invalidate an entry entryhi is NOT changed
 */
LEAF(mips_tlbinval)
	rmfc0	t0,$entryhi	/* save old entry hi */
	rmtc0	a0,$entryhi
	ssnop
	ehb

	tlbp
	ssnop
	ehb

	mfc0	v0,$index
	mtc0	zero,$entrylo0
	mtc0	zero,$entrylo1
	li	v1,KSEG1_BASE	/* replace with this */
	rmtc0	v1,$entryhi
	ehb
	bltz	v0,1f

	tlbwi
	ssnop
	ehb			/* tlbwi uses $entryhi late */

1:	rmtc0	t0,$entryhi	/* restore entry hi */
	.set push
	.set noreorder
	jr.hb	ra
	nop
	.set pop
END(mips_tlbinval)

/*
 * int mips_tlb_size();
 *
 * return number of entries in tlb
 */
LEAF(mips_tlb_size)
	/* first see if we've got a TLB */
	mfc0	t0,$config,0
	mfc0	t1,$config,1
	move	v0,zero

	and	t0,CFG0_MT_MASK
	bne	t0,CFG0_MT_TLB,9f	/* this code doesn't support BAT */

	and	v0,t1,CFG1_MMUS_MASK	/* get number of entries */
	srl	v0,CFG1_MMUS_SHIFT
	addiu	v0,1

9:	jr	ra
END(mips_tlb_size)
