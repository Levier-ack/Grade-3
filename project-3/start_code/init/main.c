/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  * * * * * * * * * * *
 *            Copyright (C) 2018 Institute of Computing Technology, CAS
 *               Author : Han Shukai (email : hanshukai@ict.ac.cn)
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  * * * * * * * * * * *
 *         The kernel's entry, where most of the initialization work is done.
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  * * * * * * * * * * *
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this 
 * software and associated documentation files (the "Software"), to deal in the Software 
 * without restriction, including without limitation the rights to use, copy, modify, 
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit 
 * persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE. 
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  * * * * * * * * * * */

#include "irq.h"
#include "test.h"
#include "stdio.h"
#include "sched.h"
#include "screen.h"
#include "common.h"
#include "syscall.h"
#include "sem.h"
#include "barrier.h"
#include "cond.h"
#include "sync.h"
#include "lock.h"
#include "mm.h"

queue_t ready_queue;
queue_t sleep_queue;
//queue_t block_queue_sleep;

void debuginfo(uint32_t info)
{
	vt100_move_cursor(1,10);
	printk("%x\n", info);
	//printf("\n");	
	 while (1) {}
}

void save_cursor(void){
	current_running->cursor_x = screen_cursor_x;
	current_running->cursor_y = screen_cursor_y;
}

void load_cursor(void){
	screen_cursor_x = current_running->cursor_x;
	screen_cursor_y = current_running->cursor_y;
}

static void init_memory()
{
	init_phy_table();//初始化物理地址表 
	//In task1&2, page table is initialized completely with address mapping, but only virtual pages in task3.
	init_TLB();		//only used in P4 task1
	// init_swap();		//only used in P4 bonus: Page swap mechanism
}

static void init_pcb()
{
	int i;
	int j = 0;

	queue_init(&ready_queue);
	queue_init(&sleep_queue);
	
	for(i=0;i<2;i++){
		pcb[i].status = TASK_READY;
		pcb[i].user_context.regs[29] = 0xa0f00000 + i*0x10000;
		pcb[i].kernel_context.regs[29] = 0xa0f00000 + (i+16)*0x10000; 
		pcb[i].pid = i;
		pcb[i].tag = 0;//pcb[i].type = USER_PROCESS;
		pcb[i].user_context.pc = 0;
		pcb[i].kernel_context.pc = 0;
		pcb[i].cursor_x = 0;
		pcb[i].cursor_y = 0;
		pcb[i].sleep_time = 0;
		pcb[i].begin_time = 0;
		pcb[i].pcb_lock.num = 0;
		for(j = 0;j<16;j++)
			pcb[i].pcb_lock.lock[j] = NULL;
	}

		for(i=2;i<16;i++){
		pcb[i].status = TASK_READY;
		pcb[i].user_context.regs[29] = 0x00000000 + i*0x10000;
		pcb[i].kernel_context.regs[29] = 0xa0f00000 + (i+16)*0x10000; 
		pcb[i].pid = i;
		pcb[i].tag = 0;//pcb[i].type = USER_PROCESS;
		pcb[i].user_context.pc = 0;
		pcb[i].kernel_context.pc = 0;
		pcb[i].cursor_x = 0;
		pcb[i].cursor_y = 0;
		pcb[i].sleep_time = 0;
		pcb[i].begin_time = 0;
		pcb[i].pcb_lock.num = 0;
		for(j = 0;j<16;j++)
			pcb[i].pcb_lock.lock[j] = NULL;
	}

	pcb[1].user_context.regs[31] = (uint32_t)&test_shell;
	pcb[1].kernel_context.regs[31] = (uint32_t)&backtouser;
	queue_push(&ready_queue,&pcb[1]);
	pcb[1].user_context.cp0_epc = (uint32_t)&test_shell;
    pcb[1].kernel_context.cp0_status = 0x10008002;
	pcb[1].user_context.cp0_status = 0x10008002;  

	pcb[0].user_context.regs[31] = (uint32_t)&test_shell;
	pcb[0].kernel_context.regs[31] = (uint32_t)&backtouser;
	pcb[0].type = KERNEL_PROCESS;
	pcb[0].kernel_context.cp0_status = 0x10008002;
	pcb[0].user_context.cp0_status = 0x10008003;
	
	current_running = &pcb[0];
}

static void init_exception_handler()
{
}

static void init_exception()
{
	disable_interrupt();// 2. Disable all interrupt		
	memcpy((void*)0x80000180,(void*)exception_handler_entry,exception_handler_end-exception_handler_begin);
	memcpy((void*)0x80000000,(void*)TLBexception_handler_entry,TLBexception_handler_end-TLBexception_handler_begin);//memcpy((void*)0xbfc00380,(void*)exception_handler_entry,exception_handler_end-exception_handler_begin);// 3. Copy the level 2 exception handling code to 0x80000180	 
}

static void init_syscall(void)
{
	syscall[2] = do_sleep;
	syscall[3] = screen_clear;
	syscall[4] = do_ps;
	syscall[5] = do_spawn;
	syscall[6] = do_kill;
	syscall[7] = do_exit;
	syscall[8] = do_waitpid;
	syscall[9] = do_getpid;
	syscall[10] = do_block;
	syscall[11] = do_unblock_one;
	syscall[12] = do_unblock_all;
	syscall[20] = screen_write;
	syscall[22] = screen_move_cursor;
	syscall[23] = screen_reflush;
	syscall[30] = do_mutex_lock_init;
	syscall[31] = do_mutex_lock_acquire;
	syscall[32] = do_mutex_lock_release;
	syscall[33] = do_semaphore_init;
	syscall[34] = do_semaphore_up;
	syscall[35] = do_semaphore_down;
	syscall[36] = do_condition_init;
	syscall[37] = do_condition_wait;
	syscall[38] = do_condition_signal;
	// syscall[39] = do_condition_signal;
	syscall[39] = do_condition_broadcast;
	syscall[40] = do_barrier_init;
	syscall[41] = do_barrier_wait;// init system call table.
}

// jump from bootloader.
// The beginning of everything >_< ~~~~~~~~~~~~~~
void __attribute__((section(".entry_function"))) _start(void)
{
	// Close the cache, no longer refresh the cache 
	//printk("test_start\n");// when making the exception vector entry copy
	asm_start();

	// init interrupt (^_^)
	init_exception();
	printk("> [INIT] Interrupt processing initialization succeeded.\n");
	// init system call table (0_0)
	init_syscall();
	printk("> [INIT] System call initialized successfully.\n");

	init_memory();
	// init Process Control Block (-_-!)
	init_pcb();
	printk("> [lINIT] PCB initialization succeeded.\n");

	// init screen (QAQ)
	init_screen();
	printk("> [INIT] SCREEN initialization succeeded.\n");

	screen_clear(0,29);
	enable_interrupt();
	reset();//4. reset CP0_COMPARE & CP0_COUNT register// TODO Enable interrupt
	//get_count();
	while (1)
	{
		//debuginfo(current_running->pid);// (QAQQQQQQQQQQQ)
		// If you do non-preemptive scheduling, you need to use it to surrender control	
		// do_scheduler();
	};
	return;
}

void do_ps(){
    int ready_num = 1;
    pcb_t *temp = (pcb_t *)(ready_queue.head);
    vt100_move_cursor(0,screen_cursor_y);
    printkf("[PROCESS TABLE]\n");
    printkf("[0] PID : %d STATUS : RUNNING : %d\n",current_running->pid,current_running->pcb_lock.num);
    while(temp != NULL){
        printkf("[%d] PID : %d STATUS : READY : %d\n",ready_num,temp->pid,temp->pcb_lock.num);
        ready_num++;
        temp = temp->next;
    }
}

void do_spawn(int x){
    int i = 2;
	
	for (i = 2; i<16; i++){		
	    if(pcb[i].tag == 0){
            pcb[i].status = TASK_READY;
			pcb[i].user_context.regs[31] = ((task_info_t *)x)->entry_point;
			pcb[i].kernel_context.regs[31] = (uint32_t)&backtouser;
		    queue_push(&ready_queue,&pcb[i]);
            pcb[i].user_context.cp0_epc = ((task_info_t *)x)->entry_point;
            pcb[i].kernel_context.cp0_status = 0x10008002;
            pcb[i].user_context.cp0_status = 0x10008002;
			pcb[i].tag = 1;
			break;  
        }
    }
	// printk("\ntest\n");
}

void do_kill(pid_t x){
    pcb_t *temp = (pcb_t *)(ready_queue.head);
	pcb_t *unused;// printk("\ntest\n");
	
	while (temp != NULL){
		if(temp->pid == x){
			unused = queue_remove(&ready_queue,temp);
			// printk("\ntest\n");
			break;
		}
		temp = temp->next;
	}
	// printk("\ntest\n");
	pcb[x].status = TASK_EXITED;
	pcb[x].user_context.regs[29] = 0x00000000 + (pcb[x].pid)*0x10000;
	pcb[x].kernel_context.regs[29] = 0xa0f00000 + (pcb[x].pid+16)*0x10000;
	pcb[x].tag = 0;
	pcb[x].user_context.pc = 0;
	pcb[x].kernel_context.pc = 0;
	pcb[x].cursor_x = 0;
	pcb[x].cursor_y = 0;
	pcb[x].sleep_time = 0;
	pcb[x].begin_time = 0;
	do_unblock_all(&(pcb[x].block_queue));
	while(pcb[x].pcb_lock.num != 0){
		pcb[x].pcb_lock.lock[(pcb[x].pcb_lock.num)-1]->status = UNLOCKED;
		pcb[x].pcb_lock.lock[(pcb[x].pcb_lock.num)-1]->lock_pid = 0;
		
		while(!queue_is_empty(&(pcb[x].pcb_lock.lock[(pcb[x].pcb_lock.num)-1]->lock_queue))){
        	do_unblock_one(&(pcb[x].pcb_lock.lock[(pcb[x].pcb_lock.num)-1]->lock_queue));
    	}
		
		pcb[x].pcb_lock.lock[(pcb[x].pcb_lock.num)-1] = NULL;
		pcb[x].pcb_lock.num--;
	}
	do_scheduler();// do_scheduler();
}

void do_exit(){
	current_running->status = TASK_EXITED;
	current_running->user_context.regs[29] = 0x00000000 + (current_running->pid)*0x10000;
	current_running->kernel_context.regs[29] = 0xa0f00000 + (current_running->pid+16)*0x10000;
	current_running->tag = 0;
	current_running->user_context.pc = 0;
	current_running->kernel_context.pc = 0;
	current_running->cursor_x = 0;
	current_running->cursor_y = 0;
	current_running->sleep_time = 0;
	current_running->begin_time = 0;
	do_unblock_all(&(current_running->block_queue));
	
	while(current_running->pcb_lock.num != 0){
		do_mutex_lock_release(current_running->pcb_lock.lock[(current_running->pcb_lock.num)-1]);
		current_running->pcb_lock.lock[(current_running->pcb_lock.num)] = NULL;
		// current_running->pcb_lock.num--;
	}
	do_scheduler();
}

void do_waitpid(pid_t x){
    current_running->status = TASK_BLOCKED;
    queue_push(&(pcb[x].block_queue),current_running);
    do_scheduler();
}


