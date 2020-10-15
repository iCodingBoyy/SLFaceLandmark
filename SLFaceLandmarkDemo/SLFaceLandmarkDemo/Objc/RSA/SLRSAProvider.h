//
//  SLRSAProvider.h
//  SLFaceLandmarkDemo
//
//  Created by myz on 2020/8/28.
//  Copyright © 2020 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - 公钥加密，私钥解密
/// 公钥加密
/// @param key 公钥
/// @param src 待加密字符串
/// @param dest 加密的base64字符串
/// @param padding RSA_Padding
/// @return 返回-1代表错误，正确则返回加密字节的长度
FOUNDATION_EXPORT int SLRSAEncryptWithPublicKey(NSString *key, NSString *src, NSString **dest, int padding);


/// 公钥加密
/// @param filePath 文件路径
/// @param src 待加密字符串
/// @param dest 加密的base64字符串
/// @param padding RSA_Padding
/// @return 返回-1代表错误，正确则返回加密字节的长度
FOUNDATION_EXPORT int SLRSAEncryptWithPublicKeyFile(NSString *filePath, NSString *src, NSString **dest, int padding);


/// 私钥解密
/// @param key 私钥
/// @param src 待解密的base64字符串
/// @param dest 解密的字符串
/// @param padding RSA_Padding
/// @return 返回-1代表错误，正确则返回解密字节的长度
FOUNDATION_EXPORT int SLRSADecryptWithPrivateKey(NSString *key, NSString *src, NSString **dest, int padding);


/// 私钥解密
/// @param filePath 私钥文件路径
/// @param src 待解密的base64字符串
/// @param dest 解密的字符串
/// @param padding RSA_Padding
/// @return 返回-1代表错误，正确则返回解密字节的长度
FOUNDATION_EXPORT int SLRSADecryptWithPrivateKeyFile(NSString *filePath, NSString *src, NSString **dest, int padding);


#pragma mark - 私钥加密，公钥解密
/// 私钥加密
/// @param key 私钥
/// @param src 待加密字符串
/// @param dest 加密的base64字符串
/// @param padding RSA_Padding
/// @return 返回-1代表错误，正确则返回加密字节的长度
FOUNDATION_EXPORT int  SLRSAEncryptWithPrivateKey(NSString *key, NSString *src, NSString **dest, int padding);


/// 私钥加密
/// @param filePath 私钥
/// @param src 待加密字符串
/// @param dest 加密的base64字符串
/// @param padding RSA_Padding
/// @return 返回-1代表错误，正确则返回加密字节的长度
FOUNDATION_EXPORT int  SLRSAEncryptWithPrivateKeyFile(NSString *filePath, NSString *src, NSString **dest, int padding);


/// 公钥解密
/// @param keyObject 公钥NSData字节或者字符串
/// @param src 待解密的base64字符串
/// @param dest 解密的字符串
/// @param padding RSA_Padding
/// @return 返回-1代表错误，正确则返回解密字节的长度
FOUNDATION_EXPORT int SLRSADecryptWithPublicKey(id keyObject, NSString *src, NSString **dest, int padding);


/// 公钥解密
/// @param filePath 公钥
/// @param src 待解密的base64字符串
/// @param dest 解密的字符串
/// @param padding RSA_Padding
/// @return 返回-1代表错误，正确则返回解密字节的长度
FOUNDATION_EXPORT int SLRSADecryptWithPublicKeyFile(NSString *filePath, NSString *src, NSString **dest, int padding);



#pragma mark - sign

FOUNDATION_EXPORT int SLRSASignWithPrivateKey(NSString *key, NSString *src, NSString **dest);

FOUNDATION_EXPORT int SLRSASignWithPrivateKeyFile(NSString *filePath, NSString *src, NSString **dest);


#pragma mark - sha1 公钥验证

/// rsa sha1 签名验证
FOUNDATION_EXPORT int SLRSASha1VerifyWithPublicKey(id key, NSString *src, NSString *sign);

FOUNDATION_EXPORT int SLRSASha1VerifyWithPublicKeyFile(NSString *filePath, NSString *src, NSString **dest);


#pragma mark - 服务器公钥、私钥转换PEM格式字符串

/// 服务器端公钥或者私钥base64字符串
/// @param base64Key 不带begin、end格式和\n的秘钥字符
FOUNDATION_EXPORT NSString *SLRSAPEMKeyFromBase64(NSString *base64Key, BOOL isPublicKey);



#pragma mark - SLRSAProvider

@interface SLRSAProvider : NSObject

@end

