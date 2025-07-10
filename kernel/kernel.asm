
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	a8813103          	ld	sp,-1400(sp) # 80007a88 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	4b0010ef          	jal	ra,800014c6 <start>

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
    80000030:	0001e797          	auipc	a5,0x1e
    80000034:	cd078793          	addi	a5,a5,-816 # 8001dd00 <end>
    80000038:	02f56f63          	bltu	a0,a5,80000076 <kfree+0x5a>
    8000003c:	47c5                	li	a5,17
    8000003e:	07ee                	slli	a5,a5,0x1b
    80000040:	02f57b63          	bgeu	a0,a5,80000076 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000044:	6605                	lui	a2,0x1
    80000046:	4585                	li	a1,1
    80000048:	4ee010ef          	jal	ra,80001536 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    8000004c:	00008917          	auipc	s2,0x8
    80000050:	a8490913          	addi	s2,s2,-1404 # 80007ad0 <kmem>
    80000054:	854a                	mv	a0,s2
    80000056:	358010ef          	jal	ra,800013ae <acquire>
  r->next = kmem.freelist;
    8000005a:	01893783          	ld	a5,24(s2)
    8000005e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000060:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000064:	854a                	mv	a0,s2
    80000066:	3e0010ef          	jal	ra,80001446 <release>
}
    8000006a:	60e2                	ld	ra,24(sp)
    8000006c:	6442                	ld	s0,16(sp)
    8000006e:	64a2                	ld	s1,8(sp)
    80000070:	6902                	ld	s2,0(sp)
    80000072:	6105                	addi	sp,sp,32
    80000074:	8082                	ret
    panic("kfree");
    80000076:	00006517          	auipc	a0,0x6
    8000007a:	f9a50513          	addi	a0,a0,-102 # 80006010 <etext+0x10>
    8000007e:	5f2000ef          	jal	ra,80000670 <panic>

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
    800000d2:	00006597          	auipc	a1,0x6
    800000d6:	f4658593          	addi	a1,a1,-186 # 80006018 <etext+0x18>
    800000da:	00008517          	auipc	a0,0x8
    800000de:	9f650513          	addi	a0,a0,-1546 # 80007ad0 <kmem>
    800000e2:	24c010ef          	jal	ra,8000132e <initlock>
  freerange(end, (void*)PHYSTOP);
    800000e6:	45c5                	li	a1,17
    800000e8:	05ee                	slli	a1,a1,0x1b
    800000ea:	0001e517          	auipc	a0,0x1e
    800000ee:	c1650513          	addi	a0,a0,-1002 # 8001dd00 <end>
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
    80000108:	00008497          	auipc	s1,0x8
    8000010c:	9c848493          	addi	s1,s1,-1592 # 80007ad0 <kmem>
    80000110:	8526                	mv	a0,s1
    80000112:	29c010ef          	jal	ra,800013ae <acquire>
  r = kmem.freelist;
    80000116:	6c84                	ld	s1,24(s1)
  if(r)
    80000118:	c485                	beqz	s1,80000140 <kalloc+0x42>
    kmem.freelist = r->next;
    8000011a:	609c                	ld	a5,0(s1)
    8000011c:	00008517          	auipc	a0,0x8
    80000120:	9b450513          	addi	a0,a0,-1612 # 80007ad0 <kmem>
    80000124:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000126:	320010ef          	jal	ra,80001446 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    8000012a:	6605                	lui	a2,0x1
    8000012c:	4595                	li	a1,5
    8000012e:	8526                	mv	a0,s1
    80000130:	406010ef          	jal	ra,80001536 <memset>
  return (void*)r;
}
    80000134:	8526                	mv	a0,s1
    80000136:	60e2                	ld	ra,24(sp)
    80000138:	6442                	ld	s0,16(sp)
    8000013a:	64a2                	ld	s1,8(sp)
    8000013c:	6105                	addi	sp,sp,32
    8000013e:	8082                	ret
  release(&kmem.lock);
    80000140:	00008517          	auipc	a0,0x8
    80000144:	99050513          	addi	a0,a0,-1648 # 80007ad0 <kmem>
    80000148:	2fe010ef          	jal	ra,80001446 <release>
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
    80000178:	631010ef          	jal	ra,80001fa8 <kerneltrap>
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
    800001b6:	654000ef          	jal	ra,8000080a <cpuid>

    // started = 1;
    // __sync_synchronize();
    // userinit();
  } else {
    while(started == 0)
    800001ba:	00008717          	auipc	a4,0x8
    800001be:	8e670713          	addi	a4,a4,-1818 # 80007aa0 <started>
  if(cpuid() == 0){
    800001c2:	c51d                	beqz	a0,800001f0 <main+0x42>
    while(started == 0)
    800001c4:	431c                	lw	a5,0(a4)
    800001c6:	2781                	sext.w	a5,a5
    800001c8:	dff5                	beqz	a5,800001c4 <main+0x16>
      ;
    __sync_synchronize();
    800001ca:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    800001ce:	63c000ef          	jal	ra,8000080a <cpuid>
    800001d2:	85aa                	mv	a1,a0
    800001d4:	00006517          	auipc	a0,0x6
    800001d8:	e8450513          	addi	a0,a0,-380 # 80006058 <etext+0x58>
    800001dc:	1e0000ef          	jal	ra,800003bc <printf>
    
    // 内存处理部分
    kvminithart();    // turn on paging
    800001e0:	080020ef          	jal	ra,80002260 <kvminithart>

    // 中断处理部分
    trapinithart();   // install kernel trap vector
    800001e4:	361010ef          	jal	ra,80001d44 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    800001e8:	096000ef          	jal	ra,8000027e <plicinithart>
  }
  scheduler();        
    800001ec:	3dd000ef          	jal	ra,80000dc8 <scheduler>
    uartinit();
    800001f0:	649010ef          	jal	ra,80002038 <uartinit>
    printfinit();
    800001f4:	4b6000ef          	jal	ra,800006aa <printfinit>
    printf("\n");
    800001f8:	00006517          	auipc	a0,0x6
    800001fc:	e7050513          	addi	a0,a0,-400 # 80006068 <etext+0x68>
    80000200:	1bc000ef          	jal	ra,800003bc <printf>
    printf("xv6 kernel is booting\n");
    80000204:	00006517          	auipc	a0,0x6
    80000208:	e1c50513          	addi	a0,a0,-484 # 80006020 <etext+0x20>
    8000020c:	1b0000ef          	jal	ra,800003bc <printf>
    printf("\n");
    80000210:	00006517          	auipc	a0,0x6
    80000214:	e5850513          	addi	a0,a0,-424 # 80006068 <etext+0x68>
    80000218:	1a4000ef          	jal	ra,800003bc <printf>
    kinit();         // physical page allocator
    8000021c:	eafff0ef          	jal	ra,800000ca <kinit>
    kvminit();       // create kernel page table
    80000220:	2ca020ef          	jal	ra,800024ea <kvminit>
    kvminithart();   // turn on paging
    80000224:	03c020ef          	jal	ra,80002260 <kvminithart>
    procinit();      // 恢复为了原来的procinit()
    80000228:	53a000ef          	jal	ra,80000762 <procinit>
    printf("xv6 passed the procinit()\n");
    8000022c:	00006517          	auipc	a0,0x6
    80000230:	e0c50513          	addi	a0,a0,-500 # 80006038 <etext+0x38>
    80000234:	188000ef          	jal	ra,800003bc <printf>
    trapinit();      // trap vectors
    80000238:	2e9010ef          	jal	ra,80001d20 <trapinit>
    trapinithart();  // install kernel trap vector
    8000023c:	309010ef          	jal	ra,80001d44 <trapinithart>
    plicinit();      // set up interrupt controller
    80000240:	028000ef          	jal	ra,80000268 <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000244:	03a000ef          	jal	ra,8000027e <plicinithart>
    binit();         // buffer cache
    80000248:	081020ef          	jal	ra,80002ac8 <binit>
    iinit();         // inode table
    8000024c:	7b0030ef          	jal	ra,800039fc <iinit>
    virtio_disk_init(); // emulated hard disk 磁盘的初始化
    80000250:	46d020ef          	jal	ra,80002ebc <virtio_disk_init>
    userinit();
    80000254:	04b000ef          	jal	ra,80000a9e <userinit>
    __sync_synchronize();
    80000258:	0ff0000f          	fence
    started = 1;
    8000025c:	4785                	li	a5,1
    8000025e:	00008717          	auipc	a4,0x8
    80000262:	84f72123          	sw	a5,-1982(a4) # 80007aa0 <started>
    80000266:	b759                	j	800001ec <main+0x3e>

0000000080000268 <plicinit>:
// 文件直接使用了xv6标准文件，应该没有错误 //
//////////////////////////////////////////

void
plicinit(void)
{
    80000268:	1141                	addi	sp,sp,-16
    8000026a:	e422                	sd	s0,8(sp)
    8000026c:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    8000026e:	0c0007b7          	lui	a5,0xc000
    80000272:	4705                	li	a4,1
    80000274:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80000276:	c3d8                	sw	a4,4(a5)
}
    80000278:	6422                	ld	s0,8(sp)
    8000027a:	0141                	addi	sp,sp,16
    8000027c:	8082                	ret

000000008000027e <plicinithart>:

void
plicinithart(void)
{
    8000027e:	1141                	addi	sp,sp,-16
    80000280:	e406                	sd	ra,8(sp)
    80000282:	e022                	sd	s0,0(sp)
    80000284:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80000286:	584000ef          	jal	ra,8000080a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    8000028a:	0085171b          	slliw	a4,a0,0x8
    8000028e:	0c0027b7          	lui	a5,0xc002
    80000292:	97ba                	add	a5,a5,a4
    80000294:	40200713          	li	a4,1026
    80000298:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    8000029c:	00d5151b          	slliw	a0,a0,0xd
    800002a0:	0c2017b7          	lui	a5,0xc201
    800002a4:	97aa                	add	a5,a5,a0
    800002a6:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800002aa:	60a2                	ld	ra,8(sp)
    800002ac:	6402                	ld	s0,0(sp)
    800002ae:	0141                	addi	sp,sp,16
    800002b0:	8082                	ret

00000000800002b2 <plic_claim>:

// ask the PLIC what interrupt we should serve.
// 从PLIC取出当前哪个设备发出了中断，返回设备的IRQ号
int
plic_claim(void)
{
    800002b2:	1141                	addi	sp,sp,-16
    800002b4:	e406                	sd	ra,8(sp)
    800002b6:	e022                	sd	s0,0(sp)
    800002b8:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800002ba:	550000ef          	jal	ra,8000080a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800002be:	00d5151b          	slliw	a0,a0,0xd
    800002c2:	0c2017b7          	lui	a5,0xc201
    800002c6:	97aa                	add	a5,a5,a0
  return irq;
}
    800002c8:	43c8                	lw	a0,4(a5)
    800002ca:	60a2                	ld	ra,8(sp)
    800002cc:	6402                	ld	s0,0(sp)
    800002ce:	0141                	addi	sp,sp,16
    800002d0:	8082                	ret

00000000800002d2 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800002d2:	1101                	addi	sp,sp,-32
    800002d4:	ec06                	sd	ra,24(sp)
    800002d6:	e822                	sd	s0,16(sp)
    800002d8:	e426                	sd	s1,8(sp)
    800002da:	1000                	addi	s0,sp,32
    800002dc:	84aa                	mv	s1,a0
  int hart = cpuid();
    800002de:	52c000ef          	jal	ra,8000080a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800002e2:	00d5151b          	slliw	a0,a0,0xd
    800002e6:	0c2017b7          	lui	a5,0xc201
    800002ea:	97aa                	add	a5,a5,a0
    800002ec:	c3c4                	sw	s1,4(a5)
}
    800002ee:	60e2                	ld	ra,24(sp)
    800002f0:	6442                	ld	s0,16(sp)
    800002f2:	64a2                	ld	s1,8(sp)
    800002f4:	6105                	addi	sp,sp,32
    800002f6:	8082                	ret

00000000800002f8 <pputc>:
////////////////////////////
// 这个函数添加用于替代console.c中的consputc()函数 后续需要的话将pputc修改回来
# define BACKSPACE 0x100
void
pputc(int c)
{
    800002f8:	1141                	addi	sp,sp,-16
    800002fa:	e406                	sd	ra,8(sp)
    800002fc:	e022                	sd	s0,0(sp)
    800002fe:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000300:	10000793          	li	a5,256
    80000304:	00f50863          	beq	a0,a5,80000314 <pputc+0x1c>
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
  }
  else
  {
    uartputc_sync(c);
    80000308:	57d010ef          	jal	ra,80002084 <uartputc_sync>
  }
}
    8000030c:	60a2                	ld	ra,8(sp)
    8000030e:	6402                	ld	s0,0(sp)
    80000310:	0141                	addi	sp,sp,16
    80000312:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000314:	4521                	li	a0,8
    80000316:	56f010ef          	jal	ra,80002084 <uartputc_sync>
    8000031a:	02000513          	li	a0,32
    8000031e:	567010ef          	jal	ra,80002084 <uartputc_sync>
    80000322:	4521                	li	a0,8
    80000324:	561010ef          	jal	ra,80002084 <uartputc_sync>
    80000328:	b7d5                	j	8000030c <pputc+0x14>

000000008000032a <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    8000032a:	7179                	addi	sp,sp,-48
    8000032c:	f406                	sd	ra,40(sp)
    8000032e:	f022                	sd	s0,32(sp)
    80000330:	ec26                	sd	s1,24(sp)
    80000332:	e84a                	sd	s2,16(sp)
    80000334:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000336:	c219                	beqz	a2,8000033c <printint+0x12>
    80000338:	06054e63          	bltz	a0,800003b4 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000033c:	4881                	li	a7,0
    8000033e:	fd040693          	addi	a3,s0,-48

  i = 0;
    80000342:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000344:	00006617          	auipc	a2,0x6
    80000348:	d4c60613          	addi	a2,a2,-692 # 80006090 <digits>
    8000034c:	883e                	mv	a6,a5
    8000034e:	2785                	addiw	a5,a5,1 # c201001 <_entry-0x73dfefff>
    80000350:	02b57733          	remu	a4,a0,a1
    80000354:	9732                	add	a4,a4,a2
    80000356:	00074703          	lbu	a4,0(a4)
    8000035a:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    8000035e:	872a                	mv	a4,a0
    80000360:	02b55533          	divu	a0,a0,a1
    80000364:	0685                	addi	a3,a3,1
    80000366:	feb773e3          	bgeu	a4,a1,8000034c <printint+0x22>

  if(sign)
    8000036a:	00088a63          	beqz	a7,8000037e <printint+0x54>
    buf[i++] = '-';
    8000036e:	1781                	addi	a5,a5,-32
    80000370:	97a2                	add	a5,a5,s0
    80000372:	02d00713          	li	a4,45
    80000376:	fee78823          	sb	a4,-16(a5)
    8000037a:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    8000037e:	02f05563          	blez	a5,800003a8 <printint+0x7e>
    80000382:	fd040713          	addi	a4,s0,-48
    80000386:	00f704b3          	add	s1,a4,a5
    8000038a:	fff70913          	addi	s2,a4,-1
    8000038e:	993e                	add	s2,s2,a5
    80000390:	37fd                	addiw	a5,a5,-1
    80000392:	1782                	slli	a5,a5,0x20
    80000394:	9381                	srli	a5,a5,0x20
    80000396:	40f90933          	sub	s2,s2,a5
    //consputc(buf[i]);
    pputc(buf[i]);
    8000039a:	fff4c503          	lbu	a0,-1(s1)
    8000039e:	f5bff0ef          	jal	ra,800002f8 <pputc>
  while(--i >= 0)
    800003a2:	14fd                	addi	s1,s1,-1
    800003a4:	ff249be3          	bne	s1,s2,8000039a <printint+0x70>
}
    800003a8:	70a2                	ld	ra,40(sp)
    800003aa:	7402                	ld	s0,32(sp)
    800003ac:	64e2                	ld	s1,24(sp)
    800003ae:	6942                	ld	s2,16(sp)
    800003b0:	6145                	addi	sp,sp,48
    800003b2:	8082                	ret
    x = -xx;
    800003b4:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800003b8:	4885                	li	a7,1
    x = -xx;
    800003ba:	b751                	j	8000033e <printint+0x14>

00000000800003bc <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800003bc:	7155                	addi	sp,sp,-208
    800003be:	e506                	sd	ra,136(sp)
    800003c0:	e122                	sd	s0,128(sp)
    800003c2:	fca6                	sd	s1,120(sp)
    800003c4:	f8ca                	sd	s2,112(sp)
    800003c6:	f4ce                	sd	s3,104(sp)
    800003c8:	f0d2                	sd	s4,96(sp)
    800003ca:	ecd6                	sd	s5,88(sp)
    800003cc:	e8da                	sd	s6,80(sp)
    800003ce:	e4de                	sd	s7,72(sp)
    800003d0:	e0e2                	sd	s8,64(sp)
    800003d2:	fc66                	sd	s9,56(sp)
    800003d4:	f86a                	sd	s10,48(sp)
    800003d6:	f46e                	sd	s11,40(sp)
    800003d8:	0900                	addi	s0,sp,144
    800003da:	8a2a                	mv	s4,a0
    800003dc:	e40c                	sd	a1,8(s0)
    800003de:	e810                	sd	a2,16(s0)
    800003e0:	ec14                	sd	a3,24(s0)
    800003e2:	f018                	sd	a4,32(s0)
    800003e4:	f41c                	sd	a5,40(s0)
    800003e6:	03043823          	sd	a6,48(s0)
    800003ea:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800003ee:	00007797          	auipc	a5,0x7
    800003f2:	71a7a783          	lw	a5,1818(a5) # 80007b08 <pr+0x18>
    800003f6:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800003fa:	eb9d                	bnez	a5,80000430 <printf+0x74>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800003fc:	00840793          	addi	a5,s0,8
    80000400:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000404:	00054503          	lbu	a0,0(a0)
    80000408:	24050463          	beqz	a0,80000650 <printf+0x294>
    8000040c:	4981                	li	s3,0
    if(cx != '%'){
    8000040e:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000412:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    80000416:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000041a:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    8000041e:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000422:	07000d93          	li	s11,112
    pputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000426:	00006b97          	auipc	s7,0x6
    8000042a:	c6ab8b93          	addi	s7,s7,-918 # 80006090 <digits>
    8000042e:	a081                	j	8000046e <printf+0xb2>
    acquire(&pr.lock);
    80000430:	00007517          	auipc	a0,0x7
    80000434:	6c050513          	addi	a0,a0,1728 # 80007af0 <pr>
    80000438:	777000ef          	jal	ra,800013ae <acquire>
  va_start(ap, fmt);
    8000043c:	00840793          	addi	a5,s0,8
    80000440:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000444:	000a4503          	lbu	a0,0(s4) # fffffffffffff000 <end+0xffffffff7ffe1300>
    80000448:	f171                	bnez	a0,8000040c <printf+0x50>
#endif
  }
  va_end(ap);

  if(locking)
    release(&pr.lock);
    8000044a:	00007517          	auipc	a0,0x7
    8000044e:	6a650513          	addi	a0,a0,1702 # 80007af0 <pr>
    80000452:	7f5000ef          	jal	ra,80001446 <release>
    80000456:	aaed                	j	80000650 <printf+0x294>
      pputc(cx);
    80000458:	ea1ff0ef          	jal	ra,800002f8 <pputc>
      continue;
    8000045c:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000045e:	0014899b          	addiw	s3,s1,1
    80000462:	013a07b3          	add	a5,s4,s3
    80000466:	0007c503          	lbu	a0,0(a5)
    8000046a:	1c050f63          	beqz	a0,80000648 <printf+0x28c>
    if(cx != '%'){
    8000046e:	ff5515e3          	bne	a0,s5,80000458 <printf+0x9c>
    i++;
    80000472:	0019849b          	addiw	s1,s3,1 # 1001 <_entry-0x7fffefff>
    c0 = fmt[i+0] & 0xff;
    80000476:	009a07b3          	add	a5,s4,s1
    8000047a:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000047e:	1c090563          	beqz	s2,80000648 <printf+0x28c>
    80000482:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000486:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000488:	c789                	beqz	a5,80000492 <printf+0xd6>
    8000048a:	009a0733          	add	a4,s4,s1
    8000048e:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80000492:	03690463          	beq	s2,s6,800004ba <printf+0xfe>
    } else if(c0 == 'l' && c1 == 'd'){
    80000496:	03890e63          	beq	s2,s8,800004d2 <printf+0x116>
    } else if(c0 == 'u'){
    8000049a:	0b990d63          	beq	s2,s9,80000554 <printf+0x198>
    } else if(c0 == 'x'){
    8000049e:	11a90363          	beq	s2,s10,800005a4 <printf+0x1e8>
    } else if(c0 == 'p'){
    800004a2:	13b90b63          	beq	s2,s11,800005d8 <printf+0x21c>
    } else if(c0 == 's'){
    800004a6:	07300793          	li	a5,115
    800004aa:	16f90363          	beq	s2,a5,80000610 <printf+0x254>
    } else if(c0 == '%'){
    800004ae:	03591c63          	bne	s2,s5,800004e6 <printf+0x12a>
      pputc('%');
    800004b2:	8556                	mv	a0,s5
    800004b4:	e45ff0ef          	jal	ra,800002f8 <pputc>
    800004b8:	b75d                	j	8000045e <printf+0xa2>
      printint(va_arg(ap, int), 10, 1);
    800004ba:	f8843783          	ld	a5,-120(s0)
    800004be:	00878713          	addi	a4,a5,8
    800004c2:	f8e43423          	sd	a4,-120(s0)
    800004c6:	4605                	li	a2,1
    800004c8:	45a9                	li	a1,10
    800004ca:	4388                	lw	a0,0(a5)
    800004cc:	e5fff0ef          	jal	ra,8000032a <printint>
    800004d0:	b779                	j	8000045e <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'd'){
    800004d2:	03678163          	beq	a5,s6,800004f4 <printf+0x138>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800004d6:	03878d63          	beq	a5,s8,80000510 <printf+0x154>
    } else if(c0 == 'l' && c1 == 'u'){
    800004da:	09978963          	beq	a5,s9,8000056c <printf+0x1b0>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800004de:	03878b63          	beq	a5,s8,80000514 <printf+0x158>
    } else if(c0 == 'l' && c1 == 'x'){
    800004e2:	0da78d63          	beq	a5,s10,800005bc <printf+0x200>
      pputc('%');
    800004e6:	8556                	mv	a0,s5
    800004e8:	e11ff0ef          	jal	ra,800002f8 <pputc>
      pputc(c0);
    800004ec:	854a                	mv	a0,s2
    800004ee:	e0bff0ef          	jal	ra,800002f8 <pputc>
    800004f2:	b7b5                	j	8000045e <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    800004f4:	f8843783          	ld	a5,-120(s0)
    800004f8:	00878713          	addi	a4,a5,8
    800004fc:	f8e43423          	sd	a4,-120(s0)
    80000500:	4605                	li	a2,1
    80000502:	45a9                	li	a1,10
    80000504:	6388                	ld	a0,0(a5)
    80000506:	e25ff0ef          	jal	ra,8000032a <printint>
      i += 1;
    8000050a:	0029849b          	addiw	s1,s3,2
    8000050e:	bf81                	j	8000045e <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000510:	03668463          	beq	a3,s6,80000538 <printf+0x17c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000514:	07968a63          	beq	a3,s9,80000588 <printf+0x1cc>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    80000518:	fda697e3          	bne	a3,s10,800004e6 <printf+0x12a>
      printint(va_arg(ap, uint64), 16, 0);
    8000051c:	f8843783          	ld	a5,-120(s0)
    80000520:	00878713          	addi	a4,a5,8
    80000524:	f8e43423          	sd	a4,-120(s0)
    80000528:	4601                	li	a2,0
    8000052a:	45c1                	li	a1,16
    8000052c:	6388                	ld	a0,0(a5)
    8000052e:	dfdff0ef          	jal	ra,8000032a <printint>
      i += 2;
    80000532:	0039849b          	addiw	s1,s3,3
    80000536:	b725                	j	8000045e <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    80000538:	f8843783          	ld	a5,-120(s0)
    8000053c:	00878713          	addi	a4,a5,8
    80000540:	f8e43423          	sd	a4,-120(s0)
    80000544:	4605                	li	a2,1
    80000546:	45a9                	li	a1,10
    80000548:	6388                	ld	a0,0(a5)
    8000054a:	de1ff0ef          	jal	ra,8000032a <printint>
      i += 2;
    8000054e:	0039849b          	addiw	s1,s3,3
    80000552:	b731                	j	8000045e <printf+0xa2>
      printint(va_arg(ap, int), 10, 0);
    80000554:	f8843783          	ld	a5,-120(s0)
    80000558:	00878713          	addi	a4,a5,8
    8000055c:	f8e43423          	sd	a4,-120(s0)
    80000560:	4601                	li	a2,0
    80000562:	45a9                	li	a1,10
    80000564:	4388                	lw	a0,0(a5)
    80000566:	dc5ff0ef          	jal	ra,8000032a <printint>
    8000056a:	bdd5                	j	8000045e <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    8000056c:	f8843783          	ld	a5,-120(s0)
    80000570:	00878713          	addi	a4,a5,8
    80000574:	f8e43423          	sd	a4,-120(s0)
    80000578:	4601                	li	a2,0
    8000057a:	45a9                	li	a1,10
    8000057c:	6388                	ld	a0,0(a5)
    8000057e:	dadff0ef          	jal	ra,8000032a <printint>
      i += 1;
    80000582:	0029849b          	addiw	s1,s3,2
    80000586:	bde1                	j	8000045e <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    80000588:	f8843783          	ld	a5,-120(s0)
    8000058c:	00878713          	addi	a4,a5,8
    80000590:	f8e43423          	sd	a4,-120(s0)
    80000594:	4601                	li	a2,0
    80000596:	45a9                	li	a1,10
    80000598:	6388                	ld	a0,0(a5)
    8000059a:	d91ff0ef          	jal	ra,8000032a <printint>
      i += 2;
    8000059e:	0039849b          	addiw	s1,s3,3
    800005a2:	bd75                	j	8000045e <printf+0xa2>
      printint(va_arg(ap, int), 16, 0);
    800005a4:	f8843783          	ld	a5,-120(s0)
    800005a8:	00878713          	addi	a4,a5,8
    800005ac:	f8e43423          	sd	a4,-120(s0)
    800005b0:	4601                	li	a2,0
    800005b2:	45c1                	li	a1,16
    800005b4:	4388                	lw	a0,0(a5)
    800005b6:	d75ff0ef          	jal	ra,8000032a <printint>
    800005ba:	b555                	j	8000045e <printf+0xa2>
      printint(va_arg(ap, uint64), 16, 0);
    800005bc:	f8843783          	ld	a5,-120(s0)
    800005c0:	00878713          	addi	a4,a5,8
    800005c4:	f8e43423          	sd	a4,-120(s0)
    800005c8:	4601                	li	a2,0
    800005ca:	45c1                	li	a1,16
    800005cc:	6388                	ld	a0,0(a5)
    800005ce:	d5dff0ef          	jal	ra,8000032a <printint>
      i += 1;
    800005d2:	0029849b          	addiw	s1,s3,2
    800005d6:	b561                	j	8000045e <printf+0xa2>
      printptr(va_arg(ap, uint64));
    800005d8:	f8843783          	ld	a5,-120(s0)
    800005dc:	00878713          	addi	a4,a5,8
    800005e0:	f8e43423          	sd	a4,-120(s0)
    800005e4:	0007b983          	ld	s3,0(a5)
  pputc('0');
    800005e8:	03000513          	li	a0,48
    800005ec:	d0dff0ef          	jal	ra,800002f8 <pputc>
  pputc('x');
    800005f0:	856a                	mv	a0,s10
    800005f2:	d07ff0ef          	jal	ra,800002f8 <pputc>
    800005f6:	4941                	li	s2,16
    pputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005f8:	03c9d793          	srli	a5,s3,0x3c
    800005fc:	97de                	add	a5,a5,s7
    800005fe:	0007c503          	lbu	a0,0(a5)
    80000602:	cf7ff0ef          	jal	ra,800002f8 <pputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000606:	0992                	slli	s3,s3,0x4
    80000608:	397d                	addiw	s2,s2,-1
    8000060a:	fe0917e3          	bnez	s2,800005f8 <printf+0x23c>
    8000060e:	bd81                	j	8000045e <printf+0xa2>
      if((s = va_arg(ap, char*)) == 0)
    80000610:	f8843783          	ld	a5,-120(s0)
    80000614:	00878713          	addi	a4,a5,8
    80000618:	f8e43423          	sd	a4,-120(s0)
    8000061c:	0007b903          	ld	s2,0(a5)
    80000620:	00090d63          	beqz	s2,8000063a <printf+0x27e>
      for(; *s; s++)
    80000624:	00094503          	lbu	a0,0(s2)
    80000628:	e2050be3          	beqz	a0,8000045e <printf+0xa2>
        pputc(*s);
    8000062c:	ccdff0ef          	jal	ra,800002f8 <pputc>
      for(; *s; s++)
    80000630:	0905                	addi	s2,s2,1
    80000632:	00094503          	lbu	a0,0(s2)
    80000636:	f97d                	bnez	a0,8000062c <printf+0x270>
    80000638:	b51d                	j	8000045e <printf+0xa2>
        s = "(null)";
    8000063a:	00006917          	auipc	s2,0x6
    8000063e:	a3690913          	addi	s2,s2,-1482 # 80006070 <etext+0x70>
      for(; *s; s++)
    80000642:	02800513          	li	a0,40
    80000646:	b7dd                	j	8000062c <printf+0x270>
  if(locking)
    80000648:	f7843783          	ld	a5,-136(s0)
    8000064c:	de079fe3          	bnez	a5,8000044a <printf+0x8e>

  return 0;
}
    80000650:	4501                	li	a0,0
    80000652:	60aa                	ld	ra,136(sp)
    80000654:	640a                	ld	s0,128(sp)
    80000656:	74e6                	ld	s1,120(sp)
    80000658:	7946                	ld	s2,112(sp)
    8000065a:	79a6                	ld	s3,104(sp)
    8000065c:	7a06                	ld	s4,96(sp)
    8000065e:	6ae6                	ld	s5,88(sp)
    80000660:	6b46                	ld	s6,80(sp)
    80000662:	6ba6                	ld	s7,72(sp)
    80000664:	6c06                	ld	s8,64(sp)
    80000666:	7ce2                	ld	s9,56(sp)
    80000668:	7d42                	ld	s10,48(sp)
    8000066a:	7da2                	ld	s11,40(sp)
    8000066c:	6169                	addi	sp,sp,208
    8000066e:	8082                	ret

0000000080000670 <panic>:

void
panic(char *s)
{
    80000670:	1101                	addi	sp,sp,-32
    80000672:	ec06                	sd	ra,24(sp)
    80000674:	e822                	sd	s0,16(sp)
    80000676:	e426                	sd	s1,8(sp)
    80000678:	1000                	addi	s0,sp,32
    8000067a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000067c:	00007797          	auipc	a5,0x7
    80000680:	4807a623          	sw	zero,1164(a5) # 80007b08 <pr+0x18>
  printf("panic: ");
    80000684:	00006517          	auipc	a0,0x6
    80000688:	9f450513          	addi	a0,a0,-1548 # 80006078 <etext+0x78>
    8000068c:	d31ff0ef          	jal	ra,800003bc <printf>
  printf("%s\n", s);
    80000690:	85a6                	mv	a1,s1
    80000692:	00006517          	auipc	a0,0x6
    80000696:	9ee50513          	addi	a0,a0,-1554 # 80006080 <etext+0x80>
    8000069a:	d23ff0ef          	jal	ra,800003bc <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000069e:	4785                	li	a5,1
    800006a0:	00007717          	auipc	a4,0x7
    800006a4:	40f72223          	sw	a5,1028(a4) # 80007aa4 <panicked>
  for(;;)
    800006a8:	a001                	j	800006a8 <panic+0x38>

00000000800006aa <printfinit>:
    ;
}

void
printfinit(void)
{
    800006aa:	1101                	addi	sp,sp,-32
    800006ac:	ec06                	sd	ra,24(sp)
    800006ae:	e822                	sd	s0,16(sp)
    800006b0:	e426                	sd	s1,8(sp)
    800006b2:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800006b4:	00007497          	auipc	s1,0x7
    800006b8:	43c48493          	addi	s1,s1,1084 # 80007af0 <pr>
    800006bc:	00006597          	auipc	a1,0x6
    800006c0:	9cc58593          	addi	a1,a1,-1588 # 80006088 <etext+0x88>
    800006c4:	8526                	mv	a0,s1
    800006c6:	469000ef          	jal	ra,8000132e <initlock>

   // 使用printf.c直接替代console.c中的打印函数，需要在这里初始化串口

  pr.locking = 1;
    800006ca:	4785                	li	a5,1
    800006cc:	cc9c                	sw	a5,24(s1)
}
    800006ce:	60e2                	ld	ra,24(sp)
    800006d0:	6442                	ld	s0,16(sp)
    800006d2:	64a2                	ld	s1,8(sp)
    800006d4:	6105                	addi	sp,sp,32
    800006d6:	8082                	ret

00000000800006d8 <proc_mapstacks>:
// Map it high in memory, followed by an invalid
// guard page.
// 原来是将所有进程分配的栈记录在内核页表上面，现在只有一个proc结构体
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800006d8:	7139                	addi	sp,sp,-64
    800006da:	fc06                	sd	ra,56(sp)
    800006dc:	f822                	sd	s0,48(sp)
    800006de:	f426                	sd	s1,40(sp)
    800006e0:	f04a                	sd	s2,32(sp)
    800006e2:	ec4e                	sd	s3,24(sp)
    800006e4:	e852                	sd	s4,16(sp)
    800006e6:	e456                	sd	s5,8(sp)
    800006e8:	e05a                	sd	s6,0(sp)
    800006ea:	0080                	addi	s0,sp,64
    800006ec:	89aa                	mv	s3,a0
  struct proc *p;
  for(p = proc; p < &proc[NPROC]; p++) {
    800006ee:	00008497          	auipc	s1,0x8
    800006f2:	85248493          	addi	s1,s1,-1966 # 80007f40 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800006f6:	8b26                	mv	s6,s1
    800006f8:	00006a97          	auipc	s5,0x6
    800006fc:	908a8a93          	addi	s5,s5,-1784 # 80006000 <etext>
    80000700:	04000937          	lui	s2,0x4000
    80000704:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80000706:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000708:	0000ba17          	auipc	s4,0xb
    8000070c:	238a0a13          	addi	s4,s4,568 # 8000b940 <stack0>
    char *pa = kalloc();
    80000710:	9efff0ef          	jal	ra,800000fe <kalloc>
    80000714:	862a                	mv	a2,a0
    if(pa == 0)
    80000716:	c121                	beqz	a0,80000756 <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    80000718:	416485b3          	sub	a1,s1,s6
    8000071c:	858d                	srai	a1,a1,0x3
    8000071e:	000ab783          	ld	a5,0(s5)
    80000722:	02f585b3          	mul	a1,a1,a5
    80000726:	2585                	addiw	a1,a1,1
    80000728:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000072c:	4719                	li	a4,6
    8000072e:	6685                	lui	a3,0x1
    80000730:	40b905b3          	sub	a1,s2,a1
    80000734:	854e                	mv	a0,s3
    80000736:	4db010ef          	jal	ra,80002410 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000073a:	0e848493          	addi	s1,s1,232
    8000073e:	fd4499e3          	bne	s1,s4,80000710 <proc_mapstacks+0x38>
  }
}
    80000742:	70e2                	ld	ra,56(sp)
    80000744:	7442                	ld	s0,48(sp)
    80000746:	74a2                	ld	s1,40(sp)
    80000748:	7902                	ld	s2,32(sp)
    8000074a:	69e2                	ld	s3,24(sp)
    8000074c:	6a42                	ld	s4,16(sp)
    8000074e:	6aa2                	ld	s5,8(sp)
    80000750:	6b02                	ld	s6,0(sp)
    80000752:	6121                	addi	sp,sp,64
    80000754:	8082                	ret
      panic("kalloc");
    80000756:	00006517          	auipc	a0,0x6
    8000075a:	95250513          	addi	a0,a0,-1710 # 800060a8 <digits+0x18>
    8000075e:	f13ff0ef          	jal	ra,80000670 <panic>

0000000080000762 <procinit>:

// initialize the proc table.
// 恢复原来的procinit
void
procinit(void)
{
    80000762:	7139                	addi	sp,sp,-64
    80000764:	fc06                	sd	ra,56(sp)
    80000766:	f822                	sd	s0,48(sp)
    80000768:	f426                	sd	s1,40(sp)
    8000076a:	f04a                	sd	s2,32(sp)
    8000076c:	ec4e                	sd	s3,24(sp)
    8000076e:	e852                	sd	s4,16(sp)
    80000770:	e456                	sd	s5,8(sp)
    80000772:	e05a                	sd	s6,0(sp)
    80000774:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80000776:	00006597          	auipc	a1,0x6
    8000077a:	93a58593          	addi	a1,a1,-1734 # 800060b0 <digits+0x20>
    8000077e:	00007517          	auipc	a0,0x7
    80000782:	39250513          	addi	a0,a0,914 # 80007b10 <pid_lock>
    80000786:	3a9000ef          	jal	ra,8000132e <initlock>
  initlock(&wait_lock, "wait_lock");
    8000078a:	00006597          	auipc	a1,0x6
    8000078e:	92e58593          	addi	a1,a1,-1746 # 800060b8 <digits+0x28>
    80000792:	00007517          	auipc	a0,0x7
    80000796:	39650513          	addi	a0,a0,918 # 80007b28 <wait_lock>
    8000079a:	395000ef          	jal	ra,8000132e <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000079e:	00007497          	auipc	s1,0x7
    800007a2:	7a248493          	addi	s1,s1,1954 # 80007f40 <proc>
      initlock(&p->lock, "proc");
    800007a6:	00006b17          	auipc	s6,0x6
    800007aa:	922b0b13          	addi	s6,s6,-1758 # 800060c8 <digits+0x38>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    800007ae:	8aa6                	mv	s5,s1
    800007b0:	00006a17          	auipc	s4,0x6
    800007b4:	850a0a13          	addi	s4,s4,-1968 # 80006000 <etext>
    800007b8:	04000937          	lui	s2,0x4000
    800007bc:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    800007be:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800007c0:	0000b997          	auipc	s3,0xb
    800007c4:	18098993          	addi	s3,s3,384 # 8000b940 <stack0>
      initlock(&p->lock, "proc");
    800007c8:	85da                	mv	a1,s6
    800007ca:	8526                	mv	a0,s1
    800007cc:	363000ef          	jal	ra,8000132e <initlock>
      p->state = UNUSED;
    800007d0:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800007d4:	415487b3          	sub	a5,s1,s5
    800007d8:	878d                	srai	a5,a5,0x3
    800007da:	000a3703          	ld	a4,0(s4)
    800007de:	02e787b3          	mul	a5,a5,a4
    800007e2:	2785                	addiw	a5,a5,1
    800007e4:	00d7979b          	slliw	a5,a5,0xd
    800007e8:	40f907b3          	sub	a5,s2,a5
    800007ec:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800007ee:	0e848493          	addi	s1,s1,232
    800007f2:	fd349be3          	bne	s1,s3,800007c8 <procinit+0x66>
  }
}
    800007f6:	70e2                	ld	ra,56(sp)
    800007f8:	7442                	ld	s0,48(sp)
    800007fa:	74a2                	ld	s1,40(sp)
    800007fc:	7902                	ld	s2,32(sp)
    800007fe:	69e2                	ld	s3,24(sp)
    80000800:	6a42                	ld	s4,16(sp)
    80000802:	6aa2                	ld	s5,8(sp)
    80000804:	6b02                	ld	s6,0(sp)
    80000806:	6121                	addi	sp,sp,64
    80000808:	8082                	ret

000000008000080a <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    8000080a:	1141                	addi	sp,sp,-16
    8000080c:	e422                	sd	s0,8(sp)
    8000080e:	0800                	addi	s0,sp,16
// this core's hartid (core number), the index into cpus[].
static inline uint64
r_tp()
{
  uint64 x;
  asm volatile("mv %0, tp" : "=r" (x) );
    80000810:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80000812:	2501                	sext.w	a0,a0
    80000814:	6422                	ld	s0,8(sp)
    80000816:	0141                	addi	sp,sp,16
    80000818:	8082                	ret

000000008000081a <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    8000081a:	1141                	addi	sp,sp,-16
    8000081c:	e422                	sd	s0,8(sp)
    8000081e:	0800                	addi	s0,sp,16
    80000820:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80000822:	2781                	sext.w	a5,a5
    80000824:	079e                	slli	a5,a5,0x7
  return c;
}
    80000826:	00007517          	auipc	a0,0x7
    8000082a:	31a50513          	addi	a0,a0,794 # 80007b40 <cpus>
    8000082e:	953e                	add	a0,a0,a5
    80000830:	6422                	ld	s0,8(sp)
    80000832:	0141                	addi	sp,sp,16
    80000834:	8082                	ret

0000000080000836 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80000836:	1101                	addi	sp,sp,-32
    80000838:	ec06                	sd	ra,24(sp)
    8000083a:	e822                	sd	s0,16(sp)
    8000083c:	e426                	sd	s1,8(sp)
    8000083e:	1000                	addi	s0,sp,32
  push_off();
    80000840:	32f000ef          	jal	ra,8000136e <push_off>
    80000844:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000846:	2781                	sext.w	a5,a5
    80000848:	079e                	slli	a5,a5,0x7
    8000084a:	00007717          	auipc	a4,0x7
    8000084e:	2c670713          	addi	a4,a4,710 # 80007b10 <pid_lock>
    80000852:	97ba                	add	a5,a5,a4
    80000854:	7b84                	ld	s1,48(a5)
  pop_off();
    80000856:	39d000ef          	jal	ra,800013f2 <pop_off>
  return p;
}
    8000085a:	8526                	mv	a0,s1
    8000085c:	60e2                	ld	ra,24(sp)
    8000085e:	6442                	ld	s0,16(sp)
    80000860:	64a2                	ld	s1,8(sp)
    80000862:	6105                	addi	sp,sp,32
    80000864:	8082                	ret

0000000080000866 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80000866:	1141                	addi	sp,sp,-16
    80000868:	e406                	sd	ra,8(sp)
    8000086a:	e022                	sd	s0,0(sp)
    8000086c:	0800                	addi	s0,sp,16
  static int first = 1; 

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    8000086e:	fc9ff0ef          	jal	ra,80000836 <myproc>
    80000872:	3d5000ef          	jal	ra,80001446 <release>

  // 这里好像涉及了文件系统，先注释
  if (first) {
    80000876:	00006797          	auipc	a5,0x6
    8000087a:	1da7a783          	lw	a5,474(a5) # 80006a50 <first.0>
    8000087e:	e799                	bnez	a5,8000088c <forkret+0x26>
    // ensure other cores see first=0.
    __sync_synchronize();
  }
  
  // 通过这个切换到用户态去
  usertrapret();
    80000880:	4dc010ef          	jal	ra,80001d5c <usertrapret>
}
    80000884:	60a2                	ld	ra,8(sp)
    80000886:	6402                	ld	s0,0(sp)
    80000888:	0141                	addi	sp,sp,16
    8000088a:	8082                	ret
    fsinit(ROOTDEV);
    8000088c:	4505                	li	a0,1
    8000088e:	102030ef          	jal	ra,80003990 <fsinit>
    first = 0;
    80000892:	00006797          	auipc	a5,0x6
    80000896:	1a07af23          	sw	zero,446(a5) # 80006a50 <first.0>
    __sync_synchronize();
    8000089a:	0ff0000f          	fence
    8000089e:	b7cd                	j	80000880 <forkret+0x1a>

00000000800008a0 <allocpid>:
{
    800008a0:	1101                	addi	sp,sp,-32
    800008a2:	ec06                	sd	ra,24(sp)
    800008a4:	e822                	sd	s0,16(sp)
    800008a6:	e426                	sd	s1,8(sp)
    800008a8:	e04a                	sd	s2,0(sp)
    800008aa:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800008ac:	00007917          	auipc	s2,0x7
    800008b0:	26490913          	addi	s2,s2,612 # 80007b10 <pid_lock>
    800008b4:	854a                	mv	a0,s2
    800008b6:	2f9000ef          	jal	ra,800013ae <acquire>
  pid = nextpid;
    800008ba:	00006797          	auipc	a5,0x6
    800008be:	19a78793          	addi	a5,a5,410 # 80006a54 <nextpid>
    800008c2:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800008c4:	0014871b          	addiw	a4,s1,1
    800008c8:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800008ca:	854a                	mv	a0,s2
    800008cc:	37b000ef          	jal	ra,80001446 <release>
}
    800008d0:	8526                	mv	a0,s1
    800008d2:	60e2                	ld	ra,24(sp)
    800008d4:	6442                	ld	s0,16(sp)
    800008d6:	64a2                	ld	s1,8(sp)
    800008d8:	6902                	ld	s2,0(sp)
    800008da:	6105                	addi	sp,sp,32
    800008dc:	8082                	ret

00000000800008de <proc_pagetable>:
{
    800008de:	1101                	addi	sp,sp,-32
    800008e0:	ec06                	sd	ra,24(sp)
    800008e2:	e822                	sd	s0,16(sp)
    800008e4:	e426                	sd	s1,8(sp)
    800008e6:	e04a                	sd	s2,0(sp)
    800008e8:	1000                	addi	s0,sp,32
    800008ea:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800008ec:	4c7010ef          	jal	ra,800025b2 <uvmcreate>
    800008f0:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800008f2:	cd05                	beqz	a0,8000092a <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    800008f4:	4729                	li	a4,10
    800008f6:	00004697          	auipc	a3,0x4
    800008fa:	70a68693          	addi	a3,a3,1802 # 80005000 <_trampoline>
    800008fe:	6605                	lui	a2,0x1
    80000900:	040005b7          	lui	a1,0x4000
    80000904:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000906:	05b2                	slli	a1,a1,0xc
    80000908:	259010ef          	jal	ra,80002360 <mappages>
    8000090c:	02054663          	bltz	a0,80000938 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80000910:	4719                	li	a4,6
    80000912:	05893683          	ld	a3,88(s2)
    80000916:	6605                	lui	a2,0x1
    80000918:	020005b7          	lui	a1,0x2000
    8000091c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    8000091e:	05b6                	slli	a1,a1,0xd
    80000920:	8526                	mv	a0,s1
    80000922:	23f010ef          	jal	ra,80002360 <mappages>
    80000926:	00054f63          	bltz	a0,80000944 <proc_pagetable+0x66>
}
    8000092a:	8526                	mv	a0,s1
    8000092c:	60e2                	ld	ra,24(sp)
    8000092e:	6442                	ld	s0,16(sp)
    80000930:	64a2                	ld	s1,8(sp)
    80000932:	6902                	ld	s2,0(sp)
    80000934:	6105                	addi	sp,sp,32
    80000936:	8082                	ret
    uvmfree(pagetable, 0);
    80000938:	4581                	li	a1,0
    8000093a:	8526                	mv	a0,s1
    8000093c:	639010ef          	jal	ra,80002774 <uvmfree>
    return 0;
    80000940:	4481                	li	s1,0
    80000942:	b7e5                	j	8000092a <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000944:	4681                	li	a3,0
    80000946:	4605                	li	a2,1
    80000948:	040005b7          	lui	a1,0x4000
    8000094c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000094e:	05b2                	slli	a1,a1,0xc
    80000950:	8526                	mv	a0,s1
    80000952:	3b5010ef          	jal	ra,80002506 <uvmunmap>
    uvmfree(pagetable, 0);
    80000956:	4581                	li	a1,0
    80000958:	8526                	mv	a0,s1
    8000095a:	61b010ef          	jal	ra,80002774 <uvmfree>
    return 0;
    8000095e:	4481                	li	s1,0
    80000960:	b7e9                	j	8000092a <proc_pagetable+0x4c>

0000000080000962 <proc_freepagetable>:
{
    80000962:	1101                	addi	sp,sp,-32
    80000964:	ec06                	sd	ra,24(sp)
    80000966:	e822                	sd	s0,16(sp)
    80000968:	e426                	sd	s1,8(sp)
    8000096a:	e04a                	sd	s2,0(sp)
    8000096c:	1000                	addi	s0,sp,32
    8000096e:	84aa                	mv	s1,a0
    80000970:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000972:	4681                	li	a3,0
    80000974:	4605                	li	a2,1
    80000976:	040005b7          	lui	a1,0x4000
    8000097a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000097c:	05b2                	slli	a1,a1,0xc
    8000097e:	389010ef          	jal	ra,80002506 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80000982:	4681                	li	a3,0
    80000984:	4605                	li	a2,1
    80000986:	020005b7          	lui	a1,0x2000
    8000098a:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    8000098c:	05b6                	slli	a1,a1,0xd
    8000098e:	8526                	mv	a0,s1
    80000990:	377010ef          	jal	ra,80002506 <uvmunmap>
  uvmfree(pagetable, sz);
    80000994:	85ca                	mv	a1,s2
    80000996:	8526                	mv	a0,s1
    80000998:	5dd010ef          	jal	ra,80002774 <uvmfree>
}
    8000099c:	60e2                	ld	ra,24(sp)
    8000099e:	6442                	ld	s0,16(sp)
    800009a0:	64a2                	ld	s1,8(sp)
    800009a2:	6902                	ld	s2,0(sp)
    800009a4:	6105                	addi	sp,sp,32
    800009a6:	8082                	ret

00000000800009a8 <freeproc>:
{
    800009a8:	1101                	addi	sp,sp,-32
    800009aa:	ec06                	sd	ra,24(sp)
    800009ac:	e822                	sd	s0,16(sp)
    800009ae:	e426                	sd	s1,8(sp)
    800009b0:	1000                	addi	s0,sp,32
    800009b2:	84aa                	mv	s1,a0
  if(p->trapframe)
    800009b4:	6d28                	ld	a0,88(a0)
    800009b6:	c119                	beqz	a0,800009bc <freeproc+0x14>
    kfree((void*)p->trapframe);
    800009b8:	e64ff0ef          	jal	ra,8000001c <kfree>
  p->trapframe = 0;
    800009bc:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    800009c0:	68a8                	ld	a0,80(s1)
    800009c2:	c501                	beqz	a0,800009ca <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    800009c4:	64ac                	ld	a1,72(s1)
    800009c6:	f9dff0ef          	jal	ra,80000962 <proc_freepagetable>
  p->pagetable = 0;
    800009ca:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    800009ce:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    800009d2:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    800009d6:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    800009da:	0c048c23          	sb	zero,216(s1)
  p->chan = 0;
    800009de:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    800009e2:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    800009e6:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    800009ea:	0004ac23          	sw	zero,24(s1)
}
    800009ee:	60e2                	ld	ra,24(sp)
    800009f0:	6442                	ld	s0,16(sp)
    800009f2:	64a2                	ld	s1,8(sp)
    800009f4:	6105                	addi	sp,sp,32
    800009f6:	8082                	ret

00000000800009f8 <allocproc>:
{
    800009f8:	1101                	addi	sp,sp,-32
    800009fa:	ec06                	sd	ra,24(sp)
    800009fc:	e822                	sd	s0,16(sp)
    800009fe:	e426                	sd	s1,8(sp)
    80000a00:	e04a                	sd	s2,0(sp)
    80000a02:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80000a04:	00007497          	auipc	s1,0x7
    80000a08:	53c48493          	addi	s1,s1,1340 # 80007f40 <proc>
    80000a0c:	0000b917          	auipc	s2,0xb
    80000a10:	f3490913          	addi	s2,s2,-204 # 8000b940 <stack0>
    acquire(&p->lock);
    80000a14:	8526                	mv	a0,s1
    80000a16:	199000ef          	jal	ra,800013ae <acquire>
    if(p->state == UNUSED) {
    80000a1a:	4c9c                	lw	a5,24(s1)
    80000a1c:	cb91                	beqz	a5,80000a30 <allocproc+0x38>
      release(&p->lock);
    80000a1e:	8526                	mv	a0,s1
    80000a20:	227000ef          	jal	ra,80001446 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000a24:	0e848493          	addi	s1,s1,232
    80000a28:	ff2496e3          	bne	s1,s2,80000a14 <allocproc+0x1c>
  return 0;
    80000a2c:	4481                	li	s1,0
    80000a2e:	a089                	j	80000a70 <allocproc+0x78>
  p->pid = allocpid();
    80000a30:	e71ff0ef          	jal	ra,800008a0 <allocpid>
    80000a34:	d888                	sw	a0,48(s1)
  p->state = USED;
    80000a36:	4785                	li	a5,1
    80000a38:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80000a3a:	ec4ff0ef          	jal	ra,800000fe <kalloc>
    80000a3e:	892a                	mv	s2,a0
    80000a40:	eca8                	sd	a0,88(s1)
    80000a42:	cd15                	beqz	a0,80000a7e <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80000a44:	8526                	mv	a0,s1
    80000a46:	e99ff0ef          	jal	ra,800008de <proc_pagetable>
    80000a4a:	892a                	mv	s2,a0
    80000a4c:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80000a4e:	c121                	beqz	a0,80000a8e <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80000a50:	07000613          	li	a2,112
    80000a54:	4581                	li	a1,0
    80000a56:	06048513          	addi	a0,s1,96
    80000a5a:	2dd000ef          	jal	ra,80001536 <memset>
  p->context.ra = (uint64)forkret;
    80000a5e:	00000797          	auipc	a5,0x0
    80000a62:	e0878793          	addi	a5,a5,-504 # 80000866 <forkret>
    80000a66:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80000a68:	60bc                	ld	a5,64(s1)
    80000a6a:	6705                	lui	a4,0x1
    80000a6c:	97ba                	add	a5,a5,a4
    80000a6e:	f4bc                	sd	a5,104(s1)
}
    80000a70:	8526                	mv	a0,s1
    80000a72:	60e2                	ld	ra,24(sp)
    80000a74:	6442                	ld	s0,16(sp)
    80000a76:	64a2                	ld	s1,8(sp)
    80000a78:	6902                	ld	s2,0(sp)
    80000a7a:	6105                	addi	sp,sp,32
    80000a7c:	8082                	ret
    freeproc(p);
    80000a7e:	8526                	mv	a0,s1
    80000a80:	f29ff0ef          	jal	ra,800009a8 <freeproc>
    release(&p->lock);
    80000a84:	8526                	mv	a0,s1
    80000a86:	1c1000ef          	jal	ra,80001446 <release>
    return 0;
    80000a8a:	84ca                	mv	s1,s2
    80000a8c:	b7d5                	j	80000a70 <allocproc+0x78>
    freeproc(p);
    80000a8e:	8526                	mv	a0,s1
    80000a90:	f19ff0ef          	jal	ra,800009a8 <freeproc>
    release(&p->lock);
    80000a94:	8526                	mv	a0,s1
    80000a96:	1b1000ef          	jal	ra,80001446 <release>
    return 0;
    80000a9a:	84ca                	mv	s1,s2
    80000a9c:	bfd1                	j	80000a70 <allocproc+0x78>

0000000080000a9e <userinit>:
{
    80000a9e:	1101                	addi	sp,sp,-32
    80000aa0:	ec06                	sd	ra,24(sp)
    80000aa2:	e822                	sd	s0,16(sp)
    80000aa4:	e426                	sd	s1,8(sp)
    80000aa6:	e04a                	sd	s2,0(sp)
    80000aa8:	1000                	addi	s0,sp,32
  p = allocproc();
    80000aaa:	f4fff0ef          	jal	ra,800009f8 <allocproc>
    80000aae:	84aa                	mv	s1,a0
  initproc = p;
    80000ab0:	00007797          	auipc	a5,0x7
    80000ab4:	fea7bc23          	sd	a0,-8(a5) # 80007aa8 <initproc>
  printf("initcode size: %ld bytes (PGSIZE: %d)\n", sizeof(initcode), PGSIZE);
    80000ab8:	6605                	lui	a2,0x1
    80000aba:	6585                	lui	a1,0x1
    80000abc:	02058593          	addi	a1,a1,32 # 1020 <_entry-0x7fffefe0>
    80000ac0:	00005517          	auipc	a0,0x5
    80000ac4:	61050513          	addi	a0,a0,1552 # 800060d0 <digits+0x40>
    80000ac8:	8f5ff0ef          	jal	ra,800003bc <printf>
    printf("initcode is larger than one page, handling manually\n");
    80000acc:	00005517          	auipc	a0,0x5
    80000ad0:	62c50513          	addi	a0,a0,1580 # 800060f8 <digits+0x68>
    80000ad4:	8e9ff0ef          	jal	ra,800003bc <printf>
    char *mem1 = kalloc();
    80000ad8:	e26ff0ef          	jal	ra,800000fe <kalloc>
    if(mem1 == 0)
    80000adc:	12050763          	beqz	a0,80000c0a <userinit+0x16c>
    80000ae0:	892a                	mv	s2,a0
    memset(mem1, 0, PGSIZE);
    80000ae2:	6605                	lui	a2,0x1
    80000ae4:	4581                	li	a1,0
    80000ae6:	251000ef          	jal	ra,80001536 <memset>
    memmove(mem1, initcode, PGSIZE);
    80000aea:	6605                	lui	a2,0x1
    80000aec:	00006597          	auipc	a1,0x6
    80000af0:	f7458593          	addi	a1,a1,-140 # 80006a60 <initcode>
    80000af4:	854a                	mv	a0,s2
    80000af6:	29d000ef          	jal	ra,80001592 <memmove>
    if(mappages(p->pagetable, 0, PGSIZE, (uint64)mem1, PTE_W|PTE_R|PTE_X|PTE_U) < 0){
    80000afa:	4779                	li	a4,30
    80000afc:	86ca                	mv	a3,s2
    80000afe:	6605                	lui	a2,0x1
    80000b00:	4581                	li	a1,0
    80000b02:	68a8                	ld	a0,80(s1)
    80000b04:	05d010ef          	jal	ra,80002360 <mappages>
    80000b08:	10054763          	bltz	a0,80000c16 <userinit+0x178>
    char *mem2 = kalloc();
    80000b0c:	df2ff0ef          	jal	ra,800000fe <kalloc>
    80000b10:	892a                	mv	s2,a0
    if(mem2 == 0)
    80000b12:	10050b63          	beqz	a0,80000c28 <userinit+0x18a>
    memset(mem2, 0, PGSIZE);
    80000b16:	6605                	lui	a2,0x1
    80000b18:	4581                	li	a1,0
    80000b1a:	21d000ef          	jal	ra,80001536 <memset>
    memmove(mem2, initcode + PGSIZE, remaining);
    80000b1e:	02000613          	li	a2,32
    80000b22:	00007597          	auipc	a1,0x7
    80000b26:	f3e58593          	addi	a1,a1,-194 # 80007a60 <initcode+0x1000>
    80000b2a:	854a                	mv	a0,s2
    80000b2c:	267000ef          	jal	ra,80001592 <memmove>
    if(mappages(p->pagetable, PGSIZE, PGSIZE, (uint64)mem2, PTE_W|PTE_R|PTE_X|PTE_U) < 0){
    80000b30:	4779                	li	a4,30
    80000b32:	86ca                	mv	a3,s2
    80000b34:	6605                	lui	a2,0x1
    80000b36:	6585                	lui	a1,0x1
    80000b38:	68a8                	ld	a0,80(s1)
    80000b3a:	027010ef          	jal	ra,80002360 <mappages>
    80000b3e:	0e054b63          	bltz	a0,80000c34 <userinit+0x196>
    p->sz = 2*PGSIZE;  // Program now takes 2 pages
    80000b42:	6789                	lui	a5,0x2
    80000b44:	e4bc                	sd	a5,72(s1)
  char *data1 = kalloc();
    80000b46:	db8ff0ef          	jal	ra,800000fe <kalloc>
    80000b4a:	892a                	mv	s2,a0
  if(data1 == 0)
    80000b4c:	0e050d63          	beqz	a0,80000c46 <userinit+0x1a8>
  memset(data1, 0, PGSIZE);
    80000b50:	6605                	lui	a2,0x1
    80000b52:	4581                	li	a1,0
    80000b54:	1e3000ef          	jal	ra,80001536 <memset>
  if(mappages(p->pagetable, p->sz, PGSIZE, (uint64)data1, PTE_W|PTE_R|PTE_U) < 0){
    80000b58:	4759                	li	a4,22
    80000b5a:	86ca                	mv	a3,s2
    80000b5c:	6605                	lui	a2,0x1
    80000b5e:	64ac                	ld	a1,72(s1)
    80000b60:	68a8                	ld	a0,80(s1)
    80000b62:	7fe010ef          	jal	ra,80002360 <mappages>
    80000b66:	0e054663          	bltz	a0,80000c52 <userinit+0x1b4>
  p->sz += PGSIZE;
    80000b6a:	64bc                	ld	a5,72(s1)
    80000b6c:	6705                	lui	a4,0x1
    80000b6e:	97ba                	add	a5,a5,a4
    80000b70:	e4bc                	sd	a5,72(s1)
  char *data2 = kalloc();
    80000b72:	d8cff0ef          	jal	ra,800000fe <kalloc>
    80000b76:	892a                	mv	s2,a0
  if(data2 == 0)
    80000b78:	0e050663          	beqz	a0,80000c64 <userinit+0x1c6>
  memset(data2, 0, PGSIZE);
    80000b7c:	6605                	lui	a2,0x1
    80000b7e:	4581                	li	a1,0
    80000b80:	1b7000ef          	jal	ra,80001536 <memset>
  if(mappages(p->pagetable, p->sz, PGSIZE, (uint64)data2, PTE_W|PTE_R|PTE_U) < 0){
    80000b84:	4759                	li	a4,22
    80000b86:	86ca                	mv	a3,s2
    80000b88:	6605                	lui	a2,0x1
    80000b8a:	64ac                	ld	a1,72(s1)
    80000b8c:	68a8                	ld	a0,80(s1)
    80000b8e:	7d2010ef          	jal	ra,80002360 <mappages>
    80000b92:	0c054f63          	bltz	a0,80000c70 <userinit+0x1d2>
  p->sz += PGSIZE;
    80000b96:	64bc                	ld	a5,72(s1)
    80000b98:	6705                	lui	a4,0x1
    80000b9a:	97ba                	add	a5,a5,a4
    80000b9c:	e4bc                	sd	a5,72(s1)
  char *stack = kalloc();
    80000b9e:	d60ff0ef          	jal	ra,800000fe <kalloc>
    80000ba2:	892a                	mv	s2,a0
  if(stack == 0)
    80000ba4:	0c050f63          	beqz	a0,80000c82 <userinit+0x1e4>
  memset(stack, 0, PGSIZE);
    80000ba8:	6605                	lui	a2,0x1
    80000baa:	4581                	li	a1,0
    80000bac:	18b000ef          	jal	ra,80001536 <memset>
  if(mappages(p->pagetable, p->sz, PGSIZE, (uint64)stack, PTE_W|PTE_R|PTE_U) < 0){
    80000bb0:	4759                	li	a4,22
    80000bb2:	86ca                	mv	a3,s2
    80000bb4:	6605                	lui	a2,0x1
    80000bb6:	64ac                	ld	a1,72(s1)
    80000bb8:	68a8                	ld	a0,80(s1)
    80000bba:	7a6010ef          	jal	ra,80002360 <mappages>
    80000bbe:	0c054863          	bltz	a0,80000c8e <userinit+0x1f0>
  uint64 stack_top = p->sz + PGSIZE;
    80000bc2:	64b8                	ld	a4,72(s1)
    80000bc4:	6785                	lui	a5,0x1
    80000bc6:	97ba                	add	a5,a5,a4
  p->sz += PGSIZE;
    80000bc8:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0x0;
    80000bca:	6cb8                	ld	a4,88(s1)
    80000bcc:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = stack_top;   // user stack pointer
    80000bd0:	6cb8                	ld	a4,88(s1)
    80000bd2:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80000bd4:	4641                	li	a2,16
    80000bd6:	00005597          	auipc	a1,0x5
    80000bda:	70258593          	addi	a1,a1,1794 # 800062d8 <digits+0x248>
    80000bde:	0d848513          	addi	a0,s1,216
    80000be2:	29b000ef          	jal	ra,8000167c <safestrcpy>
  p->cwd = namei("/");
    80000be6:	00005517          	auipc	a0,0x5
    80000bea:	70250513          	addi	a0,a0,1794 # 800062e8 <digits+0x258>
    80000bee:	686030ef          	jal	ra,80004274 <namei>
    80000bf2:	e8e8                	sd	a0,208(s1)
  p->state = RUNNABLE;
    80000bf4:	478d                	li	a5,3
    80000bf6:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80000bf8:	8526                	mv	a0,s1
    80000bfa:	04d000ef          	jal	ra,80001446 <release>
}
    80000bfe:	60e2                	ld	ra,24(sp)
    80000c00:	6442                	ld	s0,16(sp)
    80000c02:	64a2                	ld	s1,8(sp)
    80000c04:	6902                	ld	s2,0(sp)
    80000c06:	6105                	addi	sp,sp,32
    80000c08:	8082                	ret
      panic("userinit: out of memory for program page 1");
    80000c0a:	00005517          	auipc	a0,0x5
    80000c0e:	52650513          	addi	a0,a0,1318 # 80006130 <digits+0xa0>
    80000c12:	a5fff0ef          	jal	ra,80000670 <panic>
      kfree(mem1);
    80000c16:	854a                	mv	a0,s2
    80000c18:	c04ff0ef          	jal	ra,8000001c <kfree>
      panic("userinit: can't map program page 1");
    80000c1c:	00005517          	auipc	a0,0x5
    80000c20:	54450513          	addi	a0,a0,1348 # 80006160 <digits+0xd0>
    80000c24:	a4dff0ef          	jal	ra,80000670 <panic>
      panic("userinit: out of memory for program page 2");
    80000c28:	00005517          	auipc	a0,0x5
    80000c2c:	56050513          	addi	a0,a0,1376 # 80006188 <digits+0xf8>
    80000c30:	a41ff0ef          	jal	ra,80000670 <panic>
      kfree(mem2);
    80000c34:	854a                	mv	a0,s2
    80000c36:	be6ff0ef          	jal	ra,8000001c <kfree>
      panic("userinit: can't map program page 2");
    80000c3a:	00005517          	auipc	a0,0x5
    80000c3e:	57e50513          	addi	a0,a0,1406 # 800061b8 <digits+0x128>
    80000c42:	a2fff0ef          	jal	ra,80000670 <panic>
    panic("userinit: out of memory for global data page 1");
    80000c46:	00005517          	auipc	a0,0x5
    80000c4a:	59a50513          	addi	a0,a0,1434 # 800061e0 <digits+0x150>
    80000c4e:	a23ff0ef          	jal	ra,80000670 <panic>
    kfree(data1);
    80000c52:	854a                	mv	a0,s2
    80000c54:	bc8ff0ef          	jal	ra,8000001c <kfree>
    panic("userinit: can't map global data page 1");
    80000c58:	00005517          	auipc	a0,0x5
    80000c5c:	5b850513          	addi	a0,a0,1464 # 80006210 <digits+0x180>
    80000c60:	a11ff0ef          	jal	ra,80000670 <panic>
    panic("userinit: out of memory for global data page 2");
    80000c64:	00005517          	auipc	a0,0x5
    80000c68:	5d450513          	addi	a0,a0,1492 # 80006238 <digits+0x1a8>
    80000c6c:	a05ff0ef          	jal	ra,80000670 <panic>
    kfree(data2);
    80000c70:	854a                	mv	a0,s2
    80000c72:	baaff0ef          	jal	ra,8000001c <kfree>
    panic("userinit: can't map global data page 2");
    80000c76:	00005517          	auipc	a0,0x5
    80000c7a:	5f250513          	addi	a0,a0,1522 # 80006268 <digits+0x1d8>
    80000c7e:	9f3ff0ef          	jal	ra,80000670 <panic>
    panic("userinit: out of memory for stack");
    80000c82:	00005517          	auipc	a0,0x5
    80000c86:	60e50513          	addi	a0,a0,1550 # 80006290 <digits+0x200>
    80000c8a:	9e7ff0ef          	jal	ra,80000670 <panic>
    kfree(stack);
    80000c8e:	854a                	mv	a0,s2
    80000c90:	b8cff0ef          	jal	ra,8000001c <kfree>
    panic("userinit: can't map stack page");
    80000c94:	00005517          	auipc	a0,0x5
    80000c98:	62450513          	addi	a0,a0,1572 # 800062b8 <digits+0x228>
    80000c9c:	9d5ff0ef          	jal	ra,80000670 <panic>

0000000080000ca0 <growproc>:
{
    80000ca0:	1101                	addi	sp,sp,-32
    80000ca2:	ec06                	sd	ra,24(sp)
    80000ca4:	e822                	sd	s0,16(sp)
    80000ca6:	e426                	sd	s1,8(sp)
    80000ca8:	e04a                	sd	s2,0(sp)
    80000caa:	1000                	addi	s0,sp,32
    80000cac:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80000cae:	b89ff0ef          	jal	ra,80000836 <myproc>
    80000cb2:	84aa                	mv	s1,a0
  sz = p->sz;
    80000cb4:	652c                	ld	a1,72(a0)
  if(n > 0){
    80000cb6:	01204c63          	bgtz	s2,80000cce <growproc+0x2e>
  } else if(n < 0){
    80000cba:	02094463          	bltz	s2,80000ce2 <growproc+0x42>
  p->sz = sz;
    80000cbe:	e4ac                	sd	a1,72(s1)
  return 0;
    80000cc0:	4501                	li	a0,0
}
    80000cc2:	60e2                	ld	ra,24(sp)
    80000cc4:	6442                	ld	s0,16(sp)
    80000cc6:	64a2                	ld	s1,8(sp)
    80000cc8:	6902                	ld	s2,0(sp)
    80000cca:	6105                	addi	sp,sp,32
    80000ccc:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80000cce:	4691                	li	a3,4
    80000cd0:	00b90633          	add	a2,s2,a1
    80000cd4:	6928                	ld	a0,80(a0)
    80000cd6:	1a5010ef          	jal	ra,8000267a <uvmalloc>
    80000cda:	85aa                	mv	a1,a0
    80000cdc:	f16d                	bnez	a0,80000cbe <growproc+0x1e>
      return -1;
    80000cde:	557d                	li	a0,-1
    80000ce0:	b7cd                	j	80000cc2 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80000ce2:	00b90633          	add	a2,s2,a1
    80000ce6:	6928                	ld	a0,80(a0)
    80000ce8:	14f010ef          	jal	ra,80002636 <uvmdealloc>
    80000cec:	85aa                	mv	a1,a0
    80000cee:	bfc1                	j	80000cbe <growproc+0x1e>

0000000080000cf0 <fork>:
{
    80000cf0:	7179                	addi	sp,sp,-48
    80000cf2:	f406                	sd	ra,40(sp)
    80000cf4:	f022                	sd	s0,32(sp)
    80000cf6:	ec26                	sd	s1,24(sp)
    80000cf8:	e84a                	sd	s2,16(sp)
    80000cfa:	e44e                	sd	s3,8(sp)
    80000cfc:	e052                	sd	s4,0(sp)
    80000cfe:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80000d00:	b37ff0ef          	jal	ra,80000836 <myproc>
    80000d04:	8a2a                	mv	s4,a0
  if((np = allocproc()) == 0){
    80000d06:	cf3ff0ef          	jal	ra,800009f8 <allocproc>
    80000d0a:	cd4d                	beqz	a0,80000dc4 <fork+0xd4>
    80000d0c:	84aa                	mv	s1,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80000d0e:	048a3603          	ld	a2,72(s4)
    80000d12:	692c                	ld	a1,80(a0)
    80000d14:	050a3503          	ld	a0,80(s4)
    80000d18:	28f010ef          	jal	ra,800027a6 <uvmcopy>
    80000d1c:	08054c63          	bltz	a0,80000db4 <fork+0xc4>
  np->sz = p->sz;
    80000d20:	048a3783          	ld	a5,72(s4)
    80000d24:	e4bc                	sd	a5,72(s1)
  *(np->trapframe) = *(p->trapframe);
    80000d26:	058a3683          	ld	a3,88(s4)
    80000d2a:	87b6                	mv	a5,a3
    80000d2c:	6cb8                	ld	a4,88(s1)
    80000d2e:	12068693          	addi	a3,a3,288
    80000d32:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80000d36:	6788                	ld	a0,8(a5)
    80000d38:	6b8c                	ld	a1,16(a5)
    80000d3a:	6f90                	ld	a2,24(a5)
    80000d3c:	01073023          	sd	a6,0(a4)
    80000d40:	e708                	sd	a0,8(a4)
    80000d42:	eb0c                	sd	a1,16(a4)
    80000d44:	ef10                	sd	a2,24(a4)
    80000d46:	02078793          	addi	a5,a5,32
    80000d4a:	02070713          	addi	a4,a4,32
    80000d4e:	fed792e3          	bne	a5,a3,80000d32 <fork+0x42>
  np->trapframe->a0 = 0;
    80000d52:	6cbc                	ld	a5,88(s1)
    80000d54:	0607b823          	sd	zero,112(a5)
  np->cwd = idup(p->cwd);
    80000d58:	0d0a3503          	ld	a0,208(s4)
    80000d5c:	62d020ef          	jal	ra,80003b88 <idup>
    80000d60:	e8e8                	sd	a0,208(s1)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80000d62:	4641                	li	a2,16
    80000d64:	0d8a0593          	addi	a1,s4,216
    80000d68:	0d848513          	addi	a0,s1,216
    80000d6c:	111000ef          	jal	ra,8000167c <safestrcpy>
  pid = np->pid;
    80000d70:	0304a983          	lw	s3,48(s1)
  release(&np->lock);
    80000d74:	8526                	mv	a0,s1
    80000d76:	6d0000ef          	jal	ra,80001446 <release>
  acquire(&wait_lock);
    80000d7a:	00007917          	auipc	s2,0x7
    80000d7e:	dae90913          	addi	s2,s2,-594 # 80007b28 <wait_lock>
    80000d82:	854a                	mv	a0,s2
    80000d84:	62a000ef          	jal	ra,800013ae <acquire>
  np->parent = p;
    80000d88:	0344bc23          	sd	s4,56(s1)
  release(&wait_lock);
    80000d8c:	854a                	mv	a0,s2
    80000d8e:	6b8000ef          	jal	ra,80001446 <release>
  acquire(&np->lock);
    80000d92:	8526                	mv	a0,s1
    80000d94:	61a000ef          	jal	ra,800013ae <acquire>
  np->state = RUNNABLE;
    80000d98:	478d                	li	a5,3
    80000d9a:	cc9c                	sw	a5,24(s1)
  release(&np->lock);
    80000d9c:	8526                	mv	a0,s1
    80000d9e:	6a8000ef          	jal	ra,80001446 <release>
}
    80000da2:	854e                	mv	a0,s3
    80000da4:	70a2                	ld	ra,40(sp)
    80000da6:	7402                	ld	s0,32(sp)
    80000da8:	64e2                	ld	s1,24(sp)
    80000daa:	6942                	ld	s2,16(sp)
    80000dac:	69a2                	ld	s3,8(sp)
    80000dae:	6a02                	ld	s4,0(sp)
    80000db0:	6145                	addi	sp,sp,48
    80000db2:	8082                	ret
    freeproc(np);
    80000db4:	8526                	mv	a0,s1
    80000db6:	bf3ff0ef          	jal	ra,800009a8 <freeproc>
    release(&np->lock);
    80000dba:	8526                	mv	a0,s1
    80000dbc:	68a000ef          	jal	ra,80001446 <release>
    return -1;
    80000dc0:	59fd                	li	s3,-1
    80000dc2:	b7c5                	j	80000da2 <fork+0xb2>
    return -1;
    80000dc4:	59fd                	li	s3,-1
    80000dc6:	bff1                	j	80000da2 <fork+0xb2>

0000000080000dc8 <scheduler>:
{
    80000dc8:	715d                	addi	sp,sp,-80
    80000dca:	e486                	sd	ra,72(sp)
    80000dcc:	e0a2                	sd	s0,64(sp)
    80000dce:	fc26                	sd	s1,56(sp)
    80000dd0:	f84a                	sd	s2,48(sp)
    80000dd2:	f44e                	sd	s3,40(sp)
    80000dd4:	f052                	sd	s4,32(sp)
    80000dd6:	ec56                	sd	s5,24(sp)
    80000dd8:	e85a                	sd	s6,16(sp)
    80000dda:	e45e                	sd	s7,8(sp)
    80000ddc:	e062                	sd	s8,0(sp)
    80000dde:	0880                	addi	s0,sp,80
    80000de0:	8792                	mv	a5,tp
  int id = r_tp();
    80000de2:	2781                	sext.w	a5,a5
  c->proc = 0;
    80000de4:	00779b13          	slli	s6,a5,0x7
    80000de8:	00007717          	auipc	a4,0x7
    80000dec:	d2870713          	addi	a4,a4,-728 # 80007b10 <pid_lock>
    80000df0:	975a                	add	a4,a4,s6
    80000df2:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80000df6:	00007717          	auipc	a4,0x7
    80000dfa:	d5270713          	addi	a4,a4,-686 # 80007b48 <cpus+0x8>
    80000dfe:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80000e00:	4c11                	li	s8,4
        c->proc = p;
    80000e02:	079e                	slli	a5,a5,0x7
    80000e04:	00007a17          	auipc	s4,0x7
    80000e08:	d0ca0a13          	addi	s4,s4,-756 # 80007b10 <pid_lock>
    80000e0c:	9a3e                	add	s4,s4,a5
        found = 1;
    80000e0e:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80000e10:	0000b997          	auipc	s3,0xb
    80000e14:	b3098993          	addi	s3,s3,-1232 # 8000b940 <stack0>
    80000e18:	a0a9                	j	80000e62 <scheduler+0x9a>
      release(&p->lock);
    80000e1a:	8526                	mv	a0,s1
    80000e1c:	62a000ef          	jal	ra,80001446 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80000e20:	0e848493          	addi	s1,s1,232
    80000e24:	03348563          	beq	s1,s3,80000e4e <scheduler+0x86>
      acquire(&p->lock);
    80000e28:	8526                	mv	a0,s1
    80000e2a:	584000ef          	jal	ra,800013ae <acquire>
      if(p->state == RUNNABLE) {
    80000e2e:	4c9c                	lw	a5,24(s1)
    80000e30:	ff2795e3          	bne	a5,s2,80000e1a <scheduler+0x52>
        p->state = RUNNING;
    80000e34:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80000e38:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80000e3c:	06048593          	addi	a1,s1,96
    80000e40:	855a                	mv	a0,s6
    80000e42:	097000ef          	jal	ra,800016d8 <swtch>
        c->proc = 0;
    80000e46:	020a3823          	sd	zero,48(s4)
        found = 1;
    80000e4a:	8ade                	mv	s5,s7
    80000e4c:	b7f9                	j	80000e1a <scheduler+0x52>
    if(found == 0) {
    80000e4e:	000a9a63          	bnez	s5,80000e62 <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000e52:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000e56:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000e5a:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80000e5e:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000e62:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000e66:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000e6a:	10079073          	csrw	sstatus,a5
    int found = 0;
    80000e6e:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80000e70:	00007497          	auipc	s1,0x7
    80000e74:	0d048493          	addi	s1,s1,208 # 80007f40 <proc>
      if(p->state == RUNNABLE) {
    80000e78:	490d                	li	s2,3
    80000e7a:	b77d                	j	80000e28 <scheduler+0x60>

0000000080000e7c <sched>:
{
    80000e7c:	7179                	addi	sp,sp,-48
    80000e7e:	f406                	sd	ra,40(sp)
    80000e80:	f022                	sd	s0,32(sp)
    80000e82:	ec26                	sd	s1,24(sp)
    80000e84:	e84a                	sd	s2,16(sp)
    80000e86:	e44e                	sd	s3,8(sp)
    80000e88:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80000e8a:	9adff0ef          	jal	ra,80000836 <myproc>
    80000e8e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80000e90:	4b4000ef          	jal	ra,80001344 <holding>
    80000e94:	c92d                	beqz	a0,80000f06 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80000e96:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80000e98:	2781                	sext.w	a5,a5
    80000e9a:	079e                	slli	a5,a5,0x7
    80000e9c:	00007717          	auipc	a4,0x7
    80000ea0:	c7470713          	addi	a4,a4,-908 # 80007b10 <pid_lock>
    80000ea4:	97ba                	add	a5,a5,a4
    80000ea6:	0a87a703          	lw	a4,168(a5)
    80000eaa:	4785                	li	a5,1
    80000eac:	06f71363          	bne	a4,a5,80000f12 <sched+0x96>
  if(p->state == RUNNING)
    80000eb0:	4c98                	lw	a4,24(s1)
    80000eb2:	4791                	li	a5,4
    80000eb4:	06f70563          	beq	a4,a5,80000f1e <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000eb8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000ebc:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000ebe:	e7b5                	bnez	a5,80000f2a <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80000ec0:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80000ec2:	00007917          	auipc	s2,0x7
    80000ec6:	c4e90913          	addi	s2,s2,-946 # 80007b10 <pid_lock>
    80000eca:	2781                	sext.w	a5,a5
    80000ecc:	079e                	slli	a5,a5,0x7
    80000ece:	97ca                	add	a5,a5,s2
    80000ed0:	0ac7a983          	lw	s3,172(a5)
    80000ed4:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80000ed6:	2781                	sext.w	a5,a5
    80000ed8:	079e                	slli	a5,a5,0x7
    80000eda:	00007597          	auipc	a1,0x7
    80000ede:	c6e58593          	addi	a1,a1,-914 # 80007b48 <cpus+0x8>
    80000ee2:	95be                	add	a1,a1,a5
    80000ee4:	06048513          	addi	a0,s1,96
    80000ee8:	7f0000ef          	jal	ra,800016d8 <swtch>
    80000eec:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80000eee:	2781                	sext.w	a5,a5
    80000ef0:	079e                	slli	a5,a5,0x7
    80000ef2:	993e                	add	s2,s2,a5
    80000ef4:	0b392623          	sw	s3,172(s2)
}
    80000ef8:	70a2                	ld	ra,40(sp)
    80000efa:	7402                	ld	s0,32(sp)
    80000efc:	64e2                	ld	s1,24(sp)
    80000efe:	6942                	ld	s2,16(sp)
    80000f00:	69a2                	ld	s3,8(sp)
    80000f02:	6145                	addi	sp,sp,48
    80000f04:	8082                	ret
    panic("sched p->lock");
    80000f06:	00005517          	auipc	a0,0x5
    80000f0a:	3ea50513          	addi	a0,a0,1002 # 800062f0 <digits+0x260>
    80000f0e:	f62ff0ef          	jal	ra,80000670 <panic>
    panic("sched locks");
    80000f12:	00005517          	auipc	a0,0x5
    80000f16:	3ee50513          	addi	a0,a0,1006 # 80006300 <digits+0x270>
    80000f1a:	f56ff0ef          	jal	ra,80000670 <panic>
    panic("sched running");
    80000f1e:	00005517          	auipc	a0,0x5
    80000f22:	3f250513          	addi	a0,a0,1010 # 80006310 <digits+0x280>
    80000f26:	f4aff0ef          	jal	ra,80000670 <panic>
    panic("sched interruptible");
    80000f2a:	00005517          	auipc	a0,0x5
    80000f2e:	3f650513          	addi	a0,a0,1014 # 80006320 <digits+0x290>
    80000f32:	f3eff0ef          	jal	ra,80000670 <panic>

0000000080000f36 <yield>:
{
    80000f36:	1101                	addi	sp,sp,-32
    80000f38:	ec06                	sd	ra,24(sp)
    80000f3a:	e822                	sd	s0,16(sp)
    80000f3c:	e426                	sd	s1,8(sp)
    80000f3e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80000f40:	8f7ff0ef          	jal	ra,80000836 <myproc>
    80000f44:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80000f46:	468000ef          	jal	ra,800013ae <acquire>
  p->state = RUNNABLE;
    80000f4a:	478d                	li	a5,3
    80000f4c:	cc9c                	sw	a5,24(s1)
  sched();
    80000f4e:	f2fff0ef          	jal	ra,80000e7c <sched>
  release(&p->lock);
    80000f52:	8526                	mv	a0,s1
    80000f54:	4f2000ef          	jal	ra,80001446 <release>
}
    80000f58:	60e2                	ld	ra,24(sp)
    80000f5a:	6442                	ld	s0,16(sp)
    80000f5c:	64a2                	ld	s1,8(sp)
    80000f5e:	6105                	addi	sp,sp,32
    80000f60:	8082                	ret

0000000080000f62 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80000f62:	7179                	addi	sp,sp,-48
    80000f64:	f406                	sd	ra,40(sp)
    80000f66:	f022                	sd	s0,32(sp)
    80000f68:	ec26                	sd	s1,24(sp)
    80000f6a:	e84a                	sd	s2,16(sp)
    80000f6c:	e44e                	sd	s3,8(sp)
    80000f6e:	1800                	addi	s0,sp,48
    80000f70:	89aa                	mv	s3,a0
    80000f72:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80000f74:	8c3ff0ef          	jal	ra,80000836 <myproc>
    80000f78:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80000f7a:	434000ef          	jal	ra,800013ae <acquire>
  release(lk);
    80000f7e:	854a                	mv	a0,s2
    80000f80:	4c6000ef          	jal	ra,80001446 <release>

  // Go to sleep.
  p->chan = chan;
    80000f84:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80000f88:	4789                	li	a5,2
    80000f8a:	cc9c                	sw	a5,24(s1)

  sched();
    80000f8c:	ef1ff0ef          	jal	ra,80000e7c <sched>

  // Tidy up.
  p->chan = 0;
    80000f90:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80000f94:	8526                	mv	a0,s1
    80000f96:	4b0000ef          	jal	ra,80001446 <release>
  acquire(lk);
    80000f9a:	854a                	mv	a0,s2
    80000f9c:	412000ef          	jal	ra,800013ae <acquire>
}
    80000fa0:	70a2                	ld	ra,40(sp)
    80000fa2:	7402                	ld	s0,32(sp)
    80000fa4:	64e2                	ld	s1,24(sp)
    80000fa6:	6942                	ld	s2,16(sp)
    80000fa8:	69a2                	ld	s3,8(sp)
    80000faa:	6145                	addi	sp,sp,48
    80000fac:	8082                	ret

0000000080000fae <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80000fae:	7139                	addi	sp,sp,-64
    80000fb0:	fc06                	sd	ra,56(sp)
    80000fb2:	f822                	sd	s0,48(sp)
    80000fb4:	f426                	sd	s1,40(sp)
    80000fb6:	f04a                	sd	s2,32(sp)
    80000fb8:	ec4e                	sd	s3,24(sp)
    80000fba:	e852                	sd	s4,16(sp)
    80000fbc:	e456                	sd	s5,8(sp)
    80000fbe:	0080                	addi	s0,sp,64
    80000fc0:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80000fc2:	00007497          	auipc	s1,0x7
    80000fc6:	f7e48493          	addi	s1,s1,-130 # 80007f40 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80000fca:	4989                	li	s3,2
        p->state = RUNNABLE;
    80000fcc:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80000fce:	0000b917          	auipc	s2,0xb
    80000fd2:	97290913          	addi	s2,s2,-1678 # 8000b940 <stack0>
    80000fd6:	a801                	j	80000fe6 <wakeup+0x38>
      }
      release(&p->lock);
    80000fd8:	8526                	mv	a0,s1
    80000fda:	46c000ef          	jal	ra,80001446 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000fde:	0e848493          	addi	s1,s1,232
    80000fe2:	03248263          	beq	s1,s2,80001006 <wakeup+0x58>
    if(p != myproc()){
    80000fe6:	851ff0ef          	jal	ra,80000836 <myproc>
    80000fea:	fea48ae3          	beq	s1,a0,80000fde <wakeup+0x30>
      acquire(&p->lock);
    80000fee:	8526                	mv	a0,s1
    80000ff0:	3be000ef          	jal	ra,800013ae <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80000ff4:	4c9c                	lw	a5,24(s1)
    80000ff6:	ff3791e3          	bne	a5,s3,80000fd8 <wakeup+0x2a>
    80000ffa:	709c                	ld	a5,32(s1)
    80000ffc:	fd479ee3          	bne	a5,s4,80000fd8 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001000:	0154ac23          	sw	s5,24(s1)
    80001004:	bfd1                	j	80000fd8 <wakeup+0x2a>
    }
  }
}
    80001006:	70e2                	ld	ra,56(sp)
    80001008:	7442                	ld	s0,48(sp)
    8000100a:	74a2                	ld	s1,40(sp)
    8000100c:	7902                	ld	s2,32(sp)
    8000100e:	69e2                	ld	s3,24(sp)
    80001010:	6a42                	ld	s4,16(sp)
    80001012:	6aa2                	ld	s5,8(sp)
    80001014:	6121                	addi	sp,sp,64
    80001016:	8082                	ret

0000000080001018 <reparent>:
{
    80001018:	7179                	addi	sp,sp,-48
    8000101a:	f406                	sd	ra,40(sp)
    8000101c:	f022                	sd	s0,32(sp)
    8000101e:	ec26                	sd	s1,24(sp)
    80001020:	e84a                	sd	s2,16(sp)
    80001022:	e44e                	sd	s3,8(sp)
    80001024:	e052                	sd	s4,0(sp)
    80001026:	1800                	addi	s0,sp,48
    80001028:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000102a:	00007497          	auipc	s1,0x7
    8000102e:	f1648493          	addi	s1,s1,-234 # 80007f40 <proc>
      pp->parent = initproc;
    80001032:	00007a17          	auipc	s4,0x7
    80001036:	a76a0a13          	addi	s4,s4,-1418 # 80007aa8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000103a:	0000b997          	auipc	s3,0xb
    8000103e:	90698993          	addi	s3,s3,-1786 # 8000b940 <stack0>
    80001042:	a029                	j	8000104c <reparent+0x34>
    80001044:	0e848493          	addi	s1,s1,232
    80001048:	01348b63          	beq	s1,s3,8000105e <reparent+0x46>
    if(pp->parent == p){
    8000104c:	7c9c                	ld	a5,56(s1)
    8000104e:	ff279be3          	bne	a5,s2,80001044 <reparent+0x2c>
      pp->parent = initproc;
    80001052:	000a3503          	ld	a0,0(s4)
    80001056:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001058:	f57ff0ef          	jal	ra,80000fae <wakeup>
    8000105c:	b7e5                	j	80001044 <reparent+0x2c>
}
    8000105e:	70a2                	ld	ra,40(sp)
    80001060:	7402                	ld	s0,32(sp)
    80001062:	64e2                	ld	s1,24(sp)
    80001064:	6942                	ld	s2,16(sp)
    80001066:	69a2                	ld	s3,8(sp)
    80001068:	6a02                	ld	s4,0(sp)
    8000106a:	6145                	addi	sp,sp,48
    8000106c:	8082                	ret

000000008000106e <exit>:
{
    8000106e:	7179                	addi	sp,sp,-48
    80001070:	f406                	sd	ra,40(sp)
    80001072:	f022                	sd	s0,32(sp)
    80001074:	ec26                	sd	s1,24(sp)
    80001076:	e84a                	sd	s2,16(sp)
    80001078:	e44e                	sd	s3,8(sp)
    8000107a:	1800                	addi	s0,sp,48
    8000107c:	892a                	mv	s2,a0
  struct proc *p = myproc();
    8000107e:	fb8ff0ef          	jal	ra,80000836 <myproc>
  if(p == initproc)
    80001082:	00007797          	auipc	a5,0x7
    80001086:	a267b783          	ld	a5,-1498(a5) # 80007aa8 <initproc>
    8000108a:	04a78b63          	beq	a5,a0,800010e0 <exit+0x72>
    8000108e:	84aa                	mv	s1,a0
  begin_op();
    80001090:	3c0030ef          	jal	ra,80004450 <begin_op>
  iput(p->cwd);
    80001094:	68e8                	ld	a0,208(s1)
    80001096:	4a7020ef          	jal	ra,80003d3c <iput>
  end_op();
    8000109a:	424030ef          	jal	ra,800044be <end_op>
  p->cwd = 0;
    8000109e:	0c04b823          	sd	zero,208(s1)
  acquire(&wait_lock);
    800010a2:	00007997          	auipc	s3,0x7
    800010a6:	a8698993          	addi	s3,s3,-1402 # 80007b28 <wait_lock>
    800010aa:	854e                	mv	a0,s3
    800010ac:	302000ef          	jal	ra,800013ae <acquire>
  reparent(p);
    800010b0:	8526                	mv	a0,s1
    800010b2:	f67ff0ef          	jal	ra,80001018 <reparent>
  wakeup(p->parent);
    800010b6:	7c88                	ld	a0,56(s1)
    800010b8:	ef7ff0ef          	jal	ra,80000fae <wakeup>
  acquire(&p->lock);
    800010bc:	8526                	mv	a0,s1
    800010be:	2f0000ef          	jal	ra,800013ae <acquire>
  p->xstate = status;
    800010c2:	0324a623          	sw	s2,44(s1)
  p->state = ZOMBIE;
    800010c6:	4795                	li	a5,5
    800010c8:	cc9c                	sw	a5,24(s1)
  release(&wait_lock);
    800010ca:	854e                	mv	a0,s3
    800010cc:	37a000ef          	jal	ra,80001446 <release>
  sched();
    800010d0:	dadff0ef          	jal	ra,80000e7c <sched>
  panic("zombie exit");
    800010d4:	00005517          	auipc	a0,0x5
    800010d8:	27450513          	addi	a0,a0,628 # 80006348 <digits+0x2b8>
    800010dc:	d94ff0ef          	jal	ra,80000670 <panic>
    panic("init exiting");
    800010e0:	00005517          	auipc	a0,0x5
    800010e4:	25850513          	addi	a0,a0,600 # 80006338 <digits+0x2a8>
    800010e8:	d88ff0ef          	jal	ra,80000670 <panic>

00000000800010ec <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800010ec:	7179                	addi	sp,sp,-48
    800010ee:	f406                	sd	ra,40(sp)
    800010f0:	f022                	sd	s0,32(sp)
    800010f2:	ec26                	sd	s1,24(sp)
    800010f4:	e84a                	sd	s2,16(sp)
    800010f6:	e44e                	sd	s3,8(sp)
    800010f8:	1800                	addi	s0,sp,48
    800010fa:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800010fc:	00007497          	auipc	s1,0x7
    80001100:	e4448493          	addi	s1,s1,-444 # 80007f40 <proc>
    80001104:	0000b997          	auipc	s3,0xb
    80001108:	83c98993          	addi	s3,s3,-1988 # 8000b940 <stack0>
    acquire(&p->lock);
    8000110c:	8526                	mv	a0,s1
    8000110e:	2a0000ef          	jal	ra,800013ae <acquire>
    if(p->pid == pid){
    80001112:	589c                	lw	a5,48(s1)
    80001114:	01278b63          	beq	a5,s2,8000112a <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80001118:	8526                	mv	a0,s1
    8000111a:	32c000ef          	jal	ra,80001446 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000111e:	0e848493          	addi	s1,s1,232
    80001122:	ff3495e3          	bne	s1,s3,8000110c <kill+0x20>
  }
  return -1;
    80001126:	557d                	li	a0,-1
    80001128:	a819                	j	8000113e <kill+0x52>
      p->killed = 1;
    8000112a:	4785                	li	a5,1
    8000112c:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000112e:	4c98                	lw	a4,24(s1)
    80001130:	4789                	li	a5,2
    80001132:	00f70d63          	beq	a4,a5,8000114c <kill+0x60>
      release(&p->lock);
    80001136:	8526                	mv	a0,s1
    80001138:	30e000ef          	jal	ra,80001446 <release>
      return 0;
    8000113c:	4501                	li	a0,0
}
    8000113e:	70a2                	ld	ra,40(sp)
    80001140:	7402                	ld	s0,32(sp)
    80001142:	64e2                	ld	s1,24(sp)
    80001144:	6942                	ld	s2,16(sp)
    80001146:	69a2                	ld	s3,8(sp)
    80001148:	6145                	addi	sp,sp,48
    8000114a:	8082                	ret
        p->state = RUNNABLE;
    8000114c:	478d                	li	a5,3
    8000114e:	cc9c                	sw	a5,24(s1)
    80001150:	b7dd                	j	80001136 <kill+0x4a>

0000000080001152 <setkilled>:

void
setkilled(struct proc *p)
{
    80001152:	1101                	addi	sp,sp,-32
    80001154:	ec06                	sd	ra,24(sp)
    80001156:	e822                	sd	s0,16(sp)
    80001158:	e426                	sd	s1,8(sp)
    8000115a:	1000                	addi	s0,sp,32
    8000115c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000115e:	250000ef          	jal	ra,800013ae <acquire>
  p->killed = 1;
    80001162:	4785                	li	a5,1
    80001164:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80001166:	8526                	mv	a0,s1
    80001168:	2de000ef          	jal	ra,80001446 <release>
}
    8000116c:	60e2                	ld	ra,24(sp)
    8000116e:	6442                	ld	s0,16(sp)
    80001170:	64a2                	ld	s1,8(sp)
    80001172:	6105                	addi	sp,sp,32
    80001174:	8082                	ret

0000000080001176 <killed>:

int
killed(struct proc *p)
{
    80001176:	1101                	addi	sp,sp,-32
    80001178:	ec06                	sd	ra,24(sp)
    8000117a:	e822                	sd	s0,16(sp)
    8000117c:	e426                	sd	s1,8(sp)
    8000117e:	e04a                	sd	s2,0(sp)
    80001180:	1000                	addi	s0,sp,32
    80001182:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80001184:	22a000ef          	jal	ra,800013ae <acquire>
  k = p->killed;
    80001188:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000118c:	8526                	mv	a0,s1
    8000118e:	2b8000ef          	jal	ra,80001446 <release>
  return k;
}
    80001192:	854a                	mv	a0,s2
    80001194:	60e2                	ld	ra,24(sp)
    80001196:	6442                	ld	s0,16(sp)
    80001198:	64a2                	ld	s1,8(sp)
    8000119a:	6902                	ld	s2,0(sp)
    8000119c:	6105                	addi	sp,sp,32
    8000119e:	8082                	ret

00000000800011a0 <wait>:
{
    800011a0:	715d                	addi	sp,sp,-80
    800011a2:	e486                	sd	ra,72(sp)
    800011a4:	e0a2                	sd	s0,64(sp)
    800011a6:	fc26                	sd	s1,56(sp)
    800011a8:	f84a                	sd	s2,48(sp)
    800011aa:	f44e                	sd	s3,40(sp)
    800011ac:	f052                	sd	s4,32(sp)
    800011ae:	ec56                	sd	s5,24(sp)
    800011b0:	e85a                	sd	s6,16(sp)
    800011b2:	e45e                	sd	s7,8(sp)
    800011b4:	e062                	sd	s8,0(sp)
    800011b6:	0880                	addi	s0,sp,80
    800011b8:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800011ba:	e7cff0ef          	jal	ra,80000836 <myproc>
    800011be:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800011c0:	00007517          	auipc	a0,0x7
    800011c4:	96850513          	addi	a0,a0,-1688 # 80007b28 <wait_lock>
    800011c8:	1e6000ef          	jal	ra,800013ae <acquire>
    havekids = 0;
    800011cc:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800011ce:	4a15                	li	s4,5
        havekids = 1;
    800011d0:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800011d2:	0000a997          	auipc	s3,0xa
    800011d6:	76e98993          	addi	s3,s3,1902 # 8000b940 <stack0>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800011da:	00007c17          	auipc	s8,0x7
    800011de:	94ec0c13          	addi	s8,s8,-1714 # 80007b28 <wait_lock>
    havekids = 0;
    800011e2:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800011e4:	00007497          	auipc	s1,0x7
    800011e8:	d5c48493          	addi	s1,s1,-676 # 80007f40 <proc>
    800011ec:	a899                	j	80001242 <wait+0xa2>
          pid = pp->pid;
    800011ee:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800011f2:	000b0c63          	beqz	s6,8000120a <wait+0x6a>
    800011f6:	4691                	li	a3,4
    800011f8:	02c48613          	addi	a2,s1,44
    800011fc:	85da                	mv	a1,s6
    800011fe:	05093503          	ld	a0,80(s2)
    80001202:	680010ef          	jal	ra,80002882 <copyout>
    80001206:	00054f63          	bltz	a0,80001224 <wait+0x84>
          freeproc(pp);
    8000120a:	8526                	mv	a0,s1
    8000120c:	f9cff0ef          	jal	ra,800009a8 <freeproc>
          release(&pp->lock);
    80001210:	8526                	mv	a0,s1
    80001212:	234000ef          	jal	ra,80001446 <release>
          release(&wait_lock);
    80001216:	00007517          	auipc	a0,0x7
    8000121a:	91250513          	addi	a0,a0,-1774 # 80007b28 <wait_lock>
    8000121e:	228000ef          	jal	ra,80001446 <release>
          return pid;
    80001222:	a891                	j	80001276 <wait+0xd6>
            release(&pp->lock);
    80001224:	8526                	mv	a0,s1
    80001226:	220000ef          	jal	ra,80001446 <release>
            release(&wait_lock);
    8000122a:	00007517          	auipc	a0,0x7
    8000122e:	8fe50513          	addi	a0,a0,-1794 # 80007b28 <wait_lock>
    80001232:	214000ef          	jal	ra,80001446 <release>
            return -1;
    80001236:	59fd                	li	s3,-1
    80001238:	a83d                	j	80001276 <wait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000123a:	0e848493          	addi	s1,s1,232
    8000123e:	03348063          	beq	s1,s3,8000125e <wait+0xbe>
      if(pp->parent == p){
    80001242:	7c9c                	ld	a5,56(s1)
    80001244:	ff279be3          	bne	a5,s2,8000123a <wait+0x9a>
        acquire(&pp->lock);
    80001248:	8526                	mv	a0,s1
    8000124a:	164000ef          	jal	ra,800013ae <acquire>
        if(pp->state == ZOMBIE){
    8000124e:	4c9c                	lw	a5,24(s1)
    80001250:	f9478fe3          	beq	a5,s4,800011ee <wait+0x4e>
        release(&pp->lock);
    80001254:	8526                	mv	a0,s1
    80001256:	1f0000ef          	jal	ra,80001446 <release>
        havekids = 1;
    8000125a:	8756                	mv	a4,s5
    8000125c:	bff9                	j	8000123a <wait+0x9a>
    if(!havekids || killed(p)){
    8000125e:	c709                	beqz	a4,80001268 <wait+0xc8>
    80001260:	854a                	mv	a0,s2
    80001262:	f15ff0ef          	jal	ra,80001176 <killed>
    80001266:	c50d                	beqz	a0,80001290 <wait+0xf0>
      release(&wait_lock);
    80001268:	00007517          	auipc	a0,0x7
    8000126c:	8c050513          	addi	a0,a0,-1856 # 80007b28 <wait_lock>
    80001270:	1d6000ef          	jal	ra,80001446 <release>
      return -1;
    80001274:	59fd                	li	s3,-1
}
    80001276:	854e                	mv	a0,s3
    80001278:	60a6                	ld	ra,72(sp)
    8000127a:	6406                	ld	s0,64(sp)
    8000127c:	74e2                	ld	s1,56(sp)
    8000127e:	7942                	ld	s2,48(sp)
    80001280:	79a2                	ld	s3,40(sp)
    80001282:	7a02                	ld	s4,32(sp)
    80001284:	6ae2                	ld	s5,24(sp)
    80001286:	6b42                	ld	s6,16(sp)
    80001288:	6ba2                	ld	s7,8(sp)
    8000128a:	6c02                	ld	s8,0(sp)
    8000128c:	6161                	addi	sp,sp,80
    8000128e:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001290:	85e2                	mv	a1,s8
    80001292:	854a                	mv	a0,s2
    80001294:	ccfff0ef          	jal	ra,80000f62 <sleep>
    havekids = 0;
    80001298:	b7a9                	j	800011e2 <wait+0x42>

000000008000129a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000129a:	7179                	addi	sp,sp,-48
    8000129c:	f406                	sd	ra,40(sp)
    8000129e:	f022                	sd	s0,32(sp)
    800012a0:	ec26                	sd	s1,24(sp)
    800012a2:	e84a                	sd	s2,16(sp)
    800012a4:	e44e                	sd	s3,8(sp)
    800012a6:	e052                	sd	s4,0(sp)
    800012a8:	1800                	addi	s0,sp,48
    800012aa:	84aa                	mv	s1,a0
    800012ac:	892e                	mv	s2,a1
    800012ae:	89b2                	mv	s3,a2
    800012b0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800012b2:	d84ff0ef          	jal	ra,80000836 <myproc>
  if(user_dst){
    800012b6:	cc99                	beqz	s1,800012d4 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800012b8:	86d2                	mv	a3,s4
    800012ba:	864e                	mv	a2,s3
    800012bc:	85ca                	mv	a1,s2
    800012be:	6928                	ld	a0,80(a0)
    800012c0:	5c2010ef          	jal	ra,80002882 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800012c4:	70a2                	ld	ra,40(sp)
    800012c6:	7402                	ld	s0,32(sp)
    800012c8:	64e2                	ld	s1,24(sp)
    800012ca:	6942                	ld	s2,16(sp)
    800012cc:	69a2                	ld	s3,8(sp)
    800012ce:	6a02                	ld	s4,0(sp)
    800012d0:	6145                	addi	sp,sp,48
    800012d2:	8082                	ret
    memmove((char *)dst, src, len);
    800012d4:	000a061b          	sext.w	a2,s4
    800012d8:	85ce                	mv	a1,s3
    800012da:	854a                	mv	a0,s2
    800012dc:	2b6000ef          	jal	ra,80001592 <memmove>
    return 0;
    800012e0:	8526                	mv	a0,s1
    800012e2:	b7cd                	j	800012c4 <either_copyout+0x2a>

00000000800012e4 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800012e4:	7179                	addi	sp,sp,-48
    800012e6:	f406                	sd	ra,40(sp)
    800012e8:	f022                	sd	s0,32(sp)
    800012ea:	ec26                	sd	s1,24(sp)
    800012ec:	e84a                	sd	s2,16(sp)
    800012ee:	e44e                	sd	s3,8(sp)
    800012f0:	e052                	sd	s4,0(sp)
    800012f2:	1800                	addi	s0,sp,48
    800012f4:	892a                	mv	s2,a0
    800012f6:	84ae                	mv	s1,a1
    800012f8:	89b2                	mv	s3,a2
    800012fa:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800012fc:	d3aff0ef          	jal	ra,80000836 <myproc>
  if(user_src){
    80001300:	cc99                	beqz	s1,8000131e <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80001302:	86d2                	mv	a3,s4
    80001304:	864e                	mv	a2,s3
    80001306:	85ca                	mv	a1,s2
    80001308:	6928                	ld	a0,80(a0)
    8000130a:	630010ef          	jal	ra,8000293a <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000130e:	70a2                	ld	ra,40(sp)
    80001310:	7402                	ld	s0,32(sp)
    80001312:	64e2                	ld	s1,24(sp)
    80001314:	6942                	ld	s2,16(sp)
    80001316:	69a2                	ld	s3,8(sp)
    80001318:	6a02                	ld	s4,0(sp)
    8000131a:	6145                	addi	sp,sp,48
    8000131c:	8082                	ret
    memmove(dst, (char*)src, len);
    8000131e:	000a061b          	sext.w	a2,s4
    80001322:	85ce                	mv	a1,s3
    80001324:	854a                	mv	a0,s2
    80001326:	26c000ef          	jal	ra,80001592 <memmove>
    return 0;
    8000132a:	8526                	mv	a0,s1
    8000132c:	b7cd                	j	8000130e <either_copyin+0x2a>

000000008000132e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    8000132e:	1141                	addi	sp,sp,-16
    80001330:	e422                	sd	s0,8(sp)
    80001332:	0800                	addi	s0,sp,16
  lk->name = name;
    80001334:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80001336:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    8000133a:	00053823          	sd	zero,16(a0)
}
    8000133e:	6422                	ld	s0,8(sp)
    80001340:	0141                	addi	sp,sp,16
    80001342:	8082                	ret

0000000080001344 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80001344:	411c                	lw	a5,0(a0)
    80001346:	e399                	bnez	a5,8000134c <holding+0x8>
    80001348:	4501                	li	a0,0
  return r;
}
    8000134a:	8082                	ret
{
    8000134c:	1101                	addi	sp,sp,-32
    8000134e:	ec06                	sd	ra,24(sp)
    80001350:	e822                	sd	s0,16(sp)
    80001352:	e426                	sd	s1,8(sp)
    80001354:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80001356:	6904                	ld	s1,16(a0)
    80001358:	cc2ff0ef          	jal	ra,8000081a <mycpu>
    8000135c:	40a48533          	sub	a0,s1,a0
    80001360:	00153513          	seqz	a0,a0
}
    80001364:	60e2                	ld	ra,24(sp)
    80001366:	6442                	ld	s0,16(sp)
    80001368:	64a2                	ld	s1,8(sp)
    8000136a:	6105                	addi	sp,sp,32
    8000136c:	8082                	ret

000000008000136e <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    8000136e:	1101                	addi	sp,sp,-32
    80001370:	ec06                	sd	ra,24(sp)
    80001372:	e822                	sd	s0,16(sp)
    80001374:	e426                	sd	s1,8(sp)
    80001376:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001378:	100024f3          	csrr	s1,sstatus
    8000137c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001380:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001382:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80001386:	c94ff0ef          	jal	ra,8000081a <mycpu>
    8000138a:	5d3c                	lw	a5,120(a0)
    8000138c:	cb99                	beqz	a5,800013a2 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    8000138e:	c8cff0ef          	jal	ra,8000081a <mycpu>
    80001392:	5d3c                	lw	a5,120(a0)
    80001394:	2785                	addiw	a5,a5,1
    80001396:	dd3c                	sw	a5,120(a0)
}
    80001398:	60e2                	ld	ra,24(sp)
    8000139a:	6442                	ld	s0,16(sp)
    8000139c:	64a2                	ld	s1,8(sp)
    8000139e:	6105                	addi	sp,sp,32
    800013a0:	8082                	ret
    mycpu()->intena = old;
    800013a2:	c78ff0ef          	jal	ra,8000081a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    800013a6:	8085                	srli	s1,s1,0x1
    800013a8:	8885                	andi	s1,s1,1
    800013aa:	dd64                	sw	s1,124(a0)
    800013ac:	b7cd                	j	8000138e <push_off+0x20>

00000000800013ae <acquire>:
{
    800013ae:	1101                	addi	sp,sp,-32
    800013b0:	ec06                	sd	ra,24(sp)
    800013b2:	e822                	sd	s0,16(sp)
    800013b4:	e426                	sd	s1,8(sp)
    800013b6:	1000                	addi	s0,sp,32
    800013b8:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    800013ba:	fb5ff0ef          	jal	ra,8000136e <push_off>
  if(holding(lk))
    800013be:	8526                	mv	a0,s1
    800013c0:	f85ff0ef          	jal	ra,80001344 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800013c4:	4705                	li	a4,1
  if(holding(lk))
    800013c6:	e105                	bnez	a0,800013e6 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800013c8:	87ba                	mv	a5,a4
    800013ca:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    800013ce:	2781                	sext.w	a5,a5
    800013d0:	ffe5                	bnez	a5,800013c8 <acquire+0x1a>
  __sync_synchronize();
    800013d2:	0ff0000f          	fence
  lk->cpu = mycpu();
    800013d6:	c44ff0ef          	jal	ra,8000081a <mycpu>
    800013da:	e888                	sd	a0,16(s1)
}
    800013dc:	60e2                	ld	ra,24(sp)
    800013de:	6442                	ld	s0,16(sp)
    800013e0:	64a2                	ld	s1,8(sp)
    800013e2:	6105                	addi	sp,sp,32
    800013e4:	8082                	ret
    panic("acquire");
    800013e6:	00005517          	auipc	a0,0x5
    800013ea:	f7250513          	addi	a0,a0,-142 # 80006358 <digits+0x2c8>
    800013ee:	a82ff0ef          	jal	ra,80000670 <panic>

00000000800013f2 <pop_off>:

void
pop_off(void)
{
    800013f2:	1141                	addi	sp,sp,-16
    800013f4:	e406                	sd	ra,8(sp)
    800013f6:	e022                	sd	s0,0(sp)
    800013f8:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    800013fa:	c20ff0ef          	jal	ra,8000081a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800013fe:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001402:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001404:	e78d                	bnez	a5,8000142e <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80001406:	5d3c                	lw	a5,120(a0)
    80001408:	02f05963          	blez	a5,8000143a <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    8000140c:	37fd                	addiw	a5,a5,-1
    8000140e:	0007871b          	sext.w	a4,a5
    80001412:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80001414:	eb09                	bnez	a4,80001426 <pop_off+0x34>
    80001416:	5d7c                	lw	a5,124(a0)
    80001418:	c799                	beqz	a5,80001426 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000141a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000141e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001422:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80001426:	60a2                	ld	ra,8(sp)
    80001428:	6402                	ld	s0,0(sp)
    8000142a:	0141                	addi	sp,sp,16
    8000142c:	8082                	ret
    panic("pop_off - interruptible");
    8000142e:	00005517          	auipc	a0,0x5
    80001432:	f3250513          	addi	a0,a0,-206 # 80006360 <digits+0x2d0>
    80001436:	a3aff0ef          	jal	ra,80000670 <panic>
    panic("pop_off");
    8000143a:	00005517          	auipc	a0,0x5
    8000143e:	f3e50513          	addi	a0,a0,-194 # 80006378 <digits+0x2e8>
    80001442:	a2eff0ef          	jal	ra,80000670 <panic>

0000000080001446 <release>:
{
    80001446:	1101                	addi	sp,sp,-32
    80001448:	ec06                	sd	ra,24(sp)
    8000144a:	e822                	sd	s0,16(sp)
    8000144c:	e426                	sd	s1,8(sp)
    8000144e:	1000                	addi	s0,sp,32
    80001450:	84aa                	mv	s1,a0
  if(!holding(lk))
    80001452:	ef3ff0ef          	jal	ra,80001344 <holding>
    80001456:	c105                	beqz	a0,80001476 <release+0x30>
  lk->cpu = 0;
    80001458:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    8000145c:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80001460:	0f50000f          	fence	iorw,ow
    80001464:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80001468:	f8bff0ef          	jal	ra,800013f2 <pop_off>
}
    8000146c:	60e2                	ld	ra,24(sp)
    8000146e:	6442                	ld	s0,16(sp)
    80001470:	64a2                	ld	s1,8(sp)
    80001472:	6105                	addi	sp,sp,32
    80001474:	8082                	ret
    panic("release");
    80001476:	00005517          	auipc	a0,0x5
    8000147a:	f0a50513          	addi	a0,a0,-246 # 80006380 <digits+0x2f0>
    8000147e:	9f2ff0ef          	jal	ra,80000670 <panic>

0000000080001482 <timerinit>:

// ask each hart to generate timer interrupts.
// 设备驱动程序
void
timerinit()
{
    80001482:	1141                	addi	sp,sp,-16
    80001484:	e422                	sd	s0,8(sp)
    80001486:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mie" : "=r" (x) );
    80001488:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  // 使能S模式下的定时器中断
  w_mie(r_mie() | MIE_STIE);
    8000148c:	0207e793          	ori	a5,a5,32
  asm volatile("csrw mie, %0" : : "r" (x));
    80001490:	30479073          	csrw	mie,a5
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80001494:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  // 使能sstc扩展
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80001498:	577d                	li	a4,-1
    8000149a:	177e                	slli	a4,a4,0x3f
    8000149c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    8000149e:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    800014a2:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  // 允许s模式下访问计数器
  w_mcounteren(r_mcounteren() | 2);
    800014a6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    800014aa:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    800014ae:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  // 设置下一个定时器中断的时间点
  w_stimecmp(r_time() + 1000000);
    800014b2:	000f4737          	lui	a4,0xf4
    800014b6:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800014ba:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800014bc:	14d79073          	csrw	0x14d,a5
}
    800014c0:	6422                	ld	s0,8(sp)
    800014c2:	0141                	addi	sp,sp,16
    800014c4:	8082                	ret

00000000800014c6 <start>:
{
    800014c6:	1141                	addi	sp,sp,-16
    800014c8:	e406                	sd	ra,8(sp)
    800014ca:	e022                	sd	s0,0(sp)
    800014cc:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    800014ce:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK; // MSTATUS_MPP_MASK 是MPP字段的掩码（表示上一次特权级）
    800014d2:	7779                	lui	a4,0xffffe
    800014d4:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffe0aff>
    800014d8:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S; // 先清楚MPP字段，在设置为S（Supervisor）模式
    800014da:	6705                	lui	a4,0x1
    800014dc:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800014e0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800014e2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800014e6:	fffff797          	auipc	a5,0xfffff
    800014ea:	cc878793          	addi	a5,a5,-824 # 800001ae <main>
    800014ee:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800014f2:	4781                	li	a5,0
    800014f4:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800014f8:	67c1                	lui	a5,0x10
    800014fa:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800014fc:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80001500:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80001504:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80001508:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    8000150c:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80001510:	57fd                	li	a5,-1
    80001512:	83a9                	srli	a5,a5,0xa
    80001514:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80001518:	47bd                	li	a5,15
    8000151a:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    8000151e:	f65ff0ef          	jal	ra,80001482 <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80001522:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    80001526:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    80001528:	823e                	mv	tp,a5
  asm volatile("mret"); 
    8000152a:	30200073          	mret
}
    8000152e:	60a2                	ld	ra,8(sp)
    80001530:	6402                	ld	s0,0(sp)
    80001532:	0141                	addi	sp,sp,16
    80001534:	8082                	ret

0000000080001536 <memset>:
// 文件直接使用了xv6标准文件，应该没有错误 //
//////////////////////////////////////////

void*
memset(void *dst, int c, uint n)
{
    80001536:	1141                	addi	sp,sp,-16
    80001538:	e422                	sd	s0,8(sp)
    8000153a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    8000153c:	ca19                	beqz	a2,80001552 <memset+0x1c>
    8000153e:	87aa                	mv	a5,a0
    80001540:	1602                	slli	a2,a2,0x20
    80001542:	9201                	srli	a2,a2,0x20
    80001544:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80001548:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    8000154c:	0785                	addi	a5,a5,1
    8000154e:	fee79de3          	bne	a5,a4,80001548 <memset+0x12>
  }
  return dst;
}
    80001552:	6422                	ld	s0,8(sp)
    80001554:	0141                	addi	sp,sp,16
    80001556:	8082                	ret

0000000080001558 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80001558:	1141                	addi	sp,sp,-16
    8000155a:	e422                	sd	s0,8(sp)
    8000155c:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    8000155e:	ca05                	beqz	a2,8000158e <memcmp+0x36>
    80001560:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80001564:	1682                	slli	a3,a3,0x20
    80001566:	9281                	srli	a3,a3,0x20
    80001568:	0685                	addi	a3,a3,1
    8000156a:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    8000156c:	00054783          	lbu	a5,0(a0)
    80001570:	0005c703          	lbu	a4,0(a1)
    80001574:	00e79863          	bne	a5,a4,80001584 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80001578:	0505                	addi	a0,a0,1
    8000157a:	0585                	addi	a1,a1,1
  while(n-- > 0){
    8000157c:	fed518e3          	bne	a0,a3,8000156c <memcmp+0x14>
  }

  return 0;
    80001580:	4501                	li	a0,0
    80001582:	a019                	j	80001588 <memcmp+0x30>
      return *s1 - *s2;
    80001584:	40e7853b          	subw	a0,a5,a4
}
    80001588:	6422                	ld	s0,8(sp)
    8000158a:	0141                	addi	sp,sp,16
    8000158c:	8082                	ret
  return 0;
    8000158e:	4501                	li	a0,0
    80001590:	bfe5                	j	80001588 <memcmp+0x30>

0000000080001592 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80001592:	1141                	addi	sp,sp,-16
    80001594:	e422                	sd	s0,8(sp)
    80001596:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80001598:	c205                	beqz	a2,800015b8 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    8000159a:	02a5e263          	bltu	a1,a0,800015be <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    8000159e:	1602                	slli	a2,a2,0x20
    800015a0:	9201                	srli	a2,a2,0x20
    800015a2:	00c587b3          	add	a5,a1,a2
{
    800015a6:	872a                	mv	a4,a0
      *d++ = *s++;
    800015a8:	0585                	addi	a1,a1,1
    800015aa:	0705                	addi	a4,a4,1
    800015ac:	fff5c683          	lbu	a3,-1(a1)
    800015b0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    800015b4:	fef59ae3          	bne	a1,a5,800015a8 <memmove+0x16>

  return dst;
}
    800015b8:	6422                	ld	s0,8(sp)
    800015ba:	0141                	addi	sp,sp,16
    800015bc:	8082                	ret
  if(s < d && s + n > d){
    800015be:	02061693          	slli	a3,a2,0x20
    800015c2:	9281                	srli	a3,a3,0x20
    800015c4:	00d58733          	add	a4,a1,a3
    800015c8:	fce57be3          	bgeu	a0,a4,8000159e <memmove+0xc>
    d += n;
    800015cc:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    800015ce:	fff6079b          	addiw	a5,a2,-1
    800015d2:	1782                	slli	a5,a5,0x20
    800015d4:	9381                	srli	a5,a5,0x20
    800015d6:	fff7c793          	not	a5,a5
    800015da:	97ba                	add	a5,a5,a4
      *--d = *--s;
    800015dc:	177d                	addi	a4,a4,-1
    800015de:	16fd                	addi	a3,a3,-1
    800015e0:	00074603          	lbu	a2,0(a4)
    800015e4:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    800015e8:	fee79ae3          	bne	a5,a4,800015dc <memmove+0x4a>
    800015ec:	b7f1                	j	800015b8 <memmove+0x26>

00000000800015ee <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    800015ee:	1141                	addi	sp,sp,-16
    800015f0:	e406                	sd	ra,8(sp)
    800015f2:	e022                	sd	s0,0(sp)
    800015f4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    800015f6:	f9dff0ef          	jal	ra,80001592 <memmove>
}
    800015fa:	60a2                	ld	ra,8(sp)
    800015fc:	6402                	ld	s0,0(sp)
    800015fe:	0141                	addi	sp,sp,16
    80001600:	8082                	ret

0000000080001602 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80001602:	1141                	addi	sp,sp,-16
    80001604:	e422                	sd	s0,8(sp)
    80001606:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80001608:	ce11                	beqz	a2,80001624 <strncmp+0x22>
    8000160a:	00054783          	lbu	a5,0(a0)
    8000160e:	cf89                	beqz	a5,80001628 <strncmp+0x26>
    80001610:	0005c703          	lbu	a4,0(a1)
    80001614:	00f71a63          	bne	a4,a5,80001628 <strncmp+0x26>
    n--, p++, q++;
    80001618:	367d                	addiw	a2,a2,-1
    8000161a:	0505                	addi	a0,a0,1
    8000161c:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    8000161e:	f675                	bnez	a2,8000160a <strncmp+0x8>
  if(n == 0)
    return 0;
    80001620:	4501                	li	a0,0
    80001622:	a809                	j	80001634 <strncmp+0x32>
    80001624:	4501                	li	a0,0
    80001626:	a039                	j	80001634 <strncmp+0x32>
  if(n == 0)
    80001628:	ca09                	beqz	a2,8000163a <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    8000162a:	00054503          	lbu	a0,0(a0)
    8000162e:	0005c783          	lbu	a5,0(a1)
    80001632:	9d1d                	subw	a0,a0,a5
}
    80001634:	6422                	ld	s0,8(sp)
    80001636:	0141                	addi	sp,sp,16
    80001638:	8082                	ret
    return 0;
    8000163a:	4501                	li	a0,0
    8000163c:	bfe5                	j	80001634 <strncmp+0x32>

000000008000163e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    8000163e:	1141                	addi	sp,sp,-16
    80001640:	e422                	sd	s0,8(sp)
    80001642:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80001644:	872a                	mv	a4,a0
    80001646:	8832                	mv	a6,a2
    80001648:	367d                	addiw	a2,a2,-1
    8000164a:	01005963          	blez	a6,8000165c <strncpy+0x1e>
    8000164e:	0705                	addi	a4,a4,1
    80001650:	0005c783          	lbu	a5,0(a1)
    80001654:	fef70fa3          	sb	a5,-1(a4)
    80001658:	0585                	addi	a1,a1,1
    8000165a:	f7f5                	bnez	a5,80001646 <strncpy+0x8>
    ;
  while(n-- > 0)
    8000165c:	86ba                	mv	a3,a4
    8000165e:	00c05c63          	blez	a2,80001676 <strncpy+0x38>
    *s++ = 0;
    80001662:	0685                	addi	a3,a3,1
    80001664:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80001668:	40d707bb          	subw	a5,a4,a3
    8000166c:	37fd                	addiw	a5,a5,-1
    8000166e:	010787bb          	addw	a5,a5,a6
    80001672:	fef048e3          	bgtz	a5,80001662 <strncpy+0x24>
  return os;
}
    80001676:	6422                	ld	s0,8(sp)
    80001678:	0141                	addi	sp,sp,16
    8000167a:	8082                	ret

000000008000167c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    8000167c:	1141                	addi	sp,sp,-16
    8000167e:	e422                	sd	s0,8(sp)
    80001680:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80001682:	02c05363          	blez	a2,800016a8 <safestrcpy+0x2c>
    80001686:	fff6069b          	addiw	a3,a2,-1
    8000168a:	1682                	slli	a3,a3,0x20
    8000168c:	9281                	srli	a3,a3,0x20
    8000168e:	96ae                	add	a3,a3,a1
    80001690:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80001692:	00d58963          	beq	a1,a3,800016a4 <safestrcpy+0x28>
    80001696:	0585                	addi	a1,a1,1
    80001698:	0785                	addi	a5,a5,1
    8000169a:	fff5c703          	lbu	a4,-1(a1)
    8000169e:	fee78fa3          	sb	a4,-1(a5)
    800016a2:	fb65                	bnez	a4,80001692 <safestrcpy+0x16>
    ;
  *s = 0;
    800016a4:	00078023          	sb	zero,0(a5)
  return os;
}
    800016a8:	6422                	ld	s0,8(sp)
    800016aa:	0141                	addi	sp,sp,16
    800016ac:	8082                	ret

00000000800016ae <strlen>:

int
strlen(const char *s)
{
    800016ae:	1141                	addi	sp,sp,-16
    800016b0:	e422                	sd	s0,8(sp)
    800016b2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    800016b4:	00054783          	lbu	a5,0(a0)
    800016b8:	cf91                	beqz	a5,800016d4 <strlen+0x26>
    800016ba:	0505                	addi	a0,a0,1
    800016bc:	87aa                	mv	a5,a0
    800016be:	4685                	li	a3,1
    800016c0:	9e89                	subw	a3,a3,a0
    800016c2:	00f6853b          	addw	a0,a3,a5
    800016c6:	0785                	addi	a5,a5,1
    800016c8:	fff7c703          	lbu	a4,-1(a5)
    800016cc:	fb7d                	bnez	a4,800016c2 <strlen+0x14>
    ;
  return n;
}
    800016ce:	6422                	ld	s0,8(sp)
    800016d0:	0141                	addi	sp,sp,16
    800016d2:	8082                	ret
  for(n = 0; s[n]; n++)
    800016d4:	4501                	li	a0,0
    800016d6:	bfe5                	j	800016ce <strlen+0x20>

00000000800016d8 <swtch>:
    800016d8:	00153023          	sd	ra,0(a0)
    800016dc:	00253423          	sd	sp,8(a0)
    800016e0:	e900                	sd	s0,16(a0)
    800016e2:	ed04                	sd	s1,24(a0)
    800016e4:	03253023          	sd	s2,32(a0)
    800016e8:	03353423          	sd	s3,40(a0)
    800016ec:	03453823          	sd	s4,48(a0)
    800016f0:	03553c23          	sd	s5,56(a0)
    800016f4:	05653023          	sd	s6,64(a0)
    800016f8:	05753423          	sd	s7,72(a0)
    800016fc:	05853823          	sd	s8,80(a0)
    80001700:	05953c23          	sd	s9,88(a0)
    80001704:	07a53023          	sd	s10,96(a0)
    80001708:	07b53423          	sd	s11,104(a0)
    8000170c:	0005b083          	ld	ra,0(a1)
    80001710:	0085b103          	ld	sp,8(a1)
    80001714:	6980                	ld	s0,16(a1)
    80001716:	6d84                	ld	s1,24(a1)
    80001718:	0205b903          	ld	s2,32(a1)
    8000171c:	0285b983          	ld	s3,40(a1)
    80001720:	0305ba03          	ld	s4,48(a1)
    80001724:	0385ba83          	ld	s5,56(a1)
    80001728:	0405bb03          	ld	s6,64(a1)
    8000172c:	0485bb83          	ld	s7,72(a1)
    80001730:	0505bc03          	ld	s8,80(a1)
    80001734:	0585bc83          	ld	s9,88(a1)
    80001738:	0605bd03          	ld	s10,96(a1)
    8000173c:	0685bd83          	ld	s11,104(a1)
    80001740:	8082                	ret

0000000080001742 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001742:	1101                	addi	sp,sp,-32
    80001744:	ec06                	sd	ra,24(sp)
    80001746:	e822                	sd	s0,16(sp)
    80001748:	e426                	sd	s1,8(sp)
    8000174a:	1000                	addi	s0,sp,32
    8000174c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000174e:	8e8ff0ef          	jal	ra,80000836 <myproc>
  switch (n) {
    80001752:	4795                	li	a5,5
    80001754:	0497e163          	bltu	a5,s1,80001796 <argraw+0x54>
    80001758:	048a                	slli	s1,s1,0x2
    8000175a:	00005717          	auipc	a4,0x5
    8000175e:	c5670713          	addi	a4,a4,-938 # 800063b0 <digits+0x320>
    80001762:	94ba                	add	s1,s1,a4
    80001764:	409c                	lw	a5,0(s1)
    80001766:	97ba                	add	a5,a5,a4
    80001768:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000176a:	6d3c                	ld	a5,88(a0)
    8000176c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000176e:	60e2                	ld	ra,24(sp)
    80001770:	6442                	ld	s0,16(sp)
    80001772:	64a2                	ld	s1,8(sp)
    80001774:	6105                	addi	sp,sp,32
    80001776:	8082                	ret
    return p->trapframe->a1;
    80001778:	6d3c                	ld	a5,88(a0)
    8000177a:	7fa8                	ld	a0,120(a5)
    8000177c:	bfcd                	j	8000176e <argraw+0x2c>
    return p->trapframe->a2;
    8000177e:	6d3c                	ld	a5,88(a0)
    80001780:	63c8                	ld	a0,128(a5)
    80001782:	b7f5                	j	8000176e <argraw+0x2c>
    return p->trapframe->a3;
    80001784:	6d3c                	ld	a5,88(a0)
    80001786:	67c8                	ld	a0,136(a5)
    80001788:	b7dd                	j	8000176e <argraw+0x2c>
    return p->trapframe->a4;
    8000178a:	6d3c                	ld	a5,88(a0)
    8000178c:	6bc8                	ld	a0,144(a5)
    8000178e:	b7c5                	j	8000176e <argraw+0x2c>
    return p->trapframe->a5;
    80001790:	6d3c                	ld	a5,88(a0)
    80001792:	6fc8                	ld	a0,152(a5)
    80001794:	bfe9                	j	8000176e <argraw+0x2c>
  panic("argraw");
    80001796:	00005517          	auipc	a0,0x5
    8000179a:	bf250513          	addi	a0,a0,-1038 # 80006388 <digits+0x2f8>
    8000179e:	ed3fe0ef          	jal	ra,80000670 <panic>

00000000800017a2 <fetchaddr>:
{
    800017a2:	1101                	addi	sp,sp,-32
    800017a4:	ec06                	sd	ra,24(sp)
    800017a6:	e822                	sd	s0,16(sp)
    800017a8:	e426                	sd	s1,8(sp)
    800017aa:	e04a                	sd	s2,0(sp)
    800017ac:	1000                	addi	s0,sp,32
    800017ae:	84aa                	mv	s1,a0
    800017b0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800017b2:	884ff0ef          	jal	ra,80000836 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800017b6:	653c                	ld	a5,72(a0)
    800017b8:	02f4f663          	bgeu	s1,a5,800017e4 <fetchaddr+0x42>
    800017bc:	00848713          	addi	a4,s1,8
    800017c0:	02e7e463          	bltu	a5,a4,800017e8 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800017c4:	46a1                	li	a3,8
    800017c6:	8626                	mv	a2,s1
    800017c8:	85ca                	mv	a1,s2
    800017ca:	6928                	ld	a0,80(a0)
    800017cc:	16e010ef          	jal	ra,8000293a <copyin>
    800017d0:	00a03533          	snez	a0,a0
    800017d4:	40a00533          	neg	a0,a0
}
    800017d8:	60e2                	ld	ra,24(sp)
    800017da:	6442                	ld	s0,16(sp)
    800017dc:	64a2                	ld	s1,8(sp)
    800017de:	6902                	ld	s2,0(sp)
    800017e0:	6105                	addi	sp,sp,32
    800017e2:	8082                	ret
    return -1;
    800017e4:	557d                	li	a0,-1
    800017e6:	bfcd                	j	800017d8 <fetchaddr+0x36>
    800017e8:	557d                	li	a0,-1
    800017ea:	b7fd                	j	800017d8 <fetchaddr+0x36>

00000000800017ec <fetchstr>:
{
    800017ec:	7179                	addi	sp,sp,-48
    800017ee:	f406                	sd	ra,40(sp)
    800017f0:	f022                	sd	s0,32(sp)
    800017f2:	ec26                	sd	s1,24(sp)
    800017f4:	e84a                	sd	s2,16(sp)
    800017f6:	e44e                	sd	s3,8(sp)
    800017f8:	1800                	addi	s0,sp,48
    800017fa:	892a                	mv	s2,a0
    800017fc:	84ae                	mv	s1,a1
    800017fe:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001800:	836ff0ef          	jal	ra,80000836 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80001804:	86ce                	mv	a3,s3
    80001806:	864a                	mv	a2,s2
    80001808:	85a6                	mv	a1,s1
    8000180a:	6928                	ld	a0,80(a0)
    8000180c:	1b4010ef          	jal	ra,800029c0 <copyinstr>
    80001810:	00054c63          	bltz	a0,80001828 <fetchstr+0x3c>
  return strlen(buf);
    80001814:	8526                	mv	a0,s1
    80001816:	e99ff0ef          	jal	ra,800016ae <strlen>
}
    8000181a:	70a2                	ld	ra,40(sp)
    8000181c:	7402                	ld	s0,32(sp)
    8000181e:	64e2                	ld	s1,24(sp)
    80001820:	6942                	ld	s2,16(sp)
    80001822:	69a2                	ld	s3,8(sp)
    80001824:	6145                	addi	sp,sp,48
    80001826:	8082                	ret
    return -1;
    80001828:	557d                	li	a0,-1
    8000182a:	bfc5                	j	8000181a <fetchstr+0x2e>

000000008000182c <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    8000182c:	1101                	addi	sp,sp,-32
    8000182e:	ec06                	sd	ra,24(sp)
    80001830:	e822                	sd	s0,16(sp)
    80001832:	e426                	sd	s1,8(sp)
    80001834:	1000                	addi	s0,sp,32
    80001836:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001838:	f0bff0ef          	jal	ra,80001742 <argraw>
    8000183c:	c088                	sw	a0,0(s1)
}
    8000183e:	60e2                	ld	ra,24(sp)
    80001840:	6442                	ld	s0,16(sp)
    80001842:	64a2                	ld	s1,8(sp)
    80001844:	6105                	addi	sp,sp,32
    80001846:	8082                	ret

0000000080001848 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80001848:	1101                	addi	sp,sp,-32
    8000184a:	ec06                	sd	ra,24(sp)
    8000184c:	e822                	sd	s0,16(sp)
    8000184e:	e426                	sd	s1,8(sp)
    80001850:	1000                	addi	s0,sp,32
    80001852:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001854:	eefff0ef          	jal	ra,80001742 <argraw>
    80001858:	e088                	sd	a0,0(s1)
}
    8000185a:	60e2                	ld	ra,24(sp)
    8000185c:	6442                	ld	s0,16(sp)
    8000185e:	64a2                	ld	s1,8(sp)
    80001860:	6105                	addi	sp,sp,32
    80001862:	8082                	ret

0000000080001864 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80001864:	7179                	addi	sp,sp,-48
    80001866:	f406                	sd	ra,40(sp)
    80001868:	f022                	sd	s0,32(sp)
    8000186a:	ec26                	sd	s1,24(sp)
    8000186c:	e84a                	sd	s2,16(sp)
    8000186e:	1800                	addi	s0,sp,48
    80001870:	84ae                	mv	s1,a1
    80001872:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80001874:	fd840593          	addi	a1,s0,-40
    80001878:	fd1ff0ef          	jal	ra,80001848 <argaddr>
  return fetchstr(addr, buf, max);
    8000187c:	864a                	mv	a2,s2
    8000187e:	85a6                	mv	a1,s1
    80001880:	fd843503          	ld	a0,-40(s0)
    80001884:	f69ff0ef          	jal	ra,800017ec <fetchstr>
}
    80001888:	70a2                	ld	ra,40(sp)
    8000188a:	7402                	ld	s0,32(sp)
    8000188c:	64e2                	ld	s1,24(sp)
    8000188e:	6942                	ld	s2,16(sp)
    80001890:	6145                	addi	sp,sp,48
    80001892:	8082                	ret

0000000080001894 <syscall>:
// [SYS_close]   sys_close,
};

void
syscall(void)
{
    80001894:	1101                	addi	sp,sp,-32
    80001896:	ec06                	sd	ra,24(sp)
    80001898:	e822                	sd	s0,16(sp)
    8000189a:	e426                	sd	s1,8(sp)
    8000189c:	e04a                	sd	s2,0(sp)
    8000189e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800018a0:	f97fe0ef          	jal	ra,80000836 <myproc>
    800018a4:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800018a6:	05853903          	ld	s2,88(a0)
    800018aa:	0a893783          	ld	a5,168(s2)
    800018ae:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800018b2:	37fd                	addiw	a5,a5,-1
    800018b4:	473d                	li	a4,15
    800018b6:	00f76f63          	bltu	a4,a5,800018d4 <syscall+0x40>
    800018ba:	00369713          	slli	a4,a3,0x3
    800018be:	00005797          	auipc	a5,0x5
    800018c2:	b0a78793          	addi	a5,a5,-1270 # 800063c8 <syscalls>
    800018c6:	97ba                	add	a5,a5,a4
    800018c8:	639c                	ld	a5,0(a5)
    800018ca:	c789                	beqz	a5,800018d4 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800018cc:	9782                	jalr	a5
    800018ce:	06a93823          	sd	a0,112(s2)
    800018d2:	a829                	j	800018ec <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800018d4:	0d848613          	addi	a2,s1,216
    800018d8:	588c                	lw	a1,48(s1)
    800018da:	00005517          	auipc	a0,0x5
    800018de:	ab650513          	addi	a0,a0,-1354 # 80006390 <digits+0x300>
    800018e2:	adbfe0ef          	jal	ra,800003bc <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800018e6:	6cbc                	ld	a5,88(s1)
    800018e8:	577d                	li	a4,-1
    800018ea:	fbb8                	sd	a4,112(a5)
  }
    800018ec:	60e2                	ld	ra,24(sp)
    800018ee:	6442                	ld	s0,16(sp)
    800018f0:	64a2                	ld	s1,8(sp)
    800018f2:	6902                	ld	s2,0(sp)
    800018f4:	6105                	addi	sp,sp,32
    800018f6:	8082                	ret

00000000800018f8 <blocktest>:
//   return fileread(f, p, n);
// }

// 老师提供测试程序
int blocktest()
{
    800018f8:	1101                	addi	sp,sp,-32
    800018fa:	ec06                	sd	ra,24(sp)
    800018fc:	e822                	sd	s0,16(sp)
    800018fe:	e426                	sd	s1,8(sp)
    80001900:	e04a                	sd	s2,0(sp)
    80001902:	1000                	addi	s0,sp,32
  struct buf *b;
  // read superblock
  b = bread(ROOTDEV, 1);
    80001904:	4585                	li	a1,1
    80001906:	4505                	li	a0,1
    80001908:	246010ef          	jal	ra,80002b4e <bread>
    8000190c:	84aa                	mv	s1,a0
  struct superblock *sb = (struct superblock *)(b->data);
  printf("Super Block info:\n");
    8000190e:	00005517          	auipc	a0,0x5
    80001912:	b4250513          	addi	a0,a0,-1214 # 80006450 <syscalls+0x88>
    80001916:	aa7fe0ef          	jal	ra,800003bc <printf>
  printf("\tmagic: %x\n", sb->magic);
    8000191a:	4cac                	lw	a1,88(s1)
    8000191c:	00005517          	auipc	a0,0x5
    80001920:	b4c50513          	addi	a0,a0,-1204 # 80006468 <syscalls+0xa0>
    80001924:	a99fe0ef          	jal	ra,800003bc <printf>
  printf("\tsize: %d\n", sb->size);
    80001928:	4cec                	lw	a1,92(s1)
    8000192a:	00005517          	auipc	a0,0x5
    8000192e:	b4e50513          	addi	a0,a0,-1202 # 80006478 <syscalls+0xb0>
    80001932:	a8bfe0ef          	jal	ra,800003bc <printf>
  printf("\tnblocks: %d\n", sb->nblocks);
    80001936:	50ac                	lw	a1,96(s1)
    80001938:	00005517          	auipc	a0,0x5
    8000193c:	b5050513          	addi	a0,a0,-1200 # 80006488 <syscalls+0xc0>
    80001940:	a7dfe0ef          	jal	ra,800003bc <printf>
  printf("\tninodes: %d\n", sb->ninodes);
    80001944:	50ec                	lw	a1,100(s1)
    80001946:	00005517          	auipc	a0,0x5
    8000194a:	b5250513          	addi	a0,a0,-1198 # 80006498 <syscalls+0xd0>
    8000194e:	a6ffe0ef          	jal	ra,800003bc <printf>
  printf("\tnlog: %d\n", sb->nlog);
    80001952:	54ac                	lw	a1,104(s1)
    80001954:	00005517          	auipc	a0,0x5
    80001958:	b5450513          	addi	a0,a0,-1196 # 800064a8 <syscalls+0xe0>
    8000195c:	a61fe0ef          	jal	ra,800003bc <printf>
  printf("\tlogstart: %d\n", sb->logstart);
    80001960:	54ec                	lw	a1,108(s1)
    80001962:	00005517          	auipc	a0,0x5
    80001966:	b5650513          	addi	a0,a0,-1194 # 800064b8 <syscalls+0xf0>
    8000196a:	a53fe0ef          	jal	ra,800003bc <printf>
  printf("\tinodestart: %d\n", sb->inodestart);
    8000196e:	58ac                	lw	a1,112(s1)
    80001970:	00005517          	auipc	a0,0x5
    80001974:	b5850513          	addi	a0,a0,-1192 # 800064c8 <syscalls+0x100>
    80001978:	a45fe0ef          	jal	ra,800003bc <printf>
  printf("\tbmapstart: %d\n\n", sb->bmapstart);
    8000197c:	58ec                	lw	a1,116(s1)
    8000197e:	00005517          	auipc	a0,0x5
    80001982:	b6250513          	addi	a0,a0,-1182 # 800064e0 <syscalls+0x118>
    80001986:	a37fe0ef          	jal	ra,800003bc <printf>
  brelse(b);
    8000198a:	8526                	mv	a0,s1
    8000198c:	2ca010ef          	jal	ra,80002c56 <brelse>

  // read first file data block
  b = bread(ROOTDEV, 47);
    80001990:	02f00593          	li	a1,47
    80001994:	4505                	li	a0,1
    80001996:	1b8010ef          	jal	ra,80002b4e <bread>
    8000199a:	892a                	mv	s2,a0
  char *c = (char *)(b->data);
  c[BSIZE - 1] = '\0';
    8000199c:	44050ba3          	sb	zero,1111(a0)
  char *c = (char *)(b->data);
    800019a0:	05850493          	addi	s1,a0,88
  printf("README (1KB):\n%s\n\n", c);
    800019a4:	85a6                	mv	a1,s1
    800019a6:	00005517          	auipc	a0,0x5
    800019aa:	b5250513          	addi	a0,a0,-1198 # 800064f8 <syscalls+0x130>
    800019ae:	a0ffe0ef          	jal	ra,800003bc <printf>
  // modify first file data block
  int i;
  for (i = 0; i < BSIZE - 1; i++)
    800019b2:	85a6                	mv	a1,s1
    800019b4:	4781                	li	a5,0
  {
    if (c[i] == '\n' && c[i + 1] == '\n')
    800019b6:	46a9                	li	a3,10
  for (i = 0; i < BSIZE - 1; i++)
    800019b8:	3ff00613          	li	a2,1023
    800019bc:	a029                	j	800019c6 <blocktest+0xce>
    800019be:	2785                	addiw	a5,a5,1
    800019c0:	0585                	addi	a1,a1,1
    800019c2:	04c78063          	beq	a5,a2,80001a02 <blocktest+0x10a>
    if (c[i] == '\n' && c[i + 1] == '\n')
    800019c6:	0005c703          	lbu	a4,0(a1)
    800019ca:	fed71ae3          	bne	a4,a3,800019be <blocktest+0xc6>
    800019ce:	0015c703          	lbu	a4,1(a1)
    800019d2:	fed716e3          	bne	a4,a3,800019be <blocktest+0xc6>
      break;
  }
  if (i < BSIZE - 1)
    800019d6:	3fe00713          	li	a4,1022
    800019da:	02f74463          	blt	a4,a5,80001a02 <blocktest+0x10a>
    800019de:	05878713          	addi	a4,a5,88
    800019e2:	974a                	add	a4,a4,s2
    800019e4:	05990693          	addi	a3,s2,89
    800019e8:	96be                	add	a3,a3,a5
    800019ea:	3ff00613          	li	a2,1023
    800019ee:	40f607bb          	subw	a5,a2,a5
    800019f2:	1782                	slli	a5,a5,0x20
    800019f4:	9381                	srli	a5,a5,0x20
    800019f6:	97b6                	add	a5,a5,a3
  {
    for (; i < BSIZE; i++)
      c[i] = 0;
    800019f8:	00070023          	sb	zero,0(a4)
    for (; i < BSIZE; i++)
    800019fc:	0705                	addi	a4,a4,1
    800019fe:	fef71de3          	bne	a4,a5,800019f8 <blocktest+0x100>
  }
  bwrite(b);
    80001a02:	854a                	mv	a0,s2
    80001a04:	220010ef          	jal	ra,80002c24 <bwrite>
  brelse(b);
    80001a08:	854a                	mv	a0,s2
    80001a0a:	24c010ef          	jal	ra,80002c56 <brelse>

  // confirm first file data block
  b = bread(ROOTDEV, 47);
    80001a0e:	02f00593          	li	a1,47
    80001a12:	4505                	li	a0,1
    80001a14:	13a010ef          	jal	ra,80002b4e <bread>
    80001a18:	84aa                	mv	s1,a0
  c = (char *)(b->data);
  c[BSIZE - 1] = '\0';
    80001a1a:	44050ba3          	sb	zero,1111(a0)
  printf("README (modified):\n%s\n\n", c);
    80001a1e:	05850593          	addi	a1,a0,88
    80001a22:	00005517          	auipc	a0,0x5
    80001a26:	aee50513          	addi	a0,a0,-1298 # 80006510 <syscalls+0x148>
    80001a2a:	993fe0ef          	jal	ra,800003bc <printf>
  brelse(b);
    80001a2e:	8526                	mv	a0,s1
    80001a30:	226010ef          	jal	ra,80002c56 <brelse>
  return 0;
}
    80001a34:	4501                	li	a0,0
    80001a36:	60e2                	ld	ra,24(sp)
    80001a38:	6442                	ld	s0,16(sp)
    80001a3a:	64a2                	ld	s1,8(sp)
    80001a3c:	6902                	ld	s2,0(sp)
    80001a3e:	6105                	addi	sp,sp,32
    80001a40:	8082                	ret

0000000080001a42 <sys_write>:


uint64
sys_write(void)
{
    80001a42:	7179                	addi	sp,sp,-48
    80001a44:	f406                	sd	ra,40(sp)
    80001a46:	f022                	sd	s0,32(sp)
    80001a48:	1800                	addi	s0,sp,48

//   return filewrite(f, p, n);
  int n;
  uint64 p;
  int fd_test;
  argint(0,&fd_test);
    80001a4a:	fdc40593          	addi	a1,s0,-36
    80001a4e:	4501                	li	a0,0
    80001a50:	dddff0ef          	jal	ra,8000182c <argint>
  argaddr(1, &p);
    80001a54:	fe040593          	addi	a1,s0,-32
    80001a58:	4505                	li	a0,1
    80001a5a:	defff0ef          	jal	ra,80001848 <argaddr>
  argint(2, &n);
    80001a5e:	fec40593          	addi	a1,s0,-20
    80001a62:	4509                	li	a0,2
    80001a64:	dc9ff0ef          	jal	ra,8000182c <argint>

  // if(argfd(0, 0, &f) < 0)
  //   return -1;
  if(fd_test < 3)
    80001a68:	fdc42783          	lw	a5,-36(s0)
    80001a6c:	4709                	li	a4,2
    80001a6e:	00f75a63          	bge	a4,a5,80001a82 <sys_write+0x40>
    return consolewrite(1,p,n);
  else if(fd_test == 3)
    80001a72:	470d                	li	a4,3
    return blocktest();
  return 0;
    80001a74:	4501                	li	a0,0
  else if(fd_test == 3)
    80001a76:	00e78e63          	beq	a5,a4,80001a92 <sys_write+0x50>
}
    80001a7a:	70a2                	ld	ra,40(sp)
    80001a7c:	7402                	ld	s0,32(sp)
    80001a7e:	6145                	addi	sp,sp,48
    80001a80:	8082                	ret
    return consolewrite(1,p,n);
    80001a82:	fec42603          	lw	a2,-20(s0)
    80001a86:	fe043583          	ld	a1,-32(s0)
    80001a8a:	4505                	li	a0,1
    80001a8c:	7e1000ef          	jal	ra,80002a6c <consolewrite>
    80001a90:	b7ed                	j	80001a7a <sys_write+0x38>
    return blocktest();
    80001a92:	e67ff0ef          	jal	ra,800018f8 <blocktest>
    80001a96:	b7d5                	j	80001a7a <sys_write+0x38>

0000000080001a98 <sys_exec>:
//   return 0;
// }

uint64
sys_exec(void)
{
    80001a98:	7145                	addi	sp,sp,-464
    80001a9a:	e786                	sd	ra,456(sp)
    80001a9c:	e3a2                	sd	s0,448(sp)
    80001a9e:	ff26                	sd	s1,440(sp)
    80001aa0:	fb4a                	sd	s2,432(sp)
    80001aa2:	f74e                	sd	s3,424(sp)
    80001aa4:	f352                	sd	s4,416(sp)
    80001aa6:	ef56                	sd	s5,408(sp)
    80001aa8:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80001aaa:	e3840593          	addi	a1,s0,-456
    80001aae:	4505                	li	a0,1
    80001ab0:	d99ff0ef          	jal	ra,80001848 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80001ab4:	08000613          	li	a2,128
    80001ab8:	f4040593          	addi	a1,s0,-192
    80001abc:	4501                	li	a0,0
    80001abe:	da7ff0ef          	jal	ra,80001864 <argstr>
    80001ac2:	87aa                	mv	a5,a0
    return -1;
    80001ac4:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80001ac6:	0a07c563          	bltz	a5,80001b70 <sys_exec+0xd8>
  }
  memset(argv, 0, sizeof(argv));
    80001aca:	10000613          	li	a2,256
    80001ace:	4581                	li	a1,0
    80001ad0:	e4040513          	addi	a0,s0,-448
    80001ad4:	a63ff0ef          	jal	ra,80001536 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80001ad8:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80001adc:	89a6                	mv	s3,s1
    80001ade:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80001ae0:	02000a13          	li	s4,32
    80001ae4:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80001ae8:	00391513          	slli	a0,s2,0x3
    80001aec:	e3040593          	addi	a1,s0,-464
    80001af0:	e3843783          	ld	a5,-456(s0)
    80001af4:	953e                	add	a0,a0,a5
    80001af6:	cadff0ef          	jal	ra,800017a2 <fetchaddr>
    80001afa:	02054663          	bltz	a0,80001b26 <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    80001afe:	e3043783          	ld	a5,-464(s0)
    80001b02:	cf8d                	beqz	a5,80001b3c <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80001b04:	dfafe0ef          	jal	ra,800000fe <kalloc>
    80001b08:	85aa                	mv	a1,a0
    80001b0a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80001b0e:	cd01                	beqz	a0,80001b26 <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80001b10:	6605                	lui	a2,0x1
    80001b12:	e3043503          	ld	a0,-464(s0)
    80001b16:	cd7ff0ef          	jal	ra,800017ec <fetchstr>
    80001b1a:	00054663          	bltz	a0,80001b26 <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    80001b1e:	0905                	addi	s2,s2,1
    80001b20:	09a1                	addi	s3,s3,8
    80001b22:	fd4911e3          	bne	s2,s4,80001ae4 <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80001b26:	f4040913          	addi	s2,s0,-192
    80001b2a:	6088                	ld	a0,0(s1)
    80001b2c:	c129                	beqz	a0,80001b6e <sys_exec+0xd6>
    kfree(argv[i]);
    80001b2e:	ceefe0ef          	jal	ra,8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80001b32:	04a1                	addi	s1,s1,8
    80001b34:	ff249be3          	bne	s1,s2,80001b2a <sys_exec+0x92>
  return -1;
    80001b38:	557d                	li	a0,-1
    80001b3a:	a81d                	j	80001b70 <sys_exec+0xd8>
      argv[i] = 0;
    80001b3c:	0a8e                	slli	s5,s5,0x3
    80001b3e:	fc0a8793          	addi	a5,s5,-64
    80001b42:	00878ab3          	add	s5,a5,s0
    80001b46:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80001b4a:	e4040593          	addi	a1,s0,-448
    80001b4e:	f4040513          	addi	a0,s0,-192
    80001b52:	7f8010ef          	jal	ra,8000334a <exec>
    80001b56:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80001b58:	f4040993          	addi	s3,s0,-192
    80001b5c:	6088                	ld	a0,0(s1)
    80001b5e:	c511                	beqz	a0,80001b6a <sys_exec+0xd2>
    kfree(argv[i]);
    80001b60:	cbcfe0ef          	jal	ra,8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80001b64:	04a1                	addi	s1,s1,8
    80001b66:	ff349be3          	bne	s1,s3,80001b5c <sys_exec+0xc4>
  return ret;
    80001b6a:	854a                	mv	a0,s2
    80001b6c:	a011                	j	80001b70 <sys_exec+0xd8>
  return -1;
    80001b6e:	557d                	li	a0,-1
}
    80001b70:	60be                	ld	ra,456(sp)
    80001b72:	641e                	ld	s0,448(sp)
    80001b74:	74fa                	ld	s1,440(sp)
    80001b76:	795a                	ld	s2,432(sp)
    80001b78:	79ba                	ld	s3,424(sp)
    80001b7a:	7a1a                	ld	s4,416(sp)
    80001b7c:	6afa                	ld	s5,408(sp)
    80001b7e:	6179                	addi	sp,sp,464
    80001b80:	8082                	ret

0000000080001b82 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80001b82:	1101                	addi	sp,sp,-32
    80001b84:	ec06                	sd	ra,24(sp)
    80001b86:	e822                	sd	s0,16(sp)
    80001b88:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80001b8a:	fec40593          	addi	a1,s0,-20
    80001b8e:	4501                	li	a0,0
    80001b90:	c9dff0ef          	jal	ra,8000182c <argint>
  exit(n);
    80001b94:	fec42503          	lw	a0,-20(s0)
    80001b98:	cd6ff0ef          	jal	ra,8000106e <exit>
  return 0;  // not reached
}
    80001b9c:	4501                	li	a0,0
    80001b9e:	60e2                	ld	ra,24(sp)
    80001ba0:	6442                	ld	s0,16(sp)
    80001ba2:	6105                	addi	sp,sp,32
    80001ba4:	8082                	ret

0000000080001ba6 <sys_getpid>:

uint64
sys_getpid(void)
{
    80001ba6:	1141                	addi	sp,sp,-16
    80001ba8:	e406                	sd	ra,8(sp)
    80001baa:	e022                	sd	s0,0(sp)
    80001bac:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80001bae:	c89fe0ef          	jal	ra,80000836 <myproc>
}
    80001bb2:	5908                	lw	a0,48(a0)
    80001bb4:	60a2                	ld	ra,8(sp)
    80001bb6:	6402                	ld	s0,0(sp)
    80001bb8:	0141                	addi	sp,sp,16
    80001bba:	8082                	ret

0000000080001bbc <sys_fork>:

uint64
sys_fork(void)
{
    80001bbc:	1141                	addi	sp,sp,-16
    80001bbe:	e406                	sd	ra,8(sp)
    80001bc0:	e022                	sd	s0,0(sp)
    80001bc2:	0800                	addi	s0,sp,16
  return fork();
    80001bc4:	92cff0ef          	jal	ra,80000cf0 <fork>
}
    80001bc8:	60a2                	ld	ra,8(sp)
    80001bca:	6402                	ld	s0,0(sp)
    80001bcc:	0141                	addi	sp,sp,16
    80001bce:	8082                	ret

0000000080001bd0 <sys_wait>:

uint64
sys_wait(void)
{
    80001bd0:	1101                	addi	sp,sp,-32
    80001bd2:	ec06                	sd	ra,24(sp)
    80001bd4:	e822                	sd	s0,16(sp)
    80001bd6:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80001bd8:	fe840593          	addi	a1,s0,-24
    80001bdc:	4501                	li	a0,0
    80001bde:	c6bff0ef          	jal	ra,80001848 <argaddr>
  return wait(p);
    80001be2:	fe843503          	ld	a0,-24(s0)
    80001be6:	dbaff0ef          	jal	ra,800011a0 <wait>
}
    80001bea:	60e2                	ld	ra,24(sp)
    80001bec:	6442                	ld	s0,16(sp)
    80001bee:	6105                	addi	sp,sp,32
    80001bf0:	8082                	ret

0000000080001bf2 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80001bf2:	7179                	addi	sp,sp,-48
    80001bf4:	f406                	sd	ra,40(sp)
    80001bf6:	f022                	sd	s0,32(sp)
    80001bf8:	ec26                	sd	s1,24(sp)
    80001bfa:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80001bfc:	fdc40593          	addi	a1,s0,-36
    80001c00:	4501                	li	a0,0
    80001c02:	c2bff0ef          	jal	ra,8000182c <argint>
  addr = myproc()->sz;
    80001c06:	c31fe0ef          	jal	ra,80000836 <myproc>
    80001c0a:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80001c0c:	fdc42503          	lw	a0,-36(s0)
    80001c10:	890ff0ef          	jal	ra,80000ca0 <growproc>
    80001c14:	00054863          	bltz	a0,80001c24 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80001c18:	8526                	mv	a0,s1
    80001c1a:	70a2                	ld	ra,40(sp)
    80001c1c:	7402                	ld	s0,32(sp)
    80001c1e:	64e2                	ld	s1,24(sp)
    80001c20:	6145                	addi	sp,sp,48
    80001c22:	8082                	ret
    return -1;
    80001c24:	54fd                	li	s1,-1
    80001c26:	bfcd                	j	80001c18 <sys_sbrk+0x26>

0000000080001c28 <sys_sleep>:

uint64
sys_sleep(void)
{
    80001c28:	7139                	addi	sp,sp,-64
    80001c2a:	fc06                	sd	ra,56(sp)
    80001c2c:	f822                	sd	s0,48(sp)
    80001c2e:	f426                	sd	s1,40(sp)
    80001c30:	f04a                	sd	s2,32(sp)
    80001c32:	ec4e                	sd	s3,24(sp)
    80001c34:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80001c36:	fcc40593          	addi	a1,s0,-52
    80001c3a:	4501                	li	a0,0
    80001c3c:	bf1ff0ef          	jal	ra,8000182c <argint>
  if(n < 0)
    80001c40:	fcc42783          	lw	a5,-52(s0)
    80001c44:	0607c563          	bltz	a5,80001cae <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80001c48:	00012517          	auipc	a0,0x12
    80001c4c:	cf850513          	addi	a0,a0,-776 # 80013940 <tickslock>
    80001c50:	f5eff0ef          	jal	ra,800013ae <acquire>
  ticks0 = ticks;
    80001c54:	00006917          	auipc	s2,0x6
    80001c58:	e5c92903          	lw	s2,-420(s2) # 80007ab0 <ticks>
  while(ticks - ticks0 < n){
    80001c5c:	fcc42783          	lw	a5,-52(s0)
    80001c60:	cb8d                	beqz	a5,80001c92 <sys_sleep+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80001c62:	00012997          	auipc	s3,0x12
    80001c66:	cde98993          	addi	s3,s3,-802 # 80013940 <tickslock>
    80001c6a:	00006497          	auipc	s1,0x6
    80001c6e:	e4648493          	addi	s1,s1,-442 # 80007ab0 <ticks>
    if(killed(myproc())){
    80001c72:	bc5fe0ef          	jal	ra,80000836 <myproc>
    80001c76:	d00ff0ef          	jal	ra,80001176 <killed>
    80001c7a:	ed0d                	bnez	a0,80001cb4 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80001c7c:	85ce                	mv	a1,s3
    80001c7e:	8526                	mv	a0,s1
    80001c80:	ae2ff0ef          	jal	ra,80000f62 <sleep>
  while(ticks - ticks0 < n){
    80001c84:	409c                	lw	a5,0(s1)
    80001c86:	412787bb          	subw	a5,a5,s2
    80001c8a:	fcc42703          	lw	a4,-52(s0)
    80001c8e:	fee7e2e3          	bltu	a5,a4,80001c72 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80001c92:	00012517          	auipc	a0,0x12
    80001c96:	cae50513          	addi	a0,a0,-850 # 80013940 <tickslock>
    80001c9a:	facff0ef          	jal	ra,80001446 <release>
  return 0;
    80001c9e:	4501                	li	a0,0
}
    80001ca0:	70e2                	ld	ra,56(sp)
    80001ca2:	7442                	ld	s0,48(sp)
    80001ca4:	74a2                	ld	s1,40(sp)
    80001ca6:	7902                	ld	s2,32(sp)
    80001ca8:	69e2                	ld	s3,24(sp)
    80001caa:	6121                	addi	sp,sp,64
    80001cac:	8082                	ret
    n = 0;
    80001cae:	fc042623          	sw	zero,-52(s0)
    80001cb2:	bf59                	j	80001c48 <sys_sleep+0x20>
      release(&tickslock);
    80001cb4:	00012517          	auipc	a0,0x12
    80001cb8:	c8c50513          	addi	a0,a0,-884 # 80013940 <tickslock>
    80001cbc:	f8aff0ef          	jal	ra,80001446 <release>
      return -1;
    80001cc0:	557d                	li	a0,-1
    80001cc2:	bff9                	j	80001ca0 <sys_sleep+0x78>

0000000080001cc4 <sys_kill>:

uint64
sys_kill(void)
{
    80001cc4:	1101                	addi	sp,sp,-32
    80001cc6:	ec06                	sd	ra,24(sp)
    80001cc8:	e822                	sd	s0,16(sp)
    80001cca:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80001ccc:	fec40593          	addi	a1,s0,-20
    80001cd0:	4501                	li	a0,0
    80001cd2:	b5bff0ef          	jal	ra,8000182c <argint>
  return kill(pid);
    80001cd6:	fec42503          	lw	a0,-20(s0)
    80001cda:	c12ff0ef          	jal	ra,800010ec <kill>
}
    80001cde:	60e2                	ld	ra,24(sp)
    80001ce0:	6442                	ld	s0,16(sp)
    80001ce2:	6105                	addi	sp,sp,32
    80001ce4:	8082                	ret

0000000080001ce6 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80001ce6:	1101                	addi	sp,sp,-32
    80001ce8:	ec06                	sd	ra,24(sp)
    80001cea:	e822                	sd	s0,16(sp)
    80001cec:	e426                	sd	s1,8(sp)
    80001cee:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80001cf0:	00012517          	auipc	a0,0x12
    80001cf4:	c5050513          	addi	a0,a0,-944 # 80013940 <tickslock>
    80001cf8:	eb6ff0ef          	jal	ra,800013ae <acquire>
  xticks = ticks;
    80001cfc:	00006497          	auipc	s1,0x6
    80001d00:	db44a483          	lw	s1,-588(s1) # 80007ab0 <ticks>
  release(&tickslock);
    80001d04:	00012517          	auipc	a0,0x12
    80001d08:	c3c50513          	addi	a0,a0,-964 # 80013940 <tickslock>
    80001d0c:	f3aff0ef          	jal	ra,80001446 <release>
  return xticks;
}
    80001d10:	02049513          	slli	a0,s1,0x20
    80001d14:	9101                	srli	a0,a0,0x20
    80001d16:	60e2                	ld	ra,24(sp)
    80001d18:	6442                	ld	s0,16(sp)
    80001d1a:	64a2                	ld	s1,8(sp)
    80001d1c:	6105                	addi	sp,sp,32
    80001d1e:	8082                	ret

0000000080001d20 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80001d20:	1141                	addi	sp,sp,-16
    80001d22:	e406                	sd	ra,8(sp)
    80001d24:	e022                	sd	s0,0(sp)
    80001d26:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80001d28:	00005597          	auipc	a1,0x5
    80001d2c:	80058593          	addi	a1,a1,-2048 # 80006528 <syscalls+0x160>
    80001d30:	00012517          	auipc	a0,0x12
    80001d34:	c1050513          	addi	a0,a0,-1008 # 80013940 <tickslock>
    80001d38:	df6ff0ef          	jal	ra,8000132e <initlock>
}
    80001d3c:	60a2                	ld	ra,8(sp)
    80001d3e:	6402                	ld	s0,0(sp)
    80001d40:	0141                	addi	sp,sp,16
    80001d42:	8082                	ret

0000000080001d44 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001d44:	1141                	addi	sp,sp,-16
    80001d46:	e422                	sd	s0,8(sp)
    80001d48:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001d4a:	ffffe797          	auipc	a5,0xffffe
    80001d4e:	40678793          	addi	a5,a5,1030 # 80000150 <kernelvec>
    80001d52:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001d56:	6422                	ld	s0,8(sp)
    80001d58:	0141                	addi	sp,sp,16
    80001d5a:	8082                	ret

0000000080001d5c <usertrapret>:
// 现阶段我swtch之后会到这个地方往下执行
// 这个函数的主要作用就是将当前进程从内核态恢复到用户态
// 在处理完用户态进程的系统调用、中断或异常后被调用
void
usertrapret(void)
{
    80001d5c:	1141                	addi	sp,sp,-16
    80001d5e:	e406                	sd	ra,8(sp)
    80001d60:	e022                	sd	s0,0(sp)
    80001d62:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001d64:	ad3fe0ef          	jal	ra,80000836 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d68:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001d6c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d6e:	10079073          	csrw	sstatus,a5
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  // uservec 是trampoline.S中的一个标签，用于记录从用户态到内核态的入口
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80001d72:	00003697          	auipc	a3,0x3
    80001d76:	28e68693          	addi	a3,a3,654 # 80005000 <_trampoline>
    80001d7a:	00003717          	auipc	a4,0x3
    80001d7e:	28670713          	addi	a4,a4,646 # 80005000 <_trampoline>
    80001d82:	8f15                	sub	a4,a4,a3
    80001d84:	040007b7          	lui	a5,0x4000
    80001d88:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80001d8a:	07b2                	slli	a5,a5,0xc
    80001d8c:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001d8e:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001d92:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001d94:	18002673          	csrr	a2,satp
    80001d98:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001d9a:	6d30                	ld	a2,88(a0)
    80001d9c:	6138                	ld	a4,64(a0)
    80001d9e:	6585                	lui	a1,0x1
    80001da0:	972e                	add	a4,a4,a1
    80001da2:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001da4:	6d38                	ld	a4,88(a0)
    80001da6:	00000617          	auipc	a2,0x0
    80001daa:	12a60613          	addi	a2,a2,298 # 80001ed0 <usertrap>
    80001dae:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001db0:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001db2:	8612                	mv	a2,tp
    80001db4:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001db6:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001dba:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001dbe:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dc2:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001dc6:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001dc8:	6f18                	ld	a4,24(a4)
    80001dca:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80001dce:	6928                	ld	a0,80(a0)
    80001dd0:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline); // 看作一个函数指针
    80001dd2:	00003717          	auipc	a4,0x3
    80001dd6:	2ca70713          	addi	a4,a4,714 # 8000509c <userret>
    80001dda:	8f15                	sub	a4,a4,a3
    80001ddc:	97ba                	add	a5,a5,a4
  // 这个看作在调用 userret()这个函数，用于从内核到用户态的，这个函数就放在trampoline_userret这个位置
  // 后面的satp是参数，应该是这个进程的用户态的页表
  ((void (*)(uint64))trampoline_userret)(satp);  
    80001dde:	577d                	li	a4,-1
    80001de0:	177e                	slli	a4,a4,0x3f
    80001de2:	8d59                	or	a0,a0,a4
    80001de4:	9782                	jalr	a5
}
    80001de6:	60a2                	ld	ra,8(sp)
    80001de8:	6402                	ld	s0,0(sp)
    80001dea:	0141                	addi	sp,sp,16
    80001dec:	8082                	ret

0000000080001dee <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001dee:	1141                	addi	sp,sp,-16
    80001df0:	e406                	sd	ra,8(sp)
    80001df2:	e022                	sd	s0,0(sp)
    80001df4:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80001df6:	a15fe0ef          	jal	ra,8000080a <cpuid>
    80001dfa:	cd11                	beqz	a0,80001e16 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80001dfc:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80001e00:	000f4737          	lui	a4,0xf4
    80001e04:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80001e08:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80001e0a:	14d79073          	csrw	0x14d,a5
}
    80001e0e:	60a2                	ld	ra,8(sp)
    80001e10:	6402                	ld	s0,0(sp)
    80001e12:	0141                	addi	sp,sp,16
    80001e14:	8082                	ret
    acquire(&tickslock);
    80001e16:	00012517          	auipc	a0,0x12
    80001e1a:	b2a50513          	addi	a0,a0,-1238 # 80013940 <tickslock>
    80001e1e:	d90ff0ef          	jal	ra,800013ae <acquire>
    ticks++;
    80001e22:	00006717          	auipc	a4,0x6
    80001e26:	c8e70713          	addi	a4,a4,-882 # 80007ab0 <ticks>
    80001e2a:	431c                	lw	a5,0(a4)
    80001e2c:	2785                	addiw	a5,a5,1
    80001e2e:	c31c                	sw	a5,0(a4)
    if(ticks % 30 == 0){ //每30次时钟中断打印出一个T
    80001e30:	4779                	li	a4,30
    80001e32:	02e7f7bb          	remuw	a5,a5,a4
    80001e36:	cf91                	beqz	a5,80001e52 <clockintr+0x64>
    wakeup(&ticks);
    80001e38:	00006517          	auipc	a0,0x6
    80001e3c:	c7850513          	addi	a0,a0,-904 # 80007ab0 <ticks>
    80001e40:	96eff0ef          	jal	ra,80000fae <wakeup>
    release(&tickslock);
    80001e44:	00012517          	auipc	a0,0x12
    80001e48:	afc50513          	addi	a0,a0,-1284 # 80013940 <tickslock>
    80001e4c:	dfaff0ef          	jal	ra,80001446 <release>
    80001e50:	b775                	j	80001dfc <clockintr+0xe>
        printf("T");
    80001e52:	00004517          	auipc	a0,0x4
    80001e56:	6de50513          	addi	a0,a0,1758 # 80006530 <syscalls+0x168>
    80001e5a:	d62fe0ef          	jal	ra,800003bc <printf>
    80001e5e:	bfe9                	j	80001e38 <clockintr+0x4a>

0000000080001e60 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001e60:	1101                	addi	sp,sp,-32
    80001e62:	ec06                	sd	ra,24(sp)
    80001e64:	e822                	sd	s0,16(sp)
    80001e66:	e426                	sd	s1,8(sp)
    80001e68:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001e6a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80001e6e:	57fd                	li	a5,-1
    80001e70:	17fe                	slli	a5,a5,0x3f
    80001e72:	07a5                	addi	a5,a5,9
    80001e74:	00f70d63          	beq	a4,a5,80001e8e <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80001e78:	57fd                	li	a5,-1
    80001e7a:	17fe                	slli	a5,a5,0x3f
    80001e7c:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80001e7e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80001e80:	04f70463          	beq	a4,a5,80001ec8 <devintr+0x68>
  }
}
    80001e84:	60e2                	ld	ra,24(sp)
    80001e86:	6442                	ld	s0,16(sp)
    80001e88:	64a2                	ld	s1,8(sp)
    80001e8a:	6105                	addi	sp,sp,32
    80001e8c:	8082                	ret
    int irq = plic_claim();
    80001e8e:	c24fe0ef          	jal	ra,800002b2 <plic_claim>
    80001e92:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001e94:	47a9                	li	a5,10
    80001e96:	02f50363          	beq	a0,a5,80001ebc <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80001e9a:	4785                	li	a5,1
    80001e9c:	02f50363          	beq	a0,a5,80001ec2 <devintr+0x62>
    return 1;
    80001ea0:	4505                	li	a0,1
    } else if(irq){
    80001ea2:	d0ed                	beqz	s1,80001e84 <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80001ea4:	85a6                	mv	a1,s1
    80001ea6:	00004517          	auipc	a0,0x4
    80001eaa:	69250513          	addi	a0,a0,1682 # 80006538 <syscalls+0x170>
    80001eae:	d0efe0ef          	jal	ra,800003bc <printf>
      plic_complete(irq);
    80001eb2:	8526                	mv	a0,s1
    80001eb4:	c1efe0ef          	jal	ra,800002d2 <plic_complete>
    return 1;
    80001eb8:	4505                	li	a0,1
    80001eba:	b7e9                	j	80001e84 <devintr+0x24>
      uartintr();
    80001ebc:	368000ef          	jal	ra,80002224 <uartintr>
    80001ec0:	bfcd                	j	80001eb2 <devintr+0x52>
    virtio_disk_intr();
    80001ec2:	3ca010ef          	jal	ra,8000328c <virtio_disk_intr>
    80001ec6:	b7f5                	j	80001eb2 <devintr+0x52>
    clockintr();
    80001ec8:	f27ff0ef          	jal	ra,80001dee <clockintr>
    return 2;
    80001ecc:	4509                	li	a0,2
    80001ece:	bf5d                	j	80001e84 <devintr+0x24>

0000000080001ed0 <usertrap>:
{
    80001ed0:	1101                	addi	sp,sp,-32
    80001ed2:	ec06                	sd	ra,24(sp)
    80001ed4:	e822                	sd	s0,16(sp)
    80001ed6:	e426                	sd	s1,8(sp)
    80001ed8:	e04a                	sd	s2,0(sp)
    80001eda:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001edc:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001ee0:	1007f793          	andi	a5,a5,256
    80001ee4:	ef85                	bnez	a5,80001f1c <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001ee6:	ffffe797          	auipc	a5,0xffffe
    80001eea:	26a78793          	addi	a5,a5,618 # 80000150 <kernelvec>
    80001eee:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001ef2:	945fe0ef          	jal	ra,80000836 <myproc>
    80001ef6:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001ef8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001efa:	14102773          	csrr	a4,sepc
    80001efe:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001f00:	14202773          	csrr	a4,scause
  if(r_scause() == 8){ //用户态系统调用就会来到这个地方
    80001f04:	47a1                	li	a5,8
    80001f06:	02f70163          	beq	a4,a5,80001f28 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80001f0a:	f57ff0ef          	jal	ra,80001e60 <devintr>
    80001f0e:	892a                	mv	s2,a0
    80001f10:	c135                	beqz	a0,80001f74 <usertrap+0xa4>
  if(killed(p))
    80001f12:	8526                	mv	a0,s1
    80001f14:	a62ff0ef          	jal	ra,80001176 <killed>
    80001f18:	cd1d                	beqz	a0,80001f56 <usertrap+0x86>
    80001f1a:	a81d                	j	80001f50 <usertrap+0x80>
    panic("usertrap: not from user mode");
    80001f1c:	00004517          	auipc	a0,0x4
    80001f20:	63c50513          	addi	a0,a0,1596 # 80006558 <syscalls+0x190>
    80001f24:	f4cfe0ef          	jal	ra,80000670 <panic>
    if(killed(p))
    80001f28:	a4eff0ef          	jal	ra,80001176 <killed>
    80001f2c:	e121                	bnez	a0,80001f6c <usertrap+0x9c>
    p->trapframe->epc += 4;
    80001f2e:	6cb8                	ld	a4,88(s1)
    80001f30:	6f1c                	ld	a5,24(a4)
    80001f32:	0791                	addi	a5,a5,4
    80001f34:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f36:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f3a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f3e:	10079073          	csrw	sstatus,a5
    syscall();
    80001f42:	953ff0ef          	jal	ra,80001894 <syscall>
  if(killed(p))
    80001f46:	8526                	mv	a0,s1
    80001f48:	a2eff0ef          	jal	ra,80001176 <killed>
    80001f4c:	c901                	beqz	a0,80001f5c <usertrap+0x8c>
    80001f4e:	4901                	li	s2,0
    exit(-1);
    80001f50:	557d                	li	a0,-1
    80001f52:	91cff0ef          	jal	ra,8000106e <exit>
  if(which_dev == 2)
    80001f56:	4789                	li	a5,2
    80001f58:	04f90563          	beq	s2,a5,80001fa2 <usertrap+0xd2>
  usertrapret();
    80001f5c:	e01ff0ef          	jal	ra,80001d5c <usertrapret>
}
    80001f60:	60e2                	ld	ra,24(sp)
    80001f62:	6442                	ld	s0,16(sp)
    80001f64:	64a2                	ld	s1,8(sp)
    80001f66:	6902                	ld	s2,0(sp)
    80001f68:	6105                	addi	sp,sp,32
    80001f6a:	8082                	ret
      exit(-1);
    80001f6c:	557d                	li	a0,-1
    80001f6e:	900ff0ef          	jal	ra,8000106e <exit>
    80001f72:	bf75                	j	80001f2e <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001f74:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80001f78:	5890                	lw	a2,48(s1)
    80001f7a:	00004517          	auipc	a0,0x4
    80001f7e:	5fe50513          	addi	a0,a0,1534 # 80006578 <syscalls+0x1b0>
    80001f82:	c3afe0ef          	jal	ra,800003bc <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001f86:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001f8a:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80001f8e:	00004517          	auipc	a0,0x4
    80001f92:	61a50513          	addi	a0,a0,1562 # 800065a8 <syscalls+0x1e0>
    80001f96:	c26fe0ef          	jal	ra,800003bc <printf>
    setkilled(p);
    80001f9a:	8526                	mv	a0,s1
    80001f9c:	9b6ff0ef          	jal	ra,80001152 <setkilled>
    80001fa0:	b75d                	j	80001f46 <usertrap+0x76>
    yield(); //等下要把这个注释掉 这个是用来处理时钟中断的
    80001fa2:	f95fe0ef          	jal	ra,80000f36 <yield>
    80001fa6:	bf5d                	j	80001f5c <usertrap+0x8c>

0000000080001fa8 <kerneltrap>:
{
    80001fa8:	7179                	addi	sp,sp,-48
    80001faa:	f406                	sd	ra,40(sp)
    80001fac:	f022                	sd	s0,32(sp)
    80001fae:	ec26                	sd	s1,24(sp)
    80001fb0:	e84a                	sd	s2,16(sp)
    80001fb2:	e44e                	sd	s3,8(sp)
    80001fb4:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001fb6:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fba:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001fbe:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001fc2:	1004f793          	andi	a5,s1,256
    80001fc6:	c795                	beqz	a5,80001ff2 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fc8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001fcc:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001fce:	eb85                	bnez	a5,80001ffe <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80001fd0:	e91ff0ef          	jal	ra,80001e60 <devintr>
    80001fd4:	c91d                	beqz	a0,8000200a <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80001fd6:	4789                	li	a5,2
    80001fd8:	04f50a63          	beq	a0,a5,8000202c <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001fdc:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fe0:	10049073          	csrw	sstatus,s1
}
    80001fe4:	70a2                	ld	ra,40(sp)
    80001fe6:	7402                	ld	s0,32(sp)
    80001fe8:	64e2                	ld	s1,24(sp)
    80001fea:	6942                	ld	s2,16(sp)
    80001fec:	69a2                	ld	s3,8(sp)
    80001fee:	6145                	addi	sp,sp,48
    80001ff0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001ff2:	00004517          	auipc	a0,0x4
    80001ff6:	5de50513          	addi	a0,a0,1502 # 800065d0 <syscalls+0x208>
    80001ffa:	e76fe0ef          	jal	ra,80000670 <panic>
    panic("kerneltrap: interrupts enabled");
    80001ffe:	00004517          	auipc	a0,0x4
    80002002:	5fa50513          	addi	a0,a0,1530 # 800065f8 <syscalls+0x230>
    80002006:	e6afe0ef          	jal	ra,80000670 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000200a:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000200e:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002012:	85ce                	mv	a1,s3
    80002014:	00004517          	auipc	a0,0x4
    80002018:	60450513          	addi	a0,a0,1540 # 80006618 <syscalls+0x250>
    8000201c:	ba0fe0ef          	jal	ra,800003bc <printf>
    panic("kerneltrap");
    80002020:	00004517          	auipc	a0,0x4
    80002024:	62050513          	addi	a0,a0,1568 # 80006640 <syscalls+0x278>
    80002028:	e48fe0ef          	jal	ra,80000670 <panic>
  if(which_dev == 2 && myproc() != 0)
    8000202c:	80bfe0ef          	jal	ra,80000836 <myproc>
    80002030:	d555                	beqz	a0,80001fdc <kerneltrap+0x34>
    yield();
    80002032:	f05fe0ef          	jal	ra,80000f36 <yield>
    80002036:	b75d                	j	80001fdc <kerneltrap+0x34>

0000000080002038 <uartinit>:

// 原本是被console.c调用，现在被printf.c调用
// 作用：初始化UART硬件
void
uartinit(void)
{
    80002038:	1141                	addi	sp,sp,-16
    8000203a:	e406                	sd	ra,8(sp)
    8000203c:	e022                	sd	s0,0(sp)
    8000203e:	0800                	addi	s0,sp,16
  // disable interrupts.
  // 关闭中断
  WriteReg(IER, 0x00);
    80002040:	100007b7          	lui	a5,0x10000
    80002044:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  // 设置波特率
  WriteReg(LCR, LCR_BAUD_LATCH);
    80002048:	f8000713          	li	a4,-128
    8000204c:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  // 配置数据格式
  WriteReg(0, 0x03);
    80002050:	470d                	li	a4,3
    80002052:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  // 使能并清空FIFO
  WriteReg(1, 0x00);
    80002056:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000205a:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000205e:	469d                	li	a3,7
    80002060:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80002064:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    80002068:	00004597          	auipc	a1,0x4
    8000206c:	5e858593          	addi	a1,a1,1512 # 80006650 <syscalls+0x288>
    80002070:	00012517          	auipc	a0,0x12
    80002074:	8e850513          	addi	a0,a0,-1816 # 80013958 <uart_tx_lock>
    80002078:	ab6ff0ef          	jal	ra,8000132e <initlock>
}
    8000207c:	60a2                	ld	ra,8(sp)
    8000207e:	6402                	ld	s0,0(sp)
    80002080:	0141                	addi	sp,sp,16
    80002082:	8082                	ret

0000000080002084 <uartputc_sync>:
// to echo characters. it spins waiting for the uart's
// output register to be empty.
// 直接（同步）发送一个字符到UART
void
uartputc_sync(int c)
{
    80002084:	1101                	addi	sp,sp,-32
    80002086:	ec06                	sd	ra,24(sp)
    80002088:	e822                	sd	s0,16(sp)
    8000208a:	e426                	sd	s1,8(sp)
    8000208c:	1000                	addi	s0,sp,32
    8000208e:	84aa                	mv	s1,a0
  push_off();
    80002090:	adeff0ef          	jal	ra,8000136e <push_off>

  if(panicked){
    80002094:	00006797          	auipc	a5,0x6
    80002098:	a107a783          	lw	a5,-1520(a5) # 80007aa4 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000209c:	10000737          	lui	a4,0x10000
  if(panicked){
    800020a0:	c391                	beqz	a5,800020a4 <uartputc_sync+0x20>
    for(;;)
    800020a2:	a001                	j	800020a2 <uartputc_sync+0x1e>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800020a4:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800020a8:	0207f793          	andi	a5,a5,32
    800020ac:	dfe5                	beqz	a5,800020a4 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    800020ae:	0ff4f513          	zext.b	a0,s1
    800020b2:	100007b7          	lui	a5,0x10000
    800020b6:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    800020ba:	b38ff0ef          	jal	ra,800013f2 <pop_off>
}
    800020be:	60e2                	ld	ra,24(sp)
    800020c0:	6442                	ld	s0,16(sp)
    800020c2:	64a2                	ld	s1,8(sp)
    800020c4:	6105                	addi	sp,sp,32
    800020c6:	8082                	ret

00000000800020c8 <uartstart>:
// called from both the top- and bottom-half.
// 将缓冲区的数据实际写入UART寄存器，启动发送
void uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    800020c8:	00006797          	auipc	a5,0x6
    800020cc:	9f07b783          	ld	a5,-1552(a5) # 80007ab8 <uart_tx_r>
    800020d0:	00006717          	auipc	a4,0x6
    800020d4:	9f073703          	ld	a4,-1552(a4) # 80007ac0 <uart_tx_w>
    800020d8:	06f70c63          	beq	a4,a5,80002150 <uartstart+0x88>
{
    800020dc:	7139                	addi	sp,sp,-64
    800020de:	fc06                	sd	ra,56(sp)
    800020e0:	f822                	sd	s0,48(sp)
    800020e2:	f426                	sd	s1,40(sp)
    800020e4:	f04a                	sd	s2,32(sp)
    800020e6:	ec4e                	sd	s3,24(sp)
    800020e8:	e852                	sd	s4,16(sp)
    800020ea:	e456                	sd	s5,8(sp)
    800020ec:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800020ee:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800020f2:	00012a17          	auipc	s4,0x12
    800020f6:	866a0a13          	addi	s4,s4,-1946 # 80013958 <uart_tx_lock>
    uart_tx_r += 1;
    800020fa:	00006497          	auipc	s1,0x6
    800020fe:	9be48493          	addi	s1,s1,-1602 # 80007ab8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80002102:	00006997          	auipc	s3,0x6
    80002106:	9be98993          	addi	s3,s3,-1602 # 80007ac0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000210a:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000210e:	02077713          	andi	a4,a4,32
    80002112:	c715                	beqz	a4,8000213e <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80002114:	01f7f713          	andi	a4,a5,31
    80002118:	9752                	add	a4,a4,s4
    8000211a:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000211e:	0785                	addi	a5,a5,1
    80002120:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r); 
    80002122:	8526                	mv	a0,s1
    80002124:	e8bfe0ef          	jal	ra,80000fae <wakeup>
    
    WriteReg(THR, c);
    80002128:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000212c:	609c                	ld	a5,0(s1)
    8000212e:	0009b703          	ld	a4,0(s3)
    80002132:	fcf71ce3          	bne	a4,a5,8000210a <uartstart+0x42>
      ReadReg(ISR);
    80002136:	100007b7          	lui	a5,0x10000
    8000213a:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
  }
}
    8000213e:	70e2                	ld	ra,56(sp)
    80002140:	7442                	ld	s0,48(sp)
    80002142:	74a2                	ld	s1,40(sp)
    80002144:	7902                	ld	s2,32(sp)
    80002146:	69e2                	ld	s3,24(sp)
    80002148:	6a42                	ld	s4,16(sp)
    8000214a:	6aa2                	ld	s5,8(sp)
    8000214c:	6121                	addi	sp,sp,64
    8000214e:	8082                	ret
      ReadReg(ISR);
    80002150:	100007b7          	lui	a5,0x10000
    80002154:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
      return;
    80002158:	8082                	ret

000000008000215a <uartputc>:
{
    8000215a:	7179                	addi	sp,sp,-48
    8000215c:	f406                	sd	ra,40(sp)
    8000215e:	f022                	sd	s0,32(sp)
    80002160:	ec26                	sd	s1,24(sp)
    80002162:	e84a                	sd	s2,16(sp)
    80002164:	e44e                	sd	s3,8(sp)
    80002166:	e052                	sd	s4,0(sp)
    80002168:	1800                	addi	s0,sp,48
    8000216a:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000216c:	00011517          	auipc	a0,0x11
    80002170:	7ec50513          	addi	a0,a0,2028 # 80013958 <uart_tx_lock>
    80002174:	a3aff0ef          	jal	ra,800013ae <acquire>
  if(panicked){
    80002178:	00006797          	auipc	a5,0x6
    8000217c:	92c7a783          	lw	a5,-1748(a5) # 80007aa4 <panicked>
    80002180:	efbd                	bnez	a5,800021fe <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80002182:	00006717          	auipc	a4,0x6
    80002186:	93e73703          	ld	a4,-1730(a4) # 80007ac0 <uart_tx_w>
    8000218a:	00006797          	auipc	a5,0x6
    8000218e:	92e7b783          	ld	a5,-1746(a5) # 80007ab8 <uart_tx_r>
    80002192:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80002196:	00011997          	auipc	s3,0x11
    8000219a:	7c298993          	addi	s3,s3,1986 # 80013958 <uart_tx_lock>
    8000219e:	00006497          	auipc	s1,0x6
    800021a2:	91a48493          	addi	s1,s1,-1766 # 80007ab8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800021a6:	00006917          	auipc	s2,0x6
    800021aa:	91a90913          	addi	s2,s2,-1766 # 80007ac0 <uart_tx_w>
    800021ae:	00e79d63          	bne	a5,a4,800021c8 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    800021b2:	85ce                	mv	a1,s3
    800021b4:	8526                	mv	a0,s1
    800021b6:	dadfe0ef          	jal	ra,80000f62 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800021ba:	00093703          	ld	a4,0(s2)
    800021be:	609c                	ld	a5,0(s1)
    800021c0:	02078793          	addi	a5,a5,32
    800021c4:	fee787e3          	beq	a5,a4,800021b2 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800021c8:	00011497          	auipc	s1,0x11
    800021cc:	79048493          	addi	s1,s1,1936 # 80013958 <uart_tx_lock>
    800021d0:	01f77793          	andi	a5,a4,31
    800021d4:	97a6                	add	a5,a5,s1
    800021d6:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800021da:	0705                	addi	a4,a4,1
    800021dc:	00006797          	auipc	a5,0x6
    800021e0:	8ee7b223          	sd	a4,-1820(a5) # 80007ac0 <uart_tx_w>
  uartstart();
    800021e4:	ee5ff0ef          	jal	ra,800020c8 <uartstart>
  release(&uart_tx_lock);
    800021e8:	8526                	mv	a0,s1
    800021ea:	a5cff0ef          	jal	ra,80001446 <release>
}
    800021ee:	70a2                	ld	ra,40(sp)
    800021f0:	7402                	ld	s0,32(sp)
    800021f2:	64e2                	ld	s1,24(sp)
    800021f4:	6942                	ld	s2,16(sp)
    800021f6:	69a2                	ld	s3,8(sp)
    800021f8:	6a02                	ld	s4,0(sp)
    800021fa:	6145                	addi	sp,sp,48
    800021fc:	8082                	ret
    for(;;)
    800021fe:	a001                	j	800021fe <uartputc+0xa4>

0000000080002200 <uartgetc>:
// read one input character from the UART.
// return -1 if none is waiting.
// 从UART读取一个输入字符
int
uartgetc(void)
{
    80002200:	1141                	addi	sp,sp,-16
    80002202:	e422                	sd	s0,8(sp)
    80002204:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80002206:	100007b7          	lui	a5,0x10000
    8000220a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000220e:	8b85                	andi	a5,a5,1
    80002210:	cb81                	beqz	a5,80002220 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80002212:	100007b7          	lui	a5,0x10000
    80002216:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000221a:	6422                	ld	s0,8(sp)
    8000221c:	0141                	addi	sp,sp,16
    8000221e:	8082                	ret
    return -1;
    80002220:	557d                	li	a0,-1
    80002222:	bfe5                	j	8000221a <uartgetc+0x1a>

0000000080002224 <uartintr>:
// arrived, or the uart is ready for more output, or
// both. called from devintr().
// UART中断处理函数
void
uartintr(void)
{
    80002224:	1101                	addi	sp,sp,-32
    80002226:	ec06                	sd	ra,24(sp)
    80002228:	e822                	sd	s0,16(sp)
    8000222a:	e426                	sd	s1,8(sp)
    8000222c:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc(); // 这个就是从UART寄存器读取一个字符
    if(c == -1)
    8000222e:	54fd                	li	s1,-1
    80002230:	a019                	j	80002236 <uartintr+0x12>
      break;
    // 这个好像委托到console.c的consoleintr()函数处理
    // 老师的意思好像是直接调用那个同步的putc发送
    // 这里不能使用console.c的文件
    // consoleintr(c); 
    pputc(c); // 直接调用printf.c的pputc函数发送字符
    80002232:	8c6fe0ef          	jal	ra,800002f8 <pputc>
    int c = uartgetc(); // 这个就是从UART寄存器读取一个字符
    80002236:	fcbff0ef          	jal	ra,80002200 <uartgetc>
    if(c == -1)
    8000223a:	fe951ce3          	bne	a0,s1,80002232 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    8000223e:	00011497          	auipc	s1,0x11
    80002242:	71a48493          	addi	s1,s1,1818 # 80013958 <uart_tx_lock>
    80002246:	8526                	mv	a0,s1
    80002248:	966ff0ef          	jal	ra,800013ae <acquire>
  uartstart();
    8000224c:	e7dff0ef          	jal	ra,800020c8 <uartstart>
  release(&uart_tx_lock);
    80002250:	8526                	mv	a0,s1
    80002252:	9f4ff0ef          	jal	ra,80001446 <release>
}
    80002256:	60e2                	ld	ra,24(sp)
    80002258:	6442                	ld	s0,16(sp)
    8000225a:	64a2                	ld	s1,8(sp)
    8000225c:	6105                	addi	sp,sp,32
    8000225e:	8082                	ret

0000000080002260 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80002260:	1141                	addi	sp,sp,-16
    80002262:	e422                	sd	s0,8(sp)
    80002264:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80002266:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  // 应该是将TLB中的内容清空，内核更换的时候应该都要做
  sfence_vma();

  // 将kernel_pagetable的地址写入每个CPU核的satp寄存器中
  w_satp(MAKE_SATP(kernel_pagetable));
    8000226a:	00006797          	auipc	a5,0x6
    8000226e:	85e7b783          	ld	a5,-1954(a5) # 80007ac8 <kernel_pagetable>
    80002272:	83b1                	srli	a5,a5,0xc
    80002274:	577d                	li	a4,-1
    80002276:	177e                	slli	a4,a4,0x3f
    80002278:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000227a:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    8000227e:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  // 不知道是不是再清空一遍TLB
  sfence_vma();
}
    80002282:	6422                	ld	s0,8(sp)
    80002284:	0141                	addi	sp,sp,16
    80002286:	8082                	ret

0000000080002288 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80002288:	7139                	addi	sp,sp,-64
    8000228a:	fc06                	sd	ra,56(sp)
    8000228c:	f822                	sd	s0,48(sp)
    8000228e:	f426                	sd	s1,40(sp)
    80002290:	f04a                	sd	s2,32(sp)
    80002292:	ec4e                	sd	s3,24(sp)
    80002294:	e852                	sd	s4,16(sp)
    80002296:	e456                	sd	s5,8(sp)
    80002298:	e05a                	sd	s6,0(sp)
    8000229a:	0080                	addi	s0,sp,64
    8000229c:	84aa                	mv	s1,a0
    8000229e:	89ae                	mv	s3,a1
    800022a0:	8ab2                	mv	s5,a2
  // 首先检查va是否超出了最大的虚拟地址
  if(va >= MAXVA)
    800022a2:	57fd                	li	a5,-1
    800022a4:	83e9                	srli	a5,a5,0x1a
    800022a6:	4a79                	li	s4,30
    panic("walk");
  
  for(int level = 2; level > 0; level--) {
    800022a8:	4b31                	li	s6,12
  if(va >= MAXVA)
    800022aa:	02b7fc63          	bgeu	a5,a1,800022e2 <walk+0x5a>
    panic("walk");
    800022ae:	00004517          	auipc	a0,0x4
    800022b2:	3aa50513          	addi	a0,a0,938 # 80006658 <syscalls+0x290>
    800022b6:	bbafe0ef          	jal	ra,80000670 <panic>
    //查找以pagetable为基址的页表中，序号为VPN[level]的条目
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) { // 如果这个条目是有效的
      pagetable = (pagetable_t)PTE2PA(*pte);  // 取出这个条目对应的物理页面基址
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0) // 如果是一个无效的条目并且不允许分配就返回了
    800022ba:	060a8263          	beqz	s5,8000231e <walk+0x96>
    800022be:	e41fd0ef          	jal	ra,800000fe <kalloc>
    800022c2:	84aa                	mv	s1,a0
    800022c4:	c139                	beqz	a0,8000230a <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800022c6:	6605                	lui	a2,0x1
    800022c8:	4581                	li	a1,0
    800022ca:	a6cff0ef          	jal	ra,80001536 <memset>
      *pte = PA2PTE(pagetable) | PTE_V; // 如果允许分配，就将这个条目记录在这个页表中，并设置有效位
    800022ce:	00c4d793          	srli	a5,s1,0xc
    800022d2:	07aa                	slli	a5,a5,0xa
    800022d4:	0017e793          	ori	a5,a5,1
    800022d8:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800022dc:	3a5d                	addiw	s4,s4,-9
    800022de:	036a0063          	beq	s4,s6,800022fe <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    800022e2:	0149d933          	srl	s2,s3,s4
    800022e6:	1ff97913          	andi	s2,s2,511
    800022ea:	090e                	slli	s2,s2,0x3
    800022ec:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) { // 如果这个条目是有效的
    800022ee:	00093483          	ld	s1,0(s2)
    800022f2:	0014f793          	andi	a5,s1,1
    800022f6:	d3f1                	beqz	a5,800022ba <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);  // 取出这个条目对应的物理页面基址
    800022f8:	80a9                	srli	s1,s1,0xa
    800022fa:	04b2                	slli	s1,s1,0xc
    800022fc:	b7c5                	j	800022dc <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];  // 返回三级页表中序号为VPN[0]的条目地址
    800022fe:	00c9d513          	srli	a0,s3,0xc
    80002302:	1ff57513          	andi	a0,a0,511
    80002306:	050e                	slli	a0,a0,0x3
    80002308:	9526                	add	a0,a0,s1
}
    8000230a:	70e2                	ld	ra,56(sp)
    8000230c:	7442                	ld	s0,48(sp)
    8000230e:	74a2                	ld	s1,40(sp)
    80002310:	7902                	ld	s2,32(sp)
    80002312:	69e2                	ld	s3,24(sp)
    80002314:	6a42                	ld	s4,16(sp)
    80002316:	6aa2                	ld	s5,8(sp)
    80002318:	6b02                	ld	s6,0(sp)
    8000231a:	6121                	addi	sp,sp,64
    8000231c:	8082                	ret
        return 0;
    8000231e:	4501                	li	a0,0
    80002320:	b7ed                	j	8000230a <walk+0x82>

0000000080002322 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80002322:	57fd                	li	a5,-1
    80002324:	83e9                	srli	a5,a5,0x1a
    80002326:	00b7f463          	bgeu	a5,a1,8000232e <walkaddr+0xc>
    return 0;
    8000232a:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000232c:	8082                	ret
{
    8000232e:	1141                	addi	sp,sp,-16
    80002330:	e406                	sd	ra,8(sp)
    80002332:	e022                	sd	s0,0(sp)
    80002334:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80002336:	4601                	li	a2,0
    80002338:	f51ff0ef          	jal	ra,80002288 <walk>
  if(pte == 0)
    8000233c:	c105                	beqz	a0,8000235c <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    8000233e:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80002340:	0117f693          	andi	a3,a5,17
    80002344:	4745                	li	a4,17
    return 0;
    80002346:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80002348:	00e68663          	beq	a3,a4,80002354 <walkaddr+0x32>
}
    8000234c:	60a2                	ld	ra,8(sp)
    8000234e:	6402                	ld	s0,0(sp)
    80002350:	0141                	addi	sp,sp,16
    80002352:	8082                	ret
  pa = PTE2PA(*pte);
    80002354:	83a9                	srli	a5,a5,0xa
    80002356:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000235a:	bfcd                	j	8000234c <walkaddr+0x2a>
    return 0;
    8000235c:	4501                	li	a0,0
    8000235e:	b7fd                	j	8000234c <walkaddr+0x2a>

0000000080002360 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80002360:	715d                	addi	sp,sp,-80
    80002362:	e486                	sd	ra,72(sp)
    80002364:	e0a2                	sd	s0,64(sp)
    80002366:	fc26                	sd	s1,56(sp)
    80002368:	f84a                	sd	s2,48(sp)
    8000236a:	f44e                	sd	s3,40(sp)
    8000236c:	f052                	sd	s4,32(sp)
    8000236e:	ec56                	sd	s5,24(sp)
    80002370:	e85a                	sd	s6,16(sp)
    80002372:	e45e                	sd	s7,8(sp)
    80002374:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80002376:	03459793          	slli	a5,a1,0x34
    8000237a:	e7a9                	bnez	a5,800023c4 <mappages+0x64>
    8000237c:	8aaa                	mv	s5,a0
    8000237e:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80002380:	03461793          	slli	a5,a2,0x34
    80002384:	e7b1                	bnez	a5,800023d0 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    80002386:	ca39                	beqz	a2,800023dc <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80002388:	77fd                	lui	a5,0xfffff
    8000238a:	963e                	add	a2,a2,a5
    8000238c:	00b609b3          	add	s3,a2,a1
  a = va;
    80002390:	892e                	mv	s2,a1
    80002392:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V; // 将内容填写到表项上面去pte-> ppn-perm 物理地址前面部分-标志位
    if(a == last)
      break;
    a += PGSIZE;
    80002396:	6b85                	lui	s7,0x1
    80002398:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000239c:	4605                	li	a2,1
    8000239e:	85ca                	mv	a1,s2
    800023a0:	8556                	mv	a0,s5
    800023a2:	ee7ff0ef          	jal	ra,80002288 <walk>
    800023a6:	c539                	beqz	a0,800023f4 <mappages+0x94>
    if(*pte & PTE_V)
    800023a8:	611c                	ld	a5,0(a0)
    800023aa:	8b85                	andi	a5,a5,1
    800023ac:	ef95                	bnez	a5,800023e8 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V; // 将内容填写到表项上面去pte-> ppn-perm 物理地址前面部分-标志位
    800023ae:	80b1                	srli	s1,s1,0xc
    800023b0:	04aa                	slli	s1,s1,0xa
    800023b2:	0164e4b3          	or	s1,s1,s6
    800023b6:	0014e493          	ori	s1,s1,1
    800023ba:	e104                	sd	s1,0(a0)
    if(a == last)
    800023bc:	05390863          	beq	s2,s3,8000240c <mappages+0xac>
    a += PGSIZE;
    800023c0:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800023c2:	bfd9                	j	80002398 <mappages+0x38>
    panic("mappages: va not aligned");
    800023c4:	00004517          	auipc	a0,0x4
    800023c8:	29c50513          	addi	a0,a0,668 # 80006660 <syscalls+0x298>
    800023cc:	aa4fe0ef          	jal	ra,80000670 <panic>
    panic("mappages: size not aligned");
    800023d0:	00004517          	auipc	a0,0x4
    800023d4:	2b050513          	addi	a0,a0,688 # 80006680 <syscalls+0x2b8>
    800023d8:	a98fe0ef          	jal	ra,80000670 <panic>
    panic("mappages: size");
    800023dc:	00004517          	auipc	a0,0x4
    800023e0:	2c450513          	addi	a0,a0,708 # 800066a0 <syscalls+0x2d8>
    800023e4:	a8cfe0ef          	jal	ra,80000670 <panic>
      panic("mappages: remap");
    800023e8:	00004517          	auipc	a0,0x4
    800023ec:	2c850513          	addi	a0,a0,712 # 800066b0 <syscalls+0x2e8>
    800023f0:	a80fe0ef          	jal	ra,80000670 <panic>
      return -1;
    800023f4:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800023f6:	60a6                	ld	ra,72(sp)
    800023f8:	6406                	ld	s0,64(sp)
    800023fa:	74e2                	ld	s1,56(sp)
    800023fc:	7942                	ld	s2,48(sp)
    800023fe:	79a2                	ld	s3,40(sp)
    80002400:	7a02                	ld	s4,32(sp)
    80002402:	6ae2                	ld	s5,24(sp)
    80002404:	6b42                	ld	s6,16(sp)
    80002406:	6ba2                	ld	s7,8(sp)
    80002408:	6161                	addi	sp,sp,80
    8000240a:	8082                	ret
  return 0;
    8000240c:	4501                	li	a0,0
    8000240e:	b7e5                	j	800023f6 <mappages+0x96>

0000000080002410 <kvmmap>:
{
    80002410:	1141                	addi	sp,sp,-16
    80002412:	e406                	sd	ra,8(sp)
    80002414:	e022                	sd	s0,0(sp)
    80002416:	0800                	addi	s0,sp,16
    80002418:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000241a:	86b2                	mv	a3,a2
    8000241c:	863e                	mv	a2,a5
    8000241e:	f43ff0ef          	jal	ra,80002360 <mappages>
    80002422:	e509                	bnez	a0,8000242c <kvmmap+0x1c>
}
    80002424:	60a2                	ld	ra,8(sp)
    80002426:	6402                	ld	s0,0(sp)
    80002428:	0141                	addi	sp,sp,16
    8000242a:	8082                	ret
    panic("kvmmap");
    8000242c:	00004517          	auipc	a0,0x4
    80002430:	29450513          	addi	a0,a0,660 # 800066c0 <syscalls+0x2f8>
    80002434:	a3cfe0ef          	jal	ra,80000670 <panic>

0000000080002438 <kvmmake>:
{
    80002438:	1101                	addi	sp,sp,-32
    8000243a:	ec06                	sd	ra,24(sp)
    8000243c:	e822                	sd	s0,16(sp)
    8000243e:	e426                	sd	s1,8(sp)
    80002440:	e04a                	sd	s2,0(sp)
    80002442:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80002444:	cbbfd0ef          	jal	ra,800000fe <kalloc>
    80002448:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000244a:	6605                	lui	a2,0x1
    8000244c:	4581                	li	a1,0
    8000244e:	8e8ff0ef          	jal	ra,80001536 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80002452:	4719                	li	a4,6
    80002454:	6685                	lui	a3,0x1
    80002456:	10000637          	lui	a2,0x10000
    8000245a:	100005b7          	lui	a1,0x10000
    8000245e:	8526                	mv	a0,s1
    80002460:	fb1ff0ef          	jal	ra,80002410 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80002464:	4719                	li	a4,6
    80002466:	6685                	lui	a3,0x1
    80002468:	10001637          	lui	a2,0x10001
    8000246c:	100015b7          	lui	a1,0x10001
    80002470:	8526                	mv	a0,s1
    80002472:	f9fff0ef          	jal	ra,80002410 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80002476:	4719                	li	a4,6
    80002478:	040006b7          	lui	a3,0x4000
    8000247c:	0c000637          	lui	a2,0xc000
    80002480:	0c0005b7          	lui	a1,0xc000
    80002484:	8526                	mv	a0,s1
    80002486:	f8bff0ef          	jal	ra,80002410 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000248a:	00004917          	auipc	s2,0x4
    8000248e:	b7690913          	addi	s2,s2,-1162 # 80006000 <etext>
    80002492:	4729                	li	a4,10
    80002494:	80004697          	auipc	a3,0x80004
    80002498:	b6c68693          	addi	a3,a3,-1172 # 6000 <_entry-0x7fffa000>
    8000249c:	4605                	li	a2,1
    8000249e:	067e                	slli	a2,a2,0x1f
    800024a0:	85b2                	mv	a1,a2
    800024a2:	8526                	mv	a0,s1
    800024a4:	f6dff0ef          	jal	ra,80002410 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800024a8:	4719                	li	a4,6
    800024aa:	46c5                	li	a3,17
    800024ac:	06ee                	slli	a3,a3,0x1b
    800024ae:	412686b3          	sub	a3,a3,s2
    800024b2:	864a                	mv	a2,s2
    800024b4:	85ca                	mv	a1,s2
    800024b6:	8526                	mv	a0,s1
    800024b8:	f59ff0ef          	jal	ra,80002410 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800024bc:	4729                	li	a4,10
    800024be:	6685                	lui	a3,0x1
    800024c0:	00003617          	auipc	a2,0x3
    800024c4:	b4060613          	addi	a2,a2,-1216 # 80005000 <_trampoline>
    800024c8:	040005b7          	lui	a1,0x4000
    800024cc:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800024ce:	05b2                	slli	a1,a1,0xc
    800024d0:	8526                	mv	a0,s1
    800024d2:	f3fff0ef          	jal	ra,80002410 <kvmmap>
  proc_mapstacks(kpgtbl);
    800024d6:	8526                	mv	a0,s1
    800024d8:	a00fe0ef          	jal	ra,800006d8 <proc_mapstacks>
}
    800024dc:	8526                	mv	a0,s1
    800024de:	60e2                	ld	ra,24(sp)
    800024e0:	6442                	ld	s0,16(sp)
    800024e2:	64a2                	ld	s1,8(sp)
    800024e4:	6902                	ld	s2,0(sp)
    800024e6:	6105                	addi	sp,sp,32
    800024e8:	8082                	ret

00000000800024ea <kvminit>:
{
    800024ea:	1141                	addi	sp,sp,-16
    800024ec:	e406                	sd	ra,8(sp)
    800024ee:	e022                	sd	s0,0(sp)
    800024f0:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800024f2:	f47ff0ef          	jal	ra,80002438 <kvmmake>
    800024f6:	00005797          	auipc	a5,0x5
    800024fa:	5ca7b923          	sd	a0,1490(a5) # 80007ac8 <kernel_pagetable>
}
    800024fe:	60a2                	ld	ra,8(sp)
    80002500:	6402                	ld	s0,0(sp)
    80002502:	0141                	addi	sp,sp,16
    80002504:	8082                	ret

0000000080002506 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80002506:	715d                	addi	sp,sp,-80
    80002508:	e486                	sd	ra,72(sp)
    8000250a:	e0a2                	sd	s0,64(sp)
    8000250c:	fc26                	sd	s1,56(sp)
    8000250e:	f84a                	sd	s2,48(sp)
    80002510:	f44e                	sd	s3,40(sp)
    80002512:	f052                	sd	s4,32(sp)
    80002514:	ec56                	sd	s5,24(sp)
    80002516:	e85a                	sd	s6,16(sp)
    80002518:	e45e                	sd	s7,8(sp)
    8000251a:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000251c:	03459793          	slli	a5,a1,0x34
    80002520:	e795                	bnez	a5,8000254c <uvmunmap+0x46>
    80002522:	8a2a                	mv	s4,a0
    80002524:	892e                	mv	s2,a1
    80002526:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80002528:	0632                	slli	a2,a2,0xc
    8000252a:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000252e:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80002530:	6b05                	lui	s6,0x1
    80002532:	0535ea63          	bltu	a1,s3,80002586 <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80002536:	60a6                	ld	ra,72(sp)
    80002538:	6406                	ld	s0,64(sp)
    8000253a:	74e2                	ld	s1,56(sp)
    8000253c:	7942                	ld	s2,48(sp)
    8000253e:	79a2                	ld	s3,40(sp)
    80002540:	7a02                	ld	s4,32(sp)
    80002542:	6ae2                	ld	s5,24(sp)
    80002544:	6b42                	ld	s6,16(sp)
    80002546:	6ba2                	ld	s7,8(sp)
    80002548:	6161                	addi	sp,sp,80
    8000254a:	8082                	ret
    panic("uvmunmap: not aligned");
    8000254c:	00004517          	auipc	a0,0x4
    80002550:	17c50513          	addi	a0,a0,380 # 800066c8 <syscalls+0x300>
    80002554:	91cfe0ef          	jal	ra,80000670 <panic>
      panic("uvmunmap: walk");
    80002558:	00004517          	auipc	a0,0x4
    8000255c:	18850513          	addi	a0,a0,392 # 800066e0 <syscalls+0x318>
    80002560:	910fe0ef          	jal	ra,80000670 <panic>
      panic("uvmunmap: not mapped");
    80002564:	00004517          	auipc	a0,0x4
    80002568:	18c50513          	addi	a0,a0,396 # 800066f0 <syscalls+0x328>
    8000256c:	904fe0ef          	jal	ra,80000670 <panic>
      panic("uvmunmap: not a leaf");
    80002570:	00004517          	auipc	a0,0x4
    80002574:	19850513          	addi	a0,a0,408 # 80006708 <syscalls+0x340>
    80002578:	8f8fe0ef          	jal	ra,80000670 <panic>
    *pte = 0;
    8000257c:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80002580:	995a                	add	s2,s2,s6
    80002582:	fb397ae3          	bgeu	s2,s3,80002536 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80002586:	4601                	li	a2,0
    80002588:	85ca                	mv	a1,s2
    8000258a:	8552                	mv	a0,s4
    8000258c:	cfdff0ef          	jal	ra,80002288 <walk>
    80002590:	84aa                	mv	s1,a0
    80002592:	d179                	beqz	a0,80002558 <uvmunmap+0x52>
    if((*pte & PTE_V) == 0)
    80002594:	6108                	ld	a0,0(a0)
    80002596:	00157793          	andi	a5,a0,1
    8000259a:	d7e9                	beqz	a5,80002564 <uvmunmap+0x5e>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000259c:	3ff57793          	andi	a5,a0,1023
    800025a0:	fd7788e3          	beq	a5,s7,80002570 <uvmunmap+0x6a>
    if(do_free){
    800025a4:	fc0a8ce3          	beqz	s5,8000257c <uvmunmap+0x76>
      uint64 pa = PTE2PA(*pte);
    800025a8:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800025aa:	0532                	slli	a0,a0,0xc
    800025ac:	a71fd0ef          	jal	ra,8000001c <kfree>
    800025b0:	b7f1                	j	8000257c <uvmunmap+0x76>

00000000800025b2 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800025b2:	1101                	addi	sp,sp,-32
    800025b4:	ec06                	sd	ra,24(sp)
    800025b6:	e822                	sd	s0,16(sp)
    800025b8:	e426                	sd	s1,8(sp)
    800025ba:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800025bc:	b43fd0ef          	jal	ra,800000fe <kalloc>
    800025c0:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800025c2:	c509                	beqz	a0,800025cc <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800025c4:	6605                	lui	a2,0x1
    800025c6:	4581                	li	a1,0
    800025c8:	f6ffe0ef          	jal	ra,80001536 <memset>
  return pagetable;
}
    800025cc:	8526                	mv	a0,s1
    800025ce:	60e2                	ld	ra,24(sp)
    800025d0:	6442                	ld	s0,16(sp)
    800025d2:	64a2                	ld	s1,8(sp)
    800025d4:	6105                	addi	sp,sp,32
    800025d6:	8082                	ret

00000000800025d8 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800025d8:	7179                	addi	sp,sp,-48
    800025da:	f406                	sd	ra,40(sp)
    800025dc:	f022                	sd	s0,32(sp)
    800025de:	ec26                	sd	s1,24(sp)
    800025e0:	e84a                	sd	s2,16(sp)
    800025e2:	e44e                	sd	s3,8(sp)
    800025e4:	e052                	sd	s4,0(sp)
    800025e6:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800025e8:	6785                	lui	a5,0x1
    800025ea:	04f67063          	bgeu	a2,a5,8000262a <uvmfirst+0x52>
    800025ee:	8a2a                	mv	s4,a0
    800025f0:	89ae                	mv	s3,a1
    800025f2:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800025f4:	b0bfd0ef          	jal	ra,800000fe <kalloc>
    800025f8:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800025fa:	6605                	lui	a2,0x1
    800025fc:	4581                	li	a1,0
    800025fe:	f39fe0ef          	jal	ra,80001536 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80002602:	4779                	li	a4,30
    80002604:	86ca                	mv	a3,s2
    80002606:	6605                	lui	a2,0x1
    80002608:	4581                	li	a1,0
    8000260a:	8552                	mv	a0,s4
    8000260c:	d55ff0ef          	jal	ra,80002360 <mappages>
  memmove(mem, src, sz);
    80002610:	8626                	mv	a2,s1
    80002612:	85ce                	mv	a1,s3
    80002614:	854a                	mv	a0,s2
    80002616:	f7dfe0ef          	jal	ra,80001592 <memmove>
}
    8000261a:	70a2                	ld	ra,40(sp)
    8000261c:	7402                	ld	s0,32(sp)
    8000261e:	64e2                	ld	s1,24(sp)
    80002620:	6942                	ld	s2,16(sp)
    80002622:	69a2                	ld	s3,8(sp)
    80002624:	6a02                	ld	s4,0(sp)
    80002626:	6145                	addi	sp,sp,48
    80002628:	8082                	ret
    panic("uvmfirst: more than a page");
    8000262a:	00004517          	auipc	a0,0x4
    8000262e:	0f650513          	addi	a0,a0,246 # 80006720 <syscalls+0x358>
    80002632:	83efe0ef          	jal	ra,80000670 <panic>

0000000080002636 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80002636:	1101                	addi	sp,sp,-32
    80002638:	ec06                	sd	ra,24(sp)
    8000263a:	e822                	sd	s0,16(sp)
    8000263c:	e426                	sd	s1,8(sp)
    8000263e:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80002640:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80002642:	00b67d63          	bgeu	a2,a1,8000265c <uvmdealloc+0x26>
    80002646:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80002648:	6785                	lui	a5,0x1
    8000264a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000264c:	00f60733          	add	a4,a2,a5
    80002650:	76fd                	lui	a3,0xfffff
    80002652:	8f75                	and	a4,a4,a3
    80002654:	97ae                	add	a5,a5,a1
    80002656:	8ff5                	and	a5,a5,a3
    80002658:	00f76863          	bltu	a4,a5,80002668 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000265c:	8526                	mv	a0,s1
    8000265e:	60e2                	ld	ra,24(sp)
    80002660:	6442                	ld	s0,16(sp)
    80002662:	64a2                	ld	s1,8(sp)
    80002664:	6105                	addi	sp,sp,32
    80002666:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80002668:	8f99                	sub	a5,a5,a4
    8000266a:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000266c:	4685                	li	a3,1
    8000266e:	0007861b          	sext.w	a2,a5
    80002672:	85ba                	mv	a1,a4
    80002674:	e93ff0ef          	jal	ra,80002506 <uvmunmap>
    80002678:	b7d5                	j	8000265c <uvmdealloc+0x26>

000000008000267a <uvmalloc>:
  if(newsz < oldsz)
    8000267a:	08b66963          	bltu	a2,a1,8000270c <uvmalloc+0x92>
{
    8000267e:	7139                	addi	sp,sp,-64
    80002680:	fc06                	sd	ra,56(sp)
    80002682:	f822                	sd	s0,48(sp)
    80002684:	f426                	sd	s1,40(sp)
    80002686:	f04a                	sd	s2,32(sp)
    80002688:	ec4e                	sd	s3,24(sp)
    8000268a:	e852                	sd	s4,16(sp)
    8000268c:	e456                	sd	s5,8(sp)
    8000268e:	e05a                	sd	s6,0(sp)
    80002690:	0080                	addi	s0,sp,64
    80002692:	8aaa                	mv	s5,a0
    80002694:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80002696:	6785                	lui	a5,0x1
    80002698:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000269a:	95be                	add	a1,a1,a5
    8000269c:	77fd                	lui	a5,0xfffff
    8000269e:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800026a2:	06c9f763          	bgeu	s3,a2,80002710 <uvmalloc+0x96>
    800026a6:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800026a8:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800026ac:	a53fd0ef          	jal	ra,800000fe <kalloc>
    800026b0:	84aa                	mv	s1,a0
    if(mem == 0){
    800026b2:	c11d                	beqz	a0,800026d8 <uvmalloc+0x5e>
    memset(mem, 0, PGSIZE);
    800026b4:	6605                	lui	a2,0x1
    800026b6:	4581                	li	a1,0
    800026b8:	e7ffe0ef          	jal	ra,80001536 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800026bc:	875a                	mv	a4,s6
    800026be:	86a6                	mv	a3,s1
    800026c0:	6605                	lui	a2,0x1
    800026c2:	85ca                	mv	a1,s2
    800026c4:	8556                	mv	a0,s5
    800026c6:	c9bff0ef          	jal	ra,80002360 <mappages>
    800026ca:	e51d                	bnez	a0,800026f8 <uvmalloc+0x7e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800026cc:	6785                	lui	a5,0x1
    800026ce:	993e                	add	s2,s2,a5
    800026d0:	fd496ee3          	bltu	s2,s4,800026ac <uvmalloc+0x32>
  return newsz;
    800026d4:	8552                	mv	a0,s4
    800026d6:	a039                	j	800026e4 <uvmalloc+0x6a>
      uvmdealloc(pagetable, a, oldsz);
    800026d8:	864e                	mv	a2,s3
    800026da:	85ca                	mv	a1,s2
    800026dc:	8556                	mv	a0,s5
    800026de:	f59ff0ef          	jal	ra,80002636 <uvmdealloc>
      return 0;
    800026e2:	4501                	li	a0,0
}
    800026e4:	70e2                	ld	ra,56(sp)
    800026e6:	7442                	ld	s0,48(sp)
    800026e8:	74a2                	ld	s1,40(sp)
    800026ea:	7902                	ld	s2,32(sp)
    800026ec:	69e2                	ld	s3,24(sp)
    800026ee:	6a42                	ld	s4,16(sp)
    800026f0:	6aa2                	ld	s5,8(sp)
    800026f2:	6b02                	ld	s6,0(sp)
    800026f4:	6121                	addi	sp,sp,64
    800026f6:	8082                	ret
      kfree(mem);
    800026f8:	8526                	mv	a0,s1
    800026fa:	923fd0ef          	jal	ra,8000001c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800026fe:	864e                	mv	a2,s3
    80002700:	85ca                	mv	a1,s2
    80002702:	8556                	mv	a0,s5
    80002704:	f33ff0ef          	jal	ra,80002636 <uvmdealloc>
      return 0;
    80002708:	4501                	li	a0,0
    8000270a:	bfe9                	j	800026e4 <uvmalloc+0x6a>
    return oldsz;
    8000270c:	852e                	mv	a0,a1
}
    8000270e:	8082                	ret
  return newsz;
    80002710:	8532                	mv	a0,a2
    80002712:	bfc9                	j	800026e4 <uvmalloc+0x6a>

0000000080002714 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80002714:	7179                	addi	sp,sp,-48
    80002716:	f406                	sd	ra,40(sp)
    80002718:	f022                	sd	s0,32(sp)
    8000271a:	ec26                	sd	s1,24(sp)
    8000271c:	e84a                	sd	s2,16(sp)
    8000271e:	e44e                	sd	s3,8(sp)
    80002720:	e052                	sd	s4,0(sp)
    80002722:	1800                	addi	s0,sp,48
    80002724:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80002726:	84aa                	mv	s1,a0
    80002728:	6905                	lui	s2,0x1
    8000272a:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000272c:	4985                	li	s3,1
    8000272e:	a819                	j	80002744 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80002730:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80002732:	00c79513          	slli	a0,a5,0xc
    80002736:	fdfff0ef          	jal	ra,80002714 <freewalk>
      pagetable[i] = 0;
    8000273a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000273e:	04a1                	addi	s1,s1,8
    80002740:	01248f63          	beq	s1,s2,8000275e <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80002744:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80002746:	00f7f713          	andi	a4,a5,15
    8000274a:	ff3703e3          	beq	a4,s3,80002730 <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000274e:	8b85                	andi	a5,a5,1
    80002750:	d7fd                	beqz	a5,8000273e <freewalk+0x2a>
      panic("freewalk: leaf");
    80002752:	00004517          	auipc	a0,0x4
    80002756:	fee50513          	addi	a0,a0,-18 # 80006740 <syscalls+0x378>
    8000275a:	f17fd0ef          	jal	ra,80000670 <panic>
    }
  }
  kfree((void*)pagetable);
    8000275e:	8552                	mv	a0,s4
    80002760:	8bdfd0ef          	jal	ra,8000001c <kfree>
}
    80002764:	70a2                	ld	ra,40(sp)
    80002766:	7402                	ld	s0,32(sp)
    80002768:	64e2                	ld	s1,24(sp)
    8000276a:	6942                	ld	s2,16(sp)
    8000276c:	69a2                	ld	s3,8(sp)
    8000276e:	6a02                	ld	s4,0(sp)
    80002770:	6145                	addi	sp,sp,48
    80002772:	8082                	ret

0000000080002774 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80002774:	1101                	addi	sp,sp,-32
    80002776:	ec06                	sd	ra,24(sp)
    80002778:	e822                	sd	s0,16(sp)
    8000277a:	e426                	sd	s1,8(sp)
    8000277c:	1000                	addi	s0,sp,32
    8000277e:	84aa                	mv	s1,a0
  if(sz > 0)
    80002780:	e989                	bnez	a1,80002792 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80002782:	8526                	mv	a0,s1
    80002784:	f91ff0ef          	jal	ra,80002714 <freewalk>
}
    80002788:	60e2                	ld	ra,24(sp)
    8000278a:	6442                	ld	s0,16(sp)
    8000278c:	64a2                	ld	s1,8(sp)
    8000278e:	6105                	addi	sp,sp,32
    80002790:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80002792:	6785                	lui	a5,0x1
    80002794:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80002796:	95be                	add	a1,a1,a5
    80002798:	4685                	li	a3,1
    8000279a:	00c5d613          	srli	a2,a1,0xc
    8000279e:	4581                	li	a1,0
    800027a0:	d67ff0ef          	jal	ra,80002506 <uvmunmap>
    800027a4:	bff9                	j	80002782 <uvmfree+0xe>

00000000800027a6 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800027a6:	c65d                	beqz	a2,80002854 <uvmcopy+0xae>
{
    800027a8:	715d                	addi	sp,sp,-80
    800027aa:	e486                	sd	ra,72(sp)
    800027ac:	e0a2                	sd	s0,64(sp)
    800027ae:	fc26                	sd	s1,56(sp)
    800027b0:	f84a                	sd	s2,48(sp)
    800027b2:	f44e                	sd	s3,40(sp)
    800027b4:	f052                	sd	s4,32(sp)
    800027b6:	ec56                	sd	s5,24(sp)
    800027b8:	e85a                	sd	s6,16(sp)
    800027ba:	e45e                	sd	s7,8(sp)
    800027bc:	0880                	addi	s0,sp,80
    800027be:	8b2a                	mv	s6,a0
    800027c0:	8aae                	mv	s5,a1
    800027c2:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800027c4:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800027c6:	4601                	li	a2,0
    800027c8:	85ce                	mv	a1,s3
    800027ca:	855a                	mv	a0,s6
    800027cc:	abdff0ef          	jal	ra,80002288 <walk>
    800027d0:	c121                	beqz	a0,80002810 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800027d2:	6118                	ld	a4,0(a0)
    800027d4:	00177793          	andi	a5,a4,1
    800027d8:	c3b1                	beqz	a5,8000281c <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800027da:	00a75593          	srli	a1,a4,0xa
    800027de:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800027e2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800027e6:	919fd0ef          	jal	ra,800000fe <kalloc>
    800027ea:	892a                	mv	s2,a0
    800027ec:	c129                	beqz	a0,8000282e <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800027ee:	6605                	lui	a2,0x1
    800027f0:	85de                	mv	a1,s7
    800027f2:	da1fe0ef          	jal	ra,80001592 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800027f6:	8726                	mv	a4,s1
    800027f8:	86ca                	mv	a3,s2
    800027fa:	6605                	lui	a2,0x1
    800027fc:	85ce                	mv	a1,s3
    800027fe:	8556                	mv	a0,s5
    80002800:	b61ff0ef          	jal	ra,80002360 <mappages>
    80002804:	e115                	bnez	a0,80002828 <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    80002806:	6785                	lui	a5,0x1
    80002808:	99be                	add	s3,s3,a5
    8000280a:	fb49eee3          	bltu	s3,s4,800027c6 <uvmcopy+0x20>
    8000280e:	a805                	j	8000283e <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    80002810:	00004517          	auipc	a0,0x4
    80002814:	f4050513          	addi	a0,a0,-192 # 80006750 <syscalls+0x388>
    80002818:	e59fd0ef          	jal	ra,80000670 <panic>
      panic("uvmcopy: page not present");
    8000281c:	00004517          	auipc	a0,0x4
    80002820:	f5450513          	addi	a0,a0,-172 # 80006770 <syscalls+0x3a8>
    80002824:	e4dfd0ef          	jal	ra,80000670 <panic>
      kfree(mem);
    80002828:	854a                	mv	a0,s2
    8000282a:	ff2fd0ef          	jal	ra,8000001c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000282e:	4685                	li	a3,1
    80002830:	00c9d613          	srli	a2,s3,0xc
    80002834:	4581                	li	a1,0
    80002836:	8556                	mv	a0,s5
    80002838:	ccfff0ef          	jal	ra,80002506 <uvmunmap>
  return -1;
    8000283c:	557d                	li	a0,-1
}
    8000283e:	60a6                	ld	ra,72(sp)
    80002840:	6406                	ld	s0,64(sp)
    80002842:	74e2                	ld	s1,56(sp)
    80002844:	7942                	ld	s2,48(sp)
    80002846:	79a2                	ld	s3,40(sp)
    80002848:	7a02                	ld	s4,32(sp)
    8000284a:	6ae2                	ld	s5,24(sp)
    8000284c:	6b42                	ld	s6,16(sp)
    8000284e:	6ba2                	ld	s7,8(sp)
    80002850:	6161                	addi	sp,sp,80
    80002852:	8082                	ret
  return 0;
    80002854:	4501                	li	a0,0
}
    80002856:	8082                	ret

0000000080002858 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80002858:	1141                	addi	sp,sp,-16
    8000285a:	e406                	sd	ra,8(sp)
    8000285c:	e022                	sd	s0,0(sp)
    8000285e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80002860:	4601                	li	a2,0
    80002862:	a27ff0ef          	jal	ra,80002288 <walk>
  if(pte == 0)
    80002866:	c901                	beqz	a0,80002876 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80002868:	611c                	ld	a5,0(a0)
    8000286a:	9bbd                	andi	a5,a5,-17
    8000286c:	e11c                	sd	a5,0(a0)
}
    8000286e:	60a2                	ld	ra,8(sp)
    80002870:	6402                	ld	s0,0(sp)
    80002872:	0141                	addi	sp,sp,16
    80002874:	8082                	ret
    panic("uvmclear");
    80002876:	00004517          	auipc	a0,0x4
    8000287a:	f1a50513          	addi	a0,a0,-230 # 80006790 <syscalls+0x3c8>
    8000287e:	df3fd0ef          	jal	ra,80000670 <panic>

0000000080002882 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    80002882:	c6c9                	beqz	a3,8000290c <copyout+0x8a>
{
    80002884:	711d                	addi	sp,sp,-96
    80002886:	ec86                	sd	ra,88(sp)
    80002888:	e8a2                	sd	s0,80(sp)
    8000288a:	e4a6                	sd	s1,72(sp)
    8000288c:	e0ca                	sd	s2,64(sp)
    8000288e:	fc4e                	sd	s3,56(sp)
    80002890:	f852                	sd	s4,48(sp)
    80002892:	f456                	sd	s5,40(sp)
    80002894:	f05a                	sd	s6,32(sp)
    80002896:	ec5e                	sd	s7,24(sp)
    80002898:	e862                	sd	s8,16(sp)
    8000289a:	e466                	sd	s9,8(sp)
    8000289c:	e06a                	sd	s10,0(sp)
    8000289e:	1080                	addi	s0,sp,96
    800028a0:	8baa                	mv	s7,a0
    800028a2:	8aae                	mv	s5,a1
    800028a4:	8b32                	mv	s6,a2
    800028a6:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800028a8:	74fd                	lui	s1,0xfffff
    800028aa:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    800028ac:	57fd                	li	a5,-1
    800028ae:	83e9                	srli	a5,a5,0x1a
    800028b0:	0697e063          	bltu	a5,s1,80002910 <copyout+0x8e>
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800028b4:	4cd5                	li	s9,21
    800028b6:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    800028b8:	8c3e                	mv	s8,a5
    800028ba:	a025                	j	800028e2 <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    800028bc:	83a9                	srli	a5,a5,0xa
    800028be:	07b2                	slli	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800028c0:	409a8533          	sub	a0,s5,s1
    800028c4:	0009061b          	sext.w	a2,s2
    800028c8:	85da                	mv	a1,s6
    800028ca:	953e                	add	a0,a0,a5
    800028cc:	cc7fe0ef          	jal	ra,80001592 <memmove>

    len -= n;
    800028d0:	412989b3          	sub	s3,s3,s2
    src += n;
    800028d4:	9b4a                	add	s6,s6,s2
  while(len > 0){
    800028d6:	02098963          	beqz	s3,80002908 <copyout+0x86>
    if(va0 >= MAXVA)
    800028da:	034c6d63          	bltu	s8,s4,80002914 <copyout+0x92>
    va0 = PGROUNDDOWN(dstva);
    800028de:	84d2                	mv	s1,s4
    dstva = va0 + PGSIZE;
    800028e0:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    800028e2:	4601                	li	a2,0
    800028e4:	85a6                	mv	a1,s1
    800028e6:	855e                	mv	a0,s7
    800028e8:	9a1ff0ef          	jal	ra,80002288 <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800028ec:	c515                	beqz	a0,80002918 <copyout+0x96>
    800028ee:	611c                	ld	a5,0(a0)
    800028f0:	0157f713          	andi	a4,a5,21
    800028f4:	05971163          	bne	a4,s9,80002936 <copyout+0xb4>
    n = PGSIZE - (dstva - va0);
    800028f8:	01a48a33          	add	s4,s1,s10
    800028fc:	415a0933          	sub	s2,s4,s5
    80002900:	fb29fee3          	bgeu	s3,s2,800028bc <copyout+0x3a>
    80002904:	894e                	mv	s2,s3
    80002906:	bf5d                	j	800028bc <copyout+0x3a>
  }
  return 0;
    80002908:	4501                	li	a0,0
    8000290a:	a801                	j	8000291a <copyout+0x98>
    8000290c:	4501                	li	a0,0
}
    8000290e:	8082                	ret
      return -1;
    80002910:	557d                	li	a0,-1
    80002912:	a021                	j	8000291a <copyout+0x98>
    80002914:	557d                	li	a0,-1
    80002916:	a011                	j	8000291a <copyout+0x98>
      return -1;
    80002918:	557d                	li	a0,-1
}
    8000291a:	60e6                	ld	ra,88(sp)
    8000291c:	6446                	ld	s0,80(sp)
    8000291e:	64a6                	ld	s1,72(sp)
    80002920:	6906                	ld	s2,64(sp)
    80002922:	79e2                	ld	s3,56(sp)
    80002924:	7a42                	ld	s4,48(sp)
    80002926:	7aa2                	ld	s5,40(sp)
    80002928:	7b02                	ld	s6,32(sp)
    8000292a:	6be2                	ld	s7,24(sp)
    8000292c:	6c42                	ld	s8,16(sp)
    8000292e:	6ca2                	ld	s9,8(sp)
    80002930:	6d02                	ld	s10,0(sp)
    80002932:	6125                	addi	sp,sp,96
    80002934:	8082                	ret
      return -1;
    80002936:	557d                	li	a0,-1
    80002938:	b7cd                	j	8000291a <copyout+0x98>

000000008000293a <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000293a:	c6a5                	beqz	a3,800029a2 <copyin+0x68>
{
    8000293c:	715d                	addi	sp,sp,-80
    8000293e:	e486                	sd	ra,72(sp)
    80002940:	e0a2                	sd	s0,64(sp)
    80002942:	fc26                	sd	s1,56(sp)
    80002944:	f84a                	sd	s2,48(sp)
    80002946:	f44e                	sd	s3,40(sp)
    80002948:	f052                	sd	s4,32(sp)
    8000294a:	ec56                	sd	s5,24(sp)
    8000294c:	e85a                	sd	s6,16(sp)
    8000294e:	e45e                	sd	s7,8(sp)
    80002950:	e062                	sd	s8,0(sp)
    80002952:	0880                	addi	s0,sp,80
    80002954:	8b2a                	mv	s6,a0
    80002956:	8a2e                	mv	s4,a1
    80002958:	8c32                	mv	s8,a2
    8000295a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000295c:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000295e:	6a85                	lui	s5,0x1
    80002960:	a00d                	j	80002982 <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80002962:	018505b3          	add	a1,a0,s8
    80002966:	0004861b          	sext.w	a2,s1
    8000296a:	412585b3          	sub	a1,a1,s2
    8000296e:	8552                	mv	a0,s4
    80002970:	c23fe0ef          	jal	ra,80001592 <memmove>

    len -= n;
    80002974:	409989b3          	sub	s3,s3,s1
    dst += n;
    80002978:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000297a:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000297e:	02098063          	beqz	s3,8000299e <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80002982:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80002986:	85ca                	mv	a1,s2
    80002988:	855a                	mv	a0,s6
    8000298a:	999ff0ef          	jal	ra,80002322 <walkaddr>
    if(pa0 == 0)
    8000298e:	cd01                	beqz	a0,800029a6 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    80002990:	418904b3          	sub	s1,s2,s8
    80002994:	94d6                	add	s1,s1,s5
    80002996:	fc99f6e3          	bgeu	s3,s1,80002962 <copyin+0x28>
    8000299a:	84ce                	mv	s1,s3
    8000299c:	b7d9                	j	80002962 <copyin+0x28>
  }
  return 0;
    8000299e:	4501                	li	a0,0
    800029a0:	a021                	j	800029a8 <copyin+0x6e>
    800029a2:	4501                	li	a0,0
}
    800029a4:	8082                	ret
      return -1;
    800029a6:	557d                	li	a0,-1
}
    800029a8:	60a6                	ld	ra,72(sp)
    800029aa:	6406                	ld	s0,64(sp)
    800029ac:	74e2                	ld	s1,56(sp)
    800029ae:	7942                	ld	s2,48(sp)
    800029b0:	79a2                	ld	s3,40(sp)
    800029b2:	7a02                	ld	s4,32(sp)
    800029b4:	6ae2                	ld	s5,24(sp)
    800029b6:	6b42                	ld	s6,16(sp)
    800029b8:	6ba2                	ld	s7,8(sp)
    800029ba:	6c02                	ld	s8,0(sp)
    800029bc:	6161                	addi	sp,sp,80
    800029be:	8082                	ret

00000000800029c0 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800029c0:	c2cd                	beqz	a3,80002a62 <copyinstr+0xa2>
{
    800029c2:	715d                	addi	sp,sp,-80
    800029c4:	e486                	sd	ra,72(sp)
    800029c6:	e0a2                	sd	s0,64(sp)
    800029c8:	fc26                	sd	s1,56(sp)
    800029ca:	f84a                	sd	s2,48(sp)
    800029cc:	f44e                	sd	s3,40(sp)
    800029ce:	f052                	sd	s4,32(sp)
    800029d0:	ec56                	sd	s5,24(sp)
    800029d2:	e85a                	sd	s6,16(sp)
    800029d4:	e45e                	sd	s7,8(sp)
    800029d6:	0880                	addi	s0,sp,80
    800029d8:	8a2a                	mv	s4,a0
    800029da:	8b2e                	mv	s6,a1
    800029dc:	8bb2                	mv	s7,a2
    800029de:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800029e0:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800029e2:	6985                	lui	s3,0x1
    800029e4:	a02d                	j	80002a0e <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800029e6:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800029ea:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800029ec:	37fd                	addiw	a5,a5,-1
    800029ee:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800029f2:	60a6                	ld	ra,72(sp)
    800029f4:	6406                	ld	s0,64(sp)
    800029f6:	74e2                	ld	s1,56(sp)
    800029f8:	7942                	ld	s2,48(sp)
    800029fa:	79a2                	ld	s3,40(sp)
    800029fc:	7a02                	ld	s4,32(sp)
    800029fe:	6ae2                	ld	s5,24(sp)
    80002a00:	6b42                	ld	s6,16(sp)
    80002a02:	6ba2                	ld	s7,8(sp)
    80002a04:	6161                	addi	sp,sp,80
    80002a06:	8082                	ret
    srcva = va0 + PGSIZE;
    80002a08:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80002a0c:	c4b9                	beqz	s1,80002a5a <copyinstr+0x9a>
    va0 = PGROUNDDOWN(srcva);
    80002a0e:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80002a12:	85ca                	mv	a1,s2
    80002a14:	8552                	mv	a0,s4
    80002a16:	90dff0ef          	jal	ra,80002322 <walkaddr>
    if(pa0 == 0)
    80002a1a:	c131                	beqz	a0,80002a5e <copyinstr+0x9e>
    n = PGSIZE - (srcva - va0);
    80002a1c:	417906b3          	sub	a3,s2,s7
    80002a20:	96ce                	add	a3,a3,s3
    80002a22:	00d4f363          	bgeu	s1,a3,80002a28 <copyinstr+0x68>
    80002a26:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80002a28:	955e                	add	a0,a0,s7
    80002a2a:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80002a2e:	dee9                	beqz	a3,80002a08 <copyinstr+0x48>
    80002a30:	87da                	mv	a5,s6
      if(*p == '\0'){
    80002a32:	41650633          	sub	a2,a0,s6
    80002a36:	fff48593          	addi	a1,s1,-1 # ffffffffffffefff <end+0xffffffff7ffe12ff>
    80002a3a:	95da                	add	a1,a1,s6
    while(n > 0){
    80002a3c:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80002a3e:	00f60733          	add	a4,a2,a5
    80002a42:	00074703          	lbu	a4,0(a4)
    80002a46:	d345                	beqz	a4,800029e6 <copyinstr+0x26>
        *dst = *p;
    80002a48:	00e78023          	sb	a4,0(a5)
      --max;
    80002a4c:	40f584b3          	sub	s1,a1,a5
      dst++;
    80002a50:	0785                	addi	a5,a5,1
    while(n > 0){
    80002a52:	fed796e3          	bne	a5,a3,80002a3e <copyinstr+0x7e>
      dst++;
    80002a56:	8b3e                	mv	s6,a5
    80002a58:	bf45                	j	80002a08 <copyinstr+0x48>
    80002a5a:	4781                	li	a5,0
    80002a5c:	bf41                	j	800029ec <copyinstr+0x2c>
      return -1;
    80002a5e:	557d                	li	a0,-1
    80002a60:	bf49                	j	800029f2 <copyinstr+0x32>
  int got_null = 0;
    80002a62:	4781                	li	a5,0
  if(got_null){
    80002a64:	37fd                	addiw	a5,a5,-1
    80002a66:	0007851b          	sext.w	a0,a5
}
    80002a6a:	8082                	ret

0000000080002a6c <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80002a6c:	715d                	addi	sp,sp,-80
    80002a6e:	e486                	sd	ra,72(sp)
    80002a70:	e0a2                	sd	s0,64(sp)
    80002a72:	fc26                	sd	s1,56(sp)
    80002a74:	f84a                	sd	s2,48(sp)
    80002a76:	f44e                	sd	s3,40(sp)
    80002a78:	f052                	sd	s4,32(sp)
    80002a7a:	ec56                	sd	s5,24(sp)
    80002a7c:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80002a7e:	04c05363          	blez	a2,80002ac4 <consolewrite+0x58>
    80002a82:	8a2a                	mv	s4,a0
    80002a84:	84ae                	mv	s1,a1
    80002a86:	89b2                	mv	s3,a2
    80002a88:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80002a8a:	5afd                	li	s5,-1
    80002a8c:	4685                	li	a3,1
    80002a8e:	8626                	mv	a2,s1
    80002a90:	85d2                	mv	a1,s4
    80002a92:	fbf40513          	addi	a0,s0,-65
    80002a96:	84ffe0ef          	jal	ra,800012e4 <either_copyin>
    80002a9a:	01550b63          	beq	a0,s5,80002ab0 <consolewrite+0x44>
      break;
    uartputc(c);
    80002a9e:	fbf44503          	lbu	a0,-65(s0)
    80002aa2:	eb8ff0ef          	jal	ra,8000215a <uartputc>
  for(i = 0; i < n; i++){
    80002aa6:	2905                	addiw	s2,s2,1 # 1001 <_entry-0x7fffefff>
    80002aa8:	0485                	addi	s1,s1,1
    80002aaa:	ff2991e3          	bne	s3,s2,80002a8c <consolewrite+0x20>
    80002aae:	894e                	mv	s2,s3
  }

  return i;
}
    80002ab0:	854a                	mv	a0,s2
    80002ab2:	60a6                	ld	ra,72(sp)
    80002ab4:	6406                	ld	s0,64(sp)
    80002ab6:	74e2                	ld	s1,56(sp)
    80002ab8:	7942                	ld	s2,48(sp)
    80002aba:	79a2                	ld	s3,40(sp)
    80002abc:	7a02                	ld	s4,32(sp)
    80002abe:	6ae2                	ld	s5,24(sp)
    80002ac0:	6161                	addi	sp,sp,80
    80002ac2:	8082                	ret
  for(i = 0; i < n; i++){
    80002ac4:	4901                	li	s2,0
    80002ac6:	b7ed                	j	80002ab0 <consolewrite+0x44>

0000000080002ac8 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002ac8:	7179                	addi	sp,sp,-48
    80002aca:	f406                	sd	ra,40(sp)
    80002acc:	f022                	sd	s0,32(sp)
    80002ace:	ec26                	sd	s1,24(sp)
    80002ad0:	e84a                	sd	s2,16(sp)
    80002ad2:	e44e                	sd	s3,8(sp)
    80002ad4:	e052                	sd	s4,0(sp)
    80002ad6:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002ad8:	00004597          	auipc	a1,0x4
    80002adc:	cc858593          	addi	a1,a1,-824 # 800067a0 <syscalls+0x3d8>
    80002ae0:	00011517          	auipc	a0,0x11
    80002ae4:	eb050513          	addi	a0,a0,-336 # 80013990 <bcache>
    80002ae8:	847fe0ef          	jal	ra,8000132e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002aec:	00019797          	auipc	a5,0x19
    80002af0:	ea478793          	addi	a5,a5,-348 # 8001b990 <bcache+0x8000>
    80002af4:	00019717          	auipc	a4,0x19
    80002af8:	10470713          	addi	a4,a4,260 # 8001bbf8 <bcache+0x8268>
    80002afc:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002b00:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b04:	00011497          	auipc	s1,0x11
    80002b08:	ea448493          	addi	s1,s1,-348 # 800139a8 <bcache+0x18>
    b->next = bcache.head.next;
    80002b0c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002b0e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002b10:	00004a17          	auipc	s4,0x4
    80002b14:	c98a0a13          	addi	s4,s4,-872 # 800067a8 <syscalls+0x3e0>
    b->next = bcache.head.next;
    80002b18:	2b893783          	ld	a5,696(s2)
    80002b1c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002b1e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002b22:	85d2                	mv	a1,s4
    80002b24:	01048513          	addi	a0,s1,16
    80002b28:	220000ef          	jal	ra,80002d48 <initsleeplock>
    bcache.head.next->prev = b;
    80002b2c:	2b893783          	ld	a5,696(s2)
    80002b30:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002b32:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b36:	45848493          	addi	s1,s1,1112
    80002b3a:	fd349fe3          	bne	s1,s3,80002b18 <binit+0x50>
  }
}
    80002b3e:	70a2                	ld	ra,40(sp)
    80002b40:	7402                	ld	s0,32(sp)
    80002b42:	64e2                	ld	s1,24(sp)
    80002b44:	6942                	ld	s2,16(sp)
    80002b46:	69a2                	ld	s3,8(sp)
    80002b48:	6a02                	ld	s4,0(sp)
    80002b4a:	6145                	addi	sp,sp,48
    80002b4c:	8082                	ret

0000000080002b4e <bread>:

// Return a locked buf with the contents of the indicated block.
// 传入物理设备和块号，返回一块已经读好了相关物理块内容的buf 这个块号是物理块号
struct buf*
bread(uint dev, uint blockno)
{
    80002b4e:	7179                	addi	sp,sp,-48
    80002b50:	f406                	sd	ra,40(sp)
    80002b52:	f022                	sd	s0,32(sp)
    80002b54:	ec26                	sd	s1,24(sp)
    80002b56:	e84a                	sd	s2,16(sp)
    80002b58:	e44e                	sd	s3,8(sp)
    80002b5a:	1800                	addi	s0,sp,48
    80002b5c:	892a                	mv	s2,a0
    80002b5e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002b60:	00011517          	auipc	a0,0x11
    80002b64:	e3050513          	addi	a0,a0,-464 # 80013990 <bcache>
    80002b68:	847fe0ef          	jal	ra,800013ae <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002b6c:	00019497          	auipc	s1,0x19
    80002b70:	0dc4b483          	ld	s1,220(s1) # 8001bc48 <bcache+0x82b8>
    80002b74:	00019797          	auipc	a5,0x19
    80002b78:	08478793          	addi	a5,a5,132 # 8001bbf8 <bcache+0x8268>
    80002b7c:	02f48b63          	beq	s1,a5,80002bb2 <bread+0x64>
    80002b80:	873e                	mv	a4,a5
    80002b82:	a021                	j	80002b8a <bread+0x3c>
    80002b84:	68a4                	ld	s1,80(s1)
    80002b86:	02e48663          	beq	s1,a4,80002bb2 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002b8a:	449c                	lw	a5,8(s1)
    80002b8c:	ff279ce3          	bne	a5,s2,80002b84 <bread+0x36>
    80002b90:	44dc                	lw	a5,12(s1)
    80002b92:	ff3799e3          	bne	a5,s3,80002b84 <bread+0x36>
      b->refcnt++;
    80002b96:	40bc                	lw	a5,64(s1)
    80002b98:	2785                	addiw	a5,a5,1
    80002b9a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002b9c:	00011517          	auipc	a0,0x11
    80002ba0:	df450513          	addi	a0,a0,-524 # 80013990 <bcache>
    80002ba4:	8a3fe0ef          	jal	ra,80001446 <release>
      acquiresleep(&b->lock);
    80002ba8:	01048513          	addi	a0,s1,16
    80002bac:	1d2000ef          	jal	ra,80002d7e <acquiresleep>
      return b;
    80002bb0:	a889                	j	80002c02 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002bb2:	00019497          	auipc	s1,0x19
    80002bb6:	08e4b483          	ld	s1,142(s1) # 8001bc40 <bcache+0x82b0>
    80002bba:	00019797          	auipc	a5,0x19
    80002bbe:	03e78793          	addi	a5,a5,62 # 8001bbf8 <bcache+0x8268>
    80002bc2:	00f48863          	beq	s1,a5,80002bd2 <bread+0x84>
    80002bc6:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002bc8:	40bc                	lw	a5,64(s1)
    80002bca:	cb91                	beqz	a5,80002bde <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002bcc:	64a4                	ld	s1,72(s1)
    80002bce:	fee49de3          	bne	s1,a4,80002bc8 <bread+0x7a>
  panic("bget: no buffers");
    80002bd2:	00004517          	auipc	a0,0x4
    80002bd6:	bde50513          	addi	a0,a0,-1058 # 800067b0 <syscalls+0x3e8>
    80002bda:	a97fd0ef          	jal	ra,80000670 <panic>
      b->dev = dev;
    80002bde:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002be2:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002be6:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002bea:	4785                	li	a5,1
    80002bec:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002bee:	00011517          	auipc	a0,0x11
    80002bf2:	da250513          	addi	a0,a0,-606 # 80013990 <bcache>
    80002bf6:	851fe0ef          	jal	ra,80001446 <release>
      acquiresleep(&b->lock);
    80002bfa:	01048513          	addi	a0,s1,16
    80002bfe:	180000ef          	jal	ra,80002d7e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002c02:	409c                	lw	a5,0(s1)
    80002c04:	cb89                	beqz	a5,80002c16 <bread+0xc8>
    virtio_disk_rw(b, 0); 
    b->valid = 1;
  }
  return b;
}
    80002c06:	8526                	mv	a0,s1
    80002c08:	70a2                	ld	ra,40(sp)
    80002c0a:	7402                	ld	s0,32(sp)
    80002c0c:	64e2                	ld	s1,24(sp)
    80002c0e:	6942                	ld	s2,16(sp)
    80002c10:	69a2                	ld	s3,8(sp)
    80002c12:	6145                	addi	sp,sp,48
    80002c14:	8082                	ret
    virtio_disk_rw(b, 0); 
    80002c16:	4581                	li	a1,0
    80002c18:	8526                	mv	a0,s1
    80002c1a:	458000ef          	jal	ra,80003072 <virtio_disk_rw>
    b->valid = 1;
    80002c1e:	4785                	li	a5,1
    80002c20:	c09c                	sw	a5,0(s1)
  return b;
    80002c22:	b7d5                	j	80002c06 <bread+0xb8>

0000000080002c24 <bwrite>:

// Write b's contents to disk.  Must be locked.
// 传入buf，将其写入disk
void
bwrite(struct buf *b)
{
    80002c24:	1101                	addi	sp,sp,-32
    80002c26:	ec06                	sd	ra,24(sp)
    80002c28:	e822                	sd	s0,16(sp)
    80002c2a:	e426                	sd	s1,8(sp)
    80002c2c:	1000                	addi	s0,sp,32
    80002c2e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002c30:	0541                	addi	a0,a0,16
    80002c32:	1ca000ef          	jal	ra,80002dfc <holdingsleep>
    80002c36:	c911                	beqz	a0,80002c4a <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002c38:	4585                	li	a1,1
    80002c3a:	8526                	mv	a0,s1
    80002c3c:	436000ef          	jal	ra,80003072 <virtio_disk_rw>
}
    80002c40:	60e2                	ld	ra,24(sp)
    80002c42:	6442                	ld	s0,16(sp)
    80002c44:	64a2                	ld	s1,8(sp)
    80002c46:	6105                	addi	sp,sp,32
    80002c48:	8082                	ret
    panic("bwrite");
    80002c4a:	00004517          	auipc	a0,0x4
    80002c4e:	b7e50513          	addi	a0,a0,-1154 # 800067c8 <syscalls+0x400>
    80002c52:	a1ffd0ef          	jal	ra,80000670 <panic>

0000000080002c56 <brelse>:
// Release a locked buffer.
// Move to the head of the most-recently-used list.
// 释放一块被使用的buffer
void
brelse(struct buf *b)
{
    80002c56:	1101                	addi	sp,sp,-32
    80002c58:	ec06                	sd	ra,24(sp)
    80002c5a:	e822                	sd	s0,16(sp)
    80002c5c:	e426                	sd	s1,8(sp)
    80002c5e:	e04a                	sd	s2,0(sp)
    80002c60:	1000                	addi	s0,sp,32
    80002c62:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002c64:	01050913          	addi	s2,a0,16
    80002c68:	854a                	mv	a0,s2
    80002c6a:	192000ef          	jal	ra,80002dfc <holdingsleep>
    80002c6e:	c13d                	beqz	a0,80002cd4 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    80002c70:	854a                	mv	a0,s2
    80002c72:	152000ef          	jal	ra,80002dc4 <releasesleep>

  acquire(&bcache.lock);
    80002c76:	00011517          	auipc	a0,0x11
    80002c7a:	d1a50513          	addi	a0,a0,-742 # 80013990 <bcache>
    80002c7e:	f30fe0ef          	jal	ra,800013ae <acquire>
  b->refcnt--;
    80002c82:	40bc                	lw	a5,64(s1)
    80002c84:	37fd                	addiw	a5,a5,-1
    80002c86:	0007871b          	sext.w	a4,a5
    80002c8a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002c8c:	eb05                	bnez	a4,80002cbc <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002c8e:	68bc                	ld	a5,80(s1)
    80002c90:	64b8                	ld	a4,72(s1)
    80002c92:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002c94:	64bc                	ld	a5,72(s1)
    80002c96:	68b8                	ld	a4,80(s1)
    80002c98:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002c9a:	00019797          	auipc	a5,0x19
    80002c9e:	cf678793          	addi	a5,a5,-778 # 8001b990 <bcache+0x8000>
    80002ca2:	2b87b703          	ld	a4,696(a5)
    80002ca6:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002ca8:	00019717          	auipc	a4,0x19
    80002cac:	f5070713          	addi	a4,a4,-176 # 8001bbf8 <bcache+0x8268>
    80002cb0:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002cb2:	2b87b703          	ld	a4,696(a5)
    80002cb6:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002cb8:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002cbc:	00011517          	auipc	a0,0x11
    80002cc0:	cd450513          	addi	a0,a0,-812 # 80013990 <bcache>
    80002cc4:	f82fe0ef          	jal	ra,80001446 <release>
}
    80002cc8:	60e2                	ld	ra,24(sp)
    80002cca:	6442                	ld	s0,16(sp)
    80002ccc:	64a2                	ld	s1,8(sp)
    80002cce:	6902                	ld	s2,0(sp)
    80002cd0:	6105                	addi	sp,sp,32
    80002cd2:	8082                	ret
    panic("brelse");
    80002cd4:	00004517          	auipc	a0,0x4
    80002cd8:	afc50513          	addi	a0,a0,-1284 # 800067d0 <syscalls+0x408>
    80002cdc:	995fd0ef          	jal	ra,80000670 <panic>

0000000080002ce0 <bpin>:

void
bpin(struct buf *b) {
    80002ce0:	1101                	addi	sp,sp,-32
    80002ce2:	ec06                	sd	ra,24(sp)
    80002ce4:	e822                	sd	s0,16(sp)
    80002ce6:	e426                	sd	s1,8(sp)
    80002ce8:	1000                	addi	s0,sp,32
    80002cea:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002cec:	00011517          	auipc	a0,0x11
    80002cf0:	ca450513          	addi	a0,a0,-860 # 80013990 <bcache>
    80002cf4:	ebafe0ef          	jal	ra,800013ae <acquire>
  b->refcnt++;
    80002cf8:	40bc                	lw	a5,64(s1)
    80002cfa:	2785                	addiw	a5,a5,1
    80002cfc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002cfe:	00011517          	auipc	a0,0x11
    80002d02:	c9250513          	addi	a0,a0,-878 # 80013990 <bcache>
    80002d06:	f40fe0ef          	jal	ra,80001446 <release>
}
    80002d0a:	60e2                	ld	ra,24(sp)
    80002d0c:	6442                	ld	s0,16(sp)
    80002d0e:	64a2                	ld	s1,8(sp)
    80002d10:	6105                	addi	sp,sp,32
    80002d12:	8082                	ret

0000000080002d14 <bunpin>:

void
bunpin(struct buf *b) {
    80002d14:	1101                	addi	sp,sp,-32
    80002d16:	ec06                	sd	ra,24(sp)
    80002d18:	e822                	sd	s0,16(sp)
    80002d1a:	e426                	sd	s1,8(sp)
    80002d1c:	1000                	addi	s0,sp,32
    80002d1e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d20:	00011517          	auipc	a0,0x11
    80002d24:	c7050513          	addi	a0,a0,-912 # 80013990 <bcache>
    80002d28:	e86fe0ef          	jal	ra,800013ae <acquire>
  b->refcnt--;
    80002d2c:	40bc                	lw	a5,64(s1)
    80002d2e:	37fd                	addiw	a5,a5,-1
    80002d30:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d32:	00011517          	auipc	a0,0x11
    80002d36:	c5e50513          	addi	a0,a0,-930 # 80013990 <bcache>
    80002d3a:	f0cfe0ef          	jal	ra,80001446 <release>
}
    80002d3e:	60e2                	ld	ra,24(sp)
    80002d40:	6442                	ld	s0,16(sp)
    80002d42:	64a2                	ld	s1,8(sp)
    80002d44:	6105                	addi	sp,sp,32
    80002d46:	8082                	ret

0000000080002d48 <initsleeplock>:
// 文件直接使用了xv6标准文件，应该没有错误 //
//////////////////////////////////////////

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80002d48:	1101                	addi	sp,sp,-32
    80002d4a:	ec06                	sd	ra,24(sp)
    80002d4c:	e822                	sd	s0,16(sp)
    80002d4e:	e426                	sd	s1,8(sp)
    80002d50:	e04a                	sd	s2,0(sp)
    80002d52:	1000                	addi	s0,sp,32
    80002d54:	84aa                	mv	s1,a0
    80002d56:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80002d58:	00004597          	auipc	a1,0x4
    80002d5c:	a8058593          	addi	a1,a1,-1408 # 800067d8 <syscalls+0x410>
    80002d60:	0521                	addi	a0,a0,8
    80002d62:	dccfe0ef          	jal	ra,8000132e <initlock>
  lk->name = name;
    80002d66:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80002d6a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80002d6e:	0204a423          	sw	zero,40(s1)
}
    80002d72:	60e2                	ld	ra,24(sp)
    80002d74:	6442                	ld	s0,16(sp)
    80002d76:	64a2                	ld	s1,8(sp)
    80002d78:	6902                	ld	s2,0(sp)
    80002d7a:	6105                	addi	sp,sp,32
    80002d7c:	8082                	ret

0000000080002d7e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80002d7e:	1101                	addi	sp,sp,-32
    80002d80:	ec06                	sd	ra,24(sp)
    80002d82:	e822                	sd	s0,16(sp)
    80002d84:	e426                	sd	s1,8(sp)
    80002d86:	e04a                	sd	s2,0(sp)
    80002d88:	1000                	addi	s0,sp,32
    80002d8a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80002d8c:	00850913          	addi	s2,a0,8
    80002d90:	854a                	mv	a0,s2
    80002d92:	e1cfe0ef          	jal	ra,800013ae <acquire>
  while (lk->locked) {
    80002d96:	409c                	lw	a5,0(s1)
    80002d98:	c799                	beqz	a5,80002da6 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80002d9a:	85ca                	mv	a1,s2
    80002d9c:	8526                	mv	a0,s1
    80002d9e:	9c4fe0ef          	jal	ra,80000f62 <sleep>
  while (lk->locked) {
    80002da2:	409c                	lw	a5,0(s1)
    80002da4:	fbfd                	bnez	a5,80002d9a <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80002da6:	4785                	li	a5,1
    80002da8:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80002daa:	a8dfd0ef          	jal	ra,80000836 <myproc>
    80002dae:	591c                	lw	a5,48(a0)
    80002db0:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80002db2:	854a                	mv	a0,s2
    80002db4:	e92fe0ef          	jal	ra,80001446 <release>
}
    80002db8:	60e2                	ld	ra,24(sp)
    80002dba:	6442                	ld	s0,16(sp)
    80002dbc:	64a2                	ld	s1,8(sp)
    80002dbe:	6902                	ld	s2,0(sp)
    80002dc0:	6105                	addi	sp,sp,32
    80002dc2:	8082                	ret

0000000080002dc4 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80002dc4:	1101                	addi	sp,sp,-32
    80002dc6:	ec06                	sd	ra,24(sp)
    80002dc8:	e822                	sd	s0,16(sp)
    80002dca:	e426                	sd	s1,8(sp)
    80002dcc:	e04a                	sd	s2,0(sp)
    80002dce:	1000                	addi	s0,sp,32
    80002dd0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80002dd2:	00850913          	addi	s2,a0,8
    80002dd6:	854a                	mv	a0,s2
    80002dd8:	dd6fe0ef          	jal	ra,800013ae <acquire>
  lk->locked = 0;
    80002ddc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80002de0:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80002de4:	8526                	mv	a0,s1
    80002de6:	9c8fe0ef          	jal	ra,80000fae <wakeup>
  release(&lk->lk);
    80002dea:	854a                	mv	a0,s2
    80002dec:	e5afe0ef          	jal	ra,80001446 <release>
}
    80002df0:	60e2                	ld	ra,24(sp)
    80002df2:	6442                	ld	s0,16(sp)
    80002df4:	64a2                	ld	s1,8(sp)
    80002df6:	6902                	ld	s2,0(sp)
    80002df8:	6105                	addi	sp,sp,32
    80002dfa:	8082                	ret

0000000080002dfc <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80002dfc:	7179                	addi	sp,sp,-48
    80002dfe:	f406                	sd	ra,40(sp)
    80002e00:	f022                	sd	s0,32(sp)
    80002e02:	ec26                	sd	s1,24(sp)
    80002e04:	e84a                	sd	s2,16(sp)
    80002e06:	e44e                	sd	s3,8(sp)
    80002e08:	1800                	addi	s0,sp,48
    80002e0a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80002e0c:	00850913          	addi	s2,a0,8
    80002e10:	854a                	mv	a0,s2
    80002e12:	d9cfe0ef          	jal	ra,800013ae <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80002e16:	409c                	lw	a5,0(s1)
    80002e18:	ef89                	bnez	a5,80002e32 <holdingsleep+0x36>
    80002e1a:	4481                	li	s1,0
  release(&lk->lk);
    80002e1c:	854a                	mv	a0,s2
    80002e1e:	e28fe0ef          	jal	ra,80001446 <release>
  return r;
}
    80002e22:	8526                	mv	a0,s1
    80002e24:	70a2                	ld	ra,40(sp)
    80002e26:	7402                	ld	s0,32(sp)
    80002e28:	64e2                	ld	s1,24(sp)
    80002e2a:	6942                	ld	s2,16(sp)
    80002e2c:	69a2                	ld	s3,8(sp)
    80002e2e:	6145                	addi	sp,sp,48
    80002e30:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80002e32:	0284a983          	lw	s3,40(s1)
    80002e36:	a01fd0ef          	jal	ra,80000836 <myproc>
    80002e3a:	5904                	lw	s1,48(a0)
    80002e3c:	413484b3          	sub	s1,s1,s3
    80002e40:	0014b493          	seqz	s1,s1
    80002e44:	bfe1                	j	80002e1c <holdingsleep+0x20>

0000000080002e46 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80002e46:	1141                	addi	sp,sp,-16
    80002e48:	e406                	sd	ra,8(sp)
    80002e4a:	e022                	sd	s0,0(sp)
    80002e4c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80002e4e:	479d                	li	a5,7
    80002e50:	04a7ca63          	blt	a5,a0,80002ea4 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80002e54:	00019797          	auipc	a5,0x19
    80002e58:	1fc78793          	addi	a5,a5,508 # 8001c050 <disk>
    80002e5c:	97aa                	add	a5,a5,a0
    80002e5e:	0187c783          	lbu	a5,24(a5)
    80002e62:	e7b9                	bnez	a5,80002eb0 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80002e64:	00451693          	slli	a3,a0,0x4
    80002e68:	00019797          	auipc	a5,0x19
    80002e6c:	1e878793          	addi	a5,a5,488 # 8001c050 <disk>
    80002e70:	6398                	ld	a4,0(a5)
    80002e72:	9736                	add	a4,a4,a3
    80002e74:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80002e78:	6398                	ld	a4,0(a5)
    80002e7a:	9736                	add	a4,a4,a3
    80002e7c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80002e80:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80002e84:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80002e88:	97aa                	add	a5,a5,a0
    80002e8a:	4705                	li	a4,1
    80002e8c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80002e90:	00019517          	auipc	a0,0x19
    80002e94:	1d850513          	addi	a0,a0,472 # 8001c068 <disk+0x18>
    80002e98:	916fe0ef          	jal	ra,80000fae <wakeup>
}
    80002e9c:	60a2                	ld	ra,8(sp)
    80002e9e:	6402                	ld	s0,0(sp)
    80002ea0:	0141                	addi	sp,sp,16
    80002ea2:	8082                	ret
    panic("free_desc 1");
    80002ea4:	00004517          	auipc	a0,0x4
    80002ea8:	94450513          	addi	a0,a0,-1724 # 800067e8 <syscalls+0x420>
    80002eac:	fc4fd0ef          	jal	ra,80000670 <panic>
    panic("free_desc 2");
    80002eb0:	00004517          	auipc	a0,0x4
    80002eb4:	94850513          	addi	a0,a0,-1720 # 800067f8 <syscalls+0x430>
    80002eb8:	fb8fd0ef          	jal	ra,80000670 <panic>

0000000080002ebc <virtio_disk_init>:
{
    80002ebc:	1101                	addi	sp,sp,-32
    80002ebe:	ec06                	sd	ra,24(sp)
    80002ec0:	e822                	sd	s0,16(sp)
    80002ec2:	e426                	sd	s1,8(sp)
    80002ec4:	e04a                	sd	s2,0(sp)
    80002ec6:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80002ec8:	00004597          	auipc	a1,0x4
    80002ecc:	94058593          	addi	a1,a1,-1728 # 80006808 <syscalls+0x440>
    80002ed0:	00019517          	auipc	a0,0x19
    80002ed4:	2a850513          	addi	a0,a0,680 # 8001c178 <disk+0x128>
    80002ed8:	c56fe0ef          	jal	ra,8000132e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80002edc:	100017b7          	lui	a5,0x10001
    80002ee0:	4398                	lw	a4,0(a5)
    80002ee2:	2701                	sext.w	a4,a4
    80002ee4:	747277b7          	lui	a5,0x74727
    80002ee8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80002eec:	12f71f63          	bne	a4,a5,8000302a <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80002ef0:	100017b7          	lui	a5,0x10001
    80002ef4:	43dc                	lw	a5,4(a5)
    80002ef6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80002ef8:	4709                	li	a4,2
    80002efa:	12e79863          	bne	a5,a4,8000302a <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80002efe:	100017b7          	lui	a5,0x10001
    80002f02:	479c                	lw	a5,8(a5)
    80002f04:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80002f06:	12e79263          	bne	a5,a4,8000302a <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80002f0a:	100017b7          	lui	a5,0x10001
    80002f0e:	47d8                	lw	a4,12(a5)
    80002f10:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80002f12:	554d47b7          	lui	a5,0x554d4
    80002f16:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80002f1a:	10f71863          	bne	a4,a5,8000302a <virtio_disk_init+0x16e>
  *R(VIRTIO_MMIO_STATUS) = status;
    80002f1e:	100017b7          	lui	a5,0x10001
    80002f22:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80002f26:	4705                	li	a4,1
    80002f28:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80002f2a:	470d                	li	a4,3
    80002f2c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80002f2e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80002f30:	c7ffe6b7          	lui	a3,0xc7ffe
    80002f34:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fe0a5f>
    80002f38:	8f75                	and	a4,a4,a3
    80002f3a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80002f3c:	472d                	li	a4,11
    80002f3e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80002f40:	5bbc                	lw	a5,112(a5)
    80002f42:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80002f46:	8ba1                	andi	a5,a5,8
    80002f48:	0e078763          	beqz	a5,80003036 <virtio_disk_init+0x17a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80002f4c:	100017b7          	lui	a5,0x10001
    80002f50:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80002f54:	43fc                	lw	a5,68(a5)
    80002f56:	2781                	sext.w	a5,a5
    80002f58:	0e079563          	bnez	a5,80003042 <virtio_disk_init+0x186>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80002f5c:	100017b7          	lui	a5,0x10001
    80002f60:	5bdc                	lw	a5,52(a5)
    80002f62:	2781                	sext.w	a5,a5
  if(max == 0)
    80002f64:	0e078563          	beqz	a5,8000304e <virtio_disk_init+0x192>
  if(max < NUM)
    80002f68:	471d                	li	a4,7
    80002f6a:	0ef77863          	bgeu	a4,a5,8000305a <virtio_disk_init+0x19e>
  disk.desc = kalloc();
    80002f6e:	990fd0ef          	jal	ra,800000fe <kalloc>
    80002f72:	00019497          	auipc	s1,0x19
    80002f76:	0de48493          	addi	s1,s1,222 # 8001c050 <disk>
    80002f7a:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80002f7c:	982fd0ef          	jal	ra,800000fe <kalloc>
    80002f80:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80002f82:	97cfd0ef          	jal	ra,800000fe <kalloc>
    80002f86:	87aa                	mv	a5,a0
    80002f88:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80002f8a:	6088                	ld	a0,0(s1)
    80002f8c:	cd69                	beqz	a0,80003066 <virtio_disk_init+0x1aa>
    80002f8e:	00019717          	auipc	a4,0x19
    80002f92:	0ca73703          	ld	a4,202(a4) # 8001c058 <disk+0x8>
    80002f96:	cb61                	beqz	a4,80003066 <virtio_disk_init+0x1aa>
    80002f98:	c7f9                	beqz	a5,80003066 <virtio_disk_init+0x1aa>
  memset(disk.desc, 0, PGSIZE);
    80002f9a:	6605                	lui	a2,0x1
    80002f9c:	4581                	li	a1,0
    80002f9e:	d98fe0ef          	jal	ra,80001536 <memset>
  memset(disk.avail, 0, PGSIZE);
    80002fa2:	00019497          	auipc	s1,0x19
    80002fa6:	0ae48493          	addi	s1,s1,174 # 8001c050 <disk>
    80002faa:	6605                	lui	a2,0x1
    80002fac:	4581                	li	a1,0
    80002fae:	6488                	ld	a0,8(s1)
    80002fb0:	d86fe0ef          	jal	ra,80001536 <memset>
  memset(disk.used, 0, PGSIZE);
    80002fb4:	6605                	lui	a2,0x1
    80002fb6:	4581                	li	a1,0
    80002fb8:	6888                	ld	a0,16(s1)
    80002fba:	d7cfe0ef          	jal	ra,80001536 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80002fbe:	100017b7          	lui	a5,0x10001
    80002fc2:	4721                	li	a4,8
    80002fc4:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80002fc6:	4098                	lw	a4,0(s1)
    80002fc8:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80002fcc:	40d8                	lw	a4,4(s1)
    80002fce:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80002fd2:	6498                	ld	a4,8(s1)
    80002fd4:	0007069b          	sext.w	a3,a4
    80002fd8:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80002fdc:	9701                	srai	a4,a4,0x20
    80002fde:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80002fe2:	6898                	ld	a4,16(s1)
    80002fe4:	0007069b          	sext.w	a3,a4
    80002fe8:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80002fec:	9701                	srai	a4,a4,0x20
    80002fee:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80002ff2:	4705                	li	a4,1
    80002ff4:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80002ff6:	00e48c23          	sb	a4,24(s1)
    80002ffa:	00e48ca3          	sb	a4,25(s1)
    80002ffe:	00e48d23          	sb	a4,26(s1)
    80003002:	00e48da3          	sb	a4,27(s1)
    80003006:	00e48e23          	sb	a4,28(s1)
    8000300a:	00e48ea3          	sb	a4,29(s1)
    8000300e:	00e48f23          	sb	a4,30(s1)
    80003012:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80003016:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    8000301a:	0727a823          	sw	s2,112(a5)
}
    8000301e:	60e2                	ld	ra,24(sp)
    80003020:	6442                	ld	s0,16(sp)
    80003022:	64a2                	ld	s1,8(sp)
    80003024:	6902                	ld	s2,0(sp)
    80003026:	6105                	addi	sp,sp,32
    80003028:	8082                	ret
    panic("could not find virtio disk");
    8000302a:	00003517          	auipc	a0,0x3
    8000302e:	7ee50513          	addi	a0,a0,2030 # 80006818 <syscalls+0x450>
    80003032:	e3efd0ef          	jal	ra,80000670 <panic>
    panic("virtio disk FEATURES_OK unset");
    80003036:	00004517          	auipc	a0,0x4
    8000303a:	80250513          	addi	a0,a0,-2046 # 80006838 <syscalls+0x470>
    8000303e:	e32fd0ef          	jal	ra,80000670 <panic>
    panic("virtio disk should not be ready");
    80003042:	00004517          	auipc	a0,0x4
    80003046:	81650513          	addi	a0,a0,-2026 # 80006858 <syscalls+0x490>
    8000304a:	e26fd0ef          	jal	ra,80000670 <panic>
    panic("virtio disk has no queue 0");
    8000304e:	00004517          	auipc	a0,0x4
    80003052:	82a50513          	addi	a0,a0,-2006 # 80006878 <syscalls+0x4b0>
    80003056:	e1afd0ef          	jal	ra,80000670 <panic>
    panic("virtio disk max queue too short");
    8000305a:	00004517          	auipc	a0,0x4
    8000305e:	83e50513          	addi	a0,a0,-1986 # 80006898 <syscalls+0x4d0>
    80003062:	e0efd0ef          	jal	ra,80000670 <panic>
    panic("virtio disk kalloc");
    80003066:	00004517          	auipc	a0,0x4
    8000306a:	85250513          	addi	a0,a0,-1966 # 800068b8 <syscalls+0x4f0>
    8000306e:	e02fd0ef          	jal	ra,80000670 <panic>

0000000080003072 <virtio_disk_rw>:

// 这个函数比较重要，这个被bio.c中的bread,bwrite调用
// 做的事情就是将buffer结构体中的数据写入disk或读取数据到buffer
void
virtio_disk_rw(struct buf *b, int write)
{
    80003072:	7119                	addi	sp,sp,-128
    80003074:	fc86                	sd	ra,120(sp)
    80003076:	f8a2                	sd	s0,112(sp)
    80003078:	f4a6                	sd	s1,104(sp)
    8000307a:	f0ca                	sd	s2,96(sp)
    8000307c:	ecce                	sd	s3,88(sp)
    8000307e:	e8d2                	sd	s4,80(sp)
    80003080:	e4d6                	sd	s5,72(sp)
    80003082:	e0da                	sd	s6,64(sp)
    80003084:	fc5e                	sd	s7,56(sp)
    80003086:	f862                	sd	s8,48(sp)
    80003088:	f466                	sd	s9,40(sp)
    8000308a:	f06a                	sd	s10,32(sp)
    8000308c:	ec6e                	sd	s11,24(sp)
    8000308e:	0100                	addi	s0,sp,128
    80003090:	8aaa                	mv	s5,a0
    80003092:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512); 
    80003094:	00c52d03          	lw	s10,12(a0)
    80003098:	001d1d1b          	slliw	s10,s10,0x1
    8000309c:	1d02                	slli	s10,s10,0x20
    8000309e:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800030a2:	00019517          	auipc	a0,0x19
    800030a6:	0d650513          	addi	a0,a0,214 # 8001c178 <disk+0x128>
    800030aa:	b04fe0ef          	jal	ra,800013ae <acquire>
  for(int i = 0; i < 3; i++){
    800030ae:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800030b0:	44a1                	li	s1,8
      disk.free[i] = 0;
    800030b2:	00019b97          	auipc	s7,0x19
    800030b6:	f9eb8b93          	addi	s7,s7,-98 # 8001c050 <disk>
  for(int i = 0; i < 3; i++){
    800030ba:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800030bc:	00019c97          	auipc	s9,0x19
    800030c0:	0bcc8c93          	addi	s9,s9,188 # 8001c178 <disk+0x128>
    800030c4:	a8a9                	j	8000311e <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    800030c6:	00fb8733          	add	a4,s7,a5
    800030ca:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800030ce:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800030d0:	0207c563          	bltz	a5,800030fa <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800030d4:	2905                	addiw	s2,s2,1
    800030d6:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800030d8:	05690863          	beq	s2,s6,80003128 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    800030dc:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800030de:	00019717          	auipc	a4,0x19
    800030e2:	f7270713          	addi	a4,a4,-142 # 8001c050 <disk>
    800030e6:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800030e8:	01874683          	lbu	a3,24(a4)
    800030ec:	fee9                	bnez	a3,800030c6 <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    800030ee:	2785                	addiw	a5,a5,1
    800030f0:	0705                	addi	a4,a4,1
    800030f2:	fe979be3          	bne	a5,s1,800030e8 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800030f6:	57fd                	li	a5,-1
    800030f8:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800030fa:	01205b63          	blez	s2,80003110 <virtio_disk_rw+0x9e>
    800030fe:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80003100:	000a2503          	lw	a0,0(s4)
    80003104:	d43ff0ef          	jal	ra,80002e46 <free_desc>
      for(int j = 0; j < i; j++)
    80003108:	2d85                	addiw	s11,s11,1
    8000310a:	0a11                	addi	s4,s4,4
    8000310c:	ff2d9ae3          	bne	s11,s2,80003100 <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80003110:	85e6                	mv	a1,s9
    80003112:	00019517          	auipc	a0,0x19
    80003116:	f5650513          	addi	a0,a0,-170 # 8001c068 <disk+0x18>
    8000311a:	e49fd0ef          	jal	ra,80000f62 <sleep>
  for(int i = 0; i < 3; i++){
    8000311e:	f8040a13          	addi	s4,s0,-128
{
    80003122:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80003124:	894e                	mv	s2,s3
    80003126:	bf5d                	j	800030dc <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80003128:	f8042503          	lw	a0,-128(s0)
    8000312c:	00a50713          	addi	a4,a0,10
    80003130:	0712                	slli	a4,a4,0x4

  if(write)
    80003132:	00019797          	auipc	a5,0x19
    80003136:	f1e78793          	addi	a5,a5,-226 # 8001c050 <disk>
    8000313a:	00e786b3          	add	a3,a5,a4
    8000313e:	01803633          	snez	a2,s8
    80003142:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80003144:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80003148:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000314c:	f6070613          	addi	a2,a4,-160
    80003150:	6394                	ld	a3,0(a5)
    80003152:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80003154:	00870593          	addi	a1,a4,8
    80003158:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000315a:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000315c:	0007b803          	ld	a6,0(a5)
    80003160:	9642                	add	a2,a2,a6
    80003162:	46c1                	li	a3,16
    80003164:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80003166:	4585                	li	a1,1
    80003168:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    8000316c:	f8442683          	lw	a3,-124(s0)
    80003170:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80003174:	0692                	slli	a3,a3,0x4
    80003176:	9836                	add	a6,a6,a3
    80003178:	058a8613          	addi	a2,s5,88 # fffffffffffff058 <end+0xffffffff7ffe1358>
    8000317c:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80003180:	0007b803          	ld	a6,0(a5)
    80003184:	96c2                	add	a3,a3,a6
    80003186:	40000613          	li	a2,1024
    8000318a:	c690                	sw	a2,8(a3)
  if(write)
    8000318c:	001c3613          	seqz	a2,s8
    80003190:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80003194:	00166613          	ori	a2,a2,1
    80003198:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000319c:	f8842603          	lw	a2,-120(s0)
    800031a0:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800031a4:	00250693          	addi	a3,a0,2
    800031a8:	0692                	slli	a3,a3,0x4
    800031aa:	96be                	add	a3,a3,a5
    800031ac:	58fd                	li	a7,-1
    800031ae:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800031b2:	0612                	slli	a2,a2,0x4
    800031b4:	9832                	add	a6,a6,a2
    800031b6:	f9070713          	addi	a4,a4,-112
    800031ba:	973e                	add	a4,a4,a5
    800031bc:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    800031c0:	6398                	ld	a4,0(a5)
    800031c2:	9732                	add	a4,a4,a2
    800031c4:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800031c6:	4609                	li	a2,2
    800031c8:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    800031cc:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800031d0:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    800031d4:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800031d8:	6794                	ld	a3,8(a5)
    800031da:	0026d703          	lhu	a4,2(a3)
    800031de:	8b1d                	andi	a4,a4,7
    800031e0:	0706                	slli	a4,a4,0x1
    800031e2:	96ba                	add	a3,a3,a4
    800031e4:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800031e8:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800031ec:	6798                	ld	a4,8(a5)
    800031ee:	00275783          	lhu	a5,2(a4)
    800031f2:	2785                	addiw	a5,a5,1
    800031f4:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800031f8:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800031fc:	100017b7          	lui	a5,0x10001
    80003200:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80003204:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80003208:	00019917          	auipc	s2,0x19
    8000320c:	f7090913          	addi	s2,s2,-144 # 8001c178 <disk+0x128>
  while(b->disk == 1) {
    80003210:	4485                	li	s1,1
    80003212:	00b79a63          	bne	a5,a1,80003226 <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    80003216:	85ca                	mv	a1,s2
    80003218:	8556                	mv	a0,s5
    8000321a:	d49fd0ef          	jal	ra,80000f62 <sleep>
  while(b->disk == 1) {
    8000321e:	004aa783          	lw	a5,4(s5)
    80003222:	fe978ae3          	beq	a5,s1,80003216 <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    80003226:	f8042903          	lw	s2,-128(s0)
    8000322a:	00290713          	addi	a4,s2,2
    8000322e:	0712                	slli	a4,a4,0x4
    80003230:	00019797          	auipc	a5,0x19
    80003234:	e2078793          	addi	a5,a5,-480 # 8001c050 <disk>
    80003238:	97ba                	add	a5,a5,a4
    8000323a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000323e:	00019997          	auipc	s3,0x19
    80003242:	e1298993          	addi	s3,s3,-494 # 8001c050 <disk>
    80003246:	00491713          	slli	a4,s2,0x4
    8000324a:	0009b783          	ld	a5,0(s3)
    8000324e:	97ba                	add	a5,a5,a4
    80003250:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80003254:	854a                	mv	a0,s2
    80003256:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000325a:	bedff0ef          	jal	ra,80002e46 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000325e:	8885                	andi	s1,s1,1
    80003260:	f0fd                	bnez	s1,80003246 <virtio_disk_rw+0x1d4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80003262:	00019517          	auipc	a0,0x19
    80003266:	f1650513          	addi	a0,a0,-234 # 8001c178 <disk+0x128>
    8000326a:	9dcfe0ef          	jal	ra,80001446 <release>
}
    8000326e:	70e6                	ld	ra,120(sp)
    80003270:	7446                	ld	s0,112(sp)
    80003272:	74a6                	ld	s1,104(sp)
    80003274:	7906                	ld	s2,96(sp)
    80003276:	69e6                	ld	s3,88(sp)
    80003278:	6a46                	ld	s4,80(sp)
    8000327a:	6aa6                	ld	s5,72(sp)
    8000327c:	6b06                	ld	s6,64(sp)
    8000327e:	7be2                	ld	s7,56(sp)
    80003280:	7c42                	ld	s8,48(sp)
    80003282:	7ca2                	ld	s9,40(sp)
    80003284:	7d02                	ld	s10,32(sp)
    80003286:	6de2                	ld	s11,24(sp)
    80003288:	6109                	addi	sp,sp,128
    8000328a:	8082                	ret

000000008000328c <virtio_disk_intr>:
// 这个应该是对应上面的virtio_disk_rw中的sleep
// 上面发送读取信号之后buffer结构体就去sleep了，
// 这个函数应该是完成读写操作后发送一个中断唤醒相关的进程
void
virtio_disk_intr()
{
    8000328c:	1101                	addi	sp,sp,-32
    8000328e:	ec06                	sd	ra,24(sp)
    80003290:	e822                	sd	s0,16(sp)
    80003292:	e426                	sd	s1,8(sp)
    80003294:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80003296:	00019497          	auipc	s1,0x19
    8000329a:	dba48493          	addi	s1,s1,-582 # 8001c050 <disk>
    8000329e:	00019517          	auipc	a0,0x19
    800032a2:	eda50513          	addi	a0,a0,-294 # 8001c178 <disk+0x128>
    800032a6:	908fe0ef          	jal	ra,800013ae <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800032aa:	10001737          	lui	a4,0x10001
    800032ae:	533c                	lw	a5,96(a4)
    800032b0:	8b8d                	andi	a5,a5,3
    800032b2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800032b4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800032b8:	689c                	ld	a5,16(s1)
    800032ba:	0204d703          	lhu	a4,32(s1)
    800032be:	0027d783          	lhu	a5,2(a5)
    800032c2:	04f70663          	beq	a4,a5,8000330e <virtio_disk_intr+0x82>
    __sync_synchronize();
    800032c6:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800032ca:	6898                	ld	a4,16(s1)
    800032cc:	0204d783          	lhu	a5,32(s1)
    800032d0:	8b9d                	andi	a5,a5,7
    800032d2:	078e                	slli	a5,a5,0x3
    800032d4:	97ba                	add	a5,a5,a4
    800032d6:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800032d8:	00278713          	addi	a4,a5,2
    800032dc:	0712                	slli	a4,a4,0x4
    800032de:	9726                	add	a4,a4,s1
    800032e0:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800032e4:	e321                	bnez	a4,80003324 <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800032e6:	0789                	addi	a5,a5,2
    800032e8:	0792                	slli	a5,a5,0x4
    800032ea:	97a6                	add	a5,a5,s1
    800032ec:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800032ee:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800032f2:	cbdfd0ef          	jal	ra,80000fae <wakeup>

    disk.used_idx += 1;
    800032f6:	0204d783          	lhu	a5,32(s1)
    800032fa:	2785                	addiw	a5,a5,1
    800032fc:	17c2                	slli	a5,a5,0x30
    800032fe:	93c1                	srli	a5,a5,0x30
    80003300:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80003304:	6898                	ld	a4,16(s1)
    80003306:	00275703          	lhu	a4,2(a4)
    8000330a:	faf71ee3          	bne	a4,a5,800032c6 <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    8000330e:	00019517          	auipc	a0,0x19
    80003312:	e6a50513          	addi	a0,a0,-406 # 8001c178 <disk+0x128>
    80003316:	930fe0ef          	jal	ra,80001446 <release>
}
    8000331a:	60e2                	ld	ra,24(sp)
    8000331c:	6442                	ld	s0,16(sp)
    8000331e:	64a2                	ld	s1,8(sp)
    80003320:	6105                	addi	sp,sp,32
    80003322:	8082                	ret
      panic("virtio_disk_intr status");
    80003324:	00003517          	auipc	a0,0x3
    80003328:	5ac50513          	addi	a0,a0,1452 # 800068d0 <syscalls+0x508>
    8000332c:	b44fd0ef          	jal	ra,80000670 <panic>

0000000080003330 <flags2perm>:
// 还没看这个文件在干什么

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80003330:	1141                	addi	sp,sp,-16
    80003332:	e422                	sd	s0,8(sp)
    80003334:	0800                	addi	s0,sp,16
    80003336:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80003338:	8905                	andi	a0,a0,1
    8000333a:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    8000333c:	8b89                	andi	a5,a5,2
    8000333e:	c399                	beqz	a5,80003344 <flags2perm+0x14>
      perm |= PTE_W;
    80003340:	00456513          	ori	a0,a0,4
    return perm;
}
    80003344:	6422                	ld	s0,8(sp)
    80003346:	0141                	addi	sp,sp,16
    80003348:	8082                	ret

000000008000334a <exec>:

int
exec(char *path, char **argv)
{
    8000334a:	de010113          	addi	sp,sp,-544
    8000334e:	20113c23          	sd	ra,536(sp)
    80003352:	20813823          	sd	s0,528(sp)
    80003356:	20913423          	sd	s1,520(sp)
    8000335a:	21213023          	sd	s2,512(sp)
    8000335e:	ffce                	sd	s3,504(sp)
    80003360:	fbd2                	sd	s4,496(sp)
    80003362:	f7d6                	sd	s5,488(sp)
    80003364:	f3da                	sd	s6,480(sp)
    80003366:	efde                	sd	s7,472(sp)
    80003368:	ebe2                	sd	s8,464(sp)
    8000336a:	e7e6                	sd	s9,456(sp)
    8000336c:	e3ea                	sd	s10,448(sp)
    8000336e:	ff6e                	sd	s11,440(sp)
    80003370:	1400                	addi	s0,sp,544
    80003372:	892a                	mv	s2,a0
    80003374:	dea43423          	sd	a0,-536(s0)
    80003378:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000337c:	cbafd0ef          	jal	ra,80000836 <myproc>
    80003380:	84aa                	mv	s1,a0

  begin_op();
    80003382:	0ce010ef          	jal	ra,80004450 <begin_op>

  if((ip = namei(path)) == 0){
    80003386:	854a                	mv	a0,s2
    80003388:	6ed000ef          	jal	ra,80004274 <namei>
    8000338c:	c13d                	beqz	a0,800033f2 <exec+0xa8>
    8000338e:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80003390:	02f000ef          	jal	ra,80003bbe <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80003394:	04000713          	li	a4,64
    80003398:	4681                	li	a3,0
    8000339a:	e5040613          	addi	a2,s0,-432
    8000339e:	4581                	li	a1,0
    800033a0:	8556                	mv	a0,s5
    800033a2:	26d000ef          	jal	ra,80003e0e <readi>
    800033a6:	04000793          	li	a5,64
    800033aa:	00f51a63          	bne	a0,a5,800033be <exec+0x74>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800033ae:	e5042703          	lw	a4,-432(s0)
    800033b2:	464c47b7          	lui	a5,0x464c4
    800033b6:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800033ba:	04f70063          	beq	a4,a5,800033fa <exec+0xb0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800033be:	8556                	mv	a0,s5
    800033c0:	205000ef          	jal	ra,80003dc4 <iunlockput>
    end_op();
    800033c4:	0fa010ef          	jal	ra,800044be <end_op>
  }
  return -1;
    800033c8:	557d                	li	a0,-1
}
    800033ca:	21813083          	ld	ra,536(sp)
    800033ce:	21013403          	ld	s0,528(sp)
    800033d2:	20813483          	ld	s1,520(sp)
    800033d6:	20013903          	ld	s2,512(sp)
    800033da:	79fe                	ld	s3,504(sp)
    800033dc:	7a5e                	ld	s4,496(sp)
    800033de:	7abe                	ld	s5,488(sp)
    800033e0:	7b1e                	ld	s6,480(sp)
    800033e2:	6bfe                	ld	s7,472(sp)
    800033e4:	6c5e                	ld	s8,464(sp)
    800033e6:	6cbe                	ld	s9,456(sp)
    800033e8:	6d1e                	ld	s10,448(sp)
    800033ea:	7dfa                	ld	s11,440(sp)
    800033ec:	22010113          	addi	sp,sp,544
    800033f0:	8082                	ret
    end_op();
    800033f2:	0cc010ef          	jal	ra,800044be <end_op>
    return -1;
    800033f6:	557d                	li	a0,-1
    800033f8:	bfc9                	j	800033ca <exec+0x80>
  if((pagetable = proc_pagetable(p)) == 0)
    800033fa:	8526                	mv	a0,s1
    800033fc:	ce2fd0ef          	jal	ra,800008de <proc_pagetable>
    80003400:	8b2a                	mv	s6,a0
    80003402:	dd55                	beqz	a0,800033be <exec+0x74>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003404:	e7042783          	lw	a5,-400(s0)
    80003408:	e8845703          	lhu	a4,-376(s0)
    8000340c:	c325                	beqz	a4,8000346c <exec+0x122>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000340e:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003410:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80003414:	6a05                	lui	s4,0x1
    80003416:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    8000341a:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    8000341e:	6d85                	lui	s11,0x1
    80003420:	7d7d                	lui	s10,0xfffff
    80003422:	a409                	j	80003624 <exec+0x2da>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80003424:	00003517          	auipc	a0,0x3
    80003428:	4c450513          	addi	a0,a0,1220 # 800068e8 <syscalls+0x520>
    8000342c:	a44fd0ef          	jal	ra,80000670 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80003430:	874a                	mv	a4,s2
    80003432:	009c86bb          	addw	a3,s9,s1
    80003436:	4581                	li	a1,0
    80003438:	8556                	mv	a0,s5
    8000343a:	1d5000ef          	jal	ra,80003e0e <readi>
    8000343e:	2501                	sext.w	a0,a0
    80003440:	18a91163          	bne	s2,a0,800035c2 <exec+0x278>
  for(i = 0; i < sz; i += PGSIZE){
    80003444:	009d84bb          	addw	s1,s11,s1
    80003448:	013d09bb          	addw	s3,s10,s3
    8000344c:	1b74fc63          	bgeu	s1,s7,80003604 <exec+0x2ba>
    pa = walkaddr(pagetable, va + i);
    80003450:	02049593          	slli	a1,s1,0x20
    80003454:	9181                	srli	a1,a1,0x20
    80003456:	95e2                	add	a1,a1,s8
    80003458:	855a                	mv	a0,s6
    8000345a:	ec9fe0ef          	jal	ra,80002322 <walkaddr>
    8000345e:	862a                	mv	a2,a0
    if(pa == 0)
    80003460:	d171                	beqz	a0,80003424 <exec+0xda>
      n = PGSIZE;
    80003462:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80003464:	fd49f6e3          	bgeu	s3,s4,80003430 <exec+0xe6>
      n = sz - i;
    80003468:	894e                	mv	s2,s3
    8000346a:	b7d9                	j	80003430 <exec+0xe6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000346c:	4901                	li	s2,0
  iunlockput(ip);
    8000346e:	8556                	mv	a0,s5
    80003470:	155000ef          	jal	ra,80003dc4 <iunlockput>
  end_op();
    80003474:	04a010ef          	jal	ra,800044be <end_op>
  p = myproc();
    80003478:	bbefd0ef          	jal	ra,80000836 <myproc>
    8000347c:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    8000347e:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80003482:	6785                	lui	a5,0x1
    80003484:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80003486:	97ca                	add	a5,a5,s2
    80003488:	777d                	lui	a4,0xfffff
    8000348a:	8ff9                	and	a5,a5,a4
    8000348c:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003490:	4691                	li	a3,4
    80003492:	6609                	lui	a2,0x2
    80003494:	963e                	add	a2,a2,a5
    80003496:	85be                	mv	a1,a5
    80003498:	855a                	mv	a0,s6
    8000349a:	9e0ff0ef          	jal	ra,8000267a <uvmalloc>
    8000349e:	8c2a                	mv	s8,a0
  ip = 0;
    800034a0:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800034a2:	12050063          	beqz	a0,800035c2 <exec+0x278>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800034a6:	75f9                	lui	a1,0xffffe
    800034a8:	95aa                	add	a1,a1,a0
    800034aa:	855a                	mv	a0,s6
    800034ac:	bacff0ef          	jal	ra,80002858 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800034b0:	7afd                	lui	s5,0xfffff
    800034b2:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800034b4:	df043783          	ld	a5,-528(s0)
    800034b8:	6388                	ld	a0,0(a5)
    800034ba:	c135                	beqz	a0,8000351e <exec+0x1d4>
    800034bc:	e9040993          	addi	s3,s0,-368
    800034c0:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800034c4:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800034c6:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800034c8:	9e6fe0ef          	jal	ra,800016ae <strlen>
    800034cc:	0015079b          	addiw	a5,a0,1
    800034d0:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800034d4:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800034d8:	11596a63          	bltu	s2,s5,800035ec <exec+0x2a2>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800034dc:	df043d83          	ld	s11,-528(s0)
    800034e0:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800034e4:	8552                	mv	a0,s4
    800034e6:	9c8fe0ef          	jal	ra,800016ae <strlen>
    800034ea:	0015069b          	addiw	a3,a0,1
    800034ee:	8652                	mv	a2,s4
    800034f0:	85ca                	mv	a1,s2
    800034f2:	855a                	mv	a0,s6
    800034f4:	b8eff0ef          	jal	ra,80002882 <copyout>
    800034f8:	0e054e63          	bltz	a0,800035f4 <exec+0x2aa>
    ustack[argc] = sp;
    800034fc:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80003500:	0485                	addi	s1,s1,1
    80003502:	008d8793          	addi	a5,s11,8
    80003506:	def43823          	sd	a5,-528(s0)
    8000350a:	008db503          	ld	a0,8(s11)
    8000350e:	c911                	beqz	a0,80003522 <exec+0x1d8>
    if(argc >= MAXARG)
    80003510:	09a1                	addi	s3,s3,8
    80003512:	fb3c9be3          	bne	s9,s3,800034c8 <exec+0x17e>
  sz = sz1;
    80003516:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000351a:	4a81                	li	s5,0
    8000351c:	a05d                	j	800035c2 <exec+0x278>
  sp = sz;
    8000351e:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80003520:	4481                	li	s1,0
  ustack[argc] = 0;
    80003522:	00349793          	slli	a5,s1,0x3
    80003526:	f9078793          	addi	a5,a5,-112
    8000352a:	97a2                	add	a5,a5,s0
    8000352c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80003530:	00148693          	addi	a3,s1,1
    80003534:	068e                	slli	a3,a3,0x3
    80003536:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000353a:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    8000353e:	01597663          	bgeu	s2,s5,8000354a <exec+0x200>
  sz = sz1;
    80003542:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003546:	4a81                	li	s5,0
    80003548:	a8ad                	j	800035c2 <exec+0x278>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000354a:	e9040613          	addi	a2,s0,-368
    8000354e:	85ca                	mv	a1,s2
    80003550:	855a                	mv	a0,s6
    80003552:	b30ff0ef          	jal	ra,80002882 <copyout>
    80003556:	0a054363          	bltz	a0,800035fc <exec+0x2b2>
  p->trapframe->a1 = sp;
    8000355a:	058bb783          	ld	a5,88(s7)
    8000355e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80003562:	de843783          	ld	a5,-536(s0)
    80003566:	0007c703          	lbu	a4,0(a5)
    8000356a:	cf11                	beqz	a4,80003586 <exec+0x23c>
    8000356c:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000356e:	02f00693          	li	a3,47
    80003572:	a039                	j	80003580 <exec+0x236>
      last = s+1;
    80003574:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80003578:	0785                	addi	a5,a5,1
    8000357a:	fff7c703          	lbu	a4,-1(a5)
    8000357e:	c701                	beqz	a4,80003586 <exec+0x23c>
    if(*s == '/')
    80003580:	fed71ce3          	bne	a4,a3,80003578 <exec+0x22e>
    80003584:	bfc5                	j	80003574 <exec+0x22a>
  safestrcpy(p->name, last, sizeof(p->name));
    80003586:	4641                	li	a2,16
    80003588:	de843583          	ld	a1,-536(s0)
    8000358c:	0d8b8513          	addi	a0,s7,216
    80003590:	8ecfe0ef          	jal	ra,8000167c <safestrcpy>
  oldpagetable = p->pagetable;
    80003594:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80003598:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    8000359c:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800035a0:	058bb783          	ld	a5,88(s7)
    800035a4:	e6843703          	ld	a4,-408(s0)
    800035a8:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800035aa:	058bb783          	ld	a5,88(s7)
    800035ae:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800035b2:	85ea                	mv	a1,s10
    800035b4:	baefd0ef          	jal	ra,80000962 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800035b8:	0004851b          	sext.w	a0,s1
    800035bc:	b539                	j	800033ca <exec+0x80>
    800035be:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800035c2:	df843583          	ld	a1,-520(s0)
    800035c6:	855a                	mv	a0,s6
    800035c8:	b9afd0ef          	jal	ra,80000962 <proc_freepagetable>
  if(ip){
    800035cc:	de0a99e3          	bnez	s5,800033be <exec+0x74>
  return -1;
    800035d0:	557d                	li	a0,-1
    800035d2:	bbe5                	j	800033ca <exec+0x80>
    800035d4:	df243c23          	sd	s2,-520(s0)
    800035d8:	b7ed                	j	800035c2 <exec+0x278>
    800035da:	df243c23          	sd	s2,-520(s0)
    800035de:	b7d5                	j	800035c2 <exec+0x278>
    800035e0:	df243c23          	sd	s2,-520(s0)
    800035e4:	bff9                	j	800035c2 <exec+0x278>
    800035e6:	df243c23          	sd	s2,-520(s0)
    800035ea:	bfe1                	j	800035c2 <exec+0x278>
  sz = sz1;
    800035ec:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800035f0:	4a81                	li	s5,0
    800035f2:	bfc1                	j	800035c2 <exec+0x278>
  sz = sz1;
    800035f4:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800035f8:	4a81                	li	s5,0
    800035fa:	b7e1                	j	800035c2 <exec+0x278>
  sz = sz1;
    800035fc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80003600:	4a81                	li	s5,0
    80003602:	b7c1                	j	800035c2 <exec+0x278>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80003604:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003608:	e0843783          	ld	a5,-504(s0)
    8000360c:	0017869b          	addiw	a3,a5,1
    80003610:	e0d43423          	sd	a3,-504(s0)
    80003614:	e0043783          	ld	a5,-512(s0)
    80003618:	0387879b          	addiw	a5,a5,56
    8000361c:	e8845703          	lhu	a4,-376(s0)
    80003620:	e4e6d7e3          	bge	a3,a4,8000346e <exec+0x124>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80003624:	2781                	sext.w	a5,a5
    80003626:	e0f43023          	sd	a5,-512(s0)
    8000362a:	03800713          	li	a4,56
    8000362e:	86be                	mv	a3,a5
    80003630:	e1840613          	addi	a2,s0,-488
    80003634:	4581                	li	a1,0
    80003636:	8556                	mv	a0,s5
    80003638:	7d6000ef          	jal	ra,80003e0e <readi>
    8000363c:	03800793          	li	a5,56
    80003640:	f6f51fe3          	bne	a0,a5,800035be <exec+0x274>
    if(ph.type != ELF_PROG_LOAD)
    80003644:	e1842783          	lw	a5,-488(s0)
    80003648:	4705                	li	a4,1
    8000364a:	fae79fe3          	bne	a5,a4,80003608 <exec+0x2be>
    if(ph.memsz < ph.filesz)
    8000364e:	e4043483          	ld	s1,-448(s0)
    80003652:	e3843783          	ld	a5,-456(s0)
    80003656:	f6f4efe3          	bltu	s1,a5,800035d4 <exec+0x28a>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000365a:	e2843783          	ld	a5,-472(s0)
    8000365e:	94be                	add	s1,s1,a5
    80003660:	f6f4ede3          	bltu	s1,a5,800035da <exec+0x290>
    if(ph.vaddr % PGSIZE != 0)
    80003664:	de043703          	ld	a4,-544(s0)
    80003668:	8ff9                	and	a5,a5,a4
    8000366a:	fbbd                	bnez	a5,800035e0 <exec+0x296>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000366c:	e1c42503          	lw	a0,-484(s0)
    80003670:	cc1ff0ef          	jal	ra,80003330 <flags2perm>
    80003674:	86aa                	mv	a3,a0
    80003676:	8626                	mv	a2,s1
    80003678:	85ca                	mv	a1,s2
    8000367a:	855a                	mv	a0,s6
    8000367c:	ffffe0ef          	jal	ra,8000267a <uvmalloc>
    80003680:	dea43c23          	sd	a0,-520(s0)
    80003684:	d12d                	beqz	a0,800035e6 <exec+0x29c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80003686:	e2843c03          	ld	s8,-472(s0)
    8000368a:	e2042c83          	lw	s9,-480(s0)
    8000368e:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80003692:	f60b89e3          	beqz	s7,80003604 <exec+0x2ba>
    80003696:	89de                	mv	s3,s7
    80003698:	4481                	li	s1,0
    8000369a:	bb5d                	j	80003450 <exec+0x106>

000000008000369c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000369c:	1101                	addi	sp,sp,-32
    8000369e:	ec06                	sd	ra,24(sp)
    800036a0:	e822                	sd	s0,16(sp)
    800036a2:	e426                	sd	s1,8(sp)
    800036a4:	e04a                	sd	s2,0(sp)
    800036a6:	1000                	addi	s0,sp,32
    800036a8:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800036aa:	00d5d59b          	srliw	a1,a1,0xd
    800036ae:	00019797          	auipc	a5,0x19
    800036b2:	afe7a783          	lw	a5,-1282(a5) # 8001c1ac <sb+0x1c>
    800036b6:	9dbd                	addw	a1,a1,a5
    800036b8:	c96ff0ef          	jal	ra,80002b4e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800036bc:	0074f713          	andi	a4,s1,7
    800036c0:	4785                	li	a5,1
    800036c2:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800036c6:	14ce                	slli	s1,s1,0x33
    800036c8:	90d9                	srli	s1,s1,0x36
    800036ca:	00950733          	add	a4,a0,s1
    800036ce:	05874703          	lbu	a4,88(a4) # fffffffffffff058 <end+0xffffffff7ffe1358>
    800036d2:	00e7f6b3          	and	a3,a5,a4
    800036d6:	c29d                	beqz	a3,800036fc <bfree+0x60>
    800036d8:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800036da:	94aa                	add	s1,s1,a0
    800036dc:	fff7c793          	not	a5,a5
    800036e0:	8f7d                	and	a4,a4,a5
    800036e2:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800036e6:	6ed000ef          	jal	ra,800045d2 <log_write>
  brelse(bp);
    800036ea:	854a                	mv	a0,s2
    800036ec:	d6aff0ef          	jal	ra,80002c56 <brelse>
}
    800036f0:	60e2                	ld	ra,24(sp)
    800036f2:	6442                	ld	s0,16(sp)
    800036f4:	64a2                	ld	s1,8(sp)
    800036f6:	6902                	ld	s2,0(sp)
    800036f8:	6105                	addi	sp,sp,32
    800036fa:	8082                	ret
    panic("freeing free block");
    800036fc:	00003517          	auipc	a0,0x3
    80003700:	20c50513          	addi	a0,a0,524 # 80006908 <syscalls+0x540>
    80003704:	f6dfc0ef          	jal	ra,80000670 <panic>

0000000080003708 <balloc>:
{
    80003708:	711d                	addi	sp,sp,-96
    8000370a:	ec86                	sd	ra,88(sp)
    8000370c:	e8a2                	sd	s0,80(sp)
    8000370e:	e4a6                	sd	s1,72(sp)
    80003710:	e0ca                	sd	s2,64(sp)
    80003712:	fc4e                	sd	s3,56(sp)
    80003714:	f852                	sd	s4,48(sp)
    80003716:	f456                	sd	s5,40(sp)
    80003718:	f05a                	sd	s6,32(sp)
    8000371a:	ec5e                	sd	s7,24(sp)
    8000371c:	e862                	sd	s8,16(sp)
    8000371e:	e466                	sd	s9,8(sp)
    80003720:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003722:	00019797          	auipc	a5,0x19
    80003726:	a727a783          	lw	a5,-1422(a5) # 8001c194 <sb+0x4>
    8000372a:	cff1                	beqz	a5,80003806 <balloc+0xfe>
    8000372c:	8baa                	mv	s7,a0
    8000372e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003730:	00019b17          	auipc	s6,0x19
    80003734:	a60b0b13          	addi	s6,s6,-1440 # 8001c190 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003738:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000373a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000373c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000373e:	6c89                	lui	s9,0x2
    80003740:	a0b5                	j	800037ac <balloc+0xa4>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003742:	97ca                	add	a5,a5,s2
    80003744:	8e55                	or	a2,a2,a3
    80003746:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000374a:	854a                	mv	a0,s2
    8000374c:	687000ef          	jal	ra,800045d2 <log_write>
        brelse(bp);
    80003750:	854a                	mv	a0,s2
    80003752:	d04ff0ef          	jal	ra,80002c56 <brelse>
  bp = bread(dev, bno);
    80003756:	85a6                	mv	a1,s1
    80003758:	855e                	mv	a0,s7
    8000375a:	bf4ff0ef          	jal	ra,80002b4e <bread>
    8000375e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003760:	40000613          	li	a2,1024
    80003764:	4581                	li	a1,0
    80003766:	05850513          	addi	a0,a0,88
    8000376a:	dcdfd0ef          	jal	ra,80001536 <memset>
  log_write(bp);
    8000376e:	854a                	mv	a0,s2
    80003770:	663000ef          	jal	ra,800045d2 <log_write>
  brelse(bp);
    80003774:	854a                	mv	a0,s2
    80003776:	ce0ff0ef          	jal	ra,80002c56 <brelse>
}
    8000377a:	8526                	mv	a0,s1
    8000377c:	60e6                	ld	ra,88(sp)
    8000377e:	6446                	ld	s0,80(sp)
    80003780:	64a6                	ld	s1,72(sp)
    80003782:	6906                	ld	s2,64(sp)
    80003784:	79e2                	ld	s3,56(sp)
    80003786:	7a42                	ld	s4,48(sp)
    80003788:	7aa2                	ld	s5,40(sp)
    8000378a:	7b02                	ld	s6,32(sp)
    8000378c:	6be2                	ld	s7,24(sp)
    8000378e:	6c42                	ld	s8,16(sp)
    80003790:	6ca2                	ld	s9,8(sp)
    80003792:	6125                	addi	sp,sp,96
    80003794:	8082                	ret
    brelse(bp);
    80003796:	854a                	mv	a0,s2
    80003798:	cbeff0ef          	jal	ra,80002c56 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000379c:	015c87bb          	addw	a5,s9,s5
    800037a0:	00078a9b          	sext.w	s5,a5
    800037a4:	004b2703          	lw	a4,4(s6)
    800037a8:	04eaff63          	bgeu	s5,a4,80003806 <balloc+0xfe>
    bp = bread(dev, BBLOCK(b, sb));
    800037ac:	41fad79b          	sraiw	a5,s5,0x1f
    800037b0:	0137d79b          	srliw	a5,a5,0x13
    800037b4:	015787bb          	addw	a5,a5,s5
    800037b8:	40d7d79b          	sraiw	a5,a5,0xd
    800037bc:	01cb2583          	lw	a1,28(s6)
    800037c0:	9dbd                	addw	a1,a1,a5
    800037c2:	855e                	mv	a0,s7
    800037c4:	b8aff0ef          	jal	ra,80002b4e <bread>
    800037c8:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037ca:	004b2503          	lw	a0,4(s6)
    800037ce:	000a849b          	sext.w	s1,s5
    800037d2:	8762                	mv	a4,s8
    800037d4:	fca4f1e3          	bgeu	s1,a0,80003796 <balloc+0x8e>
      m = 1 << (bi % 8);
    800037d8:	00777693          	andi	a3,a4,7
    800037dc:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800037e0:	41f7579b          	sraiw	a5,a4,0x1f
    800037e4:	01d7d79b          	srliw	a5,a5,0x1d
    800037e8:	9fb9                	addw	a5,a5,a4
    800037ea:	4037d79b          	sraiw	a5,a5,0x3
    800037ee:	00f90633          	add	a2,s2,a5
    800037f2:	05864603          	lbu	a2,88(a2) # 2058 <_entry-0x7fffdfa8>
    800037f6:	00c6f5b3          	and	a1,a3,a2
    800037fa:	d5a1                	beqz	a1,80003742 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037fc:	2705                	addiw	a4,a4,1
    800037fe:	2485                	addiw	s1,s1,1
    80003800:	fd471ae3          	bne	a4,s4,800037d4 <balloc+0xcc>
    80003804:	bf49                	j	80003796 <balloc+0x8e>
  printf("balloc: out of blocks\n");
    80003806:	00003517          	auipc	a0,0x3
    8000380a:	11a50513          	addi	a0,a0,282 # 80006920 <syscalls+0x558>
    8000380e:	baffc0ef          	jal	ra,800003bc <printf>
  return 0;
    80003812:	4481                	li	s1,0
    80003814:	b79d                	j	8000377a <balloc+0x72>

0000000080003816 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003816:	7179                	addi	sp,sp,-48
    80003818:	f406                	sd	ra,40(sp)
    8000381a:	f022                	sd	s0,32(sp)
    8000381c:	ec26                	sd	s1,24(sp)
    8000381e:	e84a                	sd	s2,16(sp)
    80003820:	e44e                	sd	s3,8(sp)
    80003822:	e052                	sd	s4,0(sp)
    80003824:	1800                	addi	s0,sp,48
    80003826:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003828:	47ad                	li	a5,11
    8000382a:	02b7e663          	bltu	a5,a1,80003856 <bmap+0x40>
    if((addr = ip->addrs[bn]) == 0){
    8000382e:	02059793          	slli	a5,a1,0x20
    80003832:	01e7d593          	srli	a1,a5,0x1e
    80003836:	00b504b3          	add	s1,a0,a1
    8000383a:	0504a903          	lw	s2,80(s1)
    8000383e:	06091663          	bnez	s2,800038aa <bmap+0x94>
      addr = balloc(ip->dev);
    80003842:	4108                	lw	a0,0(a0)
    80003844:	ec5ff0ef          	jal	ra,80003708 <balloc>
    80003848:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000384c:	04090f63          	beqz	s2,800038aa <bmap+0x94>
        return 0;
      ip->addrs[bn] = addr;
    80003850:	0524a823          	sw	s2,80(s1)
    80003854:	a899                	j	800038aa <bmap+0x94>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003856:	ff45849b          	addiw	s1,a1,-12 # ffffffffffffdff4 <end+0xffffffff7ffe02f4>
    8000385a:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000385e:	0ff00793          	li	a5,255
    80003862:	06e7eb63          	bltu	a5,a4,800038d8 <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003866:	08052903          	lw	s2,128(a0)
    8000386a:	00091b63          	bnez	s2,80003880 <bmap+0x6a>
      addr = balloc(ip->dev);
    8000386e:	4108                	lw	a0,0(a0)
    80003870:	e99ff0ef          	jal	ra,80003708 <balloc>
    80003874:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003878:	02090963          	beqz	s2,800038aa <bmap+0x94>
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000387c:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003880:	85ca                	mv	a1,s2
    80003882:	0009a503          	lw	a0,0(s3)
    80003886:	ac8ff0ef          	jal	ra,80002b4e <bread>
    8000388a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000388c:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003890:	02049713          	slli	a4,s1,0x20
    80003894:	01e75593          	srli	a1,a4,0x1e
    80003898:	00b784b3          	add	s1,a5,a1
    8000389c:	0004a903          	lw	s2,0(s1)
    800038a0:	00090e63          	beqz	s2,800038bc <bmap+0xa6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800038a4:	8552                	mv	a0,s4
    800038a6:	bb0ff0ef          	jal	ra,80002c56 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800038aa:	854a                	mv	a0,s2
    800038ac:	70a2                	ld	ra,40(sp)
    800038ae:	7402                	ld	s0,32(sp)
    800038b0:	64e2                	ld	s1,24(sp)
    800038b2:	6942                	ld	s2,16(sp)
    800038b4:	69a2                	ld	s3,8(sp)
    800038b6:	6a02                	ld	s4,0(sp)
    800038b8:	6145                	addi	sp,sp,48
    800038ba:	8082                	ret
      addr = balloc(ip->dev);
    800038bc:	0009a503          	lw	a0,0(s3)
    800038c0:	e49ff0ef          	jal	ra,80003708 <balloc>
    800038c4:	0005091b          	sext.w	s2,a0
      if(addr){
    800038c8:	fc090ee3          	beqz	s2,800038a4 <bmap+0x8e>
        a[bn] = addr;
    800038cc:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800038d0:	8552                	mv	a0,s4
    800038d2:	501000ef          	jal	ra,800045d2 <log_write>
    800038d6:	b7f9                	j	800038a4 <bmap+0x8e>
  panic("bmap: out of range");
    800038d8:	00003517          	auipc	a0,0x3
    800038dc:	06050513          	addi	a0,a0,96 # 80006938 <syscalls+0x570>
    800038e0:	d91fc0ef          	jal	ra,80000670 <panic>

00000000800038e4 <iget>:
{
    800038e4:	7179                	addi	sp,sp,-48
    800038e6:	f406                	sd	ra,40(sp)
    800038e8:	f022                	sd	s0,32(sp)
    800038ea:	ec26                	sd	s1,24(sp)
    800038ec:	e84a                	sd	s2,16(sp)
    800038ee:	e44e                	sd	s3,8(sp)
    800038f0:	e052                	sd	s4,0(sp)
    800038f2:	1800                	addi	s0,sp,48
    800038f4:	89aa                	mv	s3,a0
    800038f6:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800038f8:	00019517          	auipc	a0,0x19
    800038fc:	8b850513          	addi	a0,a0,-1864 # 8001c1b0 <itable>
    80003900:	aaffd0ef          	jal	ra,800013ae <acquire>
  empty = 0;
    80003904:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003906:	00019497          	auipc	s1,0x19
    8000390a:	8c248493          	addi	s1,s1,-1854 # 8001c1c8 <itable+0x18>
    8000390e:	0001a697          	auipc	a3,0x1a
    80003912:	34a68693          	addi	a3,a3,842 # 8001dc58 <log>
    80003916:	a039                	j	80003924 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003918:	02090963          	beqz	s2,8000394a <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000391c:	08848493          	addi	s1,s1,136
    80003920:	02d48863          	beq	s1,a3,80003950 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003924:	449c                	lw	a5,8(s1)
    80003926:	fef059e3          	blez	a5,80003918 <iget+0x34>
    8000392a:	4098                	lw	a4,0(s1)
    8000392c:	ff3716e3          	bne	a4,s3,80003918 <iget+0x34>
    80003930:	40d8                	lw	a4,4(s1)
    80003932:	ff4713e3          	bne	a4,s4,80003918 <iget+0x34>
      ip->ref++;
    80003936:	2785                	addiw	a5,a5,1
    80003938:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000393a:	00019517          	auipc	a0,0x19
    8000393e:	87650513          	addi	a0,a0,-1930 # 8001c1b0 <itable>
    80003942:	b05fd0ef          	jal	ra,80001446 <release>
      return ip;
    80003946:	8926                	mv	s2,s1
    80003948:	a02d                	j	80003972 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000394a:	fbe9                	bnez	a5,8000391c <iget+0x38>
    8000394c:	8926                	mv	s2,s1
    8000394e:	b7f9                	j	8000391c <iget+0x38>
  if(empty == 0)
    80003950:	02090a63          	beqz	s2,80003984 <iget+0xa0>
  ip->dev = dev;
    80003954:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003958:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000395c:	4785                	li	a5,1
    8000395e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003962:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003966:	00019517          	auipc	a0,0x19
    8000396a:	84a50513          	addi	a0,a0,-1974 # 8001c1b0 <itable>
    8000396e:	ad9fd0ef          	jal	ra,80001446 <release>
}
    80003972:	854a                	mv	a0,s2
    80003974:	70a2                	ld	ra,40(sp)
    80003976:	7402                	ld	s0,32(sp)
    80003978:	64e2                	ld	s1,24(sp)
    8000397a:	6942                	ld	s2,16(sp)
    8000397c:	69a2                	ld	s3,8(sp)
    8000397e:	6a02                	ld	s4,0(sp)
    80003980:	6145                	addi	sp,sp,48
    80003982:	8082                	ret
    panic("iget: no inodes");
    80003984:	00003517          	auipc	a0,0x3
    80003988:	fcc50513          	addi	a0,a0,-52 # 80006950 <syscalls+0x588>
    8000398c:	ce5fc0ef          	jal	ra,80000670 <panic>

0000000080003990 <fsinit>:
fsinit(int dev) {
    80003990:	7179                	addi	sp,sp,-48
    80003992:	f406                	sd	ra,40(sp)
    80003994:	f022                	sd	s0,32(sp)
    80003996:	ec26                	sd	s1,24(sp)
    80003998:	e84a                	sd	s2,16(sp)
    8000399a:	e44e                	sd	s3,8(sp)
    8000399c:	1800                	addi	s0,sp,48
    8000399e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800039a0:	4585                	li	a1,1
    800039a2:	9acff0ef          	jal	ra,80002b4e <bread>
    800039a6:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800039a8:	00018997          	auipc	s3,0x18
    800039ac:	7e898993          	addi	s3,s3,2024 # 8001c190 <sb>
    800039b0:	02000613          	li	a2,32
    800039b4:	05850593          	addi	a1,a0,88
    800039b8:	854e                	mv	a0,s3
    800039ba:	bd9fd0ef          	jal	ra,80001592 <memmove>
  brelse(bp);
    800039be:	8526                	mv	a0,s1
    800039c0:	a96ff0ef          	jal	ra,80002c56 <brelse>
  if(sb.magic != FSMAGIC)
    800039c4:	0009a703          	lw	a4,0(s3)
    800039c8:	102037b7          	lui	a5,0x10203
    800039cc:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800039d0:	02f71063          	bne	a4,a5,800039f0 <fsinit+0x60>
  initlog(dev, &sb);
    800039d4:	00018597          	auipc	a1,0x18
    800039d8:	7bc58593          	addi	a1,a1,1980 # 8001c190 <sb>
    800039dc:	854a                	mv	a0,s2
    800039de:	1e1000ef          	jal	ra,800043be <initlog>
}
    800039e2:	70a2                	ld	ra,40(sp)
    800039e4:	7402                	ld	s0,32(sp)
    800039e6:	64e2                	ld	s1,24(sp)
    800039e8:	6942                	ld	s2,16(sp)
    800039ea:	69a2                	ld	s3,8(sp)
    800039ec:	6145                	addi	sp,sp,48
    800039ee:	8082                	ret
    panic("invalid file system");
    800039f0:	00003517          	auipc	a0,0x3
    800039f4:	f7050513          	addi	a0,a0,-144 # 80006960 <syscalls+0x598>
    800039f8:	c79fc0ef          	jal	ra,80000670 <panic>

00000000800039fc <iinit>:
{
    800039fc:	7179                	addi	sp,sp,-48
    800039fe:	f406                	sd	ra,40(sp)
    80003a00:	f022                	sd	s0,32(sp)
    80003a02:	ec26                	sd	s1,24(sp)
    80003a04:	e84a                	sd	s2,16(sp)
    80003a06:	e44e                	sd	s3,8(sp)
    80003a08:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003a0a:	00003597          	auipc	a1,0x3
    80003a0e:	f6e58593          	addi	a1,a1,-146 # 80006978 <syscalls+0x5b0>
    80003a12:	00018517          	auipc	a0,0x18
    80003a16:	79e50513          	addi	a0,a0,1950 # 8001c1b0 <itable>
    80003a1a:	915fd0ef          	jal	ra,8000132e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003a1e:	00018497          	auipc	s1,0x18
    80003a22:	7ba48493          	addi	s1,s1,1978 # 8001c1d8 <itable+0x28>
    80003a26:	0001a997          	auipc	s3,0x1a
    80003a2a:	24298993          	addi	s3,s3,578 # 8001dc68 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003a2e:	00003917          	auipc	s2,0x3
    80003a32:	f5290913          	addi	s2,s2,-174 # 80006980 <syscalls+0x5b8>
    80003a36:	85ca                	mv	a1,s2
    80003a38:	8526                	mv	a0,s1
    80003a3a:	b0eff0ef          	jal	ra,80002d48 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003a3e:	08848493          	addi	s1,s1,136
    80003a42:	ff349ae3          	bne	s1,s3,80003a36 <iinit+0x3a>
}
    80003a46:	70a2                	ld	ra,40(sp)
    80003a48:	7402                	ld	s0,32(sp)
    80003a4a:	64e2                	ld	s1,24(sp)
    80003a4c:	6942                	ld	s2,16(sp)
    80003a4e:	69a2                	ld	s3,8(sp)
    80003a50:	6145                	addi	sp,sp,48
    80003a52:	8082                	ret

0000000080003a54 <ialloc>:
{
    80003a54:	715d                	addi	sp,sp,-80
    80003a56:	e486                	sd	ra,72(sp)
    80003a58:	e0a2                	sd	s0,64(sp)
    80003a5a:	fc26                	sd	s1,56(sp)
    80003a5c:	f84a                	sd	s2,48(sp)
    80003a5e:	f44e                	sd	s3,40(sp)
    80003a60:	f052                	sd	s4,32(sp)
    80003a62:	ec56                	sd	s5,24(sp)
    80003a64:	e85a                	sd	s6,16(sp)
    80003a66:	e45e                	sd	s7,8(sp)
    80003a68:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a6a:	00018717          	auipc	a4,0x18
    80003a6e:	73272703          	lw	a4,1842(a4) # 8001c19c <sb+0xc>
    80003a72:	4785                	li	a5,1
    80003a74:	04e7f663          	bgeu	a5,a4,80003ac0 <ialloc+0x6c>
    80003a78:	8aaa                	mv	s5,a0
    80003a7a:	8bae                	mv	s7,a1
    80003a7c:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003a7e:	00018a17          	auipc	s4,0x18
    80003a82:	712a0a13          	addi	s4,s4,1810 # 8001c190 <sb>
    80003a86:	00048b1b          	sext.w	s6,s1
    80003a8a:	0044d593          	srli	a1,s1,0x4
    80003a8e:	018a2783          	lw	a5,24(s4)
    80003a92:	9dbd                	addw	a1,a1,a5
    80003a94:	8556                	mv	a0,s5
    80003a96:	8b8ff0ef          	jal	ra,80002b4e <bread>
    80003a9a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003a9c:	05850993          	addi	s3,a0,88
    80003aa0:	00f4f793          	andi	a5,s1,15
    80003aa4:	079a                	slli	a5,a5,0x6
    80003aa6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003aa8:	00099783          	lh	a5,0(s3)
    80003aac:	cf85                	beqz	a5,80003ae4 <ialloc+0x90>
    brelse(bp);
    80003aae:	9a8ff0ef          	jal	ra,80002c56 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003ab2:	0485                	addi	s1,s1,1
    80003ab4:	00ca2703          	lw	a4,12(s4)
    80003ab8:	0004879b          	sext.w	a5,s1
    80003abc:	fce7e5e3          	bltu	a5,a4,80003a86 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003ac0:	00003517          	auipc	a0,0x3
    80003ac4:	ec850513          	addi	a0,a0,-312 # 80006988 <syscalls+0x5c0>
    80003ac8:	8f5fc0ef          	jal	ra,800003bc <printf>
  return 0;
    80003acc:	4501                	li	a0,0
}
    80003ace:	60a6                	ld	ra,72(sp)
    80003ad0:	6406                	ld	s0,64(sp)
    80003ad2:	74e2                	ld	s1,56(sp)
    80003ad4:	7942                	ld	s2,48(sp)
    80003ad6:	79a2                	ld	s3,40(sp)
    80003ad8:	7a02                	ld	s4,32(sp)
    80003ada:	6ae2                	ld	s5,24(sp)
    80003adc:	6b42                	ld	s6,16(sp)
    80003ade:	6ba2                	ld	s7,8(sp)
    80003ae0:	6161                	addi	sp,sp,80
    80003ae2:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003ae4:	04000613          	li	a2,64
    80003ae8:	4581                	li	a1,0
    80003aea:	854e                	mv	a0,s3
    80003aec:	a4bfd0ef          	jal	ra,80001536 <memset>
      dip->type = type;
    80003af0:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003af4:	854a                	mv	a0,s2
    80003af6:	2dd000ef          	jal	ra,800045d2 <log_write>
      brelse(bp);
    80003afa:	854a                	mv	a0,s2
    80003afc:	95aff0ef          	jal	ra,80002c56 <brelse>
      return iget(dev, inum);
    80003b00:	85da                	mv	a1,s6
    80003b02:	8556                	mv	a0,s5
    80003b04:	de1ff0ef          	jal	ra,800038e4 <iget>
    80003b08:	b7d9                	j	80003ace <ialloc+0x7a>

0000000080003b0a <iupdate>:
{
    80003b0a:	1101                	addi	sp,sp,-32
    80003b0c:	ec06                	sd	ra,24(sp)
    80003b0e:	e822                	sd	s0,16(sp)
    80003b10:	e426                	sd	s1,8(sp)
    80003b12:	e04a                	sd	s2,0(sp)
    80003b14:	1000                	addi	s0,sp,32
    80003b16:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b18:	415c                	lw	a5,4(a0)
    80003b1a:	0047d79b          	srliw	a5,a5,0x4
    80003b1e:	00018597          	auipc	a1,0x18
    80003b22:	68a5a583          	lw	a1,1674(a1) # 8001c1a8 <sb+0x18>
    80003b26:	9dbd                	addw	a1,a1,a5
    80003b28:	4108                	lw	a0,0(a0)
    80003b2a:	824ff0ef          	jal	ra,80002b4e <bread>
    80003b2e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b30:	05850793          	addi	a5,a0,88
    80003b34:	40d8                	lw	a4,4(s1)
    80003b36:	8b3d                	andi	a4,a4,15
    80003b38:	071a                	slli	a4,a4,0x6
    80003b3a:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003b3c:	04449703          	lh	a4,68(s1)
    80003b40:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003b44:	04649703          	lh	a4,70(s1)
    80003b48:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003b4c:	04849703          	lh	a4,72(s1)
    80003b50:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003b54:	04a49703          	lh	a4,74(s1)
    80003b58:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003b5c:	44f8                	lw	a4,76(s1)
    80003b5e:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003b60:	03400613          	li	a2,52
    80003b64:	05048593          	addi	a1,s1,80
    80003b68:	00c78513          	addi	a0,a5,12
    80003b6c:	a27fd0ef          	jal	ra,80001592 <memmove>
  log_write(bp);
    80003b70:	854a                	mv	a0,s2
    80003b72:	261000ef          	jal	ra,800045d2 <log_write>
  brelse(bp);
    80003b76:	854a                	mv	a0,s2
    80003b78:	8deff0ef          	jal	ra,80002c56 <brelse>
}
    80003b7c:	60e2                	ld	ra,24(sp)
    80003b7e:	6442                	ld	s0,16(sp)
    80003b80:	64a2                	ld	s1,8(sp)
    80003b82:	6902                	ld	s2,0(sp)
    80003b84:	6105                	addi	sp,sp,32
    80003b86:	8082                	ret

0000000080003b88 <idup>:
{
    80003b88:	1101                	addi	sp,sp,-32
    80003b8a:	ec06                	sd	ra,24(sp)
    80003b8c:	e822                	sd	s0,16(sp)
    80003b8e:	e426                	sd	s1,8(sp)
    80003b90:	1000                	addi	s0,sp,32
    80003b92:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b94:	00018517          	auipc	a0,0x18
    80003b98:	61c50513          	addi	a0,a0,1564 # 8001c1b0 <itable>
    80003b9c:	813fd0ef          	jal	ra,800013ae <acquire>
  ip->ref++;
    80003ba0:	449c                	lw	a5,8(s1)
    80003ba2:	2785                	addiw	a5,a5,1
    80003ba4:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003ba6:	00018517          	auipc	a0,0x18
    80003baa:	60a50513          	addi	a0,a0,1546 # 8001c1b0 <itable>
    80003bae:	899fd0ef          	jal	ra,80001446 <release>
}
    80003bb2:	8526                	mv	a0,s1
    80003bb4:	60e2                	ld	ra,24(sp)
    80003bb6:	6442                	ld	s0,16(sp)
    80003bb8:	64a2                	ld	s1,8(sp)
    80003bba:	6105                	addi	sp,sp,32
    80003bbc:	8082                	ret

0000000080003bbe <ilock>:
{
    80003bbe:	1101                	addi	sp,sp,-32
    80003bc0:	ec06                	sd	ra,24(sp)
    80003bc2:	e822                	sd	s0,16(sp)
    80003bc4:	e426                	sd	s1,8(sp)
    80003bc6:	e04a                	sd	s2,0(sp)
    80003bc8:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003bca:	c105                	beqz	a0,80003bea <ilock+0x2c>
    80003bcc:	84aa                	mv	s1,a0
    80003bce:	451c                	lw	a5,8(a0)
    80003bd0:	00f05d63          	blez	a5,80003bea <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003bd4:	0541                	addi	a0,a0,16
    80003bd6:	9a8ff0ef          	jal	ra,80002d7e <acquiresleep>
  if(ip->valid == 0){
    80003bda:	40bc                	lw	a5,64(s1)
    80003bdc:	cf89                	beqz	a5,80003bf6 <ilock+0x38>
}
    80003bde:	60e2                	ld	ra,24(sp)
    80003be0:	6442                	ld	s0,16(sp)
    80003be2:	64a2                	ld	s1,8(sp)
    80003be4:	6902                	ld	s2,0(sp)
    80003be6:	6105                	addi	sp,sp,32
    80003be8:	8082                	ret
    panic("ilock");
    80003bea:	00003517          	auipc	a0,0x3
    80003bee:	db650513          	addi	a0,a0,-586 # 800069a0 <syscalls+0x5d8>
    80003bf2:	a7ffc0ef          	jal	ra,80000670 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003bf6:	40dc                	lw	a5,4(s1)
    80003bf8:	0047d79b          	srliw	a5,a5,0x4
    80003bfc:	00018597          	auipc	a1,0x18
    80003c00:	5ac5a583          	lw	a1,1452(a1) # 8001c1a8 <sb+0x18>
    80003c04:	9dbd                	addw	a1,a1,a5
    80003c06:	4088                	lw	a0,0(s1)
    80003c08:	f47fe0ef          	jal	ra,80002b4e <bread>
    80003c0c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c0e:	05850593          	addi	a1,a0,88
    80003c12:	40dc                	lw	a5,4(s1)
    80003c14:	8bbd                	andi	a5,a5,15
    80003c16:	079a                	slli	a5,a5,0x6
    80003c18:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003c1a:	00059783          	lh	a5,0(a1)
    80003c1e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003c22:	00259783          	lh	a5,2(a1)
    80003c26:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003c2a:	00459783          	lh	a5,4(a1)
    80003c2e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003c32:	00659783          	lh	a5,6(a1)
    80003c36:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003c3a:	459c                	lw	a5,8(a1)
    80003c3c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003c3e:	03400613          	li	a2,52
    80003c42:	05b1                	addi	a1,a1,12
    80003c44:	05048513          	addi	a0,s1,80
    80003c48:	94bfd0ef          	jal	ra,80001592 <memmove>
    brelse(bp);
    80003c4c:	854a                	mv	a0,s2
    80003c4e:	808ff0ef          	jal	ra,80002c56 <brelse>
    ip->valid = 1;
    80003c52:	4785                	li	a5,1
    80003c54:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003c56:	04449783          	lh	a5,68(s1)
    80003c5a:	f3d1                	bnez	a5,80003bde <ilock+0x20>
      panic("ilock: no type");
    80003c5c:	00003517          	auipc	a0,0x3
    80003c60:	d4c50513          	addi	a0,a0,-692 # 800069a8 <syscalls+0x5e0>
    80003c64:	a0dfc0ef          	jal	ra,80000670 <panic>

0000000080003c68 <iunlock>:
{
    80003c68:	1101                	addi	sp,sp,-32
    80003c6a:	ec06                	sd	ra,24(sp)
    80003c6c:	e822                	sd	s0,16(sp)
    80003c6e:	e426                	sd	s1,8(sp)
    80003c70:	e04a                	sd	s2,0(sp)
    80003c72:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003c74:	c505                	beqz	a0,80003c9c <iunlock+0x34>
    80003c76:	84aa                	mv	s1,a0
    80003c78:	01050913          	addi	s2,a0,16
    80003c7c:	854a                	mv	a0,s2
    80003c7e:	97eff0ef          	jal	ra,80002dfc <holdingsleep>
    80003c82:	cd09                	beqz	a0,80003c9c <iunlock+0x34>
    80003c84:	449c                	lw	a5,8(s1)
    80003c86:	00f05b63          	blez	a5,80003c9c <iunlock+0x34>
  releasesleep(&ip->lock);
    80003c8a:	854a                	mv	a0,s2
    80003c8c:	938ff0ef          	jal	ra,80002dc4 <releasesleep>
}
    80003c90:	60e2                	ld	ra,24(sp)
    80003c92:	6442                	ld	s0,16(sp)
    80003c94:	64a2                	ld	s1,8(sp)
    80003c96:	6902                	ld	s2,0(sp)
    80003c98:	6105                	addi	sp,sp,32
    80003c9a:	8082                	ret
    panic("iunlock");
    80003c9c:	00003517          	auipc	a0,0x3
    80003ca0:	d1c50513          	addi	a0,a0,-740 # 800069b8 <syscalls+0x5f0>
    80003ca4:	9cdfc0ef          	jal	ra,80000670 <panic>

0000000080003ca8 <itrunc>:
// Truncate inode (discard contents).
// Caller must hold ip->lock.
// 丢弃inode的内容
void
itrunc(struct inode *ip)
{
    80003ca8:	7179                	addi	sp,sp,-48
    80003caa:	f406                	sd	ra,40(sp)
    80003cac:	f022                	sd	s0,32(sp)
    80003cae:	ec26                	sd	s1,24(sp)
    80003cb0:	e84a                	sd	s2,16(sp)
    80003cb2:	e44e                	sd	s3,8(sp)
    80003cb4:	e052                	sd	s4,0(sp)
    80003cb6:	1800                	addi	s0,sp,48
    80003cb8:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003cba:	05050493          	addi	s1,a0,80
    80003cbe:	08050913          	addi	s2,a0,128
    80003cc2:	a021                	j	80003cca <itrunc+0x22>
    80003cc4:	0491                	addi	s1,s1,4
    80003cc6:	01248b63          	beq	s1,s2,80003cdc <itrunc+0x34>
    if(ip->addrs[i]){
    80003cca:	408c                	lw	a1,0(s1)
    80003ccc:	dde5                	beqz	a1,80003cc4 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003cce:	0009a503          	lw	a0,0(s3)
    80003cd2:	9cbff0ef          	jal	ra,8000369c <bfree>
      ip->addrs[i] = 0;
    80003cd6:	0004a023          	sw	zero,0(s1)
    80003cda:	b7ed                	j	80003cc4 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003cdc:	0809a583          	lw	a1,128(s3)
    80003ce0:	ed91                	bnez	a1,80003cfc <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003ce2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003ce6:	854e                	mv	a0,s3
    80003ce8:	e23ff0ef          	jal	ra,80003b0a <iupdate>
}
    80003cec:	70a2                	ld	ra,40(sp)
    80003cee:	7402                	ld	s0,32(sp)
    80003cf0:	64e2                	ld	s1,24(sp)
    80003cf2:	6942                	ld	s2,16(sp)
    80003cf4:	69a2                	ld	s3,8(sp)
    80003cf6:	6a02                	ld	s4,0(sp)
    80003cf8:	6145                	addi	sp,sp,48
    80003cfa:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003cfc:	0009a503          	lw	a0,0(s3)
    80003d00:	e4ffe0ef          	jal	ra,80002b4e <bread>
    80003d04:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003d06:	05850493          	addi	s1,a0,88
    80003d0a:	45850913          	addi	s2,a0,1112
    80003d0e:	a021                	j	80003d16 <itrunc+0x6e>
    80003d10:	0491                	addi	s1,s1,4
    80003d12:	01248963          	beq	s1,s2,80003d24 <itrunc+0x7c>
      if(a[j])
    80003d16:	408c                	lw	a1,0(s1)
    80003d18:	dde5                	beqz	a1,80003d10 <itrunc+0x68>
        bfree(ip->dev, a[j]);
    80003d1a:	0009a503          	lw	a0,0(s3)
    80003d1e:	97fff0ef          	jal	ra,8000369c <bfree>
    80003d22:	b7fd                	j	80003d10 <itrunc+0x68>
    brelse(bp);
    80003d24:	8552                	mv	a0,s4
    80003d26:	f31fe0ef          	jal	ra,80002c56 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003d2a:	0809a583          	lw	a1,128(s3)
    80003d2e:	0009a503          	lw	a0,0(s3)
    80003d32:	96bff0ef          	jal	ra,8000369c <bfree>
    ip->addrs[NDIRECT] = 0;
    80003d36:	0809a023          	sw	zero,128(s3)
    80003d3a:	b765                	j	80003ce2 <itrunc+0x3a>

0000000080003d3c <iput>:
{
    80003d3c:	1101                	addi	sp,sp,-32
    80003d3e:	ec06                	sd	ra,24(sp)
    80003d40:	e822                	sd	s0,16(sp)
    80003d42:	e426                	sd	s1,8(sp)
    80003d44:	e04a                	sd	s2,0(sp)
    80003d46:	1000                	addi	s0,sp,32
    80003d48:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d4a:	00018517          	auipc	a0,0x18
    80003d4e:	46650513          	addi	a0,a0,1126 # 8001c1b0 <itable>
    80003d52:	e5cfd0ef          	jal	ra,800013ae <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d56:	4498                	lw	a4,8(s1)
    80003d58:	4785                	li	a5,1
    80003d5a:	02f70163          	beq	a4,a5,80003d7c <iput+0x40>
  ip->ref--;
    80003d5e:	449c                	lw	a5,8(s1)
    80003d60:	37fd                	addiw	a5,a5,-1
    80003d62:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003d64:	00018517          	auipc	a0,0x18
    80003d68:	44c50513          	addi	a0,a0,1100 # 8001c1b0 <itable>
    80003d6c:	edafd0ef          	jal	ra,80001446 <release>
}
    80003d70:	60e2                	ld	ra,24(sp)
    80003d72:	6442                	ld	s0,16(sp)
    80003d74:	64a2                	ld	s1,8(sp)
    80003d76:	6902                	ld	s2,0(sp)
    80003d78:	6105                	addi	sp,sp,32
    80003d7a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d7c:	40bc                	lw	a5,64(s1)
    80003d7e:	d3e5                	beqz	a5,80003d5e <iput+0x22>
    80003d80:	04a49783          	lh	a5,74(s1)
    80003d84:	ffe9                	bnez	a5,80003d5e <iput+0x22>
    acquiresleep(&ip->lock);
    80003d86:	01048913          	addi	s2,s1,16
    80003d8a:	854a                	mv	a0,s2
    80003d8c:	ff3fe0ef          	jal	ra,80002d7e <acquiresleep>
    release(&itable.lock);
    80003d90:	00018517          	auipc	a0,0x18
    80003d94:	42050513          	addi	a0,a0,1056 # 8001c1b0 <itable>
    80003d98:	eaefd0ef          	jal	ra,80001446 <release>
    itrunc(ip);
    80003d9c:	8526                	mv	a0,s1
    80003d9e:	f0bff0ef          	jal	ra,80003ca8 <itrunc>
    ip->type = 0;
    80003da2:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003da6:	8526                	mv	a0,s1
    80003da8:	d63ff0ef          	jal	ra,80003b0a <iupdate>
    ip->valid = 0;
    80003dac:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003db0:	854a                	mv	a0,s2
    80003db2:	812ff0ef          	jal	ra,80002dc4 <releasesleep>
    acquire(&itable.lock);
    80003db6:	00018517          	auipc	a0,0x18
    80003dba:	3fa50513          	addi	a0,a0,1018 # 8001c1b0 <itable>
    80003dbe:	df0fd0ef          	jal	ra,800013ae <acquire>
    80003dc2:	bf71                	j	80003d5e <iput+0x22>

0000000080003dc4 <iunlockput>:
{
    80003dc4:	1101                	addi	sp,sp,-32
    80003dc6:	ec06                	sd	ra,24(sp)
    80003dc8:	e822                	sd	s0,16(sp)
    80003dca:	e426                	sd	s1,8(sp)
    80003dcc:	1000                	addi	s0,sp,32
    80003dce:	84aa                	mv	s1,a0
  iunlock(ip);
    80003dd0:	e99ff0ef          	jal	ra,80003c68 <iunlock>
  iput(ip);
    80003dd4:	8526                	mv	a0,s1
    80003dd6:	f67ff0ef          	jal	ra,80003d3c <iput>
}
    80003dda:	60e2                	ld	ra,24(sp)
    80003ddc:	6442                	ld	s0,16(sp)
    80003dde:	64a2                	ld	s1,8(sp)
    80003de0:	6105                	addi	sp,sp,32
    80003de2:	8082                	ret

0000000080003de4 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003de4:	1141                	addi	sp,sp,-16
    80003de6:	e422                	sd	s0,8(sp)
    80003de8:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003dea:	411c                	lw	a5,0(a0)
    80003dec:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003dee:	415c                	lw	a5,4(a0)
    80003df0:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003df2:	04451783          	lh	a5,68(a0)
    80003df6:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003dfa:	04a51783          	lh	a5,74(a0)
    80003dfe:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003e02:	04c56783          	lwu	a5,76(a0)
    80003e06:	e99c                	sd	a5,16(a1)
}
    80003e08:	6422                	ld	s0,8(sp)
    80003e0a:	0141                	addi	sp,sp,16
    80003e0c:	8082                	ret

0000000080003e0e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e0e:	457c                	lw	a5,76(a0)
    80003e10:	0cd7ef63          	bltu	a5,a3,80003eee <readi+0xe0>
{
    80003e14:	7159                	addi	sp,sp,-112
    80003e16:	f486                	sd	ra,104(sp)
    80003e18:	f0a2                	sd	s0,96(sp)
    80003e1a:	eca6                	sd	s1,88(sp)
    80003e1c:	e8ca                	sd	s2,80(sp)
    80003e1e:	e4ce                	sd	s3,72(sp)
    80003e20:	e0d2                	sd	s4,64(sp)
    80003e22:	fc56                	sd	s5,56(sp)
    80003e24:	f85a                	sd	s6,48(sp)
    80003e26:	f45e                	sd	s7,40(sp)
    80003e28:	f062                	sd	s8,32(sp)
    80003e2a:	ec66                	sd	s9,24(sp)
    80003e2c:	e86a                	sd	s10,16(sp)
    80003e2e:	e46e                	sd	s11,8(sp)
    80003e30:	1880                	addi	s0,sp,112
    80003e32:	8b2a                	mv	s6,a0
    80003e34:	8bae                	mv	s7,a1
    80003e36:	8a32                	mv	s4,a2
    80003e38:	84b6                	mv	s1,a3
    80003e3a:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003e3c:	9f35                	addw	a4,a4,a3
    return 0;
    80003e3e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003e40:	08d76663          	bltu	a4,a3,80003ecc <readi+0xbe>
  if(off + n > ip->size)
    80003e44:	00e7f463          	bgeu	a5,a4,80003e4c <readi+0x3e>
    n = ip->size - off;
    80003e48:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e4c:	080a8f63          	beqz	s5,80003eea <readi+0xdc>
    80003e50:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e52:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003e56:	5c7d                	li	s8,-1
    80003e58:	a80d                	j	80003e8a <readi+0x7c>
    80003e5a:	020d1d93          	slli	s11,s10,0x20
    80003e5e:	020ddd93          	srli	s11,s11,0x20
    80003e62:	05890613          	addi	a2,s2,88
    80003e66:	86ee                	mv	a3,s11
    80003e68:	963a                	add	a2,a2,a4
    80003e6a:	85d2                	mv	a1,s4
    80003e6c:	855e                	mv	a0,s7
    80003e6e:	c2cfd0ef          	jal	ra,8000129a <either_copyout>
    80003e72:	05850763          	beq	a0,s8,80003ec0 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003e76:	854a                	mv	a0,s2
    80003e78:	ddffe0ef          	jal	ra,80002c56 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e7c:	013d09bb          	addw	s3,s10,s3
    80003e80:	009d04bb          	addw	s1,s10,s1
    80003e84:	9a6e                	add	s4,s4,s11
    80003e86:	0559f163          	bgeu	s3,s5,80003ec8 <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    80003e8a:	00a4d59b          	srliw	a1,s1,0xa
    80003e8e:	855a                	mv	a0,s6
    80003e90:	987ff0ef          	jal	ra,80003816 <bmap>
    80003e94:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003e98:	c985                	beqz	a1,80003ec8 <readi+0xba>
    bp = bread(ip->dev, addr);
    80003e9a:	000b2503          	lw	a0,0(s6)
    80003e9e:	cb1fe0ef          	jal	ra,80002b4e <bread>
    80003ea2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ea4:	3ff4f713          	andi	a4,s1,1023
    80003ea8:	40ec87bb          	subw	a5,s9,a4
    80003eac:	413a86bb          	subw	a3,s5,s3
    80003eb0:	8d3e                	mv	s10,a5
    80003eb2:	2781                	sext.w	a5,a5
    80003eb4:	0006861b          	sext.w	a2,a3
    80003eb8:	faf671e3          	bgeu	a2,a5,80003e5a <readi+0x4c>
    80003ebc:	8d36                	mv	s10,a3
    80003ebe:	bf71                	j	80003e5a <readi+0x4c>
      brelse(bp);
    80003ec0:	854a                	mv	a0,s2
    80003ec2:	d95fe0ef          	jal	ra,80002c56 <brelse>
      tot = -1;
    80003ec6:	59fd                	li	s3,-1
  }
  return tot;
    80003ec8:	0009851b          	sext.w	a0,s3
}
    80003ecc:	70a6                	ld	ra,104(sp)
    80003ece:	7406                	ld	s0,96(sp)
    80003ed0:	64e6                	ld	s1,88(sp)
    80003ed2:	6946                	ld	s2,80(sp)
    80003ed4:	69a6                	ld	s3,72(sp)
    80003ed6:	6a06                	ld	s4,64(sp)
    80003ed8:	7ae2                	ld	s5,56(sp)
    80003eda:	7b42                	ld	s6,48(sp)
    80003edc:	7ba2                	ld	s7,40(sp)
    80003ede:	7c02                	ld	s8,32(sp)
    80003ee0:	6ce2                	ld	s9,24(sp)
    80003ee2:	6d42                	ld	s10,16(sp)
    80003ee4:	6da2                	ld	s11,8(sp)
    80003ee6:	6165                	addi	sp,sp,112
    80003ee8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003eea:	89d6                	mv	s3,s5
    80003eec:	bff1                	j	80003ec8 <readi+0xba>
    return 0;
    80003eee:	4501                	li	a0,0
}
    80003ef0:	8082                	ret

0000000080003ef2 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ef2:	457c                	lw	a5,76(a0)
    80003ef4:	0ed7ea63          	bltu	a5,a3,80003fe8 <writei+0xf6>
{
    80003ef8:	7159                	addi	sp,sp,-112
    80003efa:	f486                	sd	ra,104(sp)
    80003efc:	f0a2                	sd	s0,96(sp)
    80003efe:	eca6                	sd	s1,88(sp)
    80003f00:	e8ca                	sd	s2,80(sp)
    80003f02:	e4ce                	sd	s3,72(sp)
    80003f04:	e0d2                	sd	s4,64(sp)
    80003f06:	fc56                	sd	s5,56(sp)
    80003f08:	f85a                	sd	s6,48(sp)
    80003f0a:	f45e                	sd	s7,40(sp)
    80003f0c:	f062                	sd	s8,32(sp)
    80003f0e:	ec66                	sd	s9,24(sp)
    80003f10:	e86a                	sd	s10,16(sp)
    80003f12:	e46e                	sd	s11,8(sp)
    80003f14:	1880                	addi	s0,sp,112
    80003f16:	8aaa                	mv	s5,a0
    80003f18:	8bae                	mv	s7,a1
    80003f1a:	8a32                	mv	s4,a2
    80003f1c:	8936                	mv	s2,a3
    80003f1e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003f20:	00e687bb          	addw	a5,a3,a4
    80003f24:	0cd7e463          	bltu	a5,a3,80003fec <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003f28:	00043737          	lui	a4,0x43
    80003f2c:	0cf76263          	bltu	a4,a5,80003ff0 <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f30:	0a0b0a63          	beqz	s6,80003fe4 <writei+0xf2>
    80003f34:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f36:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003f3a:	5c7d                	li	s8,-1
    80003f3c:	a825                	j	80003f74 <writei+0x82>
    80003f3e:	020d1d93          	slli	s11,s10,0x20
    80003f42:	020ddd93          	srli	s11,s11,0x20
    80003f46:	05848513          	addi	a0,s1,88
    80003f4a:	86ee                	mv	a3,s11
    80003f4c:	8652                	mv	a2,s4
    80003f4e:	85de                	mv	a1,s7
    80003f50:	953a                	add	a0,a0,a4
    80003f52:	b92fd0ef          	jal	ra,800012e4 <either_copyin>
    80003f56:	05850a63          	beq	a0,s8,80003faa <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003f5a:	8526                	mv	a0,s1
    80003f5c:	676000ef          	jal	ra,800045d2 <log_write>
    brelse(bp);
    80003f60:	8526                	mv	a0,s1
    80003f62:	cf5fe0ef          	jal	ra,80002c56 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f66:	013d09bb          	addw	s3,s10,s3
    80003f6a:	012d093b          	addw	s2,s10,s2
    80003f6e:	9a6e                	add	s4,s4,s11
    80003f70:	0569f063          	bgeu	s3,s6,80003fb0 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003f74:	00a9559b          	srliw	a1,s2,0xa
    80003f78:	8556                	mv	a0,s5
    80003f7a:	89dff0ef          	jal	ra,80003816 <bmap>
    80003f7e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f82:	c59d                	beqz	a1,80003fb0 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003f84:	000aa503          	lw	a0,0(s5) # fffffffffffff000 <end+0xffffffff7ffe1300>
    80003f88:	bc7fe0ef          	jal	ra,80002b4e <bread>
    80003f8c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f8e:	3ff97713          	andi	a4,s2,1023
    80003f92:	40ec87bb          	subw	a5,s9,a4
    80003f96:	413b06bb          	subw	a3,s6,s3
    80003f9a:	8d3e                	mv	s10,a5
    80003f9c:	2781                	sext.w	a5,a5
    80003f9e:	0006861b          	sext.w	a2,a3
    80003fa2:	f8f67ee3          	bgeu	a2,a5,80003f3e <writei+0x4c>
    80003fa6:	8d36                	mv	s10,a3
    80003fa8:	bf59                	j	80003f3e <writei+0x4c>
      brelse(bp);
    80003faa:	8526                	mv	a0,s1
    80003fac:	cabfe0ef          	jal	ra,80002c56 <brelse>
  }

  if(off > ip->size)
    80003fb0:	04caa783          	lw	a5,76(s5)
    80003fb4:	0127f463          	bgeu	a5,s2,80003fbc <writei+0xca>
    ip->size = off;
    80003fb8:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003fbc:	8556                	mv	a0,s5
    80003fbe:	b4dff0ef          	jal	ra,80003b0a <iupdate>

  return tot;
    80003fc2:	0009851b          	sext.w	a0,s3
}
    80003fc6:	70a6                	ld	ra,104(sp)
    80003fc8:	7406                	ld	s0,96(sp)
    80003fca:	64e6                	ld	s1,88(sp)
    80003fcc:	6946                	ld	s2,80(sp)
    80003fce:	69a6                	ld	s3,72(sp)
    80003fd0:	6a06                	ld	s4,64(sp)
    80003fd2:	7ae2                	ld	s5,56(sp)
    80003fd4:	7b42                	ld	s6,48(sp)
    80003fd6:	7ba2                	ld	s7,40(sp)
    80003fd8:	7c02                	ld	s8,32(sp)
    80003fda:	6ce2                	ld	s9,24(sp)
    80003fdc:	6d42                	ld	s10,16(sp)
    80003fde:	6da2                	ld	s11,8(sp)
    80003fe0:	6165                	addi	sp,sp,112
    80003fe2:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003fe4:	89da                	mv	s3,s6
    80003fe6:	bfd9                	j	80003fbc <writei+0xca>
    return -1;
    80003fe8:	557d                	li	a0,-1
}
    80003fea:	8082                	ret
    return -1;
    80003fec:	557d                	li	a0,-1
    80003fee:	bfe1                	j	80003fc6 <writei+0xd4>
    return -1;
    80003ff0:	557d                	li	a0,-1
    80003ff2:	bfd1                	j	80003fc6 <writei+0xd4>

0000000080003ff4 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003ff4:	1141                	addi	sp,sp,-16
    80003ff6:	e406                	sd	ra,8(sp)
    80003ff8:	e022                	sd	s0,0(sp)
    80003ffa:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003ffc:	4639                	li	a2,14
    80003ffe:	e04fd0ef          	jal	ra,80001602 <strncmp>
}
    80004002:	60a2                	ld	ra,8(sp)
    80004004:	6402                	ld	s0,0(sp)
    80004006:	0141                	addi	sp,sp,16
    80004008:	8082                	ret

000000008000400a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000400a:	7139                	addi	sp,sp,-64
    8000400c:	fc06                	sd	ra,56(sp)
    8000400e:	f822                	sd	s0,48(sp)
    80004010:	f426                	sd	s1,40(sp)
    80004012:	f04a                	sd	s2,32(sp)
    80004014:	ec4e                	sd	s3,24(sp)
    80004016:	e852                	sd	s4,16(sp)
    80004018:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000401a:	04451703          	lh	a4,68(a0)
    8000401e:	4785                	li	a5,1
    80004020:	00f71a63          	bne	a4,a5,80004034 <dirlookup+0x2a>
    80004024:	892a                	mv	s2,a0
    80004026:	89ae                	mv	s3,a1
    80004028:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000402a:	457c                	lw	a5,76(a0)
    8000402c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000402e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004030:	e39d                	bnez	a5,80004056 <dirlookup+0x4c>
    80004032:	a095                	j	80004096 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80004034:	00003517          	auipc	a0,0x3
    80004038:	98c50513          	addi	a0,a0,-1652 # 800069c0 <syscalls+0x5f8>
    8000403c:	e34fc0ef          	jal	ra,80000670 <panic>
      panic("dirlookup read");
    80004040:	00003517          	auipc	a0,0x3
    80004044:	99850513          	addi	a0,a0,-1640 # 800069d8 <syscalls+0x610>
    80004048:	e28fc0ef          	jal	ra,80000670 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000404c:	24c1                	addiw	s1,s1,16
    8000404e:	04c92783          	lw	a5,76(s2)
    80004052:	04f4f163          	bgeu	s1,a5,80004094 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004056:	4741                	li	a4,16
    80004058:	86a6                	mv	a3,s1
    8000405a:	fc040613          	addi	a2,s0,-64
    8000405e:	4581                	li	a1,0
    80004060:	854a                	mv	a0,s2
    80004062:	dadff0ef          	jal	ra,80003e0e <readi>
    80004066:	47c1                	li	a5,16
    80004068:	fcf51ce3          	bne	a0,a5,80004040 <dirlookup+0x36>
    if(de.inum == 0)
    8000406c:	fc045783          	lhu	a5,-64(s0)
    80004070:	dff1                	beqz	a5,8000404c <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80004072:	fc240593          	addi	a1,s0,-62
    80004076:	854e                	mv	a0,s3
    80004078:	f7dff0ef          	jal	ra,80003ff4 <namecmp>
    8000407c:	f961                	bnez	a0,8000404c <dirlookup+0x42>
      if(poff)
    8000407e:	000a0463          	beqz	s4,80004086 <dirlookup+0x7c>
        *poff = off;
    80004082:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004086:	fc045583          	lhu	a1,-64(s0)
    8000408a:	00092503          	lw	a0,0(s2)
    8000408e:	857ff0ef          	jal	ra,800038e4 <iget>
    80004092:	a011                	j	80004096 <dirlookup+0x8c>
  return 0;
    80004094:	4501                	li	a0,0
}
    80004096:	70e2                	ld	ra,56(sp)
    80004098:	7442                	ld	s0,48(sp)
    8000409a:	74a2                	ld	s1,40(sp)
    8000409c:	7902                	ld	s2,32(sp)
    8000409e:	69e2                	ld	s3,24(sp)
    800040a0:	6a42                	ld	s4,16(sp)
    800040a2:	6121                	addi	sp,sp,64
    800040a4:	8082                	ret

00000000800040a6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800040a6:	711d                	addi	sp,sp,-96
    800040a8:	ec86                	sd	ra,88(sp)
    800040aa:	e8a2                	sd	s0,80(sp)
    800040ac:	e4a6                	sd	s1,72(sp)
    800040ae:	e0ca                	sd	s2,64(sp)
    800040b0:	fc4e                	sd	s3,56(sp)
    800040b2:	f852                	sd	s4,48(sp)
    800040b4:	f456                	sd	s5,40(sp)
    800040b6:	f05a                	sd	s6,32(sp)
    800040b8:	ec5e                	sd	s7,24(sp)
    800040ba:	e862                	sd	s8,16(sp)
    800040bc:	e466                	sd	s9,8(sp)
    800040be:	e06a                	sd	s10,0(sp)
    800040c0:	1080                	addi	s0,sp,96
    800040c2:	84aa                	mv	s1,a0
    800040c4:	8b2e                	mv	s6,a1
    800040c6:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800040c8:	00054703          	lbu	a4,0(a0)
    800040cc:	02f00793          	li	a5,47
    800040d0:	00f70e63          	beq	a4,a5,800040ec <namex+0x46>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800040d4:	f62fc0ef          	jal	ra,80000836 <myproc>
    800040d8:	6968                	ld	a0,208(a0)
    800040da:	aafff0ef          	jal	ra,80003b88 <idup>
    800040de:	8a2a                	mv	s4,a0
  while(*path == '/')
    800040e0:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800040e4:	4cb5                	li	s9,13
  len = path - s;
    800040e6:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800040e8:	4c05                	li	s8,1
    800040ea:	a879                	j	80004188 <namex+0xe2>
    ip = iget(ROOTDEV, ROOTINO);
    800040ec:	4585                	li	a1,1
    800040ee:	4505                	li	a0,1
    800040f0:	ff4ff0ef          	jal	ra,800038e4 <iget>
    800040f4:	8a2a                	mv	s4,a0
    800040f6:	b7ed                	j	800040e0 <namex+0x3a>
      iunlockput(ip);
    800040f8:	8552                	mv	a0,s4
    800040fa:	ccbff0ef          	jal	ra,80003dc4 <iunlockput>
      return 0;
    800040fe:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004100:	8552                	mv	a0,s4
    80004102:	60e6                	ld	ra,88(sp)
    80004104:	6446                	ld	s0,80(sp)
    80004106:	64a6                	ld	s1,72(sp)
    80004108:	6906                	ld	s2,64(sp)
    8000410a:	79e2                	ld	s3,56(sp)
    8000410c:	7a42                	ld	s4,48(sp)
    8000410e:	7aa2                	ld	s5,40(sp)
    80004110:	7b02                	ld	s6,32(sp)
    80004112:	6be2                	ld	s7,24(sp)
    80004114:	6c42                	ld	s8,16(sp)
    80004116:	6ca2                	ld	s9,8(sp)
    80004118:	6d02                	ld	s10,0(sp)
    8000411a:	6125                	addi	sp,sp,96
    8000411c:	8082                	ret
      iunlock(ip);
    8000411e:	8552                	mv	a0,s4
    80004120:	b49ff0ef          	jal	ra,80003c68 <iunlock>
      return ip;
    80004124:	bff1                	j	80004100 <namex+0x5a>
      iunlockput(ip);
    80004126:	8552                	mv	a0,s4
    80004128:	c9dff0ef          	jal	ra,80003dc4 <iunlockput>
      return 0;
    8000412c:	8a4e                	mv	s4,s3
    8000412e:	bfc9                	j	80004100 <namex+0x5a>
  len = path - s;
    80004130:	40998633          	sub	a2,s3,s1
    80004134:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80004138:	09acd063          	bge	s9,s10,800041b8 <namex+0x112>
    memmove(name, s, DIRSIZ);
    8000413c:	4639                	li	a2,14
    8000413e:	85a6                	mv	a1,s1
    80004140:	8556                	mv	a0,s5
    80004142:	c50fd0ef          	jal	ra,80001592 <memmove>
    80004146:	84ce                	mv	s1,s3
  while(*path == '/')
    80004148:	0004c783          	lbu	a5,0(s1)
    8000414c:	01279763          	bne	a5,s2,8000415a <namex+0xb4>
    path++;
    80004150:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004152:	0004c783          	lbu	a5,0(s1)
    80004156:	ff278de3          	beq	a5,s2,80004150 <namex+0xaa>
    ilock(ip);
    8000415a:	8552                	mv	a0,s4
    8000415c:	a63ff0ef          	jal	ra,80003bbe <ilock>
    if(ip->type != T_DIR){
    80004160:	044a1783          	lh	a5,68(s4)
    80004164:	f9879ae3          	bne	a5,s8,800040f8 <namex+0x52>
    if(nameiparent && *path == '\0'){
    80004168:	000b0563          	beqz	s6,80004172 <namex+0xcc>
    8000416c:	0004c783          	lbu	a5,0(s1)
    80004170:	d7dd                	beqz	a5,8000411e <namex+0x78>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004172:	865e                	mv	a2,s7
    80004174:	85d6                	mv	a1,s5
    80004176:	8552                	mv	a0,s4
    80004178:	e93ff0ef          	jal	ra,8000400a <dirlookup>
    8000417c:	89aa                	mv	s3,a0
    8000417e:	d545                	beqz	a0,80004126 <namex+0x80>
    iunlockput(ip);
    80004180:	8552                	mv	a0,s4
    80004182:	c43ff0ef          	jal	ra,80003dc4 <iunlockput>
    ip = next;
    80004186:	8a4e                	mv	s4,s3
  while(*path == '/')
    80004188:	0004c783          	lbu	a5,0(s1)
    8000418c:	01279763          	bne	a5,s2,8000419a <namex+0xf4>
    path++;
    80004190:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004192:	0004c783          	lbu	a5,0(s1)
    80004196:	ff278de3          	beq	a5,s2,80004190 <namex+0xea>
  if(*path == 0)
    8000419a:	cb8d                	beqz	a5,800041cc <namex+0x126>
  while(*path != '/' && *path != 0)
    8000419c:	0004c783          	lbu	a5,0(s1)
    800041a0:	89a6                	mv	s3,s1
  len = path - s;
    800041a2:	8d5e                	mv	s10,s7
    800041a4:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800041a6:	01278963          	beq	a5,s2,800041b8 <namex+0x112>
    800041aa:	d3d9                	beqz	a5,80004130 <namex+0x8a>
    path++;
    800041ac:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800041ae:	0009c783          	lbu	a5,0(s3)
    800041b2:	ff279ce3          	bne	a5,s2,800041aa <namex+0x104>
    800041b6:	bfad                	j	80004130 <namex+0x8a>
    memmove(name, s, len);
    800041b8:	2601                	sext.w	a2,a2
    800041ba:	85a6                	mv	a1,s1
    800041bc:	8556                	mv	a0,s5
    800041be:	bd4fd0ef          	jal	ra,80001592 <memmove>
    name[len] = 0;
    800041c2:	9d56                	add	s10,s10,s5
    800041c4:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffe1300>
    800041c8:	84ce                	mv	s1,s3
    800041ca:	bfbd                	j	80004148 <namex+0xa2>
  if(nameiparent){
    800041cc:	f20b0ae3          	beqz	s6,80004100 <namex+0x5a>
    iput(ip);
    800041d0:	8552                	mv	a0,s4
    800041d2:	b6bff0ef          	jal	ra,80003d3c <iput>
    return 0;
    800041d6:	4a01                	li	s4,0
    800041d8:	b725                	j	80004100 <namex+0x5a>

00000000800041da <dirlink>:
{
    800041da:	7139                	addi	sp,sp,-64
    800041dc:	fc06                	sd	ra,56(sp)
    800041de:	f822                	sd	s0,48(sp)
    800041e0:	f426                	sd	s1,40(sp)
    800041e2:	f04a                	sd	s2,32(sp)
    800041e4:	ec4e                	sd	s3,24(sp)
    800041e6:	e852                	sd	s4,16(sp)
    800041e8:	0080                	addi	s0,sp,64
    800041ea:	892a                	mv	s2,a0
    800041ec:	8a2e                	mv	s4,a1
    800041ee:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800041f0:	4601                	li	a2,0
    800041f2:	e19ff0ef          	jal	ra,8000400a <dirlookup>
    800041f6:	e52d                	bnez	a0,80004260 <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041f8:	04c92483          	lw	s1,76(s2)
    800041fc:	c48d                	beqz	s1,80004226 <dirlink+0x4c>
    800041fe:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004200:	4741                	li	a4,16
    80004202:	86a6                	mv	a3,s1
    80004204:	fc040613          	addi	a2,s0,-64
    80004208:	4581                	li	a1,0
    8000420a:	854a                	mv	a0,s2
    8000420c:	c03ff0ef          	jal	ra,80003e0e <readi>
    80004210:	47c1                	li	a5,16
    80004212:	04f51b63          	bne	a0,a5,80004268 <dirlink+0x8e>
    if(de.inum == 0)
    80004216:	fc045783          	lhu	a5,-64(s0)
    8000421a:	c791                	beqz	a5,80004226 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000421c:	24c1                	addiw	s1,s1,16
    8000421e:	04c92783          	lw	a5,76(s2)
    80004222:	fcf4efe3          	bltu	s1,a5,80004200 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80004226:	4639                	li	a2,14
    80004228:	85d2                	mv	a1,s4
    8000422a:	fc240513          	addi	a0,s0,-62
    8000422e:	c10fd0ef          	jal	ra,8000163e <strncpy>
  de.inum = inum;
    80004232:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004236:	4741                	li	a4,16
    80004238:	86a6                	mv	a3,s1
    8000423a:	fc040613          	addi	a2,s0,-64
    8000423e:	4581                	li	a1,0
    80004240:	854a                	mv	a0,s2
    80004242:	cb1ff0ef          	jal	ra,80003ef2 <writei>
    80004246:	1541                	addi	a0,a0,-16
    80004248:	00a03533          	snez	a0,a0
    8000424c:	40a00533          	neg	a0,a0
}
    80004250:	70e2                	ld	ra,56(sp)
    80004252:	7442                	ld	s0,48(sp)
    80004254:	74a2                	ld	s1,40(sp)
    80004256:	7902                	ld	s2,32(sp)
    80004258:	69e2                	ld	s3,24(sp)
    8000425a:	6a42                	ld	s4,16(sp)
    8000425c:	6121                	addi	sp,sp,64
    8000425e:	8082                	ret
    iput(ip);
    80004260:	addff0ef          	jal	ra,80003d3c <iput>
    return -1;
    80004264:	557d                	li	a0,-1
    80004266:	b7ed                	j	80004250 <dirlink+0x76>
      panic("dirlink read");
    80004268:	00002517          	auipc	a0,0x2
    8000426c:	78050513          	addi	a0,a0,1920 # 800069e8 <syscalls+0x620>
    80004270:	c00fc0ef          	jal	ra,80000670 <panic>

0000000080004274 <namei>:

struct inode*
namei(char *path)
{
    80004274:	1101                	addi	sp,sp,-32
    80004276:	ec06                	sd	ra,24(sp)
    80004278:	e822                	sd	s0,16(sp)
    8000427a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000427c:	fe040613          	addi	a2,s0,-32
    80004280:	4581                	li	a1,0
    80004282:	e25ff0ef          	jal	ra,800040a6 <namex>
}
    80004286:	60e2                	ld	ra,24(sp)
    80004288:	6442                	ld	s0,16(sp)
    8000428a:	6105                	addi	sp,sp,32
    8000428c:	8082                	ret

000000008000428e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000428e:	1141                	addi	sp,sp,-16
    80004290:	e406                	sd	ra,8(sp)
    80004292:	e022                	sd	s0,0(sp)
    80004294:	0800                	addi	s0,sp,16
    80004296:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004298:	4585                	li	a1,1
    8000429a:	e0dff0ef          	jal	ra,800040a6 <namex>
}
    8000429e:	60a2                	ld	ra,8(sp)
    800042a0:	6402                	ld	s0,0(sp)
    800042a2:	0141                	addi	sp,sp,16
    800042a4:	8082                	ret

00000000800042a6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800042a6:	1101                	addi	sp,sp,-32
    800042a8:	ec06                	sd	ra,24(sp)
    800042aa:	e822                	sd	s0,16(sp)
    800042ac:	e426                	sd	s1,8(sp)
    800042ae:	e04a                	sd	s2,0(sp)
    800042b0:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800042b2:	0001a917          	auipc	s2,0x1a
    800042b6:	9a690913          	addi	s2,s2,-1626 # 8001dc58 <log>
    800042ba:	01892583          	lw	a1,24(s2)
    800042be:	02892503          	lw	a0,40(s2)
    800042c2:	88dfe0ef          	jal	ra,80002b4e <bread>
    800042c6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800042c8:	02c92683          	lw	a3,44(s2)
    800042cc:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800042ce:	02d05863          	blez	a3,800042fe <write_head+0x58>
    800042d2:	0001a797          	auipc	a5,0x1a
    800042d6:	9b678793          	addi	a5,a5,-1610 # 8001dc88 <log+0x30>
    800042da:	05c50713          	addi	a4,a0,92
    800042de:	36fd                	addiw	a3,a3,-1
    800042e0:	02069613          	slli	a2,a3,0x20
    800042e4:	01e65693          	srli	a3,a2,0x1e
    800042e8:	0001a617          	auipc	a2,0x1a
    800042ec:	9a460613          	addi	a2,a2,-1628 # 8001dc8c <log+0x34>
    800042f0:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800042f2:	4390                	lw	a2,0(a5)
    800042f4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800042f6:	0791                	addi	a5,a5,4
    800042f8:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    800042fa:	fed79ce3          	bne	a5,a3,800042f2 <write_head+0x4c>
  }
  bwrite(buf);
    800042fe:	8526                	mv	a0,s1
    80004300:	925fe0ef          	jal	ra,80002c24 <bwrite>
  brelse(buf);
    80004304:	8526                	mv	a0,s1
    80004306:	951fe0ef          	jal	ra,80002c56 <brelse>
}
    8000430a:	60e2                	ld	ra,24(sp)
    8000430c:	6442                	ld	s0,16(sp)
    8000430e:	64a2                	ld	s1,8(sp)
    80004310:	6902                	ld	s2,0(sp)
    80004312:	6105                	addi	sp,sp,32
    80004314:	8082                	ret

0000000080004316 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004316:	0001a797          	auipc	a5,0x1a
    8000431a:	96e7a783          	lw	a5,-1682(a5) # 8001dc84 <log+0x2c>
    8000431e:	08f05f63          	blez	a5,800043bc <install_trans+0xa6>
{
    80004322:	7139                	addi	sp,sp,-64
    80004324:	fc06                	sd	ra,56(sp)
    80004326:	f822                	sd	s0,48(sp)
    80004328:	f426                	sd	s1,40(sp)
    8000432a:	f04a                	sd	s2,32(sp)
    8000432c:	ec4e                	sd	s3,24(sp)
    8000432e:	e852                	sd	s4,16(sp)
    80004330:	e456                	sd	s5,8(sp)
    80004332:	e05a                	sd	s6,0(sp)
    80004334:	0080                	addi	s0,sp,64
    80004336:	8b2a                	mv	s6,a0
    80004338:	0001aa97          	auipc	s5,0x1a
    8000433c:	950a8a93          	addi	s5,s5,-1712 # 8001dc88 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004340:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004342:	0001a997          	auipc	s3,0x1a
    80004346:	91698993          	addi	s3,s3,-1770 # 8001dc58 <log>
    8000434a:	a829                	j	80004364 <install_trans+0x4e>
    brelse(lbuf);
    8000434c:	854a                	mv	a0,s2
    8000434e:	909fe0ef          	jal	ra,80002c56 <brelse>
    brelse(dbuf);
    80004352:	8526                	mv	a0,s1
    80004354:	903fe0ef          	jal	ra,80002c56 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004358:	2a05                	addiw	s4,s4,1
    8000435a:	0a91                	addi	s5,s5,4
    8000435c:	02c9a783          	lw	a5,44(s3)
    80004360:	04fa5463          	bge	s4,a5,800043a8 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004364:	0189a583          	lw	a1,24(s3)
    80004368:	014585bb          	addw	a1,a1,s4
    8000436c:	2585                	addiw	a1,a1,1
    8000436e:	0289a503          	lw	a0,40(s3)
    80004372:	fdcfe0ef          	jal	ra,80002b4e <bread>
    80004376:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004378:	000aa583          	lw	a1,0(s5)
    8000437c:	0289a503          	lw	a0,40(s3)
    80004380:	fcefe0ef          	jal	ra,80002b4e <bread>
    80004384:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004386:	40000613          	li	a2,1024
    8000438a:	05890593          	addi	a1,s2,88
    8000438e:	05850513          	addi	a0,a0,88
    80004392:	a00fd0ef          	jal	ra,80001592 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004396:	8526                	mv	a0,s1
    80004398:	88dfe0ef          	jal	ra,80002c24 <bwrite>
    if(recovering == 0)
    8000439c:	fa0b18e3          	bnez	s6,8000434c <install_trans+0x36>
      bunpin(dbuf);
    800043a0:	8526                	mv	a0,s1
    800043a2:	973fe0ef          	jal	ra,80002d14 <bunpin>
    800043a6:	b75d                	j	8000434c <install_trans+0x36>
}
    800043a8:	70e2                	ld	ra,56(sp)
    800043aa:	7442                	ld	s0,48(sp)
    800043ac:	74a2                	ld	s1,40(sp)
    800043ae:	7902                	ld	s2,32(sp)
    800043b0:	69e2                	ld	s3,24(sp)
    800043b2:	6a42                	ld	s4,16(sp)
    800043b4:	6aa2                	ld	s5,8(sp)
    800043b6:	6b02                	ld	s6,0(sp)
    800043b8:	6121                	addi	sp,sp,64
    800043ba:	8082                	ret
    800043bc:	8082                	ret

00000000800043be <initlog>:
{
    800043be:	7179                	addi	sp,sp,-48
    800043c0:	f406                	sd	ra,40(sp)
    800043c2:	f022                	sd	s0,32(sp)
    800043c4:	ec26                	sd	s1,24(sp)
    800043c6:	e84a                	sd	s2,16(sp)
    800043c8:	e44e                	sd	s3,8(sp)
    800043ca:	1800                	addi	s0,sp,48
    800043cc:	892a                	mv	s2,a0
    800043ce:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800043d0:	0001a497          	auipc	s1,0x1a
    800043d4:	88848493          	addi	s1,s1,-1912 # 8001dc58 <log>
    800043d8:	00002597          	auipc	a1,0x2
    800043dc:	62058593          	addi	a1,a1,1568 # 800069f8 <syscalls+0x630>
    800043e0:	8526                	mv	a0,s1
    800043e2:	f4dfc0ef          	jal	ra,8000132e <initlock>
  log.start = sb->logstart;
    800043e6:	0149a583          	lw	a1,20(s3)
    800043ea:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800043ec:	0109a783          	lw	a5,16(s3)
    800043f0:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800043f2:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800043f6:	854a                	mv	a0,s2
    800043f8:	f56fe0ef          	jal	ra,80002b4e <bread>
  log.lh.n = lh->n;
    800043fc:	4d34                	lw	a3,88(a0)
    800043fe:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004400:	02d05663          	blez	a3,8000442c <initlog+0x6e>
    80004404:	05c50793          	addi	a5,a0,92
    80004408:	0001a717          	auipc	a4,0x1a
    8000440c:	88070713          	addi	a4,a4,-1920 # 8001dc88 <log+0x30>
    80004410:	36fd                	addiw	a3,a3,-1
    80004412:	02069613          	slli	a2,a3,0x20
    80004416:	01e65693          	srli	a3,a2,0x1e
    8000441a:	06050613          	addi	a2,a0,96
    8000441e:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004420:	4390                	lw	a2,0(a5)
    80004422:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004424:	0791                	addi	a5,a5,4
    80004426:	0711                	addi	a4,a4,4
    80004428:	fed79ce3          	bne	a5,a3,80004420 <initlog+0x62>
  brelse(buf);
    8000442c:	82bfe0ef          	jal	ra,80002c56 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004430:	4505                	li	a0,1
    80004432:	ee5ff0ef          	jal	ra,80004316 <install_trans>
  log.lh.n = 0;
    80004436:	0001a797          	auipc	a5,0x1a
    8000443a:	8407a723          	sw	zero,-1970(a5) # 8001dc84 <log+0x2c>
  write_head(); // clear the log
    8000443e:	e69ff0ef          	jal	ra,800042a6 <write_head>
}
    80004442:	70a2                	ld	ra,40(sp)
    80004444:	7402                	ld	s0,32(sp)
    80004446:	64e2                	ld	s1,24(sp)
    80004448:	6942                	ld	s2,16(sp)
    8000444a:	69a2                	ld	s3,8(sp)
    8000444c:	6145                	addi	sp,sp,48
    8000444e:	8082                	ret

0000000080004450 <begin_op>:

// called at the start of each FS system call.
// 开始登记，将outstanding++
void
begin_op(void)
{
    80004450:	1101                	addi	sp,sp,-32
    80004452:	ec06                	sd	ra,24(sp)
    80004454:	e822                	sd	s0,16(sp)
    80004456:	e426                	sd	s1,8(sp)
    80004458:	e04a                	sd	s2,0(sp)
    8000445a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000445c:	00019517          	auipc	a0,0x19
    80004460:	7fc50513          	addi	a0,a0,2044 # 8001dc58 <log>
    80004464:	f4bfc0ef          	jal	ra,800013ae <acquire>
  while(1){
    if(log.committing){
    80004468:	00019497          	auipc	s1,0x19
    8000446c:	7f048493          	addi	s1,s1,2032 # 8001dc58 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004470:	4979                	li	s2,30
    80004472:	a029                	j	8000447c <begin_op+0x2c>
      sleep(&log, &log.lock);
    80004474:	85a6                	mv	a1,s1
    80004476:	8526                	mv	a0,s1
    80004478:	aebfc0ef          	jal	ra,80000f62 <sleep>
    if(log.committing){
    8000447c:	50dc                	lw	a5,36(s1)
    8000447e:	fbfd                	bnez	a5,80004474 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004480:	5098                	lw	a4,32(s1)
    80004482:	2705                	addiw	a4,a4,1
    80004484:	0007069b          	sext.w	a3,a4
    80004488:	0027179b          	slliw	a5,a4,0x2
    8000448c:	9fb9                	addw	a5,a5,a4
    8000448e:	0017979b          	slliw	a5,a5,0x1
    80004492:	54d8                	lw	a4,44(s1)
    80004494:	9fb9                	addw	a5,a5,a4
    80004496:	00f95763          	bge	s2,a5,800044a4 <begin_op+0x54>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000449a:	85a6                	mv	a1,s1
    8000449c:	8526                	mv	a0,s1
    8000449e:	ac5fc0ef          	jal	ra,80000f62 <sleep>
    800044a2:	bfe9                	j	8000447c <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800044a4:	00019517          	auipc	a0,0x19
    800044a8:	7b450513          	addi	a0,a0,1972 # 8001dc58 <log>
    800044ac:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800044ae:	f99fc0ef          	jal	ra,80001446 <release>
      break;
    }
  }
}
    800044b2:	60e2                	ld	ra,24(sp)
    800044b4:	6442                	ld	s0,16(sp)
    800044b6:	64a2                	ld	s1,8(sp)
    800044b8:	6902                	ld	s2,0(sp)
    800044ba:	6105                	addi	sp,sp,32
    800044bc:	8082                	ret

00000000800044be <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800044be:	7139                	addi	sp,sp,-64
    800044c0:	fc06                	sd	ra,56(sp)
    800044c2:	f822                	sd	s0,48(sp)
    800044c4:	f426                	sd	s1,40(sp)
    800044c6:	f04a                	sd	s2,32(sp)
    800044c8:	ec4e                	sd	s3,24(sp)
    800044ca:	e852                	sd	s4,16(sp)
    800044cc:	e456                	sd	s5,8(sp)
    800044ce:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800044d0:	00019497          	auipc	s1,0x19
    800044d4:	78848493          	addi	s1,s1,1928 # 8001dc58 <log>
    800044d8:	8526                	mv	a0,s1
    800044da:	ed5fc0ef          	jal	ra,800013ae <acquire>
  log.outstanding -= 1;
    800044de:	509c                	lw	a5,32(s1)
    800044e0:	37fd                	addiw	a5,a5,-1
    800044e2:	0007891b          	sext.w	s2,a5
    800044e6:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800044e8:	50dc                	lw	a5,36(s1)
    800044ea:	ef9d                	bnez	a5,80004528 <end_op+0x6a>
    panic("log.committing");
  if(log.outstanding == 0){
    800044ec:	04091463          	bnez	s2,80004534 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    800044f0:	00019497          	auipc	s1,0x19
    800044f4:	76848493          	addi	s1,s1,1896 # 8001dc58 <log>
    800044f8:	4785                	li	a5,1
    800044fa:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800044fc:	8526                	mv	a0,s1
    800044fe:	f49fc0ef          	jal	ra,80001446 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004502:	54dc                	lw	a5,44(s1)
    80004504:	04f04b63          	bgtz	a5,8000455a <end_op+0x9c>
    acquire(&log.lock);
    80004508:	00019497          	auipc	s1,0x19
    8000450c:	75048493          	addi	s1,s1,1872 # 8001dc58 <log>
    80004510:	8526                	mv	a0,s1
    80004512:	e9dfc0ef          	jal	ra,800013ae <acquire>
    log.committing = 0;
    80004516:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000451a:	8526                	mv	a0,s1
    8000451c:	a93fc0ef          	jal	ra,80000fae <wakeup>
    release(&log.lock);
    80004520:	8526                	mv	a0,s1
    80004522:	f25fc0ef          	jal	ra,80001446 <release>
}
    80004526:	a00d                	j	80004548 <end_op+0x8a>
    panic("log.committing");
    80004528:	00002517          	auipc	a0,0x2
    8000452c:	4d850513          	addi	a0,a0,1240 # 80006a00 <syscalls+0x638>
    80004530:	940fc0ef          	jal	ra,80000670 <panic>
    wakeup(&log);
    80004534:	00019497          	auipc	s1,0x19
    80004538:	72448493          	addi	s1,s1,1828 # 8001dc58 <log>
    8000453c:	8526                	mv	a0,s1
    8000453e:	a71fc0ef          	jal	ra,80000fae <wakeup>
  release(&log.lock);
    80004542:	8526                	mv	a0,s1
    80004544:	f03fc0ef          	jal	ra,80001446 <release>
}
    80004548:	70e2                	ld	ra,56(sp)
    8000454a:	7442                	ld	s0,48(sp)
    8000454c:	74a2                	ld	s1,40(sp)
    8000454e:	7902                	ld	s2,32(sp)
    80004550:	69e2                	ld	s3,24(sp)
    80004552:	6a42                	ld	s4,16(sp)
    80004554:	6aa2                	ld	s5,8(sp)
    80004556:	6121                	addi	sp,sp,64
    80004558:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000455a:	00019a97          	auipc	s5,0x19
    8000455e:	72ea8a93          	addi	s5,s5,1838 # 8001dc88 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004562:	00019a17          	auipc	s4,0x19
    80004566:	6f6a0a13          	addi	s4,s4,1782 # 8001dc58 <log>
    8000456a:	018a2583          	lw	a1,24(s4)
    8000456e:	012585bb          	addw	a1,a1,s2
    80004572:	2585                	addiw	a1,a1,1
    80004574:	028a2503          	lw	a0,40(s4)
    80004578:	dd6fe0ef          	jal	ra,80002b4e <bread>
    8000457c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000457e:	000aa583          	lw	a1,0(s5)
    80004582:	028a2503          	lw	a0,40(s4)
    80004586:	dc8fe0ef          	jal	ra,80002b4e <bread>
    8000458a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000458c:	40000613          	li	a2,1024
    80004590:	05850593          	addi	a1,a0,88
    80004594:	05848513          	addi	a0,s1,88
    80004598:	ffbfc0ef          	jal	ra,80001592 <memmove>
    bwrite(to);  // write the log
    8000459c:	8526                	mv	a0,s1
    8000459e:	e86fe0ef          	jal	ra,80002c24 <bwrite>
    brelse(from);
    800045a2:	854e                	mv	a0,s3
    800045a4:	eb2fe0ef          	jal	ra,80002c56 <brelse>
    brelse(to);
    800045a8:	8526                	mv	a0,s1
    800045aa:	eacfe0ef          	jal	ra,80002c56 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800045ae:	2905                	addiw	s2,s2,1
    800045b0:	0a91                	addi	s5,s5,4
    800045b2:	02ca2783          	lw	a5,44(s4)
    800045b6:	faf94ae3          	blt	s2,a5,8000456a <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800045ba:	cedff0ef          	jal	ra,800042a6 <write_head>
    install_trans(0); // Now install writes to home locations
    800045be:	4501                	li	a0,0
    800045c0:	d57ff0ef          	jal	ra,80004316 <install_trans>
    log.lh.n = 0;
    800045c4:	00019797          	auipc	a5,0x19
    800045c8:	6c07a023          	sw	zero,1728(a5) # 8001dc84 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800045cc:	cdbff0ef          	jal	ra,800042a6 <write_head>
    800045d0:	bf25                	j	80004508 <end_op+0x4a>

00000000800045d2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800045d2:	1101                	addi	sp,sp,-32
    800045d4:	ec06                	sd	ra,24(sp)
    800045d6:	e822                	sd	s0,16(sp)
    800045d8:	e426                	sd	s1,8(sp)
    800045da:	e04a                	sd	s2,0(sp)
    800045dc:	1000                	addi	s0,sp,32
    800045de:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800045e0:	00019917          	auipc	s2,0x19
    800045e4:	67890913          	addi	s2,s2,1656 # 8001dc58 <log>
    800045e8:	854a                	mv	a0,s2
    800045ea:	dc5fc0ef          	jal	ra,800013ae <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800045ee:	02c92603          	lw	a2,44(s2)
    800045f2:	47f5                	li	a5,29
    800045f4:	06c7c363          	blt	a5,a2,8000465a <log_write+0x88>
    800045f8:	00019797          	auipc	a5,0x19
    800045fc:	67c7a783          	lw	a5,1660(a5) # 8001dc74 <log+0x1c>
    80004600:	37fd                	addiw	a5,a5,-1
    80004602:	04f65c63          	bge	a2,a5,8000465a <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004606:	00019797          	auipc	a5,0x19
    8000460a:	6727a783          	lw	a5,1650(a5) # 8001dc78 <log+0x20>
    8000460e:	04f05c63          	blez	a5,80004666 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004612:	4781                	li	a5,0
    80004614:	04c05f63          	blez	a2,80004672 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004618:	44cc                	lw	a1,12(s1)
    8000461a:	00019717          	auipc	a4,0x19
    8000461e:	66e70713          	addi	a4,a4,1646 # 8001dc88 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004622:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004624:	4314                	lw	a3,0(a4)
    80004626:	04b68663          	beq	a3,a1,80004672 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    8000462a:	2785                	addiw	a5,a5,1
    8000462c:	0711                	addi	a4,a4,4
    8000462e:	fef61be3          	bne	a2,a5,80004624 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004632:	0621                	addi	a2,a2,8
    80004634:	060a                	slli	a2,a2,0x2
    80004636:	00019797          	auipc	a5,0x19
    8000463a:	62278793          	addi	a5,a5,1570 # 8001dc58 <log>
    8000463e:	97b2                	add	a5,a5,a2
    80004640:	44d8                	lw	a4,12(s1)
    80004642:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004644:	8526                	mv	a0,s1
    80004646:	e9afe0ef          	jal	ra,80002ce0 <bpin>
    log.lh.n++;
    8000464a:	00019717          	auipc	a4,0x19
    8000464e:	60e70713          	addi	a4,a4,1550 # 8001dc58 <log>
    80004652:	575c                	lw	a5,44(a4)
    80004654:	2785                	addiw	a5,a5,1
    80004656:	d75c                	sw	a5,44(a4)
    80004658:	a80d                	j	8000468a <log_write+0xb8>
    panic("too big a transaction");
    8000465a:	00002517          	auipc	a0,0x2
    8000465e:	3b650513          	addi	a0,a0,950 # 80006a10 <syscalls+0x648>
    80004662:	80efc0ef          	jal	ra,80000670 <panic>
    panic("log_write outside of trans");
    80004666:	00002517          	auipc	a0,0x2
    8000466a:	3c250513          	addi	a0,a0,962 # 80006a28 <syscalls+0x660>
    8000466e:	802fc0ef          	jal	ra,80000670 <panic>
  log.lh.block[i] = b->blockno;
    80004672:	00878693          	addi	a3,a5,8
    80004676:	068a                	slli	a3,a3,0x2
    80004678:	00019717          	auipc	a4,0x19
    8000467c:	5e070713          	addi	a4,a4,1504 # 8001dc58 <log>
    80004680:	9736                	add	a4,a4,a3
    80004682:	44d4                	lw	a3,12(s1)
    80004684:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004686:	faf60fe3          	beq	a2,a5,80004644 <log_write+0x72>
  }
  release(&log.lock);
    8000468a:	00019517          	auipc	a0,0x19
    8000468e:	5ce50513          	addi	a0,a0,1486 # 8001dc58 <log>
    80004692:	db5fc0ef          	jal	ra,80001446 <release>
}
    80004696:	60e2                	ld	ra,24(sp)
    80004698:	6442                	ld	s0,16(sp)
    8000469a:	64a2                	ld	s1,8(sp)
    8000469c:	6902                	ld	s2,0(sp)
    8000469e:	6105                	addi	sp,sp,32
    800046a0:	8082                	ret
	...

0000000080005000 <_trampoline>:
    80005000:	14051073          	csrw	sscratch,a0
    80005004:	02000537          	lui	a0,0x2000
    80005008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000500a:	0536                	slli	a0,a0,0xd
    8000500c:	02153423          	sd	ra,40(a0)
    80005010:	02253823          	sd	sp,48(a0)
    80005014:	02353c23          	sd	gp,56(a0)
    80005018:	04453023          	sd	tp,64(a0)
    8000501c:	04553423          	sd	t0,72(a0)
    80005020:	04653823          	sd	t1,80(a0)
    80005024:	04753c23          	sd	t2,88(a0)
    80005028:	f120                	sd	s0,96(a0)
    8000502a:	f524                	sd	s1,104(a0)
    8000502c:	fd2c                	sd	a1,120(a0)
    8000502e:	e150                	sd	a2,128(a0)
    80005030:	e554                	sd	a3,136(a0)
    80005032:	e958                	sd	a4,144(a0)
    80005034:	ed5c                	sd	a5,152(a0)
    80005036:	0b053023          	sd	a6,160(a0)
    8000503a:	0b153423          	sd	a7,168(a0)
    8000503e:	0b253823          	sd	s2,176(a0)
    80005042:	0b353c23          	sd	s3,184(a0)
    80005046:	0d453023          	sd	s4,192(a0)
    8000504a:	0d553423          	sd	s5,200(a0)
    8000504e:	0d653823          	sd	s6,208(a0)
    80005052:	0d753c23          	sd	s7,216(a0)
    80005056:	0f853023          	sd	s8,224(a0)
    8000505a:	0f953423          	sd	s9,232(a0)
    8000505e:	0fa53823          	sd	s10,240(a0)
    80005062:	0fb53c23          	sd	s11,248(a0)
    80005066:	11c53023          	sd	t3,256(a0)
    8000506a:	11d53423          	sd	t4,264(a0)
    8000506e:	11e53823          	sd	t5,272(a0)
    80005072:	11f53c23          	sd	t6,280(a0)
    80005076:	140022f3          	csrr	t0,sscratch
    8000507a:	06553823          	sd	t0,112(a0)
    8000507e:	00853103          	ld	sp,8(a0)
    80005082:	02053203          	ld	tp,32(a0)
    80005086:	01053283          	ld	t0,16(a0)
    8000508a:	00053303          	ld	t1,0(a0)
    8000508e:	12000073          	sfence.vma
    80005092:	18031073          	csrw	satp,t1
    80005096:	12000073          	sfence.vma
    8000509a:	8282                	jr	t0

000000008000509c <userret>:
    8000509c:	12000073          	sfence.vma
    800050a0:	18051073          	csrw	satp,a0
    800050a4:	12000073          	sfence.vma
    800050a8:	02000537          	lui	a0,0x2000
    800050ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800050ae:	0536                	slli	a0,a0,0xd
    800050b0:	02853083          	ld	ra,40(a0)
    800050b4:	03053103          	ld	sp,48(a0)
    800050b8:	03853183          	ld	gp,56(a0)
    800050bc:	04053203          	ld	tp,64(a0)
    800050c0:	04853283          	ld	t0,72(a0)
    800050c4:	05053303          	ld	t1,80(a0)
    800050c8:	05853383          	ld	t2,88(a0)
    800050cc:	7120                	ld	s0,96(a0)
    800050ce:	7524                	ld	s1,104(a0)
    800050d0:	7d2c                	ld	a1,120(a0)
    800050d2:	6150                	ld	a2,128(a0)
    800050d4:	6554                	ld	a3,136(a0)
    800050d6:	6958                	ld	a4,144(a0)
    800050d8:	6d5c                	ld	a5,152(a0)
    800050da:	0a053803          	ld	a6,160(a0)
    800050de:	0a853883          	ld	a7,168(a0)
    800050e2:	0b053903          	ld	s2,176(a0)
    800050e6:	0b853983          	ld	s3,184(a0)
    800050ea:	0c053a03          	ld	s4,192(a0)
    800050ee:	0c853a83          	ld	s5,200(a0)
    800050f2:	0d053b03          	ld	s6,208(a0)
    800050f6:	0d853b83          	ld	s7,216(a0)
    800050fa:	0e053c03          	ld	s8,224(a0)
    800050fe:	0e853c83          	ld	s9,232(a0)
    80005102:	0f053d03          	ld	s10,240(a0)
    80005106:	0f853d83          	ld	s11,248(a0)
    8000510a:	10053e03          	ld	t3,256(a0)
    8000510e:	10853e83          	ld	t4,264(a0)
    80005112:	11053f03          	ld	t5,272(a0)
    80005116:	11853f83          	ld	t6,280(a0)
    8000511a:	7928                	ld	a0,112(a0)
    8000511c:	10200073          	sret
	...
