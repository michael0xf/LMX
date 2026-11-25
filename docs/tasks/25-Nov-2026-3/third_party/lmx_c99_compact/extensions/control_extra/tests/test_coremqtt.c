#include "core_mqtt_serializer.h"
#include "test.h"
#include <string.h>
int main(void) {
    uint8_t bytes[128]={0};MQTTFixedBuffer_t buffer={.pBuffer=bytes,.size=sizeof(bytes)};
    uint32_t length=0,size=0;
    CHECK(MQTT_GetPingreqPacketSize(&size)==MQTTSuccess&&size==2);
    CHECK(MQTT_SerializePingreq(&buffer)==MQTTSuccess&&bytes[0]==0xc0&&bytes[1]==0);
    const char topic[]="base/telemetry";const uint8_t payload[]={0,1,2,255};
    MQTTPublishInfo_t info={.qos=MQTTQoS1,.pTopicName=topic,.topicNameLength=sizeof(topic)-1,.pPayload=payload,.payloadLength=sizeof(payload)};
    CHECK(MQTT_GetPublishPacketSize(&info,NULL,&length,&size,sizeof(bytes))==MQTTSuccess);
    CHECK(length==23&&size==25);
    CHECK(MQTT_SerializePublish(&info,NULL,0x1234,length,&buffer)==MQTTSuccess);
    CHECK(bytes[0]==0x32&&bytes[1]==23&&bytes[2]==0&&bytes[3]==14);
    CHECK(bytes[18]==0x12&&bytes[19]==0x34&&bytes[20]==0);
    MQTTPacketInfo_t packet={.type=bytes[0],.pRemainingData=bytes+2,.remainingLength=length,.headerLength=2};
    MQTTPublishInfo_t decoded={0};uint16_t id=0;MQTTPropBuilder_t properties={0};
    CHECK(MQTT_DeserializePublish(&packet,&id,&decoded,&properties,sizeof(bytes),0)==MQTTSuccess);
    CHECK(id==0x1234&&decoded.qos==MQTTQoS1&&decoded.topicNameLength==sizeof(topic)-1);
    CHECK(memcmp(decoded.pTopicName,topic,decoded.topicNameLength)==0);
    CHECK(decoded.payloadLength==sizeof(payload)&&memcmp(decoded.pPayload,payload,sizeof(payload))==0);
    const MQTTFixedBuffer_t too_small={.pBuffer=bytes,.size=1};
    CHECK(MQTT_SerializePingreq(&too_small)==MQTTNoMemory);
    uint8_t malformed[]={0,9,'x'};packet.pRemainingData=malformed;packet.remainingLength=sizeof(malformed);
    CHECK(MQTT_DeserializePublish(&packet,&id,&decoded,&properties,sizeof(bytes),0)!=MQTTSuccess);
    puts("coreMQTT: MQTT5 QoS1 byte vector/round trip, ping, short buffers passed");
    return 0;
}
