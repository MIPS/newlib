# 1 "/althome/mips/v6/install-mips-img-elf//share/mips/boot/reset_predef.S"
# 1 "/althome/mips/v6/uhi_test/examples/predefex//"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/althome/mips/v6/install-mips-img-elf//share/mips/boot/reset_predef.S"
# 34 "/althome/mips/v6/install-mips-img-elf//share/mips/boot/reset_predef.S"
# 1 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/regdef.h" 1 3
# 35 "/althome/mips/v6/install-mips-img-elf//share/mips/boot/reset_predef.S" 2
# 1 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/cpu.h" 1 3
# 32 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/cpu.h" 3
# 1 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/m64c0.h" 1 3
# 23 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/m64c0.h" 3
# 1 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/m32c0.h" 1 3
# 28 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/m32c0.h" 3
# 1 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/m32tlb.h" 1 3
# 22 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/m32tlb.h" 3
# 1 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/asm.h" 1 3
# 169 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/asm.h" 3
 .section .reset, "ax", @progbits
# 23 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/m32tlb.h" 2 3

# 1 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/m32c0.h" 1 3
# 25 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/m32tlb.h" 2 3
# 1 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/notlb.h" 1 3
# 26 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/m32tlb.h" 2 3
# 29 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/m32c0.h" 2 3
# 705 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/m32c0.h" 3
$index = $0
$random = $1
$entrylo0 = $2
$entrylo1 = $3
$context = $4
$pagemask = $5
$wired = $6
$hwrena = $7
$vaddr = $8
$badvaddr = $8
$count = $9
$entryhi = $10
$compare = $11
$sd = $12
$cr = $13
$epc = $14
$prid = $15
$config = $16
$lladdr = $17
$watchlo = $18
$watchhi = $19
$debug = $23
$depc = $24
$perfcnt = $25
$errctl = $26
$cacheerr = $27
$taglo = $28
$taghi = $29
$errpc = $30
$desave = $31
# 24 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/m64c0.h" 2 3


# 1 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/mips64.h" 1 3
# 22 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/mips64.h" 3
# 1 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/mips32.h" 1 3
# 23 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/mips64.h" 2 3


# 1 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/m64r6cm3.h" 1 3
# 26 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/mips64.h" 2 3
# 27 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/m64c0.h" 2 3
# 33 "/althome/mips/v6/install-mips-img-elf/mips-img-elf/include/mips/cpu.h" 2 3
# 36 "/althome/mips/v6/install-mips-img-elf//share/mips/boot/reset_predef.S" 2

# 1 "/althome/mips/v6/install-mips-img-elf//share/mips/boot/predef.h" 1
# 36 "/althome/mips/v6/install-mips-img-elf//share/mips/boot/predef.h"
((0x9EAB559B >> 19) & 3)


(2 << ((0x9EAB559B >> 19) & 3))
# 38 "/althome/mips/v6/install-mips-img-elf//share/mips/boot/reset_predef.S" 2

    .set nomips16
    .set push
    .set nomicromips
.pushsection .reset, "ax", @progbits; .balign 4; .globl __reset_vector; .ent __reset_vector; __reset_vector:
    lui $27, %hi(__cpu_init)
    addiu $27, %lo(__cpu_init)
    mtc0 $0, $9 # Clear cp0 Count (Used to measure boot time.)
    jr $27
    .space 32 # Just to cope with a quirk of MIPS malta boards
      # this can be deleted for anything else.
.size __reset_vector,.-__reset_vector; .end __reset_vector; .popsection
    .set pop

.pushsection .reset, "ax", @progbits; .balign 4; .globl __cpu_init; .ent __cpu_init; __cpu_init:

    # Verify the code is here due to a reset and not NMI. If this is an NMI then trigger
    # a debugger breakpoint using a sdbp instruction.

    mfc0 $27, $12 # Read CP0 Status
    ext $27, $27, 19, 1 # extract NMI
    beqz $27, $Lnot_nmi # Branch if this is NOT an NMI exception.
    move $26, $25 # Preserve $25
    move $27, $4 # Preserve $4
    li $25, 15 # UHI exception operation
    li $4, 0 # Use hard register context
    sdbbp 1 # Invoke UHI operation

$Lnot_nmi:
    # Init CP0 Status, Count, Compare, Watch*, and Cause.
    jal __init_cp0
# 77 "/althome/mips/v6/install-mips-img-elf//share/mips/boot/reset_predef.S"
    # Initialize the L1 instruction cache.
    jal __init_icache

    # The changing of Kernel mode cacheability must be done from KSEG1
    # Since the code is executing from KSEG0 It needs to do a jump to KSEG1 change K0
    # and jump back to KSEG0

    lui $6, %hi(__change_k0_cca)
    addiu $6, $6, %lo(__change_k0_cca)
    li $5, 0xf
    ins $6, $5, 29, 1 # changed to KSEG1 address by setting bit 29
    jalr $6



    # Initialize the L1 data cache
    jal __init_dcache


    # Allow everything else to be initialized via a hook.
    .weak __boot_init_hook
    lui $6, %hi(__boot_init_hook)
    addiu $6, $6, %lo(__boot_init_hook)
    beqz $6, 1f
    jalr $6
1:
    # Copy code and data to RAM
    li $17, 0xffffffff

    # Copy code and read-only/initialized data from FLASH to (uncached) RAM.
    lui $5, %hi(__flash_app_start)
    addiu $5, $5, %lo(__flash_app_start)
    ins $5, $17, 29, 1 # Make it uncached (kseg1)
    lui $6, %hi(__app_start)
    addiu $6, $6, %lo(__app_start)
    ins $6, $17, 29, 1 # Make it uncached (kseg1)
    lui $7, %hi(_edata)
    addiu $7, $7, %lo(_edata)
    ins $7, $17, 29, 1 # Make it uncached (kseg1)
    beq $6, $7, $Lcopy_to_ram_done
$Lnext_ram_word:
    lw $4, 0($5)
    sw $4, 0($6)
    addiu $6, 4
    addiu $5, 4
    bne $7, $6, $Lnext_ram_word
$Lcopy_to_ram_done:

    # Prepare for eret to _start
    lui $31, %hi($Lall_done) # If main returns then go to all_done:.
    addiu $31, $31, %lo($Lall_done)
    lui $2, %hi(_start) # Load the address of the _start entry piint
    addiu $2, $2, %lo(_start)
    mtc0 $2, $30 # Write ErrorEPC with the address of _start
    ehb # Clear hazards (makes sure write to ErrorPC has completed)
    li $4, 0 # UHI compliant null argument setup

    # Return from exception will now execute the application startup code
    eret

$Lall_done:
    # If _start returns it will return to this point.
    # Just spin here reporting the exit.
    li $25, 1 # UHI exit operation
    move $4, $2 # Collect exit code for UHI exit
    sdbbp 1 # Invoke UHI operation
    b $Lall_done

.size __cpu_init,.-__cpu_init; .end __cpu_init; .popsection







.pushsection .reset, "ax", @progbits; .balign 4; .globl __boot_tlb_refill; .ent __boot_tlb_refill; __boot_tlb_refill:
.org 0x200 # TLB refill, 32 bit task.
    move $26, $25 # Preserve $25
    move $27, $4 # Preserve $4
    li $25, 15 # UHI exception operation
    li $4, 0 # Use hard register context
    sdbbp 1 # Invoke UHI operation
.size __boot_tlb_refill,.-__boot_tlb_refill; .end __boot_tlb_refill; .popsection

.pushsection .reset, "ax", @progbits; .balign 4; .globl __boot_xtlb_refill; .ent __boot_xtlb_refill; __boot_xtlb_refill:
.org 0x280 # XTLB refill, 64 bit task. BEV + 0x280
    move $26, $25 # Preserve $25
    move $27, $4 # Preserve $4
    li $25, 15 # UHI exception operation
    li $4, 0 # Use hard register context
    sdbbp 1 # Invoke UHI operation
.size __boot_xtlb_refill,.-__boot_xtlb_refill; .end __boot_xtlb_refill; .popsection

.pushsection .reset, "ax", @progbits; .balign 4; .globl __boot_cache_error; .ent __boot_cache_error; __boot_cache_error:
.org 0x300 # Cache error exception. BEV + 0x300
    move $26, $25 # Preserve $25
    move $27, $4 # Preserve $4
    li $25, 15 # UHI exception operation
    li $4, 0 # Use hard register context
    sdbbp 1 # Invoke UHI operation
.size __boot_cache_error,.-__boot_cache_error; .end __boot_cache_error; .popsection

.pushsection .reset, "ax", @progbits; .balign 4; .globl __boot_general_exception; .ent __boot_general_exception; __boot_general_exception:
.org 0x380 # General exception. BEV + 0x380
    move $26, $25 # Preserve $25
    move $27, $4 # Preserve $4
    li $25, 15 # UHI exception operation
    li $4, 0 # Use hard register context
    sdbbp 1 # Invoke UHI operation
.size __boot_general_exception,.-__boot_general_exception; .end __boot_general_exception; .popsection

 # If you want the above code to fit into 1k flash you will need to leave out the
# code below. This is the code that covers the debug exception which you normally will not get.

.pushsection .reset, "ax", @progbits; .balign 4; .globl __boot_debug_exception; .ent __boot_debug_exception; __boot_debug_exception:
.org 0x480 # EJTAG Debug (with ProbEn = 0 in the EJTAG Control Register)
1: b 1b
.size __boot_debug_exception,.-__boot_debug_exception; .end __boot_debug_exception; .popsection
