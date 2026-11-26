#include "check.h"
#include <stdint.h>
#include <string.h>
#include <math.h>
#include "cute_sound.h"
static void le16(unsigned char *p,unsigned value){p[0]=(unsigned char)value;p[1]=(unsigned char)(value>>8);}
static void le32(unsigned char *p,unsigned value){le16(p,value);le16(p+2,value>>16);}
int main(void) {
    unsigned char wav[44+256*2]; cs_error_t err; cs_audio_source_t *source,*disk;
    cs_sound_params_t params;cs_playing_sound_t playing;FILE *file;int i;
    memset(wav,0,sizeof(wav));memcpy(wav,"RIFF",4);le32(wav+4,sizeof(wav)-8);memcpy(wav+8,"WAVEfmt ",8);
    le32(wav+16,16);le16(wav+20,1);le16(wav+22,1);le32(wav+24,22050);le32(wav+28,44100);
    le16(wav+32,2);le16(wav+34,16);memcpy(wav+36,"data",4);le32(wav+40,512);
    for(i=0;i<256;++i)le16(wav+44+2*i,(unsigned)(i*127));
    REQUIRE(cs_init(44100,NULL)==CUTE_SOUND_ERROR_NONE);
    source=cs_read_mem_wav(wav,sizeof(wav),&err);REQUIRE(source && err==CUTE_SOUND_ERROR_NONE);
    REQUIRE(cs_get_sample_rate(source)==22050 && cs_get_sample_count(source)==256 && cs_get_channel_count(source)==1);
    file=fopen("audio.wav","wb");REQUIRE(file);REQUIRE(fwrite(wav,1,sizeof(wav),file)==sizeof(wav));fclose(file);
    disk=cs_load_wav("audio.wav",&err);REQUIRE(disk && cs_get_sample_count(disk)==256);remove("audio.wav");
    params=cs_sound_params_default();params.paused=true;params.looped=true;params.volume=.3f;params.pan=.25f;
    playing=cs_play_sound(source,params);REQUIRE(cs_sound_is_active(playing));
    REQUIRE(cs_sound_get_is_paused(playing) && cs_sound_get_is_looped(playing));
    REQUIRE(fabsf(cs_sound_get_volume(playing)-.3f)<1e-6f && fabsf(cs_sound_get_pan(playing)-.25f)<1e-6f);
    cs_sound_stop(playing);cs_update(0);cs_free_audio_source(source);cs_free_audio_source(disk);cs_shutdown();
    puts("cute_sound: WAV memory/file/sample metadata and dummy-device playback lifecycle PASS");return 0;
}
