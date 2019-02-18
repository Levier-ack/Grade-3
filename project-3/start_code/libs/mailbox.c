#include "string.h"
#include "mailbox.h"
#include "cond.h"
#include "lock.h"

#define MAX_NUM_BOX 32

static mailbox_t mboxs[MAX_NUM_BOX];
mutex_lock_t mutex;

void mbox_init()
{
    int i = 0;
    int j = 0;
    for (j = 0;j < MAX_NUM_BOX; j++){
        for(i = 0; i < 20; i++)
            mboxs[j].name[i] = '\0';
        for(i = 0; i < 100; i++)
            mboxs[j].data[i] = 0;
        mboxs[j].used_num = 0;
        condition_init(&(mboxs[j].full_condition));
        condition_init(&(mboxs[j].empty_condition));
        mboxs[j].tag = 0;
        mboxs[j].count = 0;
        mboxs[j].i = j;
    }
    
}

mailbox_t *mbox_open(char *name)
{
    int i,j,k;
    int temp = 0;
    mutex_lock_acquire(&mutex);// mailbox_t *temp;
    for (i = 0;i < MAX_NUM_BOX;i++){
        if(strcmp(name,mboxs[i].name) == 0 && mboxs[i].tag == 1){
            mboxs[i].used_num++;
            temp = 1;
            break;
        }
    }
    if(temp == 0){
        for (k = 0;k < MAX_NUM_BOX;k++){
            if(mboxs[k].tag == 0)
                break;
        }
        for (j = 0;j < strlen(name);j++)
            mboxs[k].name[j] = name[j];
        mboxs[k].tag = 1;
        mboxs[k].used_num++;
    }
    mutex_lock_release(&mutex);

    if(temp)
        return &mboxs[i];
    else
        return &mboxs[k];
}

void mbox_close(mailbox_t *mailbox)
{
    int i;
    if(mailbox->used_num == 0){
       for(i = 0; i < 20; i++)
            mailbox->name[i] = '\0';
        for(i = 0; i < 100; i++)
            mailbox->data[i] = 0;
        mailbox->used_num = 0;
        condition_init(&(mailbox->full_condition));
        condition_init(&(mailbox->empty_condition));
        mailbox->tag = 0; 
    }

}

void mbox_send(mailbox_t *mailbox, int *msg, int msg_length)
{
    mutex_lock_acquire(&(mailbox->mutex));
    while((mailbox->count) == 100){
        condition_wait(&(mailbox->mutex),&(mailbox->full_condition));
    }

    mailbox->data[(mailbox->count)] = *msg;
    mailbox->count++;


    if((mailbox->count) == 1)
        condition_signal(&(mailbox->empty_condition));
        // condition_broadcast(&(mailbox->empty_condition));
    mutex_lock_release(&(mailbox->mutex));
}

void mbox_recv(mailbox_t *mailbox, int *msg, int msg_length)
{
    mutex_lock_acquire(&(mailbox->mutex));
    while((mailbox->count) == 0){        
        condition_wait(&(mailbox->mutex),&(mailbox->empty_condition));
    }
    // debuginfo(1234);
    
    *msg = mailbox->data[(mailbox->count)-1];
    mailbox->count--;

    if((mailbox->count) == 99)
        condition_signal(&(mailbox->full_condition));
        // condition_broadcast(&(mailbox->full_condition));
    mutex_lock_release(&(mailbox->mutex));
}