/* udis86 - libudis86/decode.h
 *
 * Copyright (c) 2002-2009 Vivek Thampi
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, 
 * are permitted provided that the following conditions are met:
 * 
 *     * Redistributions of source code must retain the above copyright notice, 
 *       this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright notice, 
 *       this list of conditions and the following disclaimer in the documentation 
 *       and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR 
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES 
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON 
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
#ifndef UD_DECODE_H
#define UD_DECODE_H

#include "types.h"
#include "itab.h"

#define MAX_INSN_LENGTH 15

/* itab prefix bits */
#define P_none          ( 0 )
#define P_cast          ( 1 << 0 )
#define P_CAST(n)       ( ( n >> 0 ) & 1 )
#define P_rexb          ( 1 << 1 )
#define P_REXB(n)       ( ( n >> 1 ) & 1 )
#define P_inv64         ( 1 << 4 )
#define P_INV64(n)      ( ( n >> 4 ) & 1 )
#define P_rexw          ( 1 << 5 )
#define P_REXW(n)       ( ( n >> 5 ) & 1 )
#define P_def64         ( 1 << 7 )
#define P_DEF64(n)      ( ( n >> 7 ) & 1 )
#define P_rexr          ( 1 << 8 )
#define P_REXR(n)       ( ( n >> 8 ) & 1 )
#define P_oso           ( 1 << 9 )
#define P_OSO(n)        ( ( n >> 9 ) & 1 )
#define P_aso           ( 1 << 10 )
#define P_ASO(n)        ( ( n >> 10 ) & 1 )
#define P_rexx          ( 1 << 11 )
#define P_REXX(n)       ( ( n >> 11 ) & 1 )
#define P_ImpAddr       ( 1 << 12 )
#define P_IMPADDR(n)    ( ( n >> 12 ) & 1 )
#define P_seg           ( 1 << 13 )
#define P_SEG(n)        ( ( n >> 13 ) & 1 )
#define P_str           ( 1 << 14 )
#define P_STR(n)        ( ( n >> 14 ) & 1 )
#define P_strz          ( 1 << 15 )
#define P_STR_ZF(n)     ( ( n >> 15 ) & 1 )

/* operand type constants -- order is important! */

enum ud_operand_code {
    OP_NONE,

    OP_A,      OP_E,      OP_M,       OP_G,       
    OP_I,      OP_F,

    OP_R0,     OP_R1,     OP_R2,      OP_R3,
    OP_R4,     OP_R5,     OP_R6,      OP_R7,

    OP_AL,     OP_CL,     OP_DL,
    OP_AX,     OP_CX,     OP_DX,
    OP_eAX,    OP_eCX,    OP_eDX,
    OP_rAX,    OP_rCX,    OP_rDX,

    OP_ES,     OP_CS,     OP_SS,      OP_DS,  
    OP_FS,     OP_GS,

    OP_ST0,    OP_ST1,    OP_ST2,     OP_ST3,
    OP_ST4,    OP_ST5,    OP_ST6,     OP_ST7,

    OP_J,      OP_S,      OP_O,          
    OP_I1,     OP_I3,     OP_sI,

    OP_V,      OP_W,      OP_Q,       OP_P, 
    OP_U,      OP_N,      OP_MU,

    OP_R,      OP_C,      OP_D,       

    OP_MR
} UD_ATTR_PACKED;


/* operand size constants */

enum ud_operand_size {
    SZ_NA  = 0,
    SZ_Z   = 1,
    SZ_V   = 2,
    SZ_RDQ = 7,

    /* the following values are used as is,
     * and thus hard-coded. changing them 
     * will break internals 
     */
    SZ_B   = 8,
    SZ_W   = 16,
    SZ_D   = 32,
    SZ_Q   = 64,
    SZ_T   = 80,
    SZ_O   = 128,

    SZ_Y   = 17,

    /*
     * complex size types, that encode sizes for operands
     * of type MR (memory or register), for internal use
     * only. Id space 256 and above.
     */
    SZ_BD  = (SZ_B << 8) | SZ_D,
    SZ_BV  = (SZ_B << 8) | SZ_V,
    SZ_WD  = (SZ_W << 8) | SZ_D,
    SZ_WV  = (SZ_W << 8) | SZ_V,
    SZ_WY  = (SZ_W << 8) | SZ_Y,
    SZ_DY  = (SZ_D << 8) | SZ_Y,
    SZ_WO  = (SZ_W << 8) | SZ_O,
    SZ_DO  = (SZ_D << 8) | SZ_O,
    SZ_QO  = (SZ_Q << 8) | SZ_O,

} UD_ATTR_PACKED;


/* resolve complex size type.
 */
static inline enum ud_operand_size
Mx_mem_size(enum ud_operand_size size)
{
    return (size >> 8) & 0xff;
}

static inline enum ud_operand_size
Mx_reg_size(enum ud_operand_size size)
{
    return size & 0xff;
}

/* A single operand of an entry in the instruction table. 
 * (internal use only)
 */
struct ud_itab_entry_operand 
{
  enum ud_operand_code type;
  enum ud_operand_size size;
};


/* A single entry in an instruction table. 
 *(internal use only)
 */
struct ud_itab_entry 
{
  enum ud_mnemonic_code         mnemonic;
  struct ud_itab_entry_operand  operand1;
  struct ud_itab_entry_operand  operand2;
  struct ud_itab_entry_operand  operand3;
  uint32_t                      prefix;
};

struct ud_lookup_table_list_entry {
    const uint16_t *table;
    enum ud_table_type type;
    const char *meta;
};
     


static inline int
ud_opcode_field_sext(uint8_t primary_opcode)
{
  return (primary_opcode & 0x02) != 0;
}

extern const struct ud_itab_entry ud_itab[];
extern const struct ud_lookup_table_list_entry ud_lookup_table_list[];

#endif /* UD_DECODE_H */

/* vim:cindent
 * vim:expandtab
 * vim:ts=4
 * vim:sw=4
 */
