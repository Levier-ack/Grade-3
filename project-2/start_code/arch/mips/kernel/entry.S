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

.macro SAVE_CONTEXT offset
	addi	k0,zero,current_running
	addiu	k0,k0,-128
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
// TODO save context
.endm

.macro RESTORE_CONTEXT offset	
	addi    k0,zero,current_running
	addiu	k0,k0,-128
	lw	k1,-188(k0)
	beq	k1,zero,first_pcb
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

first_pcb:
	lw	ra,124(k0)    
// TODO restore context
.endm

NESTED(do_scheduler, 0, ra)
    SAVE_CONTEXT(KERNEL)
    jal     scheduler
    RESTORE_CONTEXT(KERNEL)
    jr      ra
END(do_scheduler)

.global exception_handler_begin
.global exception_handler_end

NESTED(exception_handler_entry, 0, sp)   
exception_handler_begin:
    // TODO close interrupt
    // jmp exception_handler[i] which decided by CP0_CAUSE
    // Leve2 exception Handler.
exception_handler_end:
END(exception_handler_entry)

NESTED(handle_int, 0, sp)
    // interrupt handler
    // Leve3 exception Handler.
END(handle_int)

NESTED(handle_syscall, 0, sp)
    // system call handler
END(handle_syscall)

NESTED(handle_other, 0, sp)
    // other exception handler
END(handle_other)

