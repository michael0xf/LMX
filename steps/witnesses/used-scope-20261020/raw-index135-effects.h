#ifndef INDEX135_EFFECTS_H
#define INDEX135_EFFECTS_H
static void **index135_outer[2],*index135_b[2],*index135_c[2],*index135_d[2];
static int index135_order,index135_marks,index135_gives;
static int index135_mark(int n){
 index135_order=index135_order*10+n;++index135_marks;
 if(n==1)index135_outer[0]=index135_b;
 if(n==2)index135_outer[0]=index135_c;
 return n==1?0:1;
}
static void *index135_give(void *value){
 index135_order=index135_order*10+3;++index135_gives;
 index135_outer[0]=index135_d;return value;
}
#endif
