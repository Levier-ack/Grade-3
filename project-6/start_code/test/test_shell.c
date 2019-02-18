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
#include "sched.h"
#include "test_fs.h"
#include "string.h"

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

void process_cd (char* string){
    int i;
    char temp1[20];
    char temp2[20];
    int temp2_length = 0;
    // debuginfo(1234);
    int temp1_length = strlen(string) - 3;

    for(i = 0; i < temp1_length; i++)
        temp1[i] = string[i+3]; 

    temp1[temp1_length] = 0;
    // printk("%s %d",temp1,temp1_length);
    // debuginfo(1234);
    for (i = 0; i < temp1_length+1; i++)
        {
            if ((temp1[i] == '/') || (temp1[i] == 0))
            {
                temp2[temp2_length] = 0;
                if(i == 0){
                    pwd = 0;
                    continue;
                }
                // vt100_move_cursor(1,5);
                // printk("%s || %s",temp1,temp2);
                // debuginfo(12345);
                sys_cd(temp2);
                // debuginfo(1234);
                temp2_length = 0;       
            } 
            else
            {
                temp2[temp2_length] = temp1[i];
                temp2_length++;
            }
        }
    return;
}

void process_mkdir (char* string){
    char* temp;
    temp = string + 6;
    sys_mkdir(temp);
    return;
}

void process_rmdir (char* string){
    char* temp;
    temp = string + 6;
    sys_rmdir(temp);
    return;
}

void process_touch (char* string){
    char* temp;
    temp = string + 6;
    sys_touch(temp);
    return;
}

void process_cat (char* string){
    char* temp;
    temp = string + 4;
    sys_cat(temp);
    return;
}

struct task_info task1 = {"task1", (uint32_t)&test_fs, USER_PROCESS};

struct task_info *test_tasks[16] = {&task1};
int num_test_tasks = 1;

// struct task_info *test_tasks[16] = {&task1,&task2,&task3,
//                                     &task4,&task5,&task6,
//                                     &task7,&task8,&task9,
//                                     &task10,&task11,&task12};
// int num_test_tasks = 12;

int searchfs()
{
    // printk("begin");
    sdread((char*)BUFFER_ADDR, SD_START_ADDR, 512);
    // debuginfo(1234);
    if (read_mem(0) == 0x66666666)
        return 1;
    else
        return 0;
}

void test_shell()
{
    int i = 0;
    int j = 0;
    int x;
    char order[20] = {'\0'};
    char ch = '\0';//统计存储命令
    char temp[7] = {'\0'};
    char ps[] = "ps";
    char clear[] = "clear";
    char exec[] = "exec ";
    char kill[] = "kill ";
    char mkfs[] = "mkfs";
    char statfs[] = "statf";
    char ls[] = "ls";
    char cd[]    = "cd ";
    char mkdir[] = "mkdir";
    char rmdir[] = "rmdir";
    char touch[] = "touch";
    char cat[]   = "cat ";

    sys_move_cursor(1,14);
    printf("-------------------- COMMAND --------------------\n");
    // debuginfo(1234)
    if (searchfs() == 1)
    {
        // printk("test0\n");
        printf(" [FS] Find an existing filesystem\n");
        pwd = 0;
        name_ptr = (char*)(read_mem(9));
        inode_size = 64;
        inode_offset = (1+1+256);
        loadfilename();
    }
    else{
        // printk("test1\n");
        sys_mkfs();
        // debuginfo(1234);
    }

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

                    for(j = 0; j < 5; j++){
                        temp[j] = order[j];
                    }
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
                    else if(strcmp(temp,ls) == 0){
                        printf("\n");
                        sys_ls();
                    }
                    else if(strcmp(temp,mkfs) == 0){
                        printf("\n");
                        sys_mkfs();
                    }
                    else if(strcmp(temp,statfs) == 0){
                        printf("\n");
                        sys_statfs();
                    }
                    else if(order[0] == 'c' && order[1] == 'd'){
                        process_cd(order);
                        printf("\n");
                    }
                    else if(strcmp(temp,mkdir) == 0){
                        process_mkdir(order);
                        printf("\n");
                    }
                    else if(strcmp(temp,rmdir) == 0){
                        process_rmdir(order);
                        printf("\n");
                    }
                    else if(strcmp(temp,touch) == 0){
                        process_touch(order);
                        printf("\n");
                    }
                    else if(order[0] == 'c' && order[1] == 'a' && order[2] == 't'){
                        process_cat(order);
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

