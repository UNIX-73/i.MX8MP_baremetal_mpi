.section .text

.align 4
.global _spin_lock
// x0 = spinlock_t *lock
_spin_lock:
0:
    ldr     w1, [x0]
    cbnz    w1, 0b          // slock != 0 -> spin

    ldaxr   w1, [x0]        // load acquire exclusive
    cbnz    w1, 0b          // slock != 0 -> spin

    mov     w2, #1
    stxr    w3, w2, [x0]    // store exclusive (0 for success 1 for failure in w3)
    cbnz    w3, 0b

    ret


.global _spin_unlock
// x0 = spinlock_t *lock
_spin_unlock:
#ifdef TEST
    ldr     w1, [x0]
    cmp     w1 , #1
    b.ne    0f
#endif
    mov     w1, #0
    stlr    w1, [x0]
    
    ret
#ifdef TEST
0:  wfe
    b       0b
#endif


.global _spin_lock_irqsave
// x0 = spinlock_t *lock
// x1 = uint64 *flags
_spin_lock_irqsave:
    mrs     x2, DAIF
    str     x2, [x1]            // save daif flags into uint64 *flags
    msr     DAIFSET, #0b10    // disable irq
    
    stp     x29, x30, [sp, #-16]!
    bl      _spin_lock
    ldp     x29, x30, [sp], #16

    ret


.global _spin_unlock_irqrestore
// x0 = spinlock_t *lock
// x1 = uint64 flags
_spin_unlock_irqrestore:
    mov     x4, x1
    
    stp     x29, x30, [sp, #-16]!
    bl      _spin_unlock
    ldp     x29, x30, [sp], #16

    msr     DAIF, x4            // restore daif
    ret
#ifdef TEST
0:  wfe
    b       0b
#endif