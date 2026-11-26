#include "check.h"
#include <math.h>
#include "cute_c2.h"
int main(void) {
    c2Circle a = {{0,0},1}, b = {{1.5f,0},1}, far = {{5,0},1};
    c2Manifold m; c2Ray r = {{0,0},{1,0},10}; c2AABB box = {{2,-1},{4,1}};
    c2Raycast hit; c2v p, q; int iterations = 0;
    REQUIRE(c2CircletoCircle(a,b)); REQUIRE(!c2CircletoCircle(a,far));
    c2CircletoCircleManifold(a,b,&m);
    REQUIRE(m.count == 1 && fabsf(m.depths[0] - .5f) < 1e-5f);
    REQUIRE(c2RaytoAABB(r,box,&hit) && fabsf(hit.t - 2) < 1e-5f);
    REQUIRE(fabsf(c2GJK(&a,C2_TYPE_CIRCLE,NULL,&far,C2_TYPE_CIRCLE,NULL,&p,&q,1,&iterations,NULL)-3) < 1e-4f);
    REQUIRE(fabsf(p.x-1) < 1e-4f && fabsf(q.x-4) < 1e-4f);
    puts("cute_c2: overlap/manifold/raycast/GJK PASS"); return 0;
}
