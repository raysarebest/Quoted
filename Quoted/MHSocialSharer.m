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
-(NSURLConnection *)postMessageToFacebookAccount:(ACAccountType *)facebook message:(NSString *)message error:(NSError **)error;
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
-(void)postToFacebookWithMessage:(NSString *)message{
    __block NSURLConnection *post = nil;
    __block NSError *globalError = nil;
    ACAccountType *facebook = [self.deviceAccounts accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary *options = @{ACFacebookAppIdKey:self.facebookAppID, ACFacebookPermissionsKey:@[@"publish_actions"], ACFacebookAudienceKey:ACFacebookAudienceFriends};
    if(facebook.accessGranted == NO){
        [self.deviceAccounts requestAccessToAccountsWithType:facebook options:options completion:^(BOOL granted, NSError *error){
            if(granted && error == nil){
                post = [self postMessageToFacebookAccount:facebook message:message error:&globalError];
                if(globalError){
                    if([(NSObject *)self.delegate respondsToSelector:@selector(postToService:didFailWithError:)]){
                        [self.delegate postToService:SLServiceTypeFacebook didFailWithError:globalError];
                    }
                }
            }
            else if (granted == YES && error != nil){
                if([(NSObject *)self.delegate respondsToSelector:@selector(postToService:didFailWithError:)]){
                    [self.delegate postToService:SLServiceTypeFacebook didFailWithError:error];
                }
            }
            else{
                if([(NSObject *)self.delegate respondsToSelector:@selector(postToService:didFailWithError:)]){
                    [self.delegate postToService:SLServiceTypeFacebook didFailWithError:[NSError errorWithDomain:@"FBUserAuth" code:403 userInfo:nil]];
                }
            }
        }];
    }
    else{
        //We're free to post, have fun
        post = [self postMessageToFacebookAccount:facebook message:message error:&globalError];
        if(globalError){
            if([(NSObject *)self.delegate respondsToSelector:@selector(postToService:didFailWithError:)]){
                [self.delegate postToService:SLServiceTypeFacebook didFailWithError:globalError];
            }
        }
    }
    if(post){
        [self.requests addObject:post];
    }
}
#pragma mark - Private Helper Methods
-(NSURLConnection *)postMessageToFacebookAccount:(ACAccountType *)facebook message:(NSString *)message error:(NSError **)error{
    NSArray *accounts = [self.deviceAccounts accountsWithAccountType:facebook];
    ACAccount *account = nil;
    if(accounts.count > 1){
        if([(NSObject *)self.delegate respondsToSelector:@selector(accountForAccountType:)]){
            account = [self.delegate accountForAccountType:facebook];
        }
    }
    else if(accounts.count == 1){
        account = accounts.lastObject;
    }
    else{
        *error = [NSError errorWithDomain:@"MHNotFoundError" code:404 userInfo:@{NSLocalizedDescriptionKey:@"No accounts found", NSLocalizedFailureReasonErrorKey:@"You are not logged into your Facebook account!", NSLocalizedRecoverySuggestionErrorKey:@"Please log into your Facebook account in the Settings app"}];
        return nil;
    }
    NSDictionary *params = @{@"message":message};
    NSURL *feed = [NSURL URLWithString:@"https://graph.facebook.com/me/feed"];
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodPOST URL:feed parameters:params];
    request.account = account;
//    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error){
//        if(error){
//            globalError = error;
//        }
//    }];
    NSURLConnection *post = [[NSURLConnection alloc] initWithRequest:[request preparedURLRequest] delegate:self startImmediately:YES];
    [self.requests addObject:post];
    return post;
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
@end