.section .text.boot
.global _start

_start:
    nop
    //  disable DAIF exceptions
   // msr daifset, #0xf

#ifdef TEST
    mrs x0, CurrentEL
    lsr x0, x0, #2 // x0 = x0 >> 2
    cmp x0, #2
    b.ne hang
#endif

    //  Init EL2 stack
    ldr x0, =__stack_el2_top
    mov sp, x0
    
    //  Init El1 stack
    ldr x0, =__stack_el1_top
    msr SP_EL1, x0

    //  Set EL2 vector table
    bl  _el2_init_vector

    bl _clean_bss

    bl kernel_entry

hang:
    wfe
    b hang