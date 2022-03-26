#include <stdio.h>
#include <openssl/ssl.h>
#include <openssl/err.h>
#include <openssl/bio.h>
#include <string.h>

#define APIKEY "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"

#define HOST "agguro.be"

#define PORT "443"

int main() {

    //
    //  Initialize the variables
    //
    BIO* bio;
    SSL* ssl;
    SSL_CTX* ctx;

    //
    //   Registers the SSL/TLS ciphers and digests.
    //
    //   Basically start the security layer.
    //
    SSL_library_init();

    //
    //  Creates a new SSL_CTX object as a framework to establish TLS/SSL
    //  or DTLS enabled connections
    //
    ctx = SSL_CTX_new(SSLv23_client_method());

    //
    //  -> Error check
    //
    if (ctx == NULL)
    {
        printf("Ctx is null\n");
    }

    //
    //   Creates a new BIO chain consisting of an SSL BIO
    //
    bio = BIO_new_ssl_connect(ctx);

    //
    //  Use the variable from the beginning of the file to create a 
    //  string that contains the URL to the site that you want to connect
    //  to while also specifying the port.
    //
    BIO_set_conn_hostname(bio, HOST ":" PORT);

    //
    //   Attempts to connect the supplied BIO
    //
    if(BIO_do_connect(bio) <= 0)
    {
        printf("Failed connection\n");
        return 1;
    }
    else
    {
        printf("Connected\n");
    }

    //
    //  The bare minimum to make a HTTP request.
    //
    char* write_buf = "POST / HTTP/1.1\r\n"
                      "Host: " HOST "\r\n"
                      "Authorization: Basic " APIKEY "\r\n"
                      "Connection: close\r\n"
                      "\r\n";

    //
    //   Attempts to write len bytes from buf to BIO
    //
    if(BIO_write(bio, write_buf, strlen(write_buf)) <= 0)
    {
        //
        //  Handle failed writes here
        //
        if(!BIO_should_retry(bio))
        {
            // Not worth implementing, but worth knowing.
        }

        //
        //  -> Let us know about the failed writes
        //
        printf("Failed write\n");
    }

    //
    //  Variables used to read the response from the server
    //
    int size;
    char buf[1024];

    //
    //  Read the response message
    //
    for(;;)
    {
        //
        //  Get chunks of the response 1023 at the time.
        //
        size = BIO_read(bio, buf, 1023);

        //
        //  If no more data, then exit the loop
        //
        if(size <= 0)
        {
            break;
        }

        //
        //  Terminate the string with a 0, to let know C when the string 
        //  ends.
        //
        buf[size] = 0;

        //
        //  ->  Print out the response
        //
        printf("%s", buf);
    }

    //
    //  Clean after ourselves
    //
    BIO_free_all(bio);
    SSL_CTX_free(ctx);

    return 0;
}
