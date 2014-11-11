//
//  MHSocialSharer.h
//  Quoted
//
//  Created by Michael Hulet on 10/14/14.
//  Copyright (c) 2014 Michael Hulet. All rights reserved.
//

@import Foundation;
@import Accounts;
@import Social;
@interface MHSocialSharer : NSObject
@property (strong, nonatomic) NSString *facebookAppID;
@property (strong, nonatomic) ACAccountStore *deviceAccounts;
-(instancetype)initWithFacebookAppID:(NSString *)id;
+(instancetype)sharerWithFacebookAppID:(NSString *)id;
-(SLComposeViewController *)facebookPostWithMessage:(NSString *)message;
-(SLComposeViewController *)tweetWithMessage:(NSString *)message;
-(NSError *)postToFacebookWithMessage:(NSString *)message;
@end