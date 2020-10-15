//
//  SLTableViewController.m
//  SLFaceLandmarkDemo
//
//  Created by 远征 马 on 2020/8/20.
//  Copyright © 2020 马远征. All rights reserved.
//

#import "SLTableViewController.h"
#import <QMUIKit/QMUIKit.h>
#import <SLFaceLandmark/SLFaceLandmark.h>
#import <SLFaceLandmark/SLFaceLandmarkDetector.h>
//#import "SLFaceLandmark.h"
//#import "SLFaceLandmarkDetector.h"


@interface SLTableViewController ()  <QMUINavigationControllerDelegate>
@end


@implementation SLTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SLFaceLandmarkRegister(@"31586", @"aa9021a26dad477cbe0ce446555adb9c");
//    [SLFaceLandmark registerWithAppId:@"31586" appSecret:@"aa9021a26dad477cbe0ce446555adb9c"];
//    NSString *pubkey = @"-----BEGIN PUBLIC KEY-----\n"\
//    "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCsbm0rY8nYU/drarKAG9Rxl80Z\n"\
//    "rP2CSn4MS3Hxx7/hPWVeiKx/XCuE2D0vJFDwBxjkawF5XN46fddgpiPTJfSYdnZ/\n"\
//    "uzfUwPGFwgB9nuxlvO8Fwi5/mRiE5Of9DSuAOO/yfVksp0hnVbGjJcK2Ov7SFH7O\n"\
//    "aU1gzuYs5TBePf9X9wIDAQAB\n"\
//    "-----END PUBLIC KEY-----";
//    NSString *src = @"1234567890";
//    NSString *dest;
//    int ret = SLRSAEncryptWithPublicKey(pubkey,src, &dest, 1);
//    NSLog(@"---ret--[%@]",@(ret));
//    NSLog(@"---dest---%@",dest);
//
//
//    NSString *privatePem = [[NSBundle mainBundle]pathForResource:@"rsa_private_key_pkcs8" ofType:@"pem"];
//
//    NSString *decrypt;
//    ret = SLRSADecryptWithPrivateKeyFile(privatePem, dest, &decrypt, 1);
//    NSLog(@"---ret--[%@]",@(ret));
//    NSLog(@"---decrypt---%@",decrypt);
    
//    NSString *publicPem = [[NSBundle mainBundle]pathForResource:@"rsa_public_key" ofType:@"pem"];
//    int ret = SLRSAEncryptWithPublicKeyFile(publicPem, src, &dest, 1);
//    NSLog(@"---ret--[%@]",@(ret));
//    NSLog(@"---dest---%@",dest);
    
//    NSString *base64PubKey = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC2/36nQTAJKRF6HEcIg7T7qrgTaYLdO1JrYUB8F3X83a+f5/Epcsww/VYvId29lgGyy7hawy294LIYxicYwyQaq8lI8ojhGF0D4u81gp+eW9pe69rvLKUVBq4r4hkxVqNgn4avZScyqxlELZdWwgzZONAcsgjMl5UNA75EAg8nIQIDAQAB";
//    NSData *pbData = [[NSData alloc]initWithBase64EncodedString:base64PubKey options:NSDataBase64DecodingIgnoreUnknownCharacters];
//    NSString *pubKey = [[NSString alloc]initWithData:pbData encoding:NSUTF8StringEncoding];
//    NSLog(@"--base64 pubKey--%@",pubKey);
//
//    NSString *base64Source = @"10101afd55f877bad4aaeab45fb4ca567d2343uuidstr159843053708315981984000001598976000000qqqqqqqqqqqqqqqqqqqqqqqqqq";
//    NSString *base64Sign = @"HEpFPHAYp3XFBME81B2C9oICIO/0Qg1sgyto0YIo3t25dzpND8q600U4EmRilLBVrQpj9TWzi8jDc0UkG6mn/TaeCK4SuS630JQ35377Ttzmzhas8Jkuyqz2vcjv49FYidg5wlQLej9zFJb/l+Ckx7TBJBhF/N4oRK+IUniOQH8=";
//    NSData *signdata = [[NSData alloc]initWithBase64EncodedString:base64Sign options:NSDataBase64DecodingIgnoreUnknownCharacters];
//    NSString *sign = [[NSString alloc]initWithData:signdata encoding:NSUTF8StringEncoding];
//    NSLog(@"--base64 sign--%@",sign);
//    int ret =  SLSignProviderSHA1Verify(pubKey, base64Source, sign);
//    NSLog(@"--ret---【%@】",@(ret));
//
//    SLSignProvider *provider = [[SLSignProvider alloc]init];
//    ret = [provider sha1Verify:pubKey src:base64Source sign:sign];
//    NSLog(@"--ret---【%@】",@(ret));
//    // Uncomment the following line to preserve selection between presentations.
//    // self.clearsSelectionOnViewWillAppear = NO;
//
//    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//    [self encryptPrivateAndDecryptPublic];
}

- (void)encryptPrivateAndDecryptPublic {
//    NSString *key = @"-----BEGIN PRIVATE KEY-----\n"\
//    "MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAKxubStjydhT92tq\n"\
//    "soAb1HGXzRms/YJKfgxLcfHHv+E9ZV6IrH9cK4TYPS8kUPAHGORrAXlc3jp912Cm\n"\
//    "I9Ml9Jh2dn+7N9TA8YXCAH2e7GW87wXCLn+ZGITk5/0NK4A47/J9WSynSGdVsaMl\n"\
//    "wrY6/tIUfs5pTWDO5izlMF49/1f3AgMBAAECgYAuhw2GK8MHUIDuxzerQdctX5zE\n"\
//    "VN2DDr68ao8wgonQKVT1EUQaibBkhETeN5pvajrZR9Z5/QkqF1LKjYoVK6S4Hbgi\n"\
//    "sKbrkgSpp6KtWfUganeN9/ND1E1vj5x4VA6UQ/o8eyUw6CUgh8BeNnwIk5Q4dQ1T\n"\
//    "XEjLYI7ROOJmBbG4AQJBANWyI79ozHJrViJcsosy0zCPTkcx3j6I7nm7PqiQt5O0\n"\
//    "Hzp825yvLcUoehMV+F02lwUmhIKMgKep91fgq5BqUQECQQDOkQyVd2sUcQ4mYYj/\n"\
//    "bA+DoW7fyEl1pG99tD5ManxnpNvtT1+65CUNqA2zRaAqnHQi5B/Wthwuf9/42ORN\n"\
//    "OzD3AkA+djdkt2kq+JzQpm+5qD16sCidPsJLXRL3mfeSpdpC3h9SpTQ79ChYvKAR\n"\
//    "/BYAiPhTlRKeZhsk5tVZZl4/dBQBAkEAxn9qKUMtGeKeJ1G4tUIhEmuRwOeVd8AB\n"\
//    "BzmqWAJH88zfLgcFRfGwjZP9PlVc2TWpAFJZKhmrsR9emaHKmVCU9wJBAMFgqXt4\n"\
//    "/mK842UNKg2C5IU8iOH/N74BkZoVNo2btbfUOkR+S38+eAPbXWOmZkoCUU0MP+rq\n"\
//    "AEftLCnlIIKUg3Q=\n"\
//    "-----END PRIVATE KEY-----";
//    NSString *src = @"1234567890";
//    NSString *dest;
//    int ret = SLRSAEncryptWithPrivateKey(key, src, &dest, 1);
//    NSLog(@"---ret--[%@]",@(ret));
//    NSLog(@"---dest---%@",dest);
//
//
//    NSString *publicPem = [[NSBundle mainBundle]pathForResource:@"rsa_public_key" ofType:@"pem"];
//    NSString *decrypt;
//    ret = SLRSADecryptWithPublicKeyFile(publicPem, dest, &decrypt, 1);
//    NSLog(@"---ret--[%@]",@(ret));
//    NSLog(@"---decrypt---%@",decrypt);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

#pragma mark - delegate

- (nullable UIColor *)navigationBarTintColor {
    return [UIColor orangeColor];
}

- (UIImage*)navigationBarBackgroundImage {
    UIColor *color = [UIColor qmui_colorWithHexString:@"#FF4275"];
    CGSize size = CGSizeMake(SCREEN_WIDTH, 88);
    UIImage *image = [UIImage qmui_imageWithColor:color size:size cornerRadius:0];
    return image;
}

- (UIImage*)navigationBarShadowImage {
    UIColor *color = [UIColor qmui_colorWithHexString:@"#E1E1E1"];
    CGSize size = CGSizeMake(SCREEN_WIDTH, 0.5);
    UIImage *image = [UIImage qmui_imageWithColor:color size:size cornerRadius:0];
    return image;
}

- (BOOL)preferredNavigationBarHidden {
    return NO;
}

- (BOOL)shouldCustomizeNavigationBarTransitionIfHideable {
    return YES;
}

- (BOOL)shouldHideKeyboardWhenTouchInView:(UIView *)view {
    return YES;
}

- (BOOL)forceEnableInteractivePopGestureRecognizer {
    return YES;
}
@end
