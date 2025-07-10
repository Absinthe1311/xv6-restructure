
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00007117          	auipc	sp,0x7
    80000004:	b1813103          	ld	sp,-1256(sp) # 80006b18 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	41c010ef          	jal	ra,80001432 <start>

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
    80000030:	0001b797          	auipc	a5,0x1b
    80000034:	ff078793          	addi	a5,a5,-16 # 8001b020 <end>
    80000038:	02f56f63          	bltu	a0,a5,80000076 <kfree+0x5a>
    8000003c:	47c5                	li	a5,17
    8000003e:	07ee                	slli	a5,a5,0x1b
    80000040:	02f57b63          	bgeu	a0,a5,80000076 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000044:	6605                	lui	a2,0x1
    80000046:	4585                	li	a1,1
    80000048:	45a010ef          	jal	ra,800014a2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    8000004c:	00007917          	auipc	s2,0x7
    80000050:	b1490913          	addi	s2,s2,-1260 # 80006b60 <kmem>
    80000054:	854a                	mv	a0,s2
    80000056:	2c4010ef          	jal	ra,8000131a <acquire>
  r->next = kmem.freelist;
    8000005a:	01893783          	ld	a5,24(s2)
    8000005e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000060:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000064:	854a                	mv	a0,s2
    80000066:	34c010ef          	jal	ra,800013b2 <release>
}
    8000006a:	60e2                	ld	ra,24(sp)
    8000006c:	6442                	ld	s0,16(sp)
    8000006e:	64a2                	ld	s1,8(sp)
    80000070:	6902                	ld	s2,0(sp)
    80000072:	6105                	addi	sp,sp,32
    80000074:	8082                	ret
    panic("kfree");
    80000076:	00005517          	auipc	a0,0x5
    8000007a:	f9a50513          	addi	a0,a0,-102 # 80005010 <etext+0x10>
    8000007e:	5ee000ef          	jal	ra,8000066c <panic>

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
    800000d2:	00005597          	auipc	a1,0x5
    800000d6:	f4658593          	addi	a1,a1,-186 # 80005018 <etext+0x18>
    800000da:	00007517          	auipc	a0,0x7
    800000de:	a8650513          	addi	a0,a0,-1402 # 80006b60 <kmem>
    800000e2:	1b8010ef          	jal	ra,8000129a <initlock>
  freerange(end, (void*)PHYSTOP);
    800000e6:	45c5                	li	a1,17
    800000e8:	05ee                	slli	a1,a1,0x1b
    800000ea:	0001b517          	auipc	a0,0x1b
    800000ee:	f3650513          	addi	a0,a0,-202 # 8001b020 <end>
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
    80000108:	00007497          	auipc	s1,0x7
    8000010c:	a5848493          	addi	s1,s1,-1448 # 80006b60 <kmem>
    80000110:	8526                	mv	a0,s1
    80000112:	208010ef          	jal	ra,8000131a <acquire>
  r = kmem.freelist;
    80000116:	6c84                	ld	s1,24(s1)
  if(r)
    80000118:	c485                	beqz	s1,80000140 <kalloc+0x42>
    kmem.freelist = r->next;
    8000011a:	609c                	ld	a5,0(s1)
    8000011c:	00007517          	auipc	a0,0x7
    80000120:	a4450513          	addi	a0,a0,-1468 # 80006b60 <kmem>
    80000124:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000126:	28c010ef          	jal	ra,800013b2 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    8000012a:	6605                	lui	a2,0x1
    8000012c:	4595                	li	a1,5
    8000012e:	8526                	mv	a0,s1
    80000130:	372010ef          	jal	ra,800014a2 <memset>
  return (void*)r;
}
    80000134:	8526                	mv	a0,s1
    80000136:	60e2                	ld	ra,24(sp)
    80000138:	6442                	ld	s0,16(sp)
    8000013a:	64a2                	ld	s1,8(sp)
    8000013c:	6105                	addi	sp,sp,32
    8000013e:	8082                	ret
  release(&kmem.lock);
    80000140:	00007517          	auipc	a0,0x7
    80000144:	a2050513          	addi	a0,a0,-1504 # 80006b60 <kmem>
    80000148:	26a010ef          	jal	ra,800013b2 <release>
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
    80000178:	4b3010ef          	jal	ra,80001e2a <kerneltrap>
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
    800001b6:	650000ef          	jal	ra,80000806 <cpuid>

    // started = 1;
    // __sync_synchronize();
    // userinit();
  } else {
    while(started == 0)
    800001ba:	00007717          	auipc	a4,0x7
    800001be:	97670713          	addi	a4,a4,-1674 # 80006b30 <started>
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
    800001ce:	638000ef          	jal	ra,80000806 <cpuid>
    800001d2:	85aa                	mv	a1,a0
    800001d4:	00005517          	auipc	a0,0x5
    800001d8:	e8450513          	addi	a0,a0,-380 # 80005058 <etext+0x58>
    800001dc:	1dc000ef          	jal	ra,800003b8 <printf>
    
    // 内存处理部分
    kvminithart();    // turn on paging
    800001e0:	6eb010ef          	jal	ra,800020ca <kvminithart>

    // 中断处理部分
    trapinithart();   // install kernel trap vector
    800001e4:	1e3010ef          	jal	ra,80001bc6 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    800001e8:	092000ef          	jal	ra,8000027a <plicinithart>
  }
  scheduler();        
    800001ec:	3a5000ef          	jal	ra,80000d90 <scheduler>
    uartinit();
    800001f0:	4cb010ef          	jal	ra,80001eba <uartinit>
    printfinit();
    800001f4:	4b2000ef          	jal	ra,800006a6 <printfinit>
    printf("\n");
    800001f8:	00005517          	auipc	a0,0x5
    800001fc:	e7050513          	addi	a0,a0,-400 # 80005068 <etext+0x68>
    80000200:	1b8000ef          	jal	ra,800003b8 <printf>
    printf("xv6 kernel is booting\n");
    80000204:	00005517          	auipc	a0,0x5
    80000208:	e1c50513          	addi	a0,a0,-484 # 80005020 <etext+0x20>
    8000020c:	1ac000ef          	jal	ra,800003b8 <printf>
    printf("\n");
    80000210:	00005517          	auipc	a0,0x5
    80000214:	e5850513          	addi	a0,a0,-424 # 80005068 <etext+0x68>
    80000218:	1a0000ef          	jal	ra,800003b8 <printf>
    kinit();         // physical page allocator
    8000021c:	eafff0ef          	jal	ra,800000ca <kinit>
    kvminit();       // create kernel page table
    80000220:	134020ef          	jal	ra,80002354 <kvminit>
    kvminithart();   // turn on paging
    80000224:	6a7010ef          	jal	ra,800020ca <kvminithart>
    procinit();      // 恢复为了原来的procinit()
    80000228:	536000ef          	jal	ra,8000075e <procinit>
    printf("xv6 passed the procinit()\n");
    8000022c:	00005517          	auipc	a0,0x5
    80000230:	e0c50513          	addi	a0,a0,-500 # 80005038 <etext+0x38>
    80000234:	184000ef          	jal	ra,800003b8 <printf>
    trapinit();      // trap vectors
    80000238:	16b010ef          	jal	ra,80001ba2 <trapinit>
    trapinithart();  // install kernel trap vector
    8000023c:	18b010ef          	jal	ra,80001bc6 <trapinithart>
    plicinit();      // set up interrupt controller
    80000240:	024000ef          	jal	ra,80000264 <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000244:	036000ef          	jal	ra,8000027a <plicinithart>
    binit();         // buffer cache
    80000248:	6c0020ef          	jal	ra,80002908 <binit>
    virtio_disk_init(); // emulated hard disk 磁盘的初始化
    8000024c:	2b1020ef          	jal	ra,80002cfc <virtio_disk_init>
    userinit();
    80000250:	02d000ef          	jal	ra,80000a7c <userinit>
    __sync_synchronize();
    80000254:	0ff0000f          	fence
    started = 1;
    80000258:	4785                	li	a5,1
    8000025a:	00007717          	auipc	a4,0x7
    8000025e:	8cf72b23          	sw	a5,-1834(a4) # 80006b30 <started>
    80000262:	b769                	j	800001ec <main+0x3e>

0000000080000264 <plicinit>:
// 文件直接使用了xv6标准文件，应该没有错误 //
//////////////////////////////////////////

void
plicinit(void)
{
    80000264:	1141                	addi	sp,sp,-16
    80000266:	e422                	sd	s0,8(sp)
    80000268:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    8000026a:	0c0007b7          	lui	a5,0xc000
    8000026e:	4705                	li	a4,1
    80000270:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80000272:	c3d8                	sw	a4,4(a5)
}
    80000274:	6422                	ld	s0,8(sp)
    80000276:	0141                	addi	sp,sp,16
    80000278:	8082                	ret

000000008000027a <plicinithart>:

void
plicinithart(void)
{
    8000027a:	1141                	addi	sp,sp,-16
    8000027c:	e406                	sd	ra,8(sp)
    8000027e:	e022                	sd	s0,0(sp)
    80000280:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80000282:	584000ef          	jal	ra,80000806 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80000286:	0085171b          	slliw	a4,a0,0x8
    8000028a:	0c0027b7          	lui	a5,0xc002
    8000028e:	97ba                	add	a5,a5,a4
    80000290:	40200713          	li	a4,1026
    80000294:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80000298:	00d5151b          	slliw	a0,a0,0xd
    8000029c:	0c2017b7          	lui	a5,0xc201
    800002a0:	97aa                	add	a5,a5,a0
    800002a2:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800002a6:	60a2                	ld	ra,8(sp)
    800002a8:	6402                	ld	s0,0(sp)
    800002aa:	0141                	addi	sp,sp,16
    800002ac:	8082                	ret

00000000800002ae <plic_claim>:

// ask the PLIC what interrupt we should serve.
// 从PLIC取出当前哪个设备发出了中断，返回设备的IRQ号
int
plic_claim(void)
{
    800002ae:	1141                	addi	sp,sp,-16
    800002b0:	e406                	sd	ra,8(sp)
    800002b2:	e022                	sd	s0,0(sp)
    800002b4:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800002b6:	550000ef          	jal	ra,80000806 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800002ba:	00d5151b          	slliw	a0,a0,0xd
    800002be:	0c2017b7          	lui	a5,0xc201
    800002c2:	97aa                	add	a5,a5,a0
  return irq;
}
    800002c4:	43c8                	lw	a0,4(a5)
    800002c6:	60a2                	ld	ra,8(sp)
    800002c8:	6402                	ld	s0,0(sp)
    800002ca:	0141                	addi	sp,sp,16
    800002cc:	8082                	ret

00000000800002ce <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800002ce:	1101                	addi	sp,sp,-32
    800002d0:	ec06                	sd	ra,24(sp)
    800002d2:	e822                	sd	s0,16(sp)
    800002d4:	e426                	sd	s1,8(sp)
    800002d6:	1000                	addi	s0,sp,32
    800002d8:	84aa                	mv	s1,a0
  int hart = cpuid();
    800002da:	52c000ef          	jal	ra,80000806 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800002de:	00d5151b          	slliw	a0,a0,0xd
    800002e2:	0c2017b7          	lui	a5,0xc201
    800002e6:	97aa                	add	a5,a5,a0
    800002e8:	c3c4                	sw	s1,4(a5)
}
    800002ea:	60e2                	ld	ra,24(sp)
    800002ec:	6442                	ld	s0,16(sp)
    800002ee:	64a2                	ld	s1,8(sp)
    800002f0:	6105                	addi	sp,sp,32
    800002f2:	8082                	ret

00000000800002f4 <pputc>:
////////////////////////////
// 这个函数添加用于替代console.c中的consputc()函数 后续需要的话将pputc修改回来
# define BACKSPACE 0x100
void
pputc(int c)
{
    800002f4:	1141                	addi	sp,sp,-16
    800002f6:	e406                	sd	ra,8(sp)
    800002f8:	e022                	sd	s0,0(sp)
    800002fa:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    800002fc:	10000793          	li	a5,256
    80000300:	00f50863          	beq	a0,a5,80000310 <pputc+0x1c>
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
  }
  else
  {
    uartputc_sync(c);
    80000304:	403010ef          	jal	ra,80001f06 <uartputc_sync>
  }
}
    80000308:	60a2                	ld	ra,8(sp)
    8000030a:	6402                	ld	s0,0(sp)
    8000030c:	0141                	addi	sp,sp,16
    8000030e:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000310:	4521                	li	a0,8
    80000312:	3f5010ef          	jal	ra,80001f06 <uartputc_sync>
    80000316:	02000513          	li	a0,32
    8000031a:	3ed010ef          	jal	ra,80001f06 <uartputc_sync>
    8000031e:	4521                	li	a0,8
    80000320:	3e7010ef          	jal	ra,80001f06 <uartputc_sync>
    80000324:	b7d5                	j	80000308 <pputc+0x14>

0000000080000326 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000326:	7179                	addi	sp,sp,-48
    80000328:	f406                	sd	ra,40(sp)
    8000032a:	f022                	sd	s0,32(sp)
    8000032c:	ec26                	sd	s1,24(sp)
    8000032e:	e84a                	sd	s2,16(sp)
    80000330:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000332:	c219                	beqz	a2,80000338 <printint+0x12>
    80000334:	06054e63          	bltz	a0,800003b0 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80000338:	4881                	li	a7,0
    8000033a:	fd040693          	addi	a3,s0,-48

  i = 0;
    8000033e:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000340:	00005617          	auipc	a2,0x5
    80000344:	d5060613          	addi	a2,a2,-688 # 80005090 <digits>
    80000348:	883e                	mv	a6,a5
    8000034a:	2785                	addiw	a5,a5,1 # c201001 <_entry-0x73dfefff>
    8000034c:	02b57733          	remu	a4,a0,a1
    80000350:	9732                	add	a4,a4,a2
    80000352:	00074703          	lbu	a4,0(a4)
    80000356:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    8000035a:	872a                	mv	a4,a0
    8000035c:	02b55533          	divu	a0,a0,a1
    80000360:	0685                	addi	a3,a3,1
    80000362:	feb773e3          	bgeu	a4,a1,80000348 <printint+0x22>

  if(sign)
    80000366:	00088a63          	beqz	a7,8000037a <printint+0x54>
    buf[i++] = '-';
    8000036a:	1781                	addi	a5,a5,-32
    8000036c:	97a2                	add	a5,a5,s0
    8000036e:	02d00713          	li	a4,45
    80000372:	fee78823          	sb	a4,-16(a5)
    80000376:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    8000037a:	02f05563          	blez	a5,800003a4 <printint+0x7e>
    8000037e:	fd040713          	addi	a4,s0,-48
    80000382:	00f704b3          	add	s1,a4,a5
    80000386:	fff70913          	addi	s2,a4,-1
    8000038a:	993e                	add	s2,s2,a5
    8000038c:	37fd                	addiw	a5,a5,-1
    8000038e:	1782                	slli	a5,a5,0x20
    80000390:	9381                	srli	a5,a5,0x20
    80000392:	40f90933          	sub	s2,s2,a5
    //consputc(buf[i]);
    pputc(buf[i]);
    80000396:	fff4c503          	lbu	a0,-1(s1)
    8000039a:	f5bff0ef          	jal	ra,800002f4 <pputc>
  while(--i >= 0)
    8000039e:	14fd                	addi	s1,s1,-1
    800003a0:	ff249be3          	bne	s1,s2,80000396 <printint+0x70>
}
    800003a4:	70a2                	ld	ra,40(sp)
    800003a6:	7402                	ld	s0,32(sp)
    800003a8:	64e2                	ld	s1,24(sp)
    800003aa:	6942                	ld	s2,16(sp)
    800003ac:	6145                	addi	sp,sp,48
    800003ae:	8082                	ret
    x = -xx;
    800003b0:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800003b4:	4885                	li	a7,1
    x = -xx;
    800003b6:	b751                	j	8000033a <printint+0x14>

00000000800003b8 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800003b8:	7155                	addi	sp,sp,-208
    800003ba:	e506                	sd	ra,136(sp)
    800003bc:	e122                	sd	s0,128(sp)
    800003be:	fca6                	sd	s1,120(sp)
    800003c0:	f8ca                	sd	s2,112(sp)
    800003c2:	f4ce                	sd	s3,104(sp)
    800003c4:	f0d2                	sd	s4,96(sp)
    800003c6:	ecd6                	sd	s5,88(sp)
    800003c8:	e8da                	sd	s6,80(sp)
    800003ca:	e4de                	sd	s7,72(sp)
    800003cc:	e0e2                	sd	s8,64(sp)
    800003ce:	fc66                	sd	s9,56(sp)
    800003d0:	f86a                	sd	s10,48(sp)
    800003d2:	f46e                	sd	s11,40(sp)
    800003d4:	0900                	addi	s0,sp,144
    800003d6:	8a2a                	mv	s4,a0
    800003d8:	e40c                	sd	a1,8(s0)
    800003da:	e810                	sd	a2,16(s0)
    800003dc:	ec14                	sd	a3,24(s0)
    800003de:	f018                	sd	a4,32(s0)
    800003e0:	f41c                	sd	a5,40(s0)
    800003e2:	03043823          	sd	a6,48(s0)
    800003e6:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800003ea:	00006797          	auipc	a5,0x6
    800003ee:	7ae7a783          	lw	a5,1966(a5) # 80006b98 <pr+0x18>
    800003f2:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800003f6:	eb9d                	bnez	a5,8000042c <printf+0x74>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800003f8:	00840793          	addi	a5,s0,8
    800003fc:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000400:	00054503          	lbu	a0,0(a0)
    80000404:	24050463          	beqz	a0,8000064c <printf+0x294>
    80000408:	4981                	li	s3,0
    if(cx != '%'){
    8000040a:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    8000040e:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    80000412:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80000416:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    8000041a:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    8000041e:	07000d93          	li	s11,112
    pputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000422:	00005b97          	auipc	s7,0x5
    80000426:	c6eb8b93          	addi	s7,s7,-914 # 80005090 <digits>
    8000042a:	a081                	j	8000046a <printf+0xb2>
    acquire(&pr.lock);
    8000042c:	00006517          	auipc	a0,0x6
    80000430:	75450513          	addi	a0,a0,1876 # 80006b80 <pr>
    80000434:	6e7000ef          	jal	ra,8000131a <acquire>
  va_start(ap, fmt);
    80000438:	00840793          	addi	a5,s0,8
    8000043c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000440:	000a4503          	lbu	a0,0(s4) # fffffffffffff000 <end+0xffffffff7ffe3fe0>
    80000444:	f171                	bnez	a0,80000408 <printf+0x50>
#endif
  }
  va_end(ap);

  if(locking)
    release(&pr.lock);
    80000446:	00006517          	auipc	a0,0x6
    8000044a:	73a50513          	addi	a0,a0,1850 # 80006b80 <pr>
    8000044e:	765000ef          	jal	ra,800013b2 <release>
    80000452:	aaed                	j	8000064c <printf+0x294>
      pputc(cx);
    80000454:	ea1ff0ef          	jal	ra,800002f4 <pputc>
      continue;
    80000458:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000045a:	0014899b          	addiw	s3,s1,1
    8000045e:	013a07b3          	add	a5,s4,s3
    80000462:	0007c503          	lbu	a0,0(a5)
    80000466:	1c050f63          	beqz	a0,80000644 <printf+0x28c>
    if(cx != '%'){
    8000046a:	ff5515e3          	bne	a0,s5,80000454 <printf+0x9c>
    i++;
    8000046e:	0019849b          	addiw	s1,s3,1 # 1001 <_entry-0x7fffefff>
    c0 = fmt[i+0] & 0xff;
    80000472:	009a07b3          	add	a5,s4,s1
    80000476:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000047a:	1c090563          	beqz	s2,80000644 <printf+0x28c>
    8000047e:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000482:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000484:	c789                	beqz	a5,8000048e <printf+0xd6>
    80000486:	009a0733          	add	a4,s4,s1
    8000048a:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    8000048e:	03690463          	beq	s2,s6,800004b6 <printf+0xfe>
    } else if(c0 == 'l' && c1 == 'd'){
    80000492:	03890e63          	beq	s2,s8,800004ce <printf+0x116>
    } else if(c0 == 'u'){
    80000496:	0b990d63          	beq	s2,s9,80000550 <printf+0x198>
    } else if(c0 == 'x'){
    8000049a:	11a90363          	beq	s2,s10,800005a0 <printf+0x1e8>
    } else if(c0 == 'p'){
    8000049e:	13b90b63          	beq	s2,s11,800005d4 <printf+0x21c>
    } else if(c0 == 's'){
    800004a2:	07300793          	li	a5,115
    800004a6:	16f90363          	beq	s2,a5,8000060c <printf+0x254>
    } else if(c0 == '%'){
    800004aa:	03591c63          	bne	s2,s5,800004e2 <printf+0x12a>
      pputc('%');
    800004ae:	8556                	mv	a0,s5
    800004b0:	e45ff0ef          	jal	ra,800002f4 <pputc>
    800004b4:	b75d                	j	8000045a <printf+0xa2>
      printint(va_arg(ap, int), 10, 1);
    800004b6:	f8843783          	ld	a5,-120(s0)
    800004ba:	00878713          	addi	a4,a5,8
    800004be:	f8e43423          	sd	a4,-120(s0)
    800004c2:	4605                	li	a2,1
    800004c4:	45a9                	li	a1,10
    800004c6:	4388                	lw	a0,0(a5)
    800004c8:	e5fff0ef          	jal	ra,80000326 <printint>
    800004cc:	b779                	j	8000045a <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'd'){
    800004ce:	03678163          	beq	a5,s6,800004f0 <printf+0x138>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800004d2:	03878d63          	beq	a5,s8,8000050c <printf+0x154>
    } else if(c0 == 'l' && c1 == 'u'){
    800004d6:	09978963          	beq	a5,s9,80000568 <printf+0x1b0>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800004da:	03878b63          	beq	a5,s8,80000510 <printf+0x158>
    } else if(c0 == 'l' && c1 == 'x'){
    800004de:	0da78d63          	beq	a5,s10,800005b8 <printf+0x200>
      pputc('%');
    800004e2:	8556                	mv	a0,s5
    800004e4:	e11ff0ef          	jal	ra,800002f4 <pputc>
      pputc(c0);
    800004e8:	854a                	mv	a0,s2
    800004ea:	e0bff0ef          	jal	ra,800002f4 <pputc>
    800004ee:	b7b5                	j	8000045a <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    800004f0:	f8843783          	ld	a5,-120(s0)
    800004f4:	00878713          	addi	a4,a5,8
    800004f8:	f8e43423          	sd	a4,-120(s0)
    800004fc:	4605                	li	a2,1
    800004fe:	45a9                	li	a1,10
    80000500:	6388                	ld	a0,0(a5)
    80000502:	e25ff0ef          	jal	ra,80000326 <printint>
      i += 1;
    80000506:	0029849b          	addiw	s1,s3,2
    8000050a:	bf81                	j	8000045a <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000050c:	03668463          	beq	a3,s6,80000534 <printf+0x17c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000510:	07968a63          	beq	a3,s9,80000584 <printf+0x1cc>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    80000514:	fda697e3          	bne	a3,s10,800004e2 <printf+0x12a>
      printint(va_arg(ap, uint64), 16, 0);
    80000518:	f8843783          	ld	a5,-120(s0)
    8000051c:	00878713          	addi	a4,a5,8
    80000520:	f8e43423          	sd	a4,-120(s0)
    80000524:	4601                	li	a2,0
    80000526:	45c1                	li	a1,16
    80000528:	6388                	ld	a0,0(a5)
    8000052a:	dfdff0ef          	jal	ra,80000326 <printint>
      i += 2;
    8000052e:	0039849b          	addiw	s1,s3,3
    80000532:	b725                	j	8000045a <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    80000534:	f8843783          	ld	a5,-120(s0)
    80000538:	00878713          	addi	a4,a5,8
    8000053c:	f8e43423          	sd	a4,-120(s0)
    80000540:	4605                	li	a2,1
    80000542:	45a9                	li	a1,10
    80000544:	6388                	ld	a0,0(a5)
    80000546:	de1ff0ef          	jal	ra,80000326 <printint>
      i += 2;
    8000054a:	0039849b          	addiw	s1,s3,3
    8000054e:	b731                	j	8000045a <printf+0xa2>
      printint(va_arg(ap, int), 10, 0);
    80000550:	f8843783          	ld	a5,-120(s0)
    80000554:	00878713          	addi	a4,a5,8
    80000558:	f8e43423          	sd	a4,-120(s0)
    8000055c:	4601                	li	a2,0
    8000055e:	45a9                	li	a1,10
    80000560:	4388                	lw	a0,0(a5)
    80000562:	dc5ff0ef          	jal	ra,80000326 <printint>
    80000566:	bdd5                	j	8000045a <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    80000568:	f8843783          	ld	a5,-120(s0)
    8000056c:	00878713          	addi	a4,a5,8
    80000570:	f8e43423          	sd	a4,-120(s0)
    80000574:	4601                	li	a2,0
    80000576:	45a9                	li	a1,10
    80000578:	6388                	ld	a0,0(a5)
    8000057a:	dadff0ef          	jal	ra,80000326 <printint>
      i += 1;
    8000057e:	0029849b          	addiw	s1,s3,2
    80000582:	bde1                	j	8000045a <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    80000584:	f8843783          	ld	a5,-120(s0)
    80000588:	00878713          	addi	a4,a5,8
    8000058c:	f8e43423          	sd	a4,-120(s0)
    80000590:	4601                	li	a2,0
    80000592:	45a9                	li	a1,10
    80000594:	6388                	ld	a0,0(a5)
    80000596:	d91ff0ef          	jal	ra,80000326 <printint>
      i += 2;
    8000059a:	0039849b          	addiw	s1,s3,3
    8000059e:	bd75                	j	8000045a <printf+0xa2>
      printint(va_arg(ap, int), 16, 0);
    800005a0:	f8843783          	ld	a5,-120(s0)
    800005a4:	00878713          	addi	a4,a5,8
    800005a8:	f8e43423          	sd	a4,-120(s0)
    800005ac:	4601                	li	a2,0
    800005ae:	45c1                	li	a1,16
    800005b0:	4388                	lw	a0,0(a5)
    800005b2:	d75ff0ef          	jal	ra,80000326 <printint>
    800005b6:	b555                	j	8000045a <printf+0xa2>
      printint(va_arg(ap, uint64), 16, 0);
    800005b8:	f8843783          	ld	a5,-120(s0)
    800005bc:	00878713          	addi	a4,a5,8
    800005c0:	f8e43423          	sd	a4,-120(s0)
    800005c4:	4601                	li	a2,0
    800005c6:	45c1                	li	a1,16
    800005c8:	6388                	ld	a0,0(a5)
    800005ca:	d5dff0ef          	jal	ra,80000326 <printint>
      i += 1;
    800005ce:	0029849b          	addiw	s1,s3,2
    800005d2:	b561                	j	8000045a <printf+0xa2>
      printptr(va_arg(ap, uint64));
    800005d4:	f8843783          	ld	a5,-120(s0)
    800005d8:	00878713          	addi	a4,a5,8
    800005dc:	f8e43423          	sd	a4,-120(s0)
    800005e0:	0007b983          	ld	s3,0(a5)
  pputc('0');
    800005e4:	03000513          	li	a0,48
    800005e8:	d0dff0ef          	jal	ra,800002f4 <pputc>
  pputc('x');
    800005ec:	856a                	mv	a0,s10
    800005ee:	d07ff0ef          	jal	ra,800002f4 <pputc>
    800005f2:	4941                	li	s2,16
    pputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005f4:	03c9d793          	srli	a5,s3,0x3c
    800005f8:	97de                	add	a5,a5,s7
    800005fa:	0007c503          	lbu	a0,0(a5)
    800005fe:	cf7ff0ef          	jal	ra,800002f4 <pputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000602:	0992                	slli	s3,s3,0x4
    80000604:	397d                	addiw	s2,s2,-1
    80000606:	fe0917e3          	bnez	s2,800005f4 <printf+0x23c>
    8000060a:	bd81                	j	8000045a <printf+0xa2>
      if((s = va_arg(ap, char*)) == 0)
    8000060c:	f8843783          	ld	a5,-120(s0)
    80000610:	00878713          	addi	a4,a5,8
    80000614:	f8e43423          	sd	a4,-120(s0)
    80000618:	0007b903          	ld	s2,0(a5)
    8000061c:	00090d63          	beqz	s2,80000636 <printf+0x27e>
      for(; *s; s++)
    80000620:	00094503          	lbu	a0,0(s2)
    80000624:	e2050be3          	beqz	a0,8000045a <printf+0xa2>
        pputc(*s);
    80000628:	ccdff0ef          	jal	ra,800002f4 <pputc>
      for(; *s; s++)
    8000062c:	0905                	addi	s2,s2,1
    8000062e:	00094503          	lbu	a0,0(s2)
    80000632:	f97d                	bnez	a0,80000628 <printf+0x270>
    80000634:	b51d                	j	8000045a <printf+0xa2>
        s = "(null)";
    80000636:	00005917          	auipc	s2,0x5
    8000063a:	a3a90913          	addi	s2,s2,-1478 # 80005070 <etext+0x70>
      for(; *s; s++)
    8000063e:	02800513          	li	a0,40
    80000642:	b7dd                	j	80000628 <printf+0x270>
  if(locking)
    80000644:	f7843783          	ld	a5,-136(s0)
    80000648:	de079fe3          	bnez	a5,80000446 <printf+0x8e>

  return 0;
}
    8000064c:	4501                	li	a0,0
    8000064e:	60aa                	ld	ra,136(sp)
    80000650:	640a                	ld	s0,128(sp)
    80000652:	74e6                	ld	s1,120(sp)
    80000654:	7946                	ld	s2,112(sp)
    80000656:	79a6                	ld	s3,104(sp)
    80000658:	7a06                	ld	s4,96(sp)
    8000065a:	6ae6                	ld	s5,88(sp)
    8000065c:	6b46                	ld	s6,80(sp)
    8000065e:	6ba6                	ld	s7,72(sp)
    80000660:	6c06                	ld	s8,64(sp)
    80000662:	7ce2                	ld	s9,56(sp)
    80000664:	7d42                	ld	s10,48(sp)
    80000666:	7da2                	ld	s11,40(sp)
    80000668:	6169                	addi	sp,sp,208
    8000066a:	8082                	ret

000000008000066c <panic>:

void
panic(char *s)
{
    8000066c:	1101                	addi	sp,sp,-32
    8000066e:	ec06                	sd	ra,24(sp)
    80000670:	e822                	sd	s0,16(sp)
    80000672:	e426                	sd	s1,8(sp)
    80000674:	1000                	addi	s0,sp,32
    80000676:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000678:	00006797          	auipc	a5,0x6
    8000067c:	5207a023          	sw	zero,1312(a5) # 80006b98 <pr+0x18>
  printf("panic: ");
    80000680:	00005517          	auipc	a0,0x5
    80000684:	9f850513          	addi	a0,a0,-1544 # 80005078 <etext+0x78>
    80000688:	d31ff0ef          	jal	ra,800003b8 <printf>
  printf("%s\n", s);
    8000068c:	85a6                	mv	a1,s1
    8000068e:	00005517          	auipc	a0,0x5
    80000692:	9f250513          	addi	a0,a0,-1550 # 80005080 <etext+0x80>
    80000696:	d23ff0ef          	jal	ra,800003b8 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000069a:	4785                	li	a5,1
    8000069c:	00006717          	auipc	a4,0x6
    800006a0:	48f72c23          	sw	a5,1176(a4) # 80006b34 <panicked>
  for(;;)
    800006a4:	a001                	j	800006a4 <panic+0x38>

00000000800006a6 <printfinit>:
    ;
}

void
printfinit(void)
{
    800006a6:	1101                	addi	sp,sp,-32
    800006a8:	ec06                	sd	ra,24(sp)
    800006aa:	e822                	sd	s0,16(sp)
    800006ac:	e426                	sd	s1,8(sp)
    800006ae:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800006b0:	00006497          	auipc	s1,0x6
    800006b4:	4d048493          	addi	s1,s1,1232 # 80006b80 <pr>
    800006b8:	00005597          	auipc	a1,0x5
    800006bc:	9d058593          	addi	a1,a1,-1584 # 80005088 <etext+0x88>
    800006c0:	8526                	mv	a0,s1
    800006c2:	3d9000ef          	jal	ra,8000129a <initlock>

   // 使用printf.c直接替代console.c中的打印函数，需要在这里初始化串口

  pr.locking = 1;
    800006c6:	4785                	li	a5,1
    800006c8:	cc9c                	sw	a5,24(s1)
}
    800006ca:	60e2                	ld	ra,24(sp)
    800006cc:	6442                	ld	s0,16(sp)
    800006ce:	64a2                	ld	s1,8(sp)
    800006d0:	6105                	addi	sp,sp,32
    800006d2:	8082                	ret

00000000800006d4 <proc_mapstacks>:
// Map it high in memory, followed by an invalid
// guard page.
// 原来是将所有进程分配的栈记录在内核页表上面，现在只有一个proc结构体
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800006d4:	7139                	addi	sp,sp,-64
    800006d6:	fc06                	sd	ra,56(sp)
    800006d8:	f822                	sd	s0,48(sp)
    800006da:	f426                	sd	s1,40(sp)
    800006dc:	f04a                	sd	s2,32(sp)
    800006de:	ec4e                	sd	s3,24(sp)
    800006e0:	e852                	sd	s4,16(sp)
    800006e2:	e456                	sd	s5,8(sp)
    800006e4:	e05a                	sd	s6,0(sp)
    800006e6:	0080                	addi	s0,sp,64
    800006e8:	89aa                	mv	s3,a0
  struct proc *p;
  for(p = proc; p < &proc[NPROC]; p++) {
    800006ea:	00007497          	auipc	s1,0x7
    800006ee:	8e648493          	addi	s1,s1,-1818 # 80006fd0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800006f2:	8b26                	mv	s6,s1
    800006f4:	00005a97          	auipc	s5,0x5
    800006f8:	90ca8a93          	addi	s5,s5,-1780 # 80005000 <etext>
    800006fc:	04000937          	lui	s2,0x4000
    80000700:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80000702:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000704:	0000aa17          	auipc	s4,0xa
    80000708:	0cca0a13          	addi	s4,s4,204 # 8000a7d0 <stack0>
    char *pa = kalloc();
    8000070c:	9f3ff0ef          	jal	ra,800000fe <kalloc>
    80000710:	862a                	mv	a2,a0
    if(pa == 0)
    80000712:	c121                	beqz	a0,80000752 <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    80000714:	416485b3          	sub	a1,s1,s6
    80000718:	8595                	srai	a1,a1,0x5
    8000071a:	000ab783          	ld	a5,0(s5)
    8000071e:	02f585b3          	mul	a1,a1,a5
    80000722:	2585                	addiw	a1,a1,1
    80000724:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000728:	4719                	li	a4,6
    8000072a:	6685                	lui	a3,0x1
    8000072c:	40b905b3          	sub	a1,s2,a1
    80000730:	854e                	mv	a0,s3
    80000732:	349010ef          	jal	ra,8000227a <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000736:	0e048493          	addi	s1,s1,224
    8000073a:	fd4499e3          	bne	s1,s4,8000070c <proc_mapstacks+0x38>
  }
}
    8000073e:	70e2                	ld	ra,56(sp)
    80000740:	7442                	ld	s0,48(sp)
    80000742:	74a2                	ld	s1,40(sp)
    80000744:	7902                	ld	s2,32(sp)
    80000746:	69e2                	ld	s3,24(sp)
    80000748:	6a42                	ld	s4,16(sp)
    8000074a:	6aa2                	ld	s5,8(sp)
    8000074c:	6b02                	ld	s6,0(sp)
    8000074e:	6121                	addi	sp,sp,64
    80000750:	8082                	ret
      panic("kalloc");
    80000752:	00005517          	auipc	a0,0x5
    80000756:	95650513          	addi	a0,a0,-1706 # 800050a8 <digits+0x18>
    8000075a:	f13ff0ef          	jal	ra,8000066c <panic>

000000008000075e <procinit>:

// initialize the proc table.
// 恢复原来的procinit
void
procinit(void)
{
    8000075e:	7139                	addi	sp,sp,-64
    80000760:	fc06                	sd	ra,56(sp)
    80000762:	f822                	sd	s0,48(sp)
    80000764:	f426                	sd	s1,40(sp)
    80000766:	f04a                	sd	s2,32(sp)
    80000768:	ec4e                	sd	s3,24(sp)
    8000076a:	e852                	sd	s4,16(sp)
    8000076c:	e456                	sd	s5,8(sp)
    8000076e:	e05a                	sd	s6,0(sp)
    80000770:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80000772:	00005597          	auipc	a1,0x5
    80000776:	93e58593          	addi	a1,a1,-1730 # 800050b0 <digits+0x20>
    8000077a:	00006517          	auipc	a0,0x6
    8000077e:	42650513          	addi	a0,a0,1062 # 80006ba0 <pid_lock>
    80000782:	319000ef          	jal	ra,8000129a <initlock>
  initlock(&wait_lock, "wait_lock");
    80000786:	00005597          	auipc	a1,0x5
    8000078a:	93258593          	addi	a1,a1,-1742 # 800050b8 <digits+0x28>
    8000078e:	00006517          	auipc	a0,0x6
    80000792:	42a50513          	addi	a0,a0,1066 # 80006bb8 <wait_lock>
    80000796:	305000ef          	jal	ra,8000129a <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000079a:	00007497          	auipc	s1,0x7
    8000079e:	83648493          	addi	s1,s1,-1994 # 80006fd0 <proc>
      initlock(&p->lock, "proc");
    800007a2:	00005b17          	auipc	s6,0x5
    800007a6:	926b0b13          	addi	s6,s6,-1754 # 800050c8 <digits+0x38>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    800007aa:	8aa6                	mv	s5,s1
    800007ac:	00005a17          	auipc	s4,0x5
    800007b0:	854a0a13          	addi	s4,s4,-1964 # 80005000 <etext>
    800007b4:	04000937          	lui	s2,0x4000
    800007b8:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    800007ba:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800007bc:	0000a997          	auipc	s3,0xa
    800007c0:	01498993          	addi	s3,s3,20 # 8000a7d0 <stack0>
      initlock(&p->lock, "proc");
    800007c4:	85da                	mv	a1,s6
    800007c6:	8526                	mv	a0,s1
    800007c8:	2d3000ef          	jal	ra,8000129a <initlock>
      p->state = UNUSED;
    800007cc:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800007d0:	415487b3          	sub	a5,s1,s5
    800007d4:	8795                	srai	a5,a5,0x5
    800007d6:	000a3703          	ld	a4,0(s4)
    800007da:	02e787b3          	mul	a5,a5,a4
    800007de:	2785                	addiw	a5,a5,1
    800007e0:	00d7979b          	slliw	a5,a5,0xd
    800007e4:	40f907b3          	sub	a5,s2,a5
    800007e8:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800007ea:	0e048493          	addi	s1,s1,224
    800007ee:	fd349be3          	bne	s1,s3,800007c4 <procinit+0x66>
  }
}
    800007f2:	70e2                	ld	ra,56(sp)
    800007f4:	7442                	ld	s0,48(sp)
    800007f6:	74a2                	ld	s1,40(sp)
    800007f8:	7902                	ld	s2,32(sp)
    800007fa:	69e2                	ld	s3,24(sp)
    800007fc:	6a42                	ld	s4,16(sp)
    800007fe:	6aa2                	ld	s5,8(sp)
    80000800:	6b02                	ld	s6,0(sp)
    80000802:	6121                	addi	sp,sp,64
    80000804:	8082                	ret

0000000080000806 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80000806:	1141                	addi	sp,sp,-16
    80000808:	e422                	sd	s0,8(sp)
    8000080a:	0800                	addi	s0,sp,16
// this core's hartid (core number), the index into cpus[].
static inline uint64
r_tp()
{
  uint64 x;
  asm volatile("mv %0, tp" : "=r" (x) );
    8000080c:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000080e:	2501                	sext.w	a0,a0
    80000810:	6422                	ld	s0,8(sp)
    80000812:	0141                	addi	sp,sp,16
    80000814:	8082                	ret

0000000080000816 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80000816:	1141                	addi	sp,sp,-16
    80000818:	e422                	sd	s0,8(sp)
    8000081a:	0800                	addi	s0,sp,16
    8000081c:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    8000081e:	2781                	sext.w	a5,a5
    80000820:	079e                	slli	a5,a5,0x7
  return c;
}
    80000822:	00006517          	auipc	a0,0x6
    80000826:	3ae50513          	addi	a0,a0,942 # 80006bd0 <cpus>
    8000082a:	953e                	add	a0,a0,a5
    8000082c:	6422                	ld	s0,8(sp)
    8000082e:	0141                	addi	sp,sp,16
    80000830:	8082                	ret

0000000080000832 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80000832:	1101                	addi	sp,sp,-32
    80000834:	ec06                	sd	ra,24(sp)
    80000836:	e822                	sd	s0,16(sp)
    80000838:	e426                	sd	s1,8(sp)
    8000083a:	1000                	addi	s0,sp,32
  push_off();
    8000083c:	29f000ef          	jal	ra,800012da <push_off>
    80000840:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000842:	2781                	sext.w	a5,a5
    80000844:	079e                	slli	a5,a5,0x7
    80000846:	00006717          	auipc	a4,0x6
    8000084a:	35a70713          	addi	a4,a4,858 # 80006ba0 <pid_lock>
    8000084e:	97ba                	add	a5,a5,a4
    80000850:	7b84                	ld	s1,48(a5)
  pop_off();
    80000852:	30d000ef          	jal	ra,8000135e <pop_off>
  return p;
}
    80000856:	8526                	mv	a0,s1
    80000858:	60e2                	ld	ra,24(sp)
    8000085a:	6442                	ld	s0,16(sp)
    8000085c:	64a2                	ld	s1,8(sp)
    8000085e:	6105                	addi	sp,sp,32
    80000860:	8082                	ret

0000000080000862 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80000862:	1141                	addi	sp,sp,-16
    80000864:	e406                	sd	ra,8(sp)
    80000866:	e022                	sd	s0,0(sp)
    80000868:	0800                	addi	s0,sp,16
  //static int first = 1; unused

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    8000086a:	fc9ff0ef          	jal	ra,80000832 <myproc>
    8000086e:	345000ef          	jal	ra,800013b2 <release>
  //   // ensure other cores see first=0.
  //   __sync_synchronize();
  // }
  
  // 通过这个切换到用户态去
  usertrapret();
    80000872:	36c010ef          	jal	ra,80001bde <usertrapret>
}
    80000876:	60a2                	ld	ra,8(sp)
    80000878:	6402                	ld	s0,0(sp)
    8000087a:	0141                	addi	sp,sp,16
    8000087c:	8082                	ret

000000008000087e <allocpid>:
{
    8000087e:	1101                	addi	sp,sp,-32
    80000880:	ec06                	sd	ra,24(sp)
    80000882:	e822                	sd	s0,16(sp)
    80000884:	e426                	sd	s1,8(sp)
    80000886:	e04a                	sd	s2,0(sp)
    80000888:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    8000088a:	00006917          	auipc	s2,0x6
    8000088e:	31690913          	addi	s2,s2,790 # 80006ba0 <pid_lock>
    80000892:	854a                	mv	a0,s2
    80000894:	287000ef          	jal	ra,8000131a <acquire>
  pid = nextpid;
    80000898:	00005797          	auipc	a5,0x5
    8000089c:	03878793          	addi	a5,a5,56 # 800058d0 <nextpid>
    800008a0:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800008a2:	0014871b          	addiw	a4,s1,1
    800008a6:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800008a8:	854a                	mv	a0,s2
    800008aa:	309000ef          	jal	ra,800013b2 <release>
}
    800008ae:	8526                	mv	a0,s1
    800008b0:	60e2                	ld	ra,24(sp)
    800008b2:	6442                	ld	s0,16(sp)
    800008b4:	64a2                	ld	s1,8(sp)
    800008b6:	6902                	ld	s2,0(sp)
    800008b8:	6105                	addi	sp,sp,32
    800008ba:	8082                	ret

00000000800008bc <proc_pagetable>:
{
    800008bc:	1101                	addi	sp,sp,-32
    800008be:	ec06                	sd	ra,24(sp)
    800008c0:	e822                	sd	s0,16(sp)
    800008c2:	e426                	sd	s1,8(sp)
    800008c4:	e04a                	sd	s2,0(sp)
    800008c6:	1000                	addi	s0,sp,32
    800008c8:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800008ca:	353010ef          	jal	ra,8000241c <uvmcreate>
    800008ce:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800008d0:	cd05                	beqz	a0,80000908 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    800008d2:	4729                	li	a4,10
    800008d4:	00003697          	auipc	a3,0x3
    800008d8:	72c68693          	addi	a3,a3,1836 # 80004000 <_trampoline>
    800008dc:	6605                	lui	a2,0x1
    800008de:	040005b7          	lui	a1,0x4000
    800008e2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800008e4:	05b2                	slli	a1,a1,0xc
    800008e6:	0e5010ef          	jal	ra,800021ca <mappages>
    800008ea:	02054663          	bltz	a0,80000916 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800008ee:	4719                	li	a4,6
    800008f0:	05893683          	ld	a3,88(s2)
    800008f4:	6605                	lui	a2,0x1
    800008f6:	020005b7          	lui	a1,0x2000
    800008fa:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800008fc:	05b6                	slli	a1,a1,0xd
    800008fe:	8526                	mv	a0,s1
    80000900:	0cb010ef          	jal	ra,800021ca <mappages>
    80000904:	00054f63          	bltz	a0,80000922 <proc_pagetable+0x66>
}
    80000908:	8526                	mv	a0,s1
    8000090a:	60e2                	ld	ra,24(sp)
    8000090c:	6442                	ld	s0,16(sp)
    8000090e:	64a2                	ld	s1,8(sp)
    80000910:	6902                	ld	s2,0(sp)
    80000912:	6105                	addi	sp,sp,32
    80000914:	8082                	ret
    uvmfree(pagetable, 0);
    80000916:	4581                	li	a1,0
    80000918:	8526                	mv	a0,s1
    8000091a:	4c5010ef          	jal	ra,800025de <uvmfree>
    return 0;
    8000091e:	4481                	li	s1,0
    80000920:	b7e5                	j	80000908 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000922:	4681                	li	a3,0
    80000924:	4605                	li	a2,1
    80000926:	040005b7          	lui	a1,0x4000
    8000092a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000092c:	05b2                	slli	a1,a1,0xc
    8000092e:	8526                	mv	a0,s1
    80000930:	241010ef          	jal	ra,80002370 <uvmunmap>
    uvmfree(pagetable, 0);
    80000934:	4581                	li	a1,0
    80000936:	8526                	mv	a0,s1
    80000938:	4a7010ef          	jal	ra,800025de <uvmfree>
    return 0;
    8000093c:	4481                	li	s1,0
    8000093e:	b7e9                	j	80000908 <proc_pagetable+0x4c>

0000000080000940 <proc_freepagetable>:
{
    80000940:	1101                	addi	sp,sp,-32
    80000942:	ec06                	sd	ra,24(sp)
    80000944:	e822                	sd	s0,16(sp)
    80000946:	e426                	sd	s1,8(sp)
    80000948:	e04a                	sd	s2,0(sp)
    8000094a:	1000                	addi	s0,sp,32
    8000094c:	84aa                	mv	s1,a0
    8000094e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000950:	4681                	li	a3,0
    80000952:	4605                	li	a2,1
    80000954:	040005b7          	lui	a1,0x4000
    80000958:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000095a:	05b2                	slli	a1,a1,0xc
    8000095c:	215010ef          	jal	ra,80002370 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80000960:	4681                	li	a3,0
    80000962:	4605                	li	a2,1
    80000964:	020005b7          	lui	a1,0x2000
    80000968:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    8000096a:	05b6                	slli	a1,a1,0xd
    8000096c:	8526                	mv	a0,s1
    8000096e:	203010ef          	jal	ra,80002370 <uvmunmap>
  uvmfree(pagetable, sz);
    80000972:	85ca                	mv	a1,s2
    80000974:	8526                	mv	a0,s1
    80000976:	469010ef          	jal	ra,800025de <uvmfree>
}
    8000097a:	60e2                	ld	ra,24(sp)
    8000097c:	6442                	ld	s0,16(sp)
    8000097e:	64a2                	ld	s1,8(sp)
    80000980:	6902                	ld	s2,0(sp)
    80000982:	6105                	addi	sp,sp,32
    80000984:	8082                	ret

0000000080000986 <freeproc>:
{
    80000986:	1101                	addi	sp,sp,-32
    80000988:	ec06                	sd	ra,24(sp)
    8000098a:	e822                	sd	s0,16(sp)
    8000098c:	e426                	sd	s1,8(sp)
    8000098e:	1000                	addi	s0,sp,32
    80000990:	84aa                	mv	s1,a0
  if(p->trapframe)
    80000992:	6d28                	ld	a0,88(a0)
    80000994:	c119                	beqz	a0,8000099a <freeproc+0x14>
    kfree((void*)p->trapframe);
    80000996:	e86ff0ef          	jal	ra,8000001c <kfree>
  p->trapframe = 0;
    8000099a:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    8000099e:	68a8                	ld	a0,80(s1)
    800009a0:	c501                	beqz	a0,800009a8 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    800009a2:	64ac                	ld	a1,72(s1)
    800009a4:	f9dff0ef          	jal	ra,80000940 <proc_freepagetable>
  p->pagetable = 0;
    800009a8:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    800009ac:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    800009b0:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    800009b4:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    800009b8:	0c048823          	sb	zero,208(s1)
  p->chan = 0;
    800009bc:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    800009c0:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    800009c4:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    800009c8:	0004ac23          	sw	zero,24(s1)
}
    800009cc:	60e2                	ld	ra,24(sp)
    800009ce:	6442                	ld	s0,16(sp)
    800009d0:	64a2                	ld	s1,8(sp)
    800009d2:	6105                	addi	sp,sp,32
    800009d4:	8082                	ret

00000000800009d6 <allocproc>:
{
    800009d6:	1101                	addi	sp,sp,-32
    800009d8:	ec06                	sd	ra,24(sp)
    800009da:	e822                	sd	s0,16(sp)
    800009dc:	e426                	sd	s1,8(sp)
    800009de:	e04a                	sd	s2,0(sp)
    800009e0:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    800009e2:	00006497          	auipc	s1,0x6
    800009e6:	5ee48493          	addi	s1,s1,1518 # 80006fd0 <proc>
    800009ea:	0000a917          	auipc	s2,0xa
    800009ee:	de690913          	addi	s2,s2,-538 # 8000a7d0 <stack0>
    acquire(&p->lock);
    800009f2:	8526                	mv	a0,s1
    800009f4:	127000ef          	jal	ra,8000131a <acquire>
    if(p->state == UNUSED) {
    800009f8:	4c9c                	lw	a5,24(s1)
    800009fa:	cb91                	beqz	a5,80000a0e <allocproc+0x38>
      release(&p->lock);
    800009fc:	8526                	mv	a0,s1
    800009fe:	1b5000ef          	jal	ra,800013b2 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000a02:	0e048493          	addi	s1,s1,224
    80000a06:	ff2496e3          	bne	s1,s2,800009f2 <allocproc+0x1c>
  return 0;
    80000a0a:	4481                	li	s1,0
    80000a0c:	a089                	j	80000a4e <allocproc+0x78>
  p->pid = allocpid();
    80000a0e:	e71ff0ef          	jal	ra,8000087e <allocpid>
    80000a12:	d888                	sw	a0,48(s1)
  p->state = USED;
    80000a14:	4785                	li	a5,1
    80000a16:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80000a18:	ee6ff0ef          	jal	ra,800000fe <kalloc>
    80000a1c:	892a                	mv	s2,a0
    80000a1e:	eca8                	sd	a0,88(s1)
    80000a20:	cd15                	beqz	a0,80000a5c <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80000a22:	8526                	mv	a0,s1
    80000a24:	e99ff0ef          	jal	ra,800008bc <proc_pagetable>
    80000a28:	892a                	mv	s2,a0
    80000a2a:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80000a2c:	c121                	beqz	a0,80000a6c <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80000a2e:	07000613          	li	a2,112
    80000a32:	4581                	li	a1,0
    80000a34:	06048513          	addi	a0,s1,96
    80000a38:	26b000ef          	jal	ra,800014a2 <memset>
  p->context.ra = (uint64)forkret;
    80000a3c:	00000797          	auipc	a5,0x0
    80000a40:	e2678793          	addi	a5,a5,-474 # 80000862 <forkret>
    80000a44:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80000a46:	60bc                	ld	a5,64(s1)
    80000a48:	6705                	lui	a4,0x1
    80000a4a:	97ba                	add	a5,a5,a4
    80000a4c:	f4bc                	sd	a5,104(s1)
}
    80000a4e:	8526                	mv	a0,s1
    80000a50:	60e2                	ld	ra,24(sp)
    80000a52:	6442                	ld	s0,16(sp)
    80000a54:	64a2                	ld	s1,8(sp)
    80000a56:	6902                	ld	s2,0(sp)
    80000a58:	6105                	addi	sp,sp,32
    80000a5a:	8082                	ret
    freeproc(p);
    80000a5c:	8526                	mv	a0,s1
    80000a5e:	f29ff0ef          	jal	ra,80000986 <freeproc>
    release(&p->lock);
    80000a62:	8526                	mv	a0,s1
    80000a64:	14f000ef          	jal	ra,800013b2 <release>
    return 0;
    80000a68:	84ca                	mv	s1,s2
    80000a6a:	b7d5                	j	80000a4e <allocproc+0x78>
    freeproc(p);
    80000a6c:	8526                	mv	a0,s1
    80000a6e:	f19ff0ef          	jal	ra,80000986 <freeproc>
    release(&p->lock);
    80000a72:	8526                	mv	a0,s1
    80000a74:	13f000ef          	jal	ra,800013b2 <release>
    return 0;
    80000a78:	84ca                	mv	s1,s2
    80000a7a:	bfd1                	j	80000a4e <allocproc+0x78>

0000000080000a7c <userinit>:
{
    80000a7c:	1101                	addi	sp,sp,-32
    80000a7e:	ec06                	sd	ra,24(sp)
    80000a80:	e822                	sd	s0,16(sp)
    80000a82:	e426                	sd	s1,8(sp)
    80000a84:	e04a                	sd	s2,0(sp)
    80000a86:	1000                	addi	s0,sp,32
  p = allocproc();
    80000a88:	f4fff0ef          	jal	ra,800009d6 <allocproc>
    80000a8c:	84aa                	mv	s1,a0
  initproc = p;
    80000a8e:	00006797          	auipc	a5,0x6
    80000a92:	0aa7b523          	sd	a0,170(a5) # 80006b38 <initproc>
  printf("initcode size: %ld bytes (PGSIZE: %d)\n", sizeof(initcode), PGSIZE);
    80000a96:	6605                	lui	a2,0x1
    80000a98:	6585                	lui	a1,0x1
    80000a9a:	23058593          	addi	a1,a1,560 # 1230 <_entry-0x7fffedd0>
    80000a9e:	00004517          	auipc	a0,0x4
    80000aa2:	63250513          	addi	a0,a0,1586 # 800050d0 <digits+0x40>
    80000aa6:	913ff0ef          	jal	ra,800003b8 <printf>
    printf("initcode is larger than one page, handling manually\n");
    80000aaa:	00004517          	auipc	a0,0x4
    80000aae:	64e50513          	addi	a0,a0,1614 # 800050f8 <digits+0x68>
    80000ab2:	907ff0ef          	jal	ra,800003b8 <printf>
    char *mem1 = kalloc();
    80000ab6:	e48ff0ef          	jal	ra,800000fe <kalloc>
    if(mem1 == 0)
    80000aba:	12050163          	beqz	a0,80000bdc <userinit+0x160>
    80000abe:	892a                	mv	s2,a0
    memset(mem1, 0, PGSIZE);
    80000ac0:	6605                	lui	a2,0x1
    80000ac2:	4581                	li	a1,0
    80000ac4:	1df000ef          	jal	ra,800014a2 <memset>
    memmove(mem1, initcode, PGSIZE);
    80000ac8:	6605                	lui	a2,0x1
    80000aca:	00005597          	auipc	a1,0x5
    80000ace:	e1658593          	addi	a1,a1,-490 # 800058e0 <initcode>
    80000ad2:	854a                	mv	a0,s2
    80000ad4:	22b000ef          	jal	ra,800014fe <memmove>
    if(mappages(p->pagetable, 0, PGSIZE, (uint64)mem1, PTE_W|PTE_R|PTE_X|PTE_U) < 0){
    80000ad8:	4779                	li	a4,30
    80000ada:	86ca                	mv	a3,s2
    80000adc:	6605                	lui	a2,0x1
    80000ade:	4581                	li	a1,0
    80000ae0:	68a8                	ld	a0,80(s1)
    80000ae2:	6e8010ef          	jal	ra,800021ca <mappages>
    80000ae6:	10054163          	bltz	a0,80000be8 <userinit+0x16c>
    char *mem2 = kalloc();
    80000aea:	e14ff0ef          	jal	ra,800000fe <kalloc>
    80000aee:	892a                	mv	s2,a0
    if(mem2 == 0)
    80000af0:	10050563          	beqz	a0,80000bfa <userinit+0x17e>
    memset(mem2, 0, PGSIZE);
    80000af4:	6605                	lui	a2,0x1
    80000af6:	4581                	li	a1,0
    80000af8:	1ab000ef          	jal	ra,800014a2 <memset>
    memmove(mem2, initcode + PGSIZE, remaining);
    80000afc:	23000613          	li	a2,560
    80000b00:	00006597          	auipc	a1,0x6
    80000b04:	de058593          	addi	a1,a1,-544 # 800068e0 <initcode+0x1000>
    80000b08:	854a                	mv	a0,s2
    80000b0a:	1f5000ef          	jal	ra,800014fe <memmove>
    if(mappages(p->pagetable, PGSIZE, PGSIZE, (uint64)mem2, PTE_W|PTE_R|PTE_X|PTE_U) < 0){
    80000b0e:	4779                	li	a4,30
    80000b10:	86ca                	mv	a3,s2
    80000b12:	6605                	lui	a2,0x1
    80000b14:	6585                	lui	a1,0x1
    80000b16:	68a8                	ld	a0,80(s1)
    80000b18:	6b2010ef          	jal	ra,800021ca <mappages>
    80000b1c:	0e054563          	bltz	a0,80000c06 <userinit+0x18a>
    p->sz = 2*PGSIZE;  // Program now takes 2 pages
    80000b20:	6789                	lui	a5,0x2
    80000b22:	e4bc                	sd	a5,72(s1)
  char *data1 = kalloc();
    80000b24:	ddaff0ef          	jal	ra,800000fe <kalloc>
    80000b28:	892a                	mv	s2,a0
  if(data1 == 0)
    80000b2a:	0e050763          	beqz	a0,80000c18 <userinit+0x19c>
  memset(data1, 0, PGSIZE);
    80000b2e:	6605                	lui	a2,0x1
    80000b30:	4581                	li	a1,0
    80000b32:	171000ef          	jal	ra,800014a2 <memset>
  if(mappages(p->pagetable, p->sz, PGSIZE, (uint64)data1, PTE_W|PTE_R|PTE_U) < 0){
    80000b36:	4759                	li	a4,22
    80000b38:	86ca                	mv	a3,s2
    80000b3a:	6605                	lui	a2,0x1
    80000b3c:	64ac                	ld	a1,72(s1)
    80000b3e:	68a8                	ld	a0,80(s1)
    80000b40:	68a010ef          	jal	ra,800021ca <mappages>
    80000b44:	0e054063          	bltz	a0,80000c24 <userinit+0x1a8>
  p->sz += PGSIZE;
    80000b48:	64bc                	ld	a5,72(s1)
    80000b4a:	6705                	lui	a4,0x1
    80000b4c:	97ba                	add	a5,a5,a4
    80000b4e:	e4bc                	sd	a5,72(s1)
  char *data2 = kalloc();
    80000b50:	daeff0ef          	jal	ra,800000fe <kalloc>
    80000b54:	892a                	mv	s2,a0
  if(data2 == 0)
    80000b56:	0e050063          	beqz	a0,80000c36 <userinit+0x1ba>
  memset(data2, 0, PGSIZE);
    80000b5a:	6605                	lui	a2,0x1
    80000b5c:	4581                	li	a1,0
    80000b5e:	145000ef          	jal	ra,800014a2 <memset>
  if(mappages(p->pagetable, p->sz, PGSIZE, (uint64)data2, PTE_W|PTE_R|PTE_U) < 0){
    80000b62:	4759                	li	a4,22
    80000b64:	86ca                	mv	a3,s2
    80000b66:	6605                	lui	a2,0x1
    80000b68:	64ac                	ld	a1,72(s1)
    80000b6a:	68a8                	ld	a0,80(s1)
    80000b6c:	65e010ef          	jal	ra,800021ca <mappages>
    80000b70:	0c054963          	bltz	a0,80000c42 <userinit+0x1c6>
  p->sz += PGSIZE;
    80000b74:	64bc                	ld	a5,72(s1)
    80000b76:	6705                	lui	a4,0x1
    80000b78:	97ba                	add	a5,a5,a4
    80000b7a:	e4bc                	sd	a5,72(s1)
  char *stack = kalloc();
    80000b7c:	d82ff0ef          	jal	ra,800000fe <kalloc>
    80000b80:	892a                	mv	s2,a0
  if(stack == 0)
    80000b82:	0c050963          	beqz	a0,80000c54 <userinit+0x1d8>
  memset(stack, 0, PGSIZE);
    80000b86:	6605                	lui	a2,0x1
    80000b88:	4581                	li	a1,0
    80000b8a:	119000ef          	jal	ra,800014a2 <memset>
  if(mappages(p->pagetable, p->sz, PGSIZE, (uint64)stack, PTE_W|PTE_R|PTE_U) < 0){
    80000b8e:	4759                	li	a4,22
    80000b90:	86ca                	mv	a3,s2
    80000b92:	6605                	lui	a2,0x1
    80000b94:	64ac                	ld	a1,72(s1)
    80000b96:	68a8                	ld	a0,80(s1)
    80000b98:	632010ef          	jal	ra,800021ca <mappages>
    80000b9c:	0c054263          	bltz	a0,80000c60 <userinit+0x1e4>
  uint64 stack_top = p->sz + PGSIZE;
    80000ba0:	64b8                	ld	a4,72(s1)
    80000ba2:	6785                	lui	a5,0x1
    80000ba4:	97ba                	add	a5,a5,a4
  p->sz += PGSIZE;
    80000ba6:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0x6ec;        // 子健的initcode，检查发现没有问题
    80000ba8:	6cb8                	ld	a4,88(s1)
    80000baa:	6ec00693          	li	a3,1772
    80000bae:	ef14                	sd	a3,24(a4)
  p->trapframe->sp = stack_top;   // user stack pointer
    80000bb0:	6cb8                	ld	a4,88(s1)
    80000bb2:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80000bb4:	4641                	li	a2,16
    80000bb6:	00004597          	auipc	a1,0x4
    80000bba:	72258593          	addi	a1,a1,1826 # 800052d8 <digits+0x248>
    80000bbe:	0d048513          	addi	a0,s1,208
    80000bc2:	227000ef          	jal	ra,800015e8 <safestrcpy>
  p->state = RUNNABLE;
    80000bc6:	478d                	li	a5,3
    80000bc8:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80000bca:	8526                	mv	a0,s1
    80000bcc:	7e6000ef          	jal	ra,800013b2 <release>
}
    80000bd0:	60e2                	ld	ra,24(sp)
    80000bd2:	6442                	ld	s0,16(sp)
    80000bd4:	64a2                	ld	s1,8(sp)
    80000bd6:	6902                	ld	s2,0(sp)
    80000bd8:	6105                	addi	sp,sp,32
    80000bda:	8082                	ret
      panic("userinit: out of memory for program page 1");
    80000bdc:	00004517          	auipc	a0,0x4
    80000be0:	55450513          	addi	a0,a0,1364 # 80005130 <digits+0xa0>
    80000be4:	a89ff0ef          	jal	ra,8000066c <panic>
      kfree(mem1);
    80000be8:	854a                	mv	a0,s2
    80000bea:	c32ff0ef          	jal	ra,8000001c <kfree>
      panic("userinit: can't map program page 1");
    80000bee:	00004517          	auipc	a0,0x4
    80000bf2:	57250513          	addi	a0,a0,1394 # 80005160 <digits+0xd0>
    80000bf6:	a77ff0ef          	jal	ra,8000066c <panic>
      panic("userinit: out of memory for program page 2");
    80000bfa:	00004517          	auipc	a0,0x4
    80000bfe:	58e50513          	addi	a0,a0,1422 # 80005188 <digits+0xf8>
    80000c02:	a6bff0ef          	jal	ra,8000066c <panic>
      kfree(mem2);
    80000c06:	854a                	mv	a0,s2
    80000c08:	c14ff0ef          	jal	ra,8000001c <kfree>
      panic("userinit: can't map program page 2");
    80000c0c:	00004517          	auipc	a0,0x4
    80000c10:	5ac50513          	addi	a0,a0,1452 # 800051b8 <digits+0x128>
    80000c14:	a59ff0ef          	jal	ra,8000066c <panic>
    panic("userinit: out of memory for global data page 1");
    80000c18:	00004517          	auipc	a0,0x4
    80000c1c:	5c850513          	addi	a0,a0,1480 # 800051e0 <digits+0x150>
    80000c20:	a4dff0ef          	jal	ra,8000066c <panic>
    kfree(data1);
    80000c24:	854a                	mv	a0,s2
    80000c26:	bf6ff0ef          	jal	ra,8000001c <kfree>
    panic("userinit: can't map global data page 1");
    80000c2a:	00004517          	auipc	a0,0x4
    80000c2e:	5e650513          	addi	a0,a0,1510 # 80005210 <digits+0x180>
    80000c32:	a3bff0ef          	jal	ra,8000066c <panic>
    panic("userinit: out of memory for global data page 2");
    80000c36:	00004517          	auipc	a0,0x4
    80000c3a:	60250513          	addi	a0,a0,1538 # 80005238 <digits+0x1a8>
    80000c3e:	a2fff0ef          	jal	ra,8000066c <panic>
    kfree(data2);
    80000c42:	854a                	mv	a0,s2
    80000c44:	bd8ff0ef          	jal	ra,8000001c <kfree>
    panic("userinit: can't map global data page 2");
    80000c48:	00004517          	auipc	a0,0x4
    80000c4c:	62050513          	addi	a0,a0,1568 # 80005268 <digits+0x1d8>
    80000c50:	a1dff0ef          	jal	ra,8000066c <panic>
    panic("userinit: out of memory for stack");
    80000c54:	00004517          	auipc	a0,0x4
    80000c58:	63c50513          	addi	a0,a0,1596 # 80005290 <digits+0x200>
    80000c5c:	a11ff0ef          	jal	ra,8000066c <panic>
    kfree(stack);
    80000c60:	854a                	mv	a0,s2
    80000c62:	bbaff0ef          	jal	ra,8000001c <kfree>
    panic("userinit: can't map stack page");
    80000c66:	00004517          	auipc	a0,0x4
    80000c6a:	65250513          	addi	a0,a0,1618 # 800052b8 <digits+0x228>
    80000c6e:	9ffff0ef          	jal	ra,8000066c <panic>

0000000080000c72 <growproc>:
{
    80000c72:	1101                	addi	sp,sp,-32
    80000c74:	ec06                	sd	ra,24(sp)
    80000c76:	e822                	sd	s0,16(sp)
    80000c78:	e426                	sd	s1,8(sp)
    80000c7a:	e04a                	sd	s2,0(sp)
    80000c7c:	1000                	addi	s0,sp,32
    80000c7e:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80000c80:	bb3ff0ef          	jal	ra,80000832 <myproc>
    80000c84:	84aa                	mv	s1,a0
  sz = p->sz;
    80000c86:	652c                	ld	a1,72(a0)
  if(n > 0){
    80000c88:	01204c63          	bgtz	s2,80000ca0 <growproc+0x2e>
  } else if(n < 0){
    80000c8c:	02094463          	bltz	s2,80000cb4 <growproc+0x42>
  p->sz = sz;
    80000c90:	e4ac                	sd	a1,72(s1)
  return 0;
    80000c92:	4501                	li	a0,0
}
    80000c94:	60e2                	ld	ra,24(sp)
    80000c96:	6442                	ld	s0,16(sp)
    80000c98:	64a2                	ld	s1,8(sp)
    80000c9a:	6902                	ld	s2,0(sp)
    80000c9c:	6105                	addi	sp,sp,32
    80000c9e:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80000ca0:	4691                	li	a3,4
    80000ca2:	00b90633          	add	a2,s2,a1
    80000ca6:	6928                	ld	a0,80(a0)
    80000ca8:	03d010ef          	jal	ra,800024e4 <uvmalloc>
    80000cac:	85aa                	mv	a1,a0
    80000cae:	f16d                	bnez	a0,80000c90 <growproc+0x1e>
      return -1;
    80000cb0:	557d                	li	a0,-1
    80000cb2:	b7cd                	j	80000c94 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80000cb4:	00b90633          	add	a2,s2,a1
    80000cb8:	6928                	ld	a0,80(a0)
    80000cba:	7e6010ef          	jal	ra,800024a0 <uvmdealloc>
    80000cbe:	85aa                	mv	a1,a0
    80000cc0:	bfc1                	j	80000c90 <growproc+0x1e>

0000000080000cc2 <fork>:
{
    80000cc2:	7179                	addi	sp,sp,-48
    80000cc4:	f406                	sd	ra,40(sp)
    80000cc6:	f022                	sd	s0,32(sp)
    80000cc8:	ec26                	sd	s1,24(sp)
    80000cca:	e84a                	sd	s2,16(sp)
    80000ccc:	e44e                	sd	s3,8(sp)
    80000cce:	e052                	sd	s4,0(sp)
    80000cd0:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80000cd2:	b61ff0ef          	jal	ra,80000832 <myproc>
    80000cd6:	8a2a                	mv	s4,a0
  if((np = allocproc()) == 0){
    80000cd8:	cffff0ef          	jal	ra,800009d6 <allocproc>
    80000cdc:	c945                	beqz	a0,80000d8c <fork+0xca>
    80000cde:	84aa                	mv	s1,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80000ce0:	048a3603          	ld	a2,72(s4)
    80000ce4:	692c                	ld	a1,80(a0)
    80000ce6:	050a3503          	ld	a0,80(s4)
    80000cea:	127010ef          	jal	ra,80002610 <uvmcopy>
    80000cee:	08054763          	bltz	a0,80000d7c <fork+0xba>
  np->sz = p->sz;
    80000cf2:	048a3783          	ld	a5,72(s4)
    80000cf6:	e4bc                	sd	a5,72(s1)
  *(np->trapframe) = *(p->trapframe);
    80000cf8:	058a3683          	ld	a3,88(s4)
    80000cfc:	87b6                	mv	a5,a3
    80000cfe:	6cb8                	ld	a4,88(s1)
    80000d00:	12068693          	addi	a3,a3,288
    80000d04:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80000d08:	6788                	ld	a0,8(a5)
    80000d0a:	6b8c                	ld	a1,16(a5)
    80000d0c:	6f90                	ld	a2,24(a5)
    80000d0e:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80000d12:	e708                	sd	a0,8(a4)
    80000d14:	eb0c                	sd	a1,16(a4)
    80000d16:	ef10                	sd	a2,24(a4)
    80000d18:	02078793          	addi	a5,a5,32
    80000d1c:	02070713          	addi	a4,a4,32
    80000d20:	fed792e3          	bne	a5,a3,80000d04 <fork+0x42>
  np->trapframe->a0 = 0;
    80000d24:	6cbc                	ld	a5,88(s1)
    80000d26:	0607b823          	sd	zero,112(a5)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80000d2a:	4641                	li	a2,16
    80000d2c:	0d0a0593          	addi	a1,s4,208
    80000d30:	0d048513          	addi	a0,s1,208
    80000d34:	0b5000ef          	jal	ra,800015e8 <safestrcpy>
  pid = np->pid;
    80000d38:	0304a983          	lw	s3,48(s1)
  release(&np->lock);
    80000d3c:	8526                	mv	a0,s1
    80000d3e:	674000ef          	jal	ra,800013b2 <release>
  acquire(&wait_lock);
    80000d42:	00006917          	auipc	s2,0x6
    80000d46:	e7690913          	addi	s2,s2,-394 # 80006bb8 <wait_lock>
    80000d4a:	854a                	mv	a0,s2
    80000d4c:	5ce000ef          	jal	ra,8000131a <acquire>
  np->parent = p;
    80000d50:	0344bc23          	sd	s4,56(s1)
  release(&wait_lock);
    80000d54:	854a                	mv	a0,s2
    80000d56:	65c000ef          	jal	ra,800013b2 <release>
  acquire(&np->lock);
    80000d5a:	8526                	mv	a0,s1
    80000d5c:	5be000ef          	jal	ra,8000131a <acquire>
  np->state = RUNNABLE;
    80000d60:	478d                	li	a5,3
    80000d62:	cc9c                	sw	a5,24(s1)
  release(&np->lock);
    80000d64:	8526                	mv	a0,s1
    80000d66:	64c000ef          	jal	ra,800013b2 <release>
}
    80000d6a:	854e                	mv	a0,s3
    80000d6c:	70a2                	ld	ra,40(sp)
    80000d6e:	7402                	ld	s0,32(sp)
    80000d70:	64e2                	ld	s1,24(sp)
    80000d72:	6942                	ld	s2,16(sp)
    80000d74:	69a2                	ld	s3,8(sp)
    80000d76:	6a02                	ld	s4,0(sp)
    80000d78:	6145                	addi	sp,sp,48
    80000d7a:	8082                	ret
    freeproc(np);
    80000d7c:	8526                	mv	a0,s1
    80000d7e:	c09ff0ef          	jal	ra,80000986 <freeproc>
    release(&np->lock);
    80000d82:	8526                	mv	a0,s1
    80000d84:	62e000ef          	jal	ra,800013b2 <release>
    return -1;
    80000d88:	59fd                	li	s3,-1
    80000d8a:	b7c5                	j	80000d6a <fork+0xa8>
    return -1;
    80000d8c:	59fd                	li	s3,-1
    80000d8e:	bff1                	j	80000d6a <fork+0xa8>

0000000080000d90 <scheduler>:
{
    80000d90:	715d                	addi	sp,sp,-80
    80000d92:	e486                	sd	ra,72(sp)
    80000d94:	e0a2                	sd	s0,64(sp)
    80000d96:	fc26                	sd	s1,56(sp)
    80000d98:	f84a                	sd	s2,48(sp)
    80000d9a:	f44e                	sd	s3,40(sp)
    80000d9c:	f052                	sd	s4,32(sp)
    80000d9e:	ec56                	sd	s5,24(sp)
    80000da0:	e85a                	sd	s6,16(sp)
    80000da2:	e45e                	sd	s7,8(sp)
    80000da4:	e062                	sd	s8,0(sp)
    80000da6:	0880                	addi	s0,sp,80
    80000da8:	8792                	mv	a5,tp
  int id = r_tp();
    80000daa:	2781                	sext.w	a5,a5
  c->proc = 0;
    80000dac:	00779b13          	slli	s6,a5,0x7
    80000db0:	00006717          	auipc	a4,0x6
    80000db4:	df070713          	addi	a4,a4,-528 # 80006ba0 <pid_lock>
    80000db8:	975a                	add	a4,a4,s6
    80000dba:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80000dbe:	00006717          	auipc	a4,0x6
    80000dc2:	e1a70713          	addi	a4,a4,-486 # 80006bd8 <cpus+0x8>
    80000dc6:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80000dc8:	4c11                	li	s8,4
        c->proc = p;
    80000dca:	079e                	slli	a5,a5,0x7
    80000dcc:	00006a17          	auipc	s4,0x6
    80000dd0:	dd4a0a13          	addi	s4,s4,-556 # 80006ba0 <pid_lock>
    80000dd4:	9a3e                	add	s4,s4,a5
        found = 1;
    80000dd6:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80000dd8:	0000a997          	auipc	s3,0xa
    80000ddc:	9f898993          	addi	s3,s3,-1544 # 8000a7d0 <stack0>
    80000de0:	a0a9                	j	80000e2a <scheduler+0x9a>
      release(&p->lock);
    80000de2:	8526                	mv	a0,s1
    80000de4:	5ce000ef          	jal	ra,800013b2 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80000de8:	0e048493          	addi	s1,s1,224
    80000dec:	03348563          	beq	s1,s3,80000e16 <scheduler+0x86>
      acquire(&p->lock);
    80000df0:	8526                	mv	a0,s1
    80000df2:	528000ef          	jal	ra,8000131a <acquire>
      if(p->state == RUNNABLE) {
    80000df6:	4c9c                	lw	a5,24(s1)
    80000df8:	ff2795e3          	bne	a5,s2,80000de2 <scheduler+0x52>
        p->state = RUNNING;
    80000dfc:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80000e00:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80000e04:	06048593          	addi	a1,s1,96
    80000e08:	855a                	mv	a0,s6
    80000e0a:	03b000ef          	jal	ra,80001644 <swtch>
        c->proc = 0;
    80000e0e:	020a3823          	sd	zero,48(s4)
        found = 1;
    80000e12:	8ade                	mv	s5,s7
    80000e14:	b7f9                	j	80000de2 <scheduler+0x52>
    if(found == 0) {
    80000e16:	000a9a63          	bnez	s5,80000e2a <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000e1a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000e1e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000e22:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80000e26:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000e2a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000e2e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000e32:	10079073          	csrw	sstatus,a5
    int found = 0;
    80000e36:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80000e38:	00006497          	auipc	s1,0x6
    80000e3c:	19848493          	addi	s1,s1,408 # 80006fd0 <proc>
      if(p->state == RUNNABLE) {
    80000e40:	490d                	li	s2,3
    80000e42:	b77d                	j	80000df0 <scheduler+0x60>

0000000080000e44 <sched>:
{
    80000e44:	7179                	addi	sp,sp,-48
    80000e46:	f406                	sd	ra,40(sp)
    80000e48:	f022                	sd	s0,32(sp)
    80000e4a:	ec26                	sd	s1,24(sp)
    80000e4c:	e84a                	sd	s2,16(sp)
    80000e4e:	e44e                	sd	s3,8(sp)
    80000e50:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80000e52:	9e1ff0ef          	jal	ra,80000832 <myproc>
    80000e56:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80000e58:	458000ef          	jal	ra,800012b0 <holding>
    80000e5c:	c92d                	beqz	a0,80000ece <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80000e5e:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80000e60:	2781                	sext.w	a5,a5
    80000e62:	079e                	slli	a5,a5,0x7
    80000e64:	00006717          	auipc	a4,0x6
    80000e68:	d3c70713          	addi	a4,a4,-708 # 80006ba0 <pid_lock>
    80000e6c:	97ba                	add	a5,a5,a4
    80000e6e:	0a87a703          	lw	a4,168(a5)
    80000e72:	4785                	li	a5,1
    80000e74:	06f71363          	bne	a4,a5,80000eda <sched+0x96>
  if(p->state == RUNNING)
    80000e78:	4c98                	lw	a4,24(s1)
    80000e7a:	4791                	li	a5,4
    80000e7c:	06f70563          	beq	a4,a5,80000ee6 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000e80:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000e84:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000e86:	e7b5                	bnez	a5,80000ef2 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80000e88:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80000e8a:	00006917          	auipc	s2,0x6
    80000e8e:	d1690913          	addi	s2,s2,-746 # 80006ba0 <pid_lock>
    80000e92:	2781                	sext.w	a5,a5
    80000e94:	079e                	slli	a5,a5,0x7
    80000e96:	97ca                	add	a5,a5,s2
    80000e98:	0ac7a983          	lw	s3,172(a5)
    80000e9c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80000e9e:	2781                	sext.w	a5,a5
    80000ea0:	079e                	slli	a5,a5,0x7
    80000ea2:	00006597          	auipc	a1,0x6
    80000ea6:	d3658593          	addi	a1,a1,-714 # 80006bd8 <cpus+0x8>
    80000eaa:	95be                	add	a1,a1,a5
    80000eac:	06048513          	addi	a0,s1,96
    80000eb0:	794000ef          	jal	ra,80001644 <swtch>
    80000eb4:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80000eb6:	2781                	sext.w	a5,a5
    80000eb8:	079e                	slli	a5,a5,0x7
    80000eba:	993e                	add	s2,s2,a5
    80000ebc:	0b392623          	sw	s3,172(s2)
}
    80000ec0:	70a2                	ld	ra,40(sp)
    80000ec2:	7402                	ld	s0,32(sp)
    80000ec4:	64e2                	ld	s1,24(sp)
    80000ec6:	6942                	ld	s2,16(sp)
    80000ec8:	69a2                	ld	s3,8(sp)
    80000eca:	6145                	addi	sp,sp,48
    80000ecc:	8082                	ret
    panic("sched p->lock");
    80000ece:	00004517          	auipc	a0,0x4
    80000ed2:	41a50513          	addi	a0,a0,1050 # 800052e8 <digits+0x258>
    80000ed6:	f96ff0ef          	jal	ra,8000066c <panic>
    panic("sched locks");
    80000eda:	00004517          	auipc	a0,0x4
    80000ede:	41e50513          	addi	a0,a0,1054 # 800052f8 <digits+0x268>
    80000ee2:	f8aff0ef          	jal	ra,8000066c <panic>
    panic("sched running");
    80000ee6:	00004517          	auipc	a0,0x4
    80000eea:	42250513          	addi	a0,a0,1058 # 80005308 <digits+0x278>
    80000eee:	f7eff0ef          	jal	ra,8000066c <panic>
    panic("sched interruptible");
    80000ef2:	00004517          	auipc	a0,0x4
    80000ef6:	42650513          	addi	a0,a0,1062 # 80005318 <digits+0x288>
    80000efa:	f72ff0ef          	jal	ra,8000066c <panic>

0000000080000efe <yield>:
{
    80000efe:	1101                	addi	sp,sp,-32
    80000f00:	ec06                	sd	ra,24(sp)
    80000f02:	e822                	sd	s0,16(sp)
    80000f04:	e426                	sd	s1,8(sp)
    80000f06:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80000f08:	92bff0ef          	jal	ra,80000832 <myproc>
    80000f0c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80000f0e:	40c000ef          	jal	ra,8000131a <acquire>
  p->state = RUNNABLE;
    80000f12:	478d                	li	a5,3
    80000f14:	cc9c                	sw	a5,24(s1)
  sched();
    80000f16:	f2fff0ef          	jal	ra,80000e44 <sched>
  release(&p->lock);
    80000f1a:	8526                	mv	a0,s1
    80000f1c:	496000ef          	jal	ra,800013b2 <release>
}
    80000f20:	60e2                	ld	ra,24(sp)
    80000f22:	6442                	ld	s0,16(sp)
    80000f24:	64a2                	ld	s1,8(sp)
    80000f26:	6105                	addi	sp,sp,32
    80000f28:	8082                	ret

0000000080000f2a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80000f2a:	7179                	addi	sp,sp,-48
    80000f2c:	f406                	sd	ra,40(sp)
    80000f2e:	f022                	sd	s0,32(sp)
    80000f30:	ec26                	sd	s1,24(sp)
    80000f32:	e84a                	sd	s2,16(sp)
    80000f34:	e44e                	sd	s3,8(sp)
    80000f36:	1800                	addi	s0,sp,48
    80000f38:	89aa                	mv	s3,a0
    80000f3a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80000f3c:	8f7ff0ef          	jal	ra,80000832 <myproc>
    80000f40:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80000f42:	3d8000ef          	jal	ra,8000131a <acquire>
  release(lk);
    80000f46:	854a                	mv	a0,s2
    80000f48:	46a000ef          	jal	ra,800013b2 <release>

  // Go to sleep.
  p->chan = chan;
    80000f4c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80000f50:	4789                	li	a5,2
    80000f52:	cc9c                	sw	a5,24(s1)

  sched();
    80000f54:	ef1ff0ef          	jal	ra,80000e44 <sched>

  // Tidy up.
  p->chan = 0;
    80000f58:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80000f5c:	8526                	mv	a0,s1
    80000f5e:	454000ef          	jal	ra,800013b2 <release>
  acquire(lk);
    80000f62:	854a                	mv	a0,s2
    80000f64:	3b6000ef          	jal	ra,8000131a <acquire>
}
    80000f68:	70a2                	ld	ra,40(sp)
    80000f6a:	7402                	ld	s0,32(sp)
    80000f6c:	64e2                	ld	s1,24(sp)
    80000f6e:	6942                	ld	s2,16(sp)
    80000f70:	69a2                	ld	s3,8(sp)
    80000f72:	6145                	addi	sp,sp,48
    80000f74:	8082                	ret

0000000080000f76 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80000f76:	7139                	addi	sp,sp,-64
    80000f78:	fc06                	sd	ra,56(sp)
    80000f7a:	f822                	sd	s0,48(sp)
    80000f7c:	f426                	sd	s1,40(sp)
    80000f7e:	f04a                	sd	s2,32(sp)
    80000f80:	ec4e                	sd	s3,24(sp)
    80000f82:	e852                	sd	s4,16(sp)
    80000f84:	e456                	sd	s5,8(sp)
    80000f86:	0080                	addi	s0,sp,64
    80000f88:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80000f8a:	00006497          	auipc	s1,0x6
    80000f8e:	04648493          	addi	s1,s1,70 # 80006fd0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80000f92:	4989                	li	s3,2
        p->state = RUNNABLE;
    80000f94:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80000f96:	0000a917          	auipc	s2,0xa
    80000f9a:	83a90913          	addi	s2,s2,-1990 # 8000a7d0 <stack0>
    80000f9e:	a801                	j	80000fae <wakeup+0x38>
      }
      release(&p->lock);
    80000fa0:	8526                	mv	a0,s1
    80000fa2:	410000ef          	jal	ra,800013b2 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000fa6:	0e048493          	addi	s1,s1,224
    80000faa:	03248263          	beq	s1,s2,80000fce <wakeup+0x58>
    if(p != myproc()){
    80000fae:	885ff0ef          	jal	ra,80000832 <myproc>
    80000fb2:	fea48ae3          	beq	s1,a0,80000fa6 <wakeup+0x30>
      acquire(&p->lock);
    80000fb6:	8526                	mv	a0,s1
    80000fb8:	362000ef          	jal	ra,8000131a <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80000fbc:	4c9c                	lw	a5,24(s1)
    80000fbe:	ff3791e3          	bne	a5,s3,80000fa0 <wakeup+0x2a>
    80000fc2:	709c                	ld	a5,32(s1)
    80000fc4:	fd479ee3          	bne	a5,s4,80000fa0 <wakeup+0x2a>
        p->state = RUNNABLE;
    80000fc8:	0154ac23          	sw	s5,24(s1)
    80000fcc:	bfd1                	j	80000fa0 <wakeup+0x2a>
    }
  }
}
    80000fce:	70e2                	ld	ra,56(sp)
    80000fd0:	7442                	ld	s0,48(sp)
    80000fd2:	74a2                	ld	s1,40(sp)
    80000fd4:	7902                	ld	s2,32(sp)
    80000fd6:	69e2                	ld	s3,24(sp)
    80000fd8:	6a42                	ld	s4,16(sp)
    80000fda:	6aa2                	ld	s5,8(sp)
    80000fdc:	6121                	addi	sp,sp,64
    80000fde:	8082                	ret

0000000080000fe0 <reparent>:
{
    80000fe0:	7179                	addi	sp,sp,-48
    80000fe2:	f406                	sd	ra,40(sp)
    80000fe4:	f022                	sd	s0,32(sp)
    80000fe6:	ec26                	sd	s1,24(sp)
    80000fe8:	e84a                	sd	s2,16(sp)
    80000fea:	e44e                	sd	s3,8(sp)
    80000fec:	e052                	sd	s4,0(sp)
    80000fee:	1800                	addi	s0,sp,48
    80000ff0:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80000ff2:	00006497          	auipc	s1,0x6
    80000ff6:	fde48493          	addi	s1,s1,-34 # 80006fd0 <proc>
      pp->parent = initproc;
    80000ffa:	00006a17          	auipc	s4,0x6
    80000ffe:	b3ea0a13          	addi	s4,s4,-1218 # 80006b38 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001002:	00009997          	auipc	s3,0x9
    80001006:	7ce98993          	addi	s3,s3,1998 # 8000a7d0 <stack0>
    8000100a:	a029                	j	80001014 <reparent+0x34>
    8000100c:	0e048493          	addi	s1,s1,224
    80001010:	01348b63          	beq	s1,s3,80001026 <reparent+0x46>
    if(pp->parent == p){
    80001014:	7c9c                	ld	a5,56(s1)
    80001016:	ff279be3          	bne	a5,s2,8000100c <reparent+0x2c>
      pp->parent = initproc;
    8000101a:	000a3503          	ld	a0,0(s4)
    8000101e:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001020:	f57ff0ef          	jal	ra,80000f76 <wakeup>
    80001024:	b7e5                	j	8000100c <reparent+0x2c>
}
    80001026:	70a2                	ld	ra,40(sp)
    80001028:	7402                	ld	s0,32(sp)
    8000102a:	64e2                	ld	s1,24(sp)
    8000102c:	6942                	ld	s2,16(sp)
    8000102e:	69a2                	ld	s3,8(sp)
    80001030:	6a02                	ld	s4,0(sp)
    80001032:	6145                	addi	sp,sp,48
    80001034:	8082                	ret

0000000080001036 <exit>:
{
    80001036:	7179                	addi	sp,sp,-48
    80001038:	f406                	sd	ra,40(sp)
    8000103a:	f022                	sd	s0,32(sp)
    8000103c:	ec26                	sd	s1,24(sp)
    8000103e:	e84a                	sd	s2,16(sp)
    80001040:	e44e                	sd	s3,8(sp)
    80001042:	1800                	addi	s0,sp,48
    80001044:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001046:	fecff0ef          	jal	ra,80000832 <myproc>
  if(p == initproc)
    8000104a:	00006797          	auipc	a5,0x6
    8000104e:	aee7b783          	ld	a5,-1298(a5) # 80006b38 <initproc>
    80001052:	04a78263          	beq	a5,a0,80001096 <exit+0x60>
    80001056:	84aa                	mv	s1,a0
  acquire(&wait_lock);
    80001058:	00006997          	auipc	s3,0x6
    8000105c:	b6098993          	addi	s3,s3,-1184 # 80006bb8 <wait_lock>
    80001060:	854e                	mv	a0,s3
    80001062:	2b8000ef          	jal	ra,8000131a <acquire>
  reparent(p);
    80001066:	8526                	mv	a0,s1
    80001068:	f79ff0ef          	jal	ra,80000fe0 <reparent>
  wakeup(p->parent);
    8000106c:	7c88                	ld	a0,56(s1)
    8000106e:	f09ff0ef          	jal	ra,80000f76 <wakeup>
  acquire(&p->lock);
    80001072:	8526                	mv	a0,s1
    80001074:	2a6000ef          	jal	ra,8000131a <acquire>
  p->xstate = status;
    80001078:	0324a623          	sw	s2,44(s1)
  p->state = ZOMBIE;
    8000107c:	4795                	li	a5,5
    8000107e:	cc9c                	sw	a5,24(s1)
  release(&wait_lock);
    80001080:	854e                	mv	a0,s3
    80001082:	330000ef          	jal	ra,800013b2 <release>
  sched();
    80001086:	dbfff0ef          	jal	ra,80000e44 <sched>
  panic("zombie exit");
    8000108a:	00004517          	auipc	a0,0x4
    8000108e:	2b650513          	addi	a0,a0,694 # 80005340 <digits+0x2b0>
    80001092:	ddaff0ef          	jal	ra,8000066c <panic>
    panic("init exiting");
    80001096:	00004517          	auipc	a0,0x4
    8000109a:	29a50513          	addi	a0,a0,666 # 80005330 <digits+0x2a0>
    8000109e:	dceff0ef          	jal	ra,8000066c <panic>

00000000800010a2 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800010a2:	7179                	addi	sp,sp,-48
    800010a4:	f406                	sd	ra,40(sp)
    800010a6:	f022                	sd	s0,32(sp)
    800010a8:	ec26                	sd	s1,24(sp)
    800010aa:	e84a                	sd	s2,16(sp)
    800010ac:	e44e                	sd	s3,8(sp)
    800010ae:	1800                	addi	s0,sp,48
    800010b0:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800010b2:	00006497          	auipc	s1,0x6
    800010b6:	f1e48493          	addi	s1,s1,-226 # 80006fd0 <proc>
    800010ba:	00009997          	auipc	s3,0x9
    800010be:	71698993          	addi	s3,s3,1814 # 8000a7d0 <stack0>
    acquire(&p->lock);
    800010c2:	8526                	mv	a0,s1
    800010c4:	256000ef          	jal	ra,8000131a <acquire>
    if(p->pid == pid){
    800010c8:	589c                	lw	a5,48(s1)
    800010ca:	01278b63          	beq	a5,s2,800010e0 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800010ce:	8526                	mv	a0,s1
    800010d0:	2e2000ef          	jal	ra,800013b2 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800010d4:	0e048493          	addi	s1,s1,224
    800010d8:	ff3495e3          	bne	s1,s3,800010c2 <kill+0x20>
  }
  return -1;
    800010dc:	557d                	li	a0,-1
    800010de:	a819                	j	800010f4 <kill+0x52>
      p->killed = 1;
    800010e0:	4785                	li	a5,1
    800010e2:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800010e4:	4c98                	lw	a4,24(s1)
    800010e6:	4789                	li	a5,2
    800010e8:	00f70d63          	beq	a4,a5,80001102 <kill+0x60>
      release(&p->lock);
    800010ec:	8526                	mv	a0,s1
    800010ee:	2c4000ef          	jal	ra,800013b2 <release>
      return 0;
    800010f2:	4501                	li	a0,0
}
    800010f4:	70a2                	ld	ra,40(sp)
    800010f6:	7402                	ld	s0,32(sp)
    800010f8:	64e2                	ld	s1,24(sp)
    800010fa:	6942                	ld	s2,16(sp)
    800010fc:	69a2                	ld	s3,8(sp)
    800010fe:	6145                	addi	sp,sp,48
    80001100:	8082                	ret
        p->state = RUNNABLE;
    80001102:	478d                	li	a5,3
    80001104:	cc9c                	sw	a5,24(s1)
    80001106:	b7dd                	j	800010ec <kill+0x4a>

0000000080001108 <setkilled>:

void
setkilled(struct proc *p)
{
    80001108:	1101                	addi	sp,sp,-32
    8000110a:	ec06                	sd	ra,24(sp)
    8000110c:	e822                	sd	s0,16(sp)
    8000110e:	e426                	sd	s1,8(sp)
    80001110:	1000                	addi	s0,sp,32
    80001112:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001114:	206000ef          	jal	ra,8000131a <acquire>
  p->killed = 1;
    80001118:	4785                	li	a5,1
    8000111a:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000111c:	8526                	mv	a0,s1
    8000111e:	294000ef          	jal	ra,800013b2 <release>
}
    80001122:	60e2                	ld	ra,24(sp)
    80001124:	6442                	ld	s0,16(sp)
    80001126:	64a2                	ld	s1,8(sp)
    80001128:	6105                	addi	sp,sp,32
    8000112a:	8082                	ret

000000008000112c <killed>:

int
killed(struct proc *p)
{
    8000112c:	1101                	addi	sp,sp,-32
    8000112e:	ec06                	sd	ra,24(sp)
    80001130:	e822                	sd	s0,16(sp)
    80001132:	e426                	sd	s1,8(sp)
    80001134:	e04a                	sd	s2,0(sp)
    80001136:	1000                	addi	s0,sp,32
    80001138:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000113a:	1e0000ef          	jal	ra,8000131a <acquire>
  k = p->killed;
    8000113e:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80001142:	8526                	mv	a0,s1
    80001144:	26e000ef          	jal	ra,800013b2 <release>
  return k;
}
    80001148:	854a                	mv	a0,s2
    8000114a:	60e2                	ld	ra,24(sp)
    8000114c:	6442                	ld	s0,16(sp)
    8000114e:	64a2                	ld	s1,8(sp)
    80001150:	6902                	ld	s2,0(sp)
    80001152:	6105                	addi	sp,sp,32
    80001154:	8082                	ret

0000000080001156 <wait>:
{
    80001156:	715d                	addi	sp,sp,-80
    80001158:	e486                	sd	ra,72(sp)
    8000115a:	e0a2                	sd	s0,64(sp)
    8000115c:	fc26                	sd	s1,56(sp)
    8000115e:	f84a                	sd	s2,48(sp)
    80001160:	f44e                	sd	s3,40(sp)
    80001162:	f052                	sd	s4,32(sp)
    80001164:	ec56                	sd	s5,24(sp)
    80001166:	e85a                	sd	s6,16(sp)
    80001168:	e45e                	sd	s7,8(sp)
    8000116a:	e062                	sd	s8,0(sp)
    8000116c:	0880                	addi	s0,sp,80
    8000116e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80001170:	ec2ff0ef          	jal	ra,80000832 <myproc>
    80001174:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80001176:	00006517          	auipc	a0,0x6
    8000117a:	a4250513          	addi	a0,a0,-1470 # 80006bb8 <wait_lock>
    8000117e:	19c000ef          	jal	ra,8000131a <acquire>
    havekids = 0;
    80001182:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80001184:	4a15                	li	s4,5
        havekids = 1;
    80001186:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001188:	00009997          	auipc	s3,0x9
    8000118c:	64898993          	addi	s3,s3,1608 # 8000a7d0 <stack0>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001190:	00006c17          	auipc	s8,0x6
    80001194:	a28c0c13          	addi	s8,s8,-1496 # 80006bb8 <wait_lock>
    havekids = 0;
    80001198:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000119a:	00006497          	auipc	s1,0x6
    8000119e:	e3648493          	addi	s1,s1,-458 # 80006fd0 <proc>
    800011a2:	a899                	j	800011f8 <wait+0xa2>
          pid = pp->pid;
    800011a4:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800011a8:	000b0c63          	beqz	s6,800011c0 <wait+0x6a>
    800011ac:	4691                	li	a3,4
    800011ae:	02c48613          	addi	a2,s1,44
    800011b2:	85da                	mv	a1,s6
    800011b4:	05093503          	ld	a0,80(s2)
    800011b8:	50a010ef          	jal	ra,800026c2 <copyout>
    800011bc:	00054f63          	bltz	a0,800011da <wait+0x84>
          freeproc(pp);
    800011c0:	8526                	mv	a0,s1
    800011c2:	fc4ff0ef          	jal	ra,80000986 <freeproc>
          release(&pp->lock);
    800011c6:	8526                	mv	a0,s1
    800011c8:	1ea000ef          	jal	ra,800013b2 <release>
          release(&wait_lock);
    800011cc:	00006517          	auipc	a0,0x6
    800011d0:	9ec50513          	addi	a0,a0,-1556 # 80006bb8 <wait_lock>
    800011d4:	1de000ef          	jal	ra,800013b2 <release>
          return pid;
    800011d8:	a891                	j	8000122c <wait+0xd6>
            release(&pp->lock);
    800011da:	8526                	mv	a0,s1
    800011dc:	1d6000ef          	jal	ra,800013b2 <release>
            release(&wait_lock);
    800011e0:	00006517          	auipc	a0,0x6
    800011e4:	9d850513          	addi	a0,a0,-1576 # 80006bb8 <wait_lock>
    800011e8:	1ca000ef          	jal	ra,800013b2 <release>
            return -1;
    800011ec:	59fd                	li	s3,-1
    800011ee:	a83d                	j	8000122c <wait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800011f0:	0e048493          	addi	s1,s1,224
    800011f4:	03348063          	beq	s1,s3,80001214 <wait+0xbe>
      if(pp->parent == p){
    800011f8:	7c9c                	ld	a5,56(s1)
    800011fa:	ff279be3          	bne	a5,s2,800011f0 <wait+0x9a>
        acquire(&pp->lock);
    800011fe:	8526                	mv	a0,s1
    80001200:	11a000ef          	jal	ra,8000131a <acquire>
        if(pp->state == ZOMBIE){
    80001204:	4c9c                	lw	a5,24(s1)
    80001206:	f9478fe3          	beq	a5,s4,800011a4 <wait+0x4e>
        release(&pp->lock);
    8000120a:	8526                	mv	a0,s1
    8000120c:	1a6000ef          	jal	ra,800013b2 <release>
        havekids = 1;
    80001210:	8756                	mv	a4,s5
    80001212:	bff9                	j	800011f0 <wait+0x9a>
    if(!havekids || killed(p)){
    80001214:	c709                	beqz	a4,8000121e <wait+0xc8>
    80001216:	854a                	mv	a0,s2
    80001218:	f15ff0ef          	jal	ra,8000112c <killed>
    8000121c:	c50d                	beqz	a0,80001246 <wait+0xf0>
      release(&wait_lock);
    8000121e:	00006517          	auipc	a0,0x6
    80001222:	99a50513          	addi	a0,a0,-1638 # 80006bb8 <wait_lock>
    80001226:	18c000ef          	jal	ra,800013b2 <release>
      return -1;
    8000122a:	59fd                	li	s3,-1
}
    8000122c:	854e                	mv	a0,s3
    8000122e:	60a6                	ld	ra,72(sp)
    80001230:	6406                	ld	s0,64(sp)
    80001232:	74e2                	ld	s1,56(sp)
    80001234:	7942                	ld	s2,48(sp)
    80001236:	79a2                	ld	s3,40(sp)
    80001238:	7a02                	ld	s4,32(sp)
    8000123a:	6ae2                	ld	s5,24(sp)
    8000123c:	6b42                	ld	s6,16(sp)
    8000123e:	6ba2                	ld	s7,8(sp)
    80001240:	6c02                	ld	s8,0(sp)
    80001242:	6161                	addi	sp,sp,80
    80001244:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001246:	85e2                	mv	a1,s8
    80001248:	854a                	mv	a0,s2
    8000124a:	ce1ff0ef          	jal	ra,80000f2a <sleep>
    havekids = 0;
    8000124e:	b7a9                	j	80001198 <wait+0x42>

0000000080001250 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001250:	7179                	addi	sp,sp,-48
    80001252:	f406                	sd	ra,40(sp)
    80001254:	f022                	sd	s0,32(sp)
    80001256:	ec26                	sd	s1,24(sp)
    80001258:	e84a                	sd	s2,16(sp)
    8000125a:	e44e                	sd	s3,8(sp)
    8000125c:	e052                	sd	s4,0(sp)
    8000125e:	1800                	addi	s0,sp,48
    80001260:	892a                	mv	s2,a0
    80001262:	84ae                	mv	s1,a1
    80001264:	89b2                	mv	s3,a2
    80001266:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001268:	dcaff0ef          	jal	ra,80000832 <myproc>
  if(user_src){
    8000126c:	cc99                	beqz	s1,8000128a <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    8000126e:	86d2                	mv	a3,s4
    80001270:	864e                	mv	a2,s3
    80001272:	85ca                	mv	a1,s2
    80001274:	6928                	ld	a0,80(a0)
    80001276:	504010ef          	jal	ra,8000277a <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000127a:	70a2                	ld	ra,40(sp)
    8000127c:	7402                	ld	s0,32(sp)
    8000127e:	64e2                	ld	s1,24(sp)
    80001280:	6942                	ld	s2,16(sp)
    80001282:	69a2                	ld	s3,8(sp)
    80001284:	6a02                	ld	s4,0(sp)
    80001286:	6145                	addi	sp,sp,48
    80001288:	8082                	ret
    memmove(dst, (char*)src, len);
    8000128a:	000a061b          	sext.w	a2,s4
    8000128e:	85ce                	mv	a1,s3
    80001290:	854a                	mv	a0,s2
    80001292:	26c000ef          	jal	ra,800014fe <memmove>
    return 0;
    80001296:	8526                	mv	a0,s1
    80001298:	b7cd                	j	8000127a <either_copyin+0x2a>

000000008000129a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    8000129a:	1141                	addi	sp,sp,-16
    8000129c:	e422                	sd	s0,8(sp)
    8000129e:	0800                	addi	s0,sp,16
  lk->name = name;
    800012a0:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    800012a2:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    800012a6:	00053823          	sd	zero,16(a0)
}
    800012aa:	6422                	ld	s0,8(sp)
    800012ac:	0141                	addi	sp,sp,16
    800012ae:	8082                	ret

00000000800012b0 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    800012b0:	411c                	lw	a5,0(a0)
    800012b2:	e399                	bnez	a5,800012b8 <holding+0x8>
    800012b4:	4501                	li	a0,0
  return r;
}
    800012b6:	8082                	ret
{
    800012b8:	1101                	addi	sp,sp,-32
    800012ba:	ec06                	sd	ra,24(sp)
    800012bc:	e822                	sd	s0,16(sp)
    800012be:	e426                	sd	s1,8(sp)
    800012c0:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    800012c2:	6904                	ld	s1,16(a0)
    800012c4:	d52ff0ef          	jal	ra,80000816 <mycpu>
    800012c8:	40a48533          	sub	a0,s1,a0
    800012cc:	00153513          	seqz	a0,a0
}
    800012d0:	60e2                	ld	ra,24(sp)
    800012d2:	6442                	ld	s0,16(sp)
    800012d4:	64a2                	ld	s1,8(sp)
    800012d6:	6105                	addi	sp,sp,32
    800012d8:	8082                	ret

00000000800012da <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    800012da:	1101                	addi	sp,sp,-32
    800012dc:	ec06                	sd	ra,24(sp)
    800012de:	e822                	sd	s0,16(sp)
    800012e0:	e426                	sd	s1,8(sp)
    800012e2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800012e4:	100024f3          	csrr	s1,sstatus
    800012e8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800012ec:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800012ee:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    800012f2:	d24ff0ef          	jal	ra,80000816 <mycpu>
    800012f6:	5d3c                	lw	a5,120(a0)
    800012f8:	cb99                	beqz	a5,8000130e <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    800012fa:	d1cff0ef          	jal	ra,80000816 <mycpu>
    800012fe:	5d3c                	lw	a5,120(a0)
    80001300:	2785                	addiw	a5,a5,1
    80001302:	dd3c                	sw	a5,120(a0)
}
    80001304:	60e2                	ld	ra,24(sp)
    80001306:	6442                	ld	s0,16(sp)
    80001308:	64a2                	ld	s1,8(sp)
    8000130a:	6105                	addi	sp,sp,32
    8000130c:	8082                	ret
    mycpu()->intena = old;
    8000130e:	d08ff0ef          	jal	ra,80000816 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80001312:	8085                	srli	s1,s1,0x1
    80001314:	8885                	andi	s1,s1,1
    80001316:	dd64                	sw	s1,124(a0)
    80001318:	b7cd                	j	800012fa <push_off+0x20>

000000008000131a <acquire>:
{
    8000131a:	1101                	addi	sp,sp,-32
    8000131c:	ec06                	sd	ra,24(sp)
    8000131e:	e822                	sd	s0,16(sp)
    80001320:	e426                	sd	s1,8(sp)
    80001322:	1000                	addi	s0,sp,32
    80001324:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80001326:	fb5ff0ef          	jal	ra,800012da <push_off>
  if(holding(lk))
    8000132a:	8526                	mv	a0,s1
    8000132c:	f85ff0ef          	jal	ra,800012b0 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80001330:	4705                	li	a4,1
  if(holding(lk))
    80001332:	e105                	bnez	a0,80001352 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80001334:	87ba                	mv	a5,a4
    80001336:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    8000133a:	2781                	sext.w	a5,a5
    8000133c:	ffe5                	bnez	a5,80001334 <acquire+0x1a>
  __sync_synchronize();
    8000133e:	0ff0000f          	fence
  lk->cpu = mycpu();
    80001342:	cd4ff0ef          	jal	ra,80000816 <mycpu>
    80001346:	e888                	sd	a0,16(s1)
}
    80001348:	60e2                	ld	ra,24(sp)
    8000134a:	6442                	ld	s0,16(sp)
    8000134c:	64a2                	ld	s1,8(sp)
    8000134e:	6105                	addi	sp,sp,32
    80001350:	8082                	ret
    panic("acquire");
    80001352:	00004517          	auipc	a0,0x4
    80001356:	ffe50513          	addi	a0,a0,-2 # 80005350 <digits+0x2c0>
    8000135a:	b12ff0ef          	jal	ra,8000066c <panic>

000000008000135e <pop_off>:

void
pop_off(void)
{
    8000135e:	1141                	addi	sp,sp,-16
    80001360:	e406                	sd	ra,8(sp)
    80001362:	e022                	sd	s0,0(sp)
    80001364:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80001366:	cb0ff0ef          	jal	ra,80000816 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000136a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000136e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001370:	e78d                	bnez	a5,8000139a <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80001372:	5d3c                	lw	a5,120(a0)
    80001374:	02f05963          	blez	a5,800013a6 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80001378:	37fd                	addiw	a5,a5,-1
    8000137a:	0007871b          	sext.w	a4,a5
    8000137e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80001380:	eb09                	bnez	a4,80001392 <pop_off+0x34>
    80001382:	5d7c                	lw	a5,124(a0)
    80001384:	c799                	beqz	a5,80001392 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001386:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000138a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000138e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80001392:	60a2                	ld	ra,8(sp)
    80001394:	6402                	ld	s0,0(sp)
    80001396:	0141                	addi	sp,sp,16
    80001398:	8082                	ret
    panic("pop_off - interruptible");
    8000139a:	00004517          	auipc	a0,0x4
    8000139e:	fbe50513          	addi	a0,a0,-66 # 80005358 <digits+0x2c8>
    800013a2:	acaff0ef          	jal	ra,8000066c <panic>
    panic("pop_off");
    800013a6:	00004517          	auipc	a0,0x4
    800013aa:	fca50513          	addi	a0,a0,-54 # 80005370 <digits+0x2e0>
    800013ae:	abeff0ef          	jal	ra,8000066c <panic>

00000000800013b2 <release>:
{
    800013b2:	1101                	addi	sp,sp,-32
    800013b4:	ec06                	sd	ra,24(sp)
    800013b6:	e822                	sd	s0,16(sp)
    800013b8:	e426                	sd	s1,8(sp)
    800013ba:	1000                	addi	s0,sp,32
    800013bc:	84aa                	mv	s1,a0
  if(!holding(lk))
    800013be:	ef3ff0ef          	jal	ra,800012b0 <holding>
    800013c2:	c105                	beqz	a0,800013e2 <release+0x30>
  lk->cpu = 0;
    800013c4:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    800013c8:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    800013cc:	0f50000f          	fence	iorw,ow
    800013d0:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    800013d4:	f8bff0ef          	jal	ra,8000135e <pop_off>
}
    800013d8:	60e2                	ld	ra,24(sp)
    800013da:	6442                	ld	s0,16(sp)
    800013dc:	64a2                	ld	s1,8(sp)
    800013de:	6105                	addi	sp,sp,32
    800013e0:	8082                	ret
    panic("release");
    800013e2:	00004517          	auipc	a0,0x4
    800013e6:	f9650513          	addi	a0,a0,-106 # 80005378 <digits+0x2e8>
    800013ea:	a82ff0ef          	jal	ra,8000066c <panic>

00000000800013ee <timerinit>:

// ask each hart to generate timer interrupts.
// 设备驱动程序
void
timerinit()
{
    800013ee:	1141                	addi	sp,sp,-16
    800013f0:	e422                	sd	s0,8(sp)
    800013f2:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mie" : "=r" (x) );
    800013f4:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  // 使能S模式下的定时器中断
  w_mie(r_mie() | MIE_STIE);
    800013f8:	0207e793          	ori	a5,a5,32
  asm volatile("csrw mie, %0" : : "r" (x));
    800013fc:	30479073          	csrw	mie,a5
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80001400:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  // 使能sstc扩展
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80001404:	577d                	li	a4,-1
    80001406:	177e                	slli	a4,a4,0x3f
    80001408:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    8000140a:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000140e:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  // 允许s模式下访问计数器
  w_mcounteren(r_mcounteren() | 2);
    80001412:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80001416:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    8000141a:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  // 设置下一个定时器中断的时间点
  w_stimecmp(r_time() + 1000000);
    8000141e:	000f4737          	lui	a4,0xf4
    80001422:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80001426:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80001428:	14d79073          	csrw	0x14d,a5
}
    8000142c:	6422                	ld	s0,8(sp)
    8000142e:	0141                	addi	sp,sp,16
    80001430:	8082                	ret

0000000080001432 <start>:
{
    80001432:	1141                	addi	sp,sp,-16
    80001434:	e406                	sd	ra,8(sp)
    80001436:	e022                	sd	s0,0(sp)
    80001438:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000143a:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK; // MSTATUS_MPP_MASK 是MPP字段的掩码（表示上一次特权级）
    8000143e:	7779                	lui	a4,0xffffe
    80001440:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffe37df>
    80001444:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S; // 先清楚MPP字段，在设置为S（Supervisor）模式
    80001446:	6705                	lui	a4,0x1
    80001448:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000144c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000144e:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80001452:	fffff797          	auipc	a5,0xfffff
    80001456:	d5c78793          	addi	a5,a5,-676 # 800001ae <main>
    8000145a:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000145e:	4781                	li	a5,0
    80001460:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80001464:	67c1                	lui	a5,0x10
    80001466:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80001468:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000146c:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80001470:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80001474:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80001478:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    8000147c:	57fd                	li	a5,-1
    8000147e:	83a9                	srli	a5,a5,0xa
    80001480:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80001484:	47bd                	li	a5,15
    80001486:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    8000148a:	f65ff0ef          	jal	ra,800013ee <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    8000148e:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    80001492:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    80001494:	823e                	mv	tp,a5
  asm volatile("mret"); 
    80001496:	30200073          	mret
}
    8000149a:	60a2                	ld	ra,8(sp)
    8000149c:	6402                	ld	s0,0(sp)
    8000149e:	0141                	addi	sp,sp,16
    800014a0:	8082                	ret

00000000800014a2 <memset>:
// 文件直接使用了xv6标准文件，应该没有错误 //
//////////////////////////////////////////

void*
memset(void *dst, int c, uint n)
{
    800014a2:	1141                	addi	sp,sp,-16
    800014a4:	e422                	sd	s0,8(sp)
    800014a6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    800014a8:	ca19                	beqz	a2,800014be <memset+0x1c>
    800014aa:	87aa                	mv	a5,a0
    800014ac:	1602                	slli	a2,a2,0x20
    800014ae:	9201                	srli	a2,a2,0x20
    800014b0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    800014b4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    800014b8:	0785                	addi	a5,a5,1
    800014ba:	fee79de3          	bne	a5,a4,800014b4 <memset+0x12>
  }
  return dst;
}
    800014be:	6422                	ld	s0,8(sp)
    800014c0:	0141                	addi	sp,sp,16
    800014c2:	8082                	ret

00000000800014c4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    800014c4:	1141                	addi	sp,sp,-16
    800014c6:	e422                	sd	s0,8(sp)
    800014c8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    800014ca:	ca05                	beqz	a2,800014fa <memcmp+0x36>
    800014cc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    800014d0:	1682                	slli	a3,a3,0x20
    800014d2:	9281                	srli	a3,a3,0x20
    800014d4:	0685                	addi	a3,a3,1
    800014d6:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    800014d8:	00054783          	lbu	a5,0(a0)
    800014dc:	0005c703          	lbu	a4,0(a1)
    800014e0:	00e79863          	bne	a5,a4,800014f0 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    800014e4:	0505                	addi	a0,a0,1
    800014e6:	0585                	addi	a1,a1,1
  while(n-- > 0){
    800014e8:	fed518e3          	bne	a0,a3,800014d8 <memcmp+0x14>
  }

  return 0;
    800014ec:	4501                	li	a0,0
    800014ee:	a019                	j	800014f4 <memcmp+0x30>
      return *s1 - *s2;
    800014f0:	40e7853b          	subw	a0,a5,a4
}
    800014f4:	6422                	ld	s0,8(sp)
    800014f6:	0141                	addi	sp,sp,16
    800014f8:	8082                	ret
  return 0;
    800014fa:	4501                	li	a0,0
    800014fc:	bfe5                	j	800014f4 <memcmp+0x30>

00000000800014fe <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    800014fe:	1141                	addi	sp,sp,-16
    80001500:	e422                	sd	s0,8(sp)
    80001502:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80001504:	c205                	beqz	a2,80001524 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80001506:	02a5e263          	bltu	a1,a0,8000152a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    8000150a:	1602                	slli	a2,a2,0x20
    8000150c:	9201                	srli	a2,a2,0x20
    8000150e:	00c587b3          	add	a5,a1,a2
{
    80001512:	872a                	mv	a4,a0
      *d++ = *s++;
    80001514:	0585                	addi	a1,a1,1
    80001516:	0705                	addi	a4,a4,1
    80001518:	fff5c683          	lbu	a3,-1(a1)
    8000151c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80001520:	fef59ae3          	bne	a1,a5,80001514 <memmove+0x16>

  return dst;
}
    80001524:	6422                	ld	s0,8(sp)
    80001526:	0141                	addi	sp,sp,16
    80001528:	8082                	ret
  if(s < d && s + n > d){
    8000152a:	02061693          	slli	a3,a2,0x20
    8000152e:	9281                	srli	a3,a3,0x20
    80001530:	00d58733          	add	a4,a1,a3
    80001534:	fce57be3          	bgeu	a0,a4,8000150a <memmove+0xc>
    d += n;
    80001538:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    8000153a:	fff6079b          	addiw	a5,a2,-1
    8000153e:	1782                	slli	a5,a5,0x20
    80001540:	9381                	srli	a5,a5,0x20
    80001542:	fff7c793          	not	a5,a5
    80001546:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80001548:	177d                	addi	a4,a4,-1
    8000154a:	16fd                	addi	a3,a3,-1
    8000154c:	00074603          	lbu	a2,0(a4)
    80001550:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80001554:	fee79ae3          	bne	a5,a4,80001548 <memmove+0x4a>
    80001558:	b7f1                	j	80001524 <memmove+0x26>

000000008000155a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    8000155a:	1141                	addi	sp,sp,-16
    8000155c:	e406                	sd	ra,8(sp)
    8000155e:	e022                	sd	s0,0(sp)
    80001560:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80001562:	f9dff0ef          	jal	ra,800014fe <memmove>
}
    80001566:	60a2                	ld	ra,8(sp)
    80001568:	6402                	ld	s0,0(sp)
    8000156a:	0141                	addi	sp,sp,16
    8000156c:	8082                	ret

000000008000156e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    8000156e:	1141                	addi	sp,sp,-16
    80001570:	e422                	sd	s0,8(sp)
    80001572:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80001574:	ce11                	beqz	a2,80001590 <strncmp+0x22>
    80001576:	00054783          	lbu	a5,0(a0)
    8000157a:	cf89                	beqz	a5,80001594 <strncmp+0x26>
    8000157c:	0005c703          	lbu	a4,0(a1)
    80001580:	00f71a63          	bne	a4,a5,80001594 <strncmp+0x26>
    n--, p++, q++;
    80001584:	367d                	addiw	a2,a2,-1
    80001586:	0505                	addi	a0,a0,1
    80001588:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    8000158a:	f675                	bnez	a2,80001576 <strncmp+0x8>
  if(n == 0)
    return 0;
    8000158c:	4501                	li	a0,0
    8000158e:	a809                	j	800015a0 <strncmp+0x32>
    80001590:	4501                	li	a0,0
    80001592:	a039                	j	800015a0 <strncmp+0x32>
  if(n == 0)
    80001594:	ca09                	beqz	a2,800015a6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80001596:	00054503          	lbu	a0,0(a0)
    8000159a:	0005c783          	lbu	a5,0(a1)
    8000159e:	9d1d                	subw	a0,a0,a5
}
    800015a0:	6422                	ld	s0,8(sp)
    800015a2:	0141                	addi	sp,sp,16
    800015a4:	8082                	ret
    return 0;
    800015a6:	4501                	li	a0,0
    800015a8:	bfe5                	j	800015a0 <strncmp+0x32>

00000000800015aa <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    800015aa:	1141                	addi	sp,sp,-16
    800015ac:	e422                	sd	s0,8(sp)
    800015ae:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    800015b0:	872a                	mv	a4,a0
    800015b2:	8832                	mv	a6,a2
    800015b4:	367d                	addiw	a2,a2,-1
    800015b6:	01005963          	blez	a6,800015c8 <strncpy+0x1e>
    800015ba:	0705                	addi	a4,a4,1
    800015bc:	0005c783          	lbu	a5,0(a1)
    800015c0:	fef70fa3          	sb	a5,-1(a4)
    800015c4:	0585                	addi	a1,a1,1
    800015c6:	f7f5                	bnez	a5,800015b2 <strncpy+0x8>
    ;
  while(n-- > 0)
    800015c8:	86ba                	mv	a3,a4
    800015ca:	00c05c63          	blez	a2,800015e2 <strncpy+0x38>
    *s++ = 0;
    800015ce:	0685                	addi	a3,a3,1
    800015d0:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    800015d4:	40d707bb          	subw	a5,a4,a3
    800015d8:	37fd                	addiw	a5,a5,-1
    800015da:	010787bb          	addw	a5,a5,a6
    800015de:	fef048e3          	bgtz	a5,800015ce <strncpy+0x24>
  return os;
}
    800015e2:	6422                	ld	s0,8(sp)
    800015e4:	0141                	addi	sp,sp,16
    800015e6:	8082                	ret

00000000800015e8 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    800015e8:	1141                	addi	sp,sp,-16
    800015ea:	e422                	sd	s0,8(sp)
    800015ec:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    800015ee:	02c05363          	blez	a2,80001614 <safestrcpy+0x2c>
    800015f2:	fff6069b          	addiw	a3,a2,-1
    800015f6:	1682                	slli	a3,a3,0x20
    800015f8:	9281                	srli	a3,a3,0x20
    800015fa:	96ae                	add	a3,a3,a1
    800015fc:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    800015fe:	00d58963          	beq	a1,a3,80001610 <safestrcpy+0x28>
    80001602:	0585                	addi	a1,a1,1
    80001604:	0785                	addi	a5,a5,1
    80001606:	fff5c703          	lbu	a4,-1(a1)
    8000160a:	fee78fa3          	sb	a4,-1(a5)
    8000160e:	fb65                	bnez	a4,800015fe <safestrcpy+0x16>
    ;
  *s = 0;
    80001610:	00078023          	sb	zero,0(a5)
  return os;
}
    80001614:	6422                	ld	s0,8(sp)
    80001616:	0141                	addi	sp,sp,16
    80001618:	8082                	ret

000000008000161a <strlen>:

int
strlen(const char *s)
{
    8000161a:	1141                	addi	sp,sp,-16
    8000161c:	e422                	sd	s0,8(sp)
    8000161e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80001620:	00054783          	lbu	a5,0(a0)
    80001624:	cf91                	beqz	a5,80001640 <strlen+0x26>
    80001626:	0505                	addi	a0,a0,1
    80001628:	87aa                	mv	a5,a0
    8000162a:	4685                	li	a3,1
    8000162c:	9e89                	subw	a3,a3,a0
    8000162e:	00f6853b          	addw	a0,a3,a5
    80001632:	0785                	addi	a5,a5,1
    80001634:	fff7c703          	lbu	a4,-1(a5)
    80001638:	fb7d                	bnez	a4,8000162e <strlen+0x14>
    ;
  return n;
}
    8000163a:	6422                	ld	s0,8(sp)
    8000163c:	0141                	addi	sp,sp,16
    8000163e:	8082                	ret
  for(n = 0; s[n]; n++)
    80001640:	4501                	li	a0,0
    80001642:	bfe5                	j	8000163a <strlen+0x20>

0000000080001644 <swtch>:
    80001644:	00153023          	sd	ra,0(a0)
    80001648:	00253423          	sd	sp,8(a0)
    8000164c:	e900                	sd	s0,16(a0)
    8000164e:	ed04                	sd	s1,24(a0)
    80001650:	03253023          	sd	s2,32(a0)
    80001654:	03353423          	sd	s3,40(a0)
    80001658:	03453823          	sd	s4,48(a0)
    8000165c:	03553c23          	sd	s5,56(a0)
    80001660:	05653023          	sd	s6,64(a0)
    80001664:	05753423          	sd	s7,72(a0)
    80001668:	05853823          	sd	s8,80(a0)
    8000166c:	05953c23          	sd	s9,88(a0)
    80001670:	07a53023          	sd	s10,96(a0)
    80001674:	07b53423          	sd	s11,104(a0)
    80001678:	0005b083          	ld	ra,0(a1)
    8000167c:	0085b103          	ld	sp,8(a1)
    80001680:	6980                	ld	s0,16(a1)
    80001682:	6d84                	ld	s1,24(a1)
    80001684:	0205b903          	ld	s2,32(a1)
    80001688:	0285b983          	ld	s3,40(a1)
    8000168c:	0305ba03          	ld	s4,48(a1)
    80001690:	0385ba83          	ld	s5,56(a1)
    80001694:	0405bb03          	ld	s6,64(a1)
    80001698:	0485bb83          	ld	s7,72(a1)
    8000169c:	0505bc03          	ld	s8,80(a1)
    800016a0:	0585bc83          	ld	s9,88(a1)
    800016a4:	0605bd03          	ld	s10,96(a1)
    800016a8:	0685bd83          	ld	s11,104(a1)
    800016ac:	8082                	ret

00000000800016ae <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800016ae:	1101                	addi	sp,sp,-32
    800016b0:	ec06                	sd	ra,24(sp)
    800016b2:	e822                	sd	s0,16(sp)
    800016b4:	e426                	sd	s1,8(sp)
    800016b6:	1000                	addi	s0,sp,32
    800016b8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800016ba:	978ff0ef          	jal	ra,80000832 <myproc>
  switch (n) {
    800016be:	4795                	li	a5,5
    800016c0:	0497e163          	bltu	a5,s1,80001702 <argraw+0x54>
    800016c4:	048a                	slli	s1,s1,0x2
    800016c6:	00004717          	auipc	a4,0x4
    800016ca:	ce270713          	addi	a4,a4,-798 # 800053a8 <digits+0x318>
    800016ce:	94ba                	add	s1,s1,a4
    800016d0:	409c                	lw	a5,0(s1)
    800016d2:	97ba                	add	a5,a5,a4
    800016d4:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800016d6:	6d3c                	ld	a5,88(a0)
    800016d8:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800016da:	60e2                	ld	ra,24(sp)
    800016dc:	6442                	ld	s0,16(sp)
    800016de:	64a2                	ld	s1,8(sp)
    800016e0:	6105                	addi	sp,sp,32
    800016e2:	8082                	ret
    return p->trapframe->a1;
    800016e4:	6d3c                	ld	a5,88(a0)
    800016e6:	7fa8                	ld	a0,120(a5)
    800016e8:	bfcd                	j	800016da <argraw+0x2c>
    return p->trapframe->a2;
    800016ea:	6d3c                	ld	a5,88(a0)
    800016ec:	63c8                	ld	a0,128(a5)
    800016ee:	b7f5                	j	800016da <argraw+0x2c>
    return p->trapframe->a3;
    800016f0:	6d3c                	ld	a5,88(a0)
    800016f2:	67c8                	ld	a0,136(a5)
    800016f4:	b7dd                	j	800016da <argraw+0x2c>
    return p->trapframe->a4;
    800016f6:	6d3c                	ld	a5,88(a0)
    800016f8:	6bc8                	ld	a0,144(a5)
    800016fa:	b7c5                	j	800016da <argraw+0x2c>
    return p->trapframe->a5;
    800016fc:	6d3c                	ld	a5,88(a0)
    800016fe:	6fc8                	ld	a0,152(a5)
    80001700:	bfe9                	j	800016da <argraw+0x2c>
  panic("argraw");
    80001702:	00004517          	auipc	a0,0x4
    80001706:	c7e50513          	addi	a0,a0,-898 # 80005380 <digits+0x2f0>
    8000170a:	f63fe0ef          	jal	ra,8000066c <panic>

000000008000170e <fetchaddr>:
{
    8000170e:	1101                	addi	sp,sp,-32
    80001710:	ec06                	sd	ra,24(sp)
    80001712:	e822                	sd	s0,16(sp)
    80001714:	e426                	sd	s1,8(sp)
    80001716:	e04a                	sd	s2,0(sp)
    80001718:	1000                	addi	s0,sp,32
    8000171a:	84aa                	mv	s1,a0
    8000171c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000171e:	914ff0ef          	jal	ra,80000832 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80001722:	653c                	ld	a5,72(a0)
    80001724:	02f4f663          	bgeu	s1,a5,80001750 <fetchaddr+0x42>
    80001728:	00848713          	addi	a4,s1,8
    8000172c:	02e7e463          	bltu	a5,a4,80001754 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001730:	46a1                	li	a3,8
    80001732:	8626                	mv	a2,s1
    80001734:	85ca                	mv	a1,s2
    80001736:	6928                	ld	a0,80(a0)
    80001738:	042010ef          	jal	ra,8000277a <copyin>
    8000173c:	00a03533          	snez	a0,a0
    80001740:	40a00533          	neg	a0,a0
}
    80001744:	60e2                	ld	ra,24(sp)
    80001746:	6442                	ld	s0,16(sp)
    80001748:	64a2                	ld	s1,8(sp)
    8000174a:	6902                	ld	s2,0(sp)
    8000174c:	6105                	addi	sp,sp,32
    8000174e:	8082                	ret
    return -1;
    80001750:	557d                	li	a0,-1
    80001752:	bfcd                	j	80001744 <fetchaddr+0x36>
    80001754:	557d                	li	a0,-1
    80001756:	b7fd                	j	80001744 <fetchaddr+0x36>

0000000080001758 <fetchstr>:
{
    80001758:	7179                	addi	sp,sp,-48
    8000175a:	f406                	sd	ra,40(sp)
    8000175c:	f022                	sd	s0,32(sp)
    8000175e:	ec26                	sd	s1,24(sp)
    80001760:	e84a                	sd	s2,16(sp)
    80001762:	e44e                	sd	s3,8(sp)
    80001764:	1800                	addi	s0,sp,48
    80001766:	892a                	mv	s2,a0
    80001768:	84ae                	mv	s1,a1
    8000176a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000176c:	8c6ff0ef          	jal	ra,80000832 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80001770:	86ce                	mv	a3,s3
    80001772:	864a                	mv	a2,s2
    80001774:	85a6                	mv	a1,s1
    80001776:	6928                	ld	a0,80(a0)
    80001778:	088010ef          	jal	ra,80002800 <copyinstr>
    8000177c:	00054c63          	bltz	a0,80001794 <fetchstr+0x3c>
  return strlen(buf);
    80001780:	8526                	mv	a0,s1
    80001782:	e99ff0ef          	jal	ra,8000161a <strlen>
}
    80001786:	70a2                	ld	ra,40(sp)
    80001788:	7402                	ld	s0,32(sp)
    8000178a:	64e2                	ld	s1,24(sp)
    8000178c:	6942                	ld	s2,16(sp)
    8000178e:	69a2                	ld	s3,8(sp)
    80001790:	6145                	addi	sp,sp,48
    80001792:	8082                	ret
    return -1;
    80001794:	557d                	li	a0,-1
    80001796:	bfc5                	j	80001786 <fetchstr+0x2e>

0000000080001798 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80001798:	1101                	addi	sp,sp,-32
    8000179a:	ec06                	sd	ra,24(sp)
    8000179c:	e822                	sd	s0,16(sp)
    8000179e:	e426                	sd	s1,8(sp)
    800017a0:	1000                	addi	s0,sp,32
    800017a2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800017a4:	f0bff0ef          	jal	ra,800016ae <argraw>
    800017a8:	c088                	sw	a0,0(s1)
}
    800017aa:	60e2                	ld	ra,24(sp)
    800017ac:	6442                	ld	s0,16(sp)
    800017ae:	64a2                	ld	s1,8(sp)
    800017b0:	6105                	addi	sp,sp,32
    800017b2:	8082                	ret

00000000800017b4 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800017b4:	1101                	addi	sp,sp,-32
    800017b6:	ec06                	sd	ra,24(sp)
    800017b8:	e822                	sd	s0,16(sp)
    800017ba:	e426                	sd	s1,8(sp)
    800017bc:	1000                	addi	s0,sp,32
    800017be:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800017c0:	eefff0ef          	jal	ra,800016ae <argraw>
    800017c4:	e088                	sd	a0,0(s1)
}
    800017c6:	60e2                	ld	ra,24(sp)
    800017c8:	6442                	ld	s0,16(sp)
    800017ca:	64a2                	ld	s1,8(sp)
    800017cc:	6105                	addi	sp,sp,32
    800017ce:	8082                	ret

00000000800017d0 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800017d0:	7179                	addi	sp,sp,-48
    800017d2:	f406                	sd	ra,40(sp)
    800017d4:	f022                	sd	s0,32(sp)
    800017d6:	ec26                	sd	s1,24(sp)
    800017d8:	e84a                	sd	s2,16(sp)
    800017da:	1800                	addi	s0,sp,48
    800017dc:	84ae                	mv	s1,a1
    800017de:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800017e0:	fd840593          	addi	a1,s0,-40
    800017e4:	fd1ff0ef          	jal	ra,800017b4 <argaddr>
  return fetchstr(addr, buf, max);
    800017e8:	864a                	mv	a2,s2
    800017ea:	85a6                	mv	a1,s1
    800017ec:	fd843503          	ld	a0,-40(s0)
    800017f0:	f69ff0ef          	jal	ra,80001758 <fetchstr>
}
    800017f4:	70a2                	ld	ra,40(sp)
    800017f6:	7402                	ld	s0,32(sp)
    800017f8:	64e2                	ld	s1,24(sp)
    800017fa:	6942                	ld	s2,16(sp)
    800017fc:	6145                	addi	sp,sp,48
    800017fe:	8082                	ret

0000000080001800 <syscall>:
// [SYS_close]   sys_close,
};

void
syscall(void)
{
    80001800:	1101                	addi	sp,sp,-32
    80001802:	ec06                	sd	ra,24(sp)
    80001804:	e822                	sd	s0,16(sp)
    80001806:	e426                	sd	s1,8(sp)
    80001808:	e04a                	sd	s2,0(sp)
    8000180a:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000180c:	826ff0ef          	jal	ra,80000832 <myproc>
    80001810:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80001812:	05853903          	ld	s2,88(a0)
    80001816:	0a893783          	ld	a5,168(s2)
    8000181a:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000181e:	37fd                	addiw	a5,a5,-1
    80001820:	473d                	li	a4,15
    80001822:	00f76f63          	bltu	a4,a5,80001840 <syscall+0x40>
    80001826:	00369713          	slli	a4,a3,0x3
    8000182a:	00004797          	auipc	a5,0x4
    8000182e:	b9678793          	addi	a5,a5,-1130 # 800053c0 <syscalls>
    80001832:	97ba                	add	a5,a5,a4
    80001834:	639c                	ld	a5,0(a5)
    80001836:	c789                	beqz	a5,80001840 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80001838:	9782                	jalr	a5
    8000183a:	06a93823          	sd	a0,112(s2)
    8000183e:	a829                	j	80001858 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80001840:	0d048613          	addi	a2,s1,208
    80001844:	588c                	lw	a1,48(s1)
    80001846:	00004517          	auipc	a0,0x4
    8000184a:	b4250513          	addi	a0,a0,-1214 # 80005388 <digits+0x2f8>
    8000184e:	b6bfe0ef          	jal	ra,800003b8 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80001852:	6cbc                	ld	a5,88(s1)
    80001854:	577d                	li	a4,-1
    80001856:	fbb8                	sd	a4,112(a5)
  }
    80001858:	60e2                	ld	ra,24(sp)
    8000185a:	6442                	ld	s0,16(sp)
    8000185c:	64a2                	ld	s1,8(sp)
    8000185e:	6902                	ld	s2,0(sp)
    80001860:	6105                	addi	sp,sp,32
    80001862:	8082                	ret

0000000080001864 <blocktest>:
//   return fileread(f, p, n);
// }

// 老师提供测试程序
int blocktest()
{
    80001864:	1101                	addi	sp,sp,-32
    80001866:	ec06                	sd	ra,24(sp)
    80001868:	e822                	sd	s0,16(sp)
    8000186a:	e426                	sd	s1,8(sp)
    8000186c:	e04a                	sd	s2,0(sp)
    8000186e:	1000                	addi	s0,sp,32
  struct buf *b;
  // read superblock
  b = bread(ROOTDEV, 1);
    80001870:	4585                	li	a1,1
    80001872:	4505                	li	a0,1
    80001874:	11a010ef          	jal	ra,8000298e <bread>
    80001878:	84aa                	mv	s1,a0
  struct superblock *sb = (struct superblock *)(b->data);
  printf("Super Block info:\n");
    8000187a:	00004517          	auipc	a0,0x4
    8000187e:	bce50513          	addi	a0,a0,-1074 # 80005448 <syscalls+0x88>
    80001882:	b37fe0ef          	jal	ra,800003b8 <printf>
  printf("\tmagic: %x\n", sb->magic);
    80001886:	4cac                	lw	a1,88(s1)
    80001888:	00004517          	auipc	a0,0x4
    8000188c:	bd850513          	addi	a0,a0,-1064 # 80005460 <syscalls+0xa0>
    80001890:	b29fe0ef          	jal	ra,800003b8 <printf>
  printf("\tsize: %d\n", sb->size);
    80001894:	4cec                	lw	a1,92(s1)
    80001896:	00004517          	auipc	a0,0x4
    8000189a:	bda50513          	addi	a0,a0,-1062 # 80005470 <syscalls+0xb0>
    8000189e:	b1bfe0ef          	jal	ra,800003b8 <printf>
  printf("\tnblocks: %d\n", sb->nblocks);
    800018a2:	50ac                	lw	a1,96(s1)
    800018a4:	00004517          	auipc	a0,0x4
    800018a8:	bdc50513          	addi	a0,a0,-1060 # 80005480 <syscalls+0xc0>
    800018ac:	b0dfe0ef          	jal	ra,800003b8 <printf>
  printf("\tninodes: %d\n", sb->ninodes);
    800018b0:	50ec                	lw	a1,100(s1)
    800018b2:	00004517          	auipc	a0,0x4
    800018b6:	bde50513          	addi	a0,a0,-1058 # 80005490 <syscalls+0xd0>
    800018ba:	afffe0ef          	jal	ra,800003b8 <printf>
  printf("\tnlog: %d\n", sb->nlog);
    800018be:	54ac                	lw	a1,104(s1)
    800018c0:	00004517          	auipc	a0,0x4
    800018c4:	be050513          	addi	a0,a0,-1056 # 800054a0 <syscalls+0xe0>
    800018c8:	af1fe0ef          	jal	ra,800003b8 <printf>
  printf("\tlogstart: %d\n", sb->logstart);
    800018cc:	54ec                	lw	a1,108(s1)
    800018ce:	00004517          	auipc	a0,0x4
    800018d2:	be250513          	addi	a0,a0,-1054 # 800054b0 <syscalls+0xf0>
    800018d6:	ae3fe0ef          	jal	ra,800003b8 <printf>
  printf("\tinodestart: %d\n", sb->inodestart);
    800018da:	58ac                	lw	a1,112(s1)
    800018dc:	00004517          	auipc	a0,0x4
    800018e0:	be450513          	addi	a0,a0,-1052 # 800054c0 <syscalls+0x100>
    800018e4:	ad5fe0ef          	jal	ra,800003b8 <printf>
  printf("\tbmapstart: %d\n\n", sb->bmapstart);
    800018e8:	58ec                	lw	a1,116(s1)
    800018ea:	00004517          	auipc	a0,0x4
    800018ee:	bee50513          	addi	a0,a0,-1042 # 800054d8 <syscalls+0x118>
    800018f2:	ac7fe0ef          	jal	ra,800003b8 <printf>
  brelse(b);
    800018f6:	8526                	mv	a0,s1
    800018f8:	19e010ef          	jal	ra,80002a96 <brelse>

  // read first file data block
  b = bread(ROOTDEV, 47);
    800018fc:	02f00593          	li	a1,47
    80001900:	4505                	li	a0,1
    80001902:	08c010ef          	jal	ra,8000298e <bread>
    80001906:	892a                	mv	s2,a0
  char *c = (char *)(b->data);
  c[BSIZE - 1] = '\0';
    80001908:	44050ba3          	sb	zero,1111(a0)
  char *c = (char *)(b->data);
    8000190c:	05850493          	addi	s1,a0,88
  printf("README (1KB):\n%s\n\n", c);
    80001910:	85a6                	mv	a1,s1
    80001912:	00004517          	auipc	a0,0x4
    80001916:	bde50513          	addi	a0,a0,-1058 # 800054f0 <syscalls+0x130>
    8000191a:	a9ffe0ef          	jal	ra,800003b8 <printf>
  // modify first file data block
  int i;
  for (i = 0; i < BSIZE - 1; i++)
    8000191e:	85a6                	mv	a1,s1
    80001920:	4781                	li	a5,0
  {
    if (c[i] == '\n' && c[i + 1] == '\n')
    80001922:	46a9                	li	a3,10
  for (i = 0; i < BSIZE - 1; i++)
    80001924:	3ff00613          	li	a2,1023
    80001928:	a029                	j	80001932 <blocktest+0xce>
    8000192a:	2785                	addiw	a5,a5,1
    8000192c:	0585                	addi	a1,a1,1
    8000192e:	04c78063          	beq	a5,a2,8000196e <blocktest+0x10a>
    if (c[i] == '\n' && c[i + 1] == '\n')
    80001932:	0005c703          	lbu	a4,0(a1)
    80001936:	fed71ae3          	bne	a4,a3,8000192a <blocktest+0xc6>
    8000193a:	0015c703          	lbu	a4,1(a1)
    8000193e:	fed716e3          	bne	a4,a3,8000192a <blocktest+0xc6>
      break;
  }
  if (i < BSIZE - 1)
    80001942:	3fe00713          	li	a4,1022
    80001946:	02f74463          	blt	a4,a5,8000196e <blocktest+0x10a>
    8000194a:	05878713          	addi	a4,a5,88
    8000194e:	974a                	add	a4,a4,s2
    80001950:	05990693          	addi	a3,s2,89
    80001954:	96be                	add	a3,a3,a5
    80001956:	3ff00613          	li	a2,1023
    8000195a:	40f607bb          	subw	a5,a2,a5
    8000195e:	1782                	slli	a5,a5,0x20
    80001960:	9381                	srli	a5,a5,0x20
    80001962:	97b6                	add	a5,a5,a3
  {
    for (; i < BSIZE; i++)
      c[i] = 0;
    80001964:	00070023          	sb	zero,0(a4)
    for (; i < BSIZE; i++)
    80001968:	0705                	addi	a4,a4,1
    8000196a:	fef71de3          	bne	a4,a5,80001964 <blocktest+0x100>
  }
  bwrite(b);
    8000196e:	854a                	mv	a0,s2
    80001970:	0f4010ef          	jal	ra,80002a64 <bwrite>
  brelse(b);
    80001974:	854a                	mv	a0,s2
    80001976:	120010ef          	jal	ra,80002a96 <brelse>

  // confirm first file data block
  b = bread(ROOTDEV, 47);
    8000197a:	02f00593          	li	a1,47
    8000197e:	4505                	li	a0,1
    80001980:	00e010ef          	jal	ra,8000298e <bread>
    80001984:	84aa                	mv	s1,a0
  c = (char *)(b->data);
  c[BSIZE - 1] = '\0';
    80001986:	44050ba3          	sb	zero,1111(a0)
  printf("README (modified):\n%s\n\n", c);
    8000198a:	05850593          	addi	a1,a0,88
    8000198e:	00004517          	auipc	a0,0x4
    80001992:	b7a50513          	addi	a0,a0,-1158 # 80005508 <syscalls+0x148>
    80001996:	a23fe0ef          	jal	ra,800003b8 <printf>
  brelse(b);
    8000199a:	8526                	mv	a0,s1
    8000199c:	0fa010ef          	jal	ra,80002a96 <brelse>
  return 0;
}
    800019a0:	4501                	li	a0,0
    800019a2:	60e2                	ld	ra,24(sp)
    800019a4:	6442                	ld	s0,16(sp)
    800019a6:	64a2                	ld	s1,8(sp)
    800019a8:	6902                	ld	s2,0(sp)
    800019aa:	6105                	addi	sp,sp,32
    800019ac:	8082                	ret

00000000800019ae <sys_write>:


uint64
sys_write(void)
{
    800019ae:	7179                	addi	sp,sp,-48
    800019b0:	f406                	sd	ra,40(sp)
    800019b2:	f022                	sd	s0,32(sp)
    800019b4:	1800                	addi	s0,sp,48

//   return filewrite(f, p, n);
  int n;
  uint64 p;
  int fd_test;
  argint(0,&fd_test);
    800019b6:	fdc40593          	addi	a1,s0,-36
    800019ba:	4501                	li	a0,0
    800019bc:	dddff0ef          	jal	ra,80001798 <argint>
  argaddr(1, &p);
    800019c0:	fe040593          	addi	a1,s0,-32
    800019c4:	4505                	li	a0,1
    800019c6:	defff0ef          	jal	ra,800017b4 <argaddr>
  argint(2, &n);
    800019ca:	fec40593          	addi	a1,s0,-20
    800019ce:	4509                	li	a0,2
    800019d0:	dc9ff0ef          	jal	ra,80001798 <argint>

  // if(argfd(0, 0, &f) < 0)
  //   return -1;
  if(fd_test < 3)
    800019d4:	fdc42783          	lw	a5,-36(s0)
    800019d8:	4709                	li	a4,2
    800019da:	00f75a63          	bge	a4,a5,800019ee <sys_write+0x40>
    return consolewrite(1,p,n);
  else if(fd_test == 3)
    800019de:	470d                	li	a4,3
    return blocktest();
  return 0;
    800019e0:	4501                	li	a0,0
  else if(fd_test == 3)
    800019e2:	00e78e63          	beq	a5,a4,800019fe <sys_write+0x50>
}
    800019e6:	70a2                	ld	ra,40(sp)
    800019e8:	7402                	ld	s0,32(sp)
    800019ea:	6145                	addi	sp,sp,48
    800019ec:	8082                	ret
    return consolewrite(1,p,n);
    800019ee:	fec42603          	lw	a2,-20(s0)
    800019f2:	fe043583          	ld	a1,-32(s0)
    800019f6:	4505                	li	a0,1
    800019f8:	6b5000ef          	jal	ra,800028ac <consolewrite>
    800019fc:	b7ed                	j	800019e6 <sys_write+0x38>
    return blocktest();
    800019fe:	e67ff0ef          	jal	ra,80001864 <blocktest>
    80001a02:	b7d5                	j	800019e6 <sys_write+0x38>

0000000080001a04 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80001a04:	1101                	addi	sp,sp,-32
    80001a06:	ec06                	sd	ra,24(sp)
    80001a08:	e822                	sd	s0,16(sp)
    80001a0a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80001a0c:	fec40593          	addi	a1,s0,-20
    80001a10:	4501                	li	a0,0
    80001a12:	d87ff0ef          	jal	ra,80001798 <argint>
  exit(n);
    80001a16:	fec42503          	lw	a0,-20(s0)
    80001a1a:	e1cff0ef          	jal	ra,80001036 <exit>
  return 0;  // not reached
}
    80001a1e:	4501                	li	a0,0
    80001a20:	60e2                	ld	ra,24(sp)
    80001a22:	6442                	ld	s0,16(sp)
    80001a24:	6105                	addi	sp,sp,32
    80001a26:	8082                	ret

0000000080001a28 <sys_getpid>:

uint64
sys_getpid(void)
{
    80001a28:	1141                	addi	sp,sp,-16
    80001a2a:	e406                	sd	ra,8(sp)
    80001a2c:	e022                	sd	s0,0(sp)
    80001a2e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80001a30:	e03fe0ef          	jal	ra,80000832 <myproc>
}
    80001a34:	5908                	lw	a0,48(a0)
    80001a36:	60a2                	ld	ra,8(sp)
    80001a38:	6402                	ld	s0,0(sp)
    80001a3a:	0141                	addi	sp,sp,16
    80001a3c:	8082                	ret

0000000080001a3e <sys_fork>:

uint64
sys_fork(void)
{
    80001a3e:	1141                	addi	sp,sp,-16
    80001a40:	e406                	sd	ra,8(sp)
    80001a42:	e022                	sd	s0,0(sp)
    80001a44:	0800                	addi	s0,sp,16
  return fork();
    80001a46:	a7cff0ef          	jal	ra,80000cc2 <fork>
}
    80001a4a:	60a2                	ld	ra,8(sp)
    80001a4c:	6402                	ld	s0,0(sp)
    80001a4e:	0141                	addi	sp,sp,16
    80001a50:	8082                	ret

0000000080001a52 <sys_wait>:

uint64
sys_wait(void)
{
    80001a52:	1101                	addi	sp,sp,-32
    80001a54:	ec06                	sd	ra,24(sp)
    80001a56:	e822                	sd	s0,16(sp)
    80001a58:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80001a5a:	fe840593          	addi	a1,s0,-24
    80001a5e:	4501                	li	a0,0
    80001a60:	d55ff0ef          	jal	ra,800017b4 <argaddr>
  return wait(p);
    80001a64:	fe843503          	ld	a0,-24(s0)
    80001a68:	eeeff0ef          	jal	ra,80001156 <wait>
}
    80001a6c:	60e2                	ld	ra,24(sp)
    80001a6e:	6442                	ld	s0,16(sp)
    80001a70:	6105                	addi	sp,sp,32
    80001a72:	8082                	ret

0000000080001a74 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80001a74:	7179                	addi	sp,sp,-48
    80001a76:	f406                	sd	ra,40(sp)
    80001a78:	f022                	sd	s0,32(sp)
    80001a7a:	ec26                	sd	s1,24(sp)
    80001a7c:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80001a7e:	fdc40593          	addi	a1,s0,-36
    80001a82:	4501                	li	a0,0
    80001a84:	d15ff0ef          	jal	ra,80001798 <argint>
  addr = myproc()->sz;
    80001a88:	dabfe0ef          	jal	ra,80000832 <myproc>
    80001a8c:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80001a8e:	fdc42503          	lw	a0,-36(s0)
    80001a92:	9e0ff0ef          	jal	ra,80000c72 <growproc>
    80001a96:	00054863          	bltz	a0,80001aa6 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80001a9a:	8526                	mv	a0,s1
    80001a9c:	70a2                	ld	ra,40(sp)
    80001a9e:	7402                	ld	s0,32(sp)
    80001aa0:	64e2                	ld	s1,24(sp)
    80001aa2:	6145                	addi	sp,sp,48
    80001aa4:	8082                	ret
    return -1;
    80001aa6:	54fd                	li	s1,-1
    80001aa8:	bfcd                	j	80001a9a <sys_sbrk+0x26>

0000000080001aaa <sys_sleep>:

uint64
sys_sleep(void)
{
    80001aaa:	7139                	addi	sp,sp,-64
    80001aac:	fc06                	sd	ra,56(sp)
    80001aae:	f822                	sd	s0,48(sp)
    80001ab0:	f426                	sd	s1,40(sp)
    80001ab2:	f04a                	sd	s2,32(sp)
    80001ab4:	ec4e                	sd	s3,24(sp)
    80001ab6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80001ab8:	fcc40593          	addi	a1,s0,-52
    80001abc:	4501                	li	a0,0
    80001abe:	cdbff0ef          	jal	ra,80001798 <argint>
  if(n < 0)
    80001ac2:	fcc42783          	lw	a5,-52(s0)
    80001ac6:	0607c563          	bltz	a5,80001b30 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80001aca:	00011517          	auipc	a0,0x11
    80001ace:	d0650513          	addi	a0,a0,-762 # 800127d0 <tickslock>
    80001ad2:	849ff0ef          	jal	ra,8000131a <acquire>
  ticks0 = ticks;
    80001ad6:	00005917          	auipc	s2,0x5
    80001ada:	06a92903          	lw	s2,106(s2) # 80006b40 <ticks>
  while(ticks - ticks0 < n){
    80001ade:	fcc42783          	lw	a5,-52(s0)
    80001ae2:	cb8d                	beqz	a5,80001b14 <sys_sleep+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80001ae4:	00011997          	auipc	s3,0x11
    80001ae8:	cec98993          	addi	s3,s3,-788 # 800127d0 <tickslock>
    80001aec:	00005497          	auipc	s1,0x5
    80001af0:	05448493          	addi	s1,s1,84 # 80006b40 <ticks>
    if(killed(myproc())){
    80001af4:	d3ffe0ef          	jal	ra,80000832 <myproc>
    80001af8:	e34ff0ef          	jal	ra,8000112c <killed>
    80001afc:	ed0d                	bnez	a0,80001b36 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80001afe:	85ce                	mv	a1,s3
    80001b00:	8526                	mv	a0,s1
    80001b02:	c28ff0ef          	jal	ra,80000f2a <sleep>
  while(ticks - ticks0 < n){
    80001b06:	409c                	lw	a5,0(s1)
    80001b08:	412787bb          	subw	a5,a5,s2
    80001b0c:	fcc42703          	lw	a4,-52(s0)
    80001b10:	fee7e2e3          	bltu	a5,a4,80001af4 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80001b14:	00011517          	auipc	a0,0x11
    80001b18:	cbc50513          	addi	a0,a0,-836 # 800127d0 <tickslock>
    80001b1c:	897ff0ef          	jal	ra,800013b2 <release>
  return 0;
    80001b20:	4501                	li	a0,0
}
    80001b22:	70e2                	ld	ra,56(sp)
    80001b24:	7442                	ld	s0,48(sp)
    80001b26:	74a2                	ld	s1,40(sp)
    80001b28:	7902                	ld	s2,32(sp)
    80001b2a:	69e2                	ld	s3,24(sp)
    80001b2c:	6121                	addi	sp,sp,64
    80001b2e:	8082                	ret
    n = 0;
    80001b30:	fc042623          	sw	zero,-52(s0)
    80001b34:	bf59                	j	80001aca <sys_sleep+0x20>
      release(&tickslock);
    80001b36:	00011517          	auipc	a0,0x11
    80001b3a:	c9a50513          	addi	a0,a0,-870 # 800127d0 <tickslock>
    80001b3e:	875ff0ef          	jal	ra,800013b2 <release>
      return -1;
    80001b42:	557d                	li	a0,-1
    80001b44:	bff9                	j	80001b22 <sys_sleep+0x78>

0000000080001b46 <sys_kill>:

uint64
sys_kill(void)
{
    80001b46:	1101                	addi	sp,sp,-32
    80001b48:	ec06                	sd	ra,24(sp)
    80001b4a:	e822                	sd	s0,16(sp)
    80001b4c:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80001b4e:	fec40593          	addi	a1,s0,-20
    80001b52:	4501                	li	a0,0
    80001b54:	c45ff0ef          	jal	ra,80001798 <argint>
  return kill(pid);
    80001b58:	fec42503          	lw	a0,-20(s0)
    80001b5c:	d46ff0ef          	jal	ra,800010a2 <kill>
}
    80001b60:	60e2                	ld	ra,24(sp)
    80001b62:	6442                	ld	s0,16(sp)
    80001b64:	6105                	addi	sp,sp,32
    80001b66:	8082                	ret

0000000080001b68 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80001b68:	1101                	addi	sp,sp,-32
    80001b6a:	ec06                	sd	ra,24(sp)
    80001b6c:	e822                	sd	s0,16(sp)
    80001b6e:	e426                	sd	s1,8(sp)
    80001b70:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80001b72:	00011517          	auipc	a0,0x11
    80001b76:	c5e50513          	addi	a0,a0,-930 # 800127d0 <tickslock>
    80001b7a:	fa0ff0ef          	jal	ra,8000131a <acquire>
  xticks = ticks;
    80001b7e:	00005497          	auipc	s1,0x5
    80001b82:	fc24a483          	lw	s1,-62(s1) # 80006b40 <ticks>
  release(&tickslock);
    80001b86:	00011517          	auipc	a0,0x11
    80001b8a:	c4a50513          	addi	a0,a0,-950 # 800127d0 <tickslock>
    80001b8e:	825ff0ef          	jal	ra,800013b2 <release>
  return xticks;
}
    80001b92:	02049513          	slli	a0,s1,0x20
    80001b96:	9101                	srli	a0,a0,0x20
    80001b98:	60e2                	ld	ra,24(sp)
    80001b9a:	6442                	ld	s0,16(sp)
    80001b9c:	64a2                	ld	s1,8(sp)
    80001b9e:	6105                	addi	sp,sp,32
    80001ba0:	8082                	ret

0000000080001ba2 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80001ba2:	1141                	addi	sp,sp,-16
    80001ba4:	e406                	sd	ra,8(sp)
    80001ba6:	e022                	sd	s0,0(sp)
    80001ba8:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80001baa:	00004597          	auipc	a1,0x4
    80001bae:	97658593          	addi	a1,a1,-1674 # 80005520 <syscalls+0x160>
    80001bb2:	00011517          	auipc	a0,0x11
    80001bb6:	c1e50513          	addi	a0,a0,-994 # 800127d0 <tickslock>
    80001bba:	ee0ff0ef          	jal	ra,8000129a <initlock>
}
    80001bbe:	60a2                	ld	ra,8(sp)
    80001bc0:	6402                	ld	s0,0(sp)
    80001bc2:	0141                	addi	sp,sp,16
    80001bc4:	8082                	ret

0000000080001bc6 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001bc6:	1141                	addi	sp,sp,-16
    80001bc8:	e422                	sd	s0,8(sp)
    80001bca:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001bcc:	ffffe797          	auipc	a5,0xffffe
    80001bd0:	58478793          	addi	a5,a5,1412 # 80000150 <kernelvec>
    80001bd4:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001bd8:	6422                	ld	s0,8(sp)
    80001bda:	0141                	addi	sp,sp,16
    80001bdc:	8082                	ret

0000000080001bde <usertrapret>:
// 现阶段我swtch之后会到这个地方往下执行
// 这个函数的主要作用就是将当前进程从内核态恢复到用户态
// 在处理完用户态进程的系统调用、中断或异常后被调用
void
usertrapret(void)
{
    80001bde:	1141                	addi	sp,sp,-16
    80001be0:	e406                	sd	ra,8(sp)
    80001be2:	e022                	sd	s0,0(sp)
    80001be4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001be6:	c4dfe0ef          	jal	ra,80000832 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001bea:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001bee:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001bf0:	10079073          	csrw	sstatus,a5
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  // uservec 是trampoline.S中的一个标签，用于记录从用户态到内核态的入口
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80001bf4:	00002697          	auipc	a3,0x2
    80001bf8:	40c68693          	addi	a3,a3,1036 # 80004000 <_trampoline>
    80001bfc:	00002717          	auipc	a4,0x2
    80001c00:	40470713          	addi	a4,a4,1028 # 80004000 <_trampoline>
    80001c04:	8f15                	sub	a4,a4,a3
    80001c06:	040007b7          	lui	a5,0x4000
    80001c0a:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80001c0c:	07b2                	slli	a5,a5,0xc
    80001c0e:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001c10:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001c14:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001c16:	18002673          	csrr	a2,satp
    80001c1a:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001c1c:	6d30                	ld	a2,88(a0)
    80001c1e:	6138                	ld	a4,64(a0)
    80001c20:	6585                	lui	a1,0x1
    80001c22:	972e                	add	a4,a4,a1
    80001c24:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001c26:	6d38                	ld	a4,88(a0)
    80001c28:	00000617          	auipc	a2,0x0
    80001c2c:	12a60613          	addi	a2,a2,298 # 80001d52 <usertrap>
    80001c30:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001c32:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001c34:	8612                	mv	a2,tp
    80001c36:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001c38:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001c3c:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001c40:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001c44:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001c48:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001c4a:	6f18                	ld	a4,24(a4)
    80001c4c:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80001c50:	6928                	ld	a0,80(a0)
    80001c52:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline); // 看作一个函数指针
    80001c54:	00002717          	auipc	a4,0x2
    80001c58:	44870713          	addi	a4,a4,1096 # 8000409c <userret>
    80001c5c:	8f15                	sub	a4,a4,a3
    80001c5e:	97ba                	add	a5,a5,a4
  // 这个看作在调用 userret()这个函数，用于从内核到用户态的，这个函数就放在trampoline_userret这个位置
  // 后面的satp是参数，应该是这个进程的用户态的页表
  ((void (*)(uint64))trampoline_userret)(satp);  
    80001c60:	577d                	li	a4,-1
    80001c62:	177e                	slli	a4,a4,0x3f
    80001c64:	8d59                	or	a0,a0,a4
    80001c66:	9782                	jalr	a5
}
    80001c68:	60a2                	ld	ra,8(sp)
    80001c6a:	6402                	ld	s0,0(sp)
    80001c6c:	0141                	addi	sp,sp,16
    80001c6e:	8082                	ret

0000000080001c70 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001c70:	1141                	addi	sp,sp,-16
    80001c72:	e406                	sd	ra,8(sp)
    80001c74:	e022                	sd	s0,0(sp)
    80001c76:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80001c78:	b8ffe0ef          	jal	ra,80000806 <cpuid>
    80001c7c:	cd11                	beqz	a0,80001c98 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80001c7e:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80001c82:	000f4737          	lui	a4,0xf4
    80001c86:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80001c8a:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80001c8c:	14d79073          	csrw	0x14d,a5
}
    80001c90:	60a2                	ld	ra,8(sp)
    80001c92:	6402                	ld	s0,0(sp)
    80001c94:	0141                	addi	sp,sp,16
    80001c96:	8082                	ret
    acquire(&tickslock);
    80001c98:	00011517          	auipc	a0,0x11
    80001c9c:	b3850513          	addi	a0,a0,-1224 # 800127d0 <tickslock>
    80001ca0:	e7aff0ef          	jal	ra,8000131a <acquire>
    ticks++;
    80001ca4:	00005717          	auipc	a4,0x5
    80001ca8:	e9c70713          	addi	a4,a4,-356 # 80006b40 <ticks>
    80001cac:	431c                	lw	a5,0(a4)
    80001cae:	2785                	addiw	a5,a5,1
    80001cb0:	c31c                	sw	a5,0(a4)
    if(ticks % 30 == 0){ //每30次时钟中断打印出一个T
    80001cb2:	4779                	li	a4,30
    80001cb4:	02e7f7bb          	remuw	a5,a5,a4
    80001cb8:	cf91                	beqz	a5,80001cd4 <clockintr+0x64>
    wakeup(&ticks);
    80001cba:	00005517          	auipc	a0,0x5
    80001cbe:	e8650513          	addi	a0,a0,-378 # 80006b40 <ticks>
    80001cc2:	ab4ff0ef          	jal	ra,80000f76 <wakeup>
    release(&tickslock);
    80001cc6:	00011517          	auipc	a0,0x11
    80001cca:	b0a50513          	addi	a0,a0,-1270 # 800127d0 <tickslock>
    80001cce:	ee4ff0ef          	jal	ra,800013b2 <release>
    80001cd2:	b775                	j	80001c7e <clockintr+0xe>
        printf("T");
    80001cd4:	00004517          	auipc	a0,0x4
    80001cd8:	85450513          	addi	a0,a0,-1964 # 80005528 <syscalls+0x168>
    80001cdc:	edcfe0ef          	jal	ra,800003b8 <printf>
    80001ce0:	bfe9                	j	80001cba <clockintr+0x4a>

0000000080001ce2 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001ce2:	1101                	addi	sp,sp,-32
    80001ce4:	ec06                	sd	ra,24(sp)
    80001ce6:	e822                	sd	s0,16(sp)
    80001ce8:	e426                	sd	s1,8(sp)
    80001cea:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001cec:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80001cf0:	57fd                	li	a5,-1
    80001cf2:	17fe                	slli	a5,a5,0x3f
    80001cf4:	07a5                	addi	a5,a5,9
    80001cf6:	00f70d63          	beq	a4,a5,80001d10 <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80001cfa:	57fd                	li	a5,-1
    80001cfc:	17fe                	slli	a5,a5,0x3f
    80001cfe:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80001d00:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80001d02:	04f70463          	beq	a4,a5,80001d4a <devintr+0x68>
  }
}
    80001d06:	60e2                	ld	ra,24(sp)
    80001d08:	6442                	ld	s0,16(sp)
    80001d0a:	64a2                	ld	s1,8(sp)
    80001d0c:	6105                	addi	sp,sp,32
    80001d0e:	8082                	ret
    int irq = plic_claim();
    80001d10:	d9efe0ef          	jal	ra,800002ae <plic_claim>
    80001d14:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001d16:	47a9                	li	a5,10
    80001d18:	02f50363          	beq	a0,a5,80001d3e <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    80001d1c:	4785                	li	a5,1
    80001d1e:	02f50363          	beq	a0,a5,80001d44 <devintr+0x62>
    return 1;
    80001d22:	4505                	li	a0,1
    } else if(irq){
    80001d24:	d0ed                	beqz	s1,80001d06 <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80001d26:	85a6                	mv	a1,s1
    80001d28:	00004517          	auipc	a0,0x4
    80001d2c:	80850513          	addi	a0,a0,-2040 # 80005530 <syscalls+0x170>
    80001d30:	e88fe0ef          	jal	ra,800003b8 <printf>
      plic_complete(irq);
    80001d34:	8526                	mv	a0,s1
    80001d36:	d98fe0ef          	jal	ra,800002ce <plic_complete>
    return 1;
    80001d3a:	4505                	li	a0,1
    80001d3c:	b7e9                	j	80001d06 <devintr+0x24>
      uartintr();
    80001d3e:	368000ef          	jal	ra,800020a6 <uartintr>
    80001d42:	bfcd                	j	80001d34 <devintr+0x52>
    virtio_disk_intr();
    80001d44:	388010ef          	jal	ra,800030cc <virtio_disk_intr>
    80001d48:	b7f5                	j	80001d34 <devintr+0x52>
    clockintr();
    80001d4a:	f27ff0ef          	jal	ra,80001c70 <clockintr>
    return 2;
    80001d4e:	4509                	li	a0,2
    80001d50:	bf5d                	j	80001d06 <devintr+0x24>

0000000080001d52 <usertrap>:
{
    80001d52:	1101                	addi	sp,sp,-32
    80001d54:	ec06                	sd	ra,24(sp)
    80001d56:	e822                	sd	s0,16(sp)
    80001d58:	e426                	sd	s1,8(sp)
    80001d5a:	e04a                	sd	s2,0(sp)
    80001d5c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d5e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001d62:	1007f793          	andi	a5,a5,256
    80001d66:	ef85                	bnez	a5,80001d9e <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001d68:	ffffe797          	auipc	a5,0xffffe
    80001d6c:	3e878793          	addi	a5,a5,1000 # 80000150 <kernelvec>
    80001d70:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001d74:	abffe0ef          	jal	ra,80000832 <myproc>
    80001d78:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001d7a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001d7c:	14102773          	csrr	a4,sepc
    80001d80:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001d82:	14202773          	csrr	a4,scause
  if(r_scause() == 8){ //用户态系统调用就会来到这个地方
    80001d86:	47a1                	li	a5,8
    80001d88:	02f70163          	beq	a4,a5,80001daa <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80001d8c:	f57ff0ef          	jal	ra,80001ce2 <devintr>
    80001d90:	892a                	mv	s2,a0
    80001d92:	c135                	beqz	a0,80001df6 <usertrap+0xa4>
  if(killed(p))
    80001d94:	8526                	mv	a0,s1
    80001d96:	b96ff0ef          	jal	ra,8000112c <killed>
    80001d9a:	cd1d                	beqz	a0,80001dd8 <usertrap+0x86>
    80001d9c:	a81d                	j	80001dd2 <usertrap+0x80>
    panic("usertrap: not from user mode");
    80001d9e:	00003517          	auipc	a0,0x3
    80001da2:	7b250513          	addi	a0,a0,1970 # 80005550 <syscalls+0x190>
    80001da6:	8c7fe0ef          	jal	ra,8000066c <panic>
    if(killed(p))
    80001daa:	b82ff0ef          	jal	ra,8000112c <killed>
    80001dae:	e121                	bnez	a0,80001dee <usertrap+0x9c>
    p->trapframe->epc += 4;
    80001db0:	6cb8                	ld	a4,88(s1)
    80001db2:	6f1c                	ld	a5,24(a4)
    80001db4:	0791                	addi	a5,a5,4
    80001db6:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001db8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001dbc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dc0:	10079073          	csrw	sstatus,a5
    syscall();
    80001dc4:	a3dff0ef          	jal	ra,80001800 <syscall>
  if(killed(p))
    80001dc8:	8526                	mv	a0,s1
    80001dca:	b62ff0ef          	jal	ra,8000112c <killed>
    80001dce:	c901                	beqz	a0,80001dde <usertrap+0x8c>
    80001dd0:	4901                	li	s2,0
    exit(-1);
    80001dd2:	557d                	li	a0,-1
    80001dd4:	a62ff0ef          	jal	ra,80001036 <exit>
  if(which_dev == 2)
    80001dd8:	4789                	li	a5,2
    80001dda:	04f90563          	beq	s2,a5,80001e24 <usertrap+0xd2>
  usertrapret();
    80001dde:	e01ff0ef          	jal	ra,80001bde <usertrapret>
}
    80001de2:	60e2                	ld	ra,24(sp)
    80001de4:	6442                	ld	s0,16(sp)
    80001de6:	64a2                	ld	s1,8(sp)
    80001de8:	6902                	ld	s2,0(sp)
    80001dea:	6105                	addi	sp,sp,32
    80001dec:	8082                	ret
      exit(-1);
    80001dee:	557d                	li	a0,-1
    80001df0:	a46ff0ef          	jal	ra,80001036 <exit>
    80001df4:	bf75                	j	80001db0 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001df6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80001dfa:	5890                	lw	a2,48(s1)
    80001dfc:	00003517          	auipc	a0,0x3
    80001e00:	77450513          	addi	a0,a0,1908 # 80005570 <syscalls+0x1b0>
    80001e04:	db4fe0ef          	jal	ra,800003b8 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001e08:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001e0c:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80001e10:	00003517          	auipc	a0,0x3
    80001e14:	79050513          	addi	a0,a0,1936 # 800055a0 <syscalls+0x1e0>
    80001e18:	da0fe0ef          	jal	ra,800003b8 <printf>
    setkilled(p);
    80001e1c:	8526                	mv	a0,s1
    80001e1e:	aeaff0ef          	jal	ra,80001108 <setkilled>
    80001e22:	b75d                	j	80001dc8 <usertrap+0x76>
    yield(); //等下要把这个注释掉 这个是用来处理时钟中断的
    80001e24:	8daff0ef          	jal	ra,80000efe <yield>
    80001e28:	bf5d                	j	80001dde <usertrap+0x8c>

0000000080001e2a <kerneltrap>:
{
    80001e2a:	7179                	addi	sp,sp,-48
    80001e2c:	f406                	sd	ra,40(sp)
    80001e2e:	f022                	sd	s0,32(sp)
    80001e30:	ec26                	sd	s1,24(sp)
    80001e32:	e84a                	sd	s2,16(sp)
    80001e34:	e44e                	sd	s3,8(sp)
    80001e36:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001e38:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e3c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001e40:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001e44:	1004f793          	andi	a5,s1,256
    80001e48:	c795                	beqz	a5,80001e74 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e4a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e4e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001e50:	eb85                	bnez	a5,80001e80 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80001e52:	e91ff0ef          	jal	ra,80001ce2 <devintr>
    80001e56:	c91d                	beqz	a0,80001e8c <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80001e58:	4789                	li	a5,2
    80001e5a:	04f50a63          	beq	a0,a5,80001eae <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001e5e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e62:	10049073          	csrw	sstatus,s1
}
    80001e66:	70a2                	ld	ra,40(sp)
    80001e68:	7402                	ld	s0,32(sp)
    80001e6a:	64e2                	ld	s1,24(sp)
    80001e6c:	6942                	ld	s2,16(sp)
    80001e6e:	69a2                	ld	s3,8(sp)
    80001e70:	6145                	addi	sp,sp,48
    80001e72:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001e74:	00003517          	auipc	a0,0x3
    80001e78:	75450513          	addi	a0,a0,1876 # 800055c8 <syscalls+0x208>
    80001e7c:	ff0fe0ef          	jal	ra,8000066c <panic>
    panic("kerneltrap: interrupts enabled");
    80001e80:	00003517          	auipc	a0,0x3
    80001e84:	77050513          	addi	a0,a0,1904 # 800055f0 <syscalls+0x230>
    80001e88:	fe4fe0ef          	jal	ra,8000066c <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001e8c:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001e90:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80001e94:	85ce                	mv	a1,s3
    80001e96:	00003517          	auipc	a0,0x3
    80001e9a:	77a50513          	addi	a0,a0,1914 # 80005610 <syscalls+0x250>
    80001e9e:	d1afe0ef          	jal	ra,800003b8 <printf>
    panic("kerneltrap");
    80001ea2:	00003517          	auipc	a0,0x3
    80001ea6:	79650513          	addi	a0,a0,1942 # 80005638 <syscalls+0x278>
    80001eaa:	fc2fe0ef          	jal	ra,8000066c <panic>
  if(which_dev == 2 && myproc() != 0)
    80001eae:	985fe0ef          	jal	ra,80000832 <myproc>
    80001eb2:	d555                	beqz	a0,80001e5e <kerneltrap+0x34>
    yield();
    80001eb4:	84aff0ef          	jal	ra,80000efe <yield>
    80001eb8:	b75d                	j	80001e5e <kerneltrap+0x34>

0000000080001eba <uartinit>:

// 原本是被console.c调用，现在被printf.c调用
// 作用：初始化UART硬件
void
uartinit(void)
{
    80001eba:	1141                	addi	sp,sp,-16
    80001ebc:	e406                	sd	ra,8(sp)
    80001ebe:	e022                	sd	s0,0(sp)
    80001ec0:	0800                	addi	s0,sp,16
  // disable interrupts.
  // 关闭中断
  WriteReg(IER, 0x00);
    80001ec2:	100007b7          	lui	a5,0x10000
    80001ec6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  // 设置波特率
  WriteReg(LCR, LCR_BAUD_LATCH);
    80001eca:	f8000713          	li	a4,-128
    80001ece:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  // 配置数据格式
  WriteReg(0, 0x03);
    80001ed2:	470d                	li	a4,3
    80001ed4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  // 使能并清空FIFO
  WriteReg(1, 0x00);
    80001ed8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80001edc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80001ee0:	469d                	li	a3,7
    80001ee2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80001ee6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    80001eea:	00003597          	auipc	a1,0x3
    80001eee:	75e58593          	addi	a1,a1,1886 # 80005648 <syscalls+0x288>
    80001ef2:	00011517          	auipc	a0,0x11
    80001ef6:	8f650513          	addi	a0,a0,-1802 # 800127e8 <uart_tx_lock>
    80001efa:	ba0ff0ef          	jal	ra,8000129a <initlock>
}
    80001efe:	60a2                	ld	ra,8(sp)
    80001f00:	6402                	ld	s0,0(sp)
    80001f02:	0141                	addi	sp,sp,16
    80001f04:	8082                	ret

0000000080001f06 <uartputc_sync>:
// to echo characters. it spins waiting for the uart's
// output register to be empty.
// 直接（同步）发送一个字符到UART
void
uartputc_sync(int c)
{
    80001f06:	1101                	addi	sp,sp,-32
    80001f08:	ec06                	sd	ra,24(sp)
    80001f0a:	e822                	sd	s0,16(sp)
    80001f0c:	e426                	sd	s1,8(sp)
    80001f0e:	1000                	addi	s0,sp,32
    80001f10:	84aa                	mv	s1,a0
  push_off();
    80001f12:	bc8ff0ef          	jal	ra,800012da <push_off>

  if(panicked){
    80001f16:	00005797          	auipc	a5,0x5
    80001f1a:	c1e7a783          	lw	a5,-994(a5) # 80006b34 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80001f1e:	10000737          	lui	a4,0x10000
  if(panicked){
    80001f22:	c391                	beqz	a5,80001f26 <uartputc_sync+0x20>
    for(;;)
    80001f24:	a001                	j	80001f24 <uartputc_sync+0x1e>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80001f26:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80001f2a:	0207f793          	andi	a5,a5,32
    80001f2e:	dfe5                	beqz	a5,80001f26 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    80001f30:	0ff4f513          	zext.b	a0,s1
    80001f34:	100007b7          	lui	a5,0x10000
    80001f38:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80001f3c:	c22ff0ef          	jal	ra,8000135e <pop_off>
}
    80001f40:	60e2                	ld	ra,24(sp)
    80001f42:	6442                	ld	s0,16(sp)
    80001f44:	64a2                	ld	s1,8(sp)
    80001f46:	6105                	addi	sp,sp,32
    80001f48:	8082                	ret

0000000080001f4a <uartstart>:
// called from both the top- and bottom-half.
// 将缓冲区的数据实际写入UART寄存器，启动发送
void uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80001f4a:	00005797          	auipc	a5,0x5
    80001f4e:	bfe7b783          	ld	a5,-1026(a5) # 80006b48 <uart_tx_r>
    80001f52:	00005717          	auipc	a4,0x5
    80001f56:	bfe73703          	ld	a4,-1026(a4) # 80006b50 <uart_tx_w>
    80001f5a:	06f70c63          	beq	a4,a5,80001fd2 <uartstart+0x88>
{
    80001f5e:	7139                	addi	sp,sp,-64
    80001f60:	fc06                	sd	ra,56(sp)
    80001f62:	f822                	sd	s0,48(sp)
    80001f64:	f426                	sd	s1,40(sp)
    80001f66:	f04a                	sd	s2,32(sp)
    80001f68:	ec4e                	sd	s3,24(sp)
    80001f6a:	e852                	sd	s4,16(sp)
    80001f6c:	e456                	sd	s5,8(sp)
    80001f6e:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80001f70:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80001f74:	00011a17          	auipc	s4,0x11
    80001f78:	874a0a13          	addi	s4,s4,-1932 # 800127e8 <uart_tx_lock>
    uart_tx_r += 1;
    80001f7c:	00005497          	auipc	s1,0x5
    80001f80:	bcc48493          	addi	s1,s1,-1076 # 80006b48 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80001f84:	00005997          	auipc	s3,0x5
    80001f88:	bcc98993          	addi	s3,s3,-1076 # 80006b50 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80001f8c:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80001f90:	02077713          	andi	a4,a4,32
    80001f94:	c715                	beqz	a4,80001fc0 <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80001f96:	01f7f713          	andi	a4,a5,31
    80001f9a:	9752                	add	a4,a4,s4
    80001f9c:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80001fa0:	0785                	addi	a5,a5,1
    80001fa2:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r); 
    80001fa4:	8526                	mv	a0,s1
    80001fa6:	fd1fe0ef          	jal	ra,80000f76 <wakeup>
    
    WriteReg(THR, c);
    80001faa:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    80001fae:	609c                	ld	a5,0(s1)
    80001fb0:	0009b703          	ld	a4,0(s3)
    80001fb4:	fcf71ce3          	bne	a4,a5,80001f8c <uartstart+0x42>
      ReadReg(ISR);
    80001fb8:	100007b7          	lui	a5,0x10000
    80001fbc:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
  }
}
    80001fc0:	70e2                	ld	ra,56(sp)
    80001fc2:	7442                	ld	s0,48(sp)
    80001fc4:	74a2                	ld	s1,40(sp)
    80001fc6:	7902                	ld	s2,32(sp)
    80001fc8:	69e2                	ld	s3,24(sp)
    80001fca:	6a42                	ld	s4,16(sp)
    80001fcc:	6aa2                	ld	s5,8(sp)
    80001fce:	6121                	addi	sp,sp,64
    80001fd0:	8082                	ret
      ReadReg(ISR);
    80001fd2:	100007b7          	lui	a5,0x10000
    80001fd6:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
      return;
    80001fda:	8082                	ret

0000000080001fdc <uartputc>:
{
    80001fdc:	7179                	addi	sp,sp,-48
    80001fde:	f406                	sd	ra,40(sp)
    80001fe0:	f022                	sd	s0,32(sp)
    80001fe2:	ec26                	sd	s1,24(sp)
    80001fe4:	e84a                	sd	s2,16(sp)
    80001fe6:	e44e                	sd	s3,8(sp)
    80001fe8:	e052                	sd	s4,0(sp)
    80001fea:	1800                	addi	s0,sp,48
    80001fec:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80001fee:	00010517          	auipc	a0,0x10
    80001ff2:	7fa50513          	addi	a0,a0,2042 # 800127e8 <uart_tx_lock>
    80001ff6:	b24ff0ef          	jal	ra,8000131a <acquire>
  if(panicked){
    80001ffa:	00005797          	auipc	a5,0x5
    80001ffe:	b3a7a783          	lw	a5,-1222(a5) # 80006b34 <panicked>
    80002002:	efbd                	bnez	a5,80002080 <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80002004:	00005717          	auipc	a4,0x5
    80002008:	b4c73703          	ld	a4,-1204(a4) # 80006b50 <uart_tx_w>
    8000200c:	00005797          	auipc	a5,0x5
    80002010:	b3c7b783          	ld	a5,-1220(a5) # 80006b48 <uart_tx_r>
    80002014:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80002018:	00010997          	auipc	s3,0x10
    8000201c:	7d098993          	addi	s3,s3,2000 # 800127e8 <uart_tx_lock>
    80002020:	00005497          	auipc	s1,0x5
    80002024:	b2848493          	addi	s1,s1,-1240 # 80006b48 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80002028:	00005917          	auipc	s2,0x5
    8000202c:	b2890913          	addi	s2,s2,-1240 # 80006b50 <uart_tx_w>
    80002030:	00e79d63          	bne	a5,a4,8000204a <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80002034:	85ce                	mv	a1,s3
    80002036:	8526                	mv	a0,s1
    80002038:	ef3fe0ef          	jal	ra,80000f2a <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000203c:	00093703          	ld	a4,0(s2)
    80002040:	609c                	ld	a5,0(s1)
    80002042:	02078793          	addi	a5,a5,32
    80002046:	fee787e3          	beq	a5,a4,80002034 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    8000204a:	00010497          	auipc	s1,0x10
    8000204e:	79e48493          	addi	s1,s1,1950 # 800127e8 <uart_tx_lock>
    80002052:	01f77793          	andi	a5,a4,31
    80002056:	97a6                	add	a5,a5,s1
    80002058:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    8000205c:	0705                	addi	a4,a4,1
    8000205e:	00005797          	auipc	a5,0x5
    80002062:	aee7b923          	sd	a4,-1294(a5) # 80006b50 <uart_tx_w>
  uartstart();
    80002066:	ee5ff0ef          	jal	ra,80001f4a <uartstart>
  release(&uart_tx_lock);
    8000206a:	8526                	mv	a0,s1
    8000206c:	b46ff0ef          	jal	ra,800013b2 <release>
}
    80002070:	70a2                	ld	ra,40(sp)
    80002072:	7402                	ld	s0,32(sp)
    80002074:	64e2                	ld	s1,24(sp)
    80002076:	6942                	ld	s2,16(sp)
    80002078:	69a2                	ld	s3,8(sp)
    8000207a:	6a02                	ld	s4,0(sp)
    8000207c:	6145                	addi	sp,sp,48
    8000207e:	8082                	ret
    for(;;)
    80002080:	a001                	j	80002080 <uartputc+0xa4>

0000000080002082 <uartgetc>:
// read one input character from the UART.
// return -1 if none is waiting.
// 从UART读取一个输入字符
int
uartgetc(void)
{
    80002082:	1141                	addi	sp,sp,-16
    80002084:	e422                	sd	s0,8(sp)
    80002086:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80002088:	100007b7          	lui	a5,0x10000
    8000208c:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80002090:	8b85                	andi	a5,a5,1
    80002092:	cb81                	beqz	a5,800020a2 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80002094:	100007b7          	lui	a5,0x10000
    80002098:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000209c:	6422                	ld	s0,8(sp)
    8000209e:	0141                	addi	sp,sp,16
    800020a0:	8082                	ret
    return -1;
    800020a2:	557d                	li	a0,-1
    800020a4:	bfe5                	j	8000209c <uartgetc+0x1a>

00000000800020a6 <uartintr>:
// arrived, or the uart is ready for more output, or
// both. called from devintr().
// UART中断处理函数
void
uartintr(void)
{
    800020a6:	1101                	addi	sp,sp,-32
    800020a8:	ec06                	sd	ra,24(sp)
    800020aa:	e822                	sd	s0,16(sp)
    800020ac:	e426                	sd	s1,8(sp)
    800020ae:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc(); // 这个就是从UART寄存器读取一个字符
    if(c == -1)
    800020b0:	54fd                	li	s1,-1
    800020b2:	a019                	j	800020b8 <uartintr+0x12>
      break;
    // 这个好像委托到console.c的consoleintr()函数处理
    // 老师的意思好像是直接调用那个同步的putc发送
    // 这里不能使用console.c的文件
    // consoleintr(c); 
    pputc(c); // 直接调用printf.c的pputc函数发送字符
    800020b4:	a40fe0ef          	jal	ra,800002f4 <pputc>
    int c = uartgetc(); // 这个就是从UART寄存器读取一个字符
    800020b8:	fcbff0ef          	jal	ra,80002082 <uartgetc>
    if(c == -1)
    800020bc:	fe951ce3          	bne	a0,s1,800020b4 <uartintr+0xe>

  // send buffered characters.
  // acquire(&uart_tx_lock);
  // uartstart();
  // release(&uart_tx_lock);
}
    800020c0:	60e2                	ld	ra,24(sp)
    800020c2:	6442                	ld	s0,16(sp)
    800020c4:	64a2                	ld	s1,8(sp)
    800020c6:	6105                	addi	sp,sp,32
    800020c8:	8082                	ret

00000000800020ca <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    800020ca:	1141                	addi	sp,sp,-16
    800020cc:	e422                	sd	s0,8(sp)
    800020ce:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800020d0:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  // 应该是将TLB中的内容清空，内核更换的时候应该都要做
  sfence_vma();

  // 将kernel_pagetable的地址写入每个CPU核的satp寄存器中
  w_satp(MAKE_SATP(kernel_pagetable));
    800020d4:	00005797          	auipc	a5,0x5
    800020d8:	a847b783          	ld	a5,-1404(a5) # 80006b58 <kernel_pagetable>
    800020dc:	83b1                	srli	a5,a5,0xc
    800020de:	577d                	li	a4,-1
    800020e0:	177e                	slli	a4,a4,0x3f
    800020e2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800020e4:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    800020e8:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  // 不知道是不是再清空一遍TLB
  sfence_vma();
}
    800020ec:	6422                	ld	s0,8(sp)
    800020ee:	0141                	addi	sp,sp,16
    800020f0:	8082                	ret

00000000800020f2 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800020f2:	7139                	addi	sp,sp,-64
    800020f4:	fc06                	sd	ra,56(sp)
    800020f6:	f822                	sd	s0,48(sp)
    800020f8:	f426                	sd	s1,40(sp)
    800020fa:	f04a                	sd	s2,32(sp)
    800020fc:	ec4e                	sd	s3,24(sp)
    800020fe:	e852                	sd	s4,16(sp)
    80002100:	e456                	sd	s5,8(sp)
    80002102:	e05a                	sd	s6,0(sp)
    80002104:	0080                	addi	s0,sp,64
    80002106:	84aa                	mv	s1,a0
    80002108:	89ae                	mv	s3,a1
    8000210a:	8ab2                	mv	s5,a2
  // 首先检查va是否超出了最大的虚拟地址
  if(va >= MAXVA)
    8000210c:	57fd                	li	a5,-1
    8000210e:	83e9                	srli	a5,a5,0x1a
    80002110:	4a79                	li	s4,30
    panic("walk");
  
  for(int level = 2; level > 0; level--) {
    80002112:	4b31                	li	s6,12
  if(va >= MAXVA)
    80002114:	02b7fc63          	bgeu	a5,a1,8000214c <walk+0x5a>
    panic("walk");
    80002118:	00003517          	auipc	a0,0x3
    8000211c:	53850513          	addi	a0,a0,1336 # 80005650 <syscalls+0x290>
    80002120:	d4cfe0ef          	jal	ra,8000066c <panic>
    //查找以pagetable为基址的页表中，序号为VPN[level]的条目
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) { // 如果这个条目是有效的
      pagetable = (pagetable_t)PTE2PA(*pte);  // 取出这个条目对应的物理页面基址
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0) // 如果是一个无效的条目并且不允许分配就返回了
    80002124:	060a8263          	beqz	s5,80002188 <walk+0x96>
    80002128:	fd7fd0ef          	jal	ra,800000fe <kalloc>
    8000212c:	84aa                	mv	s1,a0
    8000212e:	c139                	beqz	a0,80002174 <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80002130:	6605                	lui	a2,0x1
    80002132:	4581                	li	a1,0
    80002134:	b6eff0ef          	jal	ra,800014a2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V; // 如果允许分配，就将这个条目记录在这个页表中，并设置有效位
    80002138:	00c4d793          	srli	a5,s1,0xc
    8000213c:	07aa                	slli	a5,a5,0xa
    8000213e:	0017e793          	ori	a5,a5,1
    80002142:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80002146:	3a5d                	addiw	s4,s4,-9
    80002148:	036a0063          	beq	s4,s6,80002168 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    8000214c:	0149d933          	srl	s2,s3,s4
    80002150:	1ff97913          	andi	s2,s2,511
    80002154:	090e                	slli	s2,s2,0x3
    80002156:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) { // 如果这个条目是有效的
    80002158:	00093483          	ld	s1,0(s2)
    8000215c:	0014f793          	andi	a5,s1,1
    80002160:	d3f1                	beqz	a5,80002124 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);  // 取出这个条目对应的物理页面基址
    80002162:	80a9                	srli	s1,s1,0xa
    80002164:	04b2                	slli	s1,s1,0xc
    80002166:	b7c5                	j	80002146 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];  // 返回三级页表中序号为VPN[0]的条目地址
    80002168:	00c9d513          	srli	a0,s3,0xc
    8000216c:	1ff57513          	andi	a0,a0,511
    80002170:	050e                	slli	a0,a0,0x3
    80002172:	9526                	add	a0,a0,s1
}
    80002174:	70e2                	ld	ra,56(sp)
    80002176:	7442                	ld	s0,48(sp)
    80002178:	74a2                	ld	s1,40(sp)
    8000217a:	7902                	ld	s2,32(sp)
    8000217c:	69e2                	ld	s3,24(sp)
    8000217e:	6a42                	ld	s4,16(sp)
    80002180:	6aa2                	ld	s5,8(sp)
    80002182:	6b02                	ld	s6,0(sp)
    80002184:	6121                	addi	sp,sp,64
    80002186:	8082                	ret
        return 0;
    80002188:	4501                	li	a0,0
    8000218a:	b7ed                	j	80002174 <walk+0x82>

000000008000218c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000218c:	57fd                	li	a5,-1
    8000218e:	83e9                	srli	a5,a5,0x1a
    80002190:	00b7f463          	bgeu	a5,a1,80002198 <walkaddr+0xc>
    return 0;
    80002194:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80002196:	8082                	ret
{
    80002198:	1141                	addi	sp,sp,-16
    8000219a:	e406                	sd	ra,8(sp)
    8000219c:	e022                	sd	s0,0(sp)
    8000219e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800021a0:	4601                	li	a2,0
    800021a2:	f51ff0ef          	jal	ra,800020f2 <walk>
  if(pte == 0)
    800021a6:	c105                	beqz	a0,800021c6 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    800021a8:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800021aa:	0117f693          	andi	a3,a5,17
    800021ae:	4745                	li	a4,17
    return 0;
    800021b0:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800021b2:	00e68663          	beq	a3,a4,800021be <walkaddr+0x32>
}
    800021b6:	60a2                	ld	ra,8(sp)
    800021b8:	6402                	ld	s0,0(sp)
    800021ba:	0141                	addi	sp,sp,16
    800021bc:	8082                	ret
  pa = PTE2PA(*pte);
    800021be:	83a9                	srli	a5,a5,0xa
    800021c0:	00c79513          	slli	a0,a5,0xc
  return pa;
    800021c4:	bfcd                	j	800021b6 <walkaddr+0x2a>
    return 0;
    800021c6:	4501                	li	a0,0
    800021c8:	b7fd                	j	800021b6 <walkaddr+0x2a>

00000000800021ca <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800021ca:	715d                	addi	sp,sp,-80
    800021cc:	e486                	sd	ra,72(sp)
    800021ce:	e0a2                	sd	s0,64(sp)
    800021d0:	fc26                	sd	s1,56(sp)
    800021d2:	f84a                	sd	s2,48(sp)
    800021d4:	f44e                	sd	s3,40(sp)
    800021d6:	f052                	sd	s4,32(sp)
    800021d8:	ec56                	sd	s5,24(sp)
    800021da:	e85a                	sd	s6,16(sp)
    800021dc:	e45e                	sd	s7,8(sp)
    800021de:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800021e0:	03459793          	slli	a5,a1,0x34
    800021e4:	e7a9                	bnez	a5,8000222e <mappages+0x64>
    800021e6:	8aaa                	mv	s5,a0
    800021e8:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    800021ea:	03461793          	slli	a5,a2,0x34
    800021ee:	e7b1                	bnez	a5,8000223a <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    800021f0:	ca39                	beqz	a2,80002246 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    800021f2:	77fd                	lui	a5,0xfffff
    800021f4:	963e                	add	a2,a2,a5
    800021f6:	00b609b3          	add	s3,a2,a1
  a = va;
    800021fa:	892e                	mv	s2,a1
    800021fc:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V; // 将内容填写到表项上面去pte-> ppn-perm 物理地址前面部分-标志位
    if(a == last)
      break;
    a += PGSIZE;
    80002200:	6b85                	lui	s7,0x1
    80002202:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80002206:	4605                	li	a2,1
    80002208:	85ca                	mv	a1,s2
    8000220a:	8556                	mv	a0,s5
    8000220c:	ee7ff0ef          	jal	ra,800020f2 <walk>
    80002210:	c539                	beqz	a0,8000225e <mappages+0x94>
    if(*pte & PTE_V)
    80002212:	611c                	ld	a5,0(a0)
    80002214:	8b85                	andi	a5,a5,1
    80002216:	ef95                	bnez	a5,80002252 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V; // 将内容填写到表项上面去pte-> ppn-perm 物理地址前面部分-标志位
    80002218:	80b1                	srli	s1,s1,0xc
    8000221a:	04aa                	slli	s1,s1,0xa
    8000221c:	0164e4b3          	or	s1,s1,s6
    80002220:	0014e493          	ori	s1,s1,1
    80002224:	e104                	sd	s1,0(a0)
    if(a == last)
    80002226:	05390863          	beq	s2,s3,80002276 <mappages+0xac>
    a += PGSIZE;
    8000222a:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    8000222c:	bfd9                	j	80002202 <mappages+0x38>
    panic("mappages: va not aligned");
    8000222e:	00003517          	auipc	a0,0x3
    80002232:	42a50513          	addi	a0,a0,1066 # 80005658 <syscalls+0x298>
    80002236:	c36fe0ef          	jal	ra,8000066c <panic>
    panic("mappages: size not aligned");
    8000223a:	00003517          	auipc	a0,0x3
    8000223e:	43e50513          	addi	a0,a0,1086 # 80005678 <syscalls+0x2b8>
    80002242:	c2afe0ef          	jal	ra,8000066c <panic>
    panic("mappages: size");
    80002246:	00003517          	auipc	a0,0x3
    8000224a:	45250513          	addi	a0,a0,1106 # 80005698 <syscalls+0x2d8>
    8000224e:	c1efe0ef          	jal	ra,8000066c <panic>
      panic("mappages: remap");
    80002252:	00003517          	auipc	a0,0x3
    80002256:	45650513          	addi	a0,a0,1110 # 800056a8 <syscalls+0x2e8>
    8000225a:	c12fe0ef          	jal	ra,8000066c <panic>
      return -1;
    8000225e:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80002260:	60a6                	ld	ra,72(sp)
    80002262:	6406                	ld	s0,64(sp)
    80002264:	74e2                	ld	s1,56(sp)
    80002266:	7942                	ld	s2,48(sp)
    80002268:	79a2                	ld	s3,40(sp)
    8000226a:	7a02                	ld	s4,32(sp)
    8000226c:	6ae2                	ld	s5,24(sp)
    8000226e:	6b42                	ld	s6,16(sp)
    80002270:	6ba2                	ld	s7,8(sp)
    80002272:	6161                	addi	sp,sp,80
    80002274:	8082                	ret
  return 0;
    80002276:	4501                	li	a0,0
    80002278:	b7e5                	j	80002260 <mappages+0x96>

000000008000227a <kvmmap>:
{
    8000227a:	1141                	addi	sp,sp,-16
    8000227c:	e406                	sd	ra,8(sp)
    8000227e:	e022                	sd	s0,0(sp)
    80002280:	0800                	addi	s0,sp,16
    80002282:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80002284:	86b2                	mv	a3,a2
    80002286:	863e                	mv	a2,a5
    80002288:	f43ff0ef          	jal	ra,800021ca <mappages>
    8000228c:	e509                	bnez	a0,80002296 <kvmmap+0x1c>
}
    8000228e:	60a2                	ld	ra,8(sp)
    80002290:	6402                	ld	s0,0(sp)
    80002292:	0141                	addi	sp,sp,16
    80002294:	8082                	ret
    panic("kvmmap");
    80002296:	00003517          	auipc	a0,0x3
    8000229a:	42250513          	addi	a0,a0,1058 # 800056b8 <syscalls+0x2f8>
    8000229e:	bcefe0ef          	jal	ra,8000066c <panic>

00000000800022a2 <kvmmake>:
{
    800022a2:	1101                	addi	sp,sp,-32
    800022a4:	ec06                	sd	ra,24(sp)
    800022a6:	e822                	sd	s0,16(sp)
    800022a8:	e426                	sd	s1,8(sp)
    800022aa:	e04a                	sd	s2,0(sp)
    800022ac:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800022ae:	e51fd0ef          	jal	ra,800000fe <kalloc>
    800022b2:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800022b4:	6605                	lui	a2,0x1
    800022b6:	4581                	li	a1,0
    800022b8:	9eaff0ef          	jal	ra,800014a2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800022bc:	4719                	li	a4,6
    800022be:	6685                	lui	a3,0x1
    800022c0:	10000637          	lui	a2,0x10000
    800022c4:	100005b7          	lui	a1,0x10000
    800022c8:	8526                	mv	a0,s1
    800022ca:	fb1ff0ef          	jal	ra,8000227a <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800022ce:	4719                	li	a4,6
    800022d0:	6685                	lui	a3,0x1
    800022d2:	10001637          	lui	a2,0x10001
    800022d6:	100015b7          	lui	a1,0x10001
    800022da:	8526                	mv	a0,s1
    800022dc:	f9fff0ef          	jal	ra,8000227a <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800022e0:	4719                	li	a4,6
    800022e2:	040006b7          	lui	a3,0x4000
    800022e6:	0c000637          	lui	a2,0xc000
    800022ea:	0c0005b7          	lui	a1,0xc000
    800022ee:	8526                	mv	a0,s1
    800022f0:	f8bff0ef          	jal	ra,8000227a <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800022f4:	00003917          	auipc	s2,0x3
    800022f8:	d0c90913          	addi	s2,s2,-756 # 80005000 <etext>
    800022fc:	4729                	li	a4,10
    800022fe:	80003697          	auipc	a3,0x80003
    80002302:	d0268693          	addi	a3,a3,-766 # 5000 <_entry-0x7fffb000>
    80002306:	4605                	li	a2,1
    80002308:	067e                	slli	a2,a2,0x1f
    8000230a:	85b2                	mv	a1,a2
    8000230c:	8526                	mv	a0,s1
    8000230e:	f6dff0ef          	jal	ra,8000227a <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80002312:	4719                	li	a4,6
    80002314:	46c5                	li	a3,17
    80002316:	06ee                	slli	a3,a3,0x1b
    80002318:	412686b3          	sub	a3,a3,s2
    8000231c:	864a                	mv	a2,s2
    8000231e:	85ca                	mv	a1,s2
    80002320:	8526                	mv	a0,s1
    80002322:	f59ff0ef          	jal	ra,8000227a <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80002326:	4729                	li	a4,10
    80002328:	6685                	lui	a3,0x1
    8000232a:	00002617          	auipc	a2,0x2
    8000232e:	cd660613          	addi	a2,a2,-810 # 80004000 <_trampoline>
    80002332:	040005b7          	lui	a1,0x4000
    80002336:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80002338:	05b2                	slli	a1,a1,0xc
    8000233a:	8526                	mv	a0,s1
    8000233c:	f3fff0ef          	jal	ra,8000227a <kvmmap>
  proc_mapstacks(kpgtbl);
    80002340:	8526                	mv	a0,s1
    80002342:	b92fe0ef          	jal	ra,800006d4 <proc_mapstacks>
}
    80002346:	8526                	mv	a0,s1
    80002348:	60e2                	ld	ra,24(sp)
    8000234a:	6442                	ld	s0,16(sp)
    8000234c:	64a2                	ld	s1,8(sp)
    8000234e:	6902                	ld	s2,0(sp)
    80002350:	6105                	addi	sp,sp,32
    80002352:	8082                	ret

0000000080002354 <kvminit>:
{
    80002354:	1141                	addi	sp,sp,-16
    80002356:	e406                	sd	ra,8(sp)
    80002358:	e022                	sd	s0,0(sp)
    8000235a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000235c:	f47ff0ef          	jal	ra,800022a2 <kvmmake>
    80002360:	00004797          	auipc	a5,0x4
    80002364:	7ea7bc23          	sd	a0,2040(a5) # 80006b58 <kernel_pagetable>
}
    80002368:	60a2                	ld	ra,8(sp)
    8000236a:	6402                	ld	s0,0(sp)
    8000236c:	0141                	addi	sp,sp,16
    8000236e:	8082                	ret

0000000080002370 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80002370:	715d                	addi	sp,sp,-80
    80002372:	e486                	sd	ra,72(sp)
    80002374:	e0a2                	sd	s0,64(sp)
    80002376:	fc26                	sd	s1,56(sp)
    80002378:	f84a                	sd	s2,48(sp)
    8000237a:	f44e                	sd	s3,40(sp)
    8000237c:	f052                	sd	s4,32(sp)
    8000237e:	ec56                	sd	s5,24(sp)
    80002380:	e85a                	sd	s6,16(sp)
    80002382:	e45e                	sd	s7,8(sp)
    80002384:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80002386:	03459793          	slli	a5,a1,0x34
    8000238a:	e795                	bnez	a5,800023b6 <uvmunmap+0x46>
    8000238c:	8a2a                	mv	s4,a0
    8000238e:	892e                	mv	s2,a1
    80002390:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80002392:	0632                	slli	a2,a2,0xc
    80002394:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80002398:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000239a:	6b05                	lui	s6,0x1
    8000239c:	0535ea63          	bltu	a1,s3,800023f0 <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800023a0:	60a6                	ld	ra,72(sp)
    800023a2:	6406                	ld	s0,64(sp)
    800023a4:	74e2                	ld	s1,56(sp)
    800023a6:	7942                	ld	s2,48(sp)
    800023a8:	79a2                	ld	s3,40(sp)
    800023aa:	7a02                	ld	s4,32(sp)
    800023ac:	6ae2                	ld	s5,24(sp)
    800023ae:	6b42                	ld	s6,16(sp)
    800023b0:	6ba2                	ld	s7,8(sp)
    800023b2:	6161                	addi	sp,sp,80
    800023b4:	8082                	ret
    panic("uvmunmap: not aligned");
    800023b6:	00003517          	auipc	a0,0x3
    800023ba:	30a50513          	addi	a0,a0,778 # 800056c0 <syscalls+0x300>
    800023be:	aaefe0ef          	jal	ra,8000066c <panic>
      panic("uvmunmap: walk");
    800023c2:	00003517          	auipc	a0,0x3
    800023c6:	31650513          	addi	a0,a0,790 # 800056d8 <syscalls+0x318>
    800023ca:	aa2fe0ef          	jal	ra,8000066c <panic>
      panic("uvmunmap: not mapped");
    800023ce:	00003517          	auipc	a0,0x3
    800023d2:	31a50513          	addi	a0,a0,794 # 800056e8 <syscalls+0x328>
    800023d6:	a96fe0ef          	jal	ra,8000066c <panic>
      panic("uvmunmap: not a leaf");
    800023da:	00003517          	auipc	a0,0x3
    800023de:	32650513          	addi	a0,a0,806 # 80005700 <syscalls+0x340>
    800023e2:	a8afe0ef          	jal	ra,8000066c <panic>
    *pte = 0;
    800023e6:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800023ea:	995a                	add	s2,s2,s6
    800023ec:	fb397ae3          	bgeu	s2,s3,800023a0 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800023f0:	4601                	li	a2,0
    800023f2:	85ca                	mv	a1,s2
    800023f4:	8552                	mv	a0,s4
    800023f6:	cfdff0ef          	jal	ra,800020f2 <walk>
    800023fa:	84aa                	mv	s1,a0
    800023fc:	d179                	beqz	a0,800023c2 <uvmunmap+0x52>
    if((*pte & PTE_V) == 0)
    800023fe:	6108                	ld	a0,0(a0)
    80002400:	00157793          	andi	a5,a0,1
    80002404:	d7e9                	beqz	a5,800023ce <uvmunmap+0x5e>
    if(PTE_FLAGS(*pte) == PTE_V)
    80002406:	3ff57793          	andi	a5,a0,1023
    8000240a:	fd7788e3          	beq	a5,s7,800023da <uvmunmap+0x6a>
    if(do_free){
    8000240e:	fc0a8ce3          	beqz	s5,800023e6 <uvmunmap+0x76>
      uint64 pa = PTE2PA(*pte);
    80002412:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80002414:	0532                	slli	a0,a0,0xc
    80002416:	c07fd0ef          	jal	ra,8000001c <kfree>
    8000241a:	b7f1                	j	800023e6 <uvmunmap+0x76>

000000008000241c <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000241c:	1101                	addi	sp,sp,-32
    8000241e:	ec06                	sd	ra,24(sp)
    80002420:	e822                	sd	s0,16(sp)
    80002422:	e426                	sd	s1,8(sp)
    80002424:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80002426:	cd9fd0ef          	jal	ra,800000fe <kalloc>
    8000242a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000242c:	c509                	beqz	a0,80002436 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000242e:	6605                	lui	a2,0x1
    80002430:	4581                	li	a1,0
    80002432:	870ff0ef          	jal	ra,800014a2 <memset>
  return pagetable;
}
    80002436:	8526                	mv	a0,s1
    80002438:	60e2                	ld	ra,24(sp)
    8000243a:	6442                	ld	s0,16(sp)
    8000243c:	64a2                	ld	s1,8(sp)
    8000243e:	6105                	addi	sp,sp,32
    80002440:	8082                	ret

0000000080002442 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80002442:	7179                	addi	sp,sp,-48
    80002444:	f406                	sd	ra,40(sp)
    80002446:	f022                	sd	s0,32(sp)
    80002448:	ec26                	sd	s1,24(sp)
    8000244a:	e84a                	sd	s2,16(sp)
    8000244c:	e44e                	sd	s3,8(sp)
    8000244e:	e052                	sd	s4,0(sp)
    80002450:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80002452:	6785                	lui	a5,0x1
    80002454:	04f67063          	bgeu	a2,a5,80002494 <uvmfirst+0x52>
    80002458:	8a2a                	mv	s4,a0
    8000245a:	89ae                	mv	s3,a1
    8000245c:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000245e:	ca1fd0ef          	jal	ra,800000fe <kalloc>
    80002462:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80002464:	6605                	lui	a2,0x1
    80002466:	4581                	li	a1,0
    80002468:	83aff0ef          	jal	ra,800014a2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000246c:	4779                	li	a4,30
    8000246e:	86ca                	mv	a3,s2
    80002470:	6605                	lui	a2,0x1
    80002472:	4581                	li	a1,0
    80002474:	8552                	mv	a0,s4
    80002476:	d55ff0ef          	jal	ra,800021ca <mappages>
  memmove(mem, src, sz);
    8000247a:	8626                	mv	a2,s1
    8000247c:	85ce                	mv	a1,s3
    8000247e:	854a                	mv	a0,s2
    80002480:	87eff0ef          	jal	ra,800014fe <memmove>
}
    80002484:	70a2                	ld	ra,40(sp)
    80002486:	7402                	ld	s0,32(sp)
    80002488:	64e2                	ld	s1,24(sp)
    8000248a:	6942                	ld	s2,16(sp)
    8000248c:	69a2                	ld	s3,8(sp)
    8000248e:	6a02                	ld	s4,0(sp)
    80002490:	6145                	addi	sp,sp,48
    80002492:	8082                	ret
    panic("uvmfirst: more than a page");
    80002494:	00003517          	auipc	a0,0x3
    80002498:	28450513          	addi	a0,a0,644 # 80005718 <syscalls+0x358>
    8000249c:	9d0fe0ef          	jal	ra,8000066c <panic>

00000000800024a0 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800024a0:	1101                	addi	sp,sp,-32
    800024a2:	ec06                	sd	ra,24(sp)
    800024a4:	e822                	sd	s0,16(sp)
    800024a6:	e426                	sd	s1,8(sp)
    800024a8:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800024aa:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800024ac:	00b67d63          	bgeu	a2,a1,800024c6 <uvmdealloc+0x26>
    800024b0:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800024b2:	6785                	lui	a5,0x1
    800024b4:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800024b6:	00f60733          	add	a4,a2,a5
    800024ba:	76fd                	lui	a3,0xfffff
    800024bc:	8f75                	and	a4,a4,a3
    800024be:	97ae                	add	a5,a5,a1
    800024c0:	8ff5                	and	a5,a5,a3
    800024c2:	00f76863          	bltu	a4,a5,800024d2 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800024c6:	8526                	mv	a0,s1
    800024c8:	60e2                	ld	ra,24(sp)
    800024ca:	6442                	ld	s0,16(sp)
    800024cc:	64a2                	ld	s1,8(sp)
    800024ce:	6105                	addi	sp,sp,32
    800024d0:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800024d2:	8f99                	sub	a5,a5,a4
    800024d4:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800024d6:	4685                	li	a3,1
    800024d8:	0007861b          	sext.w	a2,a5
    800024dc:	85ba                	mv	a1,a4
    800024de:	e93ff0ef          	jal	ra,80002370 <uvmunmap>
    800024e2:	b7d5                	j	800024c6 <uvmdealloc+0x26>

00000000800024e4 <uvmalloc>:
  if(newsz < oldsz)
    800024e4:	08b66963          	bltu	a2,a1,80002576 <uvmalloc+0x92>
{
    800024e8:	7139                	addi	sp,sp,-64
    800024ea:	fc06                	sd	ra,56(sp)
    800024ec:	f822                	sd	s0,48(sp)
    800024ee:	f426                	sd	s1,40(sp)
    800024f0:	f04a                	sd	s2,32(sp)
    800024f2:	ec4e                	sd	s3,24(sp)
    800024f4:	e852                	sd	s4,16(sp)
    800024f6:	e456                	sd	s5,8(sp)
    800024f8:	e05a                	sd	s6,0(sp)
    800024fa:	0080                	addi	s0,sp,64
    800024fc:	8aaa                	mv	s5,a0
    800024fe:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80002500:	6785                	lui	a5,0x1
    80002502:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80002504:	95be                	add	a1,a1,a5
    80002506:	77fd                	lui	a5,0xfffff
    80002508:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000250c:	06c9f763          	bgeu	s3,a2,8000257a <uvmalloc+0x96>
    80002510:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80002512:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80002516:	be9fd0ef          	jal	ra,800000fe <kalloc>
    8000251a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000251c:	c11d                	beqz	a0,80002542 <uvmalloc+0x5e>
    memset(mem, 0, PGSIZE);
    8000251e:	6605                	lui	a2,0x1
    80002520:	4581                	li	a1,0
    80002522:	f81fe0ef          	jal	ra,800014a2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80002526:	875a                	mv	a4,s6
    80002528:	86a6                	mv	a3,s1
    8000252a:	6605                	lui	a2,0x1
    8000252c:	85ca                	mv	a1,s2
    8000252e:	8556                	mv	a0,s5
    80002530:	c9bff0ef          	jal	ra,800021ca <mappages>
    80002534:	e51d                	bnez	a0,80002562 <uvmalloc+0x7e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80002536:	6785                	lui	a5,0x1
    80002538:	993e                	add	s2,s2,a5
    8000253a:	fd496ee3          	bltu	s2,s4,80002516 <uvmalloc+0x32>
  return newsz;
    8000253e:	8552                	mv	a0,s4
    80002540:	a039                	j	8000254e <uvmalloc+0x6a>
      uvmdealloc(pagetable, a, oldsz);
    80002542:	864e                	mv	a2,s3
    80002544:	85ca                	mv	a1,s2
    80002546:	8556                	mv	a0,s5
    80002548:	f59ff0ef          	jal	ra,800024a0 <uvmdealloc>
      return 0;
    8000254c:	4501                	li	a0,0
}
    8000254e:	70e2                	ld	ra,56(sp)
    80002550:	7442                	ld	s0,48(sp)
    80002552:	74a2                	ld	s1,40(sp)
    80002554:	7902                	ld	s2,32(sp)
    80002556:	69e2                	ld	s3,24(sp)
    80002558:	6a42                	ld	s4,16(sp)
    8000255a:	6aa2                	ld	s5,8(sp)
    8000255c:	6b02                	ld	s6,0(sp)
    8000255e:	6121                	addi	sp,sp,64
    80002560:	8082                	ret
      kfree(mem);
    80002562:	8526                	mv	a0,s1
    80002564:	ab9fd0ef          	jal	ra,8000001c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80002568:	864e                	mv	a2,s3
    8000256a:	85ca                	mv	a1,s2
    8000256c:	8556                	mv	a0,s5
    8000256e:	f33ff0ef          	jal	ra,800024a0 <uvmdealloc>
      return 0;
    80002572:	4501                	li	a0,0
    80002574:	bfe9                	j	8000254e <uvmalloc+0x6a>
    return oldsz;
    80002576:	852e                	mv	a0,a1
}
    80002578:	8082                	ret
  return newsz;
    8000257a:	8532                	mv	a0,a2
    8000257c:	bfc9                	j	8000254e <uvmalloc+0x6a>

000000008000257e <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000257e:	7179                	addi	sp,sp,-48
    80002580:	f406                	sd	ra,40(sp)
    80002582:	f022                	sd	s0,32(sp)
    80002584:	ec26                	sd	s1,24(sp)
    80002586:	e84a                	sd	s2,16(sp)
    80002588:	e44e                	sd	s3,8(sp)
    8000258a:	e052                	sd	s4,0(sp)
    8000258c:	1800                	addi	s0,sp,48
    8000258e:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80002590:	84aa                	mv	s1,a0
    80002592:	6905                	lui	s2,0x1
    80002594:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80002596:	4985                	li	s3,1
    80002598:	a819                	j	800025ae <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000259a:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000259c:	00c79513          	slli	a0,a5,0xc
    800025a0:	fdfff0ef          	jal	ra,8000257e <freewalk>
      pagetable[i] = 0;
    800025a4:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800025a8:	04a1                	addi	s1,s1,8
    800025aa:	01248f63          	beq	s1,s2,800025c8 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    800025ae:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800025b0:	00f7f713          	andi	a4,a5,15
    800025b4:	ff3703e3          	beq	a4,s3,8000259a <freewalk+0x1c>
    } else if(pte & PTE_V){
    800025b8:	8b85                	andi	a5,a5,1
    800025ba:	d7fd                	beqz	a5,800025a8 <freewalk+0x2a>
      panic("freewalk: leaf");
    800025bc:	00003517          	auipc	a0,0x3
    800025c0:	17c50513          	addi	a0,a0,380 # 80005738 <syscalls+0x378>
    800025c4:	8a8fe0ef          	jal	ra,8000066c <panic>
    }
  }
  kfree((void*)pagetable);
    800025c8:	8552                	mv	a0,s4
    800025ca:	a53fd0ef          	jal	ra,8000001c <kfree>
}
    800025ce:	70a2                	ld	ra,40(sp)
    800025d0:	7402                	ld	s0,32(sp)
    800025d2:	64e2                	ld	s1,24(sp)
    800025d4:	6942                	ld	s2,16(sp)
    800025d6:	69a2                	ld	s3,8(sp)
    800025d8:	6a02                	ld	s4,0(sp)
    800025da:	6145                	addi	sp,sp,48
    800025dc:	8082                	ret

00000000800025de <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800025de:	1101                	addi	sp,sp,-32
    800025e0:	ec06                	sd	ra,24(sp)
    800025e2:	e822                	sd	s0,16(sp)
    800025e4:	e426                	sd	s1,8(sp)
    800025e6:	1000                	addi	s0,sp,32
    800025e8:	84aa                	mv	s1,a0
  if(sz > 0)
    800025ea:	e989                	bnez	a1,800025fc <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800025ec:	8526                	mv	a0,s1
    800025ee:	f91ff0ef          	jal	ra,8000257e <freewalk>
}
    800025f2:	60e2                	ld	ra,24(sp)
    800025f4:	6442                	ld	s0,16(sp)
    800025f6:	64a2                	ld	s1,8(sp)
    800025f8:	6105                	addi	sp,sp,32
    800025fa:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800025fc:	6785                	lui	a5,0x1
    800025fe:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80002600:	95be                	add	a1,a1,a5
    80002602:	4685                	li	a3,1
    80002604:	00c5d613          	srli	a2,a1,0xc
    80002608:	4581                	li	a1,0
    8000260a:	d67ff0ef          	jal	ra,80002370 <uvmunmap>
    8000260e:	bff9                	j	800025ec <uvmfree+0xe>

0000000080002610 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80002610:	c65d                	beqz	a2,800026be <uvmcopy+0xae>
{
    80002612:	715d                	addi	sp,sp,-80
    80002614:	e486                	sd	ra,72(sp)
    80002616:	e0a2                	sd	s0,64(sp)
    80002618:	fc26                	sd	s1,56(sp)
    8000261a:	f84a                	sd	s2,48(sp)
    8000261c:	f44e                	sd	s3,40(sp)
    8000261e:	f052                	sd	s4,32(sp)
    80002620:	ec56                	sd	s5,24(sp)
    80002622:	e85a                	sd	s6,16(sp)
    80002624:	e45e                	sd	s7,8(sp)
    80002626:	0880                	addi	s0,sp,80
    80002628:	8b2a                	mv	s6,a0
    8000262a:	8aae                	mv	s5,a1
    8000262c:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000262e:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80002630:	4601                	li	a2,0
    80002632:	85ce                	mv	a1,s3
    80002634:	855a                	mv	a0,s6
    80002636:	abdff0ef          	jal	ra,800020f2 <walk>
    8000263a:	c121                	beqz	a0,8000267a <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000263c:	6118                	ld	a4,0(a0)
    8000263e:	00177793          	andi	a5,a4,1
    80002642:	c3b1                	beqz	a5,80002686 <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80002644:	00a75593          	srli	a1,a4,0xa
    80002648:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000264c:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80002650:	aaffd0ef          	jal	ra,800000fe <kalloc>
    80002654:	892a                	mv	s2,a0
    80002656:	c129                	beqz	a0,80002698 <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80002658:	6605                	lui	a2,0x1
    8000265a:	85de                	mv	a1,s7
    8000265c:	ea3fe0ef          	jal	ra,800014fe <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80002660:	8726                	mv	a4,s1
    80002662:	86ca                	mv	a3,s2
    80002664:	6605                	lui	a2,0x1
    80002666:	85ce                	mv	a1,s3
    80002668:	8556                	mv	a0,s5
    8000266a:	b61ff0ef          	jal	ra,800021ca <mappages>
    8000266e:	e115                	bnez	a0,80002692 <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    80002670:	6785                	lui	a5,0x1
    80002672:	99be                	add	s3,s3,a5
    80002674:	fb49eee3          	bltu	s3,s4,80002630 <uvmcopy+0x20>
    80002678:	a805                	j	800026a8 <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    8000267a:	00003517          	auipc	a0,0x3
    8000267e:	0ce50513          	addi	a0,a0,206 # 80005748 <syscalls+0x388>
    80002682:	febfd0ef          	jal	ra,8000066c <panic>
      panic("uvmcopy: page not present");
    80002686:	00003517          	auipc	a0,0x3
    8000268a:	0e250513          	addi	a0,a0,226 # 80005768 <syscalls+0x3a8>
    8000268e:	fdffd0ef          	jal	ra,8000066c <panic>
      kfree(mem);
    80002692:	854a                	mv	a0,s2
    80002694:	989fd0ef          	jal	ra,8000001c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80002698:	4685                	li	a3,1
    8000269a:	00c9d613          	srli	a2,s3,0xc
    8000269e:	4581                	li	a1,0
    800026a0:	8556                	mv	a0,s5
    800026a2:	ccfff0ef          	jal	ra,80002370 <uvmunmap>
  return -1;
    800026a6:	557d                	li	a0,-1
}
    800026a8:	60a6                	ld	ra,72(sp)
    800026aa:	6406                	ld	s0,64(sp)
    800026ac:	74e2                	ld	s1,56(sp)
    800026ae:	7942                	ld	s2,48(sp)
    800026b0:	79a2                	ld	s3,40(sp)
    800026b2:	7a02                	ld	s4,32(sp)
    800026b4:	6ae2                	ld	s5,24(sp)
    800026b6:	6b42                	ld	s6,16(sp)
    800026b8:	6ba2                	ld	s7,8(sp)
    800026ba:	6161                	addi	sp,sp,80
    800026bc:	8082                	ret
  return 0;
    800026be:	4501                	li	a0,0
}
    800026c0:	8082                	ret

00000000800026c2 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    800026c2:	c6c9                	beqz	a3,8000274c <copyout+0x8a>
{
    800026c4:	711d                	addi	sp,sp,-96
    800026c6:	ec86                	sd	ra,88(sp)
    800026c8:	e8a2                	sd	s0,80(sp)
    800026ca:	e4a6                	sd	s1,72(sp)
    800026cc:	e0ca                	sd	s2,64(sp)
    800026ce:	fc4e                	sd	s3,56(sp)
    800026d0:	f852                	sd	s4,48(sp)
    800026d2:	f456                	sd	s5,40(sp)
    800026d4:	f05a                	sd	s6,32(sp)
    800026d6:	ec5e                	sd	s7,24(sp)
    800026d8:	e862                	sd	s8,16(sp)
    800026da:	e466                	sd	s9,8(sp)
    800026dc:	e06a                	sd	s10,0(sp)
    800026de:	1080                	addi	s0,sp,96
    800026e0:	8baa                	mv	s7,a0
    800026e2:	8aae                	mv	s5,a1
    800026e4:	8b32                	mv	s6,a2
    800026e6:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800026e8:	74fd                	lui	s1,0xfffff
    800026ea:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    800026ec:	57fd                	li	a5,-1
    800026ee:	83e9                	srli	a5,a5,0x1a
    800026f0:	0697e063          	bltu	a5,s1,80002750 <copyout+0x8e>
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800026f4:	4cd5                	li	s9,21
    800026f6:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    800026f8:	8c3e                	mv	s8,a5
    800026fa:	a025                	j	80002722 <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    800026fc:	83a9                	srli	a5,a5,0xa
    800026fe:	07b2                	slli	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80002700:	409a8533          	sub	a0,s5,s1
    80002704:	0009061b          	sext.w	a2,s2
    80002708:	85da                	mv	a1,s6
    8000270a:	953e                	add	a0,a0,a5
    8000270c:	df3fe0ef          	jal	ra,800014fe <memmove>

    len -= n;
    80002710:	412989b3          	sub	s3,s3,s2
    src += n;
    80002714:	9b4a                	add	s6,s6,s2
  while(len > 0){
    80002716:	02098963          	beqz	s3,80002748 <copyout+0x86>
    if(va0 >= MAXVA)
    8000271a:	034c6d63          	bltu	s8,s4,80002754 <copyout+0x92>
    va0 = PGROUNDDOWN(dstva);
    8000271e:	84d2                	mv	s1,s4
    dstva = va0 + PGSIZE;
    80002720:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    80002722:	4601                	li	a2,0
    80002724:	85a6                	mv	a1,s1
    80002726:	855e                	mv	a0,s7
    80002728:	9cbff0ef          	jal	ra,800020f2 <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    8000272c:	c515                	beqz	a0,80002758 <copyout+0x96>
    8000272e:	611c                	ld	a5,0(a0)
    80002730:	0157f713          	andi	a4,a5,21
    80002734:	05971163          	bne	a4,s9,80002776 <copyout+0xb4>
    n = PGSIZE - (dstva - va0);
    80002738:	01a48a33          	add	s4,s1,s10
    8000273c:	415a0933          	sub	s2,s4,s5
    80002740:	fb29fee3          	bgeu	s3,s2,800026fc <copyout+0x3a>
    80002744:	894e                	mv	s2,s3
    80002746:	bf5d                	j	800026fc <copyout+0x3a>
  }
  return 0;
    80002748:	4501                	li	a0,0
    8000274a:	a801                	j	8000275a <copyout+0x98>
    8000274c:	4501                	li	a0,0
}
    8000274e:	8082                	ret
      return -1;
    80002750:	557d                	li	a0,-1
    80002752:	a021                	j	8000275a <copyout+0x98>
    80002754:	557d                	li	a0,-1
    80002756:	a011                	j	8000275a <copyout+0x98>
      return -1;
    80002758:	557d                	li	a0,-1
}
    8000275a:	60e6                	ld	ra,88(sp)
    8000275c:	6446                	ld	s0,80(sp)
    8000275e:	64a6                	ld	s1,72(sp)
    80002760:	6906                	ld	s2,64(sp)
    80002762:	79e2                	ld	s3,56(sp)
    80002764:	7a42                	ld	s4,48(sp)
    80002766:	7aa2                	ld	s5,40(sp)
    80002768:	7b02                	ld	s6,32(sp)
    8000276a:	6be2                	ld	s7,24(sp)
    8000276c:	6c42                	ld	s8,16(sp)
    8000276e:	6ca2                	ld	s9,8(sp)
    80002770:	6d02                	ld	s10,0(sp)
    80002772:	6125                	addi	sp,sp,96
    80002774:	8082                	ret
      return -1;
    80002776:	557d                	li	a0,-1
    80002778:	b7cd                	j	8000275a <copyout+0x98>

000000008000277a <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000277a:	c6a5                	beqz	a3,800027e2 <copyin+0x68>
{
    8000277c:	715d                	addi	sp,sp,-80
    8000277e:	e486                	sd	ra,72(sp)
    80002780:	e0a2                	sd	s0,64(sp)
    80002782:	fc26                	sd	s1,56(sp)
    80002784:	f84a                	sd	s2,48(sp)
    80002786:	f44e                	sd	s3,40(sp)
    80002788:	f052                	sd	s4,32(sp)
    8000278a:	ec56                	sd	s5,24(sp)
    8000278c:	e85a                	sd	s6,16(sp)
    8000278e:	e45e                	sd	s7,8(sp)
    80002790:	e062                	sd	s8,0(sp)
    80002792:	0880                	addi	s0,sp,80
    80002794:	8b2a                	mv	s6,a0
    80002796:	8a2e                	mv	s4,a1
    80002798:	8c32                	mv	s8,a2
    8000279a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000279c:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000279e:	6a85                	lui	s5,0x1
    800027a0:	a00d                	j	800027c2 <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800027a2:	018505b3          	add	a1,a0,s8
    800027a6:	0004861b          	sext.w	a2,s1
    800027aa:	412585b3          	sub	a1,a1,s2
    800027ae:	8552                	mv	a0,s4
    800027b0:	d4ffe0ef          	jal	ra,800014fe <memmove>

    len -= n;
    800027b4:	409989b3          	sub	s3,s3,s1
    dst += n;
    800027b8:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800027ba:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800027be:	02098063          	beqz	s3,800027de <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    800027c2:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800027c6:	85ca                	mv	a1,s2
    800027c8:	855a                	mv	a0,s6
    800027ca:	9c3ff0ef          	jal	ra,8000218c <walkaddr>
    if(pa0 == 0)
    800027ce:	cd01                	beqz	a0,800027e6 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    800027d0:	418904b3          	sub	s1,s2,s8
    800027d4:	94d6                	add	s1,s1,s5
    800027d6:	fc99f6e3          	bgeu	s3,s1,800027a2 <copyin+0x28>
    800027da:	84ce                	mv	s1,s3
    800027dc:	b7d9                	j	800027a2 <copyin+0x28>
  }
  return 0;
    800027de:	4501                	li	a0,0
    800027e0:	a021                	j	800027e8 <copyin+0x6e>
    800027e2:	4501                	li	a0,0
}
    800027e4:	8082                	ret
      return -1;
    800027e6:	557d                	li	a0,-1
}
    800027e8:	60a6                	ld	ra,72(sp)
    800027ea:	6406                	ld	s0,64(sp)
    800027ec:	74e2                	ld	s1,56(sp)
    800027ee:	7942                	ld	s2,48(sp)
    800027f0:	79a2                	ld	s3,40(sp)
    800027f2:	7a02                	ld	s4,32(sp)
    800027f4:	6ae2                	ld	s5,24(sp)
    800027f6:	6b42                	ld	s6,16(sp)
    800027f8:	6ba2                	ld	s7,8(sp)
    800027fa:	6c02                	ld	s8,0(sp)
    800027fc:	6161                	addi	sp,sp,80
    800027fe:	8082                	ret

0000000080002800 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80002800:	c2cd                	beqz	a3,800028a2 <copyinstr+0xa2>
{
    80002802:	715d                	addi	sp,sp,-80
    80002804:	e486                	sd	ra,72(sp)
    80002806:	e0a2                	sd	s0,64(sp)
    80002808:	fc26                	sd	s1,56(sp)
    8000280a:	f84a                	sd	s2,48(sp)
    8000280c:	f44e                	sd	s3,40(sp)
    8000280e:	f052                	sd	s4,32(sp)
    80002810:	ec56                	sd	s5,24(sp)
    80002812:	e85a                	sd	s6,16(sp)
    80002814:	e45e                	sd	s7,8(sp)
    80002816:	0880                	addi	s0,sp,80
    80002818:	8a2a                	mv	s4,a0
    8000281a:	8b2e                	mv	s6,a1
    8000281c:	8bb2                	mv	s7,a2
    8000281e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80002820:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80002822:	6985                	lui	s3,0x1
    80002824:	a02d                	j	8000284e <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80002826:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000282a:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000282c:	37fd                	addiw	a5,a5,-1
    8000282e:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80002832:	60a6                	ld	ra,72(sp)
    80002834:	6406                	ld	s0,64(sp)
    80002836:	74e2                	ld	s1,56(sp)
    80002838:	7942                	ld	s2,48(sp)
    8000283a:	79a2                	ld	s3,40(sp)
    8000283c:	7a02                	ld	s4,32(sp)
    8000283e:	6ae2                	ld	s5,24(sp)
    80002840:	6b42                	ld	s6,16(sp)
    80002842:	6ba2                	ld	s7,8(sp)
    80002844:	6161                	addi	sp,sp,80
    80002846:	8082                	ret
    srcva = va0 + PGSIZE;
    80002848:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000284c:	c4b9                	beqz	s1,8000289a <copyinstr+0x9a>
    va0 = PGROUNDDOWN(srcva);
    8000284e:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80002852:	85ca                	mv	a1,s2
    80002854:	8552                	mv	a0,s4
    80002856:	937ff0ef          	jal	ra,8000218c <walkaddr>
    if(pa0 == 0)
    8000285a:	c131                	beqz	a0,8000289e <copyinstr+0x9e>
    n = PGSIZE - (srcva - va0);
    8000285c:	417906b3          	sub	a3,s2,s7
    80002860:	96ce                	add	a3,a3,s3
    80002862:	00d4f363          	bgeu	s1,a3,80002868 <copyinstr+0x68>
    80002866:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80002868:	955e                	add	a0,a0,s7
    8000286a:	41250533          	sub	a0,a0,s2
    while(n > 0){
    8000286e:	dee9                	beqz	a3,80002848 <copyinstr+0x48>
    80002870:	87da                	mv	a5,s6
      if(*p == '\0'){
    80002872:	41650633          	sub	a2,a0,s6
    80002876:	fff48593          	addi	a1,s1,-1 # ffffffffffffefff <end+0xffffffff7ffe3fdf>
    8000287a:	95da                	add	a1,a1,s6
    while(n > 0){
    8000287c:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    8000287e:	00f60733          	add	a4,a2,a5
    80002882:	00074703          	lbu	a4,0(a4)
    80002886:	d345                	beqz	a4,80002826 <copyinstr+0x26>
        *dst = *p;
    80002888:	00e78023          	sb	a4,0(a5)
      --max;
    8000288c:	40f584b3          	sub	s1,a1,a5
      dst++;
    80002890:	0785                	addi	a5,a5,1
    while(n > 0){
    80002892:	fed796e3          	bne	a5,a3,8000287e <copyinstr+0x7e>
      dst++;
    80002896:	8b3e                	mv	s6,a5
    80002898:	bf45                	j	80002848 <copyinstr+0x48>
    8000289a:	4781                	li	a5,0
    8000289c:	bf41                	j	8000282c <copyinstr+0x2c>
      return -1;
    8000289e:	557d                	li	a0,-1
    800028a0:	bf49                	j	80002832 <copyinstr+0x32>
  int got_null = 0;
    800028a2:	4781                	li	a5,0
  if(got_null){
    800028a4:	37fd                	addiw	a5,a5,-1
    800028a6:	0007851b          	sext.w	a0,a5
}
    800028aa:	8082                	ret

00000000800028ac <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800028ac:	715d                	addi	sp,sp,-80
    800028ae:	e486                	sd	ra,72(sp)
    800028b0:	e0a2                	sd	s0,64(sp)
    800028b2:	fc26                	sd	s1,56(sp)
    800028b4:	f84a                	sd	s2,48(sp)
    800028b6:	f44e                	sd	s3,40(sp)
    800028b8:	f052                	sd	s4,32(sp)
    800028ba:	ec56                	sd	s5,24(sp)
    800028bc:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800028be:	04c05363          	blez	a2,80002904 <consolewrite+0x58>
    800028c2:	8a2a                	mv	s4,a0
    800028c4:	84ae                	mv	s1,a1
    800028c6:	89b2                	mv	s3,a2
    800028c8:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800028ca:	5afd                	li	s5,-1
    800028cc:	4685                	li	a3,1
    800028ce:	8626                	mv	a2,s1
    800028d0:	85d2                	mv	a1,s4
    800028d2:	fbf40513          	addi	a0,s0,-65
    800028d6:	97bfe0ef          	jal	ra,80001250 <either_copyin>
    800028da:	01550b63          	beq	a0,s5,800028f0 <consolewrite+0x44>
      break;
    uartputc(c);
    800028de:	fbf44503          	lbu	a0,-65(s0)
    800028e2:	efaff0ef          	jal	ra,80001fdc <uartputc>
  for(i = 0; i < n; i++){
    800028e6:	2905                	addiw	s2,s2,1 # 1001 <_entry-0x7fffefff>
    800028e8:	0485                	addi	s1,s1,1
    800028ea:	ff2991e3          	bne	s3,s2,800028cc <consolewrite+0x20>
    800028ee:	894e                	mv	s2,s3
  }

  return i;
}
    800028f0:	854a                	mv	a0,s2
    800028f2:	60a6                	ld	ra,72(sp)
    800028f4:	6406                	ld	s0,64(sp)
    800028f6:	74e2                	ld	s1,56(sp)
    800028f8:	7942                	ld	s2,48(sp)
    800028fa:	79a2                	ld	s3,40(sp)
    800028fc:	7a02                	ld	s4,32(sp)
    800028fe:	6ae2                	ld	s5,24(sp)
    80002900:	6161                	addi	sp,sp,80
    80002902:	8082                	ret
  for(i = 0; i < n; i++){
    80002904:	4901                	li	s2,0
    80002906:	b7ed                	j	800028f0 <consolewrite+0x44>

0000000080002908 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002908:	7179                	addi	sp,sp,-48
    8000290a:	f406                	sd	ra,40(sp)
    8000290c:	f022                	sd	s0,32(sp)
    8000290e:	ec26                	sd	s1,24(sp)
    80002910:	e84a                	sd	s2,16(sp)
    80002912:	e44e                	sd	s3,8(sp)
    80002914:	e052                	sd	s4,0(sp)
    80002916:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002918:	00003597          	auipc	a1,0x3
    8000291c:	e7058593          	addi	a1,a1,-400 # 80005788 <syscalls+0x3c8>
    80002920:	00010517          	auipc	a0,0x10
    80002924:	f0050513          	addi	a0,a0,-256 # 80012820 <bcache>
    80002928:	973fe0ef          	jal	ra,8000129a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000292c:	00018797          	auipc	a5,0x18
    80002930:	ef478793          	addi	a5,a5,-268 # 8001a820 <bcache+0x8000>
    80002934:	00018717          	auipc	a4,0x18
    80002938:	15470713          	addi	a4,a4,340 # 8001aa88 <bcache+0x8268>
    8000293c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002940:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002944:	00010497          	auipc	s1,0x10
    80002948:	ef448493          	addi	s1,s1,-268 # 80012838 <bcache+0x18>
    b->next = bcache.head.next;
    8000294c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000294e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002950:	00003a17          	auipc	s4,0x3
    80002954:	e40a0a13          	addi	s4,s4,-448 # 80005790 <syscalls+0x3d0>
    b->next = bcache.head.next;
    80002958:	2b893783          	ld	a5,696(s2)
    8000295c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000295e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002962:	85d2                	mv	a1,s4
    80002964:	01048513          	addi	a0,s1,16
    80002968:	220000ef          	jal	ra,80002b88 <initsleeplock>
    bcache.head.next->prev = b;
    8000296c:	2b893783          	ld	a5,696(s2)
    80002970:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002972:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002976:	45848493          	addi	s1,s1,1112
    8000297a:	fd349fe3          	bne	s1,s3,80002958 <binit+0x50>
  }
}
    8000297e:	70a2                	ld	ra,40(sp)
    80002980:	7402                	ld	s0,32(sp)
    80002982:	64e2                	ld	s1,24(sp)
    80002984:	6942                	ld	s2,16(sp)
    80002986:	69a2                	ld	s3,8(sp)
    80002988:	6a02                	ld	s4,0(sp)
    8000298a:	6145                	addi	sp,sp,48
    8000298c:	8082                	ret

000000008000298e <bread>:

// Return a locked buf with the contents of the indicated block.
// 传入物理设备和块号，返回一块已经读好了相关物理块内容的buf
struct buf*
bread(uint dev, uint blockno)
{
    8000298e:	7179                	addi	sp,sp,-48
    80002990:	f406                	sd	ra,40(sp)
    80002992:	f022                	sd	s0,32(sp)
    80002994:	ec26                	sd	s1,24(sp)
    80002996:	e84a                	sd	s2,16(sp)
    80002998:	e44e                	sd	s3,8(sp)
    8000299a:	1800                	addi	s0,sp,48
    8000299c:	892a                	mv	s2,a0
    8000299e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800029a0:	00010517          	auipc	a0,0x10
    800029a4:	e8050513          	addi	a0,a0,-384 # 80012820 <bcache>
    800029a8:	973fe0ef          	jal	ra,8000131a <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800029ac:	00018497          	auipc	s1,0x18
    800029b0:	12c4b483          	ld	s1,300(s1) # 8001aad8 <bcache+0x82b8>
    800029b4:	00018797          	auipc	a5,0x18
    800029b8:	0d478793          	addi	a5,a5,212 # 8001aa88 <bcache+0x8268>
    800029bc:	02f48b63          	beq	s1,a5,800029f2 <bread+0x64>
    800029c0:	873e                	mv	a4,a5
    800029c2:	a021                	j	800029ca <bread+0x3c>
    800029c4:	68a4                	ld	s1,80(s1)
    800029c6:	02e48663          	beq	s1,a4,800029f2 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    800029ca:	449c                	lw	a5,8(s1)
    800029cc:	ff279ce3          	bne	a5,s2,800029c4 <bread+0x36>
    800029d0:	44dc                	lw	a5,12(s1)
    800029d2:	ff3799e3          	bne	a5,s3,800029c4 <bread+0x36>
      b->refcnt++;
    800029d6:	40bc                	lw	a5,64(s1)
    800029d8:	2785                	addiw	a5,a5,1
    800029da:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800029dc:	00010517          	auipc	a0,0x10
    800029e0:	e4450513          	addi	a0,a0,-444 # 80012820 <bcache>
    800029e4:	9cffe0ef          	jal	ra,800013b2 <release>
      acquiresleep(&b->lock);
    800029e8:	01048513          	addi	a0,s1,16
    800029ec:	1d2000ef          	jal	ra,80002bbe <acquiresleep>
      return b;
    800029f0:	a889                	j	80002a42 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800029f2:	00018497          	auipc	s1,0x18
    800029f6:	0de4b483          	ld	s1,222(s1) # 8001aad0 <bcache+0x82b0>
    800029fa:	00018797          	auipc	a5,0x18
    800029fe:	08e78793          	addi	a5,a5,142 # 8001aa88 <bcache+0x8268>
    80002a02:	00f48863          	beq	s1,a5,80002a12 <bread+0x84>
    80002a06:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002a08:	40bc                	lw	a5,64(s1)
    80002a0a:	cb91                	beqz	a5,80002a1e <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002a0c:	64a4                	ld	s1,72(s1)
    80002a0e:	fee49de3          	bne	s1,a4,80002a08 <bread+0x7a>
  panic("bget: no buffers");
    80002a12:	00003517          	auipc	a0,0x3
    80002a16:	d8650513          	addi	a0,a0,-634 # 80005798 <syscalls+0x3d8>
    80002a1a:	c53fd0ef          	jal	ra,8000066c <panic>
      b->dev = dev;
    80002a1e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002a22:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002a26:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002a2a:	4785                	li	a5,1
    80002a2c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002a2e:	00010517          	auipc	a0,0x10
    80002a32:	df250513          	addi	a0,a0,-526 # 80012820 <bcache>
    80002a36:	97dfe0ef          	jal	ra,800013b2 <release>
      acquiresleep(&b->lock);
    80002a3a:	01048513          	addi	a0,s1,16
    80002a3e:	180000ef          	jal	ra,80002bbe <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002a42:	409c                	lw	a5,0(s1)
    80002a44:	cb89                	beqz	a5,80002a56 <bread+0xc8>
    virtio_disk_rw(b, 0); 
    b->valid = 1;
  }
  return b;
}
    80002a46:	8526                	mv	a0,s1
    80002a48:	70a2                	ld	ra,40(sp)
    80002a4a:	7402                	ld	s0,32(sp)
    80002a4c:	64e2                	ld	s1,24(sp)
    80002a4e:	6942                	ld	s2,16(sp)
    80002a50:	69a2                	ld	s3,8(sp)
    80002a52:	6145                	addi	sp,sp,48
    80002a54:	8082                	ret
    virtio_disk_rw(b, 0); 
    80002a56:	4581                	li	a1,0
    80002a58:	8526                	mv	a0,s1
    80002a5a:	458000ef          	jal	ra,80002eb2 <virtio_disk_rw>
    b->valid = 1;
    80002a5e:	4785                	li	a5,1
    80002a60:	c09c                	sw	a5,0(s1)
  return b;
    80002a62:	b7d5                	j	80002a46 <bread+0xb8>

0000000080002a64 <bwrite>:

// Write b's contents to disk.  Must be locked.
// 传入buf，将其写入disk
void
bwrite(struct buf *b)
{
    80002a64:	1101                	addi	sp,sp,-32
    80002a66:	ec06                	sd	ra,24(sp)
    80002a68:	e822                	sd	s0,16(sp)
    80002a6a:	e426                	sd	s1,8(sp)
    80002a6c:	1000                	addi	s0,sp,32
    80002a6e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002a70:	0541                	addi	a0,a0,16
    80002a72:	1ca000ef          	jal	ra,80002c3c <holdingsleep>
    80002a76:	c911                	beqz	a0,80002a8a <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002a78:	4585                	li	a1,1
    80002a7a:	8526                	mv	a0,s1
    80002a7c:	436000ef          	jal	ra,80002eb2 <virtio_disk_rw>
}
    80002a80:	60e2                	ld	ra,24(sp)
    80002a82:	6442                	ld	s0,16(sp)
    80002a84:	64a2                	ld	s1,8(sp)
    80002a86:	6105                	addi	sp,sp,32
    80002a88:	8082                	ret
    panic("bwrite");
    80002a8a:	00003517          	auipc	a0,0x3
    80002a8e:	d2650513          	addi	a0,a0,-730 # 800057b0 <syscalls+0x3f0>
    80002a92:	bdbfd0ef          	jal	ra,8000066c <panic>

0000000080002a96 <brelse>:
// Release a locked buffer.
// Move to the head of the most-recently-used list.
// 释放一块被使用的buffer
void
brelse(struct buf *b)
{
    80002a96:	1101                	addi	sp,sp,-32
    80002a98:	ec06                	sd	ra,24(sp)
    80002a9a:	e822                	sd	s0,16(sp)
    80002a9c:	e426                	sd	s1,8(sp)
    80002a9e:	e04a                	sd	s2,0(sp)
    80002aa0:	1000                	addi	s0,sp,32
    80002aa2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002aa4:	01050913          	addi	s2,a0,16
    80002aa8:	854a                	mv	a0,s2
    80002aaa:	192000ef          	jal	ra,80002c3c <holdingsleep>
    80002aae:	c13d                	beqz	a0,80002b14 <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    80002ab0:	854a                	mv	a0,s2
    80002ab2:	152000ef          	jal	ra,80002c04 <releasesleep>

  acquire(&bcache.lock);
    80002ab6:	00010517          	auipc	a0,0x10
    80002aba:	d6a50513          	addi	a0,a0,-662 # 80012820 <bcache>
    80002abe:	85dfe0ef          	jal	ra,8000131a <acquire>
  b->refcnt--;
    80002ac2:	40bc                	lw	a5,64(s1)
    80002ac4:	37fd                	addiw	a5,a5,-1
    80002ac6:	0007871b          	sext.w	a4,a5
    80002aca:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002acc:	eb05                	bnez	a4,80002afc <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002ace:	68bc                	ld	a5,80(s1)
    80002ad0:	64b8                	ld	a4,72(s1)
    80002ad2:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002ad4:	64bc                	ld	a5,72(s1)
    80002ad6:	68b8                	ld	a4,80(s1)
    80002ad8:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002ada:	00018797          	auipc	a5,0x18
    80002ade:	d4678793          	addi	a5,a5,-698 # 8001a820 <bcache+0x8000>
    80002ae2:	2b87b703          	ld	a4,696(a5)
    80002ae6:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002ae8:	00018717          	auipc	a4,0x18
    80002aec:	fa070713          	addi	a4,a4,-96 # 8001aa88 <bcache+0x8268>
    80002af0:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002af2:	2b87b703          	ld	a4,696(a5)
    80002af6:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002af8:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002afc:	00010517          	auipc	a0,0x10
    80002b00:	d2450513          	addi	a0,a0,-732 # 80012820 <bcache>
    80002b04:	8affe0ef          	jal	ra,800013b2 <release>
}
    80002b08:	60e2                	ld	ra,24(sp)
    80002b0a:	6442                	ld	s0,16(sp)
    80002b0c:	64a2                	ld	s1,8(sp)
    80002b0e:	6902                	ld	s2,0(sp)
    80002b10:	6105                	addi	sp,sp,32
    80002b12:	8082                	ret
    panic("brelse");
    80002b14:	00003517          	auipc	a0,0x3
    80002b18:	ca450513          	addi	a0,a0,-860 # 800057b8 <syscalls+0x3f8>
    80002b1c:	b51fd0ef          	jal	ra,8000066c <panic>

0000000080002b20 <bpin>:

void
bpin(struct buf *b) {
    80002b20:	1101                	addi	sp,sp,-32
    80002b22:	ec06                	sd	ra,24(sp)
    80002b24:	e822                	sd	s0,16(sp)
    80002b26:	e426                	sd	s1,8(sp)
    80002b28:	1000                	addi	s0,sp,32
    80002b2a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002b2c:	00010517          	auipc	a0,0x10
    80002b30:	cf450513          	addi	a0,a0,-780 # 80012820 <bcache>
    80002b34:	fe6fe0ef          	jal	ra,8000131a <acquire>
  b->refcnt++;
    80002b38:	40bc                	lw	a5,64(s1)
    80002b3a:	2785                	addiw	a5,a5,1
    80002b3c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002b3e:	00010517          	auipc	a0,0x10
    80002b42:	ce250513          	addi	a0,a0,-798 # 80012820 <bcache>
    80002b46:	86dfe0ef          	jal	ra,800013b2 <release>
}
    80002b4a:	60e2                	ld	ra,24(sp)
    80002b4c:	6442                	ld	s0,16(sp)
    80002b4e:	64a2                	ld	s1,8(sp)
    80002b50:	6105                	addi	sp,sp,32
    80002b52:	8082                	ret

0000000080002b54 <bunpin>:

void
bunpin(struct buf *b) {
    80002b54:	1101                	addi	sp,sp,-32
    80002b56:	ec06                	sd	ra,24(sp)
    80002b58:	e822                	sd	s0,16(sp)
    80002b5a:	e426                	sd	s1,8(sp)
    80002b5c:	1000                	addi	s0,sp,32
    80002b5e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002b60:	00010517          	auipc	a0,0x10
    80002b64:	cc050513          	addi	a0,a0,-832 # 80012820 <bcache>
    80002b68:	fb2fe0ef          	jal	ra,8000131a <acquire>
  b->refcnt--;
    80002b6c:	40bc                	lw	a5,64(s1)
    80002b6e:	37fd                	addiw	a5,a5,-1
    80002b70:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002b72:	00010517          	auipc	a0,0x10
    80002b76:	cae50513          	addi	a0,a0,-850 # 80012820 <bcache>
    80002b7a:	839fe0ef          	jal	ra,800013b2 <release>
}
    80002b7e:	60e2                	ld	ra,24(sp)
    80002b80:	6442                	ld	s0,16(sp)
    80002b82:	64a2                	ld	s1,8(sp)
    80002b84:	6105                	addi	sp,sp,32
    80002b86:	8082                	ret

0000000080002b88 <initsleeplock>:
// 文件直接使用了xv6标准文件，应该没有错误 //
//////////////////////////////////////////

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80002b88:	1101                	addi	sp,sp,-32
    80002b8a:	ec06                	sd	ra,24(sp)
    80002b8c:	e822                	sd	s0,16(sp)
    80002b8e:	e426                	sd	s1,8(sp)
    80002b90:	e04a                	sd	s2,0(sp)
    80002b92:	1000                	addi	s0,sp,32
    80002b94:	84aa                	mv	s1,a0
    80002b96:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80002b98:	00003597          	auipc	a1,0x3
    80002b9c:	c2858593          	addi	a1,a1,-984 # 800057c0 <syscalls+0x400>
    80002ba0:	0521                	addi	a0,a0,8
    80002ba2:	ef8fe0ef          	jal	ra,8000129a <initlock>
  lk->name = name;
    80002ba6:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80002baa:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80002bae:	0204a423          	sw	zero,40(s1)
}
    80002bb2:	60e2                	ld	ra,24(sp)
    80002bb4:	6442                	ld	s0,16(sp)
    80002bb6:	64a2                	ld	s1,8(sp)
    80002bb8:	6902                	ld	s2,0(sp)
    80002bba:	6105                	addi	sp,sp,32
    80002bbc:	8082                	ret

0000000080002bbe <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80002bbe:	1101                	addi	sp,sp,-32
    80002bc0:	ec06                	sd	ra,24(sp)
    80002bc2:	e822                	sd	s0,16(sp)
    80002bc4:	e426                	sd	s1,8(sp)
    80002bc6:	e04a                	sd	s2,0(sp)
    80002bc8:	1000                	addi	s0,sp,32
    80002bca:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80002bcc:	00850913          	addi	s2,a0,8
    80002bd0:	854a                	mv	a0,s2
    80002bd2:	f48fe0ef          	jal	ra,8000131a <acquire>
  while (lk->locked) {
    80002bd6:	409c                	lw	a5,0(s1)
    80002bd8:	c799                	beqz	a5,80002be6 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80002bda:	85ca                	mv	a1,s2
    80002bdc:	8526                	mv	a0,s1
    80002bde:	b4cfe0ef          	jal	ra,80000f2a <sleep>
  while (lk->locked) {
    80002be2:	409c                	lw	a5,0(s1)
    80002be4:	fbfd                	bnez	a5,80002bda <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80002be6:	4785                	li	a5,1
    80002be8:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80002bea:	c49fd0ef          	jal	ra,80000832 <myproc>
    80002bee:	591c                	lw	a5,48(a0)
    80002bf0:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80002bf2:	854a                	mv	a0,s2
    80002bf4:	fbefe0ef          	jal	ra,800013b2 <release>
}
    80002bf8:	60e2                	ld	ra,24(sp)
    80002bfa:	6442                	ld	s0,16(sp)
    80002bfc:	64a2                	ld	s1,8(sp)
    80002bfe:	6902                	ld	s2,0(sp)
    80002c00:	6105                	addi	sp,sp,32
    80002c02:	8082                	ret

0000000080002c04 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80002c04:	1101                	addi	sp,sp,-32
    80002c06:	ec06                	sd	ra,24(sp)
    80002c08:	e822                	sd	s0,16(sp)
    80002c0a:	e426                	sd	s1,8(sp)
    80002c0c:	e04a                	sd	s2,0(sp)
    80002c0e:	1000                	addi	s0,sp,32
    80002c10:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80002c12:	00850913          	addi	s2,a0,8
    80002c16:	854a                	mv	a0,s2
    80002c18:	f02fe0ef          	jal	ra,8000131a <acquire>
  lk->locked = 0;
    80002c1c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80002c20:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80002c24:	8526                	mv	a0,s1
    80002c26:	b50fe0ef          	jal	ra,80000f76 <wakeup>
  release(&lk->lk);
    80002c2a:	854a                	mv	a0,s2
    80002c2c:	f86fe0ef          	jal	ra,800013b2 <release>
}
    80002c30:	60e2                	ld	ra,24(sp)
    80002c32:	6442                	ld	s0,16(sp)
    80002c34:	64a2                	ld	s1,8(sp)
    80002c36:	6902                	ld	s2,0(sp)
    80002c38:	6105                	addi	sp,sp,32
    80002c3a:	8082                	ret

0000000080002c3c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80002c3c:	7179                	addi	sp,sp,-48
    80002c3e:	f406                	sd	ra,40(sp)
    80002c40:	f022                	sd	s0,32(sp)
    80002c42:	ec26                	sd	s1,24(sp)
    80002c44:	e84a                	sd	s2,16(sp)
    80002c46:	e44e                	sd	s3,8(sp)
    80002c48:	1800                	addi	s0,sp,48
    80002c4a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80002c4c:	00850913          	addi	s2,a0,8
    80002c50:	854a                	mv	a0,s2
    80002c52:	ec8fe0ef          	jal	ra,8000131a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80002c56:	409c                	lw	a5,0(s1)
    80002c58:	ef89                	bnez	a5,80002c72 <holdingsleep+0x36>
    80002c5a:	4481                	li	s1,0
  release(&lk->lk);
    80002c5c:	854a                	mv	a0,s2
    80002c5e:	f54fe0ef          	jal	ra,800013b2 <release>
  return r;
}
    80002c62:	8526                	mv	a0,s1
    80002c64:	70a2                	ld	ra,40(sp)
    80002c66:	7402                	ld	s0,32(sp)
    80002c68:	64e2                	ld	s1,24(sp)
    80002c6a:	6942                	ld	s2,16(sp)
    80002c6c:	69a2                	ld	s3,8(sp)
    80002c6e:	6145                	addi	sp,sp,48
    80002c70:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80002c72:	0284a983          	lw	s3,40(s1)
    80002c76:	bbdfd0ef          	jal	ra,80000832 <myproc>
    80002c7a:	5904                	lw	s1,48(a0)
    80002c7c:	413484b3          	sub	s1,s1,s3
    80002c80:	0014b493          	seqz	s1,s1
    80002c84:	bfe1                	j	80002c5c <holdingsleep+0x20>

0000000080002c86 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80002c86:	1141                	addi	sp,sp,-16
    80002c88:	e406                	sd	ra,8(sp)
    80002c8a:	e022                	sd	s0,0(sp)
    80002c8c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80002c8e:	479d                	li	a5,7
    80002c90:	04a7ca63          	blt	a5,a0,80002ce4 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80002c94:	00018797          	auipc	a5,0x18
    80002c98:	24c78793          	addi	a5,a5,588 # 8001aee0 <disk>
    80002c9c:	97aa                	add	a5,a5,a0
    80002c9e:	0187c783          	lbu	a5,24(a5)
    80002ca2:	e7b9                	bnez	a5,80002cf0 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80002ca4:	00451693          	slli	a3,a0,0x4
    80002ca8:	00018797          	auipc	a5,0x18
    80002cac:	23878793          	addi	a5,a5,568 # 8001aee0 <disk>
    80002cb0:	6398                	ld	a4,0(a5)
    80002cb2:	9736                	add	a4,a4,a3
    80002cb4:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80002cb8:	6398                	ld	a4,0(a5)
    80002cba:	9736                	add	a4,a4,a3
    80002cbc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80002cc0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80002cc4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80002cc8:	97aa                	add	a5,a5,a0
    80002cca:	4705                	li	a4,1
    80002ccc:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80002cd0:	00018517          	auipc	a0,0x18
    80002cd4:	22850513          	addi	a0,a0,552 # 8001aef8 <disk+0x18>
    80002cd8:	a9efe0ef          	jal	ra,80000f76 <wakeup>
}
    80002cdc:	60a2                	ld	ra,8(sp)
    80002cde:	6402                	ld	s0,0(sp)
    80002ce0:	0141                	addi	sp,sp,16
    80002ce2:	8082                	ret
    panic("free_desc 1");
    80002ce4:	00003517          	auipc	a0,0x3
    80002ce8:	aec50513          	addi	a0,a0,-1300 # 800057d0 <syscalls+0x410>
    80002cec:	981fd0ef          	jal	ra,8000066c <panic>
    panic("free_desc 2");
    80002cf0:	00003517          	auipc	a0,0x3
    80002cf4:	af050513          	addi	a0,a0,-1296 # 800057e0 <syscalls+0x420>
    80002cf8:	975fd0ef          	jal	ra,8000066c <panic>

0000000080002cfc <virtio_disk_init>:
{
    80002cfc:	1101                	addi	sp,sp,-32
    80002cfe:	ec06                	sd	ra,24(sp)
    80002d00:	e822                	sd	s0,16(sp)
    80002d02:	e426                	sd	s1,8(sp)
    80002d04:	e04a                	sd	s2,0(sp)
    80002d06:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80002d08:	00003597          	auipc	a1,0x3
    80002d0c:	ae858593          	addi	a1,a1,-1304 # 800057f0 <syscalls+0x430>
    80002d10:	00018517          	auipc	a0,0x18
    80002d14:	2f850513          	addi	a0,a0,760 # 8001b008 <disk+0x128>
    80002d18:	d82fe0ef          	jal	ra,8000129a <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80002d1c:	100017b7          	lui	a5,0x10001
    80002d20:	4398                	lw	a4,0(a5)
    80002d22:	2701                	sext.w	a4,a4
    80002d24:	747277b7          	lui	a5,0x74727
    80002d28:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80002d2c:	12f71f63          	bne	a4,a5,80002e6a <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80002d30:	100017b7          	lui	a5,0x10001
    80002d34:	43dc                	lw	a5,4(a5)
    80002d36:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80002d38:	4709                	li	a4,2
    80002d3a:	12e79863          	bne	a5,a4,80002e6a <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80002d3e:	100017b7          	lui	a5,0x10001
    80002d42:	479c                	lw	a5,8(a5)
    80002d44:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80002d46:	12e79263          	bne	a5,a4,80002e6a <virtio_disk_init+0x16e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80002d4a:	100017b7          	lui	a5,0x10001
    80002d4e:	47d8                	lw	a4,12(a5)
    80002d50:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80002d52:	554d47b7          	lui	a5,0x554d4
    80002d56:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80002d5a:	10f71863          	bne	a4,a5,80002e6a <virtio_disk_init+0x16e>
  *R(VIRTIO_MMIO_STATUS) = status;
    80002d5e:	100017b7          	lui	a5,0x10001
    80002d62:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80002d66:	4705                	li	a4,1
    80002d68:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80002d6a:	470d                	li	a4,3
    80002d6c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80002d6e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80002d70:	c7ffe6b7          	lui	a3,0xc7ffe
    80002d74:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fe373f>
    80002d78:	8f75                	and	a4,a4,a3
    80002d7a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80002d7c:	472d                	li	a4,11
    80002d7e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80002d80:	5bbc                	lw	a5,112(a5)
    80002d82:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80002d86:	8ba1                	andi	a5,a5,8
    80002d88:	0e078763          	beqz	a5,80002e76 <virtio_disk_init+0x17a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80002d8c:	100017b7          	lui	a5,0x10001
    80002d90:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80002d94:	43fc                	lw	a5,68(a5)
    80002d96:	2781                	sext.w	a5,a5
    80002d98:	0e079563          	bnez	a5,80002e82 <virtio_disk_init+0x186>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80002d9c:	100017b7          	lui	a5,0x10001
    80002da0:	5bdc                	lw	a5,52(a5)
    80002da2:	2781                	sext.w	a5,a5
  if(max == 0)
    80002da4:	0e078563          	beqz	a5,80002e8e <virtio_disk_init+0x192>
  if(max < NUM)
    80002da8:	471d                	li	a4,7
    80002daa:	0ef77863          	bgeu	a4,a5,80002e9a <virtio_disk_init+0x19e>
  disk.desc = kalloc();
    80002dae:	b50fd0ef          	jal	ra,800000fe <kalloc>
    80002db2:	00018497          	auipc	s1,0x18
    80002db6:	12e48493          	addi	s1,s1,302 # 8001aee0 <disk>
    80002dba:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80002dbc:	b42fd0ef          	jal	ra,800000fe <kalloc>
    80002dc0:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80002dc2:	b3cfd0ef          	jal	ra,800000fe <kalloc>
    80002dc6:	87aa                	mv	a5,a0
    80002dc8:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80002dca:	6088                	ld	a0,0(s1)
    80002dcc:	cd69                	beqz	a0,80002ea6 <virtio_disk_init+0x1aa>
    80002dce:	00018717          	auipc	a4,0x18
    80002dd2:	11a73703          	ld	a4,282(a4) # 8001aee8 <disk+0x8>
    80002dd6:	cb61                	beqz	a4,80002ea6 <virtio_disk_init+0x1aa>
    80002dd8:	c7f9                	beqz	a5,80002ea6 <virtio_disk_init+0x1aa>
  memset(disk.desc, 0, PGSIZE);
    80002dda:	6605                	lui	a2,0x1
    80002ddc:	4581                	li	a1,0
    80002dde:	ec4fe0ef          	jal	ra,800014a2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80002de2:	00018497          	auipc	s1,0x18
    80002de6:	0fe48493          	addi	s1,s1,254 # 8001aee0 <disk>
    80002dea:	6605                	lui	a2,0x1
    80002dec:	4581                	li	a1,0
    80002dee:	6488                	ld	a0,8(s1)
    80002df0:	eb2fe0ef          	jal	ra,800014a2 <memset>
  memset(disk.used, 0, PGSIZE);
    80002df4:	6605                	lui	a2,0x1
    80002df6:	4581                	li	a1,0
    80002df8:	6888                	ld	a0,16(s1)
    80002dfa:	ea8fe0ef          	jal	ra,800014a2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80002dfe:	100017b7          	lui	a5,0x10001
    80002e02:	4721                	li	a4,8
    80002e04:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80002e06:	4098                	lw	a4,0(s1)
    80002e08:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80002e0c:	40d8                	lw	a4,4(s1)
    80002e0e:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80002e12:	6498                	ld	a4,8(s1)
    80002e14:	0007069b          	sext.w	a3,a4
    80002e18:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80002e1c:	9701                	srai	a4,a4,0x20
    80002e1e:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80002e22:	6898                	ld	a4,16(s1)
    80002e24:	0007069b          	sext.w	a3,a4
    80002e28:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80002e2c:	9701                	srai	a4,a4,0x20
    80002e2e:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80002e32:	4705                	li	a4,1
    80002e34:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80002e36:	00e48c23          	sb	a4,24(s1)
    80002e3a:	00e48ca3          	sb	a4,25(s1)
    80002e3e:	00e48d23          	sb	a4,26(s1)
    80002e42:	00e48da3          	sb	a4,27(s1)
    80002e46:	00e48e23          	sb	a4,28(s1)
    80002e4a:	00e48ea3          	sb	a4,29(s1)
    80002e4e:	00e48f23          	sb	a4,30(s1)
    80002e52:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80002e56:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80002e5a:	0727a823          	sw	s2,112(a5)
}
    80002e5e:	60e2                	ld	ra,24(sp)
    80002e60:	6442                	ld	s0,16(sp)
    80002e62:	64a2                	ld	s1,8(sp)
    80002e64:	6902                	ld	s2,0(sp)
    80002e66:	6105                	addi	sp,sp,32
    80002e68:	8082                	ret
    panic("could not find virtio disk");
    80002e6a:	00003517          	auipc	a0,0x3
    80002e6e:	99650513          	addi	a0,a0,-1642 # 80005800 <syscalls+0x440>
    80002e72:	ffafd0ef          	jal	ra,8000066c <panic>
    panic("virtio disk FEATURES_OK unset");
    80002e76:	00003517          	auipc	a0,0x3
    80002e7a:	9aa50513          	addi	a0,a0,-1622 # 80005820 <syscalls+0x460>
    80002e7e:	feefd0ef          	jal	ra,8000066c <panic>
    panic("virtio disk should not be ready");
    80002e82:	00003517          	auipc	a0,0x3
    80002e86:	9be50513          	addi	a0,a0,-1602 # 80005840 <syscalls+0x480>
    80002e8a:	fe2fd0ef          	jal	ra,8000066c <panic>
    panic("virtio disk has no queue 0");
    80002e8e:	00003517          	auipc	a0,0x3
    80002e92:	9d250513          	addi	a0,a0,-1582 # 80005860 <syscalls+0x4a0>
    80002e96:	fd6fd0ef          	jal	ra,8000066c <panic>
    panic("virtio disk max queue too short");
    80002e9a:	00003517          	auipc	a0,0x3
    80002e9e:	9e650513          	addi	a0,a0,-1562 # 80005880 <syscalls+0x4c0>
    80002ea2:	fcafd0ef          	jal	ra,8000066c <panic>
    panic("virtio disk kalloc");
    80002ea6:	00003517          	auipc	a0,0x3
    80002eaa:	9fa50513          	addi	a0,a0,-1542 # 800058a0 <syscalls+0x4e0>
    80002eae:	fbefd0ef          	jal	ra,8000066c <panic>

0000000080002eb2 <virtio_disk_rw>:

// 这个函数比较重要，这个被bio.c中的bread,bwrite调用
// 做的事情就是将buffer结构体中的数据写入disk或读取数据到buffer
void
virtio_disk_rw(struct buf *b, int write)
{
    80002eb2:	7119                	addi	sp,sp,-128
    80002eb4:	fc86                	sd	ra,120(sp)
    80002eb6:	f8a2                	sd	s0,112(sp)
    80002eb8:	f4a6                	sd	s1,104(sp)
    80002eba:	f0ca                	sd	s2,96(sp)
    80002ebc:	ecce                	sd	s3,88(sp)
    80002ebe:	e8d2                	sd	s4,80(sp)
    80002ec0:	e4d6                	sd	s5,72(sp)
    80002ec2:	e0da                	sd	s6,64(sp)
    80002ec4:	fc5e                	sd	s7,56(sp)
    80002ec6:	f862                	sd	s8,48(sp)
    80002ec8:	f466                	sd	s9,40(sp)
    80002eca:	f06a                	sd	s10,32(sp)
    80002ecc:	ec6e                	sd	s11,24(sp)
    80002ece:	0100                	addi	s0,sp,128
    80002ed0:	8aaa                	mv	s5,a0
    80002ed2:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512); 
    80002ed4:	00c52d03          	lw	s10,12(a0)
    80002ed8:	001d1d1b          	slliw	s10,s10,0x1
    80002edc:	1d02                	slli	s10,s10,0x20
    80002ede:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80002ee2:	00018517          	auipc	a0,0x18
    80002ee6:	12650513          	addi	a0,a0,294 # 8001b008 <disk+0x128>
    80002eea:	c30fe0ef          	jal	ra,8000131a <acquire>
  for(int i = 0; i < 3; i++){
    80002eee:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80002ef0:	44a1                	li	s1,8
      disk.free[i] = 0;
    80002ef2:	00018b97          	auipc	s7,0x18
    80002ef6:	feeb8b93          	addi	s7,s7,-18 # 8001aee0 <disk>
  for(int i = 0; i < 3; i++){
    80002efa:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80002efc:	00018c97          	auipc	s9,0x18
    80002f00:	10cc8c93          	addi	s9,s9,268 # 8001b008 <disk+0x128>
    80002f04:	a8a9                	j	80002f5e <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80002f06:	00fb8733          	add	a4,s7,a5
    80002f0a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80002f0e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80002f10:	0207c563          	bltz	a5,80002f3a <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80002f14:	2905                	addiw	s2,s2,1
    80002f16:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80002f18:	05690863          	beq	s2,s6,80002f68 <virtio_disk_rw+0xb6>
    idx[i] = alloc_desc();
    80002f1c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80002f1e:	00018717          	auipc	a4,0x18
    80002f22:	fc270713          	addi	a4,a4,-62 # 8001aee0 <disk>
    80002f26:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80002f28:	01874683          	lbu	a3,24(a4)
    80002f2c:	fee9                	bnez	a3,80002f06 <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    80002f2e:	2785                	addiw	a5,a5,1
    80002f30:	0705                	addi	a4,a4,1
    80002f32:	fe979be3          	bne	a5,s1,80002f28 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80002f36:	57fd                	li	a5,-1
    80002f38:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80002f3a:	01205b63          	blez	s2,80002f50 <virtio_disk_rw+0x9e>
    80002f3e:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80002f40:	000a2503          	lw	a0,0(s4)
    80002f44:	d43ff0ef          	jal	ra,80002c86 <free_desc>
      for(int j = 0; j < i; j++)
    80002f48:	2d85                	addiw	s11,s11,1
    80002f4a:	0a11                	addi	s4,s4,4
    80002f4c:	ff2d9ae3          	bne	s11,s2,80002f40 <virtio_disk_rw+0x8e>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80002f50:	85e6                	mv	a1,s9
    80002f52:	00018517          	auipc	a0,0x18
    80002f56:	fa650513          	addi	a0,a0,-90 # 8001aef8 <disk+0x18>
    80002f5a:	fd1fd0ef          	jal	ra,80000f2a <sleep>
  for(int i = 0; i < 3; i++){
    80002f5e:	f8040a13          	addi	s4,s0,-128
{
    80002f62:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80002f64:	894e                	mv	s2,s3
    80002f66:	bf5d                	j	80002f1c <virtio_disk_rw+0x6a>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80002f68:	f8042503          	lw	a0,-128(s0)
    80002f6c:	00a50713          	addi	a4,a0,10
    80002f70:	0712                	slli	a4,a4,0x4

  if(write)
    80002f72:	00018797          	auipc	a5,0x18
    80002f76:	f6e78793          	addi	a5,a5,-146 # 8001aee0 <disk>
    80002f7a:	00e786b3          	add	a3,a5,a4
    80002f7e:	01803633          	snez	a2,s8
    80002f82:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80002f84:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80002f88:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80002f8c:	f6070613          	addi	a2,a4,-160
    80002f90:	6394                	ld	a3,0(a5)
    80002f92:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80002f94:	00870593          	addi	a1,a4,8
    80002f98:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80002f9a:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80002f9c:	0007b803          	ld	a6,0(a5)
    80002fa0:	9642                	add	a2,a2,a6
    80002fa2:	46c1                	li	a3,16
    80002fa4:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80002fa6:	4585                	li	a1,1
    80002fa8:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80002fac:	f8442683          	lw	a3,-124(s0)
    80002fb0:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80002fb4:	0692                	slli	a3,a3,0x4
    80002fb6:	9836                	add	a6,a6,a3
    80002fb8:	058a8613          	addi	a2,s5,88 # fffffffffffff058 <end+0xffffffff7ffe4038>
    80002fbc:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80002fc0:	0007b803          	ld	a6,0(a5)
    80002fc4:	96c2                	add	a3,a3,a6
    80002fc6:	40000613          	li	a2,1024
    80002fca:	c690                	sw	a2,8(a3)
  if(write)
    80002fcc:	001c3613          	seqz	a2,s8
    80002fd0:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80002fd4:	00166613          	ori	a2,a2,1
    80002fd8:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80002fdc:	f8842603          	lw	a2,-120(s0)
    80002fe0:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80002fe4:	00250693          	addi	a3,a0,2
    80002fe8:	0692                	slli	a3,a3,0x4
    80002fea:	96be                	add	a3,a3,a5
    80002fec:	58fd                	li	a7,-1
    80002fee:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80002ff2:	0612                	slli	a2,a2,0x4
    80002ff4:	9832                	add	a6,a6,a2
    80002ff6:	f9070713          	addi	a4,a4,-112
    80002ffa:	973e                	add	a4,a4,a5
    80002ffc:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80003000:	6398                	ld	a4,0(a5)
    80003002:	9732                	add	a4,a4,a2
    80003004:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80003006:	4609                	li	a2,2
    80003008:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    8000300c:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80003010:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80003014:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80003018:	6794                	ld	a3,8(a5)
    8000301a:	0026d703          	lhu	a4,2(a3)
    8000301e:	8b1d                	andi	a4,a4,7
    80003020:	0706                	slli	a4,a4,0x1
    80003022:	96ba                	add	a3,a3,a4
    80003024:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80003028:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000302c:	6798                	ld	a4,8(a5)
    8000302e:	00275783          	lhu	a5,2(a4)
    80003032:	2785                	addiw	a5,a5,1
    80003034:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80003038:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000303c:	100017b7          	lui	a5,0x10001
    80003040:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80003044:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80003048:	00018917          	auipc	s2,0x18
    8000304c:	fc090913          	addi	s2,s2,-64 # 8001b008 <disk+0x128>
  while(b->disk == 1) {
    80003050:	4485                	li	s1,1
    80003052:	00b79a63          	bne	a5,a1,80003066 <virtio_disk_rw+0x1b4>
    sleep(b, &disk.vdisk_lock);
    80003056:	85ca                	mv	a1,s2
    80003058:	8556                	mv	a0,s5
    8000305a:	ed1fd0ef          	jal	ra,80000f2a <sleep>
  while(b->disk == 1) {
    8000305e:	004aa783          	lw	a5,4(s5)
    80003062:	fe978ae3          	beq	a5,s1,80003056 <virtio_disk_rw+0x1a4>
  }

  disk.info[idx[0]].b = 0;
    80003066:	f8042903          	lw	s2,-128(s0)
    8000306a:	00290713          	addi	a4,s2,2
    8000306e:	0712                	slli	a4,a4,0x4
    80003070:	00018797          	auipc	a5,0x18
    80003074:	e7078793          	addi	a5,a5,-400 # 8001aee0 <disk>
    80003078:	97ba                	add	a5,a5,a4
    8000307a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000307e:	00018997          	auipc	s3,0x18
    80003082:	e6298993          	addi	s3,s3,-414 # 8001aee0 <disk>
    80003086:	00491713          	slli	a4,s2,0x4
    8000308a:	0009b783          	ld	a5,0(s3)
    8000308e:	97ba                	add	a5,a5,a4
    80003090:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80003094:	854a                	mv	a0,s2
    80003096:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000309a:	bedff0ef          	jal	ra,80002c86 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000309e:	8885                	andi	s1,s1,1
    800030a0:	f0fd                	bnez	s1,80003086 <virtio_disk_rw+0x1d4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800030a2:	00018517          	auipc	a0,0x18
    800030a6:	f6650513          	addi	a0,a0,-154 # 8001b008 <disk+0x128>
    800030aa:	b08fe0ef          	jal	ra,800013b2 <release>
}
    800030ae:	70e6                	ld	ra,120(sp)
    800030b0:	7446                	ld	s0,112(sp)
    800030b2:	74a6                	ld	s1,104(sp)
    800030b4:	7906                	ld	s2,96(sp)
    800030b6:	69e6                	ld	s3,88(sp)
    800030b8:	6a46                	ld	s4,80(sp)
    800030ba:	6aa6                	ld	s5,72(sp)
    800030bc:	6b06                	ld	s6,64(sp)
    800030be:	7be2                	ld	s7,56(sp)
    800030c0:	7c42                	ld	s8,48(sp)
    800030c2:	7ca2                	ld	s9,40(sp)
    800030c4:	7d02                	ld	s10,32(sp)
    800030c6:	6de2                	ld	s11,24(sp)
    800030c8:	6109                	addi	sp,sp,128
    800030ca:	8082                	ret

00000000800030cc <virtio_disk_intr>:
// 这个应该是对应上面的virtio_disk_rw中的sleep
// 上面发送读取信号之后buffer结构体就去sleep了，
// 这个函数应该是完成读写操作后发送一个中断唤醒相关的进程
void
virtio_disk_intr()
{
    800030cc:	1101                	addi	sp,sp,-32
    800030ce:	ec06                	sd	ra,24(sp)
    800030d0:	e822                	sd	s0,16(sp)
    800030d2:	e426                	sd	s1,8(sp)
    800030d4:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800030d6:	00018497          	auipc	s1,0x18
    800030da:	e0a48493          	addi	s1,s1,-502 # 8001aee0 <disk>
    800030de:	00018517          	auipc	a0,0x18
    800030e2:	f2a50513          	addi	a0,a0,-214 # 8001b008 <disk+0x128>
    800030e6:	a34fe0ef          	jal	ra,8000131a <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800030ea:	10001737          	lui	a4,0x10001
    800030ee:	533c                	lw	a5,96(a4)
    800030f0:	8b8d                	andi	a5,a5,3
    800030f2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800030f4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800030f8:	689c                	ld	a5,16(s1)
    800030fa:	0204d703          	lhu	a4,32(s1)
    800030fe:	0027d783          	lhu	a5,2(a5)
    80003102:	04f70663          	beq	a4,a5,8000314e <virtio_disk_intr+0x82>
    __sync_synchronize();
    80003106:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000310a:	6898                	ld	a4,16(s1)
    8000310c:	0204d783          	lhu	a5,32(s1)
    80003110:	8b9d                	andi	a5,a5,7
    80003112:	078e                	slli	a5,a5,0x3
    80003114:	97ba                	add	a5,a5,a4
    80003116:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80003118:	00278713          	addi	a4,a5,2
    8000311c:	0712                	slli	a4,a4,0x4
    8000311e:	9726                	add	a4,a4,s1
    80003120:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80003124:	e321                	bnez	a4,80003164 <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80003126:	0789                	addi	a5,a5,2
    80003128:	0792                	slli	a5,a5,0x4
    8000312a:	97a6                	add	a5,a5,s1
    8000312c:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000312e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80003132:	e45fd0ef          	jal	ra,80000f76 <wakeup>

    disk.used_idx += 1;
    80003136:	0204d783          	lhu	a5,32(s1)
    8000313a:	2785                	addiw	a5,a5,1
    8000313c:	17c2                	slli	a5,a5,0x30
    8000313e:	93c1                	srli	a5,a5,0x30
    80003140:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80003144:	6898                	ld	a4,16(s1)
    80003146:	00275703          	lhu	a4,2(a4)
    8000314a:	faf71ee3          	bne	a4,a5,80003106 <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    8000314e:	00018517          	auipc	a0,0x18
    80003152:	eba50513          	addi	a0,a0,-326 # 8001b008 <disk+0x128>
    80003156:	a5cfe0ef          	jal	ra,800013b2 <release>
}
    8000315a:	60e2                	ld	ra,24(sp)
    8000315c:	6442                	ld	s0,16(sp)
    8000315e:	64a2                	ld	s1,8(sp)
    80003160:	6105                	addi	sp,sp,32
    80003162:	8082                	ret
      panic("virtio_disk_intr status");
    80003164:	00002517          	auipc	a0,0x2
    80003168:	75450513          	addi	a0,a0,1876 # 800058b8 <syscalls+0x4f8>
    8000316c:	d00fd0ef          	jal	ra,8000066c <panic>
	...

0000000080004000 <_trampoline>:
    80004000:	14051073          	csrw	sscratch,a0
    80004004:	02000537          	lui	a0,0x2000
    80004008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000400a:	0536                	slli	a0,a0,0xd
    8000400c:	02153423          	sd	ra,40(a0)
    80004010:	02253823          	sd	sp,48(a0)
    80004014:	02353c23          	sd	gp,56(a0)
    80004018:	04453023          	sd	tp,64(a0)
    8000401c:	04553423          	sd	t0,72(a0)
    80004020:	04653823          	sd	t1,80(a0)
    80004024:	04753c23          	sd	t2,88(a0)
    80004028:	f120                	sd	s0,96(a0)
    8000402a:	f524                	sd	s1,104(a0)
    8000402c:	fd2c                	sd	a1,120(a0)
    8000402e:	e150                	sd	a2,128(a0)
    80004030:	e554                	sd	a3,136(a0)
    80004032:	e958                	sd	a4,144(a0)
    80004034:	ed5c                	sd	a5,152(a0)
    80004036:	0b053023          	sd	a6,160(a0)
    8000403a:	0b153423          	sd	a7,168(a0)
    8000403e:	0b253823          	sd	s2,176(a0)
    80004042:	0b353c23          	sd	s3,184(a0)
    80004046:	0d453023          	sd	s4,192(a0)
    8000404a:	0d553423          	sd	s5,200(a0)
    8000404e:	0d653823          	sd	s6,208(a0)
    80004052:	0d753c23          	sd	s7,216(a0)
    80004056:	0f853023          	sd	s8,224(a0)
    8000405a:	0f953423          	sd	s9,232(a0)
    8000405e:	0fa53823          	sd	s10,240(a0)
    80004062:	0fb53c23          	sd	s11,248(a0)
    80004066:	11c53023          	sd	t3,256(a0)
    8000406a:	11d53423          	sd	t4,264(a0)
    8000406e:	11e53823          	sd	t5,272(a0)
    80004072:	11f53c23          	sd	t6,280(a0)
    80004076:	140022f3          	csrr	t0,sscratch
    8000407a:	06553823          	sd	t0,112(a0)
    8000407e:	00853103          	ld	sp,8(a0)
    80004082:	02053203          	ld	tp,32(a0)
    80004086:	01053283          	ld	t0,16(a0)
    8000408a:	00053303          	ld	t1,0(a0)
    8000408e:	12000073          	sfence.vma
    80004092:	18031073          	csrw	satp,t1
    80004096:	12000073          	sfence.vma
    8000409a:	8282                	jr	t0

000000008000409c <userret>:
    8000409c:	12000073          	sfence.vma
    800040a0:	18051073          	csrw	satp,a0
    800040a4:	12000073          	sfence.vma
    800040a8:	02000537          	lui	a0,0x2000
    800040ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800040ae:	0536                	slli	a0,a0,0xd
    800040b0:	02853083          	ld	ra,40(a0)
    800040b4:	03053103          	ld	sp,48(a0)
    800040b8:	03853183          	ld	gp,56(a0)
    800040bc:	04053203          	ld	tp,64(a0)
    800040c0:	04853283          	ld	t0,72(a0)
    800040c4:	05053303          	ld	t1,80(a0)
    800040c8:	05853383          	ld	t2,88(a0)
    800040cc:	7120                	ld	s0,96(a0)
    800040ce:	7524                	ld	s1,104(a0)
    800040d0:	7d2c                	ld	a1,120(a0)
    800040d2:	6150                	ld	a2,128(a0)
    800040d4:	6554                	ld	a3,136(a0)
    800040d6:	6958                	ld	a4,144(a0)
    800040d8:	6d5c                	ld	a5,152(a0)
    800040da:	0a053803          	ld	a6,160(a0)
    800040de:	0a853883          	ld	a7,168(a0)
    800040e2:	0b053903          	ld	s2,176(a0)
    800040e6:	0b853983          	ld	s3,184(a0)
    800040ea:	0c053a03          	ld	s4,192(a0)
    800040ee:	0c853a83          	ld	s5,200(a0)
    800040f2:	0d053b03          	ld	s6,208(a0)
    800040f6:	0d853b83          	ld	s7,216(a0)
    800040fa:	0e053c03          	ld	s8,224(a0)
    800040fe:	0e853c83          	ld	s9,232(a0)
    80004102:	0f053d03          	ld	s10,240(a0)
    80004106:	0f853d83          	ld	s11,248(a0)
    8000410a:	10053e03          	ld	t3,256(a0)
    8000410e:	10853e83          	ld	t4,264(a0)
    80004112:	11053f03          	ld	t5,272(a0)
    80004116:	11853f83          	ld	t6,280(a0)
    8000411a:	7928                	ld	a0,112(a0)
    8000411c:	10200073          	sret
	...
