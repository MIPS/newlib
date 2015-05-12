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
 * m64tlb_ops.S: MIPS XPA TLB support functions
 *
 */
#include <mips/m64tlb.h>
#include <mips/asm.h>
#include <mips/endian.h>

#define PTR_XO32_MTC0(top, bot, reg)	\
	mtc0	bot, reg; 		\
	.set	push;			\
	.set	nomicromips;		\
	mthc0	top, reg; 		\
	.set	pop;			\

#define PTR_XO32_MFC0(top, bot, reg)	\
	mfc0 	bot, reg;		\
	.set	push;			\
	.set	nomicromips;		\
	mfhc0 	top, reg;		\
	.set	pop;			\


LEAF(end_test)
#if _MIPS_SIM==_ABO32
#if BYTE_ORDER == BIG_ENDIAN
	PTR_L	t1, 0(a0)
	PTR_L	t2, 4(a0)
	PTR_S	t1, 0(a1)
	PTR_S	t2, 4(a1)
#endif
#endif
	jr	ra
END(end_test)

/*
 * void m64_tlbwi2(tlbhi_t hi, tlblo_t lo0, tlblo_t lo1, unsigned mask,
 *			unsigned idx)
 *
 * Writes hi,lo0,lo1 and msk in to the TLB entry specified by index.
 *
 */
LEAF(m64_tlbwi2)
#if _MIPS_SIM==_ABIO32
#if BYTE_ORDER == BIG_ENDIAN
	PTR_XO32_MTC0(a0, a1, $entryhi)
	PTR_XO32_MTC0(a2, a3, $entrylo0)

	PTR_L	t1, 20(sp)
	PTR_L	t2, 16(sp)
	PTR_XO32_MTC0(t2, t1, $entrylo1)

	PTR_L	t1, 28(sp)
	PTR_L	t2, 24(sp)
	PTR_XO32_MTC0(t2, t1, $pagemask)
#elif BYTE_ORDER == LITTLE_ENDIAN
	PTR_XO32_MTC0(a1, a0, $entryhi)
	PTR_XO32_MTC0(a3, a2, $entrylo0)

	PTR_L	t2, 20(sp)
	PTR_L	t1, 16(sp)
	PTR_XO32_MTC0(t2, t1, $entrylo1)

	PTR_L	t2, 28(sp)
	PTR_L	t1, 24(sp)
	PTR_XO32_MTC0(t2, t1, $pagemask)
#endif

	PTR_L	ta0, 32(sp)
#else /* _MIPS_SIM==N32 || _MIPS_SIM==N64 */
	PTR_MTC0 a0, $entryhi
	PTR_MTC0 a1, $entrylo0
	PTR_MTC0 a2, $entrylo1
	PTR_MTC0 a3, $pagemask
#endif

	PTR_MTC0 ta0, $index
	ehb			# mtc0, hazard barrier on tlbwi
	tlbwi
	jr.hb	ra
END(m64_tlbwi2)


/*
 * void m64_tlbwr2(tlbhi_t hi, tlblo_t lo0, tlblo_t lo1, unsigned mask)
 *
 * Writes hi, lo0, lo1 and msk into the TLB entry specified by the 
 * Random register.
 *
 */
LEAF(m64_tlbwr2)
#if _MIPS_SIM==_ABIO32
#if BYTE_ORDER == BIG_ENDIAN
	PTR_XO32_MTC0(a0, a1, $entryhi)
	PTR_XO32_MTC0(a2, a3, $entrylo0)

	PTR_L	t1, 20(sp)
	PTR_L	t2, 16(sp)
	PTR_XO32_MTC0(t2, t1, $entrylo1)

	PTR_L	t1, 28(sp)
	PTR_L	t2, 24(sp)
	PTR_XO32_MTC0(t2, t1, $pagemask)
#elif BYTE_ORDER == LITTLE_ENDIAN
	PTR_XO32_MTC0(a1, a0, $entryhi)
	PTR_XO32_MTC0(a3, a2, $entrylo0)

	PTR_L	t1, 16(sp)
	PTR_L	t2, 20(sp)
	PTR_XO32_MTC0(t2, t1, $entrylo1)

	PTR_L	t1, 24(sp)
	PTR_L	t2, 28(sp)
	PTR_XO32_MTC0(t2, t1, $pagemask)
#endif 
#else
	PTR_MTC0 a0,$entryhi
	PTR_MTC0 a1,$entrylo0
	PTR_MTC0 a2,$entrylo1
	PTR_MTC0 a3,$pagemask
#endif	
	ehb
	tlbwr
	jr.hb	ra
END(m64_tlbwr2)

/*
 * int m64_tlbrwr2(tlbhi_t hi, tlblo_t lo0, tlblo_t lo1, unsigned mask)
 *
 * Probes the TLB for an entry matching hi and if present rewrites that 
 * entry, otherwise updates a random entry. A safe way to update the TLB.
 *
 */
LEAF(m64_tlbrwr2)
#if _MIPS_SIM==_ABIO32
	PTR_XO32_MFC0(t1, t0, $entryhi)
#if BYTE_ORDER == BIG_ENDIAN
	PTR_XO32_MTC0(a0, a1, $entryhi)
#elif BYTE_ORDER == LITTLE_ENDIAN
	PTR_XO32_MTC0(a1, a0, $entryhi)
#endif
#else /* _MIPS_SIM==_ABIO32 */
	PTR_MFC0 t0,$entryhi
	PTR_MTC0 a0,$entryhi
#endif /* _MIPS_SIM==_ABIO32 */
	ehb		# MTCO, hazard on tlbp
	
	tlbp
	ehb		# tlbp, hazard on MFCO $index

	mfc0	v0,$index
#if _MIPS_SIM==_ABIO32
#if BYTE_ORDER == BIG_ENDIAN
	PTR_XO32_MTC0(a2, a3, $entrylo0)

	PTR_L	t2, 20(sp)
	PTR_L	t3, 16(sp)
	PTR_XO32_MTC0(t3, t2, $entrylo1)

	PTR_L	t2, 28(sp)
	PTR_L	t3, 24(sp)
	PTR_XO32_MTC0(t3, t2, $pagemask)
#elif BYTE_ORDER == LITTLE_ENDIAN
	PTR_XO32_MTC0(a3, a2, $entrylo0)

	PTR_L	t3, 20(sp)
	PTR_L	t2, 16(sp)
	PTR_XO32_MTC0(t3, t2, $entrylo1)

	PTR_L	t3, 28(sp)
	PTR_L	t2, 24(sp)
	PTR_XO32_MTC0(t3, t2, $pagemask)
#endif
#else /* _MIPS_SIM==_ABIO32 */
	PTR_MTC0 a1,$entrylo0
	PTR_MTC0 a2,$entrylo1
	PTR_MTC0 a3,$pagemask
#endif /* _MIPS_SIM==_ABIO32 */
	ehb		# mtc0, hazard on tlbwi
	bltz	v0,1f	# no matching entry

	tlbwi
#if _MIPS_SIM==_ABIO32
	PTR_XO32_MTC0(t1, t0, $entryhi)
#else /* _MIPS_SIM==_ABIO32 */
	PTR_MTC0 t0,$entryhi
#endif /* _MIPS_SIM==_ABIO32 */
	jr.hb	ra

1:	tlbwr
#if _MIPS_SIM==_ABIO32
	PTR_XO32_MTC0(t1, t0, $entryhi)
#else /* _MIPS_SIM==_ABIO32 */
	PTR_MTC0 t0,$entryhi
#endif /* _MIPS_SIM==_ABIO32 */
	jr.hb	ra
END(m64_tlbrwr2)


/*
 * void m64_tlbri2(tlbhi_t *hi, tlblo_t *lo0, tlblo_t *lo1, unsigned *mask,
 *		unsigned index)
 *
 * Reads the TLB entry with specified by index, and returns the EntryHi, EntryLo0, 
 * EntryLo1 and PageMask parts in *phi, *plo0, *plo1 and *pmsk respectively.
 *
 */
LEAF(m64_tlbri2)
#if _MIPS_SIM==_ABIO32
        PTR_L   ta0,16(sp)      # index
#endif /* _MIPS_SIM==_ABIO32 */
	mtc0	ta0,$index
	ehb			# mtc0, hazard on tlbr

	tlbr
	ehb			# tlbr, hazard on entry*, pagemask
#if _MIPS_SIM==_ABIO32
	PTR_XO32_MFC0(t0, t1, $entryhi)
	PTR_XO32_MFC0(t2, t3, $entrylo0)
	PTR_XO32_MFC0(t4, t5, $entrylo1)
	PTR_XO32_MFC0(t6, t7, $pagemask)
#if BYTE_ORDER == BIG_ENDIAN
	PTR_S	t0,0(a0)
	PTR_S	t1,4(a0)
	PTR_S	t2,0(a1)
	PTR_S	t3,4(a1)
	PTR_S	t4,0(a2)
	PTR_S	t5,4(a2)
	PTR_S	t6,0(a3)
	PTR_S	t7,4(a3)
#elif BYTE_ORDER == LITTLE_ENDIAN
	PTR_S	t1,0(a0)
	PTR_S	t0,4(a0)
	PTR_S	t3,0(a1)
	PTR_S	t2,4(a1)
	PTR_S	t5,0(a2)
	PTR_S	t4,4(a2)
	PTR_S	t7,0(a3)
	PTR_S	t6,4(a3)
#endif /* BYTE_ORDER */
#else /* _MIPS_SIM==_ABIO32 */
	PTR_MFC0 t0,$entryhi
	PTR_MFC0 t1,$entrylo0
	PTR_MFC0 t2,$entrylo1
	PTR_MFC0 t3,$pagemask
	PTR_S	t0,0(a0)
	PTR_S	t1,0(a1)
	PTR_S	t2,0(a2)
	PTR_S	t3,0(a3)
#endif /* _MIPS_SIM==_ABIO32 */
	jr	ra
END(m64_tlbri2)


/*
 * int m64_tlbprobe2(tlbhi_t hi, tlblo_t *lo0, tlblo_t *lo1,
 * 	unsigned int *mask)
 * 
 * Probes the TLB for an entry matching hi and returns its index, or -1 if 
 * not found. If found, then the EntryLo0, EntryLo1 and PageMask parts of the 
 * entry are also returned in *plo0, *plo1 and *pmsk respectively.
 *
 */
LEAF(m64_tlbprobe2)
#if _MIPS_SIM==_ABIO32
	PTR_XO32_MFC0(t9, t8,$entryhi)
	PTR_L	t0,16(sp)
#if BYTE_ORDER == BIG_ENDIAN
	PTR_XO32_MTC0(a0, a1,$entryhi)
#elif BYTE_ORDER == LITTLE_ENDIAN
	PTR_XO32_MTC0(a1, a0, $entryhi)
#endif /* BYTE_ORDER */

#else /* _MIPS_SIM==_ABIO32 */
	PTR_MFC0 t8,$entryhi
	PTR_MTC0 a0,$entryhi
#endif /* _MIPS_SIM==_ABIO32 */
	ehb			# mtc0, hazard on tlbp

	tlbp
	ehb			# tlpb, hazard on index.

	mfc0	v0,$index
	bltz	v0,1f		# Return -1 if not found.

	tlbr
	ehb			# tlbr, hazard on entry*, pagemask
# return entrylo, entrylo1, pagermask
#if _MIPS_SIM==_ABIO32
	PTR_XO32_MFC0(t2, t3, $entrylo0)
	PTR_XO32_MFC0(t4, t5, $entrylo1)
	PTR_XO32_MFC0(t6, t7, $pagemask)
#if BYTE_ORDER == BIG_ENDIAN
	PTR_S	t2,0(a2)
	PTR_S	t3,4(a2)
	PTR_S	t4,0(a3)
	PTR_S	t5,4(a3)
	PTR_S	t6,0(t0)
	PTR_S	t7,4(t0)
#elif BYTE_ORDER == LITTLE_ENDIAN
	PTR_S	t2,4(a2)
	PTR_S	t3,0(a2)
	PTR_S	t4,4(a3)
	PTR_S	t5,0(a3)
	PTR_S	t6,4(t0)
	PTR_S	t7,0(t0)
#endif /* BYTE_ORDER */
#else /* _MIPS_SIM==_ABIO32 */
	PTR_MFC0 t1,$entrylo0
	PTR_MFC0 t2,$entrylo1
	PTR_MFC0 t3,$pagemask
	PTR_S	t1,0(a1)
	PTR_S	t2,0(a2)
	PTR_S	t3,0(a3)
#endif /* _MIPS_SIM==_ABIO32 */

#if _MIPS_SIM==_ABIO32
	PTR_XO32_MTC0(t9, t8, $entryhi)
#else /* _MIPS_SIM==_ABIO32 */
	PTR_MTC0 t8,$entryhi
#endif /* _MIPS_SIM==_ABIO32 */
	jr.hb	ra

1:	li	v0,-1
#if _MIPS_SIM==_ABIO32
	PTR_XO32_MTC0(t9, t8, $entryhi)
#else /* _MIPS_SIM==_ABIO32 */
	PTR_MTC0 t8,$entryhi
#endif /* _MIPS_SIM==_ABIO32 */

	jr.hb	ra
END(m64_tlbprobe2)


/*
 * void m64_tlbinval(tlbhi_t a0)
 * 
 * Probes the TLB for an entry matching hi, and if present invalidates it.
 *
 */
LEAF(m64_tlbinval)

#if _MIPS_SIM==_ABIO32
	PTR_XO32_MFC0(t9, t8,$entryhi)
#if BYTE_ORDER == BIG_ENDIAN
	PTR_XO32_MTC0(a0, a1, $entryhi)
#elif BYTE_ORDER == LITTLE_ENDIAN
	PTR_XO32_MTC0(a1, a0, $entryhi)
#endif
#else /* _MIPS_SIM==_ABIO32 */
	PTR_MFC0 t8,$entryhi
	PTR_MTC0 a0,$entryhi
#endif /* _MIPS_SIM==_ABIO32 */
	ehb			# mtc0, Hazard on tlbp

	tlbp
	ehb			# tlbp, Hazard on index, entry*

	mfc0	v0, $index
	bltz	v0, 4f

#if _MIPS_SIM==_ABIO32
	PTR_XO32_MTC0(zero, zero, $entrylo0)
	PTR_XO32_MTC0(zero, zero, $entrylo1)
#else
	PTR_MTC0 zero, $entrylo0
	PTR_MTC0 zero, $entrylo1
#endif /* _MIPS_SIM==_ABIO32 */

	PTR_MFC0 v1, $config, 4
	and	v1, v1, CFG4_IE_INV
	beqz	v1, 2f

	li	v1, C0_ENTRYHI_EHINV_MASK
	b	3f
#if _MIPS_SIM==_ABIO32
2:	li	v0, -1
	li	v1, KSEG0_BASE
3:	PTR_XO32_MTC0(v0, v1, $entryhi)
#else	
2:	li	v1, KSEG0_BASE	# replace with this, plus 
3:	PTR_MTC0 v1, $entryhi
#endif
	ehb			# mtco, hazard on tlbwi

	tlbwi
	ehb			# tlbwi uses $entryhi late 

4:
#if _MIPS_SIM==_ABIO32
	PTR_XO32_MTC0(t9, t8, $entryhi)
#else /* _MIPS_SIM==_ABIO32 */
	PTR_MTC0 t8,$entryhi
#endif /* _MIPS_SIM==_ABIO32 */
	jr.hb	ra
END(m64_tlbinval)

/*
 * void m64_init_tlb()
 *
 * Initialize the tlb. Since we're using XPA,
 * we shall set the PageGrain[ELPA] bit. 
 *
 */
LEAF(m64_init_tlb)

	move	v1, ra
	jal	m64_tlbinvalall
	move	ra, v1 
	
	PTR_MFC0 t0, $config, 3
	and	t0, t0, CFG3_LPA
	beqz	t0, 1f
	
	li	t0, PAGEGRAIN_ELPA
	PTR_MTC0 t0, C0_PAGEGRAIN
#if _MIPS_SIM==_ABIO32
	PTR_XO32_MTC0(zero, zero, C0_PAGEMASK)
#else /* _MIPS_SIM==_ABIO32 */
	PTR_MTC0 zero, C0_PAGEMASK
#endif /* _MIPS_SIM==_ABIO32 */
1:	jr	ra
END(m64_init_tlb)
