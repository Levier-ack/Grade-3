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
}

void do_mutex_lock_acquire(mutex_lock_t *lock)
{
    while (lock->status == LOCKED){
        do_block(&block_queue);
        // printk("test\n");     
	    do_scheduler();
        //backtouser();
    }
    lock->status = LOCKED;
}

void do_mutex_lock_release(mutex_lock_t *lock)
{
    lock->status = UNLOCKED;
    // if(!queue_is_empty(&block_queue))
    //     do_unblock_one(&block_queue);
    // else    
    //     queue_dequeue(&ready_queue);
    while(!queue_is_empty(&block_queue)){
        do_unblock_one(&block_queue);
    }
}
// void do_mutex_lock_release(mutex_lock_t *lock)
// {
//     lock->status = UNLOCKED;
//     if(!queue_is_empty(&block_queue))
//         do_unblock_one(&block_queue);
// }
