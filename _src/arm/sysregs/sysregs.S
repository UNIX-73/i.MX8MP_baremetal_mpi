.section .text
.align 2

.global _ARM_currentEL
_ARM_currentEL:
    mrs x0, CurrentEL
    lsr x0, x0, #2
    ret

.global _ARM_MPIDR_EL1
_ARM_MPIDR_EL1:
    mrs x0, MPIDR_EL1
    ret

.global _ARM_ICC_SRE_EL2
_ARM_ICC_SRE_EL2:
    mrs x0, ICC_SRE_EL2
    ret

.global _ARM_HCR_EL2
_ARM_HCR_EL2:
    mrs x0, HCR_EL2
    ret

.global _ARM_ESR_EL2
_ARM_ESR_EL2:
    mrs x0, ESR_EL2
    ret

.global _ARM_ELR_EL2
_ARM_ELR_EL2:
    mrs x0, ELR_EL2
    ret

.global _ARM_FAR_EL2
_ARM_FAR_EL2:
    mrs x0, FAR_EL2
    ret

.global _ARM_SPSR_EL2
_ARM_SPSR_EL2:
    mrs x0, SPSR_EL2
    ret

.global _ARM_ESR_EL1
_ARM_ESR_EL1:
    mrs x0, ESR_EL1
    ret

.global _ARM_ELR_EL1
_ARM_ELR_EL1:
    mrs x0, ELR_EL1
    ret

.global _ARM_FAR_EL1
_ARM_FAR_EL1:
    mrs x0, FAR_EL1
    ret

.global _ARM_SPSR_EL1
_ARM_SPSR_EL1:
    mrs x0, SPSR_EL1
    ret

.global _ARM_SCTLR_EL1
_ARM_SCTLR_EL1:
    mrs x0, SCTLR_EL1
    ret

.global _ARM_SCTLR_EL2
_ARM_SCTLR_EL2:
    mrs x0, SCTLR_EL2
    ret


