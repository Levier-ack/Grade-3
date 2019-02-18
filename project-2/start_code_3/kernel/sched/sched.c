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

static void check_sleeping()
{
}

void scheduler(void)
{
    int i = 1;
    //debuginfo(current_running->pid);//
    if(current_running->status != TASK_BLOCKED){
    	queue_push(&ready_queue, current_running);
    	current_running->status = TASK_READY;
    }
    if (!queue_is_empty(&ready_queue)) {
	current_running = queue_dequeue(&ready_queue);
    	current_running->status = TASK_RUNNING;
    }

    //printk("%d\n",current_running->pid);

    //debuginfo(current_running->pid);//
    // TODO schedule
    // Modify the current_running pointer.
}

void do_sleep(uint32_t sleep_time)
{
    // TODO sleep(seconds)
}

void do_block(queue_t *queue)
{
    queue_push(queue,current_running);
    current_running->status = TASK_BLOCKED;// block the current_running task into the queue
}

void do_unblock_one(queue_t *queue)
{
    pcb_t *temp;
    if(!queue_is_empty(queue))
	temp = queue_dequeue(queue);
    temp->status = TASK_READY;
    queue_push(&ready_queue, temp);
    // unblock the head task from the queue
}

void do_unblock_all(queue_t *queue)
{
    // unblock all task in the queue
}
