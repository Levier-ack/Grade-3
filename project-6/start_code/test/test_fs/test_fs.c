#include "stdio.h"
#include "string.h"
#include "test_fs.h"
#include "syscall.h"
#include "sched.h"

#define O_RDWR 0
static char buff[20];

void test_fs(void)
{
    int i, j;
    int RDWR = 0;
    int fd = sys_open("1.txt", RDWR);

    for (i = 0; i < 10; i++)
    {
        sys_fwrite(fd, "hello world!\n", 13);
    }

    for (i = 0; i < 10; i++)
    {
        sys_fread(fd, buff, 13);
        for (j = 0; j < 13; j++)
        {
            printf("%c", buff[j]);
        }
    }
    sys_close(fd);

    sys_exit();
}