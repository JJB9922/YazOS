ENTRY(_start)

SECTIONS
{
  /* Start offset */
  . = 2M;
  
  /* Multiboot header, text section */
  .text : ALIGN(4K)
  {
    *(.multiboot)
    *(.text)
  }

  /* Read-only data */
  .rodata : ALIGN(4K)
  {
    *(.rodata)
  }

  /* Initialized RW data */
  .data : ALIGN(4K)
  {
    *(.data)    
  }

  /* Uninitialized RW data and stack */
  .bss : ALIGN(4K)
  {
    *(COMMON)
    *(.bss)
  }

}
