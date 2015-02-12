# Copyright 2015, Imagination Technologies Limited and/or its
#                 affiliated group companies.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted under the terms of the MIPS Free To Use 1.0
# license that you will have received with this package. If you haven't
# received this file, please contact Imagination Technologies or see the
# following URL for details.
# http://codescape-mips-sdk.imgtec.com/license/IMG-free-to-use-on-MIPS-license

#
# Keep each function in a separate named section
#define _FUNCTION_SECTIONS_

#include <mips/regdef.h>
#include <mips/asm.h>
#include <mips/cpu.h>

#define VEC_SPACE (SZPTR * 8)

LEAF(__isr_vec)
	.set	push
	.set	noat
AENT(__isr_vec_sw0)
.weak   _mips_isr_sw0
	LA	k1, _mips_isr_sw0
	beqz	k1, 1f
	jr	k1
.org	VEC_SPACE
AENT(__isr_vec_sw1)
.weak   _mips_isr_sw1
	LA	k1, _mips_isr_sw1
	beqz	k1, 1f
	jr	k1
.org	2 * VEC_SPACE
AENT(__isr_vec_hw0)
.weak   _mips_isr_hw0
	LA	k1, _mips_isr_hw0
	beqz	k1, 1f
	jr	k1
.org	3 * VEC_SPACE
AENT(__isr_vec_hw1)
.weak   _mips_isr_hw1
	LA	k1, _mips_isr_hw1
	beqz	k1, 1f
	jr	k1
.org	4 * VEC_SPACE
AENT(__isr_vec_hw2)
.weak   _mips_isr_hw2
	LA	k1, _mips_isr_hw2
	beqz	k1, 1f
	jr	k1
.org	5 * VEC_SPACE
AENT(__isr_vec_hw3)
.weak   _mips_isr_hw3
	LA	k1, _mips_isr_hw3
	beqz	k1, 1f
	jr	k1
.org	6 * VEC_SPACE
AENT(__isr_vec_hw4)
.weak   _mips_isr_hw4
	LA	k1, _mips_isr_hw4
	beqz	k1, 1f
	jr	k1
.org	7 * VEC_SPACE
AENT(__isr_vec_hw5)
.weak   _mips_isr_hw5
	LA	k1, _mips_isr_hw5
	beqz	k1, 1f
	jr	k1
.org	8 * VEC_SPACE
AENT(__isr_vec_fallback)
.weak   _mips_interrupt
1:
	LA      k1, _mips_interrupt
	beqz    k1, 1b
	jr      k1
	.set    pop
END(__isr_vec)
