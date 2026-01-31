#pragma once

#include <arm/mmu/mmu.h>
#include <lib/mem.h>


void mm_reloc_kernel(p_uintptr kernel_base, mmu_handle* h);