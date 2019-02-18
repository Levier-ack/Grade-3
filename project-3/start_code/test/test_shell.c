/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  * * * * * * * * * * *
 *            Copyright (C) 2018 Institute of Computing Technology, CAS
 *               Author : Han Shukai (email : hanshukai@ict.ac.cn)
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  * * * * * * * * * * *
 *                  The shell acts as a task running in user mode. 
 *       The main function is to make system calls through the user's output.
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  * * * * * * * * * * *
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this 
 * software and associated documentation files (the "Software"), to deal in the Software 
 * without restriction, including without limitation the rights to use, copy, modify, 
 * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit 
 * persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *  * * * * * * * * * * */

#include "test.h"
#include "stdio.h"
#include "screen.h"
#include "syscall.h"

uint32_t get_cp0_status(void){
	uint32_t status;	
	asm(
		"mfc0 %0,$12\t\n"
		: "=r"(status)	
	);
	return status;
}

uint32_t set_cp0_status(uint32_t temp){
	asm(
		"mtc0 %0,$12\t\n"
		:
        : "r"(temp)	
	);
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

void process_exec (char x, char y){
    if(y == '\0'){
        if(x <= '9' && x >= '0'){
            // printf("\n%d\n",(int)x-48);
            sys_spawn(test_tasks[(int)x-48]);
        }
        else
            printf("\nmatch process failed, please input again\n");
    }
    else if(x == '1'){
        if(y <= '4' && y>= '0'){
            // printf("\n%d\n",(int)(10+y));
            sys_spawn(test_tasks[(int)y-48+10]);
        }
        else 
            printf("\nmatch process failed, please input again\n");
    }
    else
        printf("\nmatch process failed, please input again\n");  

}

void process_kill (char x, char y){
    if(y == '\0'){
        if(x <= '9' && x>= '0'){
        //    printf("\n%d\n",(int)x); 
            sys_kill((int)x-48);
        }
        else
            printf("\nmatch process failed, please input again\n");
    }
    else if(x == '1'){
        if(y <= '4')
            sys_kill((int)y-48+10);
        else 
            printf("\nmatch process failed, please input again\n");
    }
    else
        printf("\nmatch process failed, please input again\n");  

}

struct task_info task1 = {"task1", (uint32_t)&ready_to_exit_task, USER_PROCESS};
struct task_info task2 = {"task2", (uint32_t)&wait_lock_task, USER_PROCESS};
struct task_info task3 = {"task3", (uint32_t)&wait_exit_task, USER_PROCESS};

struct task_info task4 = {"task4", (uint32_t)&semaphore_add_task1, USER_PROCESS};
struct task_info task5 = {"task5", (uint32_t)&semaphore_add_task2, USER_PROCESS};
struct task_info task6 = {"task6", (uint32_t)&semaphore_add_task3, USER_PROCESS};

struct task_info task7 = {"task7", (uint32_t)&producer_task, USER_PROCESS};
struct task_info task8 = {"task8", (uint32_t)&consumer_task1, USER_PROCESS};
struct task_info task9 = {"task9", (uint32_t)&consumer_task2, USER_PROCESS};

struct task_info task10 = {"task10", (uint32_t)&barrier_task1, USER_PROCESS};
struct task_info task11 = {"task11", (uint32_t)&barrier_task2, USER_PROCESS};
struct task_info task12 = {"task12", (uint32_t)&barrier_task3, USER_PROCESS};

struct task_info task13 = {"SunQuan",(uint32_t)&SunQuan, USER_PROCESS};
struct task_info task14 = {"LiuBei", (uint32_t)&LiuBei, USER_PROCESS};
struct task_info task15 = {"CaoCao", (uint32_t)&CaoCao, USER_PROCESS};

struct task_info *test_tasks[16] = {&task1, &task2, &task3,
                                    &task4, &task5, &task6,
                                   &task7, &task8, &task9,
                                   &task10, &task11, &task12,
                                   &task13, &task14, &task15};
int num_test_tasks = 15;

// struct task_info *test_tasks[16] = {&task1,&task2,&task3,
//                                     &task4,&task5,&task6,
//                                     &task7,&task8,&task9,
//                                     &task10,&task11,&task12};
// int num_test_tasks = 12;

void test_shell()
{
    int i = 0;
    int x;
    char order[10] = {'\0'};
    char ch = '\0';//统计存储命令
    char temp[6] = {'\0'};
    char ps[] = "ps";
    char clear[] = "clear";
    char exec[] = "exec ";
    char kill[] = "kill ";
    
    sys_move_cursor(1,14);
    printf("-------------------- COMMAND --------------------\n");
    printf("> root@UCAS_OS:");
    
    while (1)
    {
        // read command from UART port
        sys_reflush();

        disable_interrupt();
        ch = read_uart_ch();//不可被打断
        enable_interrupt();
        if (ch != '\0'){
            if((ch == 8) || (ch == 127)){
                if(screen_cursor_x > 15){
                    screen_cursor_x--;
                    printf(" ");
                    screen_cursor_x--;
                }
                if(i >= 0){
                    i--;
                    order[i] = '\0';
                }
            }
            else{       //判断是否是退格键
                if(ch != 13){           //判断是否是回车
                        order[i] = ch;
                        i++;
                        printf("%c",ch);
                        // printf("%s",order);
                }
                else{
                    temp[0] = order[0];
                    temp[1] = order[1];
                    temp[2] = order[2];
                    temp[3] = order[3];
                    temp[4] = order[4];
                    // printf("%s",temp);
                    if(strcmp(temp,ps) == 0){
                        printf("\n");
                        sys_ps();
                    }
                    else if(strcmp(temp,clear) == 0){
                        sys_screen_clear(0,SCREEN_HEIGHT-1);
                        sys_move_cursor(1,14);
                        printf("-------------------- COMMAND --------------------\n");
                    }
                    else if((x = strcmp(temp,exec)) == 0){
                        process_exec(order[5],order[6]);
                        if(order[6] == '\0')
                            printf("\nexec process[%c]",order[5]);
                        else
                            printf("\nexec process[%c%c]",order[5],order[6]);
                        printf("\n");
                    }
                    else if(strcmp(temp,kill) == 0){
                        process_kill(order[5],order[6]);
                        if(order[6] == '\0')
                            printf("\nkill process pid = %c",order[5]);
                        else
                            printf("\nkill process pid = %c%c",order[5],order[6]);
                        printf("\n");
                    }
                    else{
                        printf("\n%s match instruction failed, you noob%d\n",order,x);
                    }
                    printf("> root@UCAS_OS:");
                    
                    while(i != 0){
                        i--;
                        order[i] = '\0';    
                    }//order[100] = {0};
                }
            }// TODO solve command
        }
    }
}

