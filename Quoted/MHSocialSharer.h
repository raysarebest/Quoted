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
-(void)postToService:(NSString *)service didFailWithError:(NSError *)error;
-(void)postToService:(NSString *) didSucceed;
@optional
-(ACAccount *)accountForAccountType:(ACAccountType *)accountType;
@end
@interface MHSocialSharer : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@property (strong, nonatomic) NSString *facebookAppID;
@property (strong, nonatomic) ACAccountStore *deviceAccounts;
@property (strong, nonatomic) NSMutableArray *requests;
@property (assign, nonatomic) id<MHSocialDelegate> delegate;
-(instancetype)initWithFacebookAppID:(NSString *)appID;
+(instancetype)sharerWithFacebookAppID:(NSString *)appID;
-(SLComposeViewController *)facebookPostWithMessage:(NSString *)message;
-(SLComposeViewController *)tweetWithMessage:(NSString *)message;
-(void)postToFacebookWithMessage:(NSString *)message;
@end