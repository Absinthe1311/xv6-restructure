#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

struct cpu cpus[NCPU];

// 现今对这个proc进行修改，只使用一个proc结构体

struct proc proc[NPROC];

struct proc *initproc;

// struct proc *initproc;

int nextpid = 1;
// 这个是用来访问变量nextpid前设置的锁，现阶段可以不要
// struct spinlock pid_lock; 

// extern void forkret(void);
// static void freeproc(struct proc *p);

extern char trampoline[]; // trampoline.S

// // helps ensure that wakeups of wait()ing
// // parents are not lost. helps obey the
// // memory model when using p->parent.
// // must be acquired before any p->lock.
// struct spinlock wait_lock;

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
// 原来是将所有进程分配的栈记录在内核页表上面，现在只有一个proc结构体
void
proc_mapstacks(pagetable_t kpgtbl)
{
  //struct proc *p;
  // for(p = proc; p < &proc[NPROC]; p++) {
  //   char *pa = kalloc();
  //   if(pa == 0)
  //     panic("kalloc");
  //   uint64 va = KSTACK((int) (p - proc));
  //   kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
  // }

  struct proc *p = proc;
  char *pa = kalloc();
  if(pa == 0)
    panic("kalloc");
  uint64 va = KSTACK((int) (p - proc));
  kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
}

// initialize the proc table.
void
procinit(void)
{
  struct proc *p;

  // initlock(&pid_lock, "nextpid");
  // initlock(&wait_lock, "wait_lock");
  // for(p = proc; p < &proc[NPROC]; p++) {
  //     initlock(&p->lock, "proc");
  //     p->state = UNUSED;
  //     p->kstack = KSTACK((int) (p - proc));
  // }

  // struct proc *p = &proc;
  // p->state = UNUSED;
  // p->kstack = KSTACK((int)0);
  p = proc;
  p -> state = UNUSED;
  p->kstack = KSTACK((int)(p-proc));
}

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
  int id = r_tp();
  return id;
}

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
  int id = cpuid();
  struct cpu *c = &cpus[id];
  //printf("测试用：进入了mycpu()\n");
  return c;
}

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
  push_off();
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
  pop_off();
  return p;
}

int
allocpid()
{
  int pid;
  
  // 现在只有一个进程，所以这个锁不需要
  // acquire(&pid_lock);
  pid = nextpid;
  nextpid = nextpid + 1;
  // release(&pid_lock);

  return pid;
}
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
// Look in the process table for an UNUSED proc.
// If found, initialize state required to run in the kernel,
// and return with p->lock held.
// If there are no free procs, or a memory allocation fails, return 0.
static struct proc*
allocproc(void)
{
  struct proc *p = proc;

  // for(p = proc; p < &proc[NPROC]; p++) {
  //   acquire(&p->lock);
  //   if(p->state == UNUSED) {
  //     goto found;
  //   } else {
  //     release(&p->lock);
  //   }
  // }
  // return 0;

  // 现在只设置了一个proc结构体，对上文的修改如下
  //p = &proc;
  if(p->state == UNUSED){
    goto found;
  }
  return 0;

found:
  p->pid = allocpid();
  p->state = USED;

  // Allocate a trapframe page.
  // 为这个进程分配一页物理页作为陷入帧
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    //freeproc(p);
    //release(&p->lock);
    return 0;
  }

  // An empty user page table.
  p->pagetable = proc_pagetable(p);
  if(p->pagetable == 0){
    //freeproc(p);
    //release(&p->lock);
    return 0;
  }

  // Set up new context to start executing at forkret,
  // which returns to user space.
  // 设置进程上下文
  memset(&p->context, 0, sizeof(p->context));
  // 这里修改forkret,修改为usertrapret
  // p->context.ra = (uint64)forkret;
  p->context.ra = (uint64)usertrapret; // 这样做完我的首进程的返回地址就是usertrapret
  p->context.sp = p->kstack + PGSIZE;

  return p;
}


// // free a proc structure and the data hanging from it,
// // including user pages.
// // p->lock must be held.
// static void
// freeproc(struct proc *p)
// {
//   if(p->trapframe)
//     kfree((void*)p->trapframe);
//   p->trapframe = 0;
//   if(p->pagetable)
//     proc_freepagetable(p->pagetable, p->sz);
//   p->pagetable = 0;
//   p->sz = 0;
//   p->pid = 0;
//   p->parent = 0;
//   p->name[0] = 0;
//   p->chan = 0;
//   p->killed = 0;
//   p->xstate = 0;
//   p->state = UNUSED;
// }

// Create a user page table for a given process, with no user memory,
// but with trampoline and trapframe pages.
pagetable_t
proc_pagetable(struct proc *p)
{
  pagetable_t pagetable;

  // An empty page table.
  pagetable = uvmcreate();
  if(pagetable == 0)
    return 0;

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
              (uint64)trampoline, PTE_R | PTE_X) < 0){
    uvmfree(pagetable, 0);
    return 0;
  }

  // map the trapframe page just below the trampoline page, for
  // trampoline.S.
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
              (uint64)(p->trapframe), PTE_R | PTE_W) < 0){
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmfree(pagetable, 0);
    return 0;
  }

  return pagetable;
}

// Free a process's page table, and free the
// physical memory it refers to.
void
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
  uvmfree(pagetable, sz);
}

// a user program that calls exec("/init")
// assembled from ../user/initcode.S
// od -t xC ../user/initcode
// uchar initcode[] = {
//   0x17, 0x05, 0x00, 0x00, 0x13, 0x05, 0x45, 0x02,
//   0x97, 0x05, 0x00, 0x00, 0x93, 0x85, 0x35, 0x02,
//   0x93, 0x08, 0x70, 0x00, 0x73, 0x00, 0x00, 0x00,
//   0x93, 0x08, 0x20, 0x00, 0x73, 0x00, 0x00, 0x00,
//   0xef, 0xf0, 0x9f, 0xff, 0x2f, 0x69, 0x6e, 0x69,
//   0x74, 0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x00,
//   0x00, 0x00, 0x00, 0x00
// };

// 使用老师提供的initcode
// int main() { 
// syscall(12); // 封装 12号系统调用，a7寄存器装入12后执行ecall指令 
// syscall(12); // 再次发起相同系统调用 
// while(1) ; // 死循环 
// return 0; 
// } 
// uchar initcode[] = { 
// 0x13, 0x01, 0x01, 0xff, 0x23, 0x34, 0x11, 0x00, 
// 0x23, 0x30, 0x81, 0x00, 0x13, 0x04, 0x01, 0x01, 
// 0x13, 0x05, 0x40, 0x01, 0x97, 0x00, 0x00, 0x00, 
// 0xe7, 0x80, 0x80, 0x01, 0x13, 0x05, 0x40, 0x01, 
// 0x97, 0x00, 0x00, 0x00, 0xe7, 0x80, 0xc0, 0x00, 
// 0x6f, 0x00, 0x00, 0x00, 0x93, 0x08, 0xc0, 0x00, 
// 0x73, 0x00, 0x00, 0x00, 0x67, 0x80, 0x00, 0x00 
// };

// 阶段五的initcode
uchar initcode[] = {
  	0x13, 0x01, 0x01, 0xfe, 0x23, 0x3c, 0x11, 0x00, 0x23, 0x38, 0x81, 0x00, 
	0x23, 0x34, 0x91, 0x00, 0x13, 0x04, 0x01, 0x02, 0x93, 0x04, 0x05, 0xff, 
	0x97, 0x17, 0x00, 0x00, 0x83, 0xb7, 0x07, 0xff, 0x6f, 0x00, 0x00, 0x06, 
	0x03, 0xa7, 0x86, 0x00, 0x3b, 0x07, 0xc7, 0x00, 0x23, 0x2c, 0xe5, 0xfe, 
	0x03, 0xb7, 0x07, 0x00, 0x83, 0x36, 0x07, 0x00, 0x6f, 0x00, 0x00, 0x07, 
	0x03, 0x27, 0x85, 0xff, 0x3b, 0x07, 0xc7, 0x00, 0x23, 0xa4, 0xe7, 0x00, 
	0x83, 0x36, 0x05, 0xff, 0x93, 0x84, 0x07, 0x00, 0x6f, 0x00, 0x40, 0x07, 
	0x13, 0x05, 0x00, 0x10, 0x3b, 0x05, 0xe5, 0x40, 0x97, 0x00, 0x00, 0x00, 
	0xe7, 0x80, 0xc0, 0x0a, 0x93, 0x07, 0x00, 0x10, 0x23, 0xa4, 0xf4, 0x00, 
	0x6f, 0x00, 0x80, 0x08, 0x03, 0xb7, 0x07, 0x00, 0x63, 0xe4, 0xe7, 0x00, 
	0x63, 0xec, 0xe4, 0x00, 0x93, 0x07, 0x07, 0x00, 0xe3, 0xf8, 0x97, 0xfe, 
	0x03, 0xb7, 0x07, 0x00, 0x63, 0xe4, 0xe4, 0x00, 0xe3, 0xe8, 0xe7, 0xfe, 
	0x03, 0x26, 0x85, 0xff, 0x83, 0xb6, 0x07, 0x00, 0x93, 0x15, 0x06, 0x02, 
	0x13, 0xd7, 0xc5, 0x01, 0x33, 0x87, 0xe4, 0x00, 0xe3, 0x80, 0xe6, 0xf8, 
	0x23, 0x38, 0xd5, 0xfe, 0x03, 0xa6, 0x87, 0x00, 0x93, 0x16, 0x06, 0x02, 
	0x13, 0xd7, 0xc6, 0x01, 0x33, 0x87, 0xe7, 0x00, 0x93, 0x86, 0x04, 0x00, 
	0xe3, 0x8e, 0xe4, 0xf6, 0x23, 0xb0, 0xd7, 0x00, 0x17, 0x17, 0x00, 0x00, 
	0x23, 0x30, 0xf7, 0xf4, 0x03, 0xa7, 0x84, 0x00, 0x93, 0x16, 0x07, 0x02, 
	0x93, 0xd7, 0xc6, 0x01, 0xb3, 0x87, 0xf4, 0x00, 0x97, 0x16, 0x00, 0x00, 
	0x83, 0xb6, 0x06, 0xf2, 0x63, 0xe6, 0xd7, 0x00, 0x93, 0x07, 0xf0, 0x3f, 
	0xe3, 0xe2, 0xe7, 0xf6, 0x83, 0x30, 0x81, 0x01, 0x03, 0x34, 0x01, 0x01, 
	0x83, 0x34, 0x81, 0x00, 0x13, 0x01, 0x01, 0x02, 0x67, 0x80, 0x00, 0x00, 
	0x13, 0x01, 0x01, 0xfe, 0x23, 0x3c, 0x11, 0x00, 0x23, 0x38, 0x81, 0x00, 
	0x23, 0x34, 0x91, 0x00, 0x13, 0x04, 0x01, 0x02, 0x93, 0x04, 0x05, 0x00, 
	0x63, 0x5e, 0xa0, 0x04, 0x1b, 0x15, 0x45, 0x00, 0x97, 0x00, 0x00, 0x00, 
	0xe7, 0x80, 0xc0, 0x27, 0x93, 0x07, 0x05, 0x00, 0x13, 0x07, 0xf0, 0xff, 
	0x13, 0x05, 0x00, 0x00, 0x63, 0x86, 0xe7, 0x02, 0x23, 0xa4, 0x97, 0x00, 
	0x93, 0x94, 0x44, 0x00, 0xb3, 0x84, 0x97, 0x00, 0x17, 0x17, 0x00, 0x00, 
	0x23, 0x3a, 0x97, 0xea, 0x13, 0x85, 0x07, 0x01, 0x97, 0x00, 0x00, 0x00, 
	0xe7, 0x80, 0x80, 0xea, 0x17, 0x15, 0x00, 0x00, 0x03, 0x35, 0x85, 0xea, 
	0x83, 0x30, 0x81, 0x01, 0x03, 0x34, 0x01, 0x01, 0x83, 0x34, 0x81, 0x00, 
	0x13, 0x01, 0x01, 0x02, 0x67, 0x80, 0x00, 0x00, 0x1b, 0x15, 0x45, 0x00, 
	0x97, 0x00, 0x00, 0x00, 0xe7, 0x80, 0x40, 0x22, 0x13, 0x07, 0x05, 0x00, 
	0x93, 0x07, 0xf0, 0xff, 0x13, 0x05, 0x00, 0x00, 0xe3, 0x0a, 0xf7, 0xfc, 
	0x97, 0x17, 0x00, 0x00, 0x93, 0x87, 0x87, 0xe6, 0x93, 0x94, 0x44, 0x00, 
	0x03, 0xb7, 0x07, 0x00, 0xb3, 0x84, 0xe4, 0x00, 0x23, 0xb0, 0x97, 0x00, 
	0x6f, 0xf0, 0x9f, 0xfb, 0x13, 0x01, 0x01, 0xfb, 0x23, 0x34, 0x11, 0x04, 
	0x23, 0x30, 0x81, 0x04, 0x23, 0x3c, 0x91, 0x02, 0x23, 0x38, 0x21, 0x03, 
	0x23, 0x34, 0x31, 0x03, 0x23, 0x30, 0x41, 0x03, 0x23, 0x3c, 0x51, 0x01, 
	0x23, 0x38, 0x61, 0x01, 0x23, 0x34, 0x71, 0x01, 0x13, 0x04, 0x01, 0x05, 
	0x93, 0x14, 0x05, 0x02, 0x93, 0xd4, 0x04, 0x02, 0x93, 0x84, 0xf4, 0x00, 
	0x93, 0xd4, 0x44, 0x00, 0x1b, 0x8a, 0x14, 0x00, 0x93, 0x84, 0x14, 0x00, 
	0x17, 0x15, 0x00, 0x00, 0x03, 0x35, 0x05, 0xe1, 0x63, 0x06, 0x05, 0x02, 
	0x83, 0x37, 0x05, 0x00, 0x03, 0xa7, 0x87, 0x00, 0x63, 0x7e, 0x97, 0x02, 
	0x17, 0x19, 0x00, 0x00, 0x13, 0x09, 0x89, 0xdf, 0x13, 0x8b, 0x04, 0x00, 
	0x93, 0x8a, 0x04, 0x00, 0x93, 0x09, 0x00, 0x10, 0x93, 0x0b, 0x00, 0x10, 
	0x6f, 0x00, 0xc0, 0x09, 0x97, 0x17, 0x00, 0x00, 0x93, 0x87, 0x47, 0xde, 
	0x17, 0x17, 0x00, 0x00, 0x23, 0x3a, 0xf7, 0xdc, 0x23, 0xb0, 0xf7, 0x00, 
	0x23, 0xa4, 0x07, 0x00, 0x6f, 0xf0, 0xdf, 0xfc, 0x63, 0x8a, 0xe4, 0x04, 
	0x3b, 0x07, 0x47, 0x41, 0x23, 0xa4, 0xe7, 0x00, 0x93, 0x16, 0x07, 0x02, 
	0x13, 0xd7, 0xc6, 0x01, 0xb3, 0x87, 0xe7, 0x00, 0x23, 0xa4, 0x47, 0x01, 
	0x17, 0x17, 0x00, 0x00, 0x23, 0x32, 0xa7, 0xda, 0x13, 0x85, 0x07, 0x01, 
	0x83, 0x30, 0x81, 0x04, 0x03, 0x34, 0x01, 0x04, 0x83, 0x34, 0x81, 0x03, 
	0x03, 0x39, 0x01, 0x03, 0x83, 0x39, 0x81, 0x02, 0x03, 0x3a, 0x01, 0x02, 
	0x83, 0x3a, 0x81, 0x01, 0x03, 0x3b, 0x01, 0x01, 0x83, 0x3b, 0x81, 0x00, 
	0x13, 0x01, 0x01, 0x05, 0x67, 0x80, 0x00, 0x00, 0x03, 0xb7, 0x07, 0x00, 
	0x23, 0x30, 0xe5, 0x00, 0x6f, 0xf0, 0x1f, 0xfc, 0x1b, 0x05, 0x05, 0x00, 
	0x97, 0x00, 0x00, 0x00, 0xe7, 0x80, 0xc0, 0xe5, 0xe3, 0x0e, 0x05, 0xfa, 
	0x83, 0x37, 0x05, 0x00, 0x03, 0xa7, 0x87, 0x00, 0xe3, 0x74, 0x97, 0xf8, 
	0x03, 0x37, 0x09, 0x00, 0x13, 0x85, 0x07, 0x00, 0xe3, 0x16, 0xf7, 0xfe, 
	0x13, 0x05, 0x0b, 0x00, 0xe3, 0xfa, 0x3a, 0xfd, 0x13, 0x85, 0x0b, 0x00, 
	0x6f, 0xf0, 0xdf, 0xfc, 0x13, 0x01, 0x01, 0xf8, 0x23, 0x3c, 0x11, 0x06, 
	0x23, 0x38, 0x81, 0x06, 0x23, 0x34, 0x91, 0x06, 0x23, 0x30, 0x21, 0x07, 
	0x23, 0x3c, 0x31, 0x05, 0x13, 0x04, 0x01, 0x08, 0x13, 0x09, 0x04, 0xf8, 
	0x93, 0x04, 0x80, 0x3e, 0xb7, 0x39, 0x00, 0x00, 0x93, 0x89, 0x89, 0xaf, 
	0x13, 0x85, 0x04, 0x00, 0x97, 0x00, 0x00, 0x00, 0xe7, 0x80, 0x40, 0xea, 
	0x23, 0x30, 0xa9, 0x00, 0x9b, 0x84, 0x84, 0x3e, 0x13, 0x09, 0x89, 0x00, 
	0xe3, 0x94, 0x34, 0xff, 0x03, 0x35, 0x04, 0xf8, 0x97, 0x00, 0x00, 0x00, 
	0xe7, 0x80, 0x40, 0xcd, 0x03, 0x35, 0x04, 0xf9, 0x97, 0x00, 0x00, 0x00, 
	0xe7, 0x80, 0x80, 0xcc, 0x03, 0x35, 0x04, 0xfa, 0x97, 0x00, 0x00, 0x00, 
	0xe7, 0x80, 0xc0, 0xcb, 0x03, 0x35, 0x04, 0xfb, 0x97, 0x00, 0x00, 0x00, 
	0xe7, 0x80, 0x00, 0xcb, 0x03, 0x35, 0x04, 0xfc, 0x97, 0x00, 0x00, 0x00, 
	0xe7, 0x80, 0x40, 0xca, 0x03, 0x35, 0x84, 0xfc, 0x97, 0x00, 0x00, 0x00, 
	0xe7, 0x80, 0x80, 0xc9, 0x03, 0x35, 0x84, 0xfb, 0x97, 0x00, 0x00, 0x00, 
	0xe7, 0x80, 0xc0, 0xc8, 0x03, 0x35, 0x84, 0xfa, 0x97, 0x00, 0x00, 0x00, 
	0xe7, 0x80, 0x00, 0xc8, 0x03, 0x35, 0x84, 0xf9, 0x97, 0x00, 0x00, 0x00, 
	0xe7, 0x80, 0x40, 0xc7, 0x03, 0x35, 0x84, 0xf8, 0x97, 0x00, 0x00, 0x00, 
	0xe7, 0x80, 0x80, 0xc6, 0x6f, 0x00, 0x00, 0x00, 0x93, 0x08, 0xc0, 0x00, 
	0x73, 0x00, 0x00, 0x00, 0x67, 0x80, 0x00, 0x00, 
};

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////


// Set up first user process.
// 这个应该是第一个用户进程的初始化  我的存在问题的代码
void
userinit(void)
{
  struct proc *p;

  p = allocproc();
  initproc = p;
  
  // allocate one user page and copy initcode's instructions
  // and data into it.
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
  p->sz = 4*PGSIZE;
  // 全局数据页1
  char* mem1 = kalloc();
  if(mem1 == 0)
    panic("userinit: out of memory for global data page1");
  memset(mem1,0,PGSIZE);
  if(mappages(p->pagetable,PGSIZE,PGSIZE,(uint64)mem1,PTE_W|PTE_R|PTE_U) < 0)
  {
    kfree(mem1);
    panic("userinit: can't map global data page 1");
  }
  // 全局数据页2
  char* mem2 = kalloc();
  if(mem2 == 0)
    panic("userinit: out of memory for global data page2");
  memset(mem2,0,PGSIZE);
  if(mappages(p->pagetable,2*PGSIZE,PGSIZE,(uint64)mem2,PTE_W|PTE_R|PTE_U) < 0)
  {
    kfree(mem2);
    panic("userinit: can't map global data page 2");
  }
  // 栈
  char *stack = kalloc();
  if(stack == 0)
    panic("userinit: out of memory for stack");
  memset(stack, 0, PGSIZE);  // 栈也初始化为0
  if(mappages(p->pagetable, 3*PGSIZE, PGSIZE, (uint64)stack, PTE_W|PTE_R|PTE_U) < 0){
    kfree(stack);
    panic("userinit: can't map stack page");
  }

  // prepare for the very first "return" from kernel to user.
  // // 现在是阶段四的设置
  // p->trapframe->epc = 0;      // user program counter
  
  // 阶段五，将这个地方设置为main的地址
  p->trapframe->epc = 0x2e0; // 不确定
  p->trapframe->sp = 4*PGSIZE;  // user stack pointer

  memset(&p->context, 0, sizeof(p->context));
  //p->context.ra = (uint64)usertrapret;
  p->context.sp = p->kstack + PGSIZE; 
  p->context.ra = (uint64)usertrapret;
  

  safestrcpy(p->name, "initcode", sizeof(p->name));
  // 不知道这个有没有用，这个好像涉及到了文件，现在先注释
  // p->cwd = namei("/");

  p->state = RUNNABLE; 

  // release(&p->lock);

  struct cpu *c = mycpu();
  c->proc = p;
  swtch(&(c->context),&(p->context));
}


// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint64 sz;
  struct proc *p = myproc();

  sz = p->sz;
  if(n > 0){
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
      return -1;
    }
  } else if(n < 0){
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }
  p->sz = sz;
  return 0;
}

// // Create a new process, copying the parent.
// // Sets up child kernel stack to return as if from fork() system call.
// int
// fork(void)
// {
//   int i, pid;
//   struct proc *np;
//   struct proc *p = myproc();

//   // Allocate process.
//   if((np = allocproc()) == 0){
//     return -1;
//   }

//   // Copy user memory from parent to child.
//   if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
//     freeproc(np);
//     release(&np->lock);
//     return -1;
//   }
//   np->sz = p->sz;

//   // copy saved user registers.
//   *(np->trapframe) = *(p->trapframe);

//   // Cause fork to return 0 in the child.
//   np->trapframe->a0 = 0;

//   // increment reference counts on open file descriptors.
//   for(i = 0; i < NOFILE; i++)
//     if(p->ofile[i])
//       np->ofile[i] = filedup(p->ofile[i]);
//   np->cwd = idup(p->cwd);

//   safestrcpy(np->name, p->name, sizeof(p->name));

//   pid = np->pid;

//   release(&np->lock);

//   acquire(&wait_lock);
//   np->parent = p;
//   release(&wait_lock);

//   acquire(&np->lock);
//   np->state = RUNNABLE;
//   release(&np->lock);

//   return pid;
// }

// // Pass p's abandoned children to init.
// // Caller must hold wait_lock.
// void
// reparent(struct proc *p)
// {
//   struct proc *pp;

//   for(pp = proc; pp < &proc[NPROC]; pp++){
//     if(pp->parent == p){
//       pp->parent = initproc;
//       wakeup(initproc);
//     }
//   }
// }

// // Exit the current process.  Does not return.
// // An exited process remains in the zombie state
// // until its parent calls wait().
// void
// exit(int status)
// {
//   struct proc *p = myproc();

//   if(p == initproc)
//     panic("init exiting");

//   // Close all open files.
//   for(int fd = 0; fd < NOFILE; fd++){
//     if(p->ofile[fd]){
//       struct file *f = p->ofile[fd];
//       fileclose(f);
//       p->ofile[fd] = 0;
//     }
//   }

//   begin_op();
//   iput(p->cwd);
//   end_op();
//   p->cwd = 0;

//   acquire(&wait_lock);

//   // Give any children to init.
//   reparent(p);

//   // Parent might be sleeping in wait().
//   wakeup(p->parent);
  
//   acquire(&p->lock);

//   p->xstate = status;
//   p->state = ZOMBIE;

//   release(&wait_lock);

//   // Jump into the scheduler, never to return.
//   sched();
//   panic("zombie exit");
// }

// // Wait for a child process to exit and return its pid.
// // Return -1 if this process has no children.
// int
// wait(uint64 addr)
// {
//   struct proc *pp;
//   int havekids, pid;
//   struct proc *p = myproc();

//   acquire(&wait_lock);

//   for(;;){
//     // Scan through table looking for exited children.
//     havekids = 0;
//     for(pp = proc; pp < &proc[NPROC]; pp++){
//       if(pp->parent == p){
//         // make sure the child isn't still in exit() or swtch().
//         acquire(&pp->lock);

//         havekids = 1;
//         if(pp->state == ZOMBIE){
//           // Found one.
//           pid = pp->pid;
//           if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
//                                   sizeof(pp->xstate)) < 0) {
//             release(&pp->lock);
//             release(&wait_lock);
//             return -1;
//           }
//           freeproc(pp);
//           release(&pp->lock);
//           release(&wait_lock);
//           return pid;
//         }
//         release(&pp->lock);
//       }
//     }

//     // No point waiting if we don't have any children.
//     if(!havekids || killed(p)){
//       release(&wait_lock);
//       return -1;
//     }
    
//     // Wait for a child to exit.
//     sleep(p, &wait_lock);  //DOC: wait-sleep
//   }
// }

// // Per-CPU process scheduler.
// // Each CPU calls scheduler() after setting itself up.
// // Scheduler never returns.  It loops, doing:
// //  - choose a process to run.
// //  - swtch to start running that process.
// //  - eventually that process transfers control
// //    via swtch back to the scheduler.
// void
// scheduler(void)
// {
//   struct proc *p;
//   struct cpu *c = mycpu();

//   c->proc = 0;
//   for(;;){
//     // The most recent process to run may have had interrupts
//     // turned off; enable them to avoid a deadlock if all
//     // processes are waiting.
//     intr_on();

//     int found = 0;
//     for(p = proc; p < &proc[NPROC]; p++) {
//       acquire(&p->lock);
//       if(p->state == RUNNABLE) {
//         // Switch to chosen process.  It is the process's job
//         // to release its lock and then reacquire it
//         // before jumping back to us.
//         p->state = RUNNING;
//         c->proc = p;
//         swtch(&c->context, &p->context);

//         // Process is done running for now.
//         // It should have changed its p->state before coming back.
//         c->proc = 0;
//         found = 1;
//       }
//       release(&p->lock);
//     }
//     if(found == 0) {
//       // nothing to run; stop running on this core until an interrupt.
//       intr_on();
//       asm volatile("wfi");
//     }
//   }
// }

// // Switch to scheduler.  Must hold only p->lock
// // and have changed proc->state. Saves and restores
// // intena because intena is a property of this
// // kernel thread, not this CPU. It should
// // be proc->intena and proc->noff, but that would
// // break in the few places where a lock is held but
// // there's no process.
// void
// sched(void)
// {
//   int intena;
//   struct proc *p = myproc();

//   if(!holding(&p->lock))
//     panic("sched p->lock");
//   if(mycpu()->noff != 1)
//     panic("sched locks");
//   if(p->state == RUNNING)
//     panic("sched running");
//   if(intr_get())
//     panic("sched interruptible");

//   intena = mycpu()->intena;
//   swtch(&p->context, &mycpu()->context);
//   mycpu()->intena = intena;
// }

// // Give up the CPU for one scheduling round.
// void
// yield(void)
// {
//   struct proc *p = myproc();
//   acquire(&p->lock);
//   p->state = RUNNABLE;
//   sched();
//   release(&p->lock);
// }

// // A fork child's very first scheduling by scheduler()
// // will swtch to forkret.
// void
// forkret(void)
// {
//   static int first = 1;

//   // Still holding p->lock from scheduler.
//   release(&myproc()->lock);

//   if (first) {
//     // File system initialization must be run in the context of a
//     // regular process (e.g., because it calls sleep), and thus cannot
//     // be run from main().
//     fsinit(ROOTDEV);

//     first = 0;
//     // ensure other cores see first=0.
//     __sync_synchronize();
//   }

//   usertrapret();
// }

// // Atomically release lock and sleep on chan.
// // Reacquires lock when awakened.
// void
// sleep(void *chan, struct spinlock *lk)
// {
//   struct proc *p = myproc();
  
//   // Must acquire p->lock in order to
//   // change p->state and then call sched.
//   // Once we hold p->lock, we can be
//   // guaranteed that we won't miss any wakeup
//   // (wakeup locks p->lock),
//   // so it's okay to release lk.

//   acquire(&p->lock);  //DOC: sleeplock1
//   release(lk);

//   // Go to sleep.
//   p->chan = chan;
//   p->state = SLEEPING;

//   sched();

//   // Tidy up.
//   p->chan = 0;

//   // Reacquire original lock.
//   release(&p->lock);
//   acquire(lk);
// }

// // Wake up all processes sleeping on chan.
// // Must be called without any p->lock.
// void
// wakeup(void *chan)
// {
//   struct proc *p;

//   for(p = proc; p < &proc[NPROC]; p++) {
//     if(p != myproc()){
//       acquire(&p->lock);
//       if(p->state == SLEEPING && p->chan == chan) {
//         p->state = RUNNABLE;
//       }
//       release(&p->lock);
//     }
//   }
// }

// // Kill the process with the given pid.
// // The victim won't exit until it tries to return
// // to user space (see usertrap() in trap.c).
// int
// kill(int pid)
// {
//   struct proc *p;

//   for(p = proc; p < &proc[NPROC]; p++){
//     acquire(&p->lock);
//     if(p->pid == pid){
//       p->killed = 1;
//       if(p->state == SLEEPING){
//         // Wake process from sleep().
//         p->state = RUNNABLE;
//       }
//       release(&p->lock);
//       return 0;
//     }
//     release(&p->lock);
//   }
//   return -1;
// }

// void
// setkilled(struct proc *p)
// {
//   acquire(&p->lock);
//   p->killed = 1;
//   release(&p->lock);
// }

// int
// killed(struct proc *p)
// {
//   int k;
  
//   acquire(&p->lock);
//   k = p->killed;
//   release(&p->lock);
//   return k;
// }

// // Copy to either a user address, or kernel address,
// // depending on usr_dst.
// // Returns 0 on success, -1 on error.
// int
// either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
// {
//   struct proc *p = myproc();
//   if(user_dst){
//     return copyout(p->pagetable, dst, src, len);
//   } else {
//     memmove((char *)dst, src, len);
//     return 0;
//   }
// }

// // Copy from either a user address, or kernel address,
// // depending on usr_src.
// // Returns 0 on success, -1 on error.
// int
// either_copyin(void *dst, int user_src, uint64 src, uint64 len)
// {
//   struct proc *p = myproc();
//   if(user_src){
//     return copyin(p->pagetable, dst, src, len);
//   } else {
//     memmove(dst, (char*)src, len);
//     return 0;
//   }
// }

// // Print a process listing to console.  For debugging.
// // Runs when user types ^P on console.
// // No lock to avoid wedging a stuck machine further.
// void
// procdump(void)
// {
//   static char *states[] = {
//   [UNUSED]    "unused",
//   [USED]      "used",
//   [SLEEPING]  "sleep ",
//   [RUNNABLE]  "runble",
//   [RUNNING]   "run   ",
//   [ZOMBIE]    "zombie"
//   };
//   struct proc *p;
//   char *state;

//   printf("\n");
//   for(p = proc; p < &proc[NPROC]; p++){
//     if(p->state == UNUSED)
//       continue;
//     if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
//       state = states[p->state];
//     else
//       state = "???";
//     printf("%d %s %s", p->pid, state, p->name);
//     printf("\n");
//   }
// }
