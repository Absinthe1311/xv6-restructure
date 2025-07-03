OUTPUT_ARCH( "riscv" ) /*指定目标架构为Riscv*/
ENTRY( _entry ) /*指定程序入口为_entry entry.S中指定的_entry*/

SECTIONS
{
  /*
   * ensure that entry.S / _entry is at 0x80000000,
   * where qemu's -kernel jumps.
   * 从物理地址0x80000000开始放置内核
   */
  . = 0x80000000;
  /* 代码段*/
  .text : {
    *(.text .text.*)
    . = ALIGN(0x1000);
    
    /* 记录trampoline的起始地址，目前用不到*/
     /* _trampoline = .; 
    *(trampsec)
    . = ALIGN(0x1000);
    ASSERT(. - _trampoline == 0x1000, "error: trampoline larger than one page");  */

    PROVIDE(etext = .); /* 定义符号etext，表示代码段结束位置*/
  }

  /* 只读数据段 */
  .rodata : {
    . = ALIGN(16);
    *(.srodata .srodata.*) /* do not need to distinguish this from .rodata */
    . = ALIGN(16);
    *(.rodata .rodata.*)
  }

  /* 已初始化数据 */
  .data : {
    . = ALIGN(16);
    *(.sdata .sdata.*) /* do not need to distinguish this from .data */
    . = ALIGN(16);
    *(.data .data.*)
  }

  /* 未初始化数据段 */
  .bss : {
    . = ALIGN(16);
    *(.sbss .sbss.*) /* do not need to distinguish this from .bss */
    . = ALIGN(16);
    *(.bss .bss.*)
  }

  /* end符号 */
  PROVIDE(end = .);
}
