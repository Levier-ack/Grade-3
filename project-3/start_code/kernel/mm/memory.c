#include "mm.h"
#include "sched.h"

#define phy_number 0x1000 //458752  
#define pte_number 0x80000 // 1048576 
// #define pte_number 0x200

typedef struct page_table_entry {
    uint32_t virtual_number;
    uint32_t physical_number;
    int valid;
    uint32_t pid;
    // struct page_table_entry *next;
}PTE;

typedef struct physical_addr {
    uint32_t physical_number;
    int used;
    // struct physical_addr *next;
}phy_addr;


phy_addr *phy_table;
PTE *page_table;

uint32_t get_cp0_context(void){
	uint32_t context;	
	asm(
		"mfc0 %0,$4\t\n"
		: "=r"(context)	
	);
	return context;
}

uint32_t get_cp0_index(void){
	uint32_t context;	
	asm(
		"mfc0 %0,$0\t\n"
		: "=r"(context)	
	);
	return context;
}

uint32_t get_cp0_badvaddr(void){
	uint32_t badvaddr;	
	asm(
		"mfc0 %0,$8\t\n"
		: "=r"(badvaddr)	
	);
	return badvaddr;
}

uint32_t get_cp0_entryhi(void){
	uint32_t badvaddr;	
	asm(
		"mfc0 %0,$10\t\n"
		: "=r"(badvaddr)	
	);
	return badvaddr;
}

uint32_t get_cp0_entrylo0(void){
	uint32_t badvaddr;	
	asm(
		"mfc0 %0,$2\t\n"
		: "=r"(badvaddr)	
	);
	return badvaddr;
}

void init_phy_table(void){

    page_table = (PTE*)0xa0c00000;
    phy_table = (phy_addr*)0xa0b00000;

    uint32_t i = 0;
    for(i = 0;i < phy_number;i++){
        phy_table[i].physical_number = 0x01000000+i*0x1000;
        phy_table[i].used = 0;
    }

    for(i = 0;i < pte_number;i++){
        page_table[i].virtual_number = 0x00000000+i*0x1000;
        page_table[i].pid = 0;
        page_table[i].valid = 0;
    }
    // debuginfo(page_table[i-1].virtual_number);
} 
//In task1&2, page table is initialized completely with address mapping, but only virtual pages in task3.


void init_TLB(void){
    int i = 0;
    int entryhi = 0x0000000ff;
    int entrylo0 = 0x00000000;
    int entrylo1 = 0x00000000;
    for(i = 0;i < 32;i++){
        init_TLB_asm(i,entryhi,entrylo0,entrylo1);
        // entryhi = 0x2000 + entryhi;
        // entrylo0 = 0x80 + entrylo0;
        // entrylo1 = 0x80 + entrylo1;
    }
}
//TODO:Finish memory management functions here refer to mm.h and add any functions you need.

void do_TLB_Refill(void){
    uint32_t context  = get_cp0_context();
    TLBP((context<<5),current_running->pid);
}

void TLBrefill(void){

    uint32_t context = get_cp0_context();
    uint32_t index   = get_cp0_index();
    uint32_t entryhi = get_cp0_entryhi();
    uint32_t entrylo0 = get_cp0_entrylo0();
    uint32_t badvaddr = get_cp0_badvaddr();
    int i = 0;
    int j = 0;
    int k = 0;
    int temp = 0;
    int refill = 0;
    uint32_t asid = 0x000000ff & get_cp0_entryhi();
    uint32_t con_vir_addr = (context & 0x007ffff0)<<9;

    // printkf("\n%x \n%x \n%x \n%x \n%x",badvaddr,context,index,entryhi,entrylo0);
    for (i = 0;(i < pte_number)&&(refill != 1);i = i + 2){
        // printk("\n%d",i);
        if((con_vir_addr == page_table[i].virtual_number)&&(page_table[i].valid == 1)){
            if(asid == page_table[i].pid){
                refill = 1;
                i = i - 2;// debuginfo(i);
            }
            else {
                // debuginfo(12345);
                printk("address overload %x",i);
                while(1){}
            }
        }
        // printk("\n%d",i);
    }
    // debuginfo(refill);
    // printk("\n%x",page_table[i].physical_number);

    if(refill == 0){
        for(i = 0;i < pte_number;i = i + 2){
            if((page_table[i].valid == 0)&&(page_table[i].virtual_number == con_vir_addr)){
                // page_table[i].virtual_number = con_vir_addr;
                page_table[i].valid = 1;
                page_table[i+1].valid = 1;
                break;
            }
        }

        for(j = 0;j < phy_number;j = j + 2){
            if(phy_table[j].used == 0){
                page_table[i].physical_number = phy_table[j].physical_number;
                page_table[i+1].physical_number = phy_table[j+1].physical_number;
                phy_table[j].used += 1;
                phy_table[j+1].used += 1;
                // debuginfo(phy_table[j].physical_number);
                break;
            }
            else if(j == (phy_number-2)){
                temp = phy_table[k].used;
                for(k = 0;k < phy_number;k = k+2){
                    if(temp >= phy_table[k].used){
                        temp = phy_table[k].used;
                        j = k;
                    }
                }
                page_table[i].physical_number = phy_table[j].physical_number;
                page_table[i+1].physical_number = phy_table[j+1].physical_number;
                phy_table[j].used += 1;
                phy_table[j+1].used += 1;
            }
        }
        page_table[i].pid = (uint32_t)current_running->pid;
    }
    // printkf("%d",i);
    // printkf("\n%d \n%d \n%x \n%x \n%x",con_vir_addr,refill,i,page_table[i].virtual_number,page_table[i+1].physical_number);
    // debuginfo(index);
    set_TLBrefill(page_table[i].virtual_number,page_table[i].physical_number>>6,current_running->pid);
}

void TLBinvalid(void){

    uint32_t context = get_cp0_context();
    uint32_t index   = get_cp0_index();
    int i = 0;
    int j = 0;
    int refill = 0;
    uint32_t asid = 0x000000ff & get_cp0_entryhi();
    uint32_t con_vir_addr = (context & 0x007ffff0)<<9;

    // printk("%x",con_vir_addr);
    for (i = 0;(i < pte_number)&&(refill != 1);i = i + 2){
        // printk("\n%d",i);
        if((con_vir_addr == page_table[i].virtual_number)&&(page_table[i].valid == 1)){
            if(asid == page_table[i].pid){
                refill = 1;
                // debuginfo(12345);
            }
            else {
                // debuginfo(12345);
                printk("address overload %d",i);
                while(1){}
            }
        }
        // printk("\n%d",i);
    }
    // debuginfo(refill);
    // printk("\n%x",page_table[i].physical_number);

    if(refill == 0){
        for(i = 0;i < pte_number;i = i + 2){
            if((page_table[i].valid == 0)&&(page_table[i].virtual_number == con_vir_addr)){
                // page_table[i].virtual_number = con_vir_addr;
                page_table[i].valid = 1;
                page_table[i+1].valid = 1;
                break;
            }
        }

        for(j = 0;j < phy_number;j = j + 2){
            if(phy_table[j].used == 0){
                page_table[i].physical_number = phy_table[j].physical_number;
                page_table[i+1].physical_number = phy_table[j+1].physical_number;
                phy_table[j].used = 1;
                phy_table[j+1].used = 1;
                // debuginfo(phy_table[j].physical_number);
                break;
            }
        }
        page_table[i].pid = (uint32_t)current_running->pid;
    }
    
    // printk("\n%d \n%x \n%x \n%x",refill,i,page_table[i].virtual_number/2,page_table[i+1].physical_number);
    debuginfo(index);
    set_TLBinvalid(page_table[i].virtual_number>>1,page_table[i].physical_number>>6,current_running->pid);
}