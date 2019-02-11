/*
 * Copyright (C) 2018 MIPS Tech, LLC
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of its
 * contributors may be used to endorse or promote products derived from this
 * software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
*/

#ifndef _I7200_H_
#define _I7200_H_

#include <mips/m32c0.h>

/*
 * MIPS32 Burst COP Control register (CP0 Register 22, select 0)
 */
#define BCOPCONTROL_PSA_MASK		0xffffff00
#define  BCOPCONTROL_PSA_SHIFT			 8
#define  BCOPCONTROL_PSA_BITS			24
#define BCOPCONTROL_NB_MASK		0x000000f0
#define  BCOPCONTROL_NB_SHIFT			 4
#define  BCOPCONTROL_NB_BITS			 4
#define BCOPCONTROL_TYPE_MASK		0x0000000e
#define  BCOPCONTROL_TYPE_SHIFT			 1
#define  BCOPCONTROL_TYPE_BITS			 3
#define BCOPCONTROL_MODE_MASK		0x00000001
#define  BCOPCONTROL_MODE_SHIFT			 0
#define  BCOPCONTROL_MODE_BITS			 1

/*
 * MIPS32 Burst COP Status register (CP0 Register 22, select 1)
 */
#define BCOPSTATUS_PROGRESS_MASK	0x000000f0
#define  BCOPSTATUS_PROGRESS_SHIFT		 4
#define  BCOPSTATUS_PROGRESS_BITS		 4
#define BCOPSTATUS_RESULT_MASK		0x0000000e
#define  BCOPSTATUS_RESULT_SHIFT		 1
#define  BCOPSTATUS_RESULT_BITS			 4
#define BCOPSTATUS_STATUS_MASK		0x00000001
#define  BCOPSTATUS_STATUS_SHIFT		 0
#define  BCOPSTATUS_STATUS_BITS			 1

/*
 * MIPS32 Core Control register (CP0 Register 22, select 3)
 */
#define CORECONTROL_ISPPRED_DIS_EN	0x00000080
#define  CORECONTROL_ISPPRED_DIS_SHIFT		11
#define CORECONTROL_USPIPRED_DIS_EN	0x00000040
#define  CORECONTROL_USPIPRED_DIS_SHIFT 	10
#define CORECONTROL_USPDBP_DIS_EN	0x00000020
#define  CORECONTROL_USPDBP_DIS_SHIFT		 9
#define CORECONTROL_DSPPB_EN		0x00000010
#define  CORECONTROL_DSPPB_SHIFT		 8
#define CORECONTROL_USP_EN		0x00000004
#define  CORECONTROL_USP_EN_SHIFT		 2
#define CORECONTROL_ISP_EN		0x00000002
#define  CORECONTROL_ISP_EN_SHIFT		 1
#define CORECONTROL_DSP_EN		0x00000001
#define  CORECONTROL_DSP_EN_SHIFT		 0

/*
 * The Core Control register was previously named as
 * the SRAM Control register (Shaolin RC 1.0). Macros
 * corresponding to the out-dated register name are
 *  provided here continuity and documentation.
 */
#define SRAMCONTROL_DSPPB_EN		0x00000010
#define  SRAMCONTROL_DSPPB_SHIFT		 8
#define SRAMCONTROL_USP_EN		0x00000004
#define  SRAMCONTROL_USP_EN_SHIFT		 2
#define SRAMCONTROL_ISP_EN		0x00000002
#define  SRAMCONTROL_ISP_EN_SHIFT		 1
#define SRAMCONTROL_DSP_EN		0x00000001
#define  SRAMCONTROL_DSP_EN_SHIFT		 0

#ifdef __ASSEMBLER__

#define C0_BCOPCONTROL	$22,0
#define C0_BCOPSTATUS	$22,1
#define C0_CORECONTROL	$22,3
#define C0_SRAMCONTROL	C0_CORECONTROL

$bcop		=	$22

#else /* !__ASSEMBLER__ */

#define C0_BCOPCONTROL	22
#define C0_BCOPSTATUS	0x116
#define C0_CORECONTROL	0x316
#define C0_SRAMCONTROL	C0_CORECONTROL

/* CP0 BCOP Control register */
#define mips32_getbcopcontrol()  mips32_get_c0(C0_BCOPCONTROL)
#define mips32_setbcopcontrol(x) mips32_set_c0(C0_BCOPCONTROL, x)
#define mips32_xchbcopcontrol(x) mips32_xch_c0(C0_BCOPCONTROL, x)

/* CP0 BCOP Status register */
#define mips32_getbcopstatus()  mips32_get_c0(C0_BCOPSTATUS)
#define mips32_setbcopstatus(x) mips32_set_c0(C0_BCOPSTATUS, x)
#define mips32_xchbcopstatus(x) mips32_xch_c0(C0_BCOPSTATUS, x)

/* CP0 Core Control register */
#define mips32_getcorecontrol()  mips32_get_c0(C0_CORECONTROL)
#define mips32_setcorecontrol(x) mips32_set_c0(C0_CORECONTROL, x)
#define mips32_xchcorecontrol(x) mips32_xch_c0(C0_CORECONTROL, x)

/* CP0 SRAM Control register, obsolete interface */
#define mips32_getsramcontrol()  mips32_getcorecontrol()
#define mips32_setsramcontrol(x) mips32_setcorecontrol(x)
#define mips32_xchsramcontrol(x) mips32_xchcorecontrol(x)

#endif /* __ASSEMBLER__ */

#endif /* _I7200_H_ */
