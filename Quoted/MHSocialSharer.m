//
//  MHSocialSharer.m
//  Quoted
//
//  Created by Michael Hulet on 10/14/14.
//  Copyright (c) 2014 Michael Hulet. All rights reserved.
//

//Facebook App ID: 1523804647867642
#import "MHSocialSharer.h"
@interface MHSocialSharer()
-(SLComposeViewController *)shareSheetForNetwork:(NSString *)network message:(NSString *)message;
-(NSError *)postMessageToFacebookAccount:(ACAccountType *)facebook message:(NSString *)message;
-(void)executeOptionalDelegateMethod:(SEL)method;
@end
@implementation MHSocialSharer
#pragma mark - Initializers
-(instancetype)initWithFacebookAppID:(NSString *)appID{
    self.facebookAppID = appID;
    return self;
}
+(instancetype)sharerWithFacebookAppID:(NSString *)appID{
    return [[self alloc] initWithFacebookAppID:appID];
}
#pragma mark - User Editable Posts
-(SLComposeViewController *)facebookPostWithMessage:(NSString *)message{
    return [self shareSheetForNetwork:SLServiceTypeFacebook message:message];
}
-(SLComposeViewController *)tweetWithMessage:(NSString *)message{
    return [self shareSheetForNetwork:SLServiceTypeTwitter message:message];
}
-(SLComposeViewController *)shareSheetForNetwork:(NSString *)network message:(NSString *)message{
    if([SLComposeViewController isAvailableForServiceType:network]){
        SLComposeViewController *post = [SLComposeViewController composeViewControllerForServiceType:network];
        [post setInitialText:message];
        return post;
    }
    return nil;
}
#pragma mark - App Dictated Posts
-(NSError *)postToFacebookWithMessage:(NSString *)message{
    __block NSError *globalError = nil;
    ACAccountType *facebook = [self.deviceAccounts accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary *options = @{ACFacebookAppIdKey:self.facebookAppID, ACFacebookPermissionsKey:@[@"publish_actions"], ACFacebookAudienceKey:ACFacebookAudienceFriends};
    if(facebook.accessGranted == NO){
        [self.deviceAccounts requestAccessToAccountsWithType:facebook options:options completion:^(BOOL granted, NSError *error){
            if(granted && error == nil){
                globalError = [self postMessageToFacebookAccount:facebook message:message];
            }
            else if (granted == YES && error != nil){
                globalError = error;
            }
            else{
                globalError = [NSError errorWithDomain:@"FBUserAuth" code:403 userInfo:nil];
            }
        }];
    }
    else{
        //We're free to post, have fun
        globalError = [self postMessageToFacebookAccount:facebook message:message];
    }
    return globalError;
}
#pragma mark - Private Helper Methods
-(NSError *)postMessageToFacebookAccount:(ACAccountType *)facebook message:(NSString *)message{
    __block NSError *globalError = nil;
    NSArray *accounts = [self.deviceAccounts accountsWithAccountType:facebook];
    ACAccount * account = [accounts lastObject];
    NSDictionary *params = @{@"message":message};
    NSURL *feed = [NSURL URLWithString:@"https://graph.facebook.com/me/feed"];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodPOST URL:feed parameters:params];
    request.account = account;
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error){
        if(error){
            globalError = error;
        }
    }];
    return globalError;
}
-(void)executeOptionalDelegateMethod:(SEL)method{
    NSObject *delegate = (NSObject *)self.delegate;
    if([delegate respondsToSelector:method]){
        //Apple LLVM generates a warning here. performSelector may cause a leak because the selector is unknown. If anything terrible happens here, find this file in the "Compile Sources" section of the "Build Phases" tab in the Project Navigator, and delete the only flag that's there
        [delegate performSelector:method];
    }
}
#pragma mark - Property Lazy Instantiation
-(ACAccountStore *)deviceAccounts{
    if(!_deviceAccounts){
        _deviceAccounts = [[ACAccountStore alloc] init];
    }
    return _deviceAccounts;
}
@end