/*
Copyright (c) 2015, Imagination Technologies Limited and/or its affiliated group companies

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are
permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of
conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list
of conditions and the following disclaimer in the documentation and/or other materials
provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be
used to endorse or promote products derived from this software without specific prior
written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#ifndef C0_CONFIG1_VALUE
#error "Static cache initialisation decisions require C0_CONFIG1_VALUE"
#endif

#define ILINE_ENC     ((C0_CONFIG1_VALUE & CFG1_IL_MASK) >> CFG1_IL_SHIFT)
#define ILINE_SIZE    (2 << ILINE_ENC)
#define ISET_ENC      ((C0_CONFIG1_VALUE & CFG1_IS_MASK) >> CFG1_IS_SHIFT)
#define ISET_SIZE     (32 << ((ISET_ENC + 1) & 0x7))
#define IASSOC_ENC    ((C0_CONFIG1_VALUE & CFG1_IA_MASK) >> CFG1_IA_SHIFT)
#define IASSOC	      (IASSOC_ENC + 1)
#define ITOTAL_BYTES  (ILINE_SIZE * ISET_SIZE * IASSOC)
#define DLINE_ENC     ((C0_CONFIG1_VALUE & CFG1_DL_MASK) >> CFG1_DL_SHIFT)
#define DLINE_SIZE    (2 << DLINE_ENC)
#define DSET_ENC      ((C0_CONFIG1_VALUE & CFG1_DS_MASK) >> CFG1_DS_SHIFT)
#define DSET_SIZE     (32 << ((DSET_ENC + 1) & 0x7))
#define DASSOC_ENC    ((C0_CONFIG1_VALUE & CFG1_DA_MASK) >> CFG1_DA_SHIFT)
#define DASSOC	      (DASSOC_ENC + 1)
#define DTOTAL_BYTES  (DLINE_SIZE * DSET_SIZE * DASSOC)

#ifndef C0_CONFIG2_VALUE
# error "Static cache initialisation decisions require C0_CONFIG2_VALUE"
#endif

#ifndef C0_CONFIG4_VALUE
# error "Static cache initialisation decisions require C0_CONFIG4_VALUE"
#endif

#if (C0_CONFIG4_VALUE & CFG4_M) != 0
# ifndef C0_CONFIG5_VALUE
#  error "Static cache initialisation decisions require C0_CONFIG5_VALUE"
# endif
# if C0_CONFIG5_VALUE & CFG5_L2C != 0
#  define MEM_MAPPED_L2C 1
# endif
#endif

#define SLINE_ENC    ((C0_CONFIG2_VALUE & CFG2_SL_MASK) >> CFG2_SL_SHIFT)
#define SLINE_SIZE   (2 << SLINE_ENC)
#define SSET_ENC     ((C0_CONFIG2_VALUE & CFG2_SS_MASK) >> CFG2_SS_SHIFT)
#define SSET_SIZE    (64 << SSET_ENC)
#define SASSOC_ENC   ((C0_CONFIG2_VALUE & CFG2_SA_MASK) >> CFG2_SA_SHIFT)
#define SASSOC	      (SASSOC_ENC + 1)
#define STOTAL_BYTES (SLINE_SIZE * SSET_SIZE * SASSOC)

#define TLINE_ENC    ((C0_CONFIG2_VALUE & CFG2_TL_MASK) >> CFG2_TL_SHIFT)
#define TLINE_SIZE   (2 << TLINE_ENC)
#define TSET_ENC     ((C0_CONFIG2_VALUE & CFG2_TS_MASK) >> CFG2_TS_SHIFT)
#define TSET_SIZE    (64 << TSET_ENC)
#define TASSOC_ENC   ((C0_CONFIG2_VALUE & CFG2_TA_MASK) >> CFG2_TA_SHIFT)
#define TASSOC	      (TASSOC_ENC + 1)
#define TTOTAL_BYTES (TLINE_SIZE * TSET_SIZE * TASSOC)
