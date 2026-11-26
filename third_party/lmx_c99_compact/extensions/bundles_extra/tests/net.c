#include "check.h"
#include <string.h>
#include "cute_net.h"
int main(void) {
    cn_endpoint_t a,b; char text[128]; cn_crypto_sign_public_t pk; cn_crypto_sign_secret_t sk;
    cn_crypto_key_t send_key, receive_key; unsigned char token[CN_CONNECT_TOKEN_SIZE];
    const char *addresses[] = {"127.0.0.1:39991"}; cn_client_t *client;
    REQUIRE(cn_endpoint_init(&a,addresses[0]) == 0); cn_endpoint_to_string(a,text,sizeof(text));
    REQUIRE(cn_endpoint_init(&b,text) == 0 && cn_endpoint_equals(a,b));
    cn_crypto_sign_keygen(&pk,&sk); send_key=cn_crypto_generate_key(); receive_key=cn_crypto_generate_key();
    REQUIRE(!cn_is_error(cn_generate_connect_token(42,0,&send_key,&receive_key,1000,10,1,addresses,99,NULL,&sk,token)));
    client=cn_client_create(0,42,false,NULL); REQUIRE(client);
    REQUIRE(!cn_is_error(cn_client_connect(client,token))); cn_client_disconnect(client); cn_client_destroy(client);
    puts("cute_net: endpoint/key/token/client lifecycle PASS");return 0;
}
