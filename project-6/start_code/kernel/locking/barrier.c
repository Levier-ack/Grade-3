#include "barrier.h"
#include "sched.h"

void do_barrier_init(barrier_t *barrier, int goal)
{
    barrier->value = goal;
    queue_init(&(barrier->bar_queue));
}

void do_barrier_wait(barrier_t *barrier)
{
    while(barrier->value > 1){
        barrier->value--;
        current_running->status = TASK_BLOCKED;
        queue_push(&(barrier->bar_queue),current_running);
        do_scheduler();
    }
    // if()
    do_unblock_all(&(barrier->bar_queue));
}