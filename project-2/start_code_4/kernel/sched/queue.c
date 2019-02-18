#include "queue.h"
#include "sched.h"

typedef pcb_t item_t;

void queue_init(queue_t *queue)
{
	//printk("test_queue_init\n");    
	queue->head = queue->tail = NULL;
	//printk("test_queue_init_end\n");
}

int queue_is_empty(queue_t *queue)
{
    if (queue->head == NULL)
    {
        return 1;
    }
    return 0;
}

void queue_push(queue_t *queue, void *item)
{
    item_t *_item = (item_t *)item;
    /* queue is empty */
    if (queue->head == NULL)
    {
        queue->head = item;
        queue->tail = item;
        _item->next = NULL;
        _item->prev = NULL;
    }
    else
    {
        ((item_t *)(queue->tail))->next = item;
        _item->next = NULL;
        _item->prev = queue->tail;
        queue->tail = item;
    }
}

void *queue_dequeue(queue_t *queue)
{
    item_t *temp = (item_t *)queue->head;

    /* this queue only has one item */
    if (temp->next == NULL)
    {
        queue->head = queue->tail = NULL;
    }
    else
    {
        queue->head = ((item_t *)(queue->head))->next;
        ((item_t *)(queue->head))->prev = NULL;
    }

    temp->prev = NULL;
    temp->next = NULL;

    return (void *)temp;
}

void *sleepqueue_dequeue(int x)
{
    int i = 0;
    item_t *temp;

    if(((item_t *)(sleep_queue.head))->next == sleep_queue.tail){
        temp = queue_dequeue(&sleep_queue);
    }
    else{
        temp = (item_t *)(sleep_queue.head);
        while(i != x){
        i++;
        temp = temp->next;
        }
        if(i == 0){
            sleep_queue.head = temp->next;
            temp->prev = NULL;
        }
        else{
            if(temp->next == NULL){
                sleep_queue.tail = temp->prev;
                temp->next = NULL; 
            }
            else{
                (temp->prev)->next = temp->next;
                (temp->next)->prev = temp->prev;
            }
        }
    }

    temp->prev = NULL;
    temp->next = NULL;

    return (void *)temp;
}

/* remove this item and return next item */
void *queue_remove(queue_t *queue, void *item)
{
    item_t *_item = (item_t *)item;
    item_t *next = (item_t *)_item->next;

    if (item == queue->head && item == queue->tail)
    {
        queue->head = NULL;
        queue->tail = NULL;
    }
    else if (item == queue->head)
    {
        queue->head = _item->next;
        ((item_t *)(queue->head))->prev = NULL;
    }
    else if (item == queue->tail)
    {
        queue->tail = _item->prev;
        ((item_t *)(queue->tail))->next = NULL;
    }
    else
    {
        ((item_t *)(_item->prev))->next = _item->next;
        ((item_t *)(_item->next))->prev = _item->prev;
    }

    _item->prev = NULL;
    _item->next = NULL;

    return (void *)next;
}

int queue_count(queue_t *queue){
    int i = 0;
    pcb_t *temp = (pcb_t *)(queue->head);
        while(temp != NULL){
            i++;
            temp = temp->next;
        }
        return i;
}
