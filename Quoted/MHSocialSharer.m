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
-(NSURLConnection *)postMessageToFacebookAccount:(NSString *)message error:(NSError **)error;
-(void)removeConnection:(NSURLConnection *)connection;
-(NSURLRequest *)requestForMessage:(NSString *)message withAccount:(ACAccount *)account;
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
-(BOOL)postToFacebookWithMessage:(NSString *)message{
    __block NSURLConnection *post = nil;
    __block BOOL result = YES;
    __block NSError *globalError = nil;
    ACAccountType *facebook = [self.deviceAccounts accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    if(facebook.accessGranted == NO){
        [self.deviceAccounts requestAccessToAccountsWithType:facebook options:@{ACFacebookAppIdKey:self.facebookAppID, ACFacebookPermissionsKey:@[@"publish_actions"], ACFacebookAudienceKey:ACFacebookAudienceFriends} completion:^(BOOL granted, NSError *error){
            if(granted && error == nil){
                post = [self postMessageToFacebookAccount:message error:&globalError];
            }
            else{
                result = NO;
            }
        }];
    }
    else{
        //We're free to post, have fun
        post = [self postMessageToFacebookAccount:message error:&globalError];
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
-(NSURLConnection *)postMessageToFacebookAccount:(NSString *)message error:(NSError **)error{
    NSArray *accounts = [self.deviceAccounts accountsWithAccountType:[self.deviceAccounts accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook]];
    ACAccount *account = nil;
    if(accounts.count > 1){
#warning Need to Implement accountForAccountType: in View Controller
        if([(NSObject *)self.delegate respondsToSelector:@selector(accountForAccountType:)]){
            account = [self.delegate accountForAccountType:[self.deviceAccounts accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook]];
        }
    }
    else if(accounts.count == 1){
        account = accounts.lastObject;

    }
    else{
        *error = [NSError errorWithDomain:@"MHSocialError" code:404 userInfo:@{NSLocalizedDescriptionKey:@"No accounts found", NSLocalizedFailureReasonErrorKey:@"You are not logged into your Facebook account!", NSLocalizedRecoverySuggestionErrorKey:@"Please log into your Facebook account in the Settings app"}];
        return nil;
    }
    NSURLRequest *post = [self requestForMessage:message withAccount:account];
    if([NSURLConnection canHandleRequest:post]){
        return [[NSURLConnection alloc] initWithRequest:post delegate:self startImmediately:YES];
    }
    else{
        NSError *postError = [NSError errorWithDomain:@"MHSocialError" code:1 userInfo:@{NSLocalizedDescriptionKey:@"The post could not be completed", NSLocalizedDescriptionKey:@"An unknown error occurred", NSLocalizedRecoverySuggestionErrorKey:@"Please make sure you're connected to the internet and logged into your Facebook account in the Settings app"}];
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
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://graph.facebook.com/me/feed"] parameters:@{@"message":message}];
    request.account = account;
    return [request preparedURLRequest];
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
    //TODO: Account for networks other than Facebook
    if([connection.originalRequest.URL.absoluteString containsString:@"facebook"]){
        [self.delegate post:connection didFailWithError:error];
    }
    [self removeConnection:connection];
}
#pragma mark - NSURLConnectionDataDelegate Methods
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if([(NSObject *)self.delegate respondsToSelector:@selector(postSucceeded:)]){
        //TODO: Account for networks other than Facebook
        if([connection.originalRequest.URL.absoluteString containsString:@"facebook"]){
            [self.delegate postSucceeded:connection];
        }
    }
    [self removeConnection:connection];
}
@end