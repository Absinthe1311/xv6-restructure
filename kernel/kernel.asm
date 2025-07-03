
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00001117          	auipc	sp,0x1
    80000004:	1f813103          	ld	sp,504(sp) # 800011f8 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	06d000ef          	jal	ra,80000882 <start>

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
    80000030:	00009797          	auipc	a5,0x9
    80000034:	6a078793          	addi	a5,a5,1696 # 800096d0 <end>
    80000038:	02f56f63          	bltu	a0,a5,80000076 <kfree+0x5a>
    8000003c:	47c5                	li	a5,17
    8000003e:	07ee                	slli	a5,a5,0x1b
    80000040:	02f57b63          	bgeu	a0,a5,80000076 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000044:	6605                	lui	a2,0x1
    80000046:	4585                	li	a1,1
    80000048:	0ab000ef          	jal	ra,800008f2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    8000004c:	00001917          	auipc	s2,0x1
    80000050:	1f490913          	addi	s2,s2,500 # 80001240 <kmem>
    80000054:	854a                	mv	a0,s2
    80000056:	714000ef          	jal	ra,8000076a <acquire>
  r->next = kmem.freelist;
    8000005a:	01893783          	ld	a5,24(s2)
    8000005e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000060:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000064:	854a                	mv	a0,s2
    80000066:	79c000ef          	jal	ra,80000802 <release>
}
    8000006a:	60e2                	ld	ra,24(sp)
    8000006c:	6442                	ld	s0,16(sp)
    8000006e:	64a2                	ld	s1,8(sp)
    80000070:	6902                	ld	s2,0(sp)
    80000072:	6105                	addi	sp,sp,32
    80000074:	8082                	ret
    panic("kfree");
    80000076:	00001517          	auipc	a0,0x1
    8000007a:	f8a50513          	addi	a0,a0,-118 # 80001000 <etext>
    8000007e:	5d4000ef          	jal	ra,80000652 <panic>

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
    800000d2:	00001597          	auipc	a1,0x1
    800000d6:	f3658593          	addi	a1,a1,-202 # 80001008 <etext+0x8>
    800000da:	00001517          	auipc	a0,0x1
    800000de:	16650513          	addi	a0,a0,358 # 80001240 <kmem>
    800000e2:	608000ef          	jal	ra,800006ea <initlock>
  freerange(end, (void*)PHYSTOP);
    800000e6:	45c5                	li	a1,17
    800000e8:	05ee                	slli	a1,a1,0x1b
    800000ea:	00009517          	auipc	a0,0x9
    800000ee:	5e650513          	addi	a0,a0,1510 # 800096d0 <end>
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
    80000108:	00001497          	auipc	s1,0x1
    8000010c:	13848493          	addi	s1,s1,312 # 80001240 <kmem>
    80000110:	8526                	mv	a0,s1
    80000112:	658000ef          	jal	ra,8000076a <acquire>
  r = kmem.freelist;
    80000116:	6c84                	ld	s1,24(s1)
  if(r)
    80000118:	c485                	beqz	s1,80000140 <kalloc+0x42>
    kmem.freelist = r->next;
    8000011a:	609c                	ld	a5,0(s1)
    8000011c:	00001517          	auipc	a0,0x1
    80000120:	12450513          	addi	a0,a0,292 # 80001240 <kmem>
    80000124:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000126:	6dc000ef          	jal	ra,80000802 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    8000012a:	6605                	lui	a2,0x1
    8000012c:	4595                	li	a1,5
    8000012e:	8526                	mv	a0,s1
    80000130:	7c2000ef          	jal	ra,800008f2 <memset>
  return (void*)r;
}
    80000134:	8526                	mv	a0,s1
    80000136:	60e2                	ld	ra,24(sp)
    80000138:	6442                	ld	s0,16(sp)
    8000013a:	64a2                	ld	s1,8(sp)
    8000013c:	6105                	addi	sp,sp,32
    8000013e:	8082                	ret
  release(&kmem.lock);
    80000140:	00001517          	auipc	a0,0x1
    80000144:	10050513          	addi	a0,a0,256 # 80001240 <kmem>
    80000148:	6ba000ef          	jal	ra,80000802 <release>
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
    80000178:	237000ef          	jal	ra,80000bae <kerneltrap>
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
    800001b6:	508000ef          	jal	ra,800006be <cpuid>
    // userinit();      // first user process

    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    800001ba:	00001717          	auipc	a4,0x1
    800001be:	05670713          	addi	a4,a4,86 # 80001210 <started>
  if(cpuid() == 0){
    800001c2:	c915                	beqz	a0,800001f6 <main+0x48>
    while(started == 0)
    800001c4:	431c                	lw	a5,0(a4)
    800001c6:	2781                	sext.w	a5,a5
    800001c8:	dff5                	beqz	a5,800001c4 <main+0x16>
      ;
    __sync_synchronize();
    800001ca:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    800001ce:	4f0000ef          	jal	ra,800006be <cpuid>
    800001d2:	85aa                	mv	a1,a0
    800001d4:	00001517          	auipc	a0,0x1
    800001d8:	e5450513          	addi	a0,a0,-428 # 80001028 <etext+0x28>
    800001dc:	1c2000ef          	jal	ra,8000039e <printf>
    
    // 内存处理部分
    kvminithart();    // turn on paging
    800001e0:	325000ef          	jal	ra,80000d04 <kvminithart>

    trapinithart();   // install kernel trap vector
    800001e4:	0d5000ef          	jal	ra,80000ab8 <trapinithart>

static inline uint64
r_sstatus()
{
  uint64 x;
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800001e8:	100027f3          	csrr	a5,sstatus

// enable device interrupts
static inline void
intr_on()
{
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800001ec:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800001f0:	10079073          	csrw	sstatus,a5
    // plicinithart();   // ask PLIC for device interrupts
  }
  //while(1) ;
  //scheduler();        
  intr_on(); // 开放中断
  while(1) ;
    800001f4:	a001                	j	800001f4 <main+0x46>
    printfinit();
    800001f6:	496000ef          	jal	ra,8000068c <printfinit>
    printf("\n");
    800001fa:	00001517          	auipc	a0,0x1
    800001fe:	e3e50513          	addi	a0,a0,-450 # 80001038 <etext+0x38>
    80000202:	19c000ef          	jal	ra,8000039e <printf>
    printf("xv6 kernel is booting\n");
    80000206:	00001517          	auipc	a0,0x1
    8000020a:	e0a50513          	addi	a0,a0,-502 # 80001010 <etext+0x10>
    8000020e:	190000ef          	jal	ra,8000039e <printf>
    printf("\n");
    80000212:	00001517          	auipc	a0,0x1
    80000216:	e2650513          	addi	a0,a0,-474 # 80001038 <etext+0x38>
    8000021a:	184000ef          	jal	ra,8000039e <printf>
    kinit();         // physical page allocator
    8000021e:	eadff0ef          	jal	ra,800000ca <kinit>
    kvminit();       // create kernel page table
    80000222:	4fd000ef          	jal	ra,80000f1e <kvminit>
    kvminithart();   // turn on paging
    80000226:	2df000ef          	jal	ra,80000d04 <kvminithart>
    trapinit();      // trap vectors
    8000022a:	06b000ef          	jal	ra,80000a94 <trapinit>
    trapinithart();  // install kernel trap vector
    8000022e:	08b000ef          	jal	ra,80000ab8 <trapinithart>
    plicinit();      // set up interrupt controller
    80000232:	018000ef          	jal	ra,8000024a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000236:	02a000ef          	jal	ra,80000260 <plicinithart>
    __sync_synchronize();
    8000023a:	0ff0000f          	fence
    started = 1;
    8000023e:	4785                	li	a5,1
    80000240:	00001717          	auipc	a4,0x1
    80000244:	fcf72823          	sw	a5,-48(a4) # 80001210 <started>
    80000248:	b745                	j	800001e8 <main+0x3a>

000000008000024a <plicinit>:
// // the riscv Platform Level Interrupt Controller (PLIC).
// //

void
plicinit(void)
{
    8000024a:	1141                	addi	sp,sp,-16
    8000024c:	e422                	sd	s0,8(sp)
    8000024e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80000250:	0c0007b7          	lui	a5,0xc000
    80000254:	4705                	li	a4,1
    80000256:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80000258:	c3d8                	sw	a4,4(a5)
}
    8000025a:	6422                	ld	s0,8(sp)
    8000025c:	0141                	addi	sp,sp,16
    8000025e:	8082                	ret

0000000080000260 <plicinithart>:

void
plicinithart(void)
{
    80000260:	1141                	addi	sp,sp,-16
    80000262:	e406                	sd	ra,8(sp)
    80000264:	e022                	sd	s0,0(sp)
    80000266:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80000268:	456000ef          	jal	ra,800006be <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    8000026c:	0085171b          	slliw	a4,a0,0x8
    80000270:	0c0027b7          	lui	a5,0xc002
    80000274:	97ba                	add	a5,a5,a4
    80000276:	40200713          	li	a4,1026
    8000027a:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    8000027e:	00d5151b          	slliw	a0,a0,0xd
    80000282:	0c2017b7          	lui	a5,0xc201
    80000286:	97aa                	add	a5,a5,a0
    80000288:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    8000028c:	60a2                	ld	ra,8(sp)
    8000028e:	6402                	ld	s0,0(sp)
    80000290:	0141                	addi	sp,sp,16
    80000292:	8082                	ret

0000000080000294 <plic_claim>:

// ask the PLIC what interrupt we should serve.
// 从PLIC取出当前哪个设备发出了中断，返回设备的IRQ号
int
plic_claim(void)
{
    80000294:	1141                	addi	sp,sp,-16
    80000296:	e406                	sd	ra,8(sp)
    80000298:	e022                	sd	s0,0(sp)
    8000029a:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000029c:	422000ef          	jal	ra,800006be <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800002a0:	00d5151b          	slliw	a0,a0,0xd
    800002a4:	0c2017b7          	lui	a5,0xc201
    800002a8:	97aa                	add	a5,a5,a0
  return irq;
}
    800002aa:	43c8                	lw	a0,4(a5)
    800002ac:	60a2                	ld	ra,8(sp)
    800002ae:	6402                	ld	s0,0(sp)
    800002b0:	0141                	addi	sp,sp,16
    800002b2:	8082                	ret

00000000800002b4 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800002b4:	1101                	addi	sp,sp,-32
    800002b6:	ec06                	sd	ra,24(sp)
    800002b8:	e822                	sd	s0,16(sp)
    800002ba:	e426                	sd	s1,8(sp)
    800002bc:	1000                	addi	s0,sp,32
    800002be:	84aa                	mv	s1,a0
  int hart = cpuid();
    800002c0:	3fe000ef          	jal	ra,800006be <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800002c4:	00d5151b          	slliw	a0,a0,0xd
    800002c8:	0c2017b7          	lui	a5,0xc201
    800002cc:	97aa                	add	a5,a5,a0
    800002ce:	c3c4                	sw	s1,4(a5)
}
    800002d0:	60e2                	ld	ra,24(sp)
    800002d2:	6442                	ld	s0,16(sp)
    800002d4:	64a2                	ld	s1,8(sp)
    800002d6:	6105                	addi	sp,sp,32
    800002d8:	8082                	ret

00000000800002da <pputc>:
////////////////////////////
// 这个函数添加用于替代console.c中的consputc()函数 后续需要的话将pputc修改回来
# define BACKSPACE 0x100
void
pputc(int c)
{
    800002da:	1141                	addi	sp,sp,-16
    800002dc:	e406                	sd	ra,8(sp)
    800002de:	e022                	sd	s0,0(sp)
    800002e0:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    800002e2:	10000793          	li	a5,256
    800002e6:	00f50863          	beq	a0,a5,800002f6 <pputc+0x1c>
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
  }
  else
  {
    uartputc_sync(c);
    800002ea:	18f000ef          	jal	ra,80000c78 <uartputc_sync>
  }
}
    800002ee:	60a2                	ld	ra,8(sp)
    800002f0:	6402                	ld	s0,0(sp)
    800002f2:	0141                	addi	sp,sp,16
    800002f4:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002f6:	4521                	li	a0,8
    800002f8:	181000ef          	jal	ra,80000c78 <uartputc_sync>
    800002fc:	02000513          	li	a0,32
    80000300:	179000ef          	jal	ra,80000c78 <uartputc_sync>
    80000304:	4521                	li	a0,8
    80000306:	173000ef          	jal	ra,80000c78 <uartputc_sync>
    8000030a:	b7d5                	j	800002ee <pputc+0x14>

000000008000030c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    8000030c:	7179                	addi	sp,sp,-48
    8000030e:	f406                	sd	ra,40(sp)
    80000310:	f022                	sd	s0,32(sp)
    80000312:	ec26                	sd	s1,24(sp)
    80000314:	e84a                	sd	s2,16(sp)
    80000316:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000318:	c219                	beqz	a2,8000031e <printint+0x12>
    8000031a:	06054e63          	bltz	a0,80000396 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000031e:	4881                	li	a7,0
    80000320:	fd040693          	addi	a3,s0,-48

  i = 0;
    80000324:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000326:	00001617          	auipc	a2,0x1
    8000032a:	d3a60613          	addi	a2,a2,-710 # 80001060 <digits>
    8000032e:	883e                	mv	a6,a5
    80000330:	2785                	addiw	a5,a5,1 # c201001 <_entry-0x73dfefff>
    80000332:	02b57733          	remu	a4,a0,a1
    80000336:	9732                	add	a4,a4,a2
    80000338:	00074703          	lbu	a4,0(a4)
    8000033c:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000340:	872a                	mv	a4,a0
    80000342:	02b55533          	divu	a0,a0,a1
    80000346:	0685                	addi	a3,a3,1
    80000348:	feb773e3          	bgeu	a4,a1,8000032e <printint+0x22>

  if(sign)
    8000034c:	00088a63          	beqz	a7,80000360 <printint+0x54>
    buf[i++] = '-';
    80000350:	1781                	addi	a5,a5,-32
    80000352:	97a2                	add	a5,a5,s0
    80000354:	02d00713          	li	a4,45
    80000358:	fee78823          	sb	a4,-16(a5)
    8000035c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80000360:	02f05563          	blez	a5,8000038a <printint+0x7e>
    80000364:	fd040713          	addi	a4,s0,-48
    80000368:	00f704b3          	add	s1,a4,a5
    8000036c:	fff70913          	addi	s2,a4,-1
    80000370:	993e                	add	s2,s2,a5
    80000372:	37fd                	addiw	a5,a5,-1
    80000374:	1782                	slli	a5,a5,0x20
    80000376:	9381                	srli	a5,a5,0x20
    80000378:	40f90933          	sub	s2,s2,a5
    //consputc(buf[i]);
    pputc(buf[i]);
    8000037c:	fff4c503          	lbu	a0,-1(s1)
    80000380:	f5bff0ef          	jal	ra,800002da <pputc>
  while(--i >= 0)
    80000384:	14fd                	addi	s1,s1,-1
    80000386:	ff249be3          	bne	s1,s2,8000037c <printint+0x70>
}
    8000038a:	70a2                	ld	ra,40(sp)
    8000038c:	7402                	ld	s0,32(sp)
    8000038e:	64e2                	ld	s1,24(sp)
    80000390:	6942                	ld	s2,16(sp)
    80000392:	6145                	addi	sp,sp,48
    80000394:	8082                	ret
    x = -xx;
    80000396:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    8000039a:	4885                	li	a7,1
    x = -xx;
    8000039c:	b751                	j	80000320 <printint+0x14>

000000008000039e <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    8000039e:	7155                	addi	sp,sp,-208
    800003a0:	e506                	sd	ra,136(sp)
    800003a2:	e122                	sd	s0,128(sp)
    800003a4:	fca6                	sd	s1,120(sp)
    800003a6:	f8ca                	sd	s2,112(sp)
    800003a8:	f4ce                	sd	s3,104(sp)
    800003aa:	f0d2                	sd	s4,96(sp)
    800003ac:	ecd6                	sd	s5,88(sp)
    800003ae:	e8da                	sd	s6,80(sp)
    800003b0:	e4de                	sd	s7,72(sp)
    800003b2:	e0e2                	sd	s8,64(sp)
    800003b4:	fc66                	sd	s9,56(sp)
    800003b6:	f86a                	sd	s10,48(sp)
    800003b8:	f46e                	sd	s11,40(sp)
    800003ba:	0900                	addi	s0,sp,144
    800003bc:	8a2a                	mv	s4,a0
    800003be:	e40c                	sd	a1,8(s0)
    800003c0:	e810                	sd	a2,16(s0)
    800003c2:	ec14                	sd	a3,24(s0)
    800003c4:	f018                	sd	a4,32(s0)
    800003c6:	f41c                	sd	a5,40(s0)
    800003c8:	03043823          	sd	a6,48(s0)
    800003cc:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800003d0:	00001797          	auipc	a5,0x1
    800003d4:	ea87a783          	lw	a5,-344(a5) # 80001278 <pr+0x18>
    800003d8:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800003dc:	eb9d                	bnez	a5,80000412 <printf+0x74>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800003de:	00840793          	addi	a5,s0,8
    800003e2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800003e6:	00054503          	lbu	a0,0(a0)
    800003ea:	24050463          	beqz	a0,80000632 <printf+0x294>
    800003ee:	4981                	li	s3,0
    if(cx != '%'){
    800003f0:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    800003f4:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    800003f8:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    800003fc:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000400:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000404:	07000d93          	li	s11,112
    pputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000408:	00001b97          	auipc	s7,0x1
    8000040c:	c58b8b93          	addi	s7,s7,-936 # 80001060 <digits>
    80000410:	a081                	j	80000450 <printf+0xb2>
    acquire(&pr.lock);
    80000412:	00001517          	auipc	a0,0x1
    80000416:	e4e50513          	addi	a0,a0,-434 # 80001260 <pr>
    8000041a:	350000ef          	jal	ra,8000076a <acquire>
  va_start(ap, fmt);
    8000041e:	00840793          	addi	a5,s0,8
    80000422:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000426:	000a4503          	lbu	a0,0(s4) # fffffffffffff000 <end+0xffffffff7fff5930>
    8000042a:	f171                	bnez	a0,800003ee <printf+0x50>
#endif
  }
  va_end(ap);

  if(locking)
    release(&pr.lock);
    8000042c:	00001517          	auipc	a0,0x1
    80000430:	e3450513          	addi	a0,a0,-460 # 80001260 <pr>
    80000434:	3ce000ef          	jal	ra,80000802 <release>
    80000438:	aaed                	j	80000632 <printf+0x294>
      pputc(cx);
    8000043a:	ea1ff0ef          	jal	ra,800002da <pputc>
      continue;
    8000043e:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000440:	0014899b          	addiw	s3,s1,1
    80000444:	013a07b3          	add	a5,s4,s3
    80000448:	0007c503          	lbu	a0,0(a5)
    8000044c:	1c050f63          	beqz	a0,8000062a <printf+0x28c>
    if(cx != '%'){
    80000450:	ff5515e3          	bne	a0,s5,8000043a <printf+0x9c>
    i++;
    80000454:	0019849b          	addiw	s1,s3,1 # 1001 <_entry-0x7fffefff>
    c0 = fmt[i+0] & 0xff;
    80000458:	009a07b3          	add	a5,s4,s1
    8000045c:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000460:	1c090563          	beqz	s2,8000062a <printf+0x28c>
    80000464:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000468:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    8000046a:	c789                	beqz	a5,80000474 <printf+0xd6>
    8000046c:	009a0733          	add	a4,s4,s1
    80000470:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80000474:	03690463          	beq	s2,s6,8000049c <printf+0xfe>
    } else if(c0 == 'l' && c1 == 'd'){
    80000478:	03890e63          	beq	s2,s8,800004b4 <printf+0x116>
    } else if(c0 == 'u'){
    8000047c:	0b990d63          	beq	s2,s9,80000536 <printf+0x198>
    } else if(c0 == 'x'){
    80000480:	11a90363          	beq	s2,s10,80000586 <printf+0x1e8>
    } else if(c0 == 'p'){
    80000484:	13b90b63          	beq	s2,s11,800005ba <printf+0x21c>
    } else if(c0 == 's'){
    80000488:	07300793          	li	a5,115
    8000048c:	16f90363          	beq	s2,a5,800005f2 <printf+0x254>
    } else if(c0 == '%'){
    80000490:	03591c63          	bne	s2,s5,800004c8 <printf+0x12a>
      pputc('%');
    80000494:	8556                	mv	a0,s5
    80000496:	e45ff0ef          	jal	ra,800002da <pputc>
    8000049a:	b75d                	j	80000440 <printf+0xa2>
      printint(va_arg(ap, int), 10, 1);
    8000049c:	f8843783          	ld	a5,-120(s0)
    800004a0:	00878713          	addi	a4,a5,8
    800004a4:	f8e43423          	sd	a4,-120(s0)
    800004a8:	4605                	li	a2,1
    800004aa:	45a9                	li	a1,10
    800004ac:	4388                	lw	a0,0(a5)
    800004ae:	e5fff0ef          	jal	ra,8000030c <printint>
    800004b2:	b779                	j	80000440 <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'd'){
    800004b4:	03678163          	beq	a5,s6,800004d6 <printf+0x138>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800004b8:	03878d63          	beq	a5,s8,800004f2 <printf+0x154>
    } else if(c0 == 'l' && c1 == 'u'){
    800004bc:	09978963          	beq	a5,s9,8000054e <printf+0x1b0>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800004c0:	03878b63          	beq	a5,s8,800004f6 <printf+0x158>
    } else if(c0 == 'l' && c1 == 'x'){
    800004c4:	0da78d63          	beq	a5,s10,8000059e <printf+0x200>
      pputc('%');
    800004c8:	8556                	mv	a0,s5
    800004ca:	e11ff0ef          	jal	ra,800002da <pputc>
      pputc(c0);
    800004ce:	854a                	mv	a0,s2
    800004d0:	e0bff0ef          	jal	ra,800002da <pputc>
    800004d4:	b7b5                	j	80000440 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    800004d6:	f8843783          	ld	a5,-120(s0)
    800004da:	00878713          	addi	a4,a5,8
    800004de:	f8e43423          	sd	a4,-120(s0)
    800004e2:	4605                	li	a2,1
    800004e4:	45a9                	li	a1,10
    800004e6:	6388                	ld	a0,0(a5)
    800004e8:	e25ff0ef          	jal	ra,8000030c <printint>
      i += 1;
    800004ec:	0029849b          	addiw	s1,s3,2
    800004f0:	bf81                	j	80000440 <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800004f2:	03668463          	beq	a3,s6,8000051a <printf+0x17c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800004f6:	07968a63          	beq	a3,s9,8000056a <printf+0x1cc>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    800004fa:	fda697e3          	bne	a3,s10,800004c8 <printf+0x12a>
      printint(va_arg(ap, uint64), 16, 0);
    800004fe:	f8843783          	ld	a5,-120(s0)
    80000502:	00878713          	addi	a4,a5,8
    80000506:	f8e43423          	sd	a4,-120(s0)
    8000050a:	4601                	li	a2,0
    8000050c:	45c1                	li	a1,16
    8000050e:	6388                	ld	a0,0(a5)
    80000510:	dfdff0ef          	jal	ra,8000030c <printint>
      i += 2;
    80000514:	0039849b          	addiw	s1,s3,3
    80000518:	b725                	j	80000440 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    8000051a:	f8843783          	ld	a5,-120(s0)
    8000051e:	00878713          	addi	a4,a5,8
    80000522:	f8e43423          	sd	a4,-120(s0)
    80000526:	4605                	li	a2,1
    80000528:	45a9                	li	a1,10
    8000052a:	6388                	ld	a0,0(a5)
    8000052c:	de1ff0ef          	jal	ra,8000030c <printint>
      i += 2;
    80000530:	0039849b          	addiw	s1,s3,3
    80000534:	b731                	j	80000440 <printf+0xa2>
      printint(va_arg(ap, int), 10, 0);
    80000536:	f8843783          	ld	a5,-120(s0)
    8000053a:	00878713          	addi	a4,a5,8
    8000053e:	f8e43423          	sd	a4,-120(s0)
    80000542:	4601                	li	a2,0
    80000544:	45a9                	li	a1,10
    80000546:	4388                	lw	a0,0(a5)
    80000548:	dc5ff0ef          	jal	ra,8000030c <printint>
    8000054c:	bdd5                	j	80000440 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    8000054e:	f8843783          	ld	a5,-120(s0)
    80000552:	00878713          	addi	a4,a5,8
    80000556:	f8e43423          	sd	a4,-120(s0)
    8000055a:	4601                	li	a2,0
    8000055c:	45a9                	li	a1,10
    8000055e:	6388                	ld	a0,0(a5)
    80000560:	dadff0ef          	jal	ra,8000030c <printint>
      i += 1;
    80000564:	0029849b          	addiw	s1,s3,2
    80000568:	bde1                	j	80000440 <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    8000056a:	f8843783          	ld	a5,-120(s0)
    8000056e:	00878713          	addi	a4,a5,8
    80000572:	f8e43423          	sd	a4,-120(s0)
    80000576:	4601                	li	a2,0
    80000578:	45a9                	li	a1,10
    8000057a:	6388                	ld	a0,0(a5)
    8000057c:	d91ff0ef          	jal	ra,8000030c <printint>
      i += 2;
    80000580:	0039849b          	addiw	s1,s3,3
    80000584:	bd75                	j	80000440 <printf+0xa2>
      printint(va_arg(ap, int), 16, 0);
    80000586:	f8843783          	ld	a5,-120(s0)
    8000058a:	00878713          	addi	a4,a5,8
    8000058e:	f8e43423          	sd	a4,-120(s0)
    80000592:	4601                	li	a2,0
    80000594:	45c1                	li	a1,16
    80000596:	4388                	lw	a0,0(a5)
    80000598:	d75ff0ef          	jal	ra,8000030c <printint>
    8000059c:	b555                	j	80000440 <printf+0xa2>
      printint(va_arg(ap, uint64), 16, 0);
    8000059e:	f8843783          	ld	a5,-120(s0)
    800005a2:	00878713          	addi	a4,a5,8
    800005a6:	f8e43423          	sd	a4,-120(s0)
    800005aa:	4601                	li	a2,0
    800005ac:	45c1                	li	a1,16
    800005ae:	6388                	ld	a0,0(a5)
    800005b0:	d5dff0ef          	jal	ra,8000030c <printint>
      i += 1;
    800005b4:	0029849b          	addiw	s1,s3,2
    800005b8:	b561                	j	80000440 <printf+0xa2>
      printptr(va_arg(ap, uint64));
    800005ba:	f8843783          	ld	a5,-120(s0)
    800005be:	00878713          	addi	a4,a5,8
    800005c2:	f8e43423          	sd	a4,-120(s0)
    800005c6:	0007b983          	ld	s3,0(a5)
  pputc('0');
    800005ca:	03000513          	li	a0,48
    800005ce:	d0dff0ef          	jal	ra,800002da <pputc>
  pputc('x');
    800005d2:	856a                	mv	a0,s10
    800005d4:	d07ff0ef          	jal	ra,800002da <pputc>
    800005d8:	4941                	li	s2,16
    pputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005da:	03c9d793          	srli	a5,s3,0x3c
    800005de:	97de                	add	a5,a5,s7
    800005e0:	0007c503          	lbu	a0,0(a5)
    800005e4:	cf7ff0ef          	jal	ra,800002da <pputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800005e8:	0992                	slli	s3,s3,0x4
    800005ea:	397d                	addiw	s2,s2,-1
    800005ec:	fe0917e3          	bnez	s2,800005da <printf+0x23c>
    800005f0:	bd81                	j	80000440 <printf+0xa2>
      if((s = va_arg(ap, char*)) == 0)
    800005f2:	f8843783          	ld	a5,-120(s0)
    800005f6:	00878713          	addi	a4,a5,8
    800005fa:	f8e43423          	sd	a4,-120(s0)
    800005fe:	0007b903          	ld	s2,0(a5)
    80000602:	00090d63          	beqz	s2,8000061c <printf+0x27e>
      for(; *s; s++)
    80000606:	00094503          	lbu	a0,0(s2)
    8000060a:	e2050be3          	beqz	a0,80000440 <printf+0xa2>
        pputc(*s);
    8000060e:	ccdff0ef          	jal	ra,800002da <pputc>
      for(; *s; s++)
    80000612:	0905                	addi	s2,s2,1
    80000614:	00094503          	lbu	a0,0(s2)
    80000618:	f97d                	bnez	a0,8000060e <printf+0x270>
    8000061a:	b51d                	j	80000440 <printf+0xa2>
        s = "(null)";
    8000061c:	00001917          	auipc	s2,0x1
    80000620:	a2490913          	addi	s2,s2,-1500 # 80001040 <etext+0x40>
      for(; *s; s++)
    80000624:	02800513          	li	a0,40
    80000628:	b7dd                	j	8000060e <printf+0x270>
  if(locking)
    8000062a:	f7843783          	ld	a5,-136(s0)
    8000062e:	de079fe3          	bnez	a5,8000042c <printf+0x8e>

  return 0;
}
    80000632:	4501                	li	a0,0
    80000634:	60aa                	ld	ra,136(sp)
    80000636:	640a                	ld	s0,128(sp)
    80000638:	74e6                	ld	s1,120(sp)
    8000063a:	7946                	ld	s2,112(sp)
    8000063c:	79a6                	ld	s3,104(sp)
    8000063e:	7a06                	ld	s4,96(sp)
    80000640:	6ae6                	ld	s5,88(sp)
    80000642:	6b46                	ld	s6,80(sp)
    80000644:	6ba6                	ld	s7,72(sp)
    80000646:	6c06                	ld	s8,64(sp)
    80000648:	7ce2                	ld	s9,56(sp)
    8000064a:	7d42                	ld	s10,48(sp)
    8000064c:	7da2                	ld	s11,40(sp)
    8000064e:	6169                	addi	sp,sp,208
    80000650:	8082                	ret

0000000080000652 <panic>:

void
panic(char *s)
{
    80000652:	1101                	addi	sp,sp,-32
    80000654:	ec06                	sd	ra,24(sp)
    80000656:	e822                	sd	s0,16(sp)
    80000658:	e426                	sd	s1,8(sp)
    8000065a:	1000                	addi	s0,sp,32
    8000065c:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000065e:	00001797          	auipc	a5,0x1
    80000662:	c007ad23          	sw	zero,-998(a5) # 80001278 <pr+0x18>
  printf("panic: ");
    80000666:	00001517          	auipc	a0,0x1
    8000066a:	9e250513          	addi	a0,a0,-1566 # 80001048 <etext+0x48>
    8000066e:	d31ff0ef          	jal	ra,8000039e <printf>
  printf("%s\n", s);
    80000672:	85a6                	mv	a1,s1
    80000674:	00001517          	auipc	a0,0x1
    80000678:	9dc50513          	addi	a0,a0,-1572 # 80001050 <etext+0x50>
    8000067c:	d23ff0ef          	jal	ra,8000039e <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000680:	4785                	li	a5,1
    80000682:	00001717          	auipc	a4,0x1
    80000686:	b8f72923          	sw	a5,-1134(a4) # 80001214 <panicked>
  for(;;)
    8000068a:	a001                	j	8000068a <panic+0x38>

000000008000068c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000068c:	1101                	addi	sp,sp,-32
    8000068e:	ec06                	sd	ra,24(sp)
    80000690:	e822                	sd	s0,16(sp)
    80000692:	e426                	sd	s1,8(sp)
    80000694:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000696:	00001497          	auipc	s1,0x1
    8000069a:	bca48493          	addi	s1,s1,-1078 # 80001260 <pr>
    8000069e:	00001597          	auipc	a1,0x1
    800006a2:	9ba58593          	addi	a1,a1,-1606 # 80001058 <etext+0x58>
    800006a6:	8526                	mv	a0,s1
    800006a8:	042000ef          	jal	ra,800006ea <initlock>

  uartinit(); // 使用printf.c直接替代console.c中的打印函数，需要在这里初始化串口
    800006ac:	580000ef          	jal	ra,80000c2c <uartinit>

  pr.locking = 1;
    800006b0:	4785                	li	a5,1
    800006b2:	cc9c                	sw	a5,24(s1)
}
    800006b4:	60e2                	ld	ra,24(sp)
    800006b6:	6442                	ld	s0,16(sp)
    800006b8:	64a2                	ld	s1,8(sp)
    800006ba:	6105                	addi	sp,sp,32
    800006bc:	8082                	ret

00000000800006be <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800006be:	1141                	addi	sp,sp,-16
    800006c0:	e422                	sd	s0,8(sp)
    800006c2:	0800                	addi	s0,sp,16
// this core's hartid (core number), the index into cpus[].
static inline uint64
r_tp()
{
  uint64 x;
  asm volatile("mv %0, tp" : "=r" (x) );
    800006c4:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800006c6:	2501                	sext.w	a0,a0
    800006c8:	6422                	ld	s0,8(sp)
    800006ca:	0141                	addi	sp,sp,16
    800006cc:	8082                	ret

00000000800006ce <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800006ce:	1141                	addi	sp,sp,-16
    800006d0:	e422                	sd	s0,8(sp)
    800006d2:	0800                	addi	s0,sp,16
    800006d4:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800006d6:	2781                	sext.w	a5,a5
    800006d8:	079e                	slli	a5,a5,0x7
  return c;
}
    800006da:	00001517          	auipc	a0,0x1
    800006de:	ba650513          	addi	a0,a0,-1114 # 80001280 <cpus>
    800006e2:	953e                	add	a0,a0,a5
    800006e4:	6422                	ld	s0,8(sp)
    800006e6:	0141                	addi	sp,sp,16
    800006e8:	8082                	ret

00000000800006ea <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    800006ea:	1141                	addi	sp,sp,-16
    800006ec:	e422                	sd	s0,8(sp)
    800006ee:	0800                	addi	s0,sp,16
  lk->name = name;
    800006f0:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    800006f2:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    800006f6:	00053823          	sd	zero,16(a0)
}
    800006fa:	6422                	ld	s0,8(sp)
    800006fc:	0141                	addi	sp,sp,16
    800006fe:	8082                	ret

0000000080000700 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000700:	411c                	lw	a5,0(a0)
    80000702:	e399                	bnez	a5,80000708 <holding+0x8>
    80000704:	4501                	li	a0,0
  return r;
}
    80000706:	8082                	ret
{
    80000708:	1101                	addi	sp,sp,-32
    8000070a:	ec06                	sd	ra,24(sp)
    8000070c:	e822                	sd	s0,16(sp)
    8000070e:	e426                	sd	s1,8(sp)
    80000710:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000712:	6904                	ld	s1,16(a0)
    80000714:	fbbff0ef          	jal	ra,800006ce <mycpu>
    80000718:	40a48533          	sub	a0,s1,a0
    8000071c:	00153513          	seqz	a0,a0
}
    80000720:	60e2                	ld	ra,24(sp)
    80000722:	6442                	ld	s0,16(sp)
    80000724:	64a2                	ld	s1,8(sp)
    80000726:	6105                	addi	sp,sp,32
    80000728:	8082                	ret

000000008000072a <push_off>:
// are initially off, then push_off, pop_off leaves them off.

// 这个涉及到进程方面，先注释掉
void
push_off(void)
{
    8000072a:	1101                	addi	sp,sp,-32
    8000072c:	ec06                	sd	ra,24(sp)
    8000072e:	e822                	sd	s0,16(sp)
    80000730:	e426                	sd	s1,8(sp)
    80000732:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000734:	100024f3          	csrr	s1,sstatus
    80000738:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000073c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000073e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000742:	f8dff0ef          	jal	ra,800006ce <mycpu>
    80000746:	5d3c                	lw	a5,120(a0)
    80000748:	cb99                	beqz	a5,8000075e <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    8000074a:	f85ff0ef          	jal	ra,800006ce <mycpu>
    8000074e:	5d3c                	lw	a5,120(a0)
    80000750:	2785                	addiw	a5,a5,1
    80000752:	dd3c                	sw	a5,120(a0)
}
    80000754:	60e2                	ld	ra,24(sp)
    80000756:	6442                	ld	s0,16(sp)
    80000758:	64a2                	ld	s1,8(sp)
    8000075a:	6105                	addi	sp,sp,32
    8000075c:	8082                	ret
    mycpu()->intena = old;
    8000075e:	f71ff0ef          	jal	ra,800006ce <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000762:	8085                	srli	s1,s1,0x1
    80000764:	8885                	andi	s1,s1,1
    80000766:	dd64                	sw	s1,124(a0)
    80000768:	b7cd                	j	8000074a <push_off+0x20>

000000008000076a <acquire>:
{
    8000076a:	1101                	addi	sp,sp,-32
    8000076c:	ec06                	sd	ra,24(sp)
    8000076e:	e822                	sd	s0,16(sp)
    80000770:	e426                	sd	s1,8(sp)
    80000772:	1000                	addi	s0,sp,32
    80000774:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000776:	fb5ff0ef          	jal	ra,8000072a <push_off>
  if(holding(lk))
    8000077a:	8526                	mv	a0,s1
    8000077c:	f85ff0ef          	jal	ra,80000700 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000780:	4705                	li	a4,1
  if(holding(lk))
    80000782:	e105                	bnez	a0,800007a2 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000784:	87ba                	mv	a5,a4
    80000786:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    8000078a:	2781                	sext.w	a5,a5
    8000078c:	ffe5                	bnez	a5,80000784 <acquire+0x1a>
  __sync_synchronize();
    8000078e:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000792:	f3dff0ef          	jal	ra,800006ce <mycpu>
    80000796:	e888                	sd	a0,16(s1)
}
    80000798:	60e2                	ld	ra,24(sp)
    8000079a:	6442                	ld	s0,16(sp)
    8000079c:	64a2                	ld	s1,8(sp)
    8000079e:	6105                	addi	sp,sp,32
    800007a0:	8082                	ret
    panic("acquire");
    800007a2:	00001517          	auipc	a0,0x1
    800007a6:	8d650513          	addi	a0,a0,-1834 # 80001078 <digits+0x18>
    800007aa:	ea9ff0ef          	jal	ra,80000652 <panic>

00000000800007ae <pop_off>:

void
pop_off(void)
{
    800007ae:	1141                	addi	sp,sp,-16
    800007b0:	e406                	sd	ra,8(sp)
    800007b2:	e022                	sd	s0,0(sp)
    800007b4:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    800007b6:	f19ff0ef          	jal	ra,800006ce <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800007ba:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800007be:	8b89                	andi	a5,a5,2
  if(intr_get())
    800007c0:	e78d                	bnez	a5,800007ea <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    800007c2:	5d3c                	lw	a5,120(a0)
    800007c4:	02f05963          	blez	a5,800007f6 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    800007c8:	37fd                	addiw	a5,a5,-1
    800007ca:	0007871b          	sext.w	a4,a5
    800007ce:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    800007d0:	eb09                	bnez	a4,800007e2 <pop_off+0x34>
    800007d2:	5d7c                	lw	a5,124(a0)
    800007d4:	c799                	beqz	a5,800007e2 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800007d6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800007da:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800007de:	10079073          	csrw	sstatus,a5
    intr_on();
}
    800007e2:	60a2                	ld	ra,8(sp)
    800007e4:	6402                	ld	s0,0(sp)
    800007e6:	0141                	addi	sp,sp,16
    800007e8:	8082                	ret
    panic("pop_off - interruptible");
    800007ea:	00001517          	auipc	a0,0x1
    800007ee:	89650513          	addi	a0,a0,-1898 # 80001080 <digits+0x20>
    800007f2:	e61ff0ef          	jal	ra,80000652 <panic>
    panic("pop_off");
    800007f6:	00001517          	auipc	a0,0x1
    800007fa:	8a250513          	addi	a0,a0,-1886 # 80001098 <digits+0x38>
    800007fe:	e55ff0ef          	jal	ra,80000652 <panic>

0000000080000802 <release>:
{
    80000802:	1101                	addi	sp,sp,-32
    80000804:	ec06                	sd	ra,24(sp)
    80000806:	e822                	sd	s0,16(sp)
    80000808:	e426                	sd	s1,8(sp)
    8000080a:	1000                	addi	s0,sp,32
    8000080c:	84aa                	mv	s1,a0
  if(!holding(lk))
    8000080e:	ef3ff0ef          	jal	ra,80000700 <holding>
    80000812:	c105                	beqz	a0,80000832 <release+0x30>
  lk->cpu = 0;
    80000814:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000818:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    8000081c:	0f50000f          	fence	iorw,ow
    80000820:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000824:	f8bff0ef          	jal	ra,800007ae <pop_off>
}
    80000828:	60e2                	ld	ra,24(sp)
    8000082a:	6442                	ld	s0,16(sp)
    8000082c:	64a2                	ld	s1,8(sp)
    8000082e:	6105                	addi	sp,sp,32
    80000830:	8082                	ret
    panic("release");
    80000832:	00001517          	auipc	a0,0x1
    80000836:	86e50513          	addi	a0,a0,-1938 # 800010a0 <digits+0x40>
    8000083a:	e19ff0ef          	jal	ra,80000652 <panic>

000000008000083e <timerinit>:

// ask each hart to generate timer interrupts.
// 设备驱动程序
void
timerinit()
{
    8000083e:	1141                	addi	sp,sp,-16
    80000840:	e422                	sd	s0,8(sp)
    80000842:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000844:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  // 使能S模式下的定时器中断
  w_mie(r_mie() | MIE_STIE);
    80000848:	0207e793          	ori	a5,a5,32
  asm volatile("csrw mie, %0" : : "r" (x));
    8000084c:	30479073          	csrw	mie,a5
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80000850:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  // 使能sstc扩展
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000854:	577d                	li	a4,-1
    80000856:	177e                	slli	a4,a4,0x3f
    80000858:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    8000085a:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000085e:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  // 允许s模式下访问计数器
  w_mcounteren(r_mcounteren() | 2);
    80000862:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000866:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    8000086a:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  // 设置下一个定时器中断的时间点
  w_stimecmp(r_time() + 1000000);
    8000086e:	000f4737          	lui	a4,0xf4
    80000872:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000876:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000878:	14d79073          	csrw	0x14d,a5
}
    8000087c:	6422                	ld	s0,8(sp)
    8000087e:	0141                	addi	sp,sp,16
    80000880:	8082                	ret

0000000080000882 <start>:
{
    80000882:	1141                	addi	sp,sp,-16
    80000884:	e406                	sd	ra,8(sp)
    80000886:	e022                	sd	s0,0(sp)
    80000888:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000088a:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK; // MSTATUS_MPP_MASK 是MPP字段的掩码（表示上一次特权级）
    8000088e:	7779                	lui	a4,0xffffe
    80000890:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fff512f>
    80000894:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S; // 先清楚MPP字段，在设置为S（Supervisor）模式
    80000896:	6705                	lui	a4,0x1
    80000898:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000089c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000089e:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800008a2:	00000797          	auipc	a5,0x0
    800008a6:	90c78793          	addi	a5,a5,-1780 # 800001ae <main>
    800008aa:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800008ae:	4781                	li	a5,0
    800008b0:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800008b4:	67c1                	lui	a5,0x10
    800008b6:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800008b8:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800008bc:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800008c0:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800008c4:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800008c8:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800008cc:	57fd                	li	a5,-1
    800008ce:	83a9                	srli	a5,a5,0xa
    800008d0:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800008d4:	47bd                	li	a5,15
    800008d6:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800008da:	f65ff0ef          	jal	ra,8000083e <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800008de:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800008e2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800008e4:	823e                	mv	tp,a5
  asm volatile("mret"); 
    800008e6:	30200073          	mret
}
    800008ea:	60a2                	ld	ra,8(sp)
    800008ec:	6402                	ld	s0,0(sp)
    800008ee:	0141                	addi	sp,sp,16
    800008f0:	8082                	ret

00000000800008f2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    800008f2:	1141                	addi	sp,sp,-16
    800008f4:	e422                	sd	s0,8(sp)
    800008f6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    800008f8:	ca19                	beqz	a2,8000090e <memset+0x1c>
    800008fa:	87aa                	mv	a5,a0
    800008fc:	1602                	slli	a2,a2,0x20
    800008fe:	9201                	srli	a2,a2,0x20
    80000900:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000904:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000908:	0785                	addi	a5,a5,1
    8000090a:	fee79de3          	bne	a5,a4,80000904 <memset+0x12>
  }
  return dst;
}
    8000090e:	6422                	ld	s0,8(sp)
    80000910:	0141                	addi	sp,sp,16
    80000912:	8082                	ret

0000000080000914 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000914:	1141                	addi	sp,sp,-16
    80000916:	e422                	sd	s0,8(sp)
    80000918:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    8000091a:	ca05                	beqz	a2,8000094a <memcmp+0x36>
    8000091c:	fff6069b          	addiw	a3,a2,-1
    80000920:	1682                	slli	a3,a3,0x20
    80000922:	9281                	srli	a3,a3,0x20
    80000924:	0685                	addi	a3,a3,1
    80000926:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000928:	00054783          	lbu	a5,0(a0)
    8000092c:	0005c703          	lbu	a4,0(a1)
    80000930:	00e79863          	bne	a5,a4,80000940 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000934:	0505                	addi	a0,a0,1
    80000936:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000938:	fed518e3          	bne	a0,a3,80000928 <memcmp+0x14>
  }

  return 0;
    8000093c:	4501                	li	a0,0
    8000093e:	a019                	j	80000944 <memcmp+0x30>
      return *s1 - *s2;
    80000940:	40e7853b          	subw	a0,a5,a4
}
    80000944:	6422                	ld	s0,8(sp)
    80000946:	0141                	addi	sp,sp,16
    80000948:	8082                	ret
  return 0;
    8000094a:	4501                	li	a0,0
    8000094c:	bfe5                	j	80000944 <memcmp+0x30>

000000008000094e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    8000094e:	1141                	addi	sp,sp,-16
    80000950:	e422                	sd	s0,8(sp)
    80000952:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000954:	c205                	beqz	a2,80000974 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000956:	02a5e263          	bltu	a1,a0,8000097a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    8000095a:	1602                	slli	a2,a2,0x20
    8000095c:	9201                	srli	a2,a2,0x20
    8000095e:	00c587b3          	add	a5,a1,a2
{
    80000962:	872a                	mv	a4,a0
      *d++ = *s++;
    80000964:	0585                	addi	a1,a1,1
    80000966:	0705                	addi	a4,a4,1
    80000968:	fff5c683          	lbu	a3,-1(a1)
    8000096c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000970:	fef59ae3          	bne	a1,a5,80000964 <memmove+0x16>

  return dst;
}
    80000974:	6422                	ld	s0,8(sp)
    80000976:	0141                	addi	sp,sp,16
    80000978:	8082                	ret
  if(s < d && s + n > d){
    8000097a:	02061693          	slli	a3,a2,0x20
    8000097e:	9281                	srli	a3,a3,0x20
    80000980:	00d58733          	add	a4,a1,a3
    80000984:	fce57be3          	bgeu	a0,a4,8000095a <memmove+0xc>
    d += n;
    80000988:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    8000098a:	fff6079b          	addiw	a5,a2,-1
    8000098e:	1782                	slli	a5,a5,0x20
    80000990:	9381                	srli	a5,a5,0x20
    80000992:	fff7c793          	not	a5,a5
    80000996:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000998:	177d                	addi	a4,a4,-1
    8000099a:	16fd                	addi	a3,a3,-1
    8000099c:	00074603          	lbu	a2,0(a4)
    800009a0:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    800009a4:	fee79ae3          	bne	a5,a4,80000998 <memmove+0x4a>
    800009a8:	b7f1                	j	80000974 <memmove+0x26>

00000000800009aa <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    800009aa:	1141                	addi	sp,sp,-16
    800009ac:	e406                	sd	ra,8(sp)
    800009ae:	e022                	sd	s0,0(sp)
    800009b0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    800009b2:	f9dff0ef          	jal	ra,8000094e <memmove>
}
    800009b6:	60a2                	ld	ra,8(sp)
    800009b8:	6402                	ld	s0,0(sp)
    800009ba:	0141                	addi	sp,sp,16
    800009bc:	8082                	ret

00000000800009be <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    800009be:	1141                	addi	sp,sp,-16
    800009c0:	e422                	sd	s0,8(sp)
    800009c2:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    800009c4:	ce11                	beqz	a2,800009e0 <strncmp+0x22>
    800009c6:	00054783          	lbu	a5,0(a0)
    800009ca:	cf89                	beqz	a5,800009e4 <strncmp+0x26>
    800009cc:	0005c703          	lbu	a4,0(a1)
    800009d0:	00f71a63          	bne	a4,a5,800009e4 <strncmp+0x26>
    n--, p++, q++;
    800009d4:	367d                	addiw	a2,a2,-1
    800009d6:	0505                	addi	a0,a0,1
    800009d8:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    800009da:	f675                	bnez	a2,800009c6 <strncmp+0x8>
  if(n == 0)
    return 0;
    800009dc:	4501                	li	a0,0
    800009de:	a809                	j	800009f0 <strncmp+0x32>
    800009e0:	4501                	li	a0,0
    800009e2:	a039                	j	800009f0 <strncmp+0x32>
  if(n == 0)
    800009e4:	ca09                	beqz	a2,800009f6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    800009e6:	00054503          	lbu	a0,0(a0)
    800009ea:	0005c783          	lbu	a5,0(a1)
    800009ee:	9d1d                	subw	a0,a0,a5
}
    800009f0:	6422                	ld	s0,8(sp)
    800009f2:	0141                	addi	sp,sp,16
    800009f4:	8082                	ret
    return 0;
    800009f6:	4501                	li	a0,0
    800009f8:	bfe5                	j	800009f0 <strncmp+0x32>

00000000800009fa <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    800009fa:	1141                	addi	sp,sp,-16
    800009fc:	e422                	sd	s0,8(sp)
    800009fe:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000a00:	872a                	mv	a4,a0
    80000a02:	8832                	mv	a6,a2
    80000a04:	367d                	addiw	a2,a2,-1
    80000a06:	01005963          	blez	a6,80000a18 <strncpy+0x1e>
    80000a0a:	0705                	addi	a4,a4,1
    80000a0c:	0005c783          	lbu	a5,0(a1)
    80000a10:	fef70fa3          	sb	a5,-1(a4)
    80000a14:	0585                	addi	a1,a1,1
    80000a16:	f7f5                	bnez	a5,80000a02 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000a18:	86ba                	mv	a3,a4
    80000a1a:	00c05c63          	blez	a2,80000a32 <strncpy+0x38>
    *s++ = 0;
    80000a1e:	0685                	addi	a3,a3,1
    80000a20:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000a24:	40d707bb          	subw	a5,a4,a3
    80000a28:	37fd                	addiw	a5,a5,-1
    80000a2a:	010787bb          	addw	a5,a5,a6
    80000a2e:	fef048e3          	bgtz	a5,80000a1e <strncpy+0x24>
  return os;
}
    80000a32:	6422                	ld	s0,8(sp)
    80000a34:	0141                	addi	sp,sp,16
    80000a36:	8082                	ret

0000000080000a38 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000a38:	1141                	addi	sp,sp,-16
    80000a3a:	e422                	sd	s0,8(sp)
    80000a3c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000a3e:	02c05363          	blez	a2,80000a64 <safestrcpy+0x2c>
    80000a42:	fff6069b          	addiw	a3,a2,-1
    80000a46:	1682                	slli	a3,a3,0x20
    80000a48:	9281                	srli	a3,a3,0x20
    80000a4a:	96ae                	add	a3,a3,a1
    80000a4c:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000a4e:	00d58963          	beq	a1,a3,80000a60 <safestrcpy+0x28>
    80000a52:	0585                	addi	a1,a1,1
    80000a54:	0785                	addi	a5,a5,1
    80000a56:	fff5c703          	lbu	a4,-1(a1)
    80000a5a:	fee78fa3          	sb	a4,-1(a5)
    80000a5e:	fb65                	bnez	a4,80000a4e <safestrcpy+0x16>
    ;
  *s = 0;
    80000a60:	00078023          	sb	zero,0(a5)
  return os;
}
    80000a64:	6422                	ld	s0,8(sp)
    80000a66:	0141                	addi	sp,sp,16
    80000a68:	8082                	ret

0000000080000a6a <strlen>:

int
strlen(const char *s)
{
    80000a6a:	1141                	addi	sp,sp,-16
    80000a6c:	e422                	sd	s0,8(sp)
    80000a6e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000a70:	00054783          	lbu	a5,0(a0)
    80000a74:	cf91                	beqz	a5,80000a90 <strlen+0x26>
    80000a76:	0505                	addi	a0,a0,1
    80000a78:	87aa                	mv	a5,a0
    80000a7a:	4685                	li	a3,1
    80000a7c:	9e89                	subw	a3,a3,a0
    80000a7e:	00f6853b          	addw	a0,a3,a5
    80000a82:	0785                	addi	a5,a5,1
    80000a84:	fff7c703          	lbu	a4,-1(a5)
    80000a88:	fb7d                	bnez	a4,80000a7e <strlen+0x14>
    ;
  return n;
}
    80000a8a:	6422                	ld	s0,8(sp)
    80000a8c:	0141                	addi	sp,sp,16
    80000a8e:	8082                	ret
  for(n = 0; s[n]; n++)
    80000a90:	4501                	li	a0,0
    80000a92:	bfe5                	j	80000a8a <strlen+0x20>

0000000080000a94 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80000a94:	1141                	addi	sp,sp,-16
    80000a96:	e406                	sd	ra,8(sp)
    80000a98:	e022                	sd	s0,0(sp)
    80000a9a:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80000a9c:	00000597          	auipc	a1,0x0
    80000aa0:	60c58593          	addi	a1,a1,1548 # 800010a8 <digits+0x48>
    80000aa4:	00009517          	auipc	a0,0x9
    80000aa8:	bdc50513          	addi	a0,a0,-1060 # 80009680 <tickslock>
    80000aac:	c3fff0ef          	jal	ra,800006ea <initlock>
}
    80000ab0:	60a2                	ld	ra,8(sp)
    80000ab2:	6402                	ld	s0,0(sp)
    80000ab4:	0141                	addi	sp,sp,16
    80000ab6:	8082                	ret

0000000080000ab8 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80000ab8:	1141                	addi	sp,sp,-16
    80000aba:	e422                	sd	s0,8(sp)
    80000abc:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80000abe:	fffff797          	auipc	a5,0xfffff
    80000ac2:	69278793          	addi	a5,a5,1682 # 80000150 <kernelvec>
    80000ac6:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80000aca:	6422                	ld	s0,8(sp)
    80000acc:	0141                	addi	sp,sp,16
    80000ace:	8082                	ret

0000000080000ad0 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80000ad0:	1141                	addi	sp,sp,-16
    80000ad2:	e406                	sd	ra,8(sp)
    80000ad4:	e022                	sd	s0,0(sp)
    80000ad6:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000ad8:	be7ff0ef          	jal	ra,800006be <cpuid>
    80000adc:	cd11                	beqz	a0,80000af8 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80000ade:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80000ae2:	000f4737          	lui	a4,0xf4
    80000ae6:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000aea:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000aec:	14d79073          	csrw	0x14d,a5
}
    80000af0:	60a2                	ld	ra,8(sp)
    80000af2:	6402                	ld	s0,0(sp)
    80000af4:	0141                	addi	sp,sp,16
    80000af6:	8082                	ret
    acquire(&tickslock);
    80000af8:	00009517          	auipc	a0,0x9
    80000afc:	b8850513          	addi	a0,a0,-1144 # 80009680 <tickslock>
    80000b00:	c6bff0ef          	jal	ra,8000076a <acquire>
    ticks++;
    80000b04:	00000717          	auipc	a4,0x0
    80000b08:	71470713          	addi	a4,a4,1812 # 80001218 <ticks>
    80000b0c:	431c                	lw	a5,0(a4)
    80000b0e:	2785                	addiw	a5,a5,1
    80000b10:	c31c                	sw	a5,0(a4)
    if(ticks % 30 == 0){ //每30次时钟中断打印出一个T
    80000b12:	4779                	li	a4,30
    80000b14:	02e7f7bb          	remuw	a5,a5,a4
    80000b18:	cb81                	beqz	a5,80000b28 <clockintr+0x58>
    release(&tickslock);
    80000b1a:	00009517          	auipc	a0,0x9
    80000b1e:	b6650513          	addi	a0,a0,-1178 # 80009680 <tickslock>
    80000b22:	ce1ff0ef          	jal	ra,80000802 <release>
    80000b26:	bf65                	j	80000ade <clockintr+0xe>
        printf("T");
    80000b28:	00000517          	auipc	a0,0x0
    80000b2c:	58850513          	addi	a0,a0,1416 # 800010b0 <digits+0x50>
    80000b30:	86fff0ef          	jal	ra,8000039e <printf>
    80000b34:	b7dd                	j	80000b1a <clockintr+0x4a>

0000000080000b36 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80000b36:	1101                	addi	sp,sp,-32
    80000b38:	ec06                	sd	ra,24(sp)
    80000b3a:	e822                	sd	s0,16(sp)
    80000b3c:	e426                	sd	s1,8(sp)
    80000b3e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80000b40:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80000b44:	57fd                	li	a5,-1
    80000b46:	17fe                	slli	a5,a5,0x3f
    80000b48:	07a5                	addi	a5,a5,9
    80000b4a:	00f70d63          	beq	a4,a5,80000b64 <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80000b4e:	57fd                	li	a5,-1
    80000b50:	17fe                	slli	a5,a5,0x3f
    80000b52:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80000b54:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80000b56:	04f70863          	beq	a4,a5,80000ba6 <devintr+0x70>
  }
}
    80000b5a:	60e2                	ld	ra,24(sp)
    80000b5c:	6442                	ld	s0,16(sp)
    80000b5e:	64a2                	ld	s1,8(sp)
    80000b60:	6105                	addi	sp,sp,32
    80000b62:	8082                	ret
    int irq = plic_claim();
    80000b64:	f30ff0ef          	jal	ra,80000294 <plic_claim>
    80000b68:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80000b6a:	47a9                	li	a5,10
    80000b6c:	02f50363          	beq	a0,a5,80000b92 <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80000b70:	4785                	li	a5,1
    80000b72:	02f50363          	beq	a0,a5,80000b98 <devintr+0x62>
    return 1;
    80000b76:	4505                	li	a0,1
    } else if(irq){
    80000b78:	d0ed                	beqz	s1,80000b5a <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80000b7a:	85a6                	mv	a1,s1
    80000b7c:	00000517          	auipc	a0,0x0
    80000b80:	55c50513          	addi	a0,a0,1372 # 800010d8 <digits+0x78>
    80000b84:	81bff0ef          	jal	ra,8000039e <printf>
      plic_complete(irq);
    80000b88:	8526                	mv	a0,s1
    80000b8a:	f2aff0ef          	jal	ra,800002b4 <plic_complete>
    return 1;
    80000b8e:	4505                	li	a0,1
    80000b90:	b7e9                	j	80000b5a <devintr+0x24>
      uartintr();
    80000b92:	14e000ef          	jal	ra,80000ce0 <uartintr>
    80000b96:	bfcd                	j	80000b88 <devintr+0x52>
    printf("virtio_disk_intr in trap.c\n");
    80000b98:	00000517          	auipc	a0,0x0
    80000b9c:	52050513          	addi	a0,a0,1312 # 800010b8 <digits+0x58>
    80000ba0:	ffeff0ef          	jal	ra,8000039e <printf>
    80000ba4:	b7d5                	j	80000b88 <devintr+0x52>
    clockintr();
    80000ba6:	f2bff0ef          	jal	ra,80000ad0 <clockintr>
    return 2;
    80000baa:	4509                	li	a0,2
    80000bac:	b77d                	j	80000b5a <devintr+0x24>

0000000080000bae <kerneltrap>:
{
    80000bae:	7179                	addi	sp,sp,-48
    80000bb0:	f406                	sd	ra,40(sp)
    80000bb2:	f022                	sd	s0,32(sp)
    80000bb4:	ec26                	sd	s1,24(sp)
    80000bb6:	e84a                	sd	s2,16(sp)
    80000bb8:	e44e                	sd	s3,8(sp)
    80000bba:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80000bbc:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bc0:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80000bc4:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80000bc8:	1004f793          	andi	a5,s1,256
    80000bcc:	c39d                	beqz	a5,80000bf2 <kerneltrap+0x44>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bce:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000bd2:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80000bd4:	e78d                	bnez	a5,80000bfe <kerneltrap+0x50>
  if((which_dev = devintr()) == 0){
    80000bd6:	f61ff0ef          	jal	ra,80000b36 <devintr>
    80000bda:	c905                	beqz	a0,80000c0a <kerneltrap+0x5c>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80000bdc:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000be0:	10049073          	csrw	sstatus,s1
}
    80000be4:	70a2                	ld	ra,40(sp)
    80000be6:	7402                	ld	s0,32(sp)
    80000be8:	64e2                	ld	s1,24(sp)
    80000bea:	6942                	ld	s2,16(sp)
    80000bec:	69a2                	ld	s3,8(sp)
    80000bee:	6145                	addi	sp,sp,48
    80000bf0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80000bf2:	00000517          	auipc	a0,0x0
    80000bf6:	50650513          	addi	a0,a0,1286 # 800010f8 <digits+0x98>
    80000bfa:	a59ff0ef          	jal	ra,80000652 <panic>
    panic("kerneltrap: interrupts enabled");
    80000bfe:	00000517          	auipc	a0,0x0
    80000c02:	52250513          	addi	a0,a0,1314 # 80001120 <digits+0xc0>
    80000c06:	a4dff0ef          	jal	ra,80000652 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80000c0a:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80000c0e:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80000c12:	85ce                	mv	a1,s3
    80000c14:	00000517          	auipc	a0,0x0
    80000c18:	52c50513          	addi	a0,a0,1324 # 80001140 <digits+0xe0>
    80000c1c:	f82ff0ef          	jal	ra,8000039e <printf>
    panic("kerneltrap");
    80000c20:	00000517          	auipc	a0,0x0
    80000c24:	54850513          	addi	a0,a0,1352 # 80001168 <digits+0x108>
    80000c28:	a2bff0ef          	jal	ra,80000652 <panic>

0000000080000c2c <uartinit>:

// 原本是被console.c调用，现在被printf.c调用
// 作用：初始化UART硬件
void
uartinit(void)
{
    80000c2c:	1141                	addi	sp,sp,-16
    80000c2e:	e406                	sd	ra,8(sp)
    80000c30:	e022                	sd	s0,0(sp)
    80000c32:	0800                	addi	s0,sp,16
  // disable interrupts.
  // 关闭中断
  WriteReg(IER, 0x00);
    80000c34:	100007b7          	lui	a5,0x10000
    80000c38:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  // 设置波特率
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000c3c:	f8000713          	li	a4,-128
    80000c40:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  // 配置数据格式
  WriteReg(0, 0x03);
    80000c44:	470d                	li	a4,3
    80000c46:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  // 使能并清空FIFO
  WriteReg(1, 0x00);
    80000c4a:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000c4e:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000c52:	469d                	li	a3,7
    80000c54:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000c58:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000c5c:	00000597          	auipc	a1,0x0
    80000c60:	51c58593          	addi	a1,a1,1308 # 80001178 <digits+0x118>
    80000c64:	00009517          	auipc	a0,0x9
    80000c68:	a3450513          	addi	a0,a0,-1484 # 80009698 <uart_tx_lock>
    80000c6c:	a7fff0ef          	jal	ra,800006ea <initlock>
}
    80000c70:	60a2                	ld	ra,8(sp)
    80000c72:	6402                	ld	s0,0(sp)
    80000c74:	0141                	addi	sp,sp,16
    80000c76:	8082                	ret

0000000080000c78 <uartputc_sync>:
// to echo characters. it spins waiting for the uart's
// output register to be empty.
// 直接（同步）发送一个字符到UART
void
uartputc_sync(int c)
{
    80000c78:	1101                	addi	sp,sp,-32
    80000c7a:	ec06                	sd	ra,24(sp)
    80000c7c:	e822                	sd	s0,16(sp)
    80000c7e:	e426                	sd	s1,8(sp)
    80000c80:	1000                	addi	s0,sp,32
    80000c82:	84aa                	mv	s1,a0
  push_off();
    80000c84:	aa7ff0ef          	jal	ra,8000072a <push_off>

  if(panicked){
    80000c88:	00000797          	auipc	a5,0x0
    80000c8c:	58c7a783          	lw	a5,1420(a5) # 80001214 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000c90:	10000737          	lui	a4,0x10000
  if(panicked){
    80000c94:	c391                	beqz	a5,80000c98 <uartputc_sync+0x20>
    for(;;)
    80000c96:	a001                	j	80000c96 <uartputc_sync+0x1e>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000c98:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000c9c:	0207f793          	andi	a5,a5,32
    80000ca0:	dfe5                	beqz	a5,80000c98 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    80000ca2:	0ff4f513          	zext.b	a0,s1
    80000ca6:	100007b7          	lui	a5,0x10000
    80000caa:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000cae:	b01ff0ef          	jal	ra,800007ae <pop_off>
}
    80000cb2:	60e2                	ld	ra,24(sp)
    80000cb4:	6442                	ld	s0,16(sp)
    80000cb6:	64a2                	ld	s1,8(sp)
    80000cb8:	6105                	addi	sp,sp,32
    80000cba:	8082                	ret

0000000080000cbc <uartgetc>:
// read one input character from the UART.
// return -1 if none is waiting.
// 从UART读取一个输入字符
int
uartgetc(void)
{
    80000cbc:	1141                	addi	sp,sp,-16
    80000cbe:	e422                	sd	s0,8(sp)
    80000cc0:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000cc2:	100007b7          	lui	a5,0x10000
    80000cc6:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000cca:	8b85                	andi	a5,a5,1
    80000ccc:	cb81                	beqz	a5,80000cdc <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000cce:	100007b7          	lui	a5,0x10000
    80000cd2:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80000cd6:	6422                	ld	s0,8(sp)
    80000cd8:	0141                	addi	sp,sp,16
    80000cda:	8082                	ret
    return -1;
    80000cdc:	557d                	li	a0,-1
    80000cde:	bfe5                	j	80000cd6 <uartgetc+0x1a>

0000000080000ce0 <uartintr>:
// arrived, or the uart is ready for more output, or
// both. called from devintr().
// UART中断处理函数
void
uartintr(void)
{
    80000ce0:	1101                	addi	sp,sp,-32
    80000ce2:	ec06                	sd	ra,24(sp)
    80000ce4:	e822                	sd	s0,16(sp)
    80000ce6:	e426                	sd	s1,8(sp)
    80000ce8:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc(); // 这个就是从UART寄存器读取一个字符
    if(c == -1)
    80000cea:	54fd                	li	s1,-1
    80000cec:	a019                	j	80000cf2 <uartintr+0x12>
      break;
    // 这个好像委托到console.c的consoleintr()函数处理
    // 老师的意思好像是直接调用那个同步的putc发送
    // 这里不能使用console.c的文件
    // consoleintr(c); 
    pputc(c); // 直接调用printf.c的pputc函数发送字符
    80000cee:	decff0ef          	jal	ra,800002da <pputc>
    int c = uartgetc(); // 这个就是从UART寄存器读取一个字符
    80000cf2:	fcbff0ef          	jal	ra,80000cbc <uartgetc>
    if(c == -1)
    80000cf6:	fe951ce3          	bne	a0,s1,80000cee <uartintr+0xe>

  // send buffered characters.
  // acquire(&uart_tx_lock);
  // uartstart();
  // release(&uart_tx_lock);
}
    80000cfa:	60e2                	ld	ra,24(sp)
    80000cfc:	6442                	ld	s0,16(sp)
    80000cfe:	64a2                	ld	s1,8(sp)
    80000d00:	6105                	addi	sp,sp,32
    80000d02:	8082                	ret

0000000080000d04 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000d04:	1141                	addi	sp,sp,-16
    80000d06:	e422                	sd	s0,8(sp)
    80000d08:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000d0a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  // 应该是将TLB中的内容清空，内核更换的时候应该都要做
  sfence_vma();

  // 将kernel_pagetable的地址写入每个CPU核的satp寄存器中
  w_satp(MAKE_SATP(kernel_pagetable));
    80000d0e:	00000797          	auipc	a5,0x0
    80000d12:	5227b783          	ld	a5,1314(a5) # 80001230 <kernel_pagetable>
    80000d16:	83b1                	srli	a5,a5,0xc
    80000d18:	577d                	li	a4,-1
    80000d1a:	177e                	slli	a4,a4,0x3f
    80000d1c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000d1e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000d22:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  // 不知道是不是再清空一遍TLB
  sfence_vma();
}
    80000d26:	6422                	ld	s0,8(sp)
    80000d28:	0141                	addi	sp,sp,16
    80000d2a:	8082                	ret

0000000080000d2c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000d2c:	7139                	addi	sp,sp,-64
    80000d2e:	fc06                	sd	ra,56(sp)
    80000d30:	f822                	sd	s0,48(sp)
    80000d32:	f426                	sd	s1,40(sp)
    80000d34:	f04a                	sd	s2,32(sp)
    80000d36:	ec4e                	sd	s3,24(sp)
    80000d38:	e852                	sd	s4,16(sp)
    80000d3a:	e456                	sd	s5,8(sp)
    80000d3c:	e05a                	sd	s6,0(sp)
    80000d3e:	0080                	addi	s0,sp,64
    80000d40:	84aa                	mv	s1,a0
    80000d42:	89ae                	mv	s3,a1
    80000d44:	8ab2                	mv	s5,a2
  // 首先检查va是否超出了最大的虚拟地址
  if(va >= MAXVA)
    80000d46:	57fd                	li	a5,-1
    80000d48:	83e9                	srli	a5,a5,0x1a
    80000d4a:	4a79                	li	s4,30
    panic("walk");
  
  for(int level = 2; level > 0; level--) {
    80000d4c:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000d4e:	02b7fc63          	bgeu	a5,a1,80000d86 <walk+0x5a>
    panic("walk");
    80000d52:	00000517          	auipc	a0,0x0
    80000d56:	42e50513          	addi	a0,a0,1070 # 80001180 <digits+0x120>
    80000d5a:	8f9ff0ef          	jal	ra,80000652 <panic>
    //查找以pagetable为基址的页表中，序号为VPN[level]的条目
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) { // 如果这个条目是有效的
      pagetable = (pagetable_t)PTE2PA(*pte);  // 取出这个条目对应的物理页面基址
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0) // 如果是一个无效的条目并且不允许分配就返回了
    80000d5e:	060a8263          	beqz	s5,80000dc2 <walk+0x96>
    80000d62:	b9cff0ef          	jal	ra,800000fe <kalloc>
    80000d66:	84aa                	mv	s1,a0
    80000d68:	c139                	beqz	a0,80000dae <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000d6a:	6605                	lui	a2,0x1
    80000d6c:	4581                	li	a1,0
    80000d6e:	b85ff0ef          	jal	ra,800008f2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V; // 如果允许分配，就将这个条目记录在这个页表中，并设置有效位
    80000d72:	00c4d793          	srli	a5,s1,0xc
    80000d76:	07aa                	slli	a5,a5,0xa
    80000d78:	0017e793          	ori	a5,a5,1
    80000d7c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000d80:	3a5d                	addiw	s4,s4,-9
    80000d82:	036a0063          	beq	s4,s6,80000da2 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000d86:	0149d933          	srl	s2,s3,s4
    80000d8a:	1ff97913          	andi	s2,s2,511
    80000d8e:	090e                	slli	s2,s2,0x3
    80000d90:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) { // 如果这个条目是有效的
    80000d92:	00093483          	ld	s1,0(s2)
    80000d96:	0014f793          	andi	a5,s1,1
    80000d9a:	d3f1                	beqz	a5,80000d5e <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);  // 取出这个条目对应的物理页面基址
    80000d9c:	80a9                	srli	s1,s1,0xa
    80000d9e:	04b2                	slli	s1,s1,0xc
    80000da0:	b7c5                	j	80000d80 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];  // 返回三级页表中序号为VPN[0]的条目地址
    80000da2:	00c9d513          	srli	a0,s3,0xc
    80000da6:	1ff57513          	andi	a0,a0,511
    80000daa:	050e                	slli	a0,a0,0x3
    80000dac:	9526                	add	a0,a0,s1
}
    80000dae:	70e2                	ld	ra,56(sp)
    80000db0:	7442                	ld	s0,48(sp)
    80000db2:	74a2                	ld	s1,40(sp)
    80000db4:	7902                	ld	s2,32(sp)
    80000db6:	69e2                	ld	s3,24(sp)
    80000db8:	6a42                	ld	s4,16(sp)
    80000dba:	6aa2                	ld	s5,8(sp)
    80000dbc:	6b02                	ld	s6,0(sp)
    80000dbe:	6121                	addi	sp,sp,64
    80000dc0:	8082                	ret
        return 0;
    80000dc2:	4501                	li	a0,0
    80000dc4:	b7ed                	j	80000dae <walk+0x82>

0000000080000dc6 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000dc6:	715d                	addi	sp,sp,-80
    80000dc8:	e486                	sd	ra,72(sp)
    80000dca:	e0a2                	sd	s0,64(sp)
    80000dcc:	fc26                	sd	s1,56(sp)
    80000dce:	f84a                	sd	s2,48(sp)
    80000dd0:	f44e                	sd	s3,40(sp)
    80000dd2:	f052                	sd	s4,32(sp)
    80000dd4:	ec56                	sd	s5,24(sp)
    80000dd6:	e85a                	sd	s6,16(sp)
    80000dd8:	e45e                	sd	s7,8(sp)
    80000dda:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80000ddc:	03459793          	slli	a5,a1,0x34
    80000de0:	e7a9                	bnez	a5,80000e2a <mappages+0x64>
    80000de2:	8aaa                	mv	s5,a0
    80000de4:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80000de6:	03461793          	slli	a5,a2,0x34
    80000dea:	e7b1                	bnez	a5,80000e36 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    80000dec:	ca39                	beqz	a2,80000e42 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80000dee:	77fd                	lui	a5,0xfffff
    80000df0:	963e                	add	a2,a2,a5
    80000df2:	00b609b3          	add	s3,a2,a1
  a = va;
    80000df6:	892e                	mv	s2,a1
    80000df8:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V; // 将内容填写到表项上面去pte-> ppn-perm 物理地址前面部分-标志位
    if(a == last)
      break;
    a += PGSIZE;
    80000dfc:	6b85                	lui	s7,0x1
    80000dfe:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80000e02:	4605                	li	a2,1
    80000e04:	85ca                	mv	a1,s2
    80000e06:	8556                	mv	a0,s5
    80000e08:	f25ff0ef          	jal	ra,80000d2c <walk>
    80000e0c:	c539                	beqz	a0,80000e5a <mappages+0x94>
    if(*pte & PTE_V)
    80000e0e:	611c                	ld	a5,0(a0)
    80000e10:	8b85                	andi	a5,a5,1
    80000e12:	ef95                	bnez	a5,80000e4e <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V; // 将内容填写到表项上面去pte-> ppn-perm 物理地址前面部分-标志位
    80000e14:	80b1                	srli	s1,s1,0xc
    80000e16:	04aa                	slli	s1,s1,0xa
    80000e18:	0164e4b3          	or	s1,s1,s6
    80000e1c:	0014e493          	ori	s1,s1,1
    80000e20:	e104                	sd	s1,0(a0)
    if(a == last)
    80000e22:	05390863          	beq	s2,s3,80000e72 <mappages+0xac>
    a += PGSIZE;
    80000e26:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80000e28:	bfd9                	j	80000dfe <mappages+0x38>
    panic("mappages: va not aligned");
    80000e2a:	00000517          	auipc	a0,0x0
    80000e2e:	35e50513          	addi	a0,a0,862 # 80001188 <digits+0x128>
    80000e32:	821ff0ef          	jal	ra,80000652 <panic>
    panic("mappages: size not aligned");
    80000e36:	00000517          	auipc	a0,0x0
    80000e3a:	37250513          	addi	a0,a0,882 # 800011a8 <digits+0x148>
    80000e3e:	815ff0ef          	jal	ra,80000652 <panic>
    panic("mappages: size");
    80000e42:	00000517          	auipc	a0,0x0
    80000e46:	38650513          	addi	a0,a0,902 # 800011c8 <digits+0x168>
    80000e4a:	809ff0ef          	jal	ra,80000652 <panic>
      panic("mappages: remap");
    80000e4e:	00000517          	auipc	a0,0x0
    80000e52:	38a50513          	addi	a0,a0,906 # 800011d8 <digits+0x178>
    80000e56:	ffcff0ef          	jal	ra,80000652 <panic>
      return -1;
    80000e5a:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80000e5c:	60a6                	ld	ra,72(sp)
    80000e5e:	6406                	ld	s0,64(sp)
    80000e60:	74e2                	ld	s1,56(sp)
    80000e62:	7942                	ld	s2,48(sp)
    80000e64:	79a2                	ld	s3,40(sp)
    80000e66:	7a02                	ld	s4,32(sp)
    80000e68:	6ae2                	ld	s5,24(sp)
    80000e6a:	6b42                	ld	s6,16(sp)
    80000e6c:	6ba2                	ld	s7,8(sp)
    80000e6e:	6161                	addi	sp,sp,80
    80000e70:	8082                	ret
  return 0;
    80000e72:	4501                	li	a0,0
    80000e74:	b7e5                	j	80000e5c <mappages+0x96>

0000000080000e76 <kvmmap>:
{
    80000e76:	1141                	addi	sp,sp,-16
    80000e78:	e406                	sd	ra,8(sp)
    80000e7a:	e022                	sd	s0,0(sp)
    80000e7c:	0800                	addi	s0,sp,16
    80000e7e:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80000e80:	86b2                	mv	a3,a2
    80000e82:	863e                	mv	a2,a5
    80000e84:	f43ff0ef          	jal	ra,80000dc6 <mappages>
    80000e88:	e509                	bnez	a0,80000e92 <kvmmap+0x1c>
}
    80000e8a:	60a2                	ld	ra,8(sp)
    80000e8c:	6402                	ld	s0,0(sp)
    80000e8e:	0141                	addi	sp,sp,16
    80000e90:	8082                	ret
    panic("kvmmap");
    80000e92:	00000517          	auipc	a0,0x0
    80000e96:	35650513          	addi	a0,a0,854 # 800011e8 <digits+0x188>
    80000e9a:	fb8ff0ef          	jal	ra,80000652 <panic>

0000000080000e9e <kvmmake>:
{
    80000e9e:	1101                	addi	sp,sp,-32
    80000ea0:	ec06                	sd	ra,24(sp)
    80000ea2:	e822                	sd	s0,16(sp)
    80000ea4:	e426                	sd	s1,8(sp)
    80000ea6:	e04a                	sd	s2,0(sp)
    80000ea8:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80000eaa:	a54ff0ef          	jal	ra,800000fe <kalloc>
    80000eae:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80000eb0:	6605                	lui	a2,0x1
    80000eb2:	4581                	li	a1,0
    80000eb4:	a3fff0ef          	jal	ra,800008f2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80000eb8:	4719                	li	a4,6
    80000eba:	6685                	lui	a3,0x1
    80000ebc:	10000637          	lui	a2,0x10000
    80000ec0:	100005b7          	lui	a1,0x10000
    80000ec4:	8526                	mv	a0,s1
    80000ec6:	fb1ff0ef          	jal	ra,80000e76 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80000eca:	4719                	li	a4,6
    80000ecc:	040006b7          	lui	a3,0x4000
    80000ed0:	0c000637          	lui	a2,0xc000
    80000ed4:	0c0005b7          	lui	a1,0xc000
    80000ed8:	8526                	mv	a0,s1
    80000eda:	f9dff0ef          	jal	ra,80000e76 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80000ede:	00000917          	auipc	s2,0x0
    80000ee2:	12290913          	addi	s2,s2,290 # 80001000 <etext>
    80000ee6:	4729                	li	a4,10
    80000ee8:	80000697          	auipc	a3,0x80000
    80000eec:	11868693          	addi	a3,a3,280 # 1000 <_entry-0x7ffff000>
    80000ef0:	4605                	li	a2,1
    80000ef2:	067e                	slli	a2,a2,0x1f
    80000ef4:	85b2                	mv	a1,a2
    80000ef6:	8526                	mv	a0,s1
    80000ef8:	f7fff0ef          	jal	ra,80000e76 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80000efc:	4719                	li	a4,6
    80000efe:	46c5                	li	a3,17
    80000f00:	06ee                	slli	a3,a3,0x1b
    80000f02:	412686b3          	sub	a3,a3,s2
    80000f06:	864a                	mv	a2,s2
    80000f08:	85ca                	mv	a1,s2
    80000f0a:	8526                	mv	a0,s1
    80000f0c:	f6bff0ef          	jal	ra,80000e76 <kvmmap>
}
    80000f10:	8526                	mv	a0,s1
    80000f12:	60e2                	ld	ra,24(sp)
    80000f14:	6442                	ld	s0,16(sp)
    80000f16:	64a2                	ld	s1,8(sp)
    80000f18:	6902                	ld	s2,0(sp)
    80000f1a:	6105                	addi	sp,sp,32
    80000f1c:	8082                	ret

0000000080000f1e <kvminit>:
{
    80000f1e:	1141                	addi	sp,sp,-16
    80000f20:	e406                	sd	ra,8(sp)
    80000f22:	e022                	sd	s0,0(sp)
    80000f24:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80000f26:	f79ff0ef          	jal	ra,80000e9e <kvmmake>
    80000f2a:	00000797          	auipc	a5,0x0
    80000f2e:	30a7b323          	sd	a0,774(a5) # 80001230 <kernel_pagetable>
}
    80000f32:	60a2                	ld	ra,8(sp)
    80000f34:	6402                	ld	s0,0(sp)
    80000f36:	0141                	addi	sp,sp,16
    80000f38:	8082                	ret
	...
