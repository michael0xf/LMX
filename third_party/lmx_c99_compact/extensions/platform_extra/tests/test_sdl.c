/* Headless checks. Device backends are compiled, not claimed hardware-tested. */
#include <SDL3/SDL.h>
#include <stdio.h>
#include <string.h>
#define CHECK(x) do { if (!(x)) { fprintf(stderr,"SDL check failed at %d: %s (%s)\n",__LINE__,#x,SDL_GetError()); return 1; } } while(0)
static int compare_ints(const void *a,const void *b) { int x=*(const int *)a,y=*(const int *)b; return (x>y)-(x<y); }
static int thread_entry(void *data) { return *(int *)data+1; }
static int freed=0;
static void free_memory(void *p) { ++freed; SDL_free(p); }
int main(int argc, char **argv) {
    int values[]={4,2,9,1}, key=4, answer=41, status=0, n, i;
    SDL_SharedObject *module; int (*loaded_answer)(int);
    SDL_Thread *thread; SDL_Event event; SDL_Surface *surface,*copy,*bmp;
    SDL_Renderer *renderer; SDL_IOStream *io; unsigned char storage[4096];
    Uint8 r,g,b,a; SDL_AudioSpec input={SDL_AUDIO_S16,1,22050}, output={SDL_AUDIO_F32,2,44100};
    SDL_AudioStream *stream; Sint16 samples[64]; float floats[512];
    SDL_free_func release=free_memory; void *address=NULL,*memory;
    typedef char lmx_callback_size[(sizeof(release)==sizeof(address))?1:-1];
    SDL_SetHint(SDL_HINT_VIDEO_DRIVER,"dummy"); SDL_SetHint(SDL_HINT_AUDIO_DRIVER,"dummy");
    CHECK(SDL_Init(SDL_INIT_VIDEO|SDL_INIT_AUDIO|SDL_INIT_EVENTS));
    CHECK(argc==2); module=SDL_LoadObject(argv[1]); CHECK(module!=NULL);
    loaded_answer=(int (*)(int))SDL_LoadFunction(module,"lmx_platform_plugin_answer");
    CHECK(loaded_answer!=NULL && loaded_answer(41)==42); SDL_UnloadObject(module);
    SDL_qsort(values,4,sizeof(int),compare_ints); CHECK(values[0]==1 && values[3]==9);
    CHECK(SDL_bsearch(&key,values,4,sizeof(int),compare_ints)==&values[2]);
    thread=SDL_CreateThread(thread_entry,"lmx-test",&answer); CHECK(thread!=NULL); SDL_WaitThread(thread,&status); CHECK(status==42);
    SDL_zero(event); event.type=SDL_EVENT_USER; event.user.code=42; CHECK(SDL_PushEvent(&event));
    CHECK(SDL_PeepEvents(&event,1,SDL_GETEVENT,SDL_EVENT_USER,SDL_EVENT_USER)==1 && event.user.code==42);
    surface=SDL_CreateSurface(8,8,SDL_PIXELFORMAT_RGBA32); CHECK(surface!=NULL);
    renderer=SDL_CreateSoftwareRenderer(surface); CHECK(renderer!=NULL);
    CHECK(SDL_SetRenderDrawColor(renderer,11,22,33,255)); CHECK(SDL_RenderClear(renderer)); CHECK(SDL_RenderPresent(renderer)); SDL_DestroyRenderer(renderer);
    copy=SDL_CreateSurface(8,8,SDL_PIXELFORMAT_RGBA32); CHECK(copy!=NULL); CHECK(SDL_BlitSurface(surface,NULL,copy,NULL));
    CHECK(SDL_ReadSurfacePixel(copy,3,4,&r,&g,&b,&a) && r==11 && g==22 && b==33 && a==255);
    io=SDL_IOFromMem(storage,sizeof storage); CHECK(io!=NULL); CHECK(SDL_SaveBMP_IO(copy,io,false)); CHECK(SDL_SeekIO(io,0,SDL_IO_SEEK_SET)==0);
    bmp=SDL_LoadBMP_IO(io,true); CHECK(bmp!=NULL && bmp->w==8 && bmp->h==8);
    CHECK(SDL_ReadSurfacePixel(bmp,3,4,&r,&g,&b,&a) && r==11 && g==22 && b==33);
    SDL_DestroySurface(bmp); SDL_DestroySurface(copy); SDL_DestroySurface(surface);
    memory=SDL_malloc(8); CHECK(memory!=NULL); io=SDL_IOFromMem(memory,8); CHECK(io!=NULL);
    memcpy(&address,&release,sizeof address); CHECK(SDL_SetPointerProperty(SDL_GetIOProperties(io),SDL_PROP_IOSTREAM_MEMORY_FREE_FUNC_POINTER,address)); CHECK(SDL_CloseIO(io) && freed==1);
    for(i=0;i<64;++i) samples[i]=(Sint16)(i*200-6000);
    stream=SDL_CreateAudioStream(&input,&output); CHECK(stream!=NULL);
    CHECK(SDL_PutAudioStreamData(stream,samples,sizeof samples)); CHECK(SDL_FlushAudioStream(stream)); CHECK(SDL_GetAudioStreamAvailable(stream)>0);
    n=SDL_GetAudioStreamData(stream,floats,sizeof floats); CHECK(n>0 && n%(2*(int)sizeof(float))==0);
    for(i=0;i<n/(int)sizeof(float);i+=2) CHECK(floats[i]==floats[i+1] && floats[i]>=-1.0f && floats[i]<=1.0f);
    SDL_DestroyAudioStream(stream); SDL_Quit(); puts("SDL sort/thread/event/BMP/blit/free-callback/audio conversion OK"); return 0;
}
