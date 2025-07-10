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

    uartinit();
    
    // printf输出部分
    printfinit();
    printf("\n");
    printf("xv6 kernel is booting\n");
    printf("\n");

    // 内存处理部分
    kinit();         // physical page allocator
    kvminit();       // create kernel page table
    kvminithart();   // turn on paging

    // 进程表的初始化
    procinit();      // 恢复为了原来的procinit()

    printf("xv6 passed the procinit()\n");

    // 中断处理部分
    trapinit();      // trap vectors
    trapinithart();  // install kernel trap vector
    plicinit();      // set up interrupt controller
    plicinithart();  // ask PLIC for device interrupts

    // binit();         // buffer cache
    // iinit();         // inode table
    // fileinit();      // file table
    // virtio_disk_init(); // emulated hard disk


    /////////////////////////////////////////////
    /*    这个是原来的实现方式     */
      // //userinit();      // first user process
      // started = 1;
      // __sync_synchronize();
      // //started = 1;
      // // 修改了userinit()和started=1的位置
      // userinit();
    /////////////////////////////////////////////
    /*    现在修改为原来的main的样子        */
    started = 1;
    __sync_synchronize();
    userinit();

  } else {
    while(started == 0)
      ;
    __sync_synchronize();
    printf("hart %d starting\n", cpuid());
    
    // 内存处理部分
    kvminithart();    // turn on paging

    // 中断处理部分
    trapinithart();   // install kernel trap vector
    plicinithart();   // ask PLIC for device interrupts
  }
  scheduler();        
  // intr_on(); // 开放中断
  // while(1) ; // 其余的CPU都会陷入这个死循环
}
