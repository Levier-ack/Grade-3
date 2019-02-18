#include "cond.h"
#ifndef INCLUDE_MAIL_BOX_
#define INCLUDE_MAIL_BOX_

typedef struct mailbox
{
  char name[20];
  int used_num;
  condition_t full_condition;
  condition_t empty_condition;//   pid_t *output;
  int data[100];
  int count;  
  int tag;
  int i;
  mutex_lock_t mutex; //1为被占用，0为已释放
} mailbox_t;


void mbox_init();
mailbox_t *mbox_open(char *);
void mbox_close(mailbox_t *);
void mbox_send(mailbox_t *, int *, int);
void mbox_recv(mailbox_t *, int *, int);

#endif