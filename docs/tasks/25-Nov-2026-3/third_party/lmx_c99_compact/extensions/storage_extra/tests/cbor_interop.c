/* SPDX-License-Identifier: 0BSD */
#include "cbor.h"
#include "qcbor/qcbor_encode.h"
#include "qcbor/qcbor_spiffy_decode.h"
#include "check.h"
#include <string.h>
static const char text[]="\320\237\321\200\320\270\320\262\320\265\321\202";
static const unsigned char binary[]={0,255,128,17};
static int tiny_read(const unsigned char *p,size_t len) {
    CborParser parser;CborValue v,a;int64_t num;double d;bool b;char str[32];unsigned char bytes[8];size_t n;
    CHECK(cbor_parser_init(p,len,0,&parser,&v)==CborNoError);
    CHECK(cbor_value_is_array(&v));CHECK(cbor_value_enter_container(&v,&a)==CborNoError);
    CHECK(cbor_value_get_int64(&a,&num)==CborNoError && num==-42);CHECK(cbor_value_advance(&a)==CborNoError);
    n=sizeof str;CHECK(cbor_value_copy_text_string(&a,str,&n,&a)==CborNoError);CHECK(n==strlen(text) && !strcmp(str,text));
    CHECK(cbor_value_get_double(&a,&d)==CborNoError && d==1.5);CHECK(cbor_value_advance(&a)==CborNoError);
    CHECK(cbor_value_get_boolean(&a,&b)==CborNoError && b);CHECK(cbor_value_advance(&a)==CborNoError);
    n=sizeof bytes;CHECK(cbor_value_copy_byte_string(&a,bytes,&n,&a)==CborNoError);
    CHECK(n==sizeof binary && !memcmp(bytes,binary,n));CHECK(cbor_value_at_end(&a));
    CHECK(cbor_value_leave_container(&v,&a)==CborNoError);CHECK(cbor_value_at_end(&v));return 0;
}
static int qcbor_read(const unsigned char *p,size_t len) {
    QCBORDecodeContext ctx;UsefulBufC t,binary_out;int64_t num;double d;bool b;
    QCBORDecode_Init(&ctx,(UsefulBufC){p,len},QCBOR_DECODE_MODE_NORMAL);
    QCBORDecode_EnterArray(&ctx,NULL);QCBORDecode_GetInt64(&ctx,&num);QCBORDecode_GetTextString(&ctx,&t);
    QCBORDecode_GetDouble(&ctx,&d);QCBORDecode_GetBool(&ctx,&b);QCBORDecode_GetByteString(&ctx,&binary_out);
    QCBORDecode_ExitArray(&ctx);CHECK(QCBORDecode_Finish(&ctx)==QCBOR_SUCCESS);
    CHECK(num==-42 && d==1.5 && b);CHECK(t.len==strlen(text) && !memcmp(t.ptr,text,t.len));
    CHECK(binary_out.len==sizeof binary && !memcmp(binary_out.ptr,binary,binary_out.len));return 0;
}
int main(void) {
    unsigned char qb[128],tb[128];QCBOREncodeContext qc;UsefulBufC encoded;CborEncoder t,a;size_t len;
    QCBORDecodeContext qd;CborParser parser;CborValue value;
    QCBOREncode_Init(&qc,(UsefulBuf){qb,sizeof qb});QCBOREncode_OpenArray(&qc);
    QCBOREncode_AddInt64(&qc,-42);QCBOREncode_AddSZString(&qc,text);QCBOREncode_AddDoubleNoPreferred(&qc,1.5);
    QCBOREncode_AddBool(&qc,true);QCBOREncode_AddBytes(&qc,(UsefulBufC){binary,sizeof binary});QCBOREncode_CloseArray(&qc);
    CHECK(QCBOREncode_Finish(&qc,&encoded)==QCBOR_SUCCESS);CHECK(tiny_read(encoded.ptr,encoded.len)==0);
    cbor_encoder_init(&t,tb,sizeof tb,0);CHECK(cbor_encoder_create_array(&t,&a,5)==CborNoError);
    CHECK(cbor_encode_int(&a,-42)==CborNoError);CHECK(cbor_encode_text_stringz(&a,text)==CborNoError);
    CHECK(cbor_encode_double(&a,1.5)==CborNoError);CHECK(cbor_encode_boolean(&a,true)==CborNoError);
    CHECK(cbor_encode_byte_string(&a,binary,sizeof binary)==CborNoError);
    CHECK(cbor_encoder_close_container_checked(&t,&a)==CborNoError);
    len=cbor_encoder_get_buffer_size(&t,tb);CHECK(qcbor_read(tb,len)==0);
    /* Truncation must fail validation in both independent decoders. */
    QCBORDecode_Init(&qd,(UsefulBufC){tb,len-1},QCBOR_DECODE_MODE_NORMAL);
    {QCBORItem item;while(QCBORDecode_GetNext(&qd,&item)==QCBOR_SUCCESS){} }
    CHECK(QCBORDecode_Finish(&qd)!=QCBOR_SUCCESS);
    CHECK(cbor_parser_init(qb,encoded.len-1,0,&parser,&value)==CborNoError);
    CHECK(cbor_value_validate(&value,CborValidateBasic)!=CborNoError);
    /* Exercise the selected upstream software binary16 encode/decode path. */
    cbor_encoder_init(&t,tb,sizeof tb,0);
    CHECK(cbor_encode_float_as_half_float(&t,1.5f)==CborNoError);
    len=cbor_encoder_get_buffer_size(&t,tb);
    CHECK(len==3 && tb[0]==0xf9 && tb[1]==0x3e && tb[2]==0);
    CHECK(cbor_parser_init(tb,len,0,&parser,&value)==CborNoError);
    { float half=0; double decoded=0;
      CHECK(cbor_value_is_half_float(&value));
      CHECK(cbor_value_get_half_float_as_float(&value,&half)==CborNoError && half==1.5f);
      QCBORDecode_Init(&qd,(UsefulBufC){tb,len},QCBOR_DECODE_MODE_NORMAL);
      QCBORDecode_GetDouble(&qd,&decoded);
      CHECK(QCBORDecode_Finish(&qd)==QCBOR_SUCCESS && decoded==1.5);
    }
    return 0;
}
