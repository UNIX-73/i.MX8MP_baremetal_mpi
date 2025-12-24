.section .text.boot
.global _start

_start:
    nop
    //  disable DAIF exceptions
    msr daifset, #0xf

#ifdef TEST
    mrs x0, CurrentEL
    lsr x0, x0, #2 // x0 = x0 >> 2
    cmp x0, #2
    b.ne hang
#endif

    //  Init EL2 stack
    ldr x0, =__stack_el2_top
    mov sp, x0

    //  Set EL2 vector table
    bl _el2_init_vector
    bl _clean_bss
    bl init_panic
    
    bl _switch_to_el1

hang:
    wfe
    b hang
