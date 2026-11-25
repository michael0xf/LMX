#include "Fusion.h"
#include "test.h"
#include <math.h>
int main(void) {
    FusionAhrs ahrs;
    FusionAhrsInitialise(&ahrs);
    FusionAhrsSettings settings = fusionAhrsDefaultSettings;
    settings.sampleRate = 100.0f;
    FusionAhrsSetSettings(&ahrs, &settings);
    const FusionVector zero = {.axis={0.0f,0.0f,0.0f}};
    const FusionVector gravity = {.axis={0.0f,0.0f,1.0f}};
    for (unsigned i=0;i<1000;++i) FusionAhrsUpdateNoMagnetometer(&ahrs,zero,gravity);
    FusionQuaternion q = FusionAhrsGetQuaternion(&ahrs);
    CHECK(fabsf(q.element.w-1.0f)<0.0001f);
    CHECK(fabsf(q.element.x)+fabsf(q.element.y)+fabsf(q.element.z)<0.0001f);
    const FusionVector linear=FusionAhrsGetLinearAcceleration(&ahrs);
    CHECK(fabsf(linear.axis.x)+fabsf(linear.axis.y)+fabsf(linear.axis.z)<0.0001f);
    FusionAhrsSkipStartup(&ahrs);
    const FusionVector turn = {.axis={0.0f,0.0f,90.0f}};
    for (unsigned i=0;i<100;++i) FusionAhrsUpdateNoMagnetometer(&ahrs,turn,gravity);
    const FusionEuler e = FusionQuaternionToEuler(FusionAhrsGetQuaternion(&ahrs));
    CHECK(fabsf(e.angle.yaw-90.0f)<0.1f);
    const FusionVector raw = {.axis={3.0f,5.0f,7.0f}};
    const FusionVector sensitivity = {.axis={2.0f,2.0f,2.0f}};
    const FusionVector offset = {.axis={1.0f,1.0f,1.0f}};
    const FusionVector calibrated = FusionModelInertial(raw,FUSION_MATRIX_IDENTITY,sensitivity,offset);
    CHECK(calibrated.axis.x==4.0f && calibrated.axis.y==8.0f && calibrated.axis.z==12.0f);
    puts("Fusion: stationary/90-degree synthetic IMU and calibration passed");
    return 0;
}
