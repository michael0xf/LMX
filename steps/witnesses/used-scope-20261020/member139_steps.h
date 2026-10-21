#ifndef MEMBER139_STEPS_H
#define MEMBER139_STEPS_H
typedef struct Member139Steps {
    int (*ticks[2])(int);
    struct Member139Steps *links[2];
} Member139Steps;
static int member139_steps_calls;
static int member139_steps_indices;
static int member139_steps_bad(int n){member139_steps_calls+=100;return n+99;}
static int member139_steps_good(int n){++member139_steps_calls;return n+7;}
static Member139Steps member139_steps={{member139_steps_bad,member139_steps_good},{0,0}};
static Member139Steps *member139_steps_ptr(void){member139_steps.links[0]=0;member139_steps.links[1]=&member139_steps;return &member139_steps;}
static int member139_steps_count(void){return member139_steps_calls;}
static int member139_steps_index_count(void){return member139_steps_indices;}
static int member139_steps_index(void){++member139_steps_indices;return 1;}
#endif
