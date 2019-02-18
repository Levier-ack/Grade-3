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

void semaphore_init(semaphore_t *s, int x){
    invoke_syscall(SYSCALL_SEMA_INIT,(int)s,x,IGNORE);
}

void semaphore_up(semaphore_t *s){
    invoke_syscall(SYSCALL_SEMA_UP,(int)s,IGNORE,IGNORE);
}

void semaphore_down(semaphore_t *s){
    invoke_syscall(SYSCALL_SEMA_DOWN,(int)s,IGNORE,IGNORE);
}

void condition_init(condition_t *condition){
    invoke_syscall(SYSCALL_COND_INIT,(int)condition,IGNORE,IGNORE);
}

void condition_wait(mutex_lock_t *lock, condition_t *condition){
    invoke_syscall(SYSCALL_COND_WAIT,(int)lock,(int)condition,IGNORE);
}

void condition_signal(condition_t *condition){
    invoke_syscall(SYSCALL_COND_SIGNAL,(int)condition,IGNORE,IGNORE);
}

void condition_broadcast(condition_t *condition){
    invoke_syscall(SYSCALL_COND_BROADCAST,(int)condition,IGNORE,IGNORE);
}

void barrier_init(barrier_t *barrier,int x){
    invoke_syscall(SYSCALL_BAR_INIT,(int)barrier,x,IGNORE);
}

void barrier_wait(barrier_t *barrier){
    invoke_syscall(SYSCALL_BAR_WAIT,(int)barrier,IGNORE,IGNORE);
}

pid_t sys_getpid(){
    invoke_syscall(SYSCALL_GETPID,IGNORE,IGNORE,IGNORE);
    return current_running->user_context.regs[2];
}

void sys_mkfs(){
    invoke_syscall(SYSCALL_MKFS,IGNORE,IGNORE,IGNORE);
}

void sys_statfs(){
    invoke_syscall(SYSCALL_STATFS,IGNORE,IGNORE,IGNORE);
}

void sys_cd(char *s){
    invoke_syscall(SYSCALL_CD,(int)s,IGNORE,IGNORE);
}

void sys_mkdir(char *s){
    invoke_syscall(SYSCALL_MKDIR,(int)s,IGNORE,IGNORE);
}

void sys_rmdir(char *s){
    invoke_syscall(SYSCALL_RMDIR,(int)s,IGNORE,IGNORE);
}

void sys_ls(){
    invoke_syscall(SYSCALL_LS,IGNORE,IGNORE,IGNORE);
}

void sys_touch(char *s){
    invoke_syscall(SYSCALL_TOUCH,(int)s,IGNORE,IGNORE);
}

void sys_cat(char *s){
    invoke_syscall(SYSCALL_CAT,(int)s,IGNORE,IGNORE);
}

uint32_t sys_open(char *s, int t){
    invoke_syscall(SYSCALL_OPEN,(int)s,t,IGNORE);
    return current_running->user_context.regs[2];
}

uint32_t sys_fwrite(int l, char *m, int n){
    invoke_syscall(SYSCALL_FILE_WRITE, l, (int)m, n);
    return current_running->user_context.regs[2];
}

void sys_fread(int l, char *m, int n){
    invoke_syscall(SYSCALL_FILE_READ, l, (int)m, n);
}

void sys_close(int x){
    invoke_syscall(SYSCALL_CLOSE,x,IGNORE,IGNORE);
}