#include "irq.h"
#include "time.h"
#include "sched.h"
#include "string.h"

static void irq_timer()
{
    time_elapsed += 500000;
    //get_count();// TODO clock interrupt handler.
    screen_reflush();
    do_scheduler();    
    backtouser();//get_count();// scheduler, time counter in here to do, emmmmmm maybe.
}		

void other_exception_handler()
{
    // TODO other exception handler
}

void interrupt_helper(uint32_t status, uint32_t cause)
{
		
    if((cause & 0x0000ff00) == 0x00008000)
	irq_timer();
    else
	other_exception_handler();// TODO interrupt handler.
    //get_count();// Leve3 exception Handler.
    // read CP0 register to analyze the type of interrupt.
}


