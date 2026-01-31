#pragma once

#include <arm/mmu/mmu.h>
#include <lib/stdint.h>
#include <lib/unit/mem.h>


void mm_early_init(mmu_handle* mmu_identity_mapping);

/// it expects to be provided the identity mapping handle. It will free it, and replace it by the
/// kernel mmu handle after relocation
void mm_init(mmu_handle* mmu_h);
