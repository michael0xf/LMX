#include "PID.h"
#include "test.h"
#include <math.h>
int main(void) {
    PIDController pid = {.Kp=2.0f,.Ki=1.0f,.Kd=0.1f,.tau=0.02f,.limMin=-2.0f,.limMax=2.0f,.limMinInt=-1.5f,.limMaxInt=1.5f,.T=0.01f};
    PIDController_Init(&pid);
    float plant=0.0f;
    for (unsigned i=0;i<4000;++i) {
        const float out=PIDController_Update(&pid,1.0f,plant);
        CHECK(isfinite(out) && out>=pid.limMin && out<=pid.limMax);
        CHECK(pid.integrator>=pid.limMinInt && pid.integrator<=pid.limMaxInt);
        plant += 0.01f*(out-plant);
    }
    CHECK(fabsf(plant-1.0f)<0.002f);
    for (unsigned i=0;i<1000;++i) PIDController_Update(&pid,100.0f,0.0f);
    CHECK(pid.out==2.0f && pid.integrator==1.5f);
    PIDController_Init(&pid); pid.Kp=0.0f;pid.Ki=0.0f;
    CHECK(PIDController_Update(&pid,1.0f,0.0f)==0.0f);
    CHECK(PIDController_Update(&pid,10.0f,0.0f)==0.0f);
    pid.Kd=1.0f;pid.limMin=-100.0f;pid.limMax=100.0f;
    PIDController_Init(&pid);
    CHECK(fabsf(PIDController_Update(&pid,0.0f,1.0f)+40.0f)<0.0001f);
    CHECK(fabsf(PIDController_Update(&pid,0.0f,1.0f)+24.0f)<0.0001f);
    CHECK(fabsf(PIDController_Update(&pid,0.0f,1.0f)+14.4f)<0.0001f);
    PIDController_Init(&pid);
    for(unsigned i=0;i<1000;++i)PIDController_Update(&pid,0.0f,(float)i*pid.T);
    CHECK(fabsf(pid.differentiator+1.0f)<0.001f);
    puts("PID: plant/clamps/no kick plus derivative step decay and unit-ramp regression passed");
    return 0;
}
