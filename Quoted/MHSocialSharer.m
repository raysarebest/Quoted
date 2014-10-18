//
//  MHSocialSharer.m
//  Quoted
//
//  Created by Michael Hulet on 10/14/14.
//  Copyright (c) 2014 Michael Hulet. All rights reserved.
//

#import "MHSocialSharer.h"
@interface MHSocialSharer()
-(SLComposeViewController *)shareSheetForNetwork:(NSString *)network withMessage:(NSString *)message;
@end
@implementation MHSocialSharer
-(SLComposeViewController *)facebookPostWithMessage:(NSString *)message{
    return [self shareSheetForNetwork:SLServiceTypeFacebook withMessage:message];
}
-(SLComposeViewController *)tweetWithMessage:(NSString *)message{
    return [self shareSheetForNetwork:SLServiceTypeTwitter withMessage:message];
}
-(SLComposeViewController *)shareSheetForNetwork:(NSString *)network withMessage:(NSString *)message{
    if([SLComposeViewController isAvailableForServiceType:network]){
        SLComposeViewController *post = [SLComposeViewController composeViewControllerForServiceType:network];
        [post setInitialText:message];
        return post;
    }
    return nil;
}
@end