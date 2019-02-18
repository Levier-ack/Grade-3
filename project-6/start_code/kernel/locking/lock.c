#include "lock.h"
#include "sched.h"
#include "syscall.h"

void spin_lock_init(spin_lock_t *lock)
{
    lock->status = UNLOCKED;
}

void spin_lock_acquire(spin_lock_t *lock)
{
    while (LOCKED == lock->status)
    {
    };
    lock->status = LOCKED;
}

void spin_lock_release(spin_lock_t *lock)
{
    lock->status = UNLOCKED;
}

void do_mutex_lock_init(mutex_lock_t *lock)
{
    lock->status = UNLOCKED;
    lock->lock_pid = 0;
    queue_init(&(lock->lock_queue));
    lock->lock_id = lock_id;
    lock_id++;
}

void do_mutex_lock_acquire(mutex_lock_t *lock)
{
    while (lock->status == LOCKED){
        // printk("\n\n%d",current_running->pid);
        do_block(&(lock->lock_queue));  
        // printk("\n\n\n%d",queue_count(&(lock->lock_queue)));  
	    do_scheduler();
    }
    // printk("\n\ntest\n");
    lock->status = LOCKED;
    lock->lock_pid = current_running->pid;
    current_running->pcb_lock.lock[current_running->pcb_lock.num] = lock;
    current_running->pcb_lock.num++;
}

void do_mutex_lock_release(mutex_lock_t *lock)
{
    
    int i,j;
    lock->status = UNLOCKED;
    for(i = 0;i < current_running->pcb_lock.num;i++){
        if(current_running->pcb_lock.lock[i] == lock)
        {
            for(j = i;j < current_running->pcb_lock.num;j++)
                current_running->pcb_lock.lock[j] = current_running->pcb_lock.lock[j+1];
            // current_running->pcb_lock.num--;
        }     
    }
    lock->lock_pid = 0;
    current_running->pcb_lock.num--;

    // printk("\n\n\n%d",current_running->pcb_lock.num);
    while(!queue_is_empty(&(lock->lock_queue))){
        // printk("\n\ntest");
        do_unblock_one(&(lock->lock_queue));
        // printk("\n\n%d",queue_count(&ready_queue));
    }
}

