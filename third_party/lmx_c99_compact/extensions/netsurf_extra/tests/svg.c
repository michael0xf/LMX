/* SPDX-License-Identifier: MIT */
#include <assert.h>
#include <stddef.h>
#include <string.h>
#include <svgtiny.h>
int main(void)
{
    const char svg[] = "<svg xmlns='http://www.w3.org/2000/svg' width='100' height='50'><rect x='1' y='2' width='10' height='20' fill='red'/><path d='M 0 0 L 10 10' stroke='blue'/></svg>";
    struct svgtiny_diagram *diagram = svgtiny_create();
    assert(diagram != NULL);
    assert(svgtiny_parse(diagram, svg, strlen(svg), "file:///fixture.svg", 100, 50) == svgtiny_OK);
    assert(diagram->width == 100 && diagram->height == 50 && diagram->shape_count == 2);
    assert(diagram->shape[0].fill == svgtiny_RGB(255, 0, 0));
    assert(diagram->shape[0].path_length > 0 && diagram->shape[0].path[0] == svgtiny_PATH_MOVE);
    assert(diagram->shape[1].stroke == svgtiny_RGB(0, 0, 255));
    svgtiny_free(diagram);
    diagram = svgtiny_create(); assert(diagram != NULL);
    assert(svgtiny_parse(diagram, "<html/>", 7, "file:///bad.xml", 100, 50) == svgtiny_NOT_SVG);
    svgtiny_free(diagram);
    return 0;
}
