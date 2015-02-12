# Copyright (c) 2015, Imagination Technologies Ltd.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its
# contributors may be used to endorse or promote products derived from this
# software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

# Keep each function in a separate named section
#define _FUNCTION_SECTIONS_

#include <mips/asm.h>
#include <mips/regdef.h>
#include <mips/cpu.h>
#include "excpt.h"

# Context size, adjusted for ABI parameter area
#define ADJ (NARGSAVE * SZARG)
# Round up to 16-byte boundary (maximum stack alignment required for any
# supported ABI)
#define CTX_SIZEROUND ((CTX_SIZE + ALSZ) & ALMASK)
#define CTX_SIZEADJ (CTX_SIZEROUND + ADJ)

#define e_ISR	s1
#define e_CR	s3
#define e_BADV	s4
#define e_SR	s5
#define e_EPC	s6
#define e_RA	s7

# DESCRIPTION: Exception entry point. This is small because it must go at
#			   EBASE+0x180. It saves enough context to chain onwards to
#			   __exception_save.
#
LEAF(__exception_entry)
	.set	push
	.set	noat
	.set	noreorder
.weak   _mips_tlb_refill
	_mips_tlb_refill = __exception_save
__tlb_refill_loop:
	# Support an alternative entry point at the start of the exception
	# vector.  Since the exception vector is normally placed first
	# in the link map this allows a user to start execution from the
	# same address that an executable is loaded to.
	LA	k1, __first_boot
	lw	k1, 0(k1)
	beqz	k1, 1f
	nop
	# The start code is responsible for clearing __first_boot prior
	# to installing the exception handlers.
	j	_start
	nop
1:
	LA	k1, _mips_tlb_refill
	beqz	k1, __tlb_refill_loop
	nop
	jr	k1
	nop

	.org 0x80
.weak   _mips_xtlb_refill
	_mips_xtlb_refill = __exception_save
__xtlb_refill_loop:
	LA	k1, _mips_xtlb_refill
	beqz	k1, __xtlb_refill_loop
	nop
	jr	k1
	nop

	.org 0x100
.weak   _mips_cache_error
__cache_error_loop:
	LA	k1, _mips_cache_error
	beqz	k1, __cache_error_loop
	nop
	jr	k1
	nop

	.org 0x180
	# Free up k1, defering sp adjustment until later
	REG_S	k1, (-CTX_SIZEROUND + CTX_K1)(sp)

	# Use k1 to invoke __exception_save
	LA	k1, _mips_general_exception
	jr	k1
	nop
	.set    pop
END(__exception_entry)

LEAF(__isr_sw0)
	.set	push
	.set	noat
	.set	noreorder
.weak   _mips_isr_sw0
1:
	li	k0, 0
	LA	k1, _mips_isr_sw0
	beqz	k1, 1b
	nop
	jr	k1
	nop
	.set    pop
END(__isr_sw0)

LEAF(__isr_sw1)
	.set	push
	.set	noat
	.set	noreorder
.weak   _mips_isr_sw1
1:
	li	k0, 1
	LA	k1, _mips_isr_sw1
	beqz	k1, 1b
	nop
	jr	k1
	nop
	.set    pop
END(__isr_sw1)

LEAF(__isr_hw0)
	.set	push
	.set	noat
	.set	noreorder
.weak   _mips_isr_hw0
1:
	li	k0, 2
	LA	k1, _mips_isr_hw0
	beqz	k1, 1b
	nop
	jr	k1
	nop
	.set    pop
END(__isr_hw0)

LEAF(__isr_hw1)
	.set	push
	.set	noat
	.set	noreorder
.weak   _mips_isr_hw1
1:
	li	k0, 3
	LA	k1, _mips_isr_hw1
	beqz	k1, 1b
	nop
	jr	k1
	nop
	.set    pop
END(__isr_hw1)

LEAF(__isr_hw2)
	.set	push
	.set	noat
	.set	noreorder
.weak   _mips_isr_hw2
1:
	li	k0, 4
	LA	k1, _mips_isr_hw2
	beqz	k1, 1b
	nop
	jr	k1
	nop
	.set    pop
END(__isr_hw2)

LEAF(__isr_hw3)
	.set	push
	.set	noat
	.set	noreorder
.weak   _mips_isr_hw3
1:
	li	k0, 5
	LA	k1, _mips_isr_hw3
	beqz	k1, 1b
	nop
	jr	k1
	nop
	.set    pop
END(__isr_hw3)

LEAF(__isr_hw4)
	.set	push
	.set	noat
	.set	noreorder
.weak   _mips_isr_hw4
1:
	li	k0, 6
	LA	k1, _mips_isr_hw4
	beqz	k1, 1b
	nop
	jr	k1
	nop
	.set    pop
END(__isr_hw4)

LEAF(__isr_hw5)
	.set	push
	.set	noat
	.set	noreorder
.weak   _mips_isr_hw5
1:
	li	k0, 7
	LA	k1, _mips_isr_hw5
	beqz	k1, 1b
	nop
	jr	k1
	nop
	.set    pop
END(__isr_hw5)

#
# FUNCTION:	__exception_save
#
# DESCRIPTION: Exception context save. Save the context, then fake up a call
#              frame.
#
ANESTED(__exception_save, _mips_general_exception, CTX_SIZEADJ, zero)
	.globl  __exception_save;
	.set	push
	.set	noat
	.set	noreorder

	# k1 is already saved, so use it to save the users sp
	move	k1, sp
	# Finally adjust sp
	PTR_ADDU sp, sp, -CTX_SIZEADJ	# This should be picked up by the backtracer

	# Save context
	REG_S	$1, CTX_AT + ADJ(sp)
	REG_S	v0, CTX_V0 + ADJ(sp)
	REG_S	v1, CTX_V1 + ADJ(sp)
	REG_S	a0, CTX_A0 + ADJ(sp)
	REG_S	a1, CTX_A1 + ADJ(sp)
	REG_S	a2, CTX_A2 + ADJ(sp)
	REG_S	a3, CTX_A3 + ADJ(sp)
	REG_S	$8, CTX_T0 + ADJ(sp)	# a4 or t0
	REG_S	$9, CTX_T1 + ADJ(sp)	# a5 or t1
	REG_S	$10, CTX_T2 + ADJ(sp)	# a6 or t2
	REG_S	$11, CTX_T3 + ADJ(sp)	# a7 or t3
	REG_S	$12, CTX_T4 + ADJ(sp)	# t0 or t4
	REG_S	$13, CTX_T5 + ADJ(sp)	# t1 or t5
	REG_S	$14, CTX_T6 + ADJ(sp)	# t2 or t6
	REG_S	$15, CTX_T7 + ADJ(sp)	# t3 or t7
	REG_S	s0, CTX_S0 + ADJ(sp)
	REG_S	s1, CTX_S1 + ADJ(sp)
	REG_S	s2, CTX_S2 + ADJ(sp)
	REG_S	s3, CTX_S3 + ADJ(sp)
	REG_S	s4, CTX_S4 + ADJ(sp)
	REG_S	s5, CTX_S5 + ADJ(sp)
	REG_S	s6, CTX_S6 + ADJ(sp)
	REG_S	s7, CTX_S7 + ADJ(sp)
	REG_S	t8, CTX_T8 + ADJ(sp)
	REG_S	t9, CTX_T9 + ADJ(sp)
	REG_S	k0, CTX_K0 + ADJ(sp)
	REG_S	gp, CTX_GP + ADJ(sp)
	REG_S	k1, CTX_SP + ADJ(sp) # Use saved sp from earlier
	REG_S	fp, CTX_FP + ADJ(sp)
	REG_S	ra, CTX_RA + ADJ(sp)
	PTR_S	$0, CTX_LINK + ADJ(sp) # Clear the link field

#if (__mips_isa_rev < 6) 
	mfhi	$9
	mflo	$10
	REG_S	$9, CTX_HI0 + ADJ(sp)
	REG_S	$10, CTX_LO0 + ADJ(sp)
#endif

	# Trick the backtracer into stepping back to the point where the exception
	# occurred.
	PTR_MFC0 ra, C0_EPC
	mfc0	e_CR, C0_CR
	REG_S	ra, CTX_EPC + ADJ(sp)

	# Finish storing the rest of the CP0 registers
	PTR_MFC0 $9, C0_BADVADDR
	REG_S	$9, CTX_BADVADDR + ADJ(sp)
	sw	e_CR, CTX_CAUSE + ADJ(sp)

	move	$11, $0
	move	$12, $0
	mfc0	$9, C0_CONFIG3
	ext	$10, $9, CFG3_BP_BIT, 1
	beqz	$10, 1f
	mfc0	$11, C0_BADPINSTR
1:
	ext	$9, $9, CFG3_BI_BIT, 1
	beqz	$9, 1f
	mfc0	$12, C0_BADINSTR
1:
	sw	$11, CTX_BADPINSTR + ADJ(sp)
	sw	$12, CTX_BADINSTR + ADJ(sp)

	# Start computing the address of the context for a0
	move	a0, sp

	# Clear EXL.  Exceptions can now nest.
	mfc0	e_SR, C0_SR
	sw	e_SR, CTX_STATUS + ADJ(sp)
	lui	$9, %hi(~SR_EXL)
	addiu	$9, $9, %lo(~SR_EXL)
	and	e_SR, e_SR, $9
	mtc0	e_SR, C0_SR

	# Manually set up the return address to restore the context below
	LA	ra, 1f
	# Extract the cause code
	and	a1, e_CR, CR_XMASK

	# Finish computing the address of the context for a0
	addiu	a0, ADJ

	# Shift exception number down into expected range
	srl	a1, 2

	# Call the handler, indirect through t9 albeit not for any specific
	# reason
	LA	t9, _mips_handle_exception
	jr	t9
	nop

1:	# Return point from handler
	# Load context

#if (__mips_isa_rev < 6)
	REG_L	$9, CTX_HI0 + ADJ(sp)
	REG_L	$10, CTX_LO0 + ADJ(sp)
	mthi	$9
	mtlo	$10
#endif

	REG_L	$1, CTX_AT + ADJ(sp)
	REG_L	v0, CTX_V0 + ADJ(sp)
	REG_L	v1, CTX_V1 + ADJ(sp)
	REG_L	a0, CTX_A0 + ADJ(sp)
	REG_L	a1, CTX_A1 + ADJ(sp)
	REG_L	a2, CTX_A2 + ADJ(sp)
	REG_L	a3, CTX_A3 + ADJ(sp)
	REG_L	$8, CTX_T0 + ADJ(sp)
	REG_L	$9, CTX_T1 + ADJ(sp)
	REG_L	$10, CTX_T2 + ADJ(sp)
	REG_L	$11, CTX_T3 + ADJ(sp)
	REG_L	$12, CTX_T4 + ADJ(sp)
	REG_L	$13, CTX_T5 + ADJ(sp)
	REG_L	$14, CTX_T6 + ADJ(sp)
	REG_L	$15, CTX_T7 + ADJ(sp)
	REG_L	s0, CTX_S0 + ADJ(sp)
	REG_L	s1, CTX_S1 + ADJ(sp)
	REG_L	s2, CTX_S2 + ADJ(sp)
	REG_L	s3, CTX_S3 + ADJ(sp)
	REG_L	s4, CTX_S4 + ADJ(sp)
	REG_L	s5, CTX_S5 + ADJ(sp)
	REG_L	s6, CTX_S6 + ADJ(sp)
	REG_L	s7, CTX_S7 + ADJ(sp)
	REG_L	t8, CTX_T8 + ADJ(sp)
	REG_L	t9, CTX_T9 + ADJ(sp)
	REG_L	gp, CTX_GP + ADJ(sp)
	REG_L	fp, CTX_FP + ADJ(sp)
	REG_L	ra, CTX_RA + ADJ(sp)
	di
	lw	k0, CTX_STATUS + ADJ(sp)
	mtc0	k0, C0_SR
	REG_L	k1, CTX_EPC + ADJ(sp)
	PTR_MTC0 k1, C0_EPC
	ehb
	REG_L	sp, CTX_SP + ADJ(sp)
	REG_L	k0, CTX_K0 + ADJ(sp)
	REG_L	k1, CTX_K1 + ADJ(sp)
	# Return from exception
	eret
	.set	pop
END(__exception_save)
