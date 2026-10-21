#ifndef MEMBER139_TABLE_H
#define MEMBER139_TABLE_H
typedef struct Member139Table { int (*tick)(int); int factor; int last; } Member139Table;
static int member139_calls;
static int member139_tick(int n){++member139_calls;return n+7;}
static Member139Table member139_table={member139_tick,2,0};
static Member139Table member139_make(void){return member139_table;}
static Member139Table *member139_ptr(void){return &member139_table;}
static int member139_last(void){return member139_table.last;}
static int member139_count(void){return member139_calls;}
#endif
