#include "sched.h"
#include "stdio.h"
#include "syscall.h"
#include "time.h"
#include "screen.h"
#include "test4.h"
#include "mm.h"

int rand()
{	
	int current_time = get_timer();
	return current_time % 100000;
}

static void disable_interrupt()
{
    uint32_t cp0_status = get_cp0_status();
    cp0_status &= 0xfffffffe;
    set_cp0_status(cp0_status);
}

static void enable_interrupt()
{
    uint32_t cp0_status = get_cp0_status();
    cp0_status |= 0x01;
    set_cp0_status(cp0_status);
}

static char read_uart_ch(void)
{
    char ch = 0;
    unsigned char *read_port = (unsigned char *)(0xbfe48000 + 0x00);
    unsigned char *stat_port = (unsigned char *)(0xbfe48000 + 0x05);

    while ((*stat_port & 0x01))
    {
        ch = *read_port;
    }
    return ch;
}

void scanf(int *mem)
{
	// debuginfo(12345);// int * temp = mem;
	int order[8] = {0};
	char ch = 0;
	int i = 0;
	int j = 0;
	// screen_cursor_x--;//
	disable_interrupt();
	while (1)
	{
		ch = read_uart_ch();//不可被打断
		if(ch == 13 || ch == 10){//回车跳出循环
			// debuginfo(1234);
			break;
		}
		
		printkf("%c",ch);
		
		if((ch != 0) && (ch != 8) && (ch != 127)){
    	    if(ch >= 97){
				order[i] = ch-87;
				i++;
			}
			else {
				order[i] = ch-48;
				i++;
			}
		}
		screen_reflush();
	}
	enable_interrupt();
	for(j = 0; j<i;j++){
		// printf("\n%x",*mem);
		*mem = 16*(*mem)+order[j];
	}
	// debuginfo(123456);
	//TODO:Use read_uart_ch() to complete scanf(), read input as a hex number.
	//Extending function parameters to (const char *fmt, ...) as printf is recommended but not required.
}

void rw_task1(void)
{
	// debuginfo(1234);
	int RW_TIMES = 2;
	int mem1, mem2 = 0;
	int curs = 0;
	int memory[RW_TIMES];
	int i = 0;
	for(i = 0; i < RW_TIMES; i++)
	{
		sys_move_cursor(0, curs+i);
		scanf(&mem1);
		// debuginfo(mem1);
		sys_move_cursor(0, curs+i);
		memory[i] = mem2 = rand();
		*(int *)mem1 = mem2;
		printf("Write: 0x%x, %d", mem1, mem2);
	}
	curs = RW_TIMES;
	for(i = 0; i < RW_TIMES; i++)
	{
		sys_move_cursor(0, curs+i);
		scanf(&mem1);
		sys_move_cursor(0, curs+i);
		memory[i+RW_TIMES] = *(int *)mem1;
		if(memory[i+RW_TIMES] == memory[i])
			printf("Read succeed: %d", memory[i+RW_TIMES]);
		else
			printf("Read error: %d", memory[i+RW_TIMES]);
	}
	while(1);
	//Only input address.
	//Achieving input r/w command is recommended but not required.
}
