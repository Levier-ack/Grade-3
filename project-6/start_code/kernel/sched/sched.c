#include "lock.h"
#include "time.h"
#include "stdio.h"
#include "sched.h"
#include "queue.h"
#include "screen.h"

pcb_t pcb[NUM_MAX_TASK];

/* current running task PCB */
pcb_t *current_running;

/* global process id */
pid_t lock_id = 1;

uint32_t inode_size = 64;
uint32_t inode_offset = 258;
uint32_t pwd;
sector_offset_t* sector; 
file_t filedesc[20];

char* name_ptr;//存储文件名的块中的文件名指针



void scheduler(void)
{
    pcb_t *pcb_temp_1,*pcb_temp_2,*pcb_temp_3;
    
    pcb_temp_1 = NULL;
    pcb_temp_2 = NULL;
    pcb_temp_3 = NULL;
    if(!queue_is_empty(&sleep_queue)){
        pcb_temp_3 = (pcb_t *)(sleep_queue.head);
        while(pcb_temp_3 != NULL){//遍历sleep_queue队列
            pcb_temp_2 = pcb_temp_3;

            if(get_timer()-pcb_temp_2->begin_time >= pcb_temp_2->sleep_time){
                pcb_temp_1 = (pcb_t *)queue_remove(&sleep_queue,pcb_temp_2);
                pcb_temp_2->status = TASK_READY;
                queue_push(&ready_queue,pcb_temp_2);
                pcb_temp_3 = pcb_temp_1;
            }
            else{
                pcb_temp_3 = pcb_temp_3->next;
            }
        }
    }
    // vt100_move_cursor(1,7);
    // printk("%d",queue_count(&ready_queue));


    if((current_running->status != TASK_BLOCKED)&&(current_running->status != TASK_SLEEPING)&&(current_running->status != TASK_EXITED)){
    	queue_push(&ready_queue, current_running);
    	current_running->status = TASK_READY;
    }
    // vt100_move_cursor(1,8);
    // printk("%d",current_running->pid);
    if (!queue_is_empty(&ready_queue)) {
    	save_cursor();
        current_running = queue_dequeue(&ready_queue);
        while(current_running->status != TASK_READY){
            current_running = queue_dequeue(&ready_queue);
        }
        load_cursor();
        current_running->status = TASK_RUNNING;
    }
}

void do_sleep(uint32_t sleep_time)
{	
	current_running->status = TASK_SLEEPING;
    queue_push(&sleep_queue,current_running); 
    current_running->sleep_time = sleep_time;
    current_running->begin_time = get_timer();
    do_scheduler();
}

void do_block(queue_t *queue)
{
    current_running->status = TASK_BLOCKED;
    queue_push(queue,current_running);
//    printk("\n\n\n%d",queue_count(queue));// block the current_running task into the queue
}

void do_unblock_one(queue_t *queue)
{
    pcb_t *temp;
    
	temp = queue_dequeue(queue);
    temp->status = TASK_READY;
    queue_push(&ready_queue, temp);
    // unblock the head task from the queue
}

void do_unblock_all(queue_t *queue)
{
    pcb_t *temp;
    temp = (pcb_t *)(queue->head);
    // vt100_move_cursor(0,2);
    // printk("%d",queue_count(queue));
    while (temp != NULL){
        temp = queue_dequeue(queue);
        temp->status = TASK_READY;
        queue_push(&ready_queue,temp);
        temp = (pcb_t *)(queue->head);// unblock all task in the queue
    }
}

pid_t do_getpid(){
    return current_running->pid;
}

void init_filedesc()
{
    int i;
    for (i = 0; i < 20; i++)
        filedesc[i].used = 0;
}

void write_mem(uint32_t offset, uint32_t num)
{
    uint32_t* ptr = (uint32_t*)BUFFER_ADDR;
    *(ptr + offset) = num;
}

uint32_t read_mem(uint32_t offset)
{
    uint32_t* ptr = (uint32_t*)BUFFER_ADDR;
    // debuginfo(12345);
    return *(ptr + offset);
}

void fillzero(uint32_t offset)
{
    int i;
    for (i = offset; i < 128; i++)
    {
        write_mem(i, 0);
    }
}

uint32_t count_1_map(uint32_t num)//读一个num中1的个数
{
    int i;
    int count = 0;
    for (i = 0; i < 64; i++)
    {
        if ((num & 0x80000000) != 0)
            count++;
        num = (num << 1);
    }
    return count;
}

uint32_t get_1_map(uint32_t num)//读map中第num位的值
{
    int offset, reserve;
    uint32_t value;
    offset = num/32;
    reserve = num - offset*32;
    value = read_mem(offset);
    value = (value << reserve);
    if ((value & 0x80000000) == 0)
        return 0;
    else
        return 1;
}

void set_1_map(uint32_t num)//在map中对应偏移的位置1，表示被占用
{
    int offset, reserve;
    uint32_t value;
    offset = num/32;
    reserve = num - offset*32;
    value = read_mem(offset);
    value = (value | (0x80000000 >> reserve));
    write_mem(offset, value);
}

void savefilename()//文件名以指针存储，此处将文件名字符串写入一块
{
    sdwrite((char*)NAME_ADDR, (SD_START_ADDR + 0x1f000000), 512);
}

void loadfilename()
{
    sdread((char*)NAME_ADDR, (SD_START_ADDR + 0x1f000000), 512);
}

void read_SD(uint32_t index){//读inodeoffset中的inode，并且加载入内存修改

    sector_offset_t* temp;
    printk("test5\n"); 
    temp->offset = (inode_size*index / 512);
    printk("test6\n");
    uint32_t reserve = inode_size*index - 512*(temp->offset);
    sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*((temp->offset)+inode_offset)), 512);
    printk("test7\n");
    temp->base = reserve/4;
    // return temp; 
}

uint32_t mkdirinode()//为一个目录分配建立一个inode
{
    int i, j;
    int flag, index;
    int offset = 1;
    int reserve;

    // Find empty inode position
    flag = 0;
    for (i = offset; i < offset+1; i++)//在inodemap中找到一个空闲inode
    {
        sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*i), 512);
        for (j = 0; j < 4096; j++)
        {
            if (get_1_map(j) == 0)
            {
                flag = 1;
                break;
            }
        }
        if (flag == 1) break;
    }

    // SD卡inodemap对应置1
    index = j;
    set_1_map(index);
    sdwrite((char*)BUFFER_ADDR, (SD_START_ADDR + 512*offset), 512);
    // Allocate inode  (pos: reserve ~ reserve+64B)
    offset = (inode_size*index / 512);
    reserve = inode_size*index - 512*offset;
    sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(offset+inode_offset)), 512);
    uint32_t base = reserve/4;
    write_mem(base  , 0);
    write_mem(base+1, 0x10000000);//目录的判断标识
    // printk("test6\n");
    write_mem(base+2, 0);
    // printk("test7\n");
    for (i = 3; i < 16; i++)//初始化直接指针
        write_mem(base+i, 0);
    // printk("test8\n");
    sdwrite((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(offset+inode_offset)), 512);
    return index;
}

uint32_t mkfileinode()
{
    int i, j;
    int flag, index;
    int offset = 1;
    int reserve;

    // Find empty inode position
    flag = 0;
    for (i = offset; i < offset+1; i++)
    {
        sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*i), 512);
        for (j = 0; j < 4096; j++)//找到一个空闲inode
        {
            if (get_1_map(j) == 0)
            {
                flag = 1;
                break;
            }
        }
        if (flag == 1) break;
    }

    // Announce ownership
    index = j;
    set_1_map(index);
    sdwrite((char*)BUFFER_ADDR, (SD_START_ADDR + 512*offset), 512);

    // Allocate inode  (pos: reserve ~ reserve+64B)
    offset = (inode_size*index / 512);
    reserve = inode_size*index - 512*offset;
    sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(offset+inode_offset)), 512);
    uint32_t base = reserve/4;
    write_mem(base  , 0);
    write_mem(base+1, 0x20000000);//文件的判断标识
    write_mem(base+2, 0);
    for (i = 3; i < 16; i++)//初始化直接指针
        write_mem(base+i, 0);
    sdwrite((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(offset+inode_offset)), 512);
    return index;
}

void add_datasector(uint32_t inode_index)//添加一个空闲数据块
{
    // Find empty data position
    int i, j;
    int flag, index;
    int offset = 2;
    int reserve;

    flag = 0;
    for (i = offset; i < offset+256; i++)
    {
        sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*i), 512);
        for (j = 0; j < 4096; j++)//sectormap中寻找一个空闲块
        {
            // printk("%d", j);
            if (get_1_map(j) == 0)
            {
                flag = 1;
                break;
            }
        }
        if (flag == 1) break;
    }

    set_1_map(j);
    sdwrite((char*)BUFFER_ADDR, (SD_START_ADDR + 512*i), 512);
    index = j + 4096*(i-offset);//实际的sectormap偏移量

    fillzero(0);//清空内存buffer，并且写入分配的数据块中
    sdwrite((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(index)), 512);
    
    offset = (inode_size*inode_index / 512);
    reserve = inode_size*inode_index - 512*offset;
    sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(offset+inode_offset)), 512);
    uint32_t base = reserve/4;  //读入inode块的内容
    for (i = 3; i < 13; i++)
    {
        if (read_mem(base+i) == 0)
        {
            write_mem(base+i, index);//写入直接指针
            break;
        }
    }
    if (i == 13)
        debuginfo(0x998);
    sdwrite((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(offset+inode_offset)), 512);//inode块写回
}

int mkdir(char* name, uint32_t inode_index, uint32_t ptr_index)//name的地址和ptr_index写入inode_index对应的目录块中
{
    int i, j;
    int flag, index;
    int data_index;
    uint32_t data_array[20] = {0};
    char* str_temp;

    uint32_t offset = (inode_size*inode_index / 512);
    uint32_t reserve = inode_size*inode_index - 512*offset;
    sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(offset+inode_offset)), 512);
    uint32_t base = reserve/4;  // appeal to uint32_t

    for (i = 3; i < 13; i++)    //将inode_index中的直接指针移出buffer
        data_array[i] = read_mem(base+i);

    for (i = 3; i < 13; i++)
    {
        if (data_array[i] != 0)
        {
            sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(data_array[i])), 512);
            for (j = 0; j < 128; j+=2)//目录项包括文件名地址+inode号
            {
                if (read_mem(j) == 0)
                    break;
                str_temp = (char*)read_mem(j);
                if (strcmp(str_temp, name) == 0)//判断若存在目录名，返回
                {
                    return -1;
                }
            }
            write_mem(j, (uint32_t)name_ptr);//j为空闲的目录项位置
            write_mem(j+1, ptr_index);
            sdwrite((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(data_array[i])), 512);
            while (*name != 0)//更新全局指针
            {
                *(name_ptr) = *name;
                name_ptr++;
                name++;
            }
            *(name_ptr) = 0;
            name_ptr++;
            sdread((char*)BUFFER_ADDR, SD_START_ADDR, 512);
            write_mem(9, (uint32_t)name_ptr);//内存中全局指针存入SD卡超级块
            sdwrite((char*)BUFFER_ADDR, SD_START_ADDR, 512);
            savefilename();
            break;
        }
    }
    return 0;
}

void do_mkfs(){

    int i;
    uint32_t index;
    //superblock
    printkf("[FS]  Start initialize filesystem!\n");
    printkf("[FS]  Setting superblock...\n");
    write_mem(0,0x66666666);
    printkf("      magic : 0x66666666\n");
    write_mem(1,0x00100000);
    write_mem(2,0x00100000);
    printkf("      num sector : 0x100000, start sector : 0x100000\n");
    write_mem(3,1);
    printkf("      inode map offset : 1 (1)\n");
    write_mem(4,256);
    printkf("      sector map offset : 2 (256)\n");
    write_mem(5,512);
    printkf("      inode offset : 258 (512)\n");
    write_mem(6,0x00100000 - 769);
    printkf("      data offset : 770 (1047807)\n");
    write_mem(7,64);
    write_mem(8,32);
    printkf("      inode entry size : 64B, dir entry size : 32B\n");
    write_mem(9,NAME_ADDR);
    fillzero(10);
    sdwrite((char*)BUFFER_ADDR,SD_START_ADDR,512);
    //inodemap
    printkf("[FS] Setting inode-map...\n");
    fillzero(0);
    sdwrite((char*)BUFFER_ADDR,SD_START_ADDR+512,512);
    //sectormap
    printkf("[FS] Setting sector-map...\n");
    fillzero(0);
    // printk("test2\n");
    for(i = 1; i < 256; i++)
        sdwrite((char *)BUFFER_ADDR,SD_START_ADDR+512*(2+i),512);
    for (i = 0; i < 24; i++)//一共770个1初始化，即superblock到数据块之前的块都是被占用的
        write_mem(i, 0xffffffff);
    // printk("test3\n");
    write_mem(24, 0xc0000000);
    sdwrite((char*)BUFFER_ADDR, SD_START_ADDR+512*2, 512);
    //初始化根目录
    printkf(" [FS] Setting inode...\n");
    name_ptr = (char*)NAME_ADDR;//初始化文件名全局指针
    index = mkdirinode();//生成根目录inode
    // printk("test5\n");
    pwd = index;//初始化当前目录inode号
    // debuginfo(pwd);
    add_datasector(index);//分配目录块
    mkdir(".\0", index, index);//建立子目录目录项
    mkdir("..\0", index, index);

    printkf(" [FS] Initialize filesystem finished!\n");
}

void do_statfs(){
    int i, j;
    int count;
    uint32_t offset = 1;
    uint32_t* ptr = (uint32_t*)BUFFER_ADDR;
    uint32_t inode_num, sector_num;
    uint32_t inode_sector_num = 1; 
    uint32_t sector_sector_num = 256;

    // Calc used resource
    count = 0;
    for (i = offset; i < offset+inode_sector_num; i++)//计算inodemap中有效的inode个数
    {
        sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*i), 512);
        for (j = 0; j < 512/4; j++)//128个4字节的序列
        { 
            count += count_1_map(read_mem(j));
        }
    }
    inode_num = count;

    count = 0;
    offset = 2;
    for (i = offset; i < offset+sector_sector_num; i++)//计算已被占用的数据扇区个数
    {
        sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*i), 512);
        for (j = 0; j < 512/4; j++)
        { 
            count += count_1_map(read_mem(j));
        }
    }
    sector_num = count;

    // Print info
    offset = 1;
    sdread((char*)BUFFER_ADDR, SD_START_ADDR, 512);//读超级块内容
    printkf(" magic : 0x%x (KFS)\n", read_mem(0));
    printkf(" used sector : %d/%d, start sector : %d (0x%x)\n",
            sector_num, read_mem(1), read_mem(2), read_mem(2)*512);
    printkf(" inode map offset : %d, occupied sector : %d, used : %d/%d\n",
            offset, read_mem(3), inode_num, read_mem(3)*512*8);
    offset += read_mem(3);
    printkf(" sector map offset : %d, occupied sector : %d\n",
            offset, read_mem(4));
    offset += read_mem(4);
    printkf(" inode offset : %d, occupied sector : %d\n",
            offset, read_mem(5));
    offset += read_mem(5);
    printkf(" data offset : %d, occupied sector : %d\n",
            offset, read_mem(6));
    offset += read_mem(6);
    printkf(" inode entry size: %dB, dir entry size : %dB\n",
            read_mem(7), read_mem(8));
}

void do_cd(char* filename){
    int i;
    int j;
    uint32_t data_array[20] = {0};
    // printk("test1\n");
    uint32_t offset = (inode_size*pwd / 512);
    uint32_t reserve = inode_size*pwd - 512*offset;
    sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(offset+inode_offset)), 512);
    uint32_t base = reserve/4; // appeal to uint32_t
    
    for (i = 3; i < 13; i++)
        data_array[i] = read_mem(base+i);
    // printk("test0\n");
    for (i = 3; i < 13; i++)
    {
        if (data_array[i] != 0)
        {
            sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(data_array[i])), 512);
            // printk("test0\n");
            for (j = 0; j < 128; j+=2)
            {
                vt100_move_cursor(1,7);
                // printk("test1: || %s\n",filename);
                uint32_t temp1 = read_mem(j);
                uint32_t temp2 = strcmp((char*)temp1,filename);
                // printk("test2\n"); 
                if ((temp1 != 0) && (temp2 == 0))
                {
                    uint32_t pwdtemp = read_mem(j+1);
                    pwd = pwdtemp;
                    return;
                }
            }
        }
    }
    printkf(" Error, no such directory!\n");
}

void do_mkdir(char* filename){
    uint32_t index;
    int errcode;
    index = mkdirinode();//生成inode号
    errcode = mkdir(filename, pwd, index);
    if (errcode == -1)
    {
        printkf(" Directory has already existed!\n");
        return;
    }
    add_datasector(index);//分配空数据块
    mkdir(".", index, index);//建立目录项中的.和..
    mkdir("..", index, pwd);
}

void do_rmdir(char* filename){
    int i, j;
    uint32_t data_array[20] = {0};

    uint32_t offset = (inode_size*pwd / 512);
    uint32_t reserve = inode_size*pwd - 512*offset;
    sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(offset+inode_offset)), 512);
    uint32_t base = reserve/4;
    
    for (i = 3; i < 13; i++)
        data_array[i] = read_mem(base+i);

    for (i = 3; i < 13; i++)
    {
        if (data_array[i] != 0)
        {
            sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(data_array[i])), 512);
            for (j = 0; j < 128; j+=2)
            {
                if ((read_mem(j) != 0) && (strcmp((char*)read_mem(j), filename) == 0))
                {
                    write_mem(j, 0);
                    write_mem(j+1, 0);
                    sdwrite((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(data_array[i])), 512);
                    return;
                }
            }
        }
    }
    printkf(" Error, no such directory!\n");
}

void do_ls(){
    int i, j;
    uint32_t data_array[20] = {0};

    uint32_t offset = (inode_size*pwd / 512);
    uint32_t reserve = inode_size*pwd - 512*offset;
    sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(offset+inode_offset)), 512);
    uint32_t base = reserve/4;
    for (i = 3; i < 13; i++)//记录指针内容
        data_array[i] = read_mem(base+i);

    printkf(" ");
    for (i = 3; i < 13; i++)
    {
        if (data_array[i] != 0)
        {
            sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(data_array[i])), 512);
            for (j = 0; j < 128; j+=2)
            {
                if (read_mem(j) != 0)
                {
                    printkf("%s", read_mem(j));
                    offset = (inode_size*read_mem(j+1) / 512);
                    reserve = inode_size*read_mem(j+1) - 512*offset;
                    sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(offset+inode_offset)), 512);
                    uint32_t base = reserve/4;
                    if (read_mem(base+1) == 0x10000000)
                        printkf("/");
                    printkf("  ");
                }
                else
                    break;
                sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(data_array[i])), 512);
            }
        }
    }
    printkf("\n");
}

void do_touch(char* filename){
    uint32_t index;
    index = mkfileinode();
    mkdir(filename, pwd, index);//生成目录并写入父目录
}

uint32_t searchfile(char* filename){
    int i, j;
    uint32_t data_array[20] = {0};

    uint32_t offset = (inode_size*pwd / 512);
    uint32_t reserve = inode_size*pwd - 512*offset;
    sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(offset+inode_offset)), 512);
    uint32_t base = reserve/4;
    
    for (i = 3; i < 13; i++)
        data_array[i] = read_mem(base+i);

    for (i = 3; i < 13; i++)
    {
        if (data_array[i] != 0)
        {
            sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(data_array[i])), 512);
            for (j = 0; j < 128; j+=2)
            {
                if ((read_mem(j) != 0) && (strcmp((char*)read_mem(j), filename) == 0))//利用直接指针找到文件
                {
                    uint32_t file_inode = read_mem(j+1);
                    return file_inode;
                }
            }
        }
    }
    return -1;    
}

void do_cat(char* filename){
    int fd = do_open(filename, 1);
    int i, j;
    uint32_t data_array[20] = {0};
    uint32_t size, block_size, block_reserve;

    uint32_t offset = (inode_size*filedesc[fd].inode_index / 512);
    uint32_t reserve = inode_size*filedesc[fd].inode_index - 512*offset;
    sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(offset+inode_offset)), 512);
    uint32_t base = reserve/4;
    for (i = 3; i < 13; i++)
    {
        data_array[i] = read_mem(base+i);
    }

    size = read_mem(base);//inode第一项记录文件大小
    block_size = size/512;
    block_reserve = size - block_size*512;

    for (i = 0; i < block_size; i++)
    {
        sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(data_array[3+i])), 512);
        for (j = 0; j < 512; j++)
        {
            printkf("%c", ((char*)BUFFER_ADDR)[j]);
        }//打印整块数据
    }

    sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(data_array[3+block_size])), 512);
    for (i = 0; i < block_reserve; i++)
    {
        printkf("%c", ((char*)BUFFER_ADDR)[i]);
    }//打印不足整块的数据

    do_close(fd);
}

int do_open(char* filename, uint32_t access){
    int i;
    uint32_t filedesc_num;
    uint32_t index;

    for (i = 0; i < 20; i++)
        if (filedesc[i].used == 0)//选出未被使用的文件描述符
            break;
    filedesc_num = i;
    index = searchfile(filename);
    if(index == -1){
        printkf("Open failed\n");
        return -1;
    }
    filedesc[filedesc_num].used = 1;
    filedesc[filedesc_num].inode_index = index;
    filedesc[filedesc_num].access = access;
    filedesc[filedesc_num].wptr = 0;
    filedesc[filedesc_num].rptr = 0;
    return filedesc_num;
}

void do_read(int filedesc_num, char* buff, uint32_t size){
    int i, j;
    uint32_t data_array[20] = {0};
    uint32_t block_size, block_reserve;

    uint32_t offset = (inode_size*filedesc[filedesc_num].inode_index / 512);
    uint32_t reserve = inode_size*filedesc[filedesc_num].inode_index - 512*offset;
    sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(offset+inode_offset)), 512);
    uint32_t base = reserve/4;
    for (i = 3; i < 13; i++)
    {
        data_array[i] = read_mem(base+i);
    }

    uint32_t buff_ptr, read_ptr;

    block_size = size/512;
    block_reserve = size - block_size*512;
    read_ptr = filedesc[filedesc_num].rptr;
    buff_ptr = 0;

    for (i = 0; i < block_size; i++)
    {
        sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(data_array[3+i])), 512);
        for (j = 0; j < 512; j++)
        {
            buff[buff_ptr] = ((char*)BUFFER_ADDR)[read_ptr];
            read_ptr++;
            buff_ptr++;
        }
    }

    sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(data_array[3+block_size])), 512);
    for (i = 0; i < block_reserve; i++)
    {
        buff[buff_ptr] = ((char*)BUFFER_ADDR)[read_ptr];
        read_ptr++;
        buff_ptr++;
    }
    filedesc[filedesc_num].rptr += size;
}

void do_write(int filedesc_num, char* content, uint32_t size){
    int i, j;
    uint32_t data_array[20] = {0};
    uint32_t offset = (inode_size*filedesc[filedesc_num].inode_index / 512);
    uint32_t reserve = inode_size*filedesc[filedesc_num].inode_index - 512*offset;
    sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(offset+inode_offset)), 512);
    uint32_t base = reserve/4;
    for (i = 3; i < 13; i++)
        data_array[i] = read_mem(base+i);

    uint32_t block = filedesc[filedesc_num].wptr / 512 + 1 + 2;//转化为字符指针后计算块偏移
    uint32_t write_ptr = filedesc[filedesc_num].wptr - (block-3)*512;
    uint32_t word_ptr = 0;

    while (word_ptr < size)
    {
        if (data_array[block] == 0)
        {
            add_datasector(filedesc[filedesc_num].inode_index);
            sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(offset+inode_offset)), 512);
            data_array[block] = read_mem(base+block);
        }

        sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(data_array[block])), 512);
        *((char*)BUFFER_ADDR+write_ptr) = content[word_ptr];

        sdwrite((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(data_array[block])), 512);
        write_ptr++;
        word_ptr++;
    }
    filedesc[filedesc_num].wptr += size;//更新文件描述符内容
    sdread((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(offset+inode_offset)), 512);
    write_mem(base, filedesc[filedesc_num].wptr);
    sdwrite((char*)BUFFER_ADDR, (SD_START_ADDR + 512*(offset+inode_offset)), 512);
}

void do_close(int filedesc_num){
    filedesc[filedesc_num].used = 0;
    filedesc[filedesc_num].inode_index = 0;
    filedesc[filedesc_num].access = 0;
    filedesc[filedesc_num].wptr = 0;
    filedesc[filedesc_num].rptr = 0;
}