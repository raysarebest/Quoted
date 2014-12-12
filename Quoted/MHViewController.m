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
@property (strong, nonatomic) NSMutableArray *banners;
-(void)randomQuoteWithVibration:(BOOL)vibration;
-(void)quoteAreaWasTapped;
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
        _social = [MHSocialSharer sharerWithFacebookAppID:@"1523804647867642"];
    }
    return _social;
}
-(NSMutableArray *)banners{
    if(!_banners){
        _banners = [[NSMutableArray alloc] init];
    }
    return _banners;
}
#pragma mark - View Setup Code
-(void)viewDidLoad{
    [super viewDidLoad];
    [self randomQuoteWithVibration:NO];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(quoteAreaWasTapped)];
    tap.numberOfTapsRequired = 1;
    tap.cancelsTouchesInView = NO;
    [self.textView addGestureRecognizer:tap];
    [self.textView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [self.textView addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil];
    self.textView.scrollEnabled = YES;
    self.canDisplayBannerAds = YES;
    self.social.delegate = self;
}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self layoutSocialButtons];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self layoutSocialButtons];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self layoutSocialButtons];
}
-(void)layoutSocialButtons{
    if(![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
        self.twitterButton.hidden = YES;
    }
    else{
        self.twitterButton.hidden = NO;
    }
    if(![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        self.facebookButton.hidden = YES;
        if(!self.twitterButton.hidden){
            self.twitterButton.center = self.facebookButton.center;
        }
    }
    else{
        self.facebookButton.hidden = NO;
        if(!self.twitterButton.hidden){
            self.twitterButton.center = CGPointMake(self.facebookButton.center.x - 57, self.facebookButton.center.y);
        }
    }
}
#pragma mark - Logic Essentials
-(void)randomQuoteWithVibration:(BOOL)vibration{
    NSDictionary *quote = [self.quoter randomQuote];
    NSString *author = [quote.allKeys objectAtIndex:0];
    self.textView.text = [quote objectForKey:author];
    self.authorLabel.text = [NSString stringWithFormat:@"- %@", author];
    self.authorLabel.accessibilityLabel = self.authorLabel.text;
    UIColor *background = [self.colorPicker randomColorWithMinColorDifference:.4 randomnessSpecificity:UINT32_MAX andAlpha:1];
    if(self.canDisplayBannerAds){
        self.originalContentView.backgroundColor = background;
    }
    else{
        self.view.backgroundColor = background;
    }
    self.textView.backgroundColor = background;
    UIColor *textColor = [self.colorPicker textColorFromBackgroundColor:background];
    self.authorLabel.textColor = textColor;
    self.textView.textColor = textColor;
    self.textView.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:30];
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
-(void)quoteAreaWasTapped{
    [self randomQuoteWithVibration:NO];
}
#pragma mark - Social Buttons
-(IBAction)postToFacebook:(UIButton *)sender{
    MHAlertBannerView *banner = [MHAlertBannerView bannerWithBannerStyle:MHAlertBannerViewStyleFacebookPost];
    banner.delegate = self;
    if([self.social postToFacebookWithMessage:[NSString stringWithFormat:@"\"%@\"\n\n%@", self.textView.text, self.authorLabel.text]]){
        banner.watchedObject = self.social.requests.lastObject;
        NSLog(@"%@\n\n%@", banner.watchedObject, self.social.requests.lastObject);
        [self.view addSubview:banner];
        [banner presentBanner];
        [self.banners addObject:banner];
    }
    else{
        [banner presentBanner];
        [banner operationFailed];
    }
}
-(IBAction)postToTwitter:(UIButton *)sender{
    SLComposeViewController *tweet = [self.social tweetWithMessage:[NSString stringWithFormat:@"\"%@\"\n\n%@", self.textView.text, self.authorLabel.text]];
    if(tweet){
        [self presentViewController:tweet animated:YES completion:nil];
    }
}
#pragma mark - UI Helper Methods
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    CGFloat topCorrect = (self.textView.bounds.size.height - self.textView.contentSize.height * self.textView.zoomScale)/2.0;
    topCorrect = (topCorrect < 0.0 ? 0.0 : topCorrect);
    self.textView.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
}
#pragma mark - MHAlertBannerViewDelegate Methods
-(void)alertDidCancel:(MHAlertBannerView *)alert{
    [self.social cancelPost:alert.watchedObject];
}
#pragma mark - MHSocialDelegate Methods
-(void)post:(NSURLConnection *)post didFailWithError:(NSError *)error{
    NSLog(@"Post Failed");
    for(MHAlertBannerView *banner in self.banners){
        if(banner.watchedObject == post){
            [banner operationFailed];
            [self.banners removeObject:banner];
        }
    }
}
-(void)postSucceeded:(NSURLConnection *)post{
    NSLog(@"Post Succeeded");
    for(MHAlertBannerView *banner in self.banners){
        if(banner.watchedObject == post){
            [banner operationSucceeded];
            [self.banners removeObject:banner];
        }
    }
}
@end