#include "lock.h"
#include "sched.h"
#include "common.h"
#include "screen.h"
#include "syscall.h"

void system_call_helper(int fn, int arg1, int arg2, int arg3)
{
    syscall[fn](arg1,arg2,arg3);
    // syscall[fn](arg1, arg2, arg3)
}

void sys_sleep(uint32_t time)
{
    invoke_syscall(SYSCALL_SLEEP, time, IGNORE, IGNORE);
}

void sys_block(queue_t *queue)
{
    invoke_syscall(SYSCALL_BLOCK, (int)queue, IGNORE, IGNORE);
    // printk("test1\n");
}

void sys_unblock_one(queue_t *queue)
{
    invoke_syscall(SYSCALL_UNBLOCK_ONE, (int)queue, IGNORE, IGNORE);
}

void sys_unblock_all(queue_t *queue)
{
    invoke_syscall(SYSCALL_UNBLOCK_ALL, (int)queue, IGNORE, IGNORE);
}

void sys_write(char *buff)
{
    invoke_syscall(SYSCALL_WRITE, (int)buff, IGNORE, IGNORE);
}

void sys_reflush()
{
    invoke_syscall(SYSCALL_REFLUSH, IGNORE, IGNORE, IGNORE);
}

void sys_move_cursor(int x, int y)
{
    invoke_syscall(SYSCALL_CURSOR, x, y, IGNORE);
}

void mutex_lock_init(mutex_lock_t *lock)
{
    invoke_syscall(SYSCALL_MUTEX_LOCK_INIT, (int)lock, IGNORE, IGNORE);
}

void mutex_lock_acquire(mutex_lock_t *lock)
{
    // printk("test1\n");
    invoke_syscall(SYSCALL_MUTEX_LOCK_ACQUIRE, (int)lock, IGNORE, IGNORE);
}

void mutex_lock_release(mutex_lock_t *lock)
{
    invoke_syscall(SYSCALL_MUTEX_LOCK_RELEASE, (int)lock, IGNORE, IGNORE);
}

void sys_screen_clear(int x, int y)
{
    invoke_syscall(SYSCALL_CLEAR, x, y, IGNORE);
}

void sys_ps()
{
    invoke_syscall(SYSCALL_PS,IGNORE,IGNORE,IGNORE);
}

void sys_spawn(task_info_t *x)
{
    invoke_syscall(SYSCALL_SPAWN,(int)x,IGNORE,IGNORE);
}

void sys_kill(pid_t x)
{
    invoke_syscall(SYSCALL_KILL,x,IGNORE,IGNORE);
}

void sys_exit()
{
    invoke_syscall(SYSCALL_EXIT,IGNORE,IGNORE,IGNORE);
}

void sys_waitpid(pid_t x)
{
    invoke_syscall(SYSCALL_WAIT,x,IGNORE,IGNORE);
}

pid_t sys_getpid(){
    invoke_syscall(SYSCALL_GETPID,IGNORE,IGNORE,IGNORE);
    return current_running->user_context.regs[2];
}

void sys_init_mac(){
    invoke_syscall(SYSCALL_INIT_MAC,IGNORE,IGNORE,IGNORE);
}

uint32_t sys_net_recv(uint32_t rd,uint32_t rd_phy,uint32_t daddr){
    invoke_syscall(SYSCALL_NET_RECV,rd,rd_phy,daddr);
    return current_running->user_context.regs[2];
}

void sys_net_send(uint32_t td,uint32_t td_phy){
    invoke_syscall(SYSCALL_NET_SEND,td,td_phy,IGNORE);
}
