/* udis86 - libudis86/extern.h
 *
 * Copyright (c) 2002-2009, 2013 Vivek Thampi
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
#ifndef UD_EXTERN_H
#define UD_EXTERN_H

#ifdef __cplusplus
extern "C" {
#endif

#include "types.h"

/* ============================= PUBLIC API ================================= */

extern void ud_init(struct ud*);

extern void ud_set_mode(struct ud*, uint8_t);

extern void ud_set_pc(struct ud*, uint64_t);

extern void ud_set_input_hook(struct ud*, int (*)(struct ud*));

extern void ud_set_input_buffer(struct ud*, const uint8_t*, size_t);

#ifndef __UD_STANDALONE__
extern void ud_set_input_file(struct ud*, FILE*);
#endif /* __UD_STANDALONE__ */

extern void ud_set_vendor(struct ud*, unsigned);

extern void ud_set_syntax(struct ud*, void (*)(struct ud*));

extern void ud_input_skip(struct ud*, size_t);

extern int ud_input_end(const struct ud*);

extern unsigned int ud_decode(struct ud*);

extern unsigned int ud_disassemble(struct ud*);

#ifndef __INSIDE_CYGWIN__
extern void ud_translate_intel(struct ud*);

extern void ud_translate_att(struct ud*);
#endif /* __INSIDE_CYGWIN__ */

extern const char* ud_insn_asm(const struct ud* u);

extern const uint8_t* ud_insn_ptr(const struct ud* u);

extern uint64_t ud_insn_off(const struct ud*);

extern const char* ud_insn_hex(struct ud*);

extern unsigned int ud_insn_len(const struct ud* u);

extern const struct ud_operand* ud_insn_opr(const struct ud *u, unsigned int n);

extern int ud_opr_is_sreg(const struct ud_operand *opr);

extern int ud_opr_is_gpr(const struct ud_operand *opr);

extern enum ud_mnemonic_code ud_insn_mnemonic(const struct ud *u);

#ifndef __INSIDE_CYGWIN__
extern const char* ud_lookup_mnemonic(enum ud_mnemonic_code c);
#endif /* __INSIDE_CYGWIN__ */

extern void ud_set_user_opaque_data(struct ud*, void*);

extern void* ud_get_user_opaque_data(const struct ud*);

extern uint64_t ud_insn_sext_imm(const struct ud*, const struct ud_operand*);

extern void ud_set_asm_buffer(struct ud *u, char *buf, size_t size);

extern void ud_set_sym_resolver(struct ud *u, 
                                const char* (*resolver)(struct ud*, 
                                                        uint64_t addr,
                                                        int64_t *offset));

/* ========================================================================== */

#ifdef __cplusplus
}
#endif
#endif /* UD_EXTERN_H */
