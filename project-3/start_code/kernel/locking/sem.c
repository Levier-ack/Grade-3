#include "sem.h"
#include "stdio.h"
#include "sched.h"

void do_semaphore_init(semaphore_t *s, int val)
{
    s->sema = val;
    queue_init(&(s->sema_queue));
}

void do_semaphore_up(semaphore_t *s)
{
    pcb_t *temp;
    s->sema++;
    if(s->sema >= 0 && !queue_is_empty(&(s->sema_queue))){
        temp = queue_dequeue(&(s->sema_queue));
        temp->status = TASK_READY;
        queue_push(&ready_queue,temp);
    }
}

void do_semaphore_down(semaphore_t *s)
{
    pcb_t *temp;
    s->sema--;
    if(s->sema < 0){
        current_running->status = TASK_BLOCKED;
        queue_push(&(s->sema_queue),current_running);
        do_scheduler();
    }
}