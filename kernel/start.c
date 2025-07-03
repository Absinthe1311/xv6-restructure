#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"

void main();   
void timerinit();

// entry.S needs one stack per CPU.
__attribute__ ((aligned (16))) char stack0[4096 * NCPU];

// entry.S jumps here in machine mode on stack0.
void
start()
{
  // set M Previous Privilege mode to Supervisor, for mret.
  // mstatus寄存器存储了有关机器状态的重要信息
  unsigned long x = r_mstatus(); // r_mstatus() 读取mstatus(机器状态寄存器)
  x &= ~MSTATUS_MPP_MASK; // MSTATUS_MPP_MASK 是MPP字段的掩码（表示上一次特权级）
  x |= MSTATUS_MPP_S; // 先清楚MPP字段，在设置为S（Supervisor）模式
  w_mstatus(x);  // 将mstatus寄存器的值改成x(Supervisor)

  // set M Exception Program Counter to main, for mret.
  // requires gcc -mcmodel=medany
  // 将main函数的地址写入mepc(机器异常程序计数器)
  w_mepc((uint64)main); 

  // disable paging for now.
  // 禁用地址翻译，机器指令的所有内存就是物理地址
  w_satp(0);

  // delegate all interrupts and exceptions to supervisor mode.
  // 设置medeleg(机器异常委托寄存器)和mideleg(机器中断委托寄存器)
  // 将m模式下的所有中断和异常委托给S模式
  // riscv提供了中断代理机制，mideleg和medeleg寄存器
  // . 如果将 mideleg/medeleg 寄存器的第 i 位设为 1, 那么就说明将中断码为 i 的外中断/内中断 代理给 S 模式处理.
  w_medeleg(0xffff);
  w_mideleg(0xffff);
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);

  // configure Physical Memory Protection to give supervisor mode
  // access to all of physical memory.
  // 配置物理内存保护
  // 设置PMP区域的最大地址，允许访问所有物理内存
  w_pmpaddr0(0x3fffffffffffffull);
  // 设置权限，0xf表示读写执行全开
  w_pmpcfg0(0xf);

  // ask for clock interrupts.
  // 初始化定时器中断，为后续调度和时钟打基础
  // 时钟中断是唯一的必须陷入M模式才能处理的中断
  timerinit();

  // keep each CPU's hartid in its tp register, for cpuid().
  // 把核心号(mhartid)存入寄存器tp，tp就是所谓的线程指针
  int id = r_mhartid();
  w_tp(id);

  // switch to supervisor mode and jump to main().
  // 执行这一步从 m -> s 同时到main()执行
  asm volatile("mret"); 
}

// ask each hart to generate timer interrupts.
// 设备驱动程序
void
timerinit()
{
  // enable supervisor-mode timer interrupts.
  // 使能S模式下的定时器中断
  w_mie(r_mie() | MIE_STIE);
  
  // enable the sstc extension (i.e. stimecmp).
  // 使能sstc扩展
  w_menvcfg(r_menvcfg() | (1L << 63)); 
  
  // allow supervisor to use stimecmp and time.
  // 允许s模式下访问计数器
  w_mcounteren(r_mcounteren() | 2);
  
  // ask for the very first timer interrupt.
  // 设置下一个定时器中断的时间点
  w_stimecmp(r_time() + 1000000);
}
