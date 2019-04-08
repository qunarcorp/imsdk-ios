//
// Created by may on 2017/10/20.
//

#ifndef WIDGET_AESTOOLS_H
#define WIDGET_AESTOOLS_H

typedef unsigned char uint8_t;

typedef enum _tag_aes_out_format {
    HEX, Base64,
} AESOutFormat;

//#ifndef uint8_t
//#define uint8_t char
//#endif


int AES_CBC_Encode_auto_bytes_int(const uint8_t *input, const int length, const char *password, uint8_t **bytesOutput);
//
//void AES_CBC_Encode_base64(const uint8_t *input, const int length, const char *password, char **base64Output);
//
//int AES_CBC_Encode_base64(const uint8_t *input, const int length, const char *password, char *base64Out);

/*
 *
 * AES_CBC_Decode
 * 此为手动分配内存的版本。
 * 需要分配足够大的缓冲区以保存输出文本
 */
//int AES_CBC_Encode_base64(uint8_t *bytesOutput, const uint8_t *input, const int length, const char *password);

/*
 *
 * AES_CBC_Decode
 * 此为手动分配内存的版本。
 * 需要分配足够大的缓冲区以保存输出文本
 */
extern int AES_CBC_Encode_base64(char *base64Output, const int outlen, const uint8_t *input, const int length, const char *password);
//
//
//void AES_CBC_Decode(const uint8_t *byteInput, const int length, const char *password, char **output);
//
//int AES_CBC_Decode(char *output, const int inputLen, const uint8_t *byteInput, const int length, const char *password);

/*
 *
 * AES_CBC_Decode
 * 此为自动分配内存的版本。
 * output是一个指向指针的指针，计算后包含输出值，用完后记得释放
 */
//void AES_CBC_Decode(const char *base64Input, const int length, const char *password, char **output);
//
//int AES_CBC_Decode_bytes(const uint8_t *input, const int length,
//        const char *password, char **output);
//
//
extern int AES_CBC_Decode_bytes(char *output, const int inputLen,
                                const uint8_t *input, const int length,
                                const char *password);

int AES_CBC_Decode_auto_bytes_int(const uint8_t *input, const int length, const char *password, char **output);


/*
 *
 * AES_CBC_Decode
 * 此为手动分配内存的版本。
 * 需要分配足够大的缓冲区以保存输出文本
 */
int AES_CBC_Decode_base64(char *output, const int inputLen,
                          const char *base64Input, const int length,
                          const char *password);

//
///*
// *
// * AES_CBC_Encode_base64
// * 此为自动分配内存的版本。
// * output是一个指向指针的指针，计算后包含输出值，用完后记得释放
// */
void AES_CBC_Encode_auto_bytes(uint8_t **output, int *outLen,
                               const uint8_t *input, const int length,
                               const char iv[32],
                               const char key[32]);

//
//
///*
// *
// * AES_CBC_Decode
// * 此为自动分配内存的版本。
// * output是一个指向指针的指针，计算后包含输出值，用完后记得释放
// */
void AES_CBC_Decode_auto_bytes(char **output, int *outLen,
                               const uint8_t *input, const int length,
                               const char iv[32],
                               const char key[32]);
//
/*
 *
 * AES_CBC_Encode_base64
 * 此为手动分配内存的版本。
 * 实现中并不会new内存，所以不需要考虑释放的问题
 * 输入参数的output必须足够长，你需要自己去计算生成后的长度，一般来说公式是：
 * outlen = (length / KEYLEN + 1) * KEYLEN;
 */
int
AES_CBC_Encode_base(uint8_t *output,
                    const uint8_t *input, const int length,
                    const char iv[32],
                    const char key[32]);

/*
 *
 * AES_CBC_Encode_base64
 * 此为手动分配内存的版本。
 * 实现中并不会new内存，所以不需要考虑释放的问题
 * 输入参数的output必须足够长，你需要自己去计算生成后的长度，一般来说公式是：
 * outlen = (length / KEYLEN + 1) * KEYLEN;
 */
int AES_CBC_Decode_base(char *output,
                        const uint8_t *input, const int length,
                        const char iv[32],
                        const char key[32]);



#endif //WIDGET_AESTOOLS_H
