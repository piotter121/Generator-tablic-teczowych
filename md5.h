#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef __APPLE__
#define COMMON_DIGEST_FOR_OPENSSL
#include <CommonCrypto/CommonDigest.h>
#define SHA1 CC_SHA1
#else
#include <openssl/md5.h>
#endif

char *md5(const char *, int);
