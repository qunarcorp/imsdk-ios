//
// Created by may on 2017/10/20.
//

//typedef unsigned char uint8_t;


#include <string>
#include "AESTools.h"
#include "AES.h"
#include "Base64.h"

#include <stdlib.h>

#if defined(AES256) && (AES256 == 1)
#define Nk 8
#define KEYLEN 32
#define Nr 14
#define keyExpSize 240
#elif defined(AES192) && (AES192 == 1)
#define Nk 6
#define KEYLEN 24
#define Nr 12
#define keyExpSize 208
#else
#define Nk 4        // The number of 32 bit words in a key.
#define KEYLEN 16   // Key length in bytes
#define Nr 10       // The number of rounds in AES Cipher.
#define keyExpSize 176
#endif

static const char default_iv[]
= "6F5C7230B928CE27E9F7391B5D2B7E8B";

inline void makeKey(const char *input, char *key) {
    int bufferLen = 32;
    memset(key, 0, bufferLen);
    int pwLen = strlen(input);
    memcpy(key, input, pwLen > bufferLen ? bufferLen : pwLen);
}


int AES_CBC_Encode_auto_bytes_int(const uint8_t *input, const int length, const char *password, uint8_t **bytesOutput) {
    
    char key[32];
    makeKey(password, key);
    int len = 0;
    
    AES_CBC_Encode_auto_bytes(bytesOutput, &len, input, length, default_iv, key);
    return len;
}

/*
 *
 * AES_CBC_Decode
 * 此为手动分配内存的版本。
 * 需要分配足够大的缓冲区以保存输出文本
 */
int AES_CBC_Encode(uint8_t *bytesOutput, const uint8_t *input, const int length, const char *password) {
    
    char key[32];
    makeKey(password, key);
    
    return AES_CBC_Encode_base(bytesOutput, input, length, default_iv, key);
}

/*
 *
 * AES_CBC_Decode
 * 此为手动分配内存的版本。
 * 需要分配足够大的缓冲区以保存输出文本
 */
int AES_CBC_Encode_base64(char *base64Output, const int outlen, const uint8_t *input, const int length,
                          const char *password) {
    
    memset(base64Output, 0, outlen);
    
    uint8_t *output = NULL;
    int len = AES_CBC_Encode_auto_bytes_int(input, length, password, &output);
    
    base64_context context;
    base64_init(&context, len);
    int resultlen = 0;
    
    base64_encode(&context, output, len, base64Output, &resultlen);
    
    free(output);
    
    return resultlen;
}

void AES_CBC_Encode(const uint8_t *input, const int length, const char *password, char **base64Output) {
    char key[32];
    makeKey(password, key);
    
    uint8_t *bytesOutput = NULL;
    int len = 0;
    AES_CBC_Encode_auto_bytes(&bytesOutput, &len, input, length, default_iv, key);
    
    base64_context context;
    base64_init(&context, len);
    
    int maylen = len * 1.5;
    
    *base64Output = static_cast<char *>(malloc(maylen));
    
    int resultlen = 0;
    
    base64_encode(&context, bytesOutput, len, *base64Output, &resultlen);
    
}

int AES_CBC_Decode_base64(char *output, const int inputLen,
                          const char *input, const int length,
                          const char *password) {
    
    base64_context context;
    base64_init(&context, length);
    
    uint8_t *pBytes = static_cast<uint8_t *>(malloc(length));
    
    int resultlen = 0;
    
    base64_decode(&context, input, length, reinterpret_cast<char *>(pBytes), &resultlen);
    
    int resultLen = AES_CBC_Decode_bytes(output, inputLen, pBytes, resultlen, password);
    free(pBytes);
    
    return resultLen;
}

int AES_CBC_Decode_auto_bytes_int(const uint8_t *input, const int length, const char *password, char **output) {
    char key[32];
    makeKey(password, key);
    
    int len = (length / KEYLEN + 1) * KEYLEN;
    
    *output = static_cast<char *>(malloc(len));
    
    return AES_CBC_Decode_base(*output, input, length, default_iv, key);
}

int AES_CBC_Decode_bytes(char *output, const int inputLen,
                         const uint8_t *input, const int length,
                         const char *password) {
    char key[32];
    makeKey(password, key);
    
    memset(output, 0, inputLen);
    
    return AES_CBC_Decode_base(output, input, length, default_iv, key);
}


void AES_CBC_Decode(const char *base64Input, const int length, const char *password, char **output) {
    
    base64_context context;
    base64_init(&context, length);
    
    uint8_t *pBytes = static_cast<uint8_t *>(malloc(length));
    
    int resultlen = 0;
    
    base64_decode(&context, base64Input, length, reinterpret_cast<char *>(pBytes), &resultlen);
    
    AES_CBC_Decode_auto_bytes_int(pBytes, resultlen, password, output);
}

int AES_CBC_Decode(char *output, const int inputLen, const uint8_t *input, const int length, const char *password) {
    
    char key[32];
    makeKey(password, key);
    memset(output, 0, inputLen);
    
    return AES_CBC_Decode_base(output, input, length, default_iv, key);
}

void AES_CBC_Decode(const uint8_t *input, const int length, const char *password, char **output) {
    
    char key[32];
    makeKey(password, key);
    
    int len = 0;
    
    AES_CBC_Decode_auto_bytes(output, &len, input, length, default_iv, key);
}


void
AES_CBC_Encode_auto_bytes(uint8_t **output, int *outLen,
                          const uint8_t *input, const int length,
                          const char iv[32],
                          const char key[32]) {
    int newLength = length + 1;// 末尾补个0
    int len = (newLength / KEYLEN + 1) * KEYLEN;
    
    uint8_t *pInput = static_cast<uint8_t *>(malloc(newLength));
    memset(pInput, 0, newLength);
    memccpy(pInput, input, 0, newLength);
    
    *output = static_cast<uint8_t *>(malloc(len));
    *outLen = AES_CBC_Encode_base(*output, pInput, newLength, iv, key);
    free(pInput);
}

void AES_CBC_Decode_auto_bytes(char **output, int *outLen,
                               const uint8_t *input, const int length,
                               const char iv[32],
                               const char key[32]) {
    int len = (length / KEYLEN + 1) * KEYLEN;
    *output = static_cast<char *>(malloc(len));
    *outLen = AES_CBC_Decode_base(*output, input, length, iv, key);
}


/*
 *
 * AES_CBC_Encode_base64
 * 此为自己管理内存的版本。
 * 实现中并不会new内存，所以不需要考虑释放的问题
 * 输入参数的output必须足够长，你需要自己去计算生成后的长度，一般来说公式是：
 * outlen = (length / KEYLEN + 1) * KEYLEN;
 */
int AES_CBC_Encode_base(uint8_t *output,
                        const uint8_t *input, const int length,
                        const char iv[32],
                        const char key[32]) {
    
    if (input == NULL || length <= 0)
        return 0;
    
    int resultLen = (length / KEYLEN + 1) * KEYLEN;
    
    uint8_t *pItem = const_cast<uint8_t *>(input);
    
    uint8_t buffer[64];
    if (length <= KEYLEN) {
        
        AES_CBC_encrypt_buffer(buffer,
                               pItem, length,
                               reinterpret_cast<const uint8_t *>(key),
                               reinterpret_cast<const uint8_t *>(iv));
        memcpy(output, buffer, KEYLEN);
    } else {
        int remain = length;
        
        uint8_t *pDest = output;
        
        do {
            int perLength = remain - KEYLEN > 0 ? KEYLEN : remain;
            AES_CBC_encrypt_buffer(reinterpret_cast<uint8_t *>(buffer),
                                   pItem, perLength,
                                   reinterpret_cast<const uint8_t *>(key),
                                   reinterpret_cast<const uint8_t *>(iv));
            memcpy(pDest, buffer, KEYLEN);
            remain -= KEYLEN;
            
            if (remain <= 0)
                break;
            pDest += KEYLEN;
            pItem += perLength;
        } while (remain > 0);
    }
    
    return resultLen;
}

/*
 *
 * AES_CBC_Encode_base64
 * 此为自己管理内存的版本。
 * 实现中并不会new内存，所以不需要考虑释放的问题
 * 输入参数的output必须足够长，你需要自己去计算生成后的长度，一般来说公式是：
 * outlen = (length / KEYLEN + 1) * KEYLEN;
 */
int AES_CBC_Decode_base(char *output,
                        const uint8_t *input, const int length,
                        const char iv[32],
                        const char key[32]) {
    if (input == NULL || length <= 0)
        return 0;
    
    uint8_t buffer[64];
    
    uint8_t *pItem = const_cast<uint8_t *>(input);
    
    if (length <= KEYLEN) {
        
        AES_CBC_decrypt_buffer(buffer,
                               pItem, length,
                               reinterpret_cast<const uint8_t *>(key),
                               reinterpret_cast<const uint8_t *>(iv));
        memcpy(output, buffer, KEYLEN);
    } else {
        int remain = length;
        
        uint8_t *pDest = reinterpret_cast<uint8_t *>(output);
        
        do {
            int perLength = remain - KEYLEN > 0 ? KEYLEN : remain;
            AES_CBC_decrypt_buffer(reinterpret_cast<uint8_t *>(buffer),
                                   pItem, perLength,
                                   reinterpret_cast<const uint8_t *>(key),
                                   reinterpret_cast<const uint8_t *>(iv));
            memcpy(pDest, buffer, KEYLEN);
            remain -= KEYLEN;
            
            if (remain <= 0)
                break;
            
            pDest += KEYLEN;
            pItem += perLength;
            
        } while (remain > 0);
    }
    
    return strlen(output);
}


//void testAESTool() {
//
//    std::string message = "005年，密码学家就证明SHA-1的破解速度比预期提高了2000倍";
//
//    "，虽然破解仍然是极其困难和昂贵的，但随着计算机变得越来越快和越来越廉价，SHA-1算法的安全性也逐年降低，已被密码学家严重质疑，希望由安全强度更高的SHA-2替代它。\n"
//            "微软第一个宣布了SHA-1弃用计划，对于SSL证书和代码签名证书，微软设定了不同的替换时间表：\n"
//            "　　1、所有Windows受信任的根证书颁发机构(CA)从2016年1月1日起必须停止签发新的SHA-1签名算法SSL证书和代码签名证书；\n"
//            "　　2、对于SSL证书，Windows将于2017年1月1日起停止支持SHA1证书。也就是说：任何在之前签发的SHA-1证书必须替换成SHA-2证书；\n"
//            "　　3、对于代码签名证书，Windows将于2016年1月1日停止接受没有时间戳的SHA-1签名的代码和SHA-1证书。也就是说，Windows仍然接受在2016年1月1日之前使用SHA-1签名的已经加上RFC3161时间戳的代码，直到微软认为有可能出现SHA-1攻击时。";
//
//    char *base64Out = static_cast<char *>(malloc(65535));
//
//    int len = AES_CBC_Encode_base64(base64Out, 65535, (const uint8_t *) message.c_str(), message.length(), "asdf");
//
//    char *result = static_cast<char *>(malloc(65535));;
//
//    len = AES_CBC_Decode_base64(result, 65535, base64Out, len, "asdf");
//
//    free(base64Out);
//
//    free(result);
//
//}
