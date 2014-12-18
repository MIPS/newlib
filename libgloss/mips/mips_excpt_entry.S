##############################################################################
#
#               file : $File$
#  date last revised : $Date$
#
#          copyright : 2013 - 2014 by Imagination Technologies.
#                      All rights reserved.
#                      No part of this software, either material or conceptual
#                      may be copied or distributed, transmitted, transcribed,
#                      stored in a retrieval system or translated into any
#                      human or computer language in any form by any means,
#                      electronic, mechanical, manual or otherwise, or
#                      disclosed to third parties without the express written
#                      permission of:
#                        Imagination Technologies, Home Park Estate,
#                        Kings Langley, Hertfordshire, WD4 8LZ, U.K.
#
#        description : Exception code
#
##############################################################################

# Keep each function in a separate named section
#define _FUNCTION_SECTIONS_

#include <mips/asm.h>
#include <mips/regdef.h>
#include <mips/cpu.h>
#include "excpt.h"

#if (defined (__mips64) && (defined (_MIPS_SIM) && _MIPS_SIM == _ABI64) \
     || defined (__mips_eabi))
# define HAS_64BIT_ADDRESS
#else
# define HAS_32BIT_ADDRESS
#endif

#ifdef HAS_64BIT_ADDRESS
# define LA	dla
#else
# define LA	la
#endif

#ifdef __mips64
# define LD	ld
# define ST	sd
#else
# define LD	lw
# define ST	sw
#endif

# Context size, adjusted for ABI parameter area
#define ADJ 16
#define CTX_SIZEADJ (CTX_SIZE + ADJ)

#define e_ISR	s1
#define e_CR	s3
#define e_SRO	s4
#define e_SR	s5
#define e_EPC	s6
#define e_RA	s7

#
# FUNCTION:	__exception_entry
#
# DESCRIPTION: Exception entry point. This is small because it must go at
#			   EBASE+0x180. It saves enough context to chain onwards to
#			   __exception_save.
#
NESTED(__exception_entry, 0, ra)
	.set	push
	.set	noat
	.set	noreorder

	# Free up k1, defering sp adjustment until later
	ST	k1, (-CTX_SIZE + CTX_K1)(sp)

	# Use k1 to invoke __exception_save
	LA	k1, __exception_save
	jr	k1
	nop

	.set    pop
END(__exception_entry)

#
# FUNCTION:	__exception_save
#
# DESCRIPTION: Exception context save. Save the context, then fake up a call
#              frame.
#
NESTED(__exception_save, CTX_SIZE, zero)
	.set	push
	.set	noat
	.set	noreorder

	# k1 is already saved, so use it to save the users sp
	move	k1, sp
	# Finally adjust sp
	addiu	sp, sp, CTX_SIZEADJ	# This should be picked up by the backtracer

	# Save context
	ST	$1, CTX_AT + ADJ(sp)
	ST	v0, CTX_V0 + ADJ(sp)
	ST	v1, CTX_V1 + ADJ(sp)
	ST	a0, CTX_A0 + ADJ(sp)
	ST	a1, CTX_A1 + ADJ(sp)
	ST	a2, CTX_A2 + ADJ(sp)
	ST	a3, CTX_A3 + ADJ(sp)
	ST	$8, CTX_T0 + ADJ(sp)	# a4 or t0
	ST	$9, CTX_T1 + ADJ(sp)	# a5 or t1
	ST	$10, CTX_T2 + ADJ(sp)	# a6 or t2
	ST	$11, CTX_T3 + ADJ(sp)	# a7 or t3
	ST	$12, CTX_T4 + ADJ(sp)	# t0 or t4
	ST	$13, CTX_T5 + ADJ(sp)	# t1 or t5
	ST	$14, CTX_T6 + ADJ(sp)	# t2 or t6
	ST	$15, CTX_T7 + ADJ(sp)	# t3 or t7
	ST	s0, CTX_S0 + ADJ(sp)
	ST	s1, CTX_S1 + ADJ(sp)
	ST	s2, CTX_S2 + ADJ(sp)
	ST	s3, CTX_S3 + ADJ(sp)
	ST	s4, CTX_S4 + ADJ(sp)
	ST	s5, CTX_S5 + ADJ(sp)
	ST	s6, CTX_S6 + ADJ(sp)
	ST	s7, CTX_S7 + ADJ(sp)
	ST	t8, CTX_T8 + ADJ(sp)
	ST	t9, CTX_T9 + ADJ(sp)
	ST	k0, CTX_K0 + ADJ(sp)
	ST	gp, CTX_GP + ADJ(sp)
	ST	k1, CTX_SP + ADJ(sp) # Use saved sp from earlier
	ST	fp, CTX_FP + ADJ(sp)
	ST	ra, CTX_RA + ADJ(sp)

	# Save DSP context
#if defined (__mips_dsp)
	rddsp	$9	# DSP Control register
	ST	$9, CTX_DSPC + ADJ(sp) 
	mfhi	$10, $ac1
	mflo	$11, $ac1
	mfhi	$12, $ac2
	mflo	$13, $ac2
	mfhi	$14, $ac3
	mflo	$15, $ac3
	ST	$10, CTX_HI1 + ADJ(sp)
	ST	$11, CTX_LO1 + ADJ(sp)
	ST	$12, CTX_HI2 + ADJ(sp)
	ST	$13, CTX_LO2 + ADJ(sp)
	ST	$14, CTX_HI3 + ADJ(sp)
	ST	$15, CTX_LO3 + ADJ(sp)
#endif

#if (__mips_isa_rev < 6) 
	mfhi	$9
	mflo	$10
	ST	$9, CTX_HI0 + ADJ(sp)
	ST	$10, CTX_LO0 + ADJ(sp)
#elif defined (__mips_dsp)
	mfhi	$9, $ac0
	mflo	$10, $ac0
	ST	$9, CTX_HI0 + ADJ(sp)
	ST	$10, CTX_LO0 + ADJ(sp)
#endif

	# Trick the backtracer into stepping back to the point where the exception
	# occurred.
	mfc0	ra, C0_EPC
	mfc0	e_CR, C0_CR
	ST	ra, CTX_EPC + ADJ(sp)

	# Start computing the address of the context for a0
	move	a0, sp

	# Manually set up the return address to restore the context below
	LA	ra, 1f
	# Extract the cause code
	and	a1, e_CR, CR_XMASK

	# Finish computing the address of the context for a0
	addiu	a0, ADJ

	# Shift exception number down into expected range
	srl	a1, 2

	# Exception
	b	__exception
	nop

1:	# Return point from handler
	# Load context

#if defined (__mips_dsp)
	LD	$9, CTX_DSPC + ADJ(sp)
	wrdsp	$9
	LD	$10, CTX_HI1 + ADJ(sp)
	LD	$11, CTX_LO1 + ADJ(sp)
	LD	$12, CTX_HI2 + ADJ(sp)
	LD	$13, CTX_LO2 + ADJ(sp)
	LD	$14, CTX_HI3 + ADJ(sp)
	LD	$15, CTX_LO3 + ADJ(sp)
	mthi	$10, $ac1
	mtlo	$11, $ac1
	mthi	$12, $ac2
	mtlo	$13, $ac2
	mthi	$14, $ac3
	mtlo	$15, $ac3
#endif

#if (__mips_isa_rev < 6)
	LD	$9, CTX_HI0 + ADJ(sp)
	LD	$10, CTX_LO0 + ADJ(sp)
	mthi	$9
	mtlo	$10
#elif defined (__mips_dsp)
	LD	$9, CTX_HI0 + ADJ(sp)
	LD	$10, CTX_LO0 + ADJ(sp)
	mthi	$9, $ac0
	mtlo	$10, $ac0
#endif

	LD	e_EPC, CTX_EPC + ADJ(sp)
	mtc0	e_EPC, C0_EPC
	LD	$1, CTX_AT + ADJ(sp)
	LD	v0, CTX_V0 + ADJ(sp)
	LD	v1, CTX_V1 + ADJ(sp)
	LD	a0, CTX_A0 + ADJ(sp)
	LD	a1, CTX_A1 + ADJ(sp)
	LD	a2, CTX_A2 + ADJ(sp)
	LD	a3, CTX_A3 + ADJ(sp)
	LD	$8, CTX_T0 + ADJ(sp)
	LD	$9, CTX_T1 + ADJ(sp)
	LD	$10, CTX_T2 + ADJ(sp)
	LD	$11, CTX_T3 + ADJ(sp)
	LD	$12, CTX_T4 + ADJ(sp)
	LD	$13, CTX_T5 + ADJ(sp)
	LD	$14, CTX_T6 + ADJ(sp)
	LD	$15, CTX_T7 + ADJ(sp)
	LD	s0, CTX_S0 + ADJ(sp)
	LD	s1, CTX_S1 + ADJ(sp)
	LD	s2, CTX_S2 + ADJ(sp)
	LD	s3, CTX_S3 + ADJ(sp)
	LD	s4, CTX_S4 + ADJ(sp)
	LD	s5, CTX_S5 + ADJ(sp)
	LD	s6, CTX_S6 + ADJ(sp)
	LD	s7, CTX_S7 + ADJ(sp)
	LD	t8, CTX_T8 + ADJ(sp)
	LD	t9, CTX_T9 + ADJ(sp)
	LD	k0, CTX_K0 + ADJ(sp)
	LD	k1, CTX_K1 + ADJ(sp)
	LD	gp, CTX_GP + ADJ(sp)
	LD	fp, CTX_FP + ADJ(sp)
	LD	ra, CTX_RA + ADJ(sp)
	LD	sp, CTX_SP + ADJ(sp)
	# Return from exception
	eret
	.set	pop
END(__exception_save)
