# Copyright 2015, Imagination Technologies Limited and/or its
#                 affiliated group companies.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted under the terms of the MIPS Free To Use 1.0
# license that you will have received with this package. If you haven't
# received this file, please contact Imagination Technologies or see the
# following URL for details.
# http://codescape-mips-sdk.imgtec.com/license/IMG-free-to-use-on-MIPS-license

#include <mips/asm.h>
#include <mips/cpu.h>

EXPORTS(_count_wrap, 4)
	.word	0x0

#
# FUNCTION:
#
# DESCRIPTION:
#
LEAF(mips_start_minimal_counter)
	di	$8
	ehb
	#ori	$8, $8, SR_HINT5
	ori	$8, $8, SR_IE
	LA	$9, _count_wrap
	sw	$0, 0($9)
	li	$9, 1
	mtc0	$9, C0_COUNT
	mtc0	$0, C0_COMPARE
	mtc0	$8, C0_SR
	ehb
	jr	$31
END(mips_start_minimal_counter)

LEAF(_mips_isr_sw0)
	.set push
	.set noreorder
	.set noat
	LA	$k0, _count_wrap
	lw	$k1, 0($k0)
	addiu	$k1, $k1, 1
	sw	$k1, 0($k0)
	mtc0	$0, C0_COMPARE
	eret
	.set pop
END(_mips_isr_sw0)

LEAF(_mips_interrupt)
	.set push
	.set noreorder
	.set noat
	LA	$k0, _count_wrap
	lw	$k1, 0($k0)
	addiu	$k1, $k1, 1
	sw	$k1, 0($k0)
	mtc0	$0, C0_COMPARE
	eret
	.set pop
END(_mips_interrupt)

LEAF(mips_stop_minimal_counter)
	LA	$11, _count_wrap
	mfc0	$9, C0_COUNT
	di	$8
	ehb
	lw	$11, 0($11)
	li	$12, ~SR_HINT5
	and	$8, $8, $12
	mfc0	$10, C0_COUNT
	sltu	$9, $10, $9
	ori	$8, $8, SR_IE
	beqz	$9, 1f
	addiu	$11, $11, 1
1:
	sw	$11, 0($4)
	sw	$10, 0($5)
	mtc0	$8, C0_SR
	jr	$31
END(mips_stop_minimal_counter)
