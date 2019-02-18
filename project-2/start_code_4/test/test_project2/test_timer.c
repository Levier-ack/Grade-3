#include "time.h"
#include "test2.h"
#include "sched.h"
#include "stdio.h"
#include "syscall.h"

void timer_task(void)
{
    int count = 0;
    int print_location = 6;
    uint32_t time = 0;
    while (1)
    {
        /* call get_timer() to get time */
        time = get_timer();
        sys_move_cursor(1, print_location);
        printf("> [TASK] This is a thread to timing! (%u/%u seconds).\n", time, time_elapsed);
    }
}
