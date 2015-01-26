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
#        description : Register exception handler
#
##############################################################################

#include "regs.S"
#include "excpt.h"

#if (defined (__mips64) && (defined (_MIPS_SIM) && _MIPS_SIM == _ABI64) \
     || defined (__mips_eabi))
# define LA	dla
# define PTR_ADDU daddu
#else
# define LA	la
# define PTR_ADDU addu
#endif

#if (defined (__mips64) && (_MIPS_SIM == _ABI64 || _MIPS_SIM == _ABIO64 || \
     _MIPS_SIM == _ABIN32 || defined (__mips_eabi)))
# define STRIDE  8
# define LD	ld
# define ST	sd
#else
# define STRIDE  4
# define LD	lw
# define ST	sw
#endif

#define	C0_EBASE	$15,1
#define	C0_CONFIG3	$16,3
#define SR_IE		0x00000001
#define ADJ		16

	# Create space to store k0, k1, ra and sp
	.data
	.global	__start_ctx
__start_ctx:
	.space	STRIDE * 7
#if defined (__mips_micromips)
	.space	STRIDE
#define	start_ctx_conf3	(STRIDE * 7)	/* saved Config3 $16,3 for micromips */
#endif
#define	start_ctx_sr	(STRIDE * 0)
#define	start_ctx_k0	(STRIDE * 1)
#define	start_ctx_k1	(STRIDE * 2)
#define	start_ctx_ra	(STRIDE * 3)
#define	start_ctx_sp	(STRIDE * 4)
#define	start_ctx_ebase	(STRIDE * 5)	/* saved EBASE */
#define	chain_ebase	(STRIDE * 6)	/* chained EBASE */


#
# FUNCTION:	__register_excpt_handler
#
# DESCRIPTION: Save k0, k1, ra and sp. Register __exception_entry
#	       at EBASE+0x180
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

	# Disable interrupts before anything else gets in
	di
	nop

	# Save C0_SR IE and BEV
	LA	$9, __start_ctx
	ST	$8, start_ctx_sr($9)

	# Save k0, k1, ra, sp
	ST	$26, start_ctx_k0($9)
	ST	$27, start_ctx_k1($9)
	ST	$4, start_ctx_ra($9)	/* $4 holds $31 */
	ST	$29, start_ctx_sp($9)

	# Save C0_EBASE
	mfc0	$10, C0_EBASE
	ST	$10, start_ctx_ebase($9)

#if defined (__mips_micromips)
	# Save Config3
	mfc0	$10, C0_CONFIG3
	ST	$10, start_ctx_conf3($9)

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
	ST	$10, chain_ebase($9)
	b	2f
	nop

	# No - set chain_ebase to C0_EBASE
1:	mfc0	$10, C0_EBASE
	ST	$10, chain_ebase($9)

	# Set BEV=1 to allow changing EBASE
	lui	$10, %hi(SR_BEV)
	or	$8, $8, $10
	mtc0	$8, C0_SR

	# Set desired EBASE
2:	LA	$10, __excpt_ebase
	mtc0	$10, C0_EBASE

	# Clear BEV
	lui	$9, %hi(~SR_BEV)
	addiu	$9, %lo(~SR_BEV)
	and	$8, $8, $9
	mtc0	$8, C0_SR

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

	# Restore C0_EBASE
	LA	$9, __start_ctx
	LD	$9, start_ctx_ebase($9)
	mtc0	$9, C0_EBASE

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

	LD	$9, CTX_EPC($3)
	MTC0	$9, C0_EPC

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
