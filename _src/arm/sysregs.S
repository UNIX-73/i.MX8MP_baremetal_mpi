.section .text
.align 2

.global _currentEL
_currentEL:
    mrs x0, CurrentEL
    lsr x0, x0, #2
    ret
