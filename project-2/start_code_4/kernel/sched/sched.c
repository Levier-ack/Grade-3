#include "lock.h"
#include "time.h"
#include "stdio.h"
#include "sched.h"
#include "queue.h"
#include "screen.h"

pcb_t pcb[NUM_MAX_TASK];

/* current running task PCB */
pcb_t *current_running;

/* global process id */
pid_t process_id = 1;

void scheduler(void)
{
    pcb_t *pcb_temp_1,*pcb_temp_2,*pcb_temp_3;
    
    pcb_temp_1 = NULL;
    pcb_temp_2 = NULL;
    pcb_temp_3 = NULL;
    if(!queue_is_empty(&sleep_queue)){
        pcb_temp_3 = (pcb_t *)(sleep_queue.head);
        while(pcb_temp_3 != NULL){//遍历sleep_queue队列
            pcb_temp_2 = pcb_temp_3;
            // vt100_move_cursor(1,3);
            // printk("%d",pcb_temp_2->sleep_time);
            // vt100_move_cursor(1,2);
            // printk("%d",get_timer());
            if(get_timer()-pcb_temp_2->begin_time >= pcb_temp_2->sleep_time){
                pcb_temp_1 = (pcb_t *)queue_remove(&sleep_queue,pcb_temp_2);
                pcb_temp_2->status = TASK_READY;
                queue_push(&ready_queue,pcb_temp_2);
                pcb_temp_3 = pcb_temp_1;
            }
            else{
                // vt100_move_cursor(1,3);
                // printk("%d",pcb_temp_2->sleeped_time);
                pcb_temp_3 = pcb_temp_3->next;
            }
        }
    }
    // vt100_move_cursor(1,7);
    // printk("%d",queue_count(&ready_queue));

    if((current_running->status != TASK_BLOCKED)&&(current_running->status != TASK_SLEEPING)){
    	queue_push(&ready_queue, current_running);
    	current_running->status = TASK_READY;
    }
    // vt100_move_cursor(1,8);
    // printk("%d",current_running->pid);
    if (!queue_is_empty(&ready_queue)) {
    	save_cursor();
        current_running = queue_dequeue(&ready_queue);
        load_cursor();
        current_running->status = TASK_RUNNING;
    }
    //debuginfo(current_running->pid);//
    // TODO schedule
    // Modify the current_running pointer.
}

void do_sleep(uint32_t sleep_time)
{	
	current_running->status = TASK_SLEEPING;
    queue_push(&sleep_queue,current_running); 
    current_running->sleep_time = sleep_time;
    current_running->begin_time = get_timer();
    do_scheduler();
}

void do_block(queue_t *queue)
{
    current_running->status = TASK_BLOCKED;
    queue_push(queue,current_running);
   // block the current_running task into the queue
}

void do_unblock_one(queue_t *queue)
{
    pcb_t *temp;
    //  if(!queue_is_empty(queue))
	temp = queue_dequeue(queue);
    temp->status = TASK_READY;
    queue_push(&ready_queue, temp);
    // unblock the head task from the queue
}

void do_unblock_all(queue_t *queue)
{
    // unblock all task in the queue
}
