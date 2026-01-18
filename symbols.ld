SECTIONS
{    .platform_info : ALIGN(8)
    {
        __platform_info_start = .;

        __ddr_start = .;
        QUAD(ORIGIN(DDR));

        __ddr_size = .;
        QUAD(LENGTH(DDR));

        __aips1_base = .;
        QUAD(ORIGIN(aips_1));
        __aips1_size = .;
        QUAD(LENGTH(aips_1));

        __platform_info_end = .;
    } > DDR
}