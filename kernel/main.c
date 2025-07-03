#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"

volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
  // 主核进行的初始化部分
  if(cpuid() == 0){
    //consoleinit();

    // printf输出部分
    printfinit();
    printf("\n");
    printf("xv6 kernel is booting\n");
    printf("\n");

    // 内存处理部分
    kinit();         // physical page allocator
    kvminit();       // create kernel page table
    kvminithart();   // turn on paging

    // procinit();      // process table

    // 中断处理部分
    trapinit();      // trap vectors
    trapinithart();  // install kernel trap vector
    plicinit();      // set up interrupt controller
    plicinithart();  // ask PLIC for device interrupts

    // binit();         // buffer cache
    // iinit();         // inode table
    // fileinit();      // file table
    // virtio_disk_init(); // emulated hard disk
    // userinit();      // first user process

    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
      ;
    __sync_synchronize();
    printf("hart %d starting\n", cpuid());
    
    // 内存处理部分
    kvminithart();    // turn on paging

    trapinithart();   // install kernel trap vector
    // plicinithart();   // ask PLIC for device interrupts
  }
  //while(1) ;
  //scheduler();        
  intr_on(); // 开放中断
  while(1) ;
}
