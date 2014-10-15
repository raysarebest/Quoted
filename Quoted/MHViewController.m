//
//  MHViewController.m
//  Quoted
//
//  Created by Michael Hulet on 8/19/14.
//  Copyright (c) 2014 Michael Hulet. All rights reserved.
//

#import "MHViewController.h"
#import "MHQuoter.h"
#import "MHColorPicker.h"
#import "MHSocialSharer.h"
@import AudioToolbox;
@import Social;
@interface MHViewController ()
-(void)randomQuoteWithVibration:(BOOL)vibration;
@end
@implementation MHViewController
//I'm supposed to add random animations into this app at some point, but I really don't feel like it. Maybe I'll do it later
#pragma mark - Object Initializers
-(MHQuoter *)quoter{
    if(!_quoter){
        _quoter = [[MHQuoter alloc] init];
    }
    return _quoter;
}
-(MHColorPicker *)colorPicker{
    if(!_colorPicker){
        _colorPicker = [[MHColorPicker alloc] init];
    }
    return _colorPicker;
}
-(MHSocialSharer *)social{
    if(!_social){
        _social = [[MHSocialSharer alloc] init];
    }
    return _social;
}
#pragma mark - Xcode Generated Code
-(void)viewDidLoad{
    [super viewDidLoad];
    [self randomQuoteWithVibration:NO];
    if(![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
        self.twitterButton.hidden = YES;
    }
    if(![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        self.facebookButton.hidden = YES;
    }
}
#pragma mark - Logic Essentials
-(void)randomQuoteWithVibration:(BOOL)vibration{
    NSDictionary *quote = [self.quoter randomQuote];
    NSString *author = [quote.allKeys objectAtIndex:0];
    self.quoteLabel.text = [quote objectForKey:author];
    self.authorLabel.text = [NSString stringWithFormat:@"- %@", author];
    UIColor *background = [self.colorPicker randomColorWithMinColorDifference:.4 andRandomnessSpecificity:UINT32_MAX andAlpha:1];
    self.view.backgroundColor = background;
    UIColor *textColor = [self.colorPicker textColorFromBackgroundColor:background];
    self.authorLabel.textColor = textColor;
    self.quoteLabel.textColor = textColor;
    if(vibration){
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}
#pragma mark - User Input Handling
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if(motion == UIEventSubtypeMotionShake){
        [self randomQuoteWithVibration:YES];
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self randomQuoteWithVibration:NO];
}
#pragma mark - Social Buttons
-(IBAction)postToFacebook:(UIButton *)sender{
    SLComposeViewController *post = [self.social facebookPostWithMessage:[NSString stringWithFormat:@"\"%@\"\n\n%@", self.quoteLabel.text, self.authorLabel.text]];
    if(post){
        [self presentViewController:post animated:YES completion:nil];
    }
}
-(IBAction)postToTwitter:(UIButton *)sender{
    SLComposeViewController *tweet = [self.social tweetWithMessage:[NSString stringWithFormat:@"\"%@\"\n\n%@", self.quoteLabel.text, self.authorLabel.text]];
    if(tweet){
        [self presentViewController:tweet animated:YES completion:nil];
    }
}
@end
