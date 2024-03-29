#include "asm.h"

.equ    KERNEL, 0
.equ    USER,   156

.macro STI
.endm

.macro CLI
.endm

LEAF(asm_start)
    mtc0    zero, CP0_STATUS
    mtc0    zero, CP0_WATCHLO
    mtc0    zero, CP0_WATCHHI

    mfc0    t0, CP0_CONFIG
    and     t0, ~0x7
    ori     t0, 0x2
    mtc0    t0, CP0_CONFIG
    
    jr  ra
END(asm_start)

.macro SAVE_CONTEXT_KERNEL offset
   lw	k0, current_running	
	sw	zero,0(k0)
	sw	AT,4(k0)
	sw	v0,8(k0)
	sw	v1,12(k0)
	sw	a0,16(k0)
	sw	a1,20(k0)
	sw	a2,24(k0)
	sw	a3,28(k0)
	sw	t0,32(k0)
	sw	t1,36(k0)
	sw	t2,40(k0)
	sw	t3,44(k0)
	sw	t4,48(k0)
	sw	t5,52(k0)
	sw	t6,56(k0)
	sw	t7,60(k0)
	sw	t8,96(k0)
	sw	t9,100(k0)
	sw	s0,64(k0)
	sw	s1,68(k0)
	sw	s2,72(k0)
	sw	s3,76(k0)
	sw	s4,80(k0)
	sw	s5,84(k0)
	sw	s6,88(k0)
	sw	s7,92(k0)
	sw	fp,120(k0)
	sw	gp,112(k0)
	sw	sp,116(k0)
	sw	ra,124(k0)
	mfc0	k1,CP0_STATUS
	sw	k1,128(k0)
	# mfc0	k1,CP0_BADVADDR
	# sw	k1,140(k0)
	mfc0	k1,CP0_EPC
	sw	k1,148(k0)
	# jal save_cursor
.endm

.macro RESTORE_CONTEXT_KERNEL offset   	
	lw      k0, current_running
	lw	zero,0(k0)
	lw	AT,4(k0)
	lw	v0,8(k0)
	lw	v1,12(k0)
	lw	a0,16(k0)
	lw	a1,20(k0)
	lw	a2,24(k0)
	lw	a3,28(k0)
	lw	t0,32(k0)
	lw	t1,36(k0)
	lw	t2,40(k0)
	lw	t3,44(k0)
	lw	t4,48(k0)
	lw	t5,52(k0)
	lw	t6,56(k0)
	lw	t7,60(k0)
	lw	t8,96(k0)
	lw	t9,100(k0)
	lw	s0,64(k0)
	lw	s1,68(k0)
	lw	s2,72(k0)
	lw	s3,76(k0)
	lw	s4,80(k0)
	lw	s5,84(k0)
	lw	s6,88(k0)
	lw	s7,92(k0)
	lw	fp,120(k0)
	lw	gp,112(k0)
	lw	sp,116(k0)
	lw	ra,124(k0)
	lw	k1,128(k0)
	mtc0	k1,CP0_STATUS
	# lw	k1,140(k0)
	# mtc0	k1,CP0_BADVADDR
	lw	k1,148(k0)
	mtc0	k1,CP0_EPC
	# jal load_cursor
.endm

.macro SAVE_CONTEXT_USER offset
    lw  k0,current_running
    sw	zero,156(k0)
	sw	AT,160(k0)
	sw	v0,164(k0)
	sw	v1,168(k0)
	sw	a0,172(k0)
	sw	a1,176(k0)
	sw	a2,180(k0)
	sw	a3,184(k0)
	sw	t0,188(k0)
	sw	t1,192(k0)
	sw	t2,196(k0)
	sw	t3,200(k0)
	sw	t4,204(k0)
	sw	t5,208(k0)
	sw	t6,212(k0)
	sw	t7,216(k0)
	sw	t8,252(k0)
	sw	t9,256(k0)
	sw	s0,220(k0)
	sw	s1,224(k0)
	sw	s2,228(k0)
	sw	s3,232(k0)
	sw	s4,236(k0)
	sw	s5,240(k0)
	sw	s6,244(k0)
	sw	s7,248(k0)
	sw	fp,276(k0)
	sw	gp,268(k0)
	sw	sp,272(k0)
	sw	ra,280(k0)
	mfc0	k1,CP0_STATUS
	sw	k1,284(k0)
	# mfc0	k1,CP0_BADVADDR
	# sw	k1,296(k0)
	mfc0	k1,CP0_EPC
	sw	k1,304(k0)
	# jal save_cursor
.endm

.macro RESTORE_CONTEXT_USER offset		
	lw  k0,current_running
	lw	zero,156(k0)
	lw	AT,160(k0)
	lw	v0,164(k0)
	lw	v1,168(k0)
	lw	a0,172(k0)
	lw	a1,176(k0)
	lw	a2,180(k0)
	lw	a3,184(k0)
	lw	t0,188(k0)
	lw	t1,192(k0)
	lw	t2,196(k0)
	lw	t3,200(k0)
	lw	t4,204(k0)
	lw	t5,208(k0)
	lw	t6,212(k0)
	lw	t7,216(k0)
	lw	t8,252(k0)
	lw	t9,256(k0)
	lw	s0,220(k0)
	lw	s1,224(k0)
	lw	s2,228(k0)
	lw	s3,232(k0)
	lw	s4,236(k0)
	lw	s5,240(k0)
	lw	s6,244(k0)
	lw	s7,248(k0)
	lw	fp,276(k0)
	lw	gp,268(k0)
	lw	sp,272(k0)
	lw	ra,280(k0)
	lw	k1,284(k0)
	mtc0	k1,CP0_STATUS
	# lw	k1,296(k0)
	# mtc0	k1,CP0_BADVADDR
	lw	k1,304(k0)
	mtc0	k1,CP0_EPC
	# jal save_cursor
.endm


NESTED(do_scheduler, 0, ra)
    SAVE_CONTEXT_KERNEL(KERNEL)
    jal     scheduler
    RESTORE_CONTEXT_KERNEL(KERNEL)
    jr      ra
END(do_scheduler)

.global TLBexception_handler_begin
.global TLBexception_handler_end

NESTED(TLBexception_handler_entry, 0, sp)
TLBexception_handler_begin:
	mfc0    k0,CP0_STATUS
    lui     k1,0xffff
    ori     k1,k1,0xfffe
    and     k0,k1,k0
    mtc0    k0,CP0_STATUS
	# jal get_count
    SAVE_CONTEXT_USER(USER)
	lw		sp,116(k0)
TLB_handler:# // jmp exception_handler[i] which decided by CP0_CAUSE
    mfc0    k0,CP0_CAUSE
    andi    k0,k0,0x007c
    srl     k0,k0,0x2
	li		k1,0x3
	beq		k1,k0,1f
	nop
	li		k1,0x2
	beq		k1,k0,1f
	nop
	j		handle_other
1:
	j 		do_TLB_Refill
	nop 
	# //TODO: TLB exception entry
	# //jmp exception_handler[i] which decided by CP0_CAUSE
TLBexception_handler_end:
	nop
END(TLBexception_handler_entry)

.global exception_handler_begin
.global exception_handler_end

NESTED(exception_handler_entry, 0, sp)   
exception_handler_begin:
    mfc0    k0,CP0_STATUS
    lui     k1,0xffff
    ori     k1,k1,0xfffe
    and     k0,k1,k0
    mtc0    k0,CP0_STATUS
	# jal get_count
    SAVE_CONTEXT_USER(USER)
	lw		sp,116(k0)
    # // jmp exception_handler[i] which decided by CP0_CAUSE
    mfc0    k0,CP0_CAUSE
    andi    k0,k0,0x007c
    srl     k0,k0,0x2
    beq     k0,zero,1f
	nop
	li 		k1,0x8
	beq		k0,k1,2f
	nop
	j       TLB_handler
	nop
1:
	j 		handle_int
    nop
2:
    j       handle_syscall// TODO close interrupt
	nop
exception_handler_end:
    nop
END(exception_handler_entry)

NESTED(disable_interrupt,0,sp)
    mfc0    k0,CP0_STATUS
    lui	    k0,0x1000
    ori	    k0,k0,0x8000
    mtc0    k0,CP0_STATUS
    jr      ra
END(disable_interrupt)

NESTED(enable_interrupt,0,sp)
    mfc0    k0,CP0_STATUS
    ori     k0,k0,0x0001
    mtc0    k0,CP0_STATUS
    jr	    ra
END(enable_interrupt)

NESTED(reset,0,sp)
    li	    k0,0
    mtc0    k0,CP0_COUNT
    li      k0, 500000
    mtc0    k0,CP0_COMPARE
    jr      ra
END(reset)//reset CP0_COMPARE & CP0_COUNT

NESTED(handle_int, 0, sp)
    mfc0    k0,CP0_STATUS
    addu    a0,zero,k0
    mfc0    k0,CP0_CAUSE
    addu    a1,k0,zero
	addiu   sp,sp,-8
    jal     interrupt_helper
	addiu   sp,sp,8
    // interrupt handler
    // Leve3 exception Handler.
END(handle_int)

NESTED(backtouser, 0, sp)
    li	    k0,0
    mtc0    k0,CP0_COUNT
    li      k0, 500000
    mtc0    k0,CP0_COMPARE
    mfc0    k0,CP0_STATUS
    RESTORE_CONTEXT_USER(USER)
    mfc0    k0,CP0_STATUS
    ori     k0,k0,0x0001
    mtc0    k0,CP0_STATUS
    mfc0    k0,CP0_EPC
    mfc0    k0,CP0_CAUSE
    eret
END(backtouser)

NESTED(handle_syscall, 0, sp)    
    # mtc0 ra,CP0_EPC
	
    addu a3,zero,a2
    addu a2,a1,zero
	addu a1,a0,zero
	addu a0,v0,zero
	addiu sp,sp,-16
	jal system_call_helper// system call handler
	addiu sp,sp,16
	# li	    k0,0
    # mtc0    k0,CP0_COUNT
	lw k0,current_running
	sw v0,164(k0)
    # li      k0, 4000000
    # mtc0    k0,CP0_COMPARE
    RESTORE_CONTEXT_USER(USER)
    mfc0    k0,CP0_STATUS
    ori     k0,k0,0x0001
    mtc0    k0,CP0_STATUS
	# mtc0 	ra,CP0_EPC
    mfc0    k0,CP0_EPC
	addiu   k0,k0,0x4
	mtc0    k0,CP0_EPC
	#  jal     get_count
    # mfc0    k0,CP0_CAUSE
    eret
END(handle_syscall)

NESTED(handle_TLB, 0, sp)
    # mfc0    a0,CP0_E
	# jal     debuginfo
	RESTORE_CONTEXT_USER(USER)
    mfc0    k0,CP0_STATUS
    ori     k0,k0,0x0001
    mtc0    k0,CP0_STATUS
	# // other exception handler
	# jal 	get_count
	eret
END(handle_TLB)

NESTED(handle_other, 0, sp)
    // other exception handler
	jal 	get_count
END(handle_other)

NESTED(get_count,0,sp)
    mfc0    k0,CP0_STATUS
    lui     k1,0xffff
    ori     k1,k1,0xfffe
    and     k0,k1,k0
    mtc0    k0,CP0_STATUS
	mfc0	k0,CP0_BADVADDR
	# lw	k0,current_running
	# lw      k1,304(k0)
    addu         a0,k0,zero   
    jal         debuginfo
    jr          ra
END(get_count)

NESTED(init_TLB_asm,0,sp)
	mtc0 a1,CP0_ENTRYHI
	nop
	mtc0 a2,CP0_ENTRYLO0
	nop
	mtc0 a3,CP0_ENTRYLO1
	nop
	mtc0 zero,CP0_PAGEMASK
	nop
	mtc0 a0,CP0_INDEX
	nop
	tlbwi
    jr          ra
END(init_TLB_asm)

NESTED(set_TLBrefill,0,sp)
	andi a2,a2,0xff
	or   k1,a0,a2
	mtc0 k1,CP0_ENTRYHI
	nop
	# mfc0 a0,CP0_ENTRYHI
	# nop
	# j debuginfo
	addu k0,a1,zero
	addiu k0,k0,0x40
	li   k1,0x10|0x4|0x2|0x0
	or   k1,k1,a1
	mtc0 k1,CP0_ENTRYLO0
	nop
	# mfc0 a0,CP0_ENTRYLO0
	# j debughit
	or   k1,k1,k0
	mtc0 k1,CP0_ENTRYLO1
	nop
	mtc0 zero,CP0_INDEX
	nop
	# mfc0 a0,CP0_ENTRYLO1
	# j debuginfo
	li	 k1,0x0
	mtc0 k1,CP0_PAGEMASK
	nop
	tlbwr
    jr          ra
END(set_TLBrefill)

NESTED(set_TLBinvalid,0,sp)
	andi a2,a2,0xff
	or   k1,a0,a2
	mtc0 k1,CP0_ENTRYHI
	nop
	addu k0,a1,zero
	addiu k0,k0,0x40
	li   k1,0x10|0x4|0x2|0x0
	or   k1,k1,a1
	mtc0 k1,CP0_ENTRYLO0
	nop
	# mfc0 a0,CP0_ENTRYLO0
	# j debuginfo
	or  k1,k1,k0
	mtc0 k1,CP0_ENTRYLO1
	nop
	# mfc0 a0,CP0_ENTRYLO1
	# j debuginfo
	li	 k1,0x0
	mtc0 k1,CP0_PAGEMASK
	nop
	mtc0 zero,CP0_INDEX
	nop
	# mfc0 a0,CP0_RANDOM
	# nop
	# j debughit
	tlbwi
    jr          ra
END(set_TLBinvalid)

NESTED(TLBP,0,sp)
	andi a1,a1,0xff
	or   k1,a1,a0
	# li   k1,(a0<<13)|(a1 & 0xff)
	mtc0 k1,CP0_ENTRYHI
	nop
	tlbp
	nop
	mfc0 k0,CP0_INDEX
	nop
	li 	 k1,0x80000000
	and  k0,k0,k1
	# addu a0,k0,zero
	# j debuginfo
	beq	 k0,k1,1f
	nop
	jal 	TLBinvalid
	nop
	j       2f
	nop
1:
	jal 	TLBrefill
    nop
	# mfc0 a0,CP0_INDEX
2:	# j debuginfo
	j		handle_TLB	
END(TLBP)

