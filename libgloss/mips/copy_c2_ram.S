/*
 * copy_c2_ram.S
 *
 *  Copy code and data to ram then clear BSS
*/
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

#include <mips/regdef.h>
#include <mips/asm.h>

#define s1_all_ones     s1   /* at Will hold 0xffffffff to simplify bit insertion of 1's. */
#define a0_temp_data    a0   /* a0 data to be moved */
#define a1_temp_addr    a1   /* from address */
#define a2_temp_dest    a2   /* to address */
#define a3_temp_mark    a3   /* ending address */


    .set    noat	# Don't allow the assembler to use r1(at) for synthetic instr.

/**************************************************************************************
**************************************************************************************/
LEAF(copy_c2_ram)

    li      s1_all_ones, 0xffffffff

    # Copy code and read-only/initialized data from FLASH to (uncached) RAM.
    la      a1_temp_addr, _zap1
    ins     a1_temp_addr, s1_all_ones, 29, 1
    la      a2_temp_dest, _ftext_ram
    ins     a2_temp_dest, s1_all_ones, 29, 1
    la      a3_temp_mark, _edata_ram
    ins     a3_temp_mark, s1_all_ones, 29, 1
    beq     a2_temp_dest, a3_temp_mark, $Lcopy_c2_ram_done
$Lnext_ram_word:
    lw      a0_temp_data, 0(a1_temp_addr)
    sw      a0_temp_data, 0(a2_temp_dest)
    addiu   a2_temp_dest, 4
    addiu   a1_temp_addr, 4
    bne     a3_temp_mark, a2_temp_dest, $Lnext_ram_word

$Lcopy_c2_ram_done:
    jr	  ra

END(copy_c2_ram)

