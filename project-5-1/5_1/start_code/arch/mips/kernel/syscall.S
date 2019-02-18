#include "asm.h"

LEAF(invoke_syscall)		
	addu v0,zero,a0
	addu a0,zero,a1
	#  jal  get_count	
	addu a1,zero,a2
	addu a2,zero,a3    
	# //jal syscall[k0]// TODO syscall entry
        syscall
	nop
	jr ra
	nop
END(invoke_syscall)
