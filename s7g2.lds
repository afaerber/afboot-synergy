ENTRY(reset)
MEMORY
{
	FLASH     (RX)  : ORIGIN = 0x00000000, LENGTH = 0x00400000
	SRAMHS    (RWX) : ORIGIN = 0x1ffe0000, LENGTH = 0x00020000
	SRAM0_DED (RWX) : ORIGIN = 0x20000000, LENGTH = 0x00008000
	SRAM0     (RWX) : ORIGIN = 0x20008000, LENGTH = 0x00038000
	SRAM1     (RWX) : ORIGIN = 0x20040000, LENGTH = 0x00040000
	STACK     (RW)  : ORIGIN = 0x2000ffff, LENGTH = 0
}
SECTIONS
{
	. = ORIGIN(FLASH);

	.text :
	{
		KEEP(*(.vector_table))
		*(.text)
		*(.rodata)
		*(.rodata.*)
		_end_text = .;
	} >FLASH

	.data :
	{
		_start_data = .;
		*(.data)
		_end_data = .;
	} >SRAMHS AT >FLASH

	.bss :
	{
		_start_bss = .;
		*(.bss)
		_end_bss = .;
	} >SRAMHS

	.stack :
	{
		_stack_top = .;
	} >STACK
}
