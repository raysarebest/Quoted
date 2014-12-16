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
-(NSURLConnection *)postMessageToNetwork:(NSString *)network message:(NSString *)message error:(NSError **)error;
-(void)removeConnection:(NSURLConnection *)connection;
-(NSURLRequest *)requestForMessage:(NSString *)message withAccount:(ACAccount *)account;
-(BOOL)preflightPostForAccountType:(ACAccountType *)type completion:(void(^)(BOOL))handler;
@end
@implementation MHSocialSharer
#pragma mark - Initializers
-(instancetype)initWithFacebookAppID:(NSString *)appID{
    if(self = [super init]){
        self.facebookAppID = appID;
        return self;
    }
    return nil;
}
+(instancetype)sharerWithFacebookAppID:(NSString *)appID{
    static MHSocialSharer *singleton = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        singleton = [[self alloc] initWithFacebookAppID:appID];
    });
    return singleton;
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
-(BOOL)postToNetwork:(NSString *)network withMessage:(NSString *)message{
    __block NSURLConnection *post = nil;
    __block BOOL result = NO;
    __block NSError *globalError = nil;
    ACAccountType *accountType = [self.deviceAccounts accountTypeWithAccountTypeIdentifier:network];
    if(!accountType.accessGranted){
        NSDictionary *options = nil;
        if([network isEqualToString:ACAccountTypeIdentifierFacebook]){
            options = @{ACFacebookAppIdKey:self.facebookAppID, ACFacebookPermissionsKey:@[@"publish_actions"], ACFacebookAudienceKey:ACFacebookAudienceFriends};
        }
        [self.deviceAccounts requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted, NSError *error){
            if(granted && error == nil){
                post = [self postMessageToNetwork:network message:message error:&globalError];
            }
            else{
                result = NO;
            }
            if(post){
                [self.requests addObject:post];
            }
            if(globalError){
                result = NO;
            }
        }];
    }
    else{
        //We're free to post, have fun
        post = [self postMessageToNetwork:network message:message error:&globalError];
        result = YES;
    }
    if(post){
        [self.requests addObject:post];
    }
    if(globalError){
        result = NO;
    }
    return result;
}
-(void)cancelPost:(NSURLConnection *)post{
    if([self.requests containsObject:post]){
        [post cancel];
        [self.requests removeObject:post];
    }
}
#pragma mark - Private Helper Methods
-(NSURLConnection *)postMessageToNetwork:(NSString *)network message:(NSString *)message error:(NSError **)error{
    NSString *networkName;
    if([network isEqualToString:ACAccountTypeIdentifierFacebook]){
        networkName = @"Facebook";
    }
    //If support for more networks is added in the future, support will need to be added here
    else if([network isEqualToString:ACAccountTypeIdentifierTwitter]){
        networkName = @"Twitter";
    }
    NSArray *accounts = [self.deviceAccounts accountsWithAccountType:[self.deviceAccounts accountTypeWithAccountTypeIdentifier:network]];
    ACAccount *account = nil;
    if(accounts.count > 1){
        if([(NSObject *)self.delegate respondsToSelector:@selector(accountForAccountType:)]){
            account = [self.delegate accountForAccountType:[self.deviceAccounts accountTypeWithAccountTypeIdentifier:network]];
        }
    }
    else if(accounts.count == 1){
        account = accounts.lastObject;

    }
    else{
        *error = [NSError errorWithDomain:@"MHSocialError" code:404 userInfo:@{NSLocalizedDescriptionKey:@"No accounts found", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"You are not logged into your %@ account!", networkName], NSLocalizedRecoverySuggestionErrorKey:[NSString stringWithFormat:@"Please log into your %@ account in the Settings app", networkName]}];
        return nil;
    }
    NSURLRequest *post = [self requestForMessage:message withAccount:account];
    if([NSURLConnection canHandleRequest:post]){
        return [[NSURLConnection alloc] initWithRequest:post delegate:self startImmediately:YES];
    }
    else{
        NSError *postError = [NSError errorWithDomain:@"MHSocialError" code:1 userInfo:@{NSLocalizedDescriptionKey:@"The post could not be completed", NSLocalizedDescriptionKey:@"An unknown error occurred", NSLocalizedRecoverySuggestionErrorKey:[NSString stringWithFormat:@"Please make sure you're connected to the internet and logged into your %@ account in the Settings app", networkName]}];
        [self.delegate post:[[NSURLConnection alloc] initWithRequest:post delegate:nil startImmediately:NO] didFailWithError:postError];
        *error = postError;
        return nil;
    }
}
-(void)removeConnection:(NSURLConnection *)connection{
    if([self.requests containsObject:connection]){
        [self.requests removeObject:connection];
    }
}
-(NSURLRequest *)requestForMessage:(NSString *)message withAccount:(ACAccount *)account{
    NSString *networkAddress;
    NSString *service;
    NSDictionary *params;
    //If support for more networks is added in the future, support will need to be added here, too
    if([account.accountType.identifier isEqualToString:ACAccountTypeIdentifierFacebook]){
        networkAddress = @"https://graph.facebook.com/me/feed";
        service = SLServiceTypeFacebook;
        params = @{@"message":message};
    }
    else if([account.accountType.identifier isEqualToString:ACAccountTypeIdentifierTwitter]){
        networkAddress = @"https://api.twitter.com/1.1/statuses/update.json";
        service = SLServiceTypeTwitter;
        params = @{@"status":message};
    }
    SLRequest *request = [SLRequest requestForServiceType:service requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:networkAddress] parameters:params];
    request.account = account;
    return [request preparedURLRequest];
}
-(BOOL)preflightPostForAccountType:(ACAccountType *)type completion:(void (^)(BOOL))handler{
    //FIXME: Change this
    return NO;
}
#pragma mark - Property Lazy Instantiation
-(ACAccountStore *)deviceAccounts{
    if(!_deviceAccounts){
        _deviceAccounts = [[ACAccountStore alloc] init];
    }
    return _deviceAccounts;
}
-(NSMutableArray *)requests{
    if(!_requests){
        _requests = [[NSMutableArray alloc] init];
    }
    return _requests;
}
#pragma mark - NSURLConnectionDelegate Methods
-(BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection{
    return NO;
}
-(void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    [challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self.delegate post:connection didFailWithError:error];
    [self removeConnection:connection];
}
#pragma mark - NSURLConnectionDataDelegate Methods
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if([(NSObject *)self.delegate respondsToSelector:@selector(postSucceeded:)]){
        [self.delegate postSucceeded:connection];
    }
    [self removeConnection:connection];
}
@end