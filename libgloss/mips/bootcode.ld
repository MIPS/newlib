EXTERN (__reset_vector);
EXTERN (__init_cp0);
EXTERN (__init_l23cache);
EXTERN (__init_icache);
EXTERN (__change_k0_cca);
EXTERN (__init_dcache);
EXTERN (__init_tlb);
EXTERN (__boot_init_hook);
PROVIDE (__boot_init_hook = 0);
