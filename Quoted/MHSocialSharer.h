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
@protocol MHSocialDelegate
@optional
-(void)facebookPostDidFailWithError:(NSError *)error;
@end
@interface MHSocialSharer : NSObject
@property (strong, nonatomic) NSString *facebookAppID;
@property (strong, nonatomic) ACAccountStore *deviceAccounts;
@property (strong, nonatomic) id<MHSocialDelegate> delegate;
-(instancetype)initWithFacebookAppID:(NSString *)id;
+(instancetype)sharerWithFacebookAppID:(NSString *)id;
-(SLComposeViewController *)facebookPostWithMessage:(NSString *)message;
-(SLComposeViewController *)tweetWithMessage:(NSString *)message;
-(NSError *)postToFacebookWithMessage:(NSString *)message;
@end