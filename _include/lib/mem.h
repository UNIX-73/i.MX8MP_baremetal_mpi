#pragma once

#include <lib/stdbool.h>
#include <lib/stdint.h>

// phys address uintptr
typedef uintptr p_uintptr;

// virt address uintptr
typedef uintptr v_uintptr;


typedef struct {
    p_uintptr pa;
    v_uintptr va;
} pv_ptr;

static inline pv_ptr pv_ptr_new(p_uintptr pa, v_uintptr va)
{
    return (pv_ptr) {pa, va};
}

#define uintptr_p_to_ptr(type, uintptr_phys) ((type*)(uintptr_phys))
#define PTR_TO_UINTPTR_P(ptr) ((p_uintptr)(ptr))

#define UINTPTR_V_TO_PTR(type, uintptr_virt) ((type*)(uintptr_virt))
#define PTR_TO_UINTPTR_V(ptr) ((v_uintptr)(ptr))


/*
    Mem ctrl fns
*/

// TODO: maybe doing a c wrapper makes sense for checking if simd is enabled at
// lower EL levels
#define memcpy(dst, src, size) _memcpy(dst, src, size)

/// Standard memcpy, requieres simd instructions to be enabled
extern void* _memcpy(void* dst, void* src, uint64 size);

/// Panics: if the size is not divisible by 64
void* memcpy64(void* dst, void* src, uint64 size);

/// Panics: if the addreses are not aligned to 16 bytes or the size is not
/// divisible by 64
void* memcpy64_aligned(void* dst, void* src, uint64 size);

#ifdef TEST
void test_memcpy(size_t size_start);
#endif
