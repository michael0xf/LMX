#ifndef INDEX140_EFFECTS_H
#define INDEX140_EFFECTS_H
static void **index140_outer[2],**index140_b,**index140_c;
static int index140_order,index140_marks;
static int index140_mark(int n){
 index140_order=index140_order*10+n;++index140_marks;
 index140_outer[0]=n==1?index140_b:index140_c;
 return n==1?0:1;
}
#endif
