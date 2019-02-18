#include "time.h"
#include "test3.h"
#include "lock.h"
#include "sched.h"
#include "stdio.h"
#include "syscall.h"

static char blank[] = {"                                                "};

static char blank1[] = {"                   "};
static char plane1[] = {"    ___         _  "};
static char plane2[] = {"| __\\_\\______/_| "};
static char plane3[] = {"<[___\\_\\_______| "};
static char plane4[] = {"|  o'o             "};

mutex_lock_t lock1;
mutex_lock_t lock2;

// pid = 2
void ready_to_exit_task()
{
    int i = 22, j = 10;
    // debuginfo(1234);
    while (1)
    {
        for (i = 60; i > 0; i--)
        {
            /* move */
            sys_move_cursor(i, j + 0);
            printf("%s", plane1);

            sys_move_cursor(i, j + 1);
            printf("%s", plane2);

            sys_move_cursor(i, j + 2);
            printf("%s", plane3);

            sys_move_cursor(i, j + 3);
            printf("%s", plane4);
        }

        sys_move_cursor(1, j + 0);
        printf("%s", blank1);

        sys_move_cursor(1, j + 1);
        printf("%s", blank1);

        sys_move_cursor(1, j + 2);
        printf("%s", blank1);

        sys_move_cursor(1, j + 3);
        printf("%s", blank1);
    }
}

// pid = 3
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
		screen_reflush();
		ch = read_uart_ch();//不可被打断
		// debuginfo(1234);
		
		if(ch == 13)//回车跳出循环
			break;
		//  debuginfo(1234);
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
	}
	enable_interrupt();
	for(j = 0; j<i;j++){
		// printf("\n%x",*mem);
		*mem = 16*(*mem)+order[j];
	}
	// debuginfo(*mem);
	//TODO:Use read_uart_ch() to complete scanf(), read input as a hex number.
	//Extending function parameters to (const char *fmt, ...) as printf is recommended but not required.
}

void wait_lock_task(void)
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


// pid = 4
void wait_exit_task()
{
    int i, print_location = 2;

    sys_move_cursor(0, print_location);
    printf("> [TASK] I want to wait task (pid=2) to exit.");

    sys_waitpid(2); //test waitpid

    sys_move_cursor(0, print_location);
    printf("> [TASK] Task (pid=2) has exited.                ");

    sys_exit(); // test exit
}