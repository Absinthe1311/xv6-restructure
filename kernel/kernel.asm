
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00003117          	auipc	sp,0x3
    80000004:	49013103          	ld	sp,1168(sp) # 80003490 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	3cb000ef          	jal	ra,80000be0 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <kfree>:
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
// 用于释放内存，释放的页面挂在freelist上面
void
kfree(void *pa)
{
    8000001c:	1101                	addi	sp,sp,-32
    8000001e:	ec06                	sd	ra,24(sp)
    80000020:	e822                	sd	s0,16(sp)
    80000022:	e426                	sd	s1,8(sp)
    80000024:	e04a                	sd	s2,0(sp)
    80000026:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000028:	03451793          	slli	a5,a0,0x34
    8000002c:	e7a9                	bnez	a5,80000076 <kfree+0x5a>
    8000002e:	84aa                	mv	s1,a0
    80000030:	0000e797          	auipc	a5,0xe
    80000034:	34078793          	addi	a5,a5,832 # 8000e370 <end>
    80000038:	02f56f63          	bltu	a0,a5,80000076 <kfree+0x5a>
    8000003c:	47c5                	li	a5,17
    8000003e:	07ee                	slli	a5,a5,0x1b
    80000040:	02f57b63          	bgeu	a0,a5,80000076 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000044:	6605                	lui	a2,0x1
    80000046:	4585                	li	a1,1
    80000048:	409000ef          	jal	ra,80000c50 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    8000004c:	00003917          	auipc	s2,0x3
    80000050:	49490913          	addi	s2,s2,1172 # 800034e0 <kmem>
    80000054:	854a                	mv	a0,s2
    80000056:	273000ef          	jal	ra,80000ac8 <acquire>
  r->next = kmem.freelist;
    8000005a:	01893783          	ld	a5,24(s2)
    8000005e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000060:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000064:	854a                	mv	a0,s2
    80000066:	2fb000ef          	jal	ra,80000b60 <release>
}
    8000006a:	60e2                	ld	ra,24(sp)
    8000006c:	6442                	ld	s0,16(sp)
    8000006e:	64a2                	ld	s1,8(sp)
    80000070:	6902                	ld	s2,0(sp)
    80000072:	6105                	addi	sp,sp,32
    80000074:	8082                	ret
    panic("kfree");
    80000076:	00003517          	auipc	a0,0x3
    8000007a:	f8a50513          	addi	a0,a0,-118 # 80003000 <etext>
    8000007e:	5f0000ef          	jal	ra,8000066e <panic>

0000000080000082 <freerange>:
{
    80000082:	7179                	addi	sp,sp,-48
    80000084:	f406                	sd	ra,40(sp)
    80000086:	f022                	sd	s0,32(sp)
    80000088:	ec26                	sd	s1,24(sp)
    8000008a:	e84a                	sd	s2,16(sp)
    8000008c:	e44e                	sd	s3,8(sp)
    8000008e:	e052                	sd	s4,0(sp)
    80000090:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000092:	6785                	lui	a5,0x1
    80000094:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000098:	00e504b3          	add	s1,a0,a4
    8000009c:	777d                	lui	a4,0xfffff
    8000009e:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000a0:	94be                	add	s1,s1,a5
    800000a2:	0095ec63          	bltu	a1,s1,800000ba <freerange+0x38>
    800000a6:	892e                	mv	s2,a1
    kfree(p);
    800000a8:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000aa:	6985                	lui	s3,0x1
    kfree(p);
    800000ac:	01448533          	add	a0,s1,s4
    800000b0:	f6dff0ef          	jal	ra,8000001c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000b4:	94ce                	add	s1,s1,s3
    800000b6:	fe997be3          	bgeu	s2,s1,800000ac <freerange+0x2a>
}
    800000ba:	70a2                	ld	ra,40(sp)
    800000bc:	7402                	ld	s0,32(sp)
    800000be:	64e2                	ld	s1,24(sp)
    800000c0:	6942                	ld	s2,16(sp)
    800000c2:	69a2                	ld	s3,8(sp)
    800000c4:	6a02                	ld	s4,0(sp)
    800000c6:	6145                	addi	sp,sp,48
    800000c8:	8082                	ret

00000000800000ca <kinit>:
{
    800000ca:	1141                	addi	sp,sp,-16
    800000cc:	e406                	sd	ra,8(sp)
    800000ce:	e022                	sd	s0,0(sp)
    800000d0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    800000d2:	00003597          	auipc	a1,0x3
    800000d6:	f3658593          	addi	a1,a1,-202 # 80003008 <etext+0x8>
    800000da:	00003517          	auipc	a0,0x3
    800000de:	40650513          	addi	a0,a0,1030 # 800034e0 <kmem>
    800000e2:	167000ef          	jal	ra,80000a48 <initlock>
  freerange(end, (void*)PHYSTOP);
    800000e6:	45c5                	li	a1,17
    800000e8:	05ee                	slli	a1,a1,0x1b
    800000ea:	0000e517          	auipc	a0,0xe
    800000ee:	28650513          	addi	a0,a0,646 # 8000e370 <end>
    800000f2:	f91ff0ef          	jal	ra,80000082 <freerange>
}
    800000f6:	60a2                	ld	ra,8(sp)
    800000f8:	6402                	ld	s0,0(sp)
    800000fa:	0141                	addi	sp,sp,16
    800000fc:	8082                	ret

00000000800000fe <kalloc>:
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
// 分配物理页面，返回的应该是物理地址，用Junk初始化分配的物理页面
void *
kalloc(void)
{
    800000fe:	1101                	addi	sp,sp,-32
    80000100:	ec06                	sd	ra,24(sp)
    80000102:	e822                	sd	s0,16(sp)
    80000104:	e426                	sd	s1,8(sp)
    80000106:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000108:	00003497          	auipc	s1,0x3
    8000010c:	3d848493          	addi	s1,s1,984 # 800034e0 <kmem>
    80000110:	8526                	mv	a0,s1
    80000112:	1b7000ef          	jal	ra,80000ac8 <acquire>
  r = kmem.freelist;
    80000116:	6c84                	ld	s1,24(s1)
  if(r)
    80000118:	c485                	beqz	s1,80000140 <kalloc+0x42>
    kmem.freelist = r->next;
    8000011a:	609c                	ld	a5,0(s1)
    8000011c:	00003517          	auipc	a0,0x3
    80000120:	3c450513          	addi	a0,a0,964 # 800034e0 <kmem>
    80000124:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000126:	23b000ef          	jal	ra,80000b60 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    8000012a:	6605                	lui	a2,0x1
    8000012c:	4595                	li	a1,5
    8000012e:	8526                	mv	a0,s1
    80000130:	321000ef          	jal	ra,80000c50 <memset>
  return (void*)r;
}
    80000134:	8526                	mv	a0,s1
    80000136:	60e2                	ld	ra,24(sp)
    80000138:	6442                	ld	s0,16(sp)
    8000013a:	64a2                	ld	s1,8(sp)
    8000013c:	6105                	addi	sp,sp,32
    8000013e:	8082                	ret
  release(&kmem.lock);
    80000140:	00003517          	auipc	a0,0x3
    80000144:	3a050513          	addi	a0,a0,928 # 800034e0 <kmem>
    80000148:	219000ef          	jal	ra,80000b60 <release>
  if(r)
    8000014c:	b7e5                	j	80000134 <kalloc+0x36>
	...

0000000080000150 <kernelvec>:
    80000150:	7111                	addi	sp,sp,-256
    80000152:	e006                	sd	ra,0(sp)
    80000154:	e40a                	sd	sp,8(sp)
    80000156:	e80e                	sd	gp,16(sp)
    80000158:	ec12                	sd	tp,24(sp)
    8000015a:	f016                	sd	t0,32(sp)
    8000015c:	f41a                	sd	t1,40(sp)
    8000015e:	f81e                	sd	t2,48(sp)
    80000160:	e4aa                	sd	a0,72(sp)
    80000162:	e8ae                	sd	a1,80(sp)
    80000164:	ecb2                	sd	a2,88(sp)
    80000166:	f0b6                	sd	a3,96(sp)
    80000168:	f4ba                	sd	a4,104(sp)
    8000016a:	f8be                	sd	a5,112(sp)
    8000016c:	fcc2                	sd	a6,120(sp)
    8000016e:	e146                	sd	a7,128(sp)
    80000170:	edf2                	sd	t3,216(sp)
    80000172:	f1f6                	sd	t4,224(sp)
    80000174:	f5fa                	sd	t5,232(sp)
    80000176:	f9fe                	sd	t6,240(sp)
    80000178:	739000ef          	jal	ra,800010b0 <kerneltrap>
    8000017c:	6082                	ld	ra,0(sp)
    8000017e:	6122                	ld	sp,8(sp)
    80000180:	61c2                	ld	gp,16(sp)
    80000182:	7282                	ld	t0,32(sp)
    80000184:	7322                	ld	t1,40(sp)
    80000186:	73c2                	ld	t2,48(sp)
    80000188:	6526                	ld	a0,72(sp)
    8000018a:	65c6                	ld	a1,80(sp)
    8000018c:	6666                	ld	a2,88(sp)
    8000018e:	7686                	ld	a3,96(sp)
    80000190:	7726                	ld	a4,104(sp)
    80000192:	77c6                	ld	a5,112(sp)
    80000194:	7866                	ld	a6,120(sp)
    80000196:	688a                	ld	a7,128(sp)
    80000198:	6e6e                	ld	t3,216(sp)
    8000019a:	7e8e                	ld	t4,224(sp)
    8000019c:	7f2e                	ld	t5,232(sp)
    8000019e:	7fce                	ld	t6,240(sp)
    800001a0:	6111                	addi	sp,sp,256
    800001a2:	10200073          	sret
	...

00000000800001ae <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    800001ae:	1141                	addi	sp,sp,-16
    800001b0:	e406                	sd	ra,8(sp)
    800001b2:	e022                	sd	s0,0(sp)
    800001b4:	0800                	addi	s0,sp,16
  // 主核进行的初始化部分
  if(cpuid() == 0){
    800001b6:	57e000ef          	jal	ra,80000734 <cpuid>
    //started = 1;
    // 修改了userinit()和started=1的位置
    userinit();

  } else {
    while(started == 0)
    800001ba:	00003717          	auipc	a4,0x3
    800001be:	2f670713          	addi	a4,a4,758 # 800034b0 <started>
  if(cpuid() == 0){
    800001c2:	cd05                	beqz	a0,800001fa <main+0x4c>
    while(started == 0)
    800001c4:	431c                	lw	a5,0(a4)
    800001c6:	2781                	sext.w	a5,a5
    800001c8:	dff5                	beqz	a5,800001c4 <main+0x16>
      ;
    __sync_synchronize();
    800001ca:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    800001ce:	566000ef          	jal	ra,80000734 <cpuid>
    800001d2:	85aa                	mv	a1,a0
    800001d4:	00003517          	auipc	a0,0x3
    800001d8:	e7450513          	addi	a0,a0,-396 # 80003048 <etext+0x48>
    800001dc:	1de000ef          	jal	ra,800003ba <printf>
    
    // 内存处理部分
    kvminithart();    // turn on paging
    800001e0:	026010ef          	jal	ra,80001206 <kvminithart>

    // 中断处理部分
    trapinithart();   // install kernel trap vector
    800001e4:	49d000ef          	jal	ra,80000e80 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    800001e8:	094000ef          	jal	ra,8000027c <plicinithart>

static inline uint64
r_sstatus()
{
  uint64 x;
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800001ec:	100027f3          	csrr	a5,sstatus

// enable device interrupts
static inline void
intr_on()
{
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800001f0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800001f4:	10079073          	csrw	sstatus,a5
  }
  //while(1) ;
  //scheduler();        
  intr_on(); // 开放中断
  while(1) ; // 其余的CPU都会陷入这个死循环
    800001f8:	a001                	j	800001f8 <main+0x4a>
    uartinit();
    800001fa:	735000ef          	jal	ra,8000112e <uartinit>
    printfinit();
    800001fe:	4aa000ef          	jal	ra,800006a8 <printfinit>
    printf("\n");
    80000202:	00003517          	auipc	a0,0x3
    80000206:	e5650513          	addi	a0,a0,-426 # 80003058 <etext+0x58>
    8000020a:	1b0000ef          	jal	ra,800003ba <printf>
    printf("xv6 kernel is booting\n");
    8000020e:	00003517          	auipc	a0,0x3
    80000212:	e0250513          	addi	a0,a0,-510 # 80003010 <etext+0x10>
    80000216:	1a4000ef          	jal	ra,800003ba <printf>
    printf("\n");
    8000021a:	00003517          	auipc	a0,0x3
    8000021e:	e3e50513          	addi	a0,a0,-450 # 80003058 <etext+0x58>
    80000222:	198000ef          	jal	ra,800003ba <printf>
    kinit();         // physical page allocator
    80000226:	ea5ff0ef          	jal	ra,800000ca <kinit>
    kvminit();       // create kernel page table
    8000022a:	216010ef          	jal	ra,80001440 <kvminit>
    kvminithart();   // turn on paging
    8000022e:	7d9000ef          	jal	ra,80001206 <kvminithart>
    procinit();      // 这里做了修改，只对一个进程进行了初始化
    80000232:	4e0000ef          	jal	ra,80000712 <procinit>
    printf("xv6 passed the procinit()\n");
    80000236:	00003517          	auipc	a0,0x3
    8000023a:	df250513          	addi	a0,a0,-526 # 80003028 <etext+0x28>
    8000023e:	17c000ef          	jal	ra,800003ba <printf>
    trapinit();      // trap vectors
    80000242:	41b000ef          	jal	ra,80000e5c <trapinit>
    trapinithart();  // install kernel trap vector
    80000246:	43b000ef          	jal	ra,80000e80 <trapinithart>
    plicinit();      // set up interrupt controller
    8000024a:	01c000ef          	jal	ra,80000266 <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000024e:	02e000ef          	jal	ra,8000027c <plicinithart>
    started = 1;
    80000252:	4785                	li	a5,1
    80000254:	00003717          	auipc	a4,0x3
    80000258:	24f72e23          	sw	a5,604(a4) # 800034b0 <started>
    __sync_synchronize();
    8000025c:	0ff0000f          	fence
    userinit();
    80000260:	616000ef          	jal	ra,80000876 <userinit>
    80000264:	b761                	j	800001ec <main+0x3e>

0000000080000266 <plicinit>:
// // the riscv Platform Level Interrupt Controller (PLIC).
// //

void
plicinit(void)
{
    80000266:	1141                	addi	sp,sp,-16
    80000268:	e422                	sd	s0,8(sp)
    8000026a:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    8000026c:	0c0007b7          	lui	a5,0xc000
    80000270:	4705                	li	a4,1
    80000272:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80000274:	c3d8                	sw	a4,4(a5)
}
    80000276:	6422                	ld	s0,8(sp)
    80000278:	0141                	addi	sp,sp,16
    8000027a:	8082                	ret

000000008000027c <plicinithart>:

void
plicinithart(void)
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80000284:	4b0000ef          	jal	ra,80000734 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80000288:	0085171b          	slliw	a4,a0,0x8
    8000028c:	0c0027b7          	lui	a5,0xc002
    80000290:	97ba                	add	a5,a5,a4
    80000292:	40200713          	li	a4,1026
    80000296:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    8000029a:	00d5151b          	slliw	a0,a0,0xd
    8000029e:	0c2017b7          	lui	a5,0xc201
    800002a2:	97aa                	add	a5,a5,a0
    800002a4:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800002a8:	60a2                	ld	ra,8(sp)
    800002aa:	6402                	ld	s0,0(sp)
    800002ac:	0141                	addi	sp,sp,16
    800002ae:	8082                	ret

00000000800002b0 <plic_claim>:

// ask the PLIC what interrupt we should serve.
// 从PLIC取出当前哪个设备发出了中断，返回设备的IRQ号
int
plic_claim(void)
{
    800002b0:	1141                	addi	sp,sp,-16
    800002b2:	e406                	sd	ra,8(sp)
    800002b4:	e022                	sd	s0,0(sp)
    800002b6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800002b8:	47c000ef          	jal	ra,80000734 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800002bc:	00d5151b          	slliw	a0,a0,0xd
    800002c0:	0c2017b7          	lui	a5,0xc201
    800002c4:	97aa                	add	a5,a5,a0
  return irq;
}
    800002c6:	43c8                	lw	a0,4(a5)
    800002c8:	60a2                	ld	ra,8(sp)
    800002ca:	6402                	ld	s0,0(sp)
    800002cc:	0141                	addi	sp,sp,16
    800002ce:	8082                	ret

00000000800002d0 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800002d0:	1101                	addi	sp,sp,-32
    800002d2:	ec06                	sd	ra,24(sp)
    800002d4:	e822                	sd	s0,16(sp)
    800002d6:	e426                	sd	s1,8(sp)
    800002d8:	1000                	addi	s0,sp,32
    800002da:	84aa                	mv	s1,a0
  int hart = cpuid();
    800002dc:	458000ef          	jal	ra,80000734 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800002e0:	00d5151b          	slliw	a0,a0,0xd
    800002e4:	0c2017b7          	lui	a5,0xc201
    800002e8:	97aa                	add	a5,a5,a0
    800002ea:	c3c4                	sw	s1,4(a5)
}
    800002ec:	60e2                	ld	ra,24(sp)
    800002ee:	6442                	ld	s0,16(sp)
    800002f0:	64a2                	ld	s1,8(sp)
    800002f2:	6105                	addi	sp,sp,32
    800002f4:	8082                	ret

00000000800002f6 <pputc>:
////////////////////////////
// 这个函数添加用于替代console.c中的consputc()函数 后续需要的话将pputc修改回来
# define BACKSPACE 0x100
void
pputc(int c)
{
    800002f6:	1141                	addi	sp,sp,-16
    800002f8:	e406                	sd	ra,8(sp)
    800002fa:	e022                	sd	s0,0(sp)
    800002fc:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    800002fe:	10000793          	li	a5,256
    80000302:	00f50863          	beq	a0,a5,80000312 <pputc+0x1c>
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
  }
  else
  {
    uartputc_sync(c);
    80000306:	675000ef          	jal	ra,8000117a <uartputc_sync>
  }
}
    8000030a:	60a2                	ld	ra,8(sp)
    8000030c:	6402                	ld	s0,0(sp)
    8000030e:	0141                	addi	sp,sp,16
    80000310:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000312:	4521                	li	a0,8
    80000314:	667000ef          	jal	ra,8000117a <uartputc_sync>
    80000318:	02000513          	li	a0,32
    8000031c:	65f000ef          	jal	ra,8000117a <uartputc_sync>
    80000320:	4521                	li	a0,8
    80000322:	659000ef          	jal	ra,8000117a <uartputc_sync>
    80000326:	b7d5                	j	8000030a <pputc+0x14>

0000000080000328 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000328:	7179                	addi	sp,sp,-48
    8000032a:	f406                	sd	ra,40(sp)
    8000032c:	f022                	sd	s0,32(sp)
    8000032e:	ec26                	sd	s1,24(sp)
    80000330:	e84a                	sd	s2,16(sp)
    80000332:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000334:	c219                	beqz	a2,8000033a <printint+0x12>
    80000336:	06054e63          	bltz	a0,800003b2 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000033a:	4881                	li	a7,0
    8000033c:	fd040693          	addi	a3,s0,-48

  i = 0;
    80000340:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000342:	00003617          	auipc	a2,0x3
    80000346:	d3e60613          	addi	a2,a2,-706 # 80003080 <digits>
    8000034a:	883e                	mv	a6,a5
    8000034c:	2785                	addiw	a5,a5,1 # c201001 <_entry-0x73dfefff>
    8000034e:	02b57733          	remu	a4,a0,a1
    80000352:	9732                	add	a4,a4,a2
    80000354:	00074703          	lbu	a4,0(a4)
    80000358:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    8000035c:	872a                	mv	a4,a0
    8000035e:	02b55533          	divu	a0,a0,a1
    80000362:	0685                	addi	a3,a3,1
    80000364:	feb773e3          	bgeu	a4,a1,8000034a <printint+0x22>

  if(sign)
    80000368:	00088a63          	beqz	a7,8000037c <printint+0x54>
    buf[i++] = '-';
    8000036c:	1781                	addi	a5,a5,-32
    8000036e:	97a2                	add	a5,a5,s0
    80000370:	02d00713          	li	a4,45
    80000374:	fee78823          	sb	a4,-16(a5)
    80000378:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    8000037c:	02f05563          	blez	a5,800003a6 <printint+0x7e>
    80000380:	fd040713          	addi	a4,s0,-48
    80000384:	00f704b3          	add	s1,a4,a5
    80000388:	fff70913          	addi	s2,a4,-1
    8000038c:	993e                	add	s2,s2,a5
    8000038e:	37fd                	addiw	a5,a5,-1
    80000390:	1782                	slli	a5,a5,0x20
    80000392:	9381                	srli	a5,a5,0x20
    80000394:	40f90933          	sub	s2,s2,a5
    //consputc(buf[i]);
    pputc(buf[i]);
    80000398:	fff4c503          	lbu	a0,-1(s1)
    8000039c:	f5bff0ef          	jal	ra,800002f6 <pputc>
  while(--i >= 0)
    800003a0:	14fd                	addi	s1,s1,-1
    800003a2:	ff249be3          	bne	s1,s2,80000398 <printint+0x70>
}
    800003a6:	70a2                	ld	ra,40(sp)
    800003a8:	7402                	ld	s0,32(sp)
    800003aa:	64e2                	ld	s1,24(sp)
    800003ac:	6942                	ld	s2,16(sp)
    800003ae:	6145                	addi	sp,sp,48
    800003b0:	8082                	ret
    x = -xx;
    800003b2:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800003b6:	4885                	li	a7,1
    x = -xx;
    800003b8:	b751                	j	8000033c <printint+0x14>

00000000800003ba <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800003ba:	7155                	addi	sp,sp,-208
    800003bc:	e506                	sd	ra,136(sp)
    800003be:	e122                	sd	s0,128(sp)
    800003c0:	fca6                	sd	s1,120(sp)
    800003c2:	f8ca                	sd	s2,112(sp)
    800003c4:	f4ce                	sd	s3,104(sp)
    800003c6:	f0d2                	sd	s4,96(sp)
    800003c8:	ecd6                	sd	s5,88(sp)
    800003ca:	e8da                	sd	s6,80(sp)
    800003cc:	e4de                	sd	s7,72(sp)
    800003ce:	e0e2                	sd	s8,64(sp)
    800003d0:	fc66                	sd	s9,56(sp)
    800003d2:	f86a                	sd	s10,48(sp)
    800003d4:	f46e                	sd	s11,40(sp)
    800003d6:	0900                	addi	s0,sp,144
    800003d8:	8a2a                	mv	s4,a0
    800003da:	e40c                	sd	a1,8(s0)
    800003dc:	e810                	sd	a2,16(s0)
    800003de:	ec14                	sd	a3,24(s0)
    800003e0:	f018                	sd	a4,32(s0)
    800003e2:	f41c                	sd	a5,40(s0)
    800003e4:	03043823          	sd	a6,48(s0)
    800003e8:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800003ec:	00003797          	auipc	a5,0x3
    800003f0:	12c7a783          	lw	a5,300(a5) # 80003518 <pr+0x18>
    800003f4:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800003f8:	eb9d                	bnez	a5,8000042e <printf+0x74>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800003fa:	00840793          	addi	a5,s0,8
    800003fe:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000402:	00054503          	lbu	a0,0(a0)
    80000406:	24050463          	beqz	a0,8000064e <printf+0x294>
    8000040a:	4981                	li	s3,0
    if(cx != '%'){
    8000040c:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000410:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    80000414:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80000418:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    8000041c:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000420:	07000d93          	li	s11,112
    pputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000424:	00003b97          	auipc	s7,0x3
    80000428:	c5cb8b93          	addi	s7,s7,-932 # 80003080 <digits>
    8000042c:	a081                	j	8000046c <printf+0xb2>
    acquire(&pr.lock);
    8000042e:	00003517          	auipc	a0,0x3
    80000432:	0d250513          	addi	a0,a0,210 # 80003500 <pr>
    80000436:	692000ef          	jal	ra,80000ac8 <acquire>
  va_start(ap, fmt);
    8000043a:	00840793          	addi	a5,s0,8
    8000043e:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000442:	000a4503          	lbu	a0,0(s4) # fffffffffffff000 <end+0xffffffff7fff0c90>
    80000446:	f171                	bnez	a0,8000040a <printf+0x50>
#endif
  }
  va_end(ap);

  if(locking)
    release(&pr.lock);
    80000448:	00003517          	auipc	a0,0x3
    8000044c:	0b850513          	addi	a0,a0,184 # 80003500 <pr>
    80000450:	710000ef          	jal	ra,80000b60 <release>
    80000454:	aaed                	j	8000064e <printf+0x294>
      pputc(cx);
    80000456:	ea1ff0ef          	jal	ra,800002f6 <pputc>
      continue;
    8000045a:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000045c:	0014899b          	addiw	s3,s1,1
    80000460:	013a07b3          	add	a5,s4,s3
    80000464:	0007c503          	lbu	a0,0(a5)
    80000468:	1c050f63          	beqz	a0,80000646 <printf+0x28c>
    if(cx != '%'){
    8000046c:	ff5515e3          	bne	a0,s5,80000456 <printf+0x9c>
    i++;
    80000470:	0019849b          	addiw	s1,s3,1 # 1001 <_entry-0x7fffefff>
    c0 = fmt[i+0] & 0xff;
    80000474:	009a07b3          	add	a5,s4,s1
    80000478:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000047c:	1c090563          	beqz	s2,80000646 <printf+0x28c>
    80000480:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000484:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000486:	c789                	beqz	a5,80000490 <printf+0xd6>
    80000488:	009a0733          	add	a4,s4,s1
    8000048c:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80000490:	03690463          	beq	s2,s6,800004b8 <printf+0xfe>
    } else if(c0 == 'l' && c1 == 'd'){
    80000494:	03890e63          	beq	s2,s8,800004d0 <printf+0x116>
    } else if(c0 == 'u'){
    80000498:	0b990d63          	beq	s2,s9,80000552 <printf+0x198>
    } else if(c0 == 'x'){
    8000049c:	11a90363          	beq	s2,s10,800005a2 <printf+0x1e8>
    } else if(c0 == 'p'){
    800004a0:	13b90b63          	beq	s2,s11,800005d6 <printf+0x21c>
    } else if(c0 == 's'){
    800004a4:	07300793          	li	a5,115
    800004a8:	16f90363          	beq	s2,a5,8000060e <printf+0x254>
    } else if(c0 == '%'){
    800004ac:	03591c63          	bne	s2,s5,800004e4 <printf+0x12a>
      pputc('%');
    800004b0:	8556                	mv	a0,s5
    800004b2:	e45ff0ef          	jal	ra,800002f6 <pputc>
    800004b6:	b75d                	j	8000045c <printf+0xa2>
      printint(va_arg(ap, int), 10, 1);
    800004b8:	f8843783          	ld	a5,-120(s0)
    800004bc:	00878713          	addi	a4,a5,8
    800004c0:	f8e43423          	sd	a4,-120(s0)
    800004c4:	4605                	li	a2,1
    800004c6:	45a9                	li	a1,10
    800004c8:	4388                	lw	a0,0(a5)
    800004ca:	e5fff0ef          	jal	ra,80000328 <printint>
    800004ce:	b779                	j	8000045c <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'd'){
    800004d0:	03678163          	beq	a5,s6,800004f2 <printf+0x138>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800004d4:	03878d63          	beq	a5,s8,8000050e <printf+0x154>
    } else if(c0 == 'l' && c1 == 'u'){
    800004d8:	09978963          	beq	a5,s9,8000056a <printf+0x1b0>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800004dc:	03878b63          	beq	a5,s8,80000512 <printf+0x158>
    } else if(c0 == 'l' && c1 == 'x'){
    800004e0:	0da78d63          	beq	a5,s10,800005ba <printf+0x200>
      pputc('%');
    800004e4:	8556                	mv	a0,s5
    800004e6:	e11ff0ef          	jal	ra,800002f6 <pputc>
      pputc(c0);
    800004ea:	854a                	mv	a0,s2
    800004ec:	e0bff0ef          	jal	ra,800002f6 <pputc>
    800004f0:	b7b5                	j	8000045c <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    800004f2:	f8843783          	ld	a5,-120(s0)
    800004f6:	00878713          	addi	a4,a5,8
    800004fa:	f8e43423          	sd	a4,-120(s0)
    800004fe:	4605                	li	a2,1
    80000500:	45a9                	li	a1,10
    80000502:	6388                	ld	a0,0(a5)
    80000504:	e25ff0ef          	jal	ra,80000328 <printint>
      i += 1;
    80000508:	0029849b          	addiw	s1,s3,2
    8000050c:	bf81                	j	8000045c <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000050e:	03668463          	beq	a3,s6,80000536 <printf+0x17c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000512:	07968a63          	beq	a3,s9,80000586 <printf+0x1cc>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    80000516:	fda697e3          	bne	a3,s10,800004e4 <printf+0x12a>
      printint(va_arg(ap, uint64), 16, 0);
    8000051a:	f8843783          	ld	a5,-120(s0)
    8000051e:	00878713          	addi	a4,a5,8
    80000522:	f8e43423          	sd	a4,-120(s0)
    80000526:	4601                	li	a2,0
    80000528:	45c1                	li	a1,16
    8000052a:	6388                	ld	a0,0(a5)
    8000052c:	dfdff0ef          	jal	ra,80000328 <printint>
      i += 2;
    80000530:	0039849b          	addiw	s1,s3,3
    80000534:	b725                	j	8000045c <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    80000536:	f8843783          	ld	a5,-120(s0)
    8000053a:	00878713          	addi	a4,a5,8
    8000053e:	f8e43423          	sd	a4,-120(s0)
    80000542:	4605                	li	a2,1
    80000544:	45a9                	li	a1,10
    80000546:	6388                	ld	a0,0(a5)
    80000548:	de1ff0ef          	jal	ra,80000328 <printint>
      i += 2;
    8000054c:	0039849b          	addiw	s1,s3,3
    80000550:	b731                	j	8000045c <printf+0xa2>
      printint(va_arg(ap, int), 10, 0);
    80000552:	f8843783          	ld	a5,-120(s0)
    80000556:	00878713          	addi	a4,a5,8
    8000055a:	f8e43423          	sd	a4,-120(s0)
    8000055e:	4601                	li	a2,0
    80000560:	45a9                	li	a1,10
    80000562:	4388                	lw	a0,0(a5)
    80000564:	dc5ff0ef          	jal	ra,80000328 <printint>
    80000568:	bdd5                	j	8000045c <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    8000056a:	f8843783          	ld	a5,-120(s0)
    8000056e:	00878713          	addi	a4,a5,8
    80000572:	f8e43423          	sd	a4,-120(s0)
    80000576:	4601                	li	a2,0
    80000578:	45a9                	li	a1,10
    8000057a:	6388                	ld	a0,0(a5)
    8000057c:	dadff0ef          	jal	ra,80000328 <printint>
      i += 1;
    80000580:	0029849b          	addiw	s1,s3,2
    80000584:	bde1                	j	8000045c <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    80000586:	f8843783          	ld	a5,-120(s0)
    8000058a:	00878713          	addi	a4,a5,8
    8000058e:	f8e43423          	sd	a4,-120(s0)
    80000592:	4601                	li	a2,0
    80000594:	45a9                	li	a1,10
    80000596:	6388                	ld	a0,0(a5)
    80000598:	d91ff0ef          	jal	ra,80000328 <printint>
      i += 2;
    8000059c:	0039849b          	addiw	s1,s3,3
    800005a0:	bd75                	j	8000045c <printf+0xa2>
      printint(va_arg(ap, int), 16, 0);
    800005a2:	f8843783          	ld	a5,-120(s0)
    800005a6:	00878713          	addi	a4,a5,8
    800005aa:	f8e43423          	sd	a4,-120(s0)
    800005ae:	4601                	li	a2,0
    800005b0:	45c1                	li	a1,16
    800005b2:	4388                	lw	a0,0(a5)
    800005b4:	d75ff0ef          	jal	ra,80000328 <printint>
    800005b8:	b555                	j	8000045c <printf+0xa2>
      printint(va_arg(ap, uint64), 16, 0);
    800005ba:	f8843783          	ld	a5,-120(s0)
    800005be:	00878713          	addi	a4,a5,8
    800005c2:	f8e43423          	sd	a4,-120(s0)
    800005c6:	4601                	li	a2,0
    800005c8:	45c1                	li	a1,16
    800005ca:	6388                	ld	a0,0(a5)
    800005cc:	d5dff0ef          	jal	ra,80000328 <printint>
      i += 1;
    800005d0:	0029849b          	addiw	s1,s3,2
    800005d4:	b561                	j	8000045c <printf+0xa2>
      printptr(va_arg(ap, uint64));
    800005d6:	f8843783          	ld	a5,-120(s0)
    800005da:	00878713          	addi	a4,a5,8
    800005de:	f8e43423          	sd	a4,-120(s0)
    800005e2:	0007b983          	ld	s3,0(a5)
  pputc('0');
    800005e6:	03000513          	li	a0,48
    800005ea:	d0dff0ef          	jal	ra,800002f6 <pputc>
  pputc('x');
    800005ee:	856a                	mv	a0,s10
    800005f0:	d07ff0ef          	jal	ra,800002f6 <pputc>
    800005f4:	4941                	li	s2,16
    pputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005f6:	03c9d793          	srli	a5,s3,0x3c
    800005fa:	97de                	add	a5,a5,s7
    800005fc:	0007c503          	lbu	a0,0(a5)
    80000600:	cf7ff0ef          	jal	ra,800002f6 <pputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000604:	0992                	slli	s3,s3,0x4
    80000606:	397d                	addiw	s2,s2,-1
    80000608:	fe0917e3          	bnez	s2,800005f6 <printf+0x23c>
    8000060c:	bd81                	j	8000045c <printf+0xa2>
      if((s = va_arg(ap, char*)) == 0)
    8000060e:	f8843783          	ld	a5,-120(s0)
    80000612:	00878713          	addi	a4,a5,8
    80000616:	f8e43423          	sd	a4,-120(s0)
    8000061a:	0007b903          	ld	s2,0(a5)
    8000061e:	00090d63          	beqz	s2,80000638 <printf+0x27e>
      for(; *s; s++)
    80000622:	00094503          	lbu	a0,0(s2)
    80000626:	e2050be3          	beqz	a0,8000045c <printf+0xa2>
        pputc(*s);
    8000062a:	ccdff0ef          	jal	ra,800002f6 <pputc>
      for(; *s; s++)
    8000062e:	0905                	addi	s2,s2,1
    80000630:	00094503          	lbu	a0,0(s2)
    80000634:	f97d                	bnez	a0,8000062a <printf+0x270>
    80000636:	b51d                	j	8000045c <printf+0xa2>
        s = "(null)";
    80000638:	00003917          	auipc	s2,0x3
    8000063c:	a2890913          	addi	s2,s2,-1496 # 80003060 <etext+0x60>
      for(; *s; s++)
    80000640:	02800513          	li	a0,40
    80000644:	b7dd                	j	8000062a <printf+0x270>
  if(locking)
    80000646:	f7843783          	ld	a5,-136(s0)
    8000064a:	de079fe3          	bnez	a5,80000448 <printf+0x8e>

  return 0;
}
    8000064e:	4501                	li	a0,0
    80000650:	60aa                	ld	ra,136(sp)
    80000652:	640a                	ld	s0,128(sp)
    80000654:	74e6                	ld	s1,120(sp)
    80000656:	7946                	ld	s2,112(sp)
    80000658:	79a6                	ld	s3,104(sp)
    8000065a:	7a06                	ld	s4,96(sp)
    8000065c:	6ae6                	ld	s5,88(sp)
    8000065e:	6b46                	ld	s6,80(sp)
    80000660:	6ba6                	ld	s7,72(sp)
    80000662:	6c06                	ld	s8,64(sp)
    80000664:	7ce2                	ld	s9,56(sp)
    80000666:	7d42                	ld	s10,48(sp)
    80000668:	7da2                	ld	s11,40(sp)
    8000066a:	6169                	addi	sp,sp,208
    8000066c:	8082                	ret

000000008000066e <panic>:

void
panic(char *s)
{
    8000066e:	1101                	addi	sp,sp,-32
    80000670:	ec06                	sd	ra,24(sp)
    80000672:	e822                	sd	s0,16(sp)
    80000674:	e426                	sd	s1,8(sp)
    80000676:	1000                	addi	s0,sp,32
    80000678:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000067a:	00003797          	auipc	a5,0x3
    8000067e:	e807af23          	sw	zero,-354(a5) # 80003518 <pr+0x18>
  printf("panic: ");
    80000682:	00003517          	auipc	a0,0x3
    80000686:	9e650513          	addi	a0,a0,-1562 # 80003068 <etext+0x68>
    8000068a:	d31ff0ef          	jal	ra,800003ba <printf>
  printf("%s\n", s);
    8000068e:	85a6                	mv	a1,s1
    80000690:	00003517          	auipc	a0,0x3
    80000694:	9e050513          	addi	a0,a0,-1568 # 80003070 <etext+0x70>
    80000698:	d23ff0ef          	jal	ra,800003ba <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000069c:	4785                	li	a5,1
    8000069e:	00003717          	auipc	a4,0x3
    800006a2:	e0f72b23          	sw	a5,-490(a4) # 800034b4 <panicked>
  for(;;)
    800006a6:	a001                	j	800006a6 <panic+0x38>

00000000800006a8 <printfinit>:
    ;
}

void
printfinit(void)
{
    800006a8:	1101                	addi	sp,sp,-32
    800006aa:	ec06                	sd	ra,24(sp)
    800006ac:	e822                	sd	s0,16(sp)
    800006ae:	e426                	sd	s1,8(sp)
    800006b0:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800006b2:	00003497          	auipc	s1,0x3
    800006b6:	e4e48493          	addi	s1,s1,-434 # 80003500 <pr>
    800006ba:	00003597          	auipc	a1,0x3
    800006be:	9be58593          	addi	a1,a1,-1602 # 80003078 <etext+0x78>
    800006c2:	8526                	mv	a0,s1
    800006c4:	384000ef          	jal	ra,80000a48 <initlock>

   // 使用printf.c直接替代console.c中的打印函数，需要在这里初始化串口

  pr.locking = 1;
    800006c8:	4785                	li	a5,1
    800006ca:	cc9c                	sw	a5,24(s1)
}
    800006cc:	60e2                	ld	ra,24(sp)
    800006ce:	6442                	ld	s0,16(sp)
    800006d0:	64a2                	ld	s1,8(sp)
    800006d2:	6105                	addi	sp,sp,32
    800006d4:	8082                	ret

00000000800006d6 <proc_mapstacks>:
// Map it high in memory, followed by an invalid
// guard page.
// 原来是将所有进程分配的栈记录在内核页表上面，现在只有一个proc结构体
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800006d6:	1101                	addi	sp,sp,-32
    800006d8:	ec06                	sd	ra,24(sp)
    800006da:	e822                	sd	s0,16(sp)
    800006dc:	e426                	sd	s1,8(sp)
    800006de:	1000                	addi	s0,sp,32
    800006e0:	84aa                	mv	s1,a0
  //   uint64 va = KSTACK((int) (p - proc));
  //   kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
  // }

  struct proc *p = proc;
  char *pa = kalloc();
    800006e2:	a1dff0ef          	jal	ra,800000fe <kalloc>
  if(pa == 0)
    800006e6:	c105                	beqz	a0,80000706 <proc_mapstacks+0x30>
    800006e8:	862a                	mv	a2,a0
    panic("kalloc");
  uint64 va = KSTACK((int) (p - proc));
  kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800006ea:	4719                	li	a4,6
    800006ec:	6685                	lui	a3,0x1
    800006ee:	040005b7          	lui	a1,0x4000
    800006f2:	15f5                	addi	a1,a1,-3 # 3fffffd <_entry-0x7c000003>
    800006f4:	05b2                	slli	a1,a1,0xc
    800006f6:	8526                	mv	a0,s1
    800006f8:	481000ef          	jal	ra,80001378 <kvmmap>
}
    800006fc:	60e2                	ld	ra,24(sp)
    800006fe:	6442                	ld	s0,16(sp)
    80000700:	64a2                	ld	s1,8(sp)
    80000702:	6105                	addi	sp,sp,32
    80000704:	8082                	ret
    panic("kalloc");
    80000706:	00003517          	auipc	a0,0x3
    8000070a:	99250513          	addi	a0,a0,-1646 # 80003098 <digits+0x18>
    8000070e:	f61ff0ef          	jal	ra,8000066e <panic>

0000000080000712 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80000712:	1141                	addi	sp,sp,-16
    80000714:	e422                	sd	s0,8(sp)
    80000716:	0800                	addi	s0,sp,16

  // struct proc *p = &proc;
  // p->state = UNUSED;
  // p->kstack = KSTACK((int)0);
  p = proc;
  p -> state = UNUSED;
    80000718:	00003717          	auipc	a4,0x3
    8000071c:	20870713          	addi	a4,a4,520 # 80003920 <proc>
    80000720:	00072023          	sw	zero,0(a4)
  p->kstack = KSTACK((int)(p-proc));
    80000724:	040007b7          	lui	a5,0x4000
    80000728:	17f5                	addi	a5,a5,-3 # 3fffffd <_entry-0x7c000003>
    8000072a:	07b2                	slli	a5,a5,0xc
    8000072c:	e71c                	sd	a5,8(a4)
}
    8000072e:	6422                	ld	s0,8(sp)
    80000730:	0141                	addi	sp,sp,16
    80000732:	8082                	ret

0000000080000734 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80000734:	1141                	addi	sp,sp,-16
    80000736:	e422                	sd	s0,8(sp)
    80000738:	0800                	addi	s0,sp,16
// this core's hartid (core number), the index into cpus[].
static inline uint64
r_tp()
{
  uint64 x;
  asm volatile("mv %0, tp" : "=r" (x) );
    8000073a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000073c:	2501                	sext.w	a0,a0
    8000073e:	6422                	ld	s0,8(sp)
    80000740:	0141                	addi	sp,sp,16
    80000742:	8082                	ret

0000000080000744 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80000744:	1141                	addi	sp,sp,-16
    80000746:	e422                	sd	s0,8(sp)
    80000748:	0800                	addi	s0,sp,16
    8000074a:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    8000074c:	2781                	sext.w	a5,a5
    8000074e:	079e                	slli	a5,a5,0x7
  //printf("测试用：进入了mycpu()\n");
  return c;
}
    80000750:	00003517          	auipc	a0,0x3
    80000754:	dd050513          	addi	a0,a0,-560 # 80003520 <cpus>
    80000758:	953e                	add	a0,a0,a5
    8000075a:	6422                	ld	s0,8(sp)
    8000075c:	0141                	addi	sp,sp,16
    8000075e:	8082                	ret

0000000080000760 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80000760:	1101                	addi	sp,sp,-32
    80000762:	ec06                	sd	ra,24(sp)
    80000764:	e822                	sd	s0,16(sp)
    80000766:	e426                	sd	s1,8(sp)
    80000768:	1000                	addi	s0,sp,32
  push_off();
    8000076a:	31e000ef          	jal	ra,80000a88 <push_off>
    8000076e:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000770:	2781                	sext.w	a5,a5
    80000772:	079e                	slli	a5,a5,0x7
    80000774:	00003717          	auipc	a4,0x3
    80000778:	dac70713          	addi	a4,a4,-596 # 80003520 <cpus>
    8000077c:	97ba                	add	a5,a5,a4
    8000077e:	6384                	ld	s1,0(a5)
  pop_off();
    80000780:	38c000ef          	jal	ra,80000b0c <pop_off>
  return p;
}
    80000784:	8526                	mv	a0,s1
    80000786:	60e2                	ld	ra,24(sp)
    80000788:	6442                	ld	s0,16(sp)
    8000078a:	64a2                	ld	s1,8(sp)
    8000078c:	6105                	addi	sp,sp,32
    8000078e:	8082                	ret

0000000080000790 <allocpid>:

int
allocpid()
{
    80000790:	1141                	addi	sp,sp,-16
    80000792:	e422                	sd	s0,8(sp)
    80000794:	0800                	addi	s0,sp,16
  int pid;
  
  // 现在只有一个进程，所以这个锁不需要
  // acquire(&pid_lock);
  pid = nextpid;
    80000796:	00003797          	auipc	a5,0x3
    8000079a:	caa78793          	addi	a5,a5,-854 # 80003440 <nextpid>
    8000079e:	4388                	lw	a0,0(a5)
  nextpid = nextpid + 1;
    800007a0:	0015071b          	addiw	a4,a0,1
    800007a4:	c398                	sw	a4,0(a5)
  // release(&pid_lock);

  return pid;
}
    800007a6:	6422                	ld	s0,8(sp)
    800007a8:	0141                	addi	sp,sp,16
    800007aa:	8082                	ret

00000000800007ac <proc_pagetable>:

// Create a user page table for a given process, with no user memory,
// but with trampoline and trapframe pages.
pagetable_t
proc_pagetable(struct proc *p)
{
    800007ac:	1101                	addi	sp,sp,-32
    800007ae:	ec06                	sd	ra,24(sp)
    800007b0:	e822                	sd	s0,16(sp)
    800007b2:	e426                	sd	s1,8(sp)
    800007b4:	e04a                	sd	s2,0(sp)
    800007b6:	1000                	addi	s0,sp,32
    800007b8:	892a                	mv	s2,a0
  pagetable_t pagetable;

  // An empty page table.
  pagetable = uvmcreate();
    800007ba:	54f000ef          	jal	ra,80001508 <uvmcreate>
    800007be:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800007c0:	cd05                	beqz	a0,800007f8 <proc_pagetable+0x4c>

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    800007c2:	4729                	li	a4,10
    800007c4:	00002697          	auipc	a3,0x2
    800007c8:	83c68693          	addi	a3,a3,-1988 # 80002000 <_trampoline>
    800007cc:	6605                	lui	a2,0x1
    800007ce:	040005b7          	lui	a1,0x4000
    800007d2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800007d4:	05b2                	slli	a1,a1,0xc
    800007d6:	2f3000ef          	jal	ra,800012c8 <mappages>
    800007da:	02054663          	bltz	a0,80000806 <proc_pagetable+0x5a>
    return 0;
  }

  // map the trapframe page just below the trampoline page, for
  // trampoline.S.
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800007de:	4719                	li	a4,6
    800007e0:	02093683          	ld	a3,32(s2)
    800007e4:	6605                	lui	a2,0x1
    800007e6:	020005b7          	lui	a1,0x2000
    800007ea:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800007ec:	05b6                	slli	a1,a1,0xd
    800007ee:	8526                	mv	a0,s1
    800007f0:	2d9000ef          	jal	ra,800012c8 <mappages>
    800007f4:	00054f63          	bltz	a0,80000812 <proc_pagetable+0x66>
    uvmfree(pagetable, 0);
    return 0;
  }

  return pagetable;
}
    800007f8:	8526                	mv	a0,s1
    800007fa:	60e2                	ld	ra,24(sp)
    800007fc:	6442                	ld	s0,16(sp)
    800007fe:	64a2                	ld	s1,8(sp)
    80000800:	6902                	ld	s2,0(sp)
    80000802:	6105                	addi	sp,sp,32
    80000804:	8082                	ret
    uvmfree(pagetable, 0);
    80000806:	4581                	li	a1,0
    80000808:	8526                	mv	a0,s1
    8000080a:	5e3000ef          	jal	ra,800015ec <uvmfree>
    return 0;
    8000080e:	4481                	li	s1,0
    80000810:	b7e5                	j	800007f8 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000812:	4681                	li	a3,0
    80000814:	4605                	li	a2,1
    80000816:	040005b7          	lui	a1,0x4000
    8000081a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000081c:	05b2                	slli	a1,a1,0xc
    8000081e:	8526                	mv	a0,s1
    80000820:	43d000ef          	jal	ra,8000145c <uvmunmap>
    uvmfree(pagetable, 0);
    80000824:	4581                	li	a1,0
    80000826:	8526                	mv	a0,s1
    80000828:	5c5000ef          	jal	ra,800015ec <uvmfree>
    return 0;
    8000082c:	4481                	li	s1,0
    8000082e:	b7e9                	j	800007f8 <proc_pagetable+0x4c>

0000000080000830 <proc_freepagetable>:

// Free a process's page table, and free the
// physical memory it refers to.
void
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
    80000830:	1101                	addi	sp,sp,-32
    80000832:	ec06                	sd	ra,24(sp)
    80000834:	e822                	sd	s0,16(sp)
    80000836:	e426                	sd	s1,8(sp)
    80000838:	e04a                	sd	s2,0(sp)
    8000083a:	1000                	addi	s0,sp,32
    8000083c:	84aa                	mv	s1,a0
    8000083e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000840:	4681                	li	a3,0
    80000842:	4605                	li	a2,1
    80000844:	040005b7          	lui	a1,0x4000
    80000848:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000084a:	05b2                	slli	a1,a1,0xc
    8000084c:	411000ef          	jal	ra,8000145c <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80000850:	4681                	li	a3,0
    80000852:	4605                	li	a2,1
    80000854:	020005b7          	lui	a1,0x2000
    80000858:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    8000085a:	05b6                	slli	a1,a1,0xd
    8000085c:	8526                	mv	a0,s1
    8000085e:	3ff000ef          	jal	ra,8000145c <uvmunmap>
  uvmfree(pagetable, sz);
    80000862:	85ca                	mv	a1,s2
    80000864:	8526                	mv	a0,s1
    80000866:	587000ef          	jal	ra,800015ec <uvmfree>
}
    8000086a:	60e2                	ld	ra,24(sp)
    8000086c:	6442                	ld	s0,16(sp)
    8000086e:	64a2                	ld	s1,8(sp)
    80000870:	6902                	ld	s2,0(sp)
    80000872:	6105                	addi	sp,sp,32
    80000874:	8082                	ret

0000000080000876 <userinit>:

// Set up first user process.
// 这个应该是第一个用户进程的初始化  我的存在问题的代码
void
userinit(void)
{
    80000876:	1101                	addi	sp,sp,-32
    80000878:	ec06                	sd	ra,24(sp)
    8000087a:	e822                	sd	s0,16(sp)
    8000087c:	e426                	sd	s1,8(sp)
    8000087e:	e04a                	sd	s2,0(sp)
    80000880:	1000                	addi	s0,sp,32
  if(p->state == UNUSED){
    80000882:	00003797          	auipc	a5,0x3
    80000886:	09e7a783          	lw	a5,158(a5) # 80003920 <proc>
  return 0;
    8000088a:	4481                	li	s1,0
  if(p->state == UNUSED){
    8000088c:	0e078e63          	beqz	a5,80000988 <userinit+0x112>
  struct proc *p;

  p = allocproc();
  initproc = p;
    80000890:	00003797          	auipc	a5,0x3
    80000894:	c297b423          	sd	s1,-984(a5) # 800034b8 <initproc>
  
  // allocate one user page and copy initcode's instructions
  // and data into it.
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80000898:	03800613          	li	a2,56
    8000089c:	00003597          	auipc	a1,0x3
    800008a0:	bb458593          	addi	a1,a1,-1100 # 80003450 <initcode>
    800008a4:	6c88                	ld	a0,24(s1)
    800008a6:	489000ef          	jal	ra,8000152e <uvmfirst>
  p->sz = 4*PGSIZE;
    800008aa:	6791                	lui	a5,0x4
    800008ac:	e89c                	sd	a5,16(s1)
  // 全局数据页1
  char* mem1 = kalloc();
    800008ae:	851ff0ef          	jal	ra,800000fe <kalloc>
    800008b2:	892a                	mv	s2,a0
  if(mem1 == 0)
    800008b4:	12050d63          	beqz	a0,800009ee <userinit+0x178>
    panic("userinit: out of memory for global data page1");
  memset(mem1,0,PGSIZE);
    800008b8:	6605                	lui	a2,0x1
    800008ba:	4581                	li	a1,0
    800008bc:	394000ef          	jal	ra,80000c50 <memset>
  if(mappages(p->pagetable,PGSIZE,PGSIZE,(uint64)mem1,PTE_W|PTE_R|PTE_U) < 0)
    800008c0:	4759                	li	a4,22
    800008c2:	86ca                	mv	a3,s2
    800008c4:	6605                	lui	a2,0x1
    800008c6:	6585                	lui	a1,0x1
    800008c8:	6c88                	ld	a0,24(s1)
    800008ca:	1ff000ef          	jal	ra,800012c8 <mappages>
    800008ce:	12054663          	bltz	a0,800009fa <userinit+0x184>
  {
    kfree(mem1);
    panic("userinit: can't map global data page 1");
  }
  // 全局数据页2
  char* mem2 = kalloc();
    800008d2:	82dff0ef          	jal	ra,800000fe <kalloc>
    800008d6:	892a                	mv	s2,a0
  if(mem2 == 0)
    800008d8:	12050a63          	beqz	a0,80000a0c <userinit+0x196>
    panic("userinit: out of memory for global data page2");
  memset(mem2,0,PGSIZE);
    800008dc:	6605                	lui	a2,0x1
    800008de:	4581                	li	a1,0
    800008e0:	370000ef          	jal	ra,80000c50 <memset>
  if(mappages(p->pagetable,2*PGSIZE,PGSIZE,(uint64)mem2,PTE_W|PTE_R|PTE_U) < 0)
    800008e4:	4759                	li	a4,22
    800008e6:	86ca                	mv	a3,s2
    800008e8:	6605                	lui	a2,0x1
    800008ea:	6589                	lui	a1,0x2
    800008ec:	6c88                	ld	a0,24(s1)
    800008ee:	1db000ef          	jal	ra,800012c8 <mappages>
    800008f2:	12054363          	bltz	a0,80000a18 <userinit+0x1a2>
  {
    kfree(mem2);
    panic("userinit: can't map global data page 2");
  }
  // 栈
  char *stack = kalloc();
    800008f6:	809ff0ef          	jal	ra,800000fe <kalloc>
    800008fa:	892a                	mv	s2,a0
  if(stack == 0)
    800008fc:	12050763          	beqz	a0,80000a2a <userinit+0x1b4>
    panic("userinit: out of memory for stack");
  memset(stack, 0, PGSIZE);  // 栈也初始化为0
    80000900:	6605                	lui	a2,0x1
    80000902:	4581                	li	a1,0
    80000904:	34c000ef          	jal	ra,80000c50 <memset>
  if(mappages(p->pagetable, 3*PGSIZE, PGSIZE, (uint64)stack, PTE_W|PTE_R|PTE_U) < 0){
    80000908:	4759                	li	a4,22
    8000090a:	86ca                	mv	a3,s2
    8000090c:	6605                	lui	a2,0x1
    8000090e:	658d                	lui	a1,0x3
    80000910:	6c88                	ld	a0,24(s1)
    80000912:	1b7000ef          	jal	ra,800012c8 <mappages>
    80000916:	12054063          	bltz	a0,80000a36 <userinit+0x1c0>
    kfree(stack);
    panic("userinit: can't map stack page");
  }

  // prepare for the very first "return" from kernel to user.
  p->trapframe->epc = 0;      // user program counter
    8000091a:	709c                	ld	a5,32(s1)
    8000091c:	0007bc23          	sd	zero,24(a5) # 4018 <_entry-0x7fffbfe8>
  p->trapframe->sp = 4*PGSIZE;  // user stack pointer
    80000920:	709c                	ld	a5,32(s1)
    80000922:	6711                	lui	a4,0x4
    80000924:	fb98                	sd	a4,48(a5)

  memset(&p->context, 0, sizeof(p->context));
    80000926:	02848913          	addi	s2,s1,40
    8000092a:	07000613          	li	a2,112
    8000092e:	4581                	li	a1,0
    80000930:	854a                	mv	a0,s2
    80000932:	31e000ef          	jal	ra,80000c50 <memset>
  //p->context.ra = (uint64)usertrapret;
  p->context.sp = p->kstack + PGSIZE; 
    80000936:	649c                	ld	a5,8(s1)
    80000938:	6705                	lui	a4,0x1
    8000093a:	97ba                	add	a5,a5,a4
    8000093c:	f89c                	sd	a5,48(s1)
  p->context.ra = (uint64)usertrapret;
    8000093e:	00000797          	auipc	a5,0x0
    80000942:	55a78793          	addi	a5,a5,1370 # 80000e98 <usertrapret>
    80000946:	f49c                	sd	a5,40(s1)
  

  safestrcpy(p->name, "initcode", sizeof(p->name));
    80000948:	4641                	li	a2,16
    8000094a:	00003597          	auipc	a1,0x3
    8000094e:	84e58593          	addi	a1,a1,-1970 # 80003198 <digits+0x118>
    80000952:	09848513          	addi	a0,s1,152
    80000956:	440000ef          	jal	ra,80000d96 <safestrcpy>
  // 不知道这个有没有用，这个好像涉及到了文件，现在先注释
  // p->cwd = namei("/");

  p->state = RUNNABLE; 
    8000095a:	478d                	li	a5,3
    8000095c:	c09c                	sw	a5,0(s1)
    8000095e:	8792                	mv	a5,tp
  int id = r_tp();
    80000960:	2781                	sext.w	a5,a5

  // release(&p->lock);

  struct cpu *c = mycpu();
  c->proc = p;
    80000962:	00003517          	auipc	a0,0x3
    80000966:	bbe50513          	addi	a0,a0,-1090 # 80003520 <cpus>
    8000096a:	079e                	slli	a5,a5,0x7
    8000096c:	00f50733          	add	a4,a0,a5
    80000970:	e304                	sd	s1,0(a4)
  swtch(&(c->context),&(p->context));
    80000972:	07a1                	addi	a5,a5,8
    80000974:	85ca                	mv	a1,s2
    80000976:	953e                	add	a0,a0,a5
    80000978:	47a000ef          	jal	ra,80000df2 <swtch>
}
    8000097c:	60e2                	ld	ra,24(sp)
    8000097e:	6442                	ld	s0,16(sp)
    80000980:	64a2                	ld	s1,8(sp)
    80000982:	6902                	ld	s2,0(sp)
    80000984:	6105                	addi	sp,sp,32
    80000986:	8082                	ret
  p->pid = allocpid();
    80000988:	e09ff0ef          	jal	ra,80000790 <allocpid>
    8000098c:	00003917          	auipc	s2,0x3
    80000990:	f9490913          	addi	s2,s2,-108 # 80003920 <proc>
    80000994:	00a92223          	sw	a0,4(s2)
  p->state = USED;
    80000998:	4785                	li	a5,1
    8000099a:	00f92023          	sw	a5,0(s2)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    8000099e:	f60ff0ef          	jal	ra,800000fe <kalloc>
    800009a2:	84aa                	mv	s1,a0
    800009a4:	02a93023          	sd	a0,32(s2)
    800009a8:	ee0504e3          	beqz	a0,80000890 <userinit+0x1a>
  p->pagetable = proc_pagetable(p);
    800009ac:	854a                	mv	a0,s2
    800009ae:	dffff0ef          	jal	ra,800007ac <proc_pagetable>
    800009b2:	84aa                	mv	s1,a0
    800009b4:	00003797          	auipc	a5,0x3
    800009b8:	f8a7b223          	sd	a0,-124(a5) # 80003938 <proc+0x18>
  if(p->pagetable == 0){
    800009bc:	ec050ae3          	beqz	a0,80000890 <userinit+0x1a>
  memset(&p->context, 0, sizeof(p->context));
    800009c0:	07000613          	li	a2,112
    800009c4:	4581                	li	a1,0
    800009c6:	00003517          	auipc	a0,0x3
    800009ca:	f8250513          	addi	a0,a0,-126 # 80003948 <proc+0x28>
    800009ce:	282000ef          	jal	ra,80000c50 <memset>
  p->context.ra = (uint64)usertrapret; // 这样做完我的首进程的返回地址就是usertrapret
    800009d2:	84ca                	mv	s1,s2
    800009d4:	00000797          	auipc	a5,0x0
    800009d8:	4c478793          	addi	a5,a5,1220 # 80000e98 <usertrapret>
    800009dc:	02f93423          	sd	a5,40(s2)
  p->context.sp = p->kstack + PGSIZE;
    800009e0:	00893783          	ld	a5,8(s2)
    800009e4:	6705                	lui	a4,0x1
    800009e6:	97ba                	add	a5,a5,a4
    800009e8:	02f93823          	sd	a5,48(s2)
  return p;
    800009ec:	b555                	j	80000890 <userinit+0x1a>
    panic("userinit: out of memory for global data page1");
    800009ee:	00002517          	auipc	a0,0x2
    800009f2:	6b250513          	addi	a0,a0,1714 # 800030a0 <digits+0x20>
    800009f6:	c79ff0ef          	jal	ra,8000066e <panic>
    kfree(mem1);
    800009fa:	854a                	mv	a0,s2
    800009fc:	e20ff0ef          	jal	ra,8000001c <kfree>
    panic("userinit: can't map global data page 1");
    80000a00:	00002517          	auipc	a0,0x2
    80000a04:	6d050513          	addi	a0,a0,1744 # 800030d0 <digits+0x50>
    80000a08:	c67ff0ef          	jal	ra,8000066e <panic>
    panic("userinit: out of memory for global data page2");
    80000a0c:	00002517          	auipc	a0,0x2
    80000a10:	6ec50513          	addi	a0,a0,1772 # 800030f8 <digits+0x78>
    80000a14:	c5bff0ef          	jal	ra,8000066e <panic>
    kfree(mem2);
    80000a18:	854a                	mv	a0,s2
    80000a1a:	e02ff0ef          	jal	ra,8000001c <kfree>
    panic("userinit: can't map global data page 2");
    80000a1e:	00002517          	auipc	a0,0x2
    80000a22:	70a50513          	addi	a0,a0,1802 # 80003128 <digits+0xa8>
    80000a26:	c49ff0ef          	jal	ra,8000066e <panic>
    panic("userinit: out of memory for stack");
    80000a2a:	00002517          	auipc	a0,0x2
    80000a2e:	72650513          	addi	a0,a0,1830 # 80003150 <digits+0xd0>
    80000a32:	c3dff0ef          	jal	ra,8000066e <panic>
    kfree(stack);
    80000a36:	854a                	mv	a0,s2
    80000a38:	de4ff0ef          	jal	ra,8000001c <kfree>
    panic("userinit: can't map stack page");
    80000a3c:	00002517          	auipc	a0,0x2
    80000a40:	73c50513          	addi	a0,a0,1852 # 80003178 <digits+0xf8>
    80000a44:	c2bff0ef          	jal	ra,8000066e <panic>

0000000080000a48 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000a48:	1141                	addi	sp,sp,-16
    80000a4a:	e422                	sd	s0,8(sp)
    80000a4c:	0800                	addi	s0,sp,16
  lk->name = name;
    80000a4e:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000a50:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000a54:	00053823          	sd	zero,16(a0)
}
    80000a58:	6422                	ld	s0,8(sp)
    80000a5a:	0141                	addi	sp,sp,16
    80000a5c:	8082                	ret

0000000080000a5e <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000a5e:	411c                	lw	a5,0(a0)
    80000a60:	e399                	bnez	a5,80000a66 <holding+0x8>
    80000a62:	4501                	li	a0,0
  return r;
}
    80000a64:	8082                	ret
{
    80000a66:	1101                	addi	sp,sp,-32
    80000a68:	ec06                	sd	ra,24(sp)
    80000a6a:	e822                	sd	s0,16(sp)
    80000a6c:	e426                	sd	s1,8(sp)
    80000a6e:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000a70:	6904                	ld	s1,16(a0)
    80000a72:	cd3ff0ef          	jal	ra,80000744 <mycpu>
    80000a76:	40a48533          	sub	a0,s1,a0
    80000a7a:	00153513          	seqz	a0,a0
}
    80000a7e:	60e2                	ld	ra,24(sp)
    80000a80:	6442                	ld	s0,16(sp)
    80000a82:	64a2                	ld	s1,8(sp)
    80000a84:	6105                	addi	sp,sp,32
    80000a86:	8082                	ret

0000000080000a88 <push_off>:
// are initially off, then push_off, pop_off leaves them off.

// 这个涉及到进程方面，先注释掉
void
push_off(void)
{
    80000a88:	1101                	addi	sp,sp,-32
    80000a8a:	ec06                	sd	ra,24(sp)
    80000a8c:	e822                	sd	s0,16(sp)
    80000a8e:	e426                	sd	s1,8(sp)
    80000a90:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000a92:	100024f3          	csrr	s1,sstatus
    80000a96:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000a9a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000a9c:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000aa0:	ca5ff0ef          	jal	ra,80000744 <mycpu>
    80000aa4:	5d3c                	lw	a5,120(a0)
    80000aa6:	cb99                	beqz	a5,80000abc <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000aa8:	c9dff0ef          	jal	ra,80000744 <mycpu>
    80000aac:	5d3c                	lw	a5,120(a0)
    80000aae:	2785                	addiw	a5,a5,1
    80000ab0:	dd3c                	sw	a5,120(a0)
}
    80000ab2:	60e2                	ld	ra,24(sp)
    80000ab4:	6442                	ld	s0,16(sp)
    80000ab6:	64a2                	ld	s1,8(sp)
    80000ab8:	6105                	addi	sp,sp,32
    80000aba:	8082                	ret
    mycpu()->intena = old;
    80000abc:	c89ff0ef          	jal	ra,80000744 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000ac0:	8085                	srli	s1,s1,0x1
    80000ac2:	8885                	andi	s1,s1,1
    80000ac4:	dd64                	sw	s1,124(a0)
    80000ac6:	b7cd                	j	80000aa8 <push_off+0x20>

0000000080000ac8 <acquire>:
{
    80000ac8:	1101                	addi	sp,sp,-32
    80000aca:	ec06                	sd	ra,24(sp)
    80000acc:	e822                	sd	s0,16(sp)
    80000ace:	e426                	sd	s1,8(sp)
    80000ad0:	1000                	addi	s0,sp,32
    80000ad2:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000ad4:	fb5ff0ef          	jal	ra,80000a88 <push_off>
  if(holding(lk))
    80000ad8:	8526                	mv	a0,s1
    80000ada:	f85ff0ef          	jal	ra,80000a5e <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000ade:	4705                	li	a4,1
  if(holding(lk))
    80000ae0:	e105                	bnez	a0,80000b00 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000ae2:	87ba                	mv	a5,a4
    80000ae4:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000ae8:	2781                	sext.w	a5,a5
    80000aea:	ffe5                	bnez	a5,80000ae2 <acquire+0x1a>
  __sync_synchronize();
    80000aec:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000af0:	c55ff0ef          	jal	ra,80000744 <mycpu>
    80000af4:	e888                	sd	a0,16(s1)
}
    80000af6:	60e2                	ld	ra,24(sp)
    80000af8:	6442                	ld	s0,16(sp)
    80000afa:	64a2                	ld	s1,8(sp)
    80000afc:	6105                	addi	sp,sp,32
    80000afe:	8082                	ret
    panic("acquire");
    80000b00:	00002517          	auipc	a0,0x2
    80000b04:	6a850513          	addi	a0,a0,1704 # 800031a8 <digits+0x128>
    80000b08:	b67ff0ef          	jal	ra,8000066e <panic>

0000000080000b0c <pop_off>:

void
pop_off(void)
{
    80000b0c:	1141                	addi	sp,sp,-16
    80000b0e:	e406                	sd	ra,8(sp)
    80000b10:	e022                	sd	s0,0(sp)
    80000b12:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000b14:	c31ff0ef          	jal	ra,80000744 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b18:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000b1c:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000b1e:	e78d                	bnez	a5,80000b48 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000b20:	5d3c                	lw	a5,120(a0)
    80000b22:	02f05963          	blez	a5,80000b54 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000b26:	37fd                	addiw	a5,a5,-1
    80000b28:	0007871b          	sext.w	a4,a5
    80000b2c:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000b2e:	eb09                	bnez	a4,80000b40 <pop_off+0x34>
    80000b30:	5d7c                	lw	a5,124(a0)
    80000b32:	c799                	beqz	a5,80000b40 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b34:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000b38:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b3c:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000b40:	60a2                	ld	ra,8(sp)
    80000b42:	6402                	ld	s0,0(sp)
    80000b44:	0141                	addi	sp,sp,16
    80000b46:	8082                	ret
    panic("pop_off - interruptible");
    80000b48:	00002517          	auipc	a0,0x2
    80000b4c:	66850513          	addi	a0,a0,1640 # 800031b0 <digits+0x130>
    80000b50:	b1fff0ef          	jal	ra,8000066e <panic>
    panic("pop_off");
    80000b54:	00002517          	auipc	a0,0x2
    80000b58:	67450513          	addi	a0,a0,1652 # 800031c8 <digits+0x148>
    80000b5c:	b13ff0ef          	jal	ra,8000066e <panic>

0000000080000b60 <release>:
{
    80000b60:	1101                	addi	sp,sp,-32
    80000b62:	ec06                	sd	ra,24(sp)
    80000b64:	e822                	sd	s0,16(sp)
    80000b66:	e426                	sd	s1,8(sp)
    80000b68:	1000                	addi	s0,sp,32
    80000b6a:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000b6c:	ef3ff0ef          	jal	ra,80000a5e <holding>
    80000b70:	c105                	beqz	a0,80000b90 <release+0x30>
  lk->cpu = 0;
    80000b72:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000b76:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000b7a:	0f50000f          	fence	iorw,ow
    80000b7e:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000b82:	f8bff0ef          	jal	ra,80000b0c <pop_off>
}
    80000b86:	60e2                	ld	ra,24(sp)
    80000b88:	6442                	ld	s0,16(sp)
    80000b8a:	64a2                	ld	s1,8(sp)
    80000b8c:	6105                	addi	sp,sp,32
    80000b8e:	8082                	ret
    panic("release");
    80000b90:	00002517          	auipc	a0,0x2
    80000b94:	64050513          	addi	a0,a0,1600 # 800031d0 <digits+0x150>
    80000b98:	ad7ff0ef          	jal	ra,8000066e <panic>

0000000080000b9c <timerinit>:

// ask each hart to generate timer interrupts.
// 设备驱动程序
void
timerinit()
{
    80000b9c:	1141                	addi	sp,sp,-16
    80000b9e:	e422                	sd	s0,8(sp)
    80000ba0:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000ba2:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  // 使能S模式下的定时器中断
  w_mie(r_mie() | MIE_STIE);
    80000ba6:	0207e793          	ori	a5,a5,32
  asm volatile("csrw mie, %0" : : "r" (x));
    80000baa:	30479073          	csrw	mie,a5
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80000bae:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  // 使能sstc扩展
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000bb2:	577d                	li	a4,-1
    80000bb4:	177e                	slli	a4,a4,0x3f
    80000bb6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000bb8:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    80000bbc:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  // 允许s模式下访问计数器
  w_mcounteren(r_mcounteren() | 2);
    80000bc0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000bc4:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    80000bc8:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  // 设置下一个定时器中断的时间点
  w_stimecmp(r_time() + 1000000);
    80000bcc:	000f4737          	lui	a4,0xf4
    80000bd0:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000bd4:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000bd6:	14d79073          	csrw	0x14d,a5
}
    80000bda:	6422                	ld	s0,8(sp)
    80000bdc:	0141                	addi	sp,sp,16
    80000bde:	8082                	ret

0000000080000be0 <start>:
{
    80000be0:	1141                	addi	sp,sp,-16
    80000be2:	e406                	sd	ra,8(sp)
    80000be4:	e022                	sd	s0,0(sp)
    80000be6:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000be8:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK; // MSTATUS_MPP_MASK 是MPP字段的掩码（表示上一次特权级）
    80000bec:	7779                	lui	a4,0xffffe
    80000bee:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fff048f>
    80000bf2:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S; // 先清楚MPP字段，在设置为S（Supervisor）模式
    80000bf4:	6705                	lui	a4,0x1
    80000bf6:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80000bfa:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000bfc:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000c00:	fffff797          	auipc	a5,0xfffff
    80000c04:	5ae78793          	addi	a5,a5,1454 # 800001ae <main>
    80000c08:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80000c0c:	4781                	li	a5,0
    80000c0e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000c12:	67c1                	lui	a5,0x10
    80000c14:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000c16:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80000c1a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80000c1e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80000c22:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80000c26:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80000c2a:	57fd                	li	a5,-1
    80000c2c:	83a9                	srli	a5,a5,0xa
    80000c2e:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80000c32:	47bd                	li	a5,15
    80000c34:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80000c38:	f65ff0ef          	jal	ra,80000b9c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000c3c:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    80000c40:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    80000c42:	823e                	mv	tp,a5
  asm volatile("mret"); 
    80000c44:	30200073          	mret
}
    80000c48:	60a2                	ld	ra,8(sp)
    80000c4a:	6402                	ld	s0,0(sp)
    80000c4c:	0141                	addi	sp,sp,16
    80000c4e:	8082                	ret

0000000080000c50 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000c50:	1141                	addi	sp,sp,-16
    80000c52:	e422                	sd	s0,8(sp)
    80000c54:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000c56:	ca19                	beqz	a2,80000c6c <memset+0x1c>
    80000c58:	87aa                	mv	a5,a0
    80000c5a:	1602                	slli	a2,a2,0x20
    80000c5c:	9201                	srli	a2,a2,0x20
    80000c5e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000c62:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000c66:	0785                	addi	a5,a5,1
    80000c68:	fee79de3          	bne	a5,a4,80000c62 <memset+0x12>
  }
  return dst;
}
    80000c6c:	6422                	ld	s0,8(sp)
    80000c6e:	0141                	addi	sp,sp,16
    80000c70:	8082                	ret

0000000080000c72 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000c72:	1141                	addi	sp,sp,-16
    80000c74:	e422                	sd	s0,8(sp)
    80000c76:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000c78:	ca05                	beqz	a2,80000ca8 <memcmp+0x36>
    80000c7a:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000c7e:	1682                	slli	a3,a3,0x20
    80000c80:	9281                	srli	a3,a3,0x20
    80000c82:	0685                	addi	a3,a3,1
    80000c84:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000c86:	00054783          	lbu	a5,0(a0)
    80000c8a:	0005c703          	lbu	a4,0(a1)
    80000c8e:	00e79863          	bne	a5,a4,80000c9e <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000c92:	0505                	addi	a0,a0,1
    80000c94:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000c96:	fed518e3          	bne	a0,a3,80000c86 <memcmp+0x14>
  }

  return 0;
    80000c9a:	4501                	li	a0,0
    80000c9c:	a019                	j	80000ca2 <memcmp+0x30>
      return *s1 - *s2;
    80000c9e:	40e7853b          	subw	a0,a5,a4
}
    80000ca2:	6422                	ld	s0,8(sp)
    80000ca4:	0141                	addi	sp,sp,16
    80000ca6:	8082                	ret
  return 0;
    80000ca8:	4501                	li	a0,0
    80000caa:	bfe5                	j	80000ca2 <memcmp+0x30>

0000000080000cac <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000cac:	1141                	addi	sp,sp,-16
    80000cae:	e422                	sd	s0,8(sp)
    80000cb0:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000cb2:	c205                	beqz	a2,80000cd2 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000cb4:	02a5e263          	bltu	a1,a0,80000cd8 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000cb8:	1602                	slli	a2,a2,0x20
    80000cba:	9201                	srli	a2,a2,0x20
    80000cbc:	00c587b3          	add	a5,a1,a2
{
    80000cc0:	872a                	mv	a4,a0
      *d++ = *s++;
    80000cc2:	0585                	addi	a1,a1,1
    80000cc4:	0705                	addi	a4,a4,1
    80000cc6:	fff5c683          	lbu	a3,-1(a1)
    80000cca:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000cce:	fef59ae3          	bne	a1,a5,80000cc2 <memmove+0x16>

  return dst;
}
    80000cd2:	6422                	ld	s0,8(sp)
    80000cd4:	0141                	addi	sp,sp,16
    80000cd6:	8082                	ret
  if(s < d && s + n > d){
    80000cd8:	02061693          	slli	a3,a2,0x20
    80000cdc:	9281                	srli	a3,a3,0x20
    80000cde:	00d58733          	add	a4,a1,a3
    80000ce2:	fce57be3          	bgeu	a0,a4,80000cb8 <memmove+0xc>
    d += n;
    80000ce6:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000ce8:	fff6079b          	addiw	a5,a2,-1
    80000cec:	1782                	slli	a5,a5,0x20
    80000cee:	9381                	srli	a5,a5,0x20
    80000cf0:	fff7c793          	not	a5,a5
    80000cf4:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000cf6:	177d                	addi	a4,a4,-1
    80000cf8:	16fd                	addi	a3,a3,-1
    80000cfa:	00074603          	lbu	a2,0(a4)
    80000cfe:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d02:	fee79ae3          	bne	a5,a4,80000cf6 <memmove+0x4a>
    80000d06:	b7f1                	j	80000cd2 <memmove+0x26>

0000000080000d08 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d08:	1141                	addi	sp,sp,-16
    80000d0a:	e406                	sd	ra,8(sp)
    80000d0c:	e022                	sd	s0,0(sp)
    80000d0e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d10:	f9dff0ef          	jal	ra,80000cac <memmove>
}
    80000d14:	60a2                	ld	ra,8(sp)
    80000d16:	6402                	ld	s0,0(sp)
    80000d18:	0141                	addi	sp,sp,16
    80000d1a:	8082                	ret

0000000080000d1c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d1c:	1141                	addi	sp,sp,-16
    80000d1e:	e422                	sd	s0,8(sp)
    80000d20:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d22:	ce11                	beqz	a2,80000d3e <strncmp+0x22>
    80000d24:	00054783          	lbu	a5,0(a0)
    80000d28:	cf89                	beqz	a5,80000d42 <strncmp+0x26>
    80000d2a:	0005c703          	lbu	a4,0(a1)
    80000d2e:	00f71a63          	bne	a4,a5,80000d42 <strncmp+0x26>
    n--, p++, q++;
    80000d32:	367d                	addiw	a2,a2,-1
    80000d34:	0505                	addi	a0,a0,1
    80000d36:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000d38:	f675                	bnez	a2,80000d24 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000d3a:	4501                	li	a0,0
    80000d3c:	a809                	j	80000d4e <strncmp+0x32>
    80000d3e:	4501                	li	a0,0
    80000d40:	a039                	j	80000d4e <strncmp+0x32>
  if(n == 0)
    80000d42:	ca09                	beqz	a2,80000d54 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000d44:	00054503          	lbu	a0,0(a0)
    80000d48:	0005c783          	lbu	a5,0(a1)
    80000d4c:	9d1d                	subw	a0,a0,a5
}
    80000d4e:	6422                	ld	s0,8(sp)
    80000d50:	0141                	addi	sp,sp,16
    80000d52:	8082                	ret
    return 0;
    80000d54:	4501                	li	a0,0
    80000d56:	bfe5                	j	80000d4e <strncmp+0x32>

0000000080000d58 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000d58:	1141                	addi	sp,sp,-16
    80000d5a:	e422                	sd	s0,8(sp)
    80000d5c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000d5e:	872a                	mv	a4,a0
    80000d60:	8832                	mv	a6,a2
    80000d62:	367d                	addiw	a2,a2,-1
    80000d64:	01005963          	blez	a6,80000d76 <strncpy+0x1e>
    80000d68:	0705                	addi	a4,a4,1
    80000d6a:	0005c783          	lbu	a5,0(a1)
    80000d6e:	fef70fa3          	sb	a5,-1(a4)
    80000d72:	0585                	addi	a1,a1,1
    80000d74:	f7f5                	bnez	a5,80000d60 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000d76:	86ba                	mv	a3,a4
    80000d78:	00c05c63          	blez	a2,80000d90 <strncpy+0x38>
    *s++ = 0;
    80000d7c:	0685                	addi	a3,a3,1
    80000d7e:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000d82:	40d707bb          	subw	a5,a4,a3
    80000d86:	37fd                	addiw	a5,a5,-1
    80000d88:	010787bb          	addw	a5,a5,a6
    80000d8c:	fef048e3          	bgtz	a5,80000d7c <strncpy+0x24>
  return os;
}
    80000d90:	6422                	ld	s0,8(sp)
    80000d92:	0141                	addi	sp,sp,16
    80000d94:	8082                	ret

0000000080000d96 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000d96:	1141                	addi	sp,sp,-16
    80000d98:	e422                	sd	s0,8(sp)
    80000d9a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000d9c:	02c05363          	blez	a2,80000dc2 <safestrcpy+0x2c>
    80000da0:	fff6069b          	addiw	a3,a2,-1
    80000da4:	1682                	slli	a3,a3,0x20
    80000da6:	9281                	srli	a3,a3,0x20
    80000da8:	96ae                	add	a3,a3,a1
    80000daa:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000dac:	00d58963          	beq	a1,a3,80000dbe <safestrcpy+0x28>
    80000db0:	0585                	addi	a1,a1,1
    80000db2:	0785                	addi	a5,a5,1
    80000db4:	fff5c703          	lbu	a4,-1(a1)
    80000db8:	fee78fa3          	sb	a4,-1(a5)
    80000dbc:	fb65                	bnez	a4,80000dac <safestrcpy+0x16>
    ;
  *s = 0;
    80000dbe:	00078023          	sb	zero,0(a5)
  return os;
}
    80000dc2:	6422                	ld	s0,8(sp)
    80000dc4:	0141                	addi	sp,sp,16
    80000dc6:	8082                	ret

0000000080000dc8 <strlen>:

int
strlen(const char *s)
{
    80000dc8:	1141                	addi	sp,sp,-16
    80000dca:	e422                	sd	s0,8(sp)
    80000dcc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000dce:	00054783          	lbu	a5,0(a0)
    80000dd2:	cf91                	beqz	a5,80000dee <strlen+0x26>
    80000dd4:	0505                	addi	a0,a0,1
    80000dd6:	87aa                	mv	a5,a0
    80000dd8:	4685                	li	a3,1
    80000dda:	9e89                	subw	a3,a3,a0
    80000ddc:	00f6853b          	addw	a0,a3,a5
    80000de0:	0785                	addi	a5,a5,1
    80000de2:	fff7c703          	lbu	a4,-1(a5)
    80000de6:	fb7d                	bnez	a4,80000ddc <strlen+0x14>
    ;
  return n;
}
    80000de8:	6422                	ld	s0,8(sp)
    80000dea:	0141                	addi	sp,sp,16
    80000dec:	8082                	ret
  for(n = 0; s[n]; n++)
    80000dee:	4501                	li	a0,0
    80000df0:	bfe5                	j	80000de8 <strlen+0x20>

0000000080000df2 <swtch>:
    80000df2:	00153023          	sd	ra,0(a0)
    80000df6:	00253423          	sd	sp,8(a0)
    80000dfa:	e900                	sd	s0,16(a0)
    80000dfc:	ed04                	sd	s1,24(a0)
    80000dfe:	03253023          	sd	s2,32(a0)
    80000e02:	03353423          	sd	s3,40(a0)
    80000e06:	03453823          	sd	s4,48(a0)
    80000e0a:	03553c23          	sd	s5,56(a0)
    80000e0e:	05653023          	sd	s6,64(a0)
    80000e12:	05753423          	sd	s7,72(a0)
    80000e16:	05853823          	sd	s8,80(a0)
    80000e1a:	05953c23          	sd	s9,88(a0)
    80000e1e:	07a53023          	sd	s10,96(a0)
    80000e22:	07b53423          	sd	s11,104(a0)
    80000e26:	0005b083          	ld	ra,0(a1)
    80000e2a:	0085b103          	ld	sp,8(a1)
    80000e2e:	6980                	ld	s0,16(a1)
    80000e30:	6d84                	ld	s1,24(a1)
    80000e32:	0205b903          	ld	s2,32(a1)
    80000e36:	0285b983          	ld	s3,40(a1)
    80000e3a:	0305ba03          	ld	s4,48(a1)
    80000e3e:	0385ba83          	ld	s5,56(a1)
    80000e42:	0405bb03          	ld	s6,64(a1)
    80000e46:	0485bb83          	ld	s7,72(a1)
    80000e4a:	0505bc03          	ld	s8,80(a1)
    80000e4e:	0585bc83          	ld	s9,88(a1)
    80000e52:	0605bd03          	ld	s10,96(a1)
    80000e56:	0685bd83          	ld	s11,104(a1)
    80000e5a:	8082                	ret

0000000080000e5c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80000e5c:	1141                	addi	sp,sp,-16
    80000e5e:	e406                	sd	ra,8(sp)
    80000e60:	e022                	sd	s0,0(sp)
    80000e62:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80000e64:	00002597          	auipc	a1,0x2
    80000e68:	37458593          	addi	a1,a1,884 # 800031d8 <digits+0x158>
    80000e6c:	0000d517          	auipc	a0,0xd
    80000e70:	4b450513          	addi	a0,a0,1204 # 8000e320 <tickslock>
    80000e74:	bd5ff0ef          	jal	ra,80000a48 <initlock>
}
    80000e78:	60a2                	ld	ra,8(sp)
    80000e7a:	6402                	ld	s0,0(sp)
    80000e7c:	0141                	addi	sp,sp,16
    80000e7e:	8082                	ret

0000000080000e80 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80000e80:	1141                	addi	sp,sp,-16
    80000e82:	e422                	sd	s0,8(sp)
    80000e84:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80000e86:	fffff797          	auipc	a5,0xfffff
    80000e8a:	2ca78793          	addi	a5,a5,714 # 80000150 <kernelvec>
    80000e8e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80000e92:	6422                	ld	s0,8(sp)
    80000e94:	0141                	addi	sp,sp,16
    80000e96:	8082                	ret

0000000080000e98 <usertrapret>:
// 现阶段我swtch之后会到这个地方往下执行
// 这个函数的主要作用就是将当前进程从内核态恢复到用户态
// 在处理完用户态进程的系统调用、中断或异常后被调用
void
usertrapret(void)
{
    80000e98:	1141                	addi	sp,sp,-16
    80000e9a:	e406                	sd	ra,8(sp)
    80000e9c:	e022                	sd	s0,0(sp)
    80000e9e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80000ea0:	8c1ff0ef          	jal	ra,80000760 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ea4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000ea8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000eaa:	10079073          	csrw	sstatus,a5
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  // uservec 是trampoline.S中的一个标签，用于记录从用户态到内核态的入口
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80000eae:	00001697          	auipc	a3,0x1
    80000eb2:	15268693          	addi	a3,a3,338 # 80002000 <_trampoline>
    80000eb6:	00001717          	auipc	a4,0x1
    80000eba:	14a70713          	addi	a4,a4,330 # 80002000 <_trampoline>
    80000ebe:	8f15                	sub	a4,a4,a3
    80000ec0:	040007b7          	lui	a5,0x4000
    80000ec4:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80000ec6:	07b2                	slli	a5,a5,0xc
    80000ec8:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80000eca:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80000ece:	7118                	ld	a4,32(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80000ed0:	18002673          	csrr	a2,satp
    80000ed4:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80000ed6:	7110                	ld	a2,32(a0)
    80000ed8:	6518                	ld	a4,8(a0)
    80000eda:	6585                	lui	a1,0x1
    80000edc:	972e                	add	a4,a4,a1
    80000ede:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80000ee0:	7118                	ld	a4,32(a0)
    80000ee2:	00000617          	auipc	a2,0x0
    80000ee6:	12660613          	addi	a2,a2,294 # 80001008 <usertrap>
    80000eea:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80000eec:	7118                	ld	a4,32(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80000eee:	8612                	mv	a2,tp
    80000ef0:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ef2:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80000ef6:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80000efa:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000efe:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80000f02:	7118                	ld	a4,32(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80000f04:	6f18                	ld	a4,24(a4)
    80000f06:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80000f0a:	6d08                	ld	a0,24(a0)
    80000f0c:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80000f0e:	00001717          	auipc	a4,0x1
    80000f12:	18e70713          	addi	a4,a4,398 # 8000209c <userret>
    80000f16:	8f15                	sub	a4,a4,a3
    80000f18:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80000f1a:	577d                	li	a4,-1
    80000f1c:	177e                	slli	a4,a4,0x3f
    80000f1e:	8d59                	or	a0,a0,a4
    80000f20:	9782                	jalr	a5
}
    80000f22:	60a2                	ld	ra,8(sp)
    80000f24:	6402                	ld	s0,0(sp)
    80000f26:	0141                	addi	sp,sp,16
    80000f28:	8082                	ret

0000000080000f2a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80000f2a:	1141                	addi	sp,sp,-16
    80000f2c:	e406                	sd	ra,8(sp)
    80000f2e:	e022                	sd	s0,0(sp)
    80000f30:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f32:	803ff0ef          	jal	ra,80000734 <cpuid>
    80000f36:	cd11                	beqz	a0,80000f52 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80000f38:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80000f3c:	000f4737          	lui	a4,0xf4
    80000f40:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000f44:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000f46:	14d79073          	csrw	0x14d,a5
}
    80000f4a:	60a2                	ld	ra,8(sp)
    80000f4c:	6402                	ld	s0,0(sp)
    80000f4e:	0141                	addi	sp,sp,16
    80000f50:	8082                	ret
    acquire(&tickslock);
    80000f52:	0000d517          	auipc	a0,0xd
    80000f56:	3ce50513          	addi	a0,a0,974 # 8000e320 <tickslock>
    80000f5a:	b6fff0ef          	jal	ra,80000ac8 <acquire>
    ticks++;
    80000f5e:	00002717          	auipc	a4,0x2
    80000f62:	56270713          	addi	a4,a4,1378 # 800034c0 <ticks>
    80000f66:	431c                	lw	a5,0(a4)
    80000f68:	2785                	addiw	a5,a5,1
    80000f6a:	c31c                	sw	a5,0(a4)
    if(ticks % 30 == 0){ //每30次时钟中断打印出一个T
    80000f6c:	4779                	li	a4,30
    80000f6e:	02e7f7bb          	remuw	a5,a5,a4
    80000f72:	cb81                	beqz	a5,80000f82 <clockintr+0x58>
    release(&tickslock);
    80000f74:	0000d517          	auipc	a0,0xd
    80000f78:	3ac50513          	addi	a0,a0,940 # 8000e320 <tickslock>
    80000f7c:	be5ff0ef          	jal	ra,80000b60 <release>
    80000f80:	bf65                	j	80000f38 <clockintr+0xe>
        printf("T");
    80000f82:	00002517          	auipc	a0,0x2
    80000f86:	25e50513          	addi	a0,a0,606 # 800031e0 <digits+0x160>
    80000f8a:	c30ff0ef          	jal	ra,800003ba <printf>
    80000f8e:	b7dd                	j	80000f74 <clockintr+0x4a>

0000000080000f90 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80000f90:	1101                	addi	sp,sp,-32
    80000f92:	ec06                	sd	ra,24(sp)
    80000f94:	e822                	sd	s0,16(sp)
    80000f96:	e426                	sd	s1,8(sp)
    80000f98:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80000f9a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80000f9e:	57fd                	li	a5,-1
    80000fa0:	17fe                	slli	a5,a5,0x3f
    80000fa2:	07a5                	addi	a5,a5,9
    80000fa4:	00f70d63          	beq	a4,a5,80000fbe <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80000fa8:	57fd                	li	a5,-1
    80000faa:	17fe                	slli	a5,a5,0x3f
    80000fac:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80000fae:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80000fb0:	04f70863          	beq	a4,a5,80001000 <devintr+0x70>
  }
}
    80000fb4:	60e2                	ld	ra,24(sp)
    80000fb6:	6442                	ld	s0,16(sp)
    80000fb8:	64a2                	ld	s1,8(sp)
    80000fba:	6105                	addi	sp,sp,32
    80000fbc:	8082                	ret
    int irq = plic_claim();
    80000fbe:	af2ff0ef          	jal	ra,800002b0 <plic_claim>
    80000fc2:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80000fc4:	47a9                	li	a5,10
    80000fc6:	02f50363          	beq	a0,a5,80000fec <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80000fca:	4785                	li	a5,1
    80000fcc:	02f50363          	beq	a0,a5,80000ff2 <devintr+0x62>
    return 1;
    80000fd0:	4505                	li	a0,1
    } else if(irq){
    80000fd2:	d0ed                	beqz	s1,80000fb4 <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80000fd4:	85a6                	mv	a1,s1
    80000fd6:	00002517          	auipc	a0,0x2
    80000fda:	23250513          	addi	a0,a0,562 # 80003208 <digits+0x188>
    80000fde:	bdcff0ef          	jal	ra,800003ba <printf>
      plic_complete(irq);
    80000fe2:	8526                	mv	a0,s1
    80000fe4:	aecff0ef          	jal	ra,800002d0 <plic_complete>
    return 1;
    80000fe8:	4505                	li	a0,1
    80000fea:	b7e9                	j	80000fb4 <devintr+0x24>
      uartintr();
    80000fec:	1f6000ef          	jal	ra,800011e2 <uartintr>
    80000ff0:	bfcd                	j	80000fe2 <devintr+0x52>
    printf("virtio_disk_intr in trap.c\n");
    80000ff2:	00002517          	auipc	a0,0x2
    80000ff6:	1f650513          	addi	a0,a0,502 # 800031e8 <digits+0x168>
    80000ffa:	bc0ff0ef          	jal	ra,800003ba <printf>
    80000ffe:	b7d5                	j	80000fe2 <devintr+0x52>
    clockintr();
    80001000:	f2bff0ef          	jal	ra,80000f2a <clockintr>
    return 2;
    80001004:	4509                	li	a0,2
    80001006:	b77d                	j	80000fb4 <devintr+0x24>

0000000080001008 <usertrap>:
{
    80001008:	1101                	addi	sp,sp,-32
    8000100a:	ec06                	sd	ra,24(sp)
    8000100c:	e822                	sd	s0,16(sp)
    8000100e:	e426                	sd	s1,8(sp)
    80001010:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001012:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001016:	1007f793          	andi	a5,a5,256
    8000101a:	ef8d                	bnez	a5,80001054 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000101c:	fffff797          	auipc	a5,0xfffff
    80001020:	13478793          	addi	a5,a5,308 # 80000150 <kernelvec>
    80001024:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001028:	f38ff0ef          	jal	ra,80000760 <myproc>
    8000102c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000102e:	711c                	ld	a5,32(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001030:	14102773          	csrr	a4,sepc
    80001034:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001036:	14202773          	csrr	a4,scause
  if(r_scause() == 8){ //用户态系统调用就会来到这个地方
    8000103a:	47a1                	li	a5,8
    8000103c:	02f70263          	beq	a4,a5,80001060 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80001040:	f51ff0ef          	jal	ra,80000f90 <devintr>
    80001044:	c131                	beqz	a0,80001088 <usertrap+0x80>
  usertrapret();
    80001046:	e53ff0ef          	jal	ra,80000e98 <usertrapret>
}
    8000104a:	60e2                	ld	ra,24(sp)
    8000104c:	6442                	ld	s0,16(sp)
    8000104e:	64a2                	ld	s1,8(sp)
    80001050:	6105                	addi	sp,sp,32
    80001052:	8082                	ret
    panic("usertrap: not from user mode");
    80001054:	00002517          	auipc	a0,0x2
    80001058:	1d450513          	addi	a0,a0,468 # 80003228 <digits+0x1a8>
    8000105c:	e12ff0ef          	jal	ra,8000066e <panic>
    printf("get a syscall from proc %d\n", myproc()->pid); 
    80001060:	f00ff0ef          	jal	ra,80000760 <myproc>
    80001064:	414c                	lw	a1,4(a0)
    80001066:	00002517          	auipc	a0,0x2
    8000106a:	1e250513          	addi	a0,a0,482 # 80003248 <digits+0x1c8>
    8000106e:	b4cff0ef          	jal	ra,800003ba <printf>
    p->trapframe->epc += 4; 
    80001072:	7098                	ld	a4,32(s1)
    80001074:	6f1c                	ld	a5,24(a4)
    80001076:	0791                	addi	a5,a5,4
    80001078:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000107a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000107e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001082:	10079073          	csrw	sstatus,a5
}
    80001086:	b7c1                	j	80001046 <usertrap+0x3e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001088:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000108c:	40d0                	lw	a2,4(s1)
    8000108e:	00002517          	auipc	a0,0x2
    80001092:	1da50513          	addi	a0,a0,474 # 80003268 <digits+0x1e8>
    80001096:	b24ff0ef          	jal	ra,800003ba <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000109a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000109e:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800010a2:	00002517          	auipc	a0,0x2
    800010a6:	1f650513          	addi	a0,a0,502 # 80003298 <digits+0x218>
    800010aa:	b10ff0ef          	jal	ra,800003ba <printf>
    800010ae:	bf61                	j	80001046 <usertrap+0x3e>

00000000800010b0 <kerneltrap>:
{
    800010b0:	7179                	addi	sp,sp,-48
    800010b2:	f406                	sd	ra,40(sp)
    800010b4:	f022                	sd	s0,32(sp)
    800010b6:	ec26                	sd	s1,24(sp)
    800010b8:	e84a                	sd	s2,16(sp)
    800010ba:	e44e                	sd	s3,8(sp)
    800010bc:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800010be:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800010c2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800010c6:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800010ca:	1004f793          	andi	a5,s1,256
    800010ce:	c39d                	beqz	a5,800010f4 <kerneltrap+0x44>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800010d0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800010d4:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800010d6:	e78d                	bnez	a5,80001100 <kerneltrap+0x50>
  if((which_dev = devintr()) == 0){
    800010d8:	eb9ff0ef          	jal	ra,80000f90 <devintr>
    800010dc:	c905                	beqz	a0,8000110c <kerneltrap+0x5c>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800010de:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800010e2:	10049073          	csrw	sstatus,s1
}
    800010e6:	70a2                	ld	ra,40(sp)
    800010e8:	7402                	ld	s0,32(sp)
    800010ea:	64e2                	ld	s1,24(sp)
    800010ec:	6942                	ld	s2,16(sp)
    800010ee:	69a2                	ld	s3,8(sp)
    800010f0:	6145                	addi	sp,sp,48
    800010f2:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800010f4:	00002517          	auipc	a0,0x2
    800010f8:	1cc50513          	addi	a0,a0,460 # 800032c0 <digits+0x240>
    800010fc:	d72ff0ef          	jal	ra,8000066e <panic>
    panic("kerneltrap: interrupts enabled");
    80001100:	00002517          	auipc	a0,0x2
    80001104:	1e850513          	addi	a0,a0,488 # 800032e8 <digits+0x268>
    80001108:	d66ff0ef          	jal	ra,8000066e <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000110c:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001110:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80001114:	85ce                	mv	a1,s3
    80001116:	00002517          	auipc	a0,0x2
    8000111a:	1f250513          	addi	a0,a0,498 # 80003308 <digits+0x288>
    8000111e:	a9cff0ef          	jal	ra,800003ba <printf>
    panic("kerneltrap");
    80001122:	00002517          	auipc	a0,0x2
    80001126:	20e50513          	addi	a0,a0,526 # 80003330 <digits+0x2b0>
    8000112a:	d44ff0ef          	jal	ra,8000066e <panic>

000000008000112e <uartinit>:

// 原本是被console.c调用，现在被printf.c调用
// 作用：初始化UART硬件
void
uartinit(void)
{
    8000112e:	1141                	addi	sp,sp,-16
    80001130:	e406                	sd	ra,8(sp)
    80001132:	e022                	sd	s0,0(sp)
    80001134:	0800                	addi	s0,sp,16
  // disable interrupts.
  // 关闭中断
  WriteReg(IER, 0x00);
    80001136:	100007b7          	lui	a5,0x10000
    8000113a:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  // 设置波特率
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000113e:	f8000713          	li	a4,-128
    80001142:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  // 配置数据格式
  WriteReg(0, 0x03);
    80001146:	470d                	li	a4,3
    80001148:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  // 使能并清空FIFO
  WriteReg(1, 0x00);
    8000114c:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80001150:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80001154:	469d                	li	a3,7
    80001156:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000115a:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    8000115e:	00002597          	auipc	a1,0x2
    80001162:	1e258593          	addi	a1,a1,482 # 80003340 <digits+0x2c0>
    80001166:	0000d517          	auipc	a0,0xd
    8000116a:	1d250513          	addi	a0,a0,466 # 8000e338 <uart_tx_lock>
    8000116e:	8dbff0ef          	jal	ra,80000a48 <initlock>
}
    80001172:	60a2                	ld	ra,8(sp)
    80001174:	6402                	ld	s0,0(sp)
    80001176:	0141                	addi	sp,sp,16
    80001178:	8082                	ret

000000008000117a <uartputc_sync>:
// to echo characters. it spins waiting for the uart's
// output register to be empty.
// 直接（同步）发送一个字符到UART
void
uartputc_sync(int c)
{
    8000117a:	1101                	addi	sp,sp,-32
    8000117c:	ec06                	sd	ra,24(sp)
    8000117e:	e822                	sd	s0,16(sp)
    80001180:	e426                	sd	s1,8(sp)
    80001182:	1000                	addi	s0,sp,32
    80001184:	84aa                	mv	s1,a0
  push_off();
    80001186:	903ff0ef          	jal	ra,80000a88 <push_off>

  if(panicked){
    8000118a:	00002797          	auipc	a5,0x2
    8000118e:	32a7a783          	lw	a5,810(a5) # 800034b4 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80001192:	10000737          	lui	a4,0x10000
  if(panicked){
    80001196:	c391                	beqz	a5,8000119a <uartputc_sync+0x20>
    for(;;)
    80001198:	a001                	j	80001198 <uartputc_sync+0x1e>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000119a:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000119e:	0207f793          	andi	a5,a5,32
    800011a2:	dfe5                	beqz	a5,8000119a <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    800011a4:	0ff4f513          	zext.b	a0,s1
    800011a8:	100007b7          	lui	a5,0x10000
    800011ac:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    800011b0:	95dff0ef          	jal	ra,80000b0c <pop_off>
}
    800011b4:	60e2                	ld	ra,24(sp)
    800011b6:	6442                	ld	s0,16(sp)
    800011b8:	64a2                	ld	s1,8(sp)
    800011ba:	6105                	addi	sp,sp,32
    800011bc:	8082                	ret

00000000800011be <uartgetc>:
// read one input character from the UART.
// return -1 if none is waiting.
// 从UART读取一个输入字符
int
uartgetc(void)
{
    800011be:	1141                	addi	sp,sp,-16
    800011c0:	e422                	sd	s0,8(sp)
    800011c2:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800011c4:	100007b7          	lui	a5,0x10000
    800011c8:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800011cc:	8b85                	andi	a5,a5,1
    800011ce:	cb81                	beqz	a5,800011de <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    800011d0:	100007b7          	lui	a5,0x10000
    800011d4:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800011d8:	6422                	ld	s0,8(sp)
    800011da:	0141                	addi	sp,sp,16
    800011dc:	8082                	ret
    return -1;
    800011de:	557d                	li	a0,-1
    800011e0:	bfe5                	j	800011d8 <uartgetc+0x1a>

00000000800011e2 <uartintr>:
// arrived, or the uart is ready for more output, or
// both. called from devintr().
// UART中断处理函数
void
uartintr(void)
{
    800011e2:	1101                	addi	sp,sp,-32
    800011e4:	ec06                	sd	ra,24(sp)
    800011e6:	e822                	sd	s0,16(sp)
    800011e8:	e426                	sd	s1,8(sp)
    800011ea:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc(); // 这个就是从UART寄存器读取一个字符
    if(c == -1)
    800011ec:	54fd                	li	s1,-1
    800011ee:	a019                	j	800011f4 <uartintr+0x12>
      break;
    // 这个好像委托到console.c的consoleintr()函数处理
    // 老师的意思好像是直接调用那个同步的putc发送
    // 这里不能使用console.c的文件
    // consoleintr(c); 
    pputc(c); // 直接调用printf.c的pputc函数发送字符
    800011f0:	906ff0ef          	jal	ra,800002f6 <pputc>
    int c = uartgetc(); // 这个就是从UART寄存器读取一个字符
    800011f4:	fcbff0ef          	jal	ra,800011be <uartgetc>
    if(c == -1)
    800011f8:	fe951ce3          	bne	a0,s1,800011f0 <uartintr+0xe>

  // send buffered characters.
  // acquire(&uart_tx_lock);
  // uartstart();
  // release(&uart_tx_lock);
}
    800011fc:	60e2                	ld	ra,24(sp)
    800011fe:	6442                	ld	s0,16(sp)
    80001200:	64a2                	ld	s1,8(sp)
    80001202:	6105                	addi	sp,sp,32
    80001204:	8082                	ret

0000000080001206 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001206:	1141                	addi	sp,sp,-16
    80001208:	e422                	sd	s0,8(sp)
    8000120a:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000120c:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  // 应该是将TLB中的内容清空，内核更换的时候应该都要做
  sfence_vma();

  // 将kernel_pagetable的地址写入每个CPU核的satp寄存器中
  w_satp(MAKE_SATP(kernel_pagetable));
    80001210:	00002797          	auipc	a5,0x2
    80001214:	2c87b783          	ld	a5,712(a5) # 800034d8 <kernel_pagetable>
    80001218:	83b1                	srli	a5,a5,0xc
    8000121a:	577d                	li	a4,-1
    8000121c:	177e                	slli	a4,a4,0x3f
    8000121e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001220:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001224:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  // 不知道是不是再清空一遍TLB
  sfence_vma();
}
    80001228:	6422                	ld	s0,8(sp)
    8000122a:	0141                	addi	sp,sp,16
    8000122c:	8082                	ret

000000008000122e <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000122e:	7139                	addi	sp,sp,-64
    80001230:	fc06                	sd	ra,56(sp)
    80001232:	f822                	sd	s0,48(sp)
    80001234:	f426                	sd	s1,40(sp)
    80001236:	f04a                	sd	s2,32(sp)
    80001238:	ec4e                	sd	s3,24(sp)
    8000123a:	e852                	sd	s4,16(sp)
    8000123c:	e456                	sd	s5,8(sp)
    8000123e:	e05a                	sd	s6,0(sp)
    80001240:	0080                	addi	s0,sp,64
    80001242:	84aa                	mv	s1,a0
    80001244:	89ae                	mv	s3,a1
    80001246:	8ab2                	mv	s5,a2
  // 首先检查va是否超出了最大的虚拟地址
  if(va >= MAXVA)
    80001248:	57fd                	li	a5,-1
    8000124a:	83e9                	srli	a5,a5,0x1a
    8000124c:	4a79                	li	s4,30
    panic("walk");
  
  for(int level = 2; level > 0; level--) {
    8000124e:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001250:	02b7fc63          	bgeu	a5,a1,80001288 <walk+0x5a>
    panic("walk");
    80001254:	00002517          	auipc	a0,0x2
    80001258:	0f450513          	addi	a0,a0,244 # 80003348 <digits+0x2c8>
    8000125c:	c12ff0ef          	jal	ra,8000066e <panic>
    //查找以pagetable为基址的页表中，序号为VPN[level]的条目
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) { // 如果这个条目是有效的
      pagetable = (pagetable_t)PTE2PA(*pte);  // 取出这个条目对应的物理页面基址
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0) // 如果是一个无效的条目并且不允许分配就返回了
    80001260:	060a8263          	beqz	s5,800012c4 <walk+0x96>
    80001264:	e9bfe0ef          	jal	ra,800000fe <kalloc>
    80001268:	84aa                	mv	s1,a0
    8000126a:	c139                	beqz	a0,800012b0 <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000126c:	6605                	lui	a2,0x1
    8000126e:	4581                	li	a1,0
    80001270:	9e1ff0ef          	jal	ra,80000c50 <memset>
      *pte = PA2PTE(pagetable) | PTE_V; // 如果允许分配，就将这个条目记录在这个页表中，并设置有效位
    80001274:	00c4d793          	srli	a5,s1,0xc
    80001278:	07aa                	slli	a5,a5,0xa
    8000127a:	0017e793          	ori	a5,a5,1
    8000127e:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001282:	3a5d                	addiw	s4,s4,-9
    80001284:	036a0063          	beq	s4,s6,800012a4 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80001288:	0149d933          	srl	s2,s3,s4
    8000128c:	1ff97913          	andi	s2,s2,511
    80001290:	090e                	slli	s2,s2,0x3
    80001292:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) { // 如果这个条目是有效的
    80001294:	00093483          	ld	s1,0(s2)
    80001298:	0014f793          	andi	a5,s1,1
    8000129c:	d3f1                	beqz	a5,80001260 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);  // 取出这个条目对应的物理页面基址
    8000129e:	80a9                	srli	s1,s1,0xa
    800012a0:	04b2                	slli	s1,s1,0xc
    800012a2:	b7c5                	j	80001282 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];  // 返回三级页表中序号为VPN[0]的条目地址
    800012a4:	00c9d513          	srli	a0,s3,0xc
    800012a8:	1ff57513          	andi	a0,a0,511
    800012ac:	050e                	slli	a0,a0,0x3
    800012ae:	9526                	add	a0,a0,s1
}
    800012b0:	70e2                	ld	ra,56(sp)
    800012b2:	7442                	ld	s0,48(sp)
    800012b4:	74a2                	ld	s1,40(sp)
    800012b6:	7902                	ld	s2,32(sp)
    800012b8:	69e2                	ld	s3,24(sp)
    800012ba:	6a42                	ld	s4,16(sp)
    800012bc:	6aa2                	ld	s5,8(sp)
    800012be:	6b02                	ld	s6,0(sp)
    800012c0:	6121                	addi	sp,sp,64
    800012c2:	8082                	ret
        return 0;
    800012c4:	4501                	li	a0,0
    800012c6:	b7ed                	j	800012b0 <walk+0x82>

00000000800012c8 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800012c8:	715d                	addi	sp,sp,-80
    800012ca:	e486                	sd	ra,72(sp)
    800012cc:	e0a2                	sd	s0,64(sp)
    800012ce:	fc26                	sd	s1,56(sp)
    800012d0:	f84a                	sd	s2,48(sp)
    800012d2:	f44e                	sd	s3,40(sp)
    800012d4:	f052                	sd	s4,32(sp)
    800012d6:	ec56                	sd	s5,24(sp)
    800012d8:	e85a                	sd	s6,16(sp)
    800012da:	e45e                	sd	s7,8(sp)
    800012dc:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012de:	03459793          	slli	a5,a1,0x34
    800012e2:	e7a9                	bnez	a5,8000132c <mappages+0x64>
    800012e4:	8aaa                	mv	s5,a0
    800012e6:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    800012e8:	03461793          	slli	a5,a2,0x34
    800012ec:	e7b1                	bnez	a5,80001338 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    800012ee:	ca39                	beqz	a2,80001344 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    800012f0:	77fd                	lui	a5,0xfffff
    800012f2:	963e                	add	a2,a2,a5
    800012f4:	00b609b3          	add	s3,a2,a1
  a = va;
    800012f8:	892e                	mv	s2,a1
    800012fa:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V; // 将内容填写到表项上面去pte-> ppn-perm 物理地址前面部分-标志位
    if(a == last)
      break;
    a += PGSIZE;
    800012fe:	6b85                	lui	s7,0x1
    80001300:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001304:	4605                	li	a2,1
    80001306:	85ca                	mv	a1,s2
    80001308:	8556                	mv	a0,s5
    8000130a:	f25ff0ef          	jal	ra,8000122e <walk>
    8000130e:	c539                	beqz	a0,8000135c <mappages+0x94>
    if(*pte & PTE_V)
    80001310:	611c                	ld	a5,0(a0)
    80001312:	8b85                	andi	a5,a5,1
    80001314:	ef95                	bnez	a5,80001350 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V; // 将内容填写到表项上面去pte-> ppn-perm 物理地址前面部分-标志位
    80001316:	80b1                	srli	s1,s1,0xc
    80001318:	04aa                	slli	s1,s1,0xa
    8000131a:	0164e4b3          	or	s1,s1,s6
    8000131e:	0014e493          	ori	s1,s1,1
    80001322:	e104                	sd	s1,0(a0)
    if(a == last)
    80001324:	05390863          	beq	s2,s3,80001374 <mappages+0xac>
    a += PGSIZE;
    80001328:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000132a:	bfd9                	j	80001300 <mappages+0x38>
    panic("mappages: va not aligned");
    8000132c:	00002517          	auipc	a0,0x2
    80001330:	02450513          	addi	a0,a0,36 # 80003350 <digits+0x2d0>
    80001334:	b3aff0ef          	jal	ra,8000066e <panic>
    panic("mappages: size not aligned");
    80001338:	00002517          	auipc	a0,0x2
    8000133c:	03850513          	addi	a0,a0,56 # 80003370 <digits+0x2f0>
    80001340:	b2eff0ef          	jal	ra,8000066e <panic>
    panic("mappages: size");
    80001344:	00002517          	auipc	a0,0x2
    80001348:	04c50513          	addi	a0,a0,76 # 80003390 <digits+0x310>
    8000134c:	b22ff0ef          	jal	ra,8000066e <panic>
      panic("mappages: remap");
    80001350:	00002517          	auipc	a0,0x2
    80001354:	05050513          	addi	a0,a0,80 # 800033a0 <digits+0x320>
    80001358:	b16ff0ef          	jal	ra,8000066e <panic>
      return -1;
    8000135c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000135e:	60a6                	ld	ra,72(sp)
    80001360:	6406                	ld	s0,64(sp)
    80001362:	74e2                	ld	s1,56(sp)
    80001364:	7942                	ld	s2,48(sp)
    80001366:	79a2                	ld	s3,40(sp)
    80001368:	7a02                	ld	s4,32(sp)
    8000136a:	6ae2                	ld	s5,24(sp)
    8000136c:	6b42                	ld	s6,16(sp)
    8000136e:	6ba2                	ld	s7,8(sp)
    80001370:	6161                	addi	sp,sp,80
    80001372:	8082                	ret
  return 0;
    80001374:	4501                	li	a0,0
    80001376:	b7e5                	j	8000135e <mappages+0x96>

0000000080001378 <kvmmap>:
{
    80001378:	1141                	addi	sp,sp,-16
    8000137a:	e406                	sd	ra,8(sp)
    8000137c:	e022                	sd	s0,0(sp)
    8000137e:	0800                	addi	s0,sp,16
    80001380:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001382:	86b2                	mv	a3,a2
    80001384:	863e                	mv	a2,a5
    80001386:	f43ff0ef          	jal	ra,800012c8 <mappages>
    8000138a:	e509                	bnez	a0,80001394 <kvmmap+0x1c>
}
    8000138c:	60a2                	ld	ra,8(sp)
    8000138e:	6402                	ld	s0,0(sp)
    80001390:	0141                	addi	sp,sp,16
    80001392:	8082                	ret
    panic("kvmmap");
    80001394:	00002517          	auipc	a0,0x2
    80001398:	01c50513          	addi	a0,a0,28 # 800033b0 <digits+0x330>
    8000139c:	ad2ff0ef          	jal	ra,8000066e <panic>

00000000800013a0 <kvmmake>:
{
    800013a0:	1101                	addi	sp,sp,-32
    800013a2:	ec06                	sd	ra,24(sp)
    800013a4:	e822                	sd	s0,16(sp)
    800013a6:	e426                	sd	s1,8(sp)
    800013a8:	e04a                	sd	s2,0(sp)
    800013aa:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800013ac:	d53fe0ef          	jal	ra,800000fe <kalloc>
    800013b0:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800013b2:	6605                	lui	a2,0x1
    800013b4:	4581                	li	a1,0
    800013b6:	89bff0ef          	jal	ra,80000c50 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800013ba:	4719                	li	a4,6
    800013bc:	6685                	lui	a3,0x1
    800013be:	10000637          	lui	a2,0x10000
    800013c2:	100005b7          	lui	a1,0x10000
    800013c6:	8526                	mv	a0,s1
    800013c8:	fb1ff0ef          	jal	ra,80001378 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800013cc:	4719                	li	a4,6
    800013ce:	040006b7          	lui	a3,0x4000
    800013d2:	0c000637          	lui	a2,0xc000
    800013d6:	0c0005b7          	lui	a1,0xc000
    800013da:	8526                	mv	a0,s1
    800013dc:	f9dff0ef          	jal	ra,80001378 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800013e0:	00002917          	auipc	s2,0x2
    800013e4:	c2090913          	addi	s2,s2,-992 # 80003000 <etext>
    800013e8:	4729                	li	a4,10
    800013ea:	80002697          	auipc	a3,0x80002
    800013ee:	c1668693          	addi	a3,a3,-1002 # 3000 <_entry-0x7fffd000>
    800013f2:	4605                	li	a2,1
    800013f4:	067e                	slli	a2,a2,0x1f
    800013f6:	85b2                	mv	a1,a2
    800013f8:	8526                	mv	a0,s1
    800013fa:	f7fff0ef          	jal	ra,80001378 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800013fe:	4719                	li	a4,6
    80001400:	46c5                	li	a3,17
    80001402:	06ee                	slli	a3,a3,0x1b
    80001404:	412686b3          	sub	a3,a3,s2
    80001408:	864a                	mv	a2,s2
    8000140a:	85ca                	mv	a1,s2
    8000140c:	8526                	mv	a0,s1
    8000140e:	f6bff0ef          	jal	ra,80001378 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001412:	4729                	li	a4,10
    80001414:	6685                	lui	a3,0x1
    80001416:	00001617          	auipc	a2,0x1
    8000141a:	bea60613          	addi	a2,a2,-1046 # 80002000 <_trampoline>
    8000141e:	040005b7          	lui	a1,0x4000
    80001422:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001424:	05b2                	slli	a1,a1,0xc
    80001426:	8526                	mv	a0,s1
    80001428:	f51ff0ef          	jal	ra,80001378 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000142c:	8526                	mv	a0,s1
    8000142e:	aa8ff0ef          	jal	ra,800006d6 <proc_mapstacks>
}
    80001432:	8526                	mv	a0,s1
    80001434:	60e2                	ld	ra,24(sp)
    80001436:	6442                	ld	s0,16(sp)
    80001438:	64a2                	ld	s1,8(sp)
    8000143a:	6902                	ld	s2,0(sp)
    8000143c:	6105                	addi	sp,sp,32
    8000143e:	8082                	ret

0000000080001440 <kvminit>:
{
    80001440:	1141                	addi	sp,sp,-16
    80001442:	e406                	sd	ra,8(sp)
    80001444:	e022                	sd	s0,0(sp)
    80001446:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001448:	f59ff0ef          	jal	ra,800013a0 <kvmmake>
    8000144c:	00002797          	auipc	a5,0x2
    80001450:	08a7b623          	sd	a0,140(a5) # 800034d8 <kernel_pagetable>
}
    80001454:	60a2                	ld	ra,8(sp)
    80001456:	6402                	ld	s0,0(sp)
    80001458:	0141                	addi	sp,sp,16
    8000145a:	8082                	ret

000000008000145c <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000145c:	715d                	addi	sp,sp,-80
    8000145e:	e486                	sd	ra,72(sp)
    80001460:	e0a2                	sd	s0,64(sp)
    80001462:	fc26                	sd	s1,56(sp)
    80001464:	f84a                	sd	s2,48(sp)
    80001466:	f44e                	sd	s3,40(sp)
    80001468:	f052                	sd	s4,32(sp)
    8000146a:	ec56                	sd	s5,24(sp)
    8000146c:	e85a                	sd	s6,16(sp)
    8000146e:	e45e                	sd	s7,8(sp)
    80001470:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001472:	03459793          	slli	a5,a1,0x34
    80001476:	e795                	bnez	a5,800014a2 <uvmunmap+0x46>
    80001478:	8a2a                	mv	s4,a0
    8000147a:	892e                	mv	s2,a1
    8000147c:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000147e:	0632                	slli	a2,a2,0xc
    80001480:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001484:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001486:	6b05                	lui	s6,0x1
    80001488:	0535ea63          	bltu	a1,s3,800014dc <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000148c:	60a6                	ld	ra,72(sp)
    8000148e:	6406                	ld	s0,64(sp)
    80001490:	74e2                	ld	s1,56(sp)
    80001492:	7942                	ld	s2,48(sp)
    80001494:	79a2                	ld	s3,40(sp)
    80001496:	7a02                	ld	s4,32(sp)
    80001498:	6ae2                	ld	s5,24(sp)
    8000149a:	6b42                	ld	s6,16(sp)
    8000149c:	6ba2                	ld	s7,8(sp)
    8000149e:	6161                	addi	sp,sp,80
    800014a0:	8082                	ret
    panic("uvmunmap: not aligned");
    800014a2:	00002517          	auipc	a0,0x2
    800014a6:	f1650513          	addi	a0,a0,-234 # 800033b8 <digits+0x338>
    800014aa:	9c4ff0ef          	jal	ra,8000066e <panic>
      panic("uvmunmap: walk");
    800014ae:	00002517          	auipc	a0,0x2
    800014b2:	f2250513          	addi	a0,a0,-222 # 800033d0 <digits+0x350>
    800014b6:	9b8ff0ef          	jal	ra,8000066e <panic>
      panic("uvmunmap: not mapped");
    800014ba:	00002517          	auipc	a0,0x2
    800014be:	f2650513          	addi	a0,a0,-218 # 800033e0 <digits+0x360>
    800014c2:	9acff0ef          	jal	ra,8000066e <panic>
      panic("uvmunmap: not a leaf");
    800014c6:	00002517          	auipc	a0,0x2
    800014ca:	f3250513          	addi	a0,a0,-206 # 800033f8 <digits+0x378>
    800014ce:	9a0ff0ef          	jal	ra,8000066e <panic>
    *pte = 0;
    800014d2:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800014d6:	995a                	add	s2,s2,s6
    800014d8:	fb397ae3          	bgeu	s2,s3,8000148c <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800014dc:	4601                	li	a2,0
    800014de:	85ca                	mv	a1,s2
    800014e0:	8552                	mv	a0,s4
    800014e2:	d4dff0ef          	jal	ra,8000122e <walk>
    800014e6:	84aa                	mv	s1,a0
    800014e8:	d179                	beqz	a0,800014ae <uvmunmap+0x52>
    if((*pte & PTE_V) == 0)
    800014ea:	6108                	ld	a0,0(a0)
    800014ec:	00157793          	andi	a5,a0,1
    800014f0:	d7e9                	beqz	a5,800014ba <uvmunmap+0x5e>
    if(PTE_FLAGS(*pte) == PTE_V)
    800014f2:	3ff57793          	andi	a5,a0,1023
    800014f6:	fd7788e3          	beq	a5,s7,800014c6 <uvmunmap+0x6a>
    if(do_free){
    800014fa:	fc0a8ce3          	beqz	s5,800014d2 <uvmunmap+0x76>
      uint64 pa = PTE2PA(*pte);
    800014fe:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001500:	0532                	slli	a0,a0,0xc
    80001502:	b1bfe0ef          	jal	ra,8000001c <kfree>
    80001506:	b7f1                	j	800014d2 <uvmunmap+0x76>

0000000080001508 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001508:	1101                	addi	sp,sp,-32
    8000150a:	ec06                	sd	ra,24(sp)
    8000150c:	e822                	sd	s0,16(sp)
    8000150e:	e426                	sd	s1,8(sp)
    80001510:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001512:	bedfe0ef          	jal	ra,800000fe <kalloc>
    80001516:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001518:	c509                	beqz	a0,80001522 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000151a:	6605                	lui	a2,0x1
    8000151c:	4581                	li	a1,0
    8000151e:	f32ff0ef          	jal	ra,80000c50 <memset>
  return pagetable;
}
    80001522:	8526                	mv	a0,s1
    80001524:	60e2                	ld	ra,24(sp)
    80001526:	6442                	ld	s0,16(sp)
    80001528:	64a2                	ld	s1,8(sp)
    8000152a:	6105                	addi	sp,sp,32
    8000152c:	8082                	ret

000000008000152e <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000152e:	7179                	addi	sp,sp,-48
    80001530:	f406                	sd	ra,40(sp)
    80001532:	f022                	sd	s0,32(sp)
    80001534:	ec26                	sd	s1,24(sp)
    80001536:	e84a                	sd	s2,16(sp)
    80001538:	e44e                	sd	s3,8(sp)
    8000153a:	e052                	sd	s4,0(sp)
    8000153c:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000153e:	6785                	lui	a5,0x1
    80001540:	04f67063          	bgeu	a2,a5,80001580 <uvmfirst+0x52>
    80001544:	8a2a                	mv	s4,a0
    80001546:	89ae                	mv	s3,a1
    80001548:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000154a:	bb5fe0ef          	jal	ra,800000fe <kalloc>
    8000154e:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001550:	6605                	lui	a2,0x1
    80001552:	4581                	li	a1,0
    80001554:	efcff0ef          	jal	ra,80000c50 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001558:	4779                	li	a4,30
    8000155a:	86ca                	mv	a3,s2
    8000155c:	6605                	lui	a2,0x1
    8000155e:	4581                	li	a1,0
    80001560:	8552                	mv	a0,s4
    80001562:	d67ff0ef          	jal	ra,800012c8 <mappages>
  memmove(mem, src, sz);
    80001566:	8626                	mv	a2,s1
    80001568:	85ce                	mv	a1,s3
    8000156a:	854a                	mv	a0,s2
    8000156c:	f40ff0ef          	jal	ra,80000cac <memmove>
}
    80001570:	70a2                	ld	ra,40(sp)
    80001572:	7402                	ld	s0,32(sp)
    80001574:	64e2                	ld	s1,24(sp)
    80001576:	6942                	ld	s2,16(sp)
    80001578:	69a2                	ld	s3,8(sp)
    8000157a:	6a02                	ld	s4,0(sp)
    8000157c:	6145                	addi	sp,sp,48
    8000157e:	8082                	ret
    panic("uvmfirst: more than a page");
    80001580:	00002517          	auipc	a0,0x2
    80001584:	e9050513          	addi	a0,a0,-368 # 80003410 <digits+0x390>
    80001588:	8e6ff0ef          	jal	ra,8000066e <panic>

000000008000158c <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000158c:	7179                	addi	sp,sp,-48
    8000158e:	f406                	sd	ra,40(sp)
    80001590:	f022                	sd	s0,32(sp)
    80001592:	ec26                	sd	s1,24(sp)
    80001594:	e84a                	sd	s2,16(sp)
    80001596:	e44e                	sd	s3,8(sp)
    80001598:	e052                	sd	s4,0(sp)
    8000159a:	1800                	addi	s0,sp,48
    8000159c:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000159e:	84aa                	mv	s1,a0
    800015a0:	6905                	lui	s2,0x1
    800015a2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015a4:	4985                	li	s3,1
    800015a6:	a819                	j	800015bc <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800015a8:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800015aa:	00c79513          	slli	a0,a5,0xc
    800015ae:	fdfff0ef          	jal	ra,8000158c <freewalk>
      pagetable[i] = 0;
    800015b2:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800015b6:	04a1                	addi	s1,s1,8
    800015b8:	01248f63          	beq	s1,s2,800015d6 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    800015bc:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015be:	00f7f713          	andi	a4,a5,15
    800015c2:	ff3703e3          	beq	a4,s3,800015a8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800015c6:	8b85                	andi	a5,a5,1
    800015c8:	d7fd                	beqz	a5,800015b6 <freewalk+0x2a>
      panic("freewalk: leaf");
    800015ca:	00002517          	auipc	a0,0x2
    800015ce:	e6650513          	addi	a0,a0,-410 # 80003430 <digits+0x3b0>
    800015d2:	89cff0ef          	jal	ra,8000066e <panic>
    }
  }
  kfree((void*)pagetable);
    800015d6:	8552                	mv	a0,s4
    800015d8:	a45fe0ef          	jal	ra,8000001c <kfree>
}
    800015dc:	70a2                	ld	ra,40(sp)
    800015de:	7402                	ld	s0,32(sp)
    800015e0:	64e2                	ld	s1,24(sp)
    800015e2:	6942                	ld	s2,16(sp)
    800015e4:	69a2                	ld	s3,8(sp)
    800015e6:	6a02                	ld	s4,0(sp)
    800015e8:	6145                	addi	sp,sp,48
    800015ea:	8082                	ret

00000000800015ec <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015ec:	1101                	addi	sp,sp,-32
    800015ee:	ec06                	sd	ra,24(sp)
    800015f0:	e822                	sd	s0,16(sp)
    800015f2:	e426                	sd	s1,8(sp)
    800015f4:	1000                	addi	s0,sp,32
    800015f6:	84aa                	mv	s1,a0
  if(sz > 0)
    800015f8:	e989                	bnez	a1,8000160a <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015fa:	8526                	mv	a0,s1
    800015fc:	f91ff0ef          	jal	ra,8000158c <freewalk>
}
    80001600:	60e2                	ld	ra,24(sp)
    80001602:	6442                	ld	s0,16(sp)
    80001604:	64a2                	ld	s1,8(sp)
    80001606:	6105                	addi	sp,sp,32
    80001608:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000160a:	6785                	lui	a5,0x1
    8000160c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000160e:	95be                	add	a1,a1,a5
    80001610:	4685                	li	a3,1
    80001612:	00c5d613          	srli	a2,a1,0xc
    80001616:	4581                	li	a1,0
    80001618:	e45ff0ef          	jal	ra,8000145c <uvmunmap>
    8000161c:	bff9                	j	800015fa <uvmfree+0xe>
	...

0000000080002000 <_trampoline>:
    80002000:	14051073          	csrw	sscratch,a0
    80002004:	02000537          	lui	a0,0x2000
    80002008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000200a:	0536                	slli	a0,a0,0xd
    8000200c:	02153423          	sd	ra,40(a0)
    80002010:	02253823          	sd	sp,48(a0)
    80002014:	02353c23          	sd	gp,56(a0)
    80002018:	04453023          	sd	tp,64(a0)
    8000201c:	04553423          	sd	t0,72(a0)
    80002020:	04653823          	sd	t1,80(a0)
    80002024:	04753c23          	sd	t2,88(a0)
    80002028:	f120                	sd	s0,96(a0)
    8000202a:	f524                	sd	s1,104(a0)
    8000202c:	fd2c                	sd	a1,120(a0)
    8000202e:	e150                	sd	a2,128(a0)
    80002030:	e554                	sd	a3,136(a0)
    80002032:	e958                	sd	a4,144(a0)
    80002034:	ed5c                	sd	a5,152(a0)
    80002036:	0b053023          	sd	a6,160(a0)
    8000203a:	0b153423          	sd	a7,168(a0)
    8000203e:	0b253823          	sd	s2,176(a0)
    80002042:	0b353c23          	sd	s3,184(a0)
    80002046:	0d453023          	sd	s4,192(a0)
    8000204a:	0d553423          	sd	s5,200(a0)
    8000204e:	0d653823          	sd	s6,208(a0)
    80002052:	0d753c23          	sd	s7,216(a0)
    80002056:	0f853023          	sd	s8,224(a0)
    8000205a:	0f953423          	sd	s9,232(a0)
    8000205e:	0fa53823          	sd	s10,240(a0)
    80002062:	0fb53c23          	sd	s11,248(a0)
    80002066:	11c53023          	sd	t3,256(a0)
    8000206a:	11d53423          	sd	t4,264(a0)
    8000206e:	11e53823          	sd	t5,272(a0)
    80002072:	11f53c23          	sd	t6,280(a0)
    80002076:	140022f3          	csrr	t0,sscratch
    8000207a:	06553823          	sd	t0,112(a0)
    8000207e:	00853103          	ld	sp,8(a0)
    80002082:	02053203          	ld	tp,32(a0)
    80002086:	01053283          	ld	t0,16(a0)
    8000208a:	00053303          	ld	t1,0(a0)
    8000208e:	12000073          	sfence.vma
    80002092:	18031073          	csrw	satp,t1
    80002096:	12000073          	sfence.vma
    8000209a:	8282                	jr	t0

000000008000209c <userret>:
    8000209c:	12000073          	sfence.vma
    800020a0:	18051073          	csrw	satp,a0
    800020a4:	12000073          	sfence.vma
    800020a8:	02000537          	lui	a0,0x2000
    800020ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800020ae:	0536                	slli	a0,a0,0xd
    800020b0:	02853083          	ld	ra,40(a0)
    800020b4:	03053103          	ld	sp,48(a0)
    800020b8:	03853183          	ld	gp,56(a0)
    800020bc:	04053203          	ld	tp,64(a0)
    800020c0:	04853283          	ld	t0,72(a0)
    800020c4:	05053303          	ld	t1,80(a0)
    800020c8:	05853383          	ld	t2,88(a0)
    800020cc:	7120                	ld	s0,96(a0)
    800020ce:	7524                	ld	s1,104(a0)
    800020d0:	7d2c                	ld	a1,120(a0)
    800020d2:	6150                	ld	a2,128(a0)
    800020d4:	6554                	ld	a3,136(a0)
    800020d6:	6958                	ld	a4,144(a0)
    800020d8:	6d5c                	ld	a5,152(a0)
    800020da:	0a053803          	ld	a6,160(a0)
    800020de:	0a853883          	ld	a7,168(a0)
    800020e2:	0b053903          	ld	s2,176(a0)
    800020e6:	0b853983          	ld	s3,184(a0)
    800020ea:	0c053a03          	ld	s4,192(a0)
    800020ee:	0c853a83          	ld	s5,200(a0)
    800020f2:	0d053b03          	ld	s6,208(a0)
    800020f6:	0d853b83          	ld	s7,216(a0)
    800020fa:	0e053c03          	ld	s8,224(a0)
    800020fe:	0e853c83          	ld	s9,232(a0)
    80002102:	0f053d03          	ld	s10,240(a0)
    80002106:	0f853d83          	ld	s11,248(a0)
    8000210a:	10053e03          	ld	t3,256(a0)
    8000210e:	10853e83          	ld	t4,264(a0)
    80002112:	11053f03          	ld	t5,272(a0)
    80002116:	11853f83          	ld	t6,280(a0)
    8000211a:	7928                	ld	a0,112(a0)
    8000211c:	10200073          	sret
	...
