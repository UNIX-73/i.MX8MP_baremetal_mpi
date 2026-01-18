/*
    Generated with an llm based on the imx8mp trm
*/

MEMORY
{
    /* ========================= */
    /* DDR                        */
    /* ========================= */

    /* DDR (All modules except M7) */
    DDR_HI (rwx) :
        ORIGIN = 0x100000000,
        LENGTH = 5120M

    /* DDR (All modules) */
    DDR_LO (rwx) :
        ORIGIN = 0x40000000,
        LENGTH = 3072M

    DDR (rwx) :
        ORIGIN = 0x40000000,
        LENGTH = 5120M + 3072M


    /* ========================= */
    /* Reserved / DDRC           */
    /* ========================= */

    RESERVED_3F (rw) :
        ORIGIN = 0x3F000000,
        LENGTH = 16M

    RESERVED_3E (rw) :
        ORIGIN = 0x3E000000,
        LENGTH = 16M

    DDRC_PHY_BCAST (rw) :
        ORIGIN = 0x3DC00000,
        LENGTH = 4M

    DDRC_PERF_MON (rw) :
        ORIGIN = 0x3D800000,
        LENGTH = 4M

    DDRC_CTL (rw) :
        ORIGIN = 0x3D400000,
        LENGTH = 4M

    RESERVED_3D10 (rw) :
        ORIGIN = 0x3D100000,
        LENGTH = 3M

    DDRC_BLK_CTRL (rw) :
        ORIGIN = 0x3D000000,
        LENGTH = 1M

    DDRC_PHY (rw) :
        ORIGIN = 0x3C000000,
        LENGTH = 16M


    /* ========================= */
    /* Multimedia / accelerators */
    /* ========================= */

    AUDIO_DSP (rw) :
        ORIGIN = 0x3B000000,
        LENGTH = 16M

    GIC (rw) :
        ORIGIN = 0x38800000,
        LENGTH = 1M

    NPU (rw) :
        ORIGIN = 0x38500000,
        LENGTH = 2M

    VPU (rw) :
        ORIGIN = 0x38340000,
        LENGTH = 2M

    VPU_BLK_CTRL (rw) :
        ORIGIN = 0x38330000,
        LENGTH = 2M

    VPU_VC8000E (rw) :
        ORIGIN = 0x38320000,
        LENGTH = 2M

    VPU_G2 (rw) :
        ORIGIN = 0x38310000,
        LENGTH = 2M

    VPU_G1 (rw) :
        ORIGIN = 0x38300000,
        LENGTH = 2M


    /* ========================= */
    /* USB / GPU / QSPI / DMA    */
    /* ========================= */

    USB2 (rw) :
        ORIGIN = 0x38200000,
        LENGTH = 1M

    USB1 (rw) :
        ORIGIN = 0x38100000,
        LENGTH = 1M

    GPU_3D (rw) :
        ORIGIN = 0x38000000,
        LENGTH = 32K

    GPU_2D (rw) :
        ORIGIN = 0x38008000,
        LENGTH = 32K

    QSPI_RX (rw) :
        ORIGIN = 0x36000000,
        LENGTH = 32M

    QSPI_RX_1 (rw) :
        ORIGIN = 0x34000000,
        LENGTH = 32M

    QSPI_TX (rw) :
        ORIGIN = 0x33008000,
        LENGTH = 32K

    APBH_DMA (rw) :
        ORIGIN = 0x33000000,
        LENGTH = 32K


    /* ========================= */
    /* AIPS (Peripheral buses)   */
    /* ========================= */

    AIPS_1 (rw) :
        ORIGIN = 0x30000000,
        LENGTH = 4M

    AIPS_2 (rw) :
        ORIGIN = 0x30400000,
        LENGTH = 4M

    AIPS_3 (rw) :
        ORIGIN = 0x30800000,
        LENGTH = 4M

    AIPS_4 (rw) :
        ORIGIN = 0x32C00000,
        LENGTH = 4M

    AIPS_5 (rw) :
        ORIGIN = 0x30C00000,
        LENGTH = 4M


    /* ========================= */
    /* PCIe / OCRAM / ROM        */
    /* ========================= */

    PCIE_REG (rw) :
        ORIGIN = 0x18000000,
        LENGTH = 128M

    OCRAM (rwx) :
        ORIGIN = 0x00900000,
        LENGTH = 576K

    OCRAM_S (rw) :
        ORIGIN = 0x00180000,
        LENGTH = 36K

    OCRAM_S2 (rw) :
        ORIGIN = 0x00189000,
        LENGTH = 28K

    CAAM_SEC_RAM (rw) :
        ORIGIN = 0x00108000,
        LENGTH = 32K

    BOOT_ROM (r) :
        ORIGIN = 0x00000000,
        LENGTH = 252K
}
