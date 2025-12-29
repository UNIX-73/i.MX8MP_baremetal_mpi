#pragma once
#include <lib/stdint.h>

typedef struct {
	// 0 free / 1 locked
	volatile uint32 slock;
} spinlock_t;

#define SPINLOCK_INIT {.slock = 0}

extern void _spin_lock(spinlock_t *lock);
#define spin_lock(lock) _spin_lock(lock)

extern void _spin_unlock(spinlock_t *lock);
#define spin_unlock(lock) _spin_unlock(lock)

extern void _spin_lock_irqsave(spinlock_t *lock, uint64 *flags);
#define spin_lock_irqsave(lock, flags) _spin_lock_irqsave(lock, flags)

extern void _spin_unlock_irqrestore(spinlock_t *lock, uint64 flags);
#define spin_unlock_irqrestore(lock, flags) _spin_unlock_irqrestore(lock, flags)
