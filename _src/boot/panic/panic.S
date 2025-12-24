.section .text


// FIXME: Implement it inside the exception vectors

.align 4
.global _panic_exception_save_gpr
_panic_exception_save_gpr:
    sub sp, sp, #16
    stp x0, x1, [sp]
    
    ldr x0, =PANIC_REGISTERS

    stp x2, x3, [x0, #(1 * 16)]
    stp x4, x5, [x0, #(2 * 16)]
    stp x6, x7, [x0, #(3 * 16)]
    stp x8, x9, [x0, #(4 * 16)]
    stp x10, x11, [x0, #(5 * 16)]
    stp x12, x13, [x0, #(6 * 16)]
    stp x14, x15, [x0, #(7 * 16)]
    stp x16, x17, [x0, #(8 * 16)]
    stp x18, x19, [x0, #(9 * 16)]
    stp x20, x21, [x0, #(10 * 16)]
    stp x22, x23, [x0, #(11 * 16)]
    stp x24, x25, [x0, #(12 * 16)]
    stp x26, x27, [x0, #(13 * 16)]
    stp x28, x29, [x0, #(14 * 16)]
    
    ldp x2, x3, [sp]
    stp x2, x3, [x0]

    add sp, sp, #16

    mov x1, sp

    stp x30, x1, [x0, #(15 * 16)]

    ret

