.section .text

.align 4

.global GICV3_ARM_ICC_SRE_EL1_write
GICV3_ARM_ICC_SRE_EL1_write:
    msr ICC_SRE_EL1, x0
    isb
    ret

.global GICV3_ARM_ICC_PMR_EL1_write
GICV3_ARM_ICC_PMR_EL1_write:
    msr ICC_PMR_EL1, x0
    isb
    ret

.global GICV3_ICC_IGRPEN1_EL1_EL1_write
GICV3_ICC_IGRPEN1_EL1_EL1_write:
    msr ICC_IGRPEN1_EL1, x0
    isb
    ret