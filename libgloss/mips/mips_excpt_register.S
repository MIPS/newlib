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

#include <mips/asm.h>
#include <mips/cpu.h>
#include "excpt.h"

	# Create space to store k0, k1, ra and sp
	.data
	.global	__start_ctx
__start_ctx:
	.space	SZREG * 7
#if defined (__mips_micromips)
	.space	SZREG
#define	start_ctx_conf3	(SZREG * 7)	/* saved Config3 $16,3 for micromips */
#endif
#define	start_ctx_sr	(SZREG * 0)
#define	start_ctx_k0	(SZREG * 1)
#define	start_ctx_k1	(SZREG * 2)
#define	start_ctx_ra	(SZREG * 3)
#define	start_ctx_sp	(SZREG * 4)
#define	start_ctx_ebase	(SZREG * 5)	/* saved EBASE */
#define	chain_ebase	(SZREG * 6)	/* chained EBASE */

#
# FUNCTION:	__register_excpt_handler
#
# DESCRIPTION: Save k0, k1, ra and sp. Register __exception_entry
#	       at EBASE+0x180. Return the new value for C0_SR.
#
	.text
	.weak	__register_excpt_handler
	.ent	__register_excpt_handler
__register_excpt_handler:
	.set	push
	.set	noat
	.set	noreorder

	# Fetch initial status
	mfc0	$8, C0_SR

	# Get into a sane state.
	# Important things: base mode is kernel and ERL, ESL, IE, BEV are clear
	mfc0	$0, C0_SR
	ehb

	# Save C0_SR IE and BEV
	LA	$9, __start_ctx
	REG_S	$8, start_ctx_sr($9)

	# Save k0, k1, ra, sp
	REG_S	$26, start_ctx_k0($9)
	REG_S	$27, start_ctx_k1($9)
	REG_S	$4, start_ctx_ra($9)	/* $4 holds $31 */
	REG_S	$29, start_ctx_sp($9)

	# Save C0_EBASE
	mfc0	$10, C0_EBASE
	REG_S	$10, start_ctx_ebase($9)

#if defined (__mips_micromips)
	# Save Config3
	mfc0	$10, C0_CONFIG3
	REG_S	$10, start_ctx_conf3($9)

	# Set Config3.ISAOnExc for micromips
	lui	$4, 1			/* 0x10000 */
	or	$4, $4, $10
	mtc0	$4, C0_CONFIG3
#endif

	# Check if we booted with BEV==1
	lui	$10, %hi(SR_BEV)
	and	$10, $8, $10
	beqz	$10, 1f
	nop

	# Yes - set chain_ebase to 0xbfc00200
	# Apply the offset of 0x200 so that the boot vector entries line up
	# with the offsets in a non-boot vector
	lui	$10, 0xbfc0
	ori	$10, $10, 0x200
	REG_S	$10, chain_ebase($9)
	b	2f
	nop

	# No - set chain_ebase to C0_EBASE
1:	mfc0	$10, C0_EBASE
	REG_S	$10, chain_ebase($9)

	# Set BEV=1 to allow changing EBASE
	lui	$10, %hi(SR_BEV)
	mtc0	$10, C0_SR
	ehb

	# Set desired EBASE
2:	LA	$10, __excpt_ebase
	mtc0	$10, C0_EBASE
	ehb

	# Clear BEV
	mtc0	$0, C0_SR
	ehb

	# Turn on use of the special exception vector and enable interrupts
	lui	$9, %hi(CR_IV)
	mtc0	$9, C0_CAUSE
	ehb

	# Enable interrupts in the new status value
	addiu	$2, $0, SR_IE

	jr	$31
	nop

	.set	pop
	.end	__register_excpt_handler

#
# FUNCTION:	__return_to_boot (int exit_code)
#
# DESCRIPTION: UHI EXIT wasn't handled, return back to caller of _start 
#
	.text
	.weak	__return_to_boot
	.ent	__return_to_boot
__return_to_boot:
	.set	push
	.set	noat
	.set	noreorder

	# Set BEV=1 to allow changing EBASE
	mfc0	$9, C0_SR
	lui	$10, %hi(SR_BEV)
	or	$9, $9, $10
	mtc0	$9, C0_SR
	ehb

	# Restore C0_EBASE
	LA	$9, __start_ctx
	LD	$9, start_ctx_ebase($9)
	mtc0	$9, C0_EBASE
	ehb

	# Restore k0, k1, ra, sp and sr
	LA	$9, __start_ctx
	LD	$26, start_ctx_k0($9)
	LD	$27, start_ctx_k1($9)
	LD	$29, start_ctx_sp($9)
	LD	$31, start_ctx_ra($9)

#if defined (__mips_micromips)
	# Restore Config3
	LD	$2, start_ctx_conf3($9)
	mtc0	$2, C0_CONFIG3
#endif

	LD	$9, start_ctx_sr($9)

	# Restore C0_STATUS IE and BEV to boot value
	mtc0	$9, C0_SR
	mtc0	$0, C0_CAUSE

	# Return with exit code
	move	$2, $4
	jr.hb	$31
	nop

	.set	pop
	.end	__return_to_boot

#
# FUNCTION:	int __chain_uhi_excpt (struct gpctx *ctx);
#
# DESCRIPTION: Call exception handler of the boot 
#
	.text
	.weak	__chain_uhi_excpt
	.ent	__chain_uhi_excpt
__chain_uhi_excpt:
	.set	push
	.set	noat
	.set	noreorder

	# Move context pointer into position.  Use $3 as scratch
	# as it is the only register that is clobbered by all
	# UHI calls and is not used as an input.
	move	$3, $4

#if (__mips_isa_rev < 6)
	LD	$9, CTX_HI0($3)
	LD	$10, CTX_LO0($3)
	mthi	$9
	mtlo	$10
#endif

	lw	$9, CTX_STATUS($3)
	mtc0	$9, C0_SR
	LD	$9, CTX_EPC($3)
	PTR_MTC0 $9, C0_EPC
	ehb

	# Restore the common context
	LD	$1, CTX_AT($3)
	LD	$2, CTX_V0($3)
	LD	$4, CTX_A0($3)
	LD	$5, CTX_A1($3)
	LD	$6, CTX_A2($3)
	LD	$7, CTX_A3($3)
	LD	$8, CTX_T0($3)
	LD	$9, CTX_T1($3)
	LD	$10, CTX_T2($3)
	LD	$11, CTX_T3($3)
	LD	$12, CTX_T4($3)
	LD	$13, CTX_T5($3)
	LD	$14, CTX_T6($3)
	LD	$15, CTX_T7($3)
	LD	$16, CTX_S0($3)
	LD	$17, CTX_S1($3)
	LD	$18, CTX_S2($3)
	LD	$19, CTX_S3($3)
	LD	$20, CTX_S4($3)
	LD	$21, CTX_S5($3)
	LD	$22, CTX_S6($3)
	LD	$23, CTX_S7($3)
	LD	$24, CTX_T8($3)
	LD	$25, CTX_T9($3)
	LD	$28, CTX_GP($3)
	LD	$29, CTX_SP($3)
	LD	$30, CTX_FP($3)
	LD	$31, CTX_RA($3)

	# Restore chained exception handlers kernel regs
	LA	$3, __start_ctx
	LD	$26, start_ctx_k0($3)
	LD	$27, start_ctx_k1($3)

#if defined (__mips_micromips)
	# OR the address with Config3.ISAOnExc bit
	LD	$3, start_ctx_conf3($3)
	srl	$3, $3, 16
	andi	$3, $3, 1
	beqz	$3, 1f
	nop

	# Compute exception vector
	LA	$3, __start_ctx
	LD	$3, chain_ebase($3)
	PTR_ADDU $3, $3, 0x181		# OR ISAOnExc bit

	# Chain
	jr	$3
	nop
1:
	# Compute exception vector
	LA	$3, __start_ctx
#endif

	LD	$3, chain_ebase($3)
	PTR_ADDU $3, $3, 0x180

	# Chain
	jr	$3
	nop

	.set	pop
	.end	__chain_uhi_excpt

#
# FUNCTION:	int __get_startup_BEV (void)
#
# DESCRIPTION: Return value of BEV flag saved in
#	       __register_excpt_handler.
#
	.text
	.globl	__get_startup_BEV
	.ent	__get_startup_BEV
__get_startup_BEV:
	.set	push
	.set	noat
	.set	noreorder

	LA	$2, __start_ctx
	LD	$2, start_ctx_sr($2)
	lui	$3, %hi(SR_BEV)
	and	$2, $2, $3
	jr	$31
	nop

	.set	pop
	.end	__get_startup_BEV
