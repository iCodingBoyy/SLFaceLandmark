//
//  SLRSAProvider.m
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/8/28.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLRSAProvider.h"
#include <openssl/rsa.h>
#include <openssl/pem.h>
#include <openssl/evp.h>
#include <openssl/err.h>
#include <openssl/bio.h>


#pragma mark - 公钥、私钥读取

RSA *SLRSAReadKeyFromBio(BIO *bio, NSString *key, BOOL isPublicKey) {
    if (bio == NULL) {
        return NULL;
    }
    if (!isPublicKey) {
        RSA *rsa = PEM_read_bio_RSAPrivateKey(bio, NULL, NULL, NULL);
        BIO_free_all(bio);
        return rsa;
    }
    NSString *pkcs1_header = @"-----BEGIN RSA PUBLIC KEY-----";
//    NSString *pkcs8_header = @"-----BEGIN PUBLIC KEY-----";
    RSA *rsa = NULL;
    if (key && [key containsString:pkcs1_header]) {
        rsa = PEM_read_bio_RSAPublicKey(bio, &rsa, NULL, NULL);
    }
    else {
        rsa = PEM_read_bio_RSA_PUBKEY(bio, NULL, NULL, NULL);
    }
    BIO_free_all(bio);
    return rsa;
}

RSA *SLRSAReadKey(id keyObject, BOOL isPublicKey) {
    if (!keyObject) {
        return NULL;
    }
    BIO *bio = NULL;
    NSString *key = nil;
    if ([keyObject isKindOfClass:[NSData class]]) {
        NSData *keyData = (NSData*)keyObject;
        bio = BIO_new_mem_buf((const void*)[keyData bytes], (int)keyData.length);
    }
    else if ([keyObject isKindOfClass:[NSString class]]) {
        key = (NSString*)keyObject;
        const char *buffer = [key UTF8String];
        bio = BIO_new_mem_buf(buffer, (int)strlen(buffer));
    }
    if (bio == NULL) {
        NSLog(@"--bio new mem buf failed--");
        return NULL;
    }
    return SLRSAReadKeyFromBio(bio, key, isPublicKey);
}

RSA *SLRSAReadKeyFromFile(NSString *filePath, BOOL isPublicKey) {
    if (filePath.length <= 0) {
        return NULL;
    }
    NSData *keyData = [[NSData alloc]initWithContentsOfFile:filePath];
    NSString *key = [[NSString alloc]initWithData:keyData encoding:NSUTF8StringEncoding];
    NSLog(@"---key---%@",key);
    BIO *bio = BIO_new(BIO_s_mem());
    BIO_puts(bio, (void*)[keyData bytes]);
    return SLRSAReadKeyFromBio(bio, key, isPublicKey);
}

#pragma mark - 加密

int SLRSAEncrypt(BOOL isPublic, RSA *rsa, NSString *src, NSString **dest, int padding) {
    if (rsa == NULL || src.length <= 0 || dest == NULL) {
        if (rsa) RSA_free(rsa);
        return -1;
    }
    int flen = RSA_size(rsa);
    char *dst = (char*)malloc(flen + 1);
    bzero(dst, flen);
    NSData *srcData = [src dataUsingEncoding:NSUTF8StringEncoding];
    int ret = -1;
    if (isPublic) {
        ret = RSA_public_encrypt((int)srcData.length, (uint8_t*)[srcData bytes], (uint8_t*)dst, rsa, padding);
    }
    else {
        ret = RSA_private_encrypt((int)srcData.length, (uint8_t*)[srcData bytes], (uint8_t*)dst, rsa, padding);
    }
    if (ret < 0) {
        isPublic ? NSLog(@"--rsa public encrypt failed--") : NSLog(@"--ras private encrypt failed--");
        RSA_free(rsa);
        free(dst);
        return ret;
    }
    NSData *encryptData = [NSData dataWithBytes:(const void*)dst length:sizeof(char)*flen];
    *dest = [encryptData base64EncodedStringWithOptions:0];
    RSA_free(rsa);
    free(dst);
    return ret;
}

int SLRSADecrypt(BOOL isPublic, RSA *rsa, NSString *src, NSString **dest, int padding) {
    if (rsa == NULL || src.length <= 0 || dest == NULL) {
        if (rsa) RSA_free(rsa);
        return -1;
    }
    int flen = RSA_size(rsa);
    char *dst = (char*)malloc(flen + 1);
    bzero(dst, flen);
    
    NSData *srcData = [[NSData alloc]initWithBase64EncodedString:src options:0];
    int ret = -1;
    if (isPublic) {
        ret = RSA_public_decrypt((int)srcData.length, (uint8_t*)[srcData bytes], (uint8_t*)dst, rsa, padding);
    }
    else {
        ret = RSA_private_decrypt((int)srcData.length, (uint8_t*)[srcData bytes], (uint8_t*)dst, rsa, padding);
    }
    if (ret < 0) {
        isPublic ? NSLog(@"--rsa public encrypt failed--") : NSLog(@"--ras private encrypt failed--");
        RSA_free(rsa);
        free(dst);
        return ret;
    }
    NSData *decryptData = [NSData dataWithBytes:(const void*)dst length:sizeof(char)*flen];
    *dest = [[NSString alloc]initWithData:decryptData encoding:NSUTF8StringEncoding];
    RSA_free(rsa);
    free(dst);
    return ret;
}

#pragma mark - 公钥加密、私钥解密

int SLRSAEncryptWithPublicKey(NSString *publicKey, NSString *src, NSString **dest, int padding) {
    if (publicKey.length <= 0 || src.length <= 0 || dest == NULL) {
        NSLog(@"--input invalid parameters--");
        return -1;
    }
    RSA *rsa = SLRSAReadKey(publicKey, YES);
    if (rsa == NULL) {
        NSLog(@"--read rsa public key from bio failed--");
        return -1;
    }
    int ret = SLRSAEncrypt(YES, rsa, src, dest, padding);
    return ret;
}

int SLRSAEncryptWithPublicKeyFile(NSString *filePath, NSString *src, NSString **dest, int padding) {
    if (filePath.length <= 0 || src.length <= 0 || dest == NULL) {
        NSLog(@"--input invalid parameters--");
        return -1;
    }
    RSA *rsa = SLRSAReadKeyFromFile(filePath, YES);
    if (rsa == NULL) {
        NSLog(@"--read rsa public key from bio failed--");
        return -1;
    }
    return SLRSAEncrypt(YES, rsa, src, dest, padding);
}

int SLRSADecryptWithPrivateKey(NSString *privateKey, NSString *src, NSString **dest, int padding) {
    if (privateKey.length <= 0 || src.length <= 0 || dest == NULL) {
        NSLog(@"--input invalid parameters--");
        return -1;
    }
    RSA *rsa = SLRSAReadKey(privateKey, NO);
    if (rsa == NULL) {
        NSLog(@"--read rsa private key from bio failed--");
        return -1;
    }
    return SLRSADecrypt(NO, rsa, src, dest, padding);
}


int SLRSADecryptWithPrivateKeyFile(NSString *filePath, NSString *src, NSString **dest, int padding) {
    if (filePath.length <= 0 || src.length <= 0 || dest == NULL) {
        NSLog(@"--input invalid parameters--");
        return -1;
    }
    RSA *rsa = SLRSAReadKeyFromFile(filePath, NO);
    if (rsa == NULL) {
        NSLog(@"--read rsa private key from bio failed--");
        return -1;
    }
    return SLRSADecrypt(NO, rsa, src, dest, padding);
}

#pragma mark - 私钥加密，公钥解密

int  SLRSAEncryptWithPrivateKey(NSString *key, NSString *src, NSString **dest, int padding) {
    if (key.length <= 0 || src.length <= 0 || dest == NULL) {
        NSLog(@"--input invalid parameters--");
        return -1;
    }
    RSA *rsa = SLRSAReadKey(key, NO);
    if (rsa == NULL) {
        NSLog(@"--read rsa private key from bio failed--");
        return -1;
    }
    return SLRSAEncrypt(NO, rsa, src, dest, padding);
}

int  SLRSAEncryptWithPrivateKeyFile(NSString *filePath, NSString *src, NSString **dest, int padding) {
    if (filePath.length <= 0 || src.length <= 0 || dest == NULL) {
        NSLog(@"--input invalid parameters--");
        return -1;
    }
    RSA *rsa = SLRSAReadKeyFromFile(filePath, NO);
    if (rsa == NULL) {
        NSLog(@"--read rsa private key from bio failed--");
        return -1;
    }
    return SLRSAEncrypt(NO, rsa, src, dest, padding);
}

int SLRSADecryptWithPublicKey(id keyObject, NSString *src, NSString **dest, int padding) {
    if ( !keyObject || src.length <= 0 || dest == NULL) {
        NSLog(@"--input invalid parameters--");
        return -1;
    }
    RSA *rsa = SLRSAReadKey(keyObject, YES);
    if (rsa == NULL) {
        NSLog(@"--read rsa public key from bio failed--");
        return -1;
    }
    return SLRSADecrypt(YES, rsa, src, dest, padding);
}

int SLRSADecryptWithPublicKeyFile(NSString *filePath, NSString *src, NSString **dest, int padding) {
    if (filePath.length <= 0 || src.length <= 0 || dest == NULL) {
        NSLog(@"--input invalid parameters--");
        return -1;
    }
    RSA *rsa = SLRSAReadKeyFromFile(filePath, YES);
    if (rsa == NULL) {
        NSLog(@"--read rsa public key from bio failed--");
        return -1;
    }
    return SLRSADecrypt(YES, rsa, src, dest, padding);
}

#pragma mark - sha1 公钥验证

int SLRSASha1SignWithKey(id key, NSString *src, NSString **sign) {
    if ( !key || src.length <= 0 || sign == NULL) {
        return -1;
    }
    RSA *rsa = SLRSAReadKey(key, NO);
    if (rsa == NULL) {
        NSLog(@"--read rsa private key from bio failed--");
        return -1;
    }
    NSData *srcData = [src dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char digest[SHA_DIGEST_LENGTH];
    SHA1((const unsigned char *) [srcData bytes], (size_t)srcData.length, digest);
    
    unsigned char *signValue = (unsigned char *)malloc(256);
    unsigned int sign_len;
    
    int ret = RSA_sign(NID_sha1, digest, SHA_DIGEST_LENGTH, signValue, &sign_len, rsa);
    if (ret == 1) {
        NSData* data = [NSData dataWithBytes:signValue length:sign_len];
        *sign = [data base64EncodedStringWithOptions:0];
    }
    free(signValue);
    RSA_free(rsa);
    return ret;
}

int SLRSASha1VerifyWithPublicKey(id key, NSString *src, NSString *sign) {
    if ( !key || src.length <= 0 || sign.length <= 0) {
        return -1;
    }
    RSA *rsa = SLRSAReadKey(key, YES);
    if (rsa == NULL) {
        NSLog(@"--read rsa public key from bio failed--");
        return -1;
    }
    NSData *srcData = [src dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char digest[SHA_DIGEST_LENGTH];
    SHA1((const unsigned char *) [srcData bytes], (size_t)srcData.length, digest);
    
//    SHA_CTX sha_ctx = { 0 };
//    unsigned char digest[SHA_DIGEST_LENGTH];
//    int rc = 1;
//    rc = SHA1_Init(&sha_ctx);
//    if (1 != rc) { return NO; }
//
//    rc = SHA1_Update(&sha_ctx, [srcData bytes], srcData.length);
//    if (1 != rc) { return NO; }
//
//    rc = SHA1_Final(digest, &sha_ctx);
//    if (1 != rc) { return NO; }
    NSData *signData = [[NSData alloc]initWithBase64EncodedString:sign options:0];
    int ret = RSA_verify(NID_sha1, digest, SHA_DIGEST_LENGTH, (const uint8_t*)[signData bytes], (uint32_t)signData.length, rsa);
    RSA_free(rsa);
    return ret;
}


#pragma mark - 秘钥转换提取

NSString *SLRSAPEMKeyFromBase64(NSString *base64Key, BOOL isPublicKey) {
    NSMutableString *result = [NSMutableString string];
    if (isPublicKey) {
        [result appendString:@"-----BEGIN PUBLIC KEY-----\n"];
    }else{
        [result appendString:@"-----BEGIN RSA PRIVATE KEY-----\n"];
    }
    [result appendString:@""""];
    int count = 0;
    for (int i = 0; i < [base64Key length]; ++i) {
        unichar c = [base64Key characterAtIndex:i];
        if (c == '\n' || c == '\r') {
            continue;
        }
        [result appendFormat:@"%c", c];
        if (++count == 64) {
            [result appendString:@"\n"];
            [result appendString:@""""];
            count = 0;
        }
    }
    if (isPublicKey) {
        [result appendString:@"\n-----END PUBLIC KEY-----"];
    }else{
        [result appendString:@"\n-----END RSA PRIVATE KEY-----"];
    }
    return result;
}

@implementation SLRSAProvider

@end
