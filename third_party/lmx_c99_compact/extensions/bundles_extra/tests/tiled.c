#include "check.h"
#include <string.h>
#include "cute_tiled.h"
int main(void) {
    const char finite[]="{\"height\":1,\"width\":2,\"infinite\":false,\"orientation\":\"orthogonal\",\"renderorder\":\"right-down\",\"tileheight\":16,\"tilewidth\":16,\"type\":\"map\",\"version\":1.10,\"layers\":[{\"data\":[1,2],\"height\":1,\"width\":2,\"id\":1,\"name\":\"ground\",\"opacity\":1,\"type\":\"tilelayer\",\"visible\":true,\"x\":0,\"y\":0}],\"tilesets\":[]}";
    const char infinite[]="{\"height\":0,\"width\":0,\"infinite\":true,\"orientation\":\"orthogonal\",\"tileheight\":16,\"tilewidth\":16,\"type\":\"map\",\"layers\":[{\"chunks\":[{\"data\":[3,4],\"height\":1,\"width\":2,\"x\":-2,\"y\":5}],\"id\":1,\"name\":\"ground\",\"opacity\":1,\"type\":\"tilelayer\",\"visible\":true,\"x\":0,\"y\":0}],\"tilesets\":[]}";
    cute_tiled_map_t *m=cute_tiled_load_map_from_memory(finite,(int)strlen(finite),NULL); REQUIRE(m);
    REQUIRE(m->width==2 && m->height==1 && m->layers && m->layers->data_count==2 && m->layers->data[1]==2); cute_tiled_free_map(m);
    m=cute_tiled_load_map_from_memory(infinite,(int)strlen(infinite),NULL); REQUIRE(m);
    REQUIRE(m->infinite && m->layers && m->layers->chunks);
    REQUIRE(m->layers->chunks->x==-2 && m->layers->chunks->y==5 && m->layers->chunks->data_count==2 && m->layers->chunks->data[0]==3);
    cute_tiled_free_map(m); puts("cute_tiled: finite and chunked Tiled JSON PASS"); return 0;
}
