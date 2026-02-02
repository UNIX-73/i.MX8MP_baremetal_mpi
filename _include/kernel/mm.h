#pragma once

#include <arm/mmu/mmu.h>
#include <lib/mem.h>
#include <lib/stdbool.h>
#include <lib/stdint.h>
#include <lib/unit/mem.h>

#define KERNEL_BASE 0xFFFF'8000'0000'0000ULL

void mm_early_init();

/// it expects to be provided the identity mapping handle. It will free it, and replace it by the
/// kernel mmu handle after relocation
void mm_init();


bool mm_kernel_is_relocated();


v_uintptr mm_remap(p_uintptr pa);