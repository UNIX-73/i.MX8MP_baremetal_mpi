#pragma once

#include <lib/stdbool.h>
#include <lib/stdint.h>

// TODO: maybe doing a c wrapper makes sense for checking if simd is enabled at
// lower EL levels
#define memcpy(dst, src, size) _memcpy(dst, src, size)

/// Standard memcpy, requieres simd instructions to be enabled
extern void *_memcpy(void *dst, void *src, uint64 size);

/// Panics: if the size is not divisible by 64
void *memcpy64(void *dst, void *src, uint64 size);

/// Panics: if the addreses are not aligned to 16 bytes or the size is not
/// divisible by 64
void *memcpy64_aligned(void *dst, void *src, uint64 size);

#ifdef TEST
void test_memcpy(size_t size_start);
#endif
