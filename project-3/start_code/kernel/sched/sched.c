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
pid_t lock_id = 1;

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

            if(get_timer()-pcb_temp_2->begin_time >= pcb_temp_2->sleep_time){
                pcb_temp_1 = (pcb_t *)queue_remove(&sleep_queue,pcb_temp_2);
                pcb_temp_2->status = TASK_READY;
                queue_push(&ready_queue,pcb_temp_2);
                pcb_temp_3 = pcb_temp_1;
            }
            else{
                pcb_temp_3 = pcb_temp_3->next;
            }
        }
    }
    // vt100_move_cursor(1,7);
    // printk("%d",queue_count(&ready_queue));


    if((current_running->status != TASK_BLOCKED)&&(current_running->status != TASK_SLEEPING)&&(current_running->status != TASK_EXITED)){
    	queue_push(&ready_queue, current_running);
    	current_running->status = TASK_READY;
    }
    // vt100_move_cursor(1,8);
    // printk("%d",current_running->pid);
    if (!queue_is_empty(&ready_queue)) {
    	save_cursor();
        current_running = queue_dequeue(&ready_queue);
        while(current_running->status != TASK_READY){
            current_running = queue_dequeue(&ready_queue);
        }
        load_cursor();
        current_running->status = TASK_RUNNING;
    }
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
//    printk("\n\n\n%d",queue_count(queue));// block the current_running task into the queue
}

void do_unblock_one(queue_t *queue)
{
    pcb_t *temp;
    
	temp = queue_dequeue(queue);
    temp->status = TASK_READY;
    queue_push(&ready_queue, temp);
    // unblock the head task from the queue
}

void do_unblock_all(queue_t *queue)
{
    pcb_t *temp;
    temp = (pcb_t *)(queue->head);
    // vt100_move_cursor(0,2);
    // printk("%d",queue_count(queue));
    while (temp != NULL){
        temp = queue_dequeue(queue);
        temp->status = TASK_READY;
        queue_push(&ready_queue,temp);
        temp = (pcb_t *)(queue->head);// unblock all task in the queue
    }
}

pid_t do_getpid(){
    return current_running->pid;
}