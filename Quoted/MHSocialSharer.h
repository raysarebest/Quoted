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
-(void)post:(nonnull NSURLConnection *)post didFailWithError:(nonnull NSError *)error;
@optional
-(void)postSucceeded:(nonnull NSURLConnection *)post;
-(nonnull ACAccount *)accountForAccountType:(nonnull ACAccountType *)accountType;
@end
@interface MHSocialSharer : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@property (strong, nonatomic, nonnull) NSString *facebookAppID;
@property (strong, nonatomic, nonnull) ACAccountStore *deviceAccounts;
@property (strong, nonatomic, nonnull) NSMutableArray *requests;
@property (assign, nonatomic, nullable) id<NSObject, MHSocialDelegate> delegate;
-(nonnull instancetype)initWithFacebookAppID:(nonnull NSString *)appID;
+(nonnull instancetype)sharerWithFacebookAppID:(nonnull NSString *)appID;
-(nullable SLComposeViewController *)facebookPostWithMessage:(nonnull NSString *)message;
-(nullable SLComposeViewController *)tweetWithMessage:(nonnull NSString *)message;
-(BOOL)postToNetwork:(nonnull NSString *)network withMessage:(nonnull NSString *)message;
-(void)cancelPost:(nonnull NSURLConnection *)post;
@end