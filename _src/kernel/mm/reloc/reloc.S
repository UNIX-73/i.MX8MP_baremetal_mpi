#define KERNEL_BASE 0xFFFF800000000000

.section .text
.align 4

.global _jmp_to_with_offset
// _Noreturn void _jmp_to_with_offset(void* to, size_t offset);
_jmp_to_with_offset:

    mov x10, x30
    bl _reset_stack_el1
    mov x30, x10

    add x0, x0, x1 // to += offset
    add sp, sp, x1 // sp += offset
    add x30, x30, x1
    br  x0

