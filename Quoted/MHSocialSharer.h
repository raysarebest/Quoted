//
//  MHSocialSharer.h
//  Quoted
//
//  Created by Michael Hulet on 10/14/14.
//  Copyright (c) 2014 Michael Hulet. All rights reserved.
//

@import Foundation;
@import Social;
@interface MHSocialSharer : NSObject
-(SLComposeViewController *)facebookPostWithMessage:(NSString *)message;
-(SLComposeViewController *)tweetWithMessage:(NSString *)message;
@end