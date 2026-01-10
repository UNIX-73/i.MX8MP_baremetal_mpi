.section .text

.align 4

.global _secondary_entry
_secondary_entry:
#ifdef TEST
    mrs x0, MPIDR_EL1
    and x0, x0, #0xFFFF
    cmp x0, #0
    b.eq hang
#endif
    msr daifset, #0xf
    mrs x0, MPIDR_EL1
    and x0, x0, #0xFF // core Aff0

    ldr x3, =__NUM_CORES
    cmp x0, x3
    b.hi hang // if (coreid >= __NUM_CORES) hang
    
    ldr x1, =__EL2_STACK_SIZE
    ldr x2, =__stacks_el2_end

    mul x0, x0, x1  // x0 = coreid * stack size
    sub x0, x2, x0  // x0 = stack end - coreid * stack size

    mov sp, x0

    bl _setup_stack_el1
    bl _el2_init_vector
    bl _switch_to_el1

hang:
    wfe
    b hang
