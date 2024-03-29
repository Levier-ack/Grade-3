#include "mac.h"
#include "irq.h"
#include "type.h"
#include "screen.h"
#include "syscall.h"
#include "sched.h"
#include "test4.h"
#include "test.h"

queue_t recv_block_queue;
desc_t *send_desc;
desc_t *receive_desc;
uint32_t cnt = 1; //record the time of iqr_mac
//uint32_t buffer[PSIZE] = {0x00040045, 0x00000100, 0x5d911120, 0x0101a8c0, 0xfb0000e0, 0xe914e914, 0x00000801,0x45000400, 0x00010000, 0x2011915d, 0xc0a80101, 0xe00000fb, 0x14e914e9, 0x01080000};
uint32_t buffer[PSIZE] = {0xffffffff, 0x5500ffff, 0xf77db57d, 0x00450008, 0x0000d400, 0x11ff0040, 0xa8c073d8, 0x00e00101, 0xe914fb00, 0x0004e914, 0x0000, 0x005e0001, 0x2300fb00, 0x84b7f28b, 0x00450008, 0x0000d400, 0x11ff0040, 0xa8c073d8, 0x00e00101, 0xe914fb00, 0x0801e914, 0x0000};

/**
 * Clears all the pending interrupts.
 * If the Dma status register is read then all the interrupts gets cleared
 * @param[in] pointer to synopGMACdevice.
 * \return returns void.
 */
void clear_interrupt()
{
    uint32_t data;
    data = reg_read_32(0xbfe11000 + DmaStatus);
    reg_write_32(0xbfe11000 + DmaStatus, data);
}

static void send_desc_init(mac_t *mac)
{
    //send memory init
    int i = 0;
    uint32_t *buffer_temp = (uint32_t*)SEND_BUFFER;
    for(i = 0; i < mac->psize; i++){
        buffer_temp[i] = buffer[i];
    }
    // printf("test1\n");
    //send desc init
    uint32_t *desc_addr = (uint32_t*)SEND_DESC;
    for(i = 0; i < mac->pnum-1; i++){
        desc_addr[0] = 0x00000000;
        desc_addr[1] = 0x61000400;
        desc_addr[2] = SEND_BUFFER - 0xa0000000;
        desc_addr[3] = (uint32_t)(desc_addr + 4) - 0xa0000000;
        desc_addr = desc_addr + 4;
    }
    // printk("test2\n");
    desc_addr[0] = 0x00000000;
    desc_addr[1] = 0x63000400;
    desc_addr[2] = SEND_BUFFER - 0xa0000000;
    desc_addr[3] = SEND_DESC - 0xa0000000;

    mac->td     = SEND_DESC;
    mac->td_phy = SEND_DESC - 0xa0000000;
}

static void recv_desc_init(mac_t *mac)
{
    //recv memory init
    int i = 0;
    uint32_t *buffer_temp = (uint32_t*)RECV_BUFFER;
    for(i = 0; i < mac->psize*mac->pnum; i++){
        buffer_temp[i] = 0x00000000;
    }
    // printk("test1\n");
    //recv desc init
    uint32_t *desc_addr = (uint32_t*)RECV_DESC;
    for(i = 0; i < mac->pnum-1; i++){
        desc_addr[0] = 0x00000000;
        desc_addr[1] = 0x81000400;
        desc_addr[2] = RECV_BUFFER + i*mac->psize - 0xa0000000;
        desc_addr[3] = (uint32_t)(desc_addr + 4) - 0xa0000000;
        desc_addr = desc_addr + 4;
    }
    // printf("test2%x\n",desc_addr);
    desc_addr[0] = 0x00000000;
    desc_addr[1] = 0x83000400;
    desc_addr[2] = RECV_BUFFER + i*mac->psize - 0xa0000000;
    desc_addr[3] = RECV_DESC - 0xa0000000;
    // printk("test3\n");
    mac->rd     = RECV_DESC;
    mac->rd_phy = RECV_DESC - 0xa0000000;
    mac->daddr  = RECV_BUFFER - 0xa0000000;
}



static void mii_dul_force(mac_t *mac)
{
    reg_write_32(mac->dma_addr, 0x80); //?s
                                       //   reg_write_32(mac->dma_addr, 0x400);
    uint32_t conf = 0xc800;            //0x0080cc00;

    // loopback, 100M
    reg_write_32(mac->mac_addr, reg_read_32(mac->mac_addr) | (conf) | (1 << 8));
    //enable recieve all
    reg_write_32(mac->mac_addr + 0x4, reg_read_32(mac->mac_addr + 0x4) | 0x80000001);
}





void dma_control_init(mac_t *mac, uint32_t init_value)
{
    reg_write_32(mac->dma_addr + DmaControl, init_value);
    return;
}


void phy_regs_task1()
{

    mac_t test_mac;
    uint32_t i;
    uint32_t print_location = 2;

    test_mac.mac_addr = 0xbfe10000;
    test_mac.dma_addr = 0xbfe11000;

    test_mac.psize = PSIZE * 4; // 1024bytes
    test_mac.pnum = PNUM;       // pnum

    send_desc_init(&test_mac);

    dma_control_init(&test_mac, DmaStoreAndForward | DmaTxSecondFrame | DmaRxThreshCtrl128);
    clear_interrupt(&test_mac);

    mii_dul_force(&test_mac);

    sys_move_cursor(1, print_location);
    printf("> [SEND TASK] start send package.               \n");
               
  
    uint32_t cnt = 0;
    i = 4;
    while (i > 0)
    {
        sys_net_send(test_mac.td, test_mac.td_phy);
        cnt += PNUM;
        sys_move_cursor(1, print_location);
        printf("> [SEND TASK] totally send package %d !        \n", cnt);
        i--;
    }
    sys_exit();
}

void phy_regs_task2()
{

    mac_t test_mac;
    uint32_t i;
    // uint32_t count = 0;
    uint32_t ret;
    uint32_t print_location = 1;

    test_mac.mac_addr = 0xbfe10000;
    test_mac.dma_addr = 0xbfe11000;

    test_mac.psize = PSIZE * 4; // 64bytes
    test_mac.pnum = PNUM;       // pnum
    recv_desc_init(&test_mac);
    // debuginfo(1234);
    dma_control_init(&test_mac, DmaStoreAndForward | DmaTxSecondFrame | DmaRxThreshCtrl128);
    // printk("test4\n");
    clear_interrupt(&test_mac);
    // printk("test5\n");
    mii_dul_force(&test_mac);

    queue_init(&recv_block_queue);
    sys_move_cursor(1, print_location);
    // printk("test6\n");
    while(1){
        printk("[RECV TASK] start recv:                    ");
        ret = sys_net_recv(test_mac.rd, test_mac.rd_phy, test_mac.daddr);
        if (ret == 0)
        {
            sys_move_cursor(1, print_location);
            printf("[RECV TASK]     net recv is ok!                          ");
        }
        else
        {
            sys_move_cursor(1, print_location);
            printf("[RECV TASK]     net recv is fault!                       ");
        }
        printf("\nprint the head of all package data():\n");
        for (i = 0; i < 64; i++)
        {
            printf("%x  ", *((uint32_t*)RECV_DESC + i*0x400/4));
        }
    }
    sys_exit();
}

void phy_regs_task3()
{
    uint32_t print_location = 1;
    sys_move_cursor(1, print_location);
    printf("> [INIT] Waiting for MAC initialization .\n");
    sys_init_mac();
    sys_move_cursor(1, print_location);
    printf("> [INIT] MAC initialization succeeded.           \n");
    sys_exit();
}
