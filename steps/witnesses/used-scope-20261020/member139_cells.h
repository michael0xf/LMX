#ifndef MEMBER139_CELLS_H
#define MEMBER139_CELLS_H
typedef struct Member139Cells { int value; struct Member139Cells *links[2]; } Member139Cells;
static Member139Cells member139_cells={3,{0,0}};
static Member139Cells *member139_cells_ptr(void){member139_cells.links[0]=0;member139_cells.links[1]=&member139_cells;return &member139_cells;}
static int member139_cells_value(void){return member139_cells.value;}
#endif
