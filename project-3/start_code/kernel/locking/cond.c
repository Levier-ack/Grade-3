#include "cond.h"
#include "lock.h"
#include "sched.h"

void do_condition_init(condition_t *condition)
{
    condition->cond_num = 0;
    queue_init(&(condition->cond_queue));
}

void do_condition_wait(mutex_lock_t *lock, condition_t *condition)
{
    condition->cond_num++;
    current_running->status = TASK_BLOCKED;
    queue_push(&(condition->cond_queue),current_running);
    // debuginfo(1234);
    do_mutex_lock_release(lock);
    do_scheduler();
    do_mutex_lock_acquire(lock);
}

void do_condition_signal(condition_t *condition)
{
    pcb_t *temp;
    if(condition->cond_num > 0 && !queue_is_empty(&(condition->cond_queue))){
        temp = queue_dequeue(&(condition->cond_queue));
        temp->status = TASK_READY;
        queue_push(&ready_queue,temp);
        condition->cond_num--; 
        // do_scheduler();
    }
}

void do_condition_broadcast(condition_t *condition)
{
    pcb_t *temp;
    while(condition->cond_num > 0 && !queue_is_empty(&(condition->cond_queue))){
        temp = queue_dequeue(&(condition->cond_queue));
        temp->status = TASK_READY;
        queue_push(&ready_queue,temp);
        condition->cond_num--;
    }
    // do_scheduler();
}