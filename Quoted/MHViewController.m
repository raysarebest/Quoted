//
//  MHViewController.m
//  Quoted
//
//  Created by Michael Hulet on 8/19/14.
//  Copyright (c) 2014 Michael Hulet. All rights reserved.
//

#import "MHViewController.h"
@import QuoteKit;
@import AudioToolbox;
@import Social;
@interface MHViewController ()
@property (strong, nonatomic) NSMutableArray *banners;
@property (strong, nonatomic) ACAccount *preferredAccount;
@property (copy) void (^accountSelectionCompletion)(ACAccount *);
-(BOOL)sizeIsPortrait:(CGSize)size;
-(void)randomQuoteWithVibration:(BOOL)vibration;
-(void)quoteAreaWasTapped;
-(void)selectAccountForAccountType:(ACAccountType *)type completion:(void (^)(ACAccount *))handler;
-(void)presentBannerWithStyle:(MHAlertBannerViewStyle)style failure:(BOOL)status;
-(void)postQuoteToNetwork:(NSString *)network;
@end
@implementation MHViewController
//Generic posting message constants
static NSString *const MHFacebookPostSuccessMessage = @"Posted!";
static NSString *const MHFacebookPostFailureMessage = @"Post to Facebook Failed!";
static NSString *const MHTweetSuccessMessage = @"Tweeted!";
static NSString *const MHTweetFailureMessage = @"Tweet Failed!";
//I'm supposed to add random animations into this app at some point, but I really don't feel like it. Maybe I'll do it later
#pragma mark - Property Lazy Instantiation
-(MHSocialSharer *)social{
    if(!_social){
        _social = [MHSocialSharer sharerWithFacebookAppID:@"1523804647867642"];
    }
    return _social;
}
-(ACAccount *)preferredAccount{
    if(!_preferredAccount){
        _preferredAccount = [[ACAccount alloc] init];
    }
    return _preferredAccount;
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
    self.textView.backgroundColor = [UIColor clearColor];
    if([self sizeIsPortrait:self.view.frame.size]){
        if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
            self.textView.textAlignment = NSTextAlignmentLeft;
            self.authorLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    else{
        self.textView.textAlignment = NSTextAlignmentCenter;
        self.authorLabel.textAlignment = NSTextAlignmentCenter;
    }
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
    MHQuote *quote = [MHQuote randomQuote];
    self.textView.text = quote.quote;
    self.authorLabel.text = [@"- " stringByAppendingString:quote.author];
    self.authorLabel.accessibilityLabel = quote.author;
    UIColor *background = [MHColorPicker randomColorWithMinColorDifference:.4 randomnessSpecificity:UINT32_MAX alpha:1];
    if(self.canDisplayBannerAds){
        self.originalContentView.backgroundColor = background;
    }
    else{
        self.view.backgroundColor = background;
    }
    UIColor *textColor = [MHColorPicker textColorFromBackgroundColor:background];
    self.authorLabel.textColor = textColor;
    self.textView.textColor = textColor;
    self.textView.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:30];
    if(vibration){
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}
-(void)postQuoteToNetwork:(NSString *)network{
    //If support for more networks is added in the future, it will need to be added here, too
    MHAlertBannerViewStyle style = MHAlertBannerViewStyleCustom;
    if([network isEqualToString:ACAccountTypeIdentifierFacebook]){
        style = MHAlertBannerViewStyleFacebookPost;
    }
    else if([network isEqualToString:ACAccountTypeIdentifierTwitter]){
        style = MHAlertBannerViewStyleTwitterPost;
    }
    if([self.social.deviceAccounts accountsWithAccountType:[self.social.deviceAccounts accountTypeWithAccountTypeIdentifier:network]].count > 1){
        [self selectAccountForAccountType:[self.social.deviceAccounts accountTypeWithAccountTypeIdentifier:network] completion:^(ACAccount *account){
            if([self.social postToNetwork:network withMessage:[NSString stringWithFormat:@"\"%@\"\n\n%@", self.textView.text, self.authorLabel.text]]){
                [self presentBannerWithStyle:style failure:NO];
            }
            else{
                [self presentBannerWithStyle:style failure:YES];
            }
        }];
    }
    else{
        if([self.social postToNetwork:network withMessage:[NSString stringWithFormat:@"\"%@\"\n\n%@", self.textView.text, self.authorLabel.text]]){
            [self presentBannerWithStyle:style failure:NO];
        }
        else{
            [self presentBannerWithStyle:style failure:YES];
        }
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
-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    if([self sizeIsPortrait:size]){
        if([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
            self.textView.textAlignment = NSTextAlignmentLeft;
            self.authorLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    else{
        self.textView.textAlignment = NSTextAlignmentCenter;
        self.authorLabel.textAlignment = NSTextAlignmentCenter;
    }
}
#pragma mark - Social Buttons
-(IBAction)postToFacebook:(UIButton *)sender{
    [self postQuoteToNetwork:ACAccountTypeIdentifierFacebook];
}
-(IBAction)postToTwitter:(UIButton *)sender{
    [self postQuoteToNetwork:ACAccountTypeIdentifierTwitter];
}
-(void)selectAccountForAccountType:(ACAccountType *)type completion:(void (^)(ACAccount *))handler{
    self.accountSelectionCompletion = handler;
    NSString *prefix = [NSString string];
    if([type.identifier isEqualToString:ACAccountTypeIdentifierTwitter]){
        prefix = @"@";
    }
    NSArray *accounts = [self.social.deviceAccounts accountsWithAccountType:type];
    if([UIDevice currentDevice].systemVersion.floatValue >= 8){
        UIAlertController *picker = [UIAlertController alertControllerWithTitle:@"Select an Account" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        for(ACAccount *account in accounts){
            [picker addAction:[UIAlertAction actionWithTitle:[prefix stringByAppendingString:account.username] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                self.preferredAccount = account;
                handler(account);
            }]];
        }
        [picker addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
            [popover presentPopoverFromRect:(type.identifier == ACAccountTypeIdentifierFacebook ? self.facebookButton.frame : self.twitterButton.frame) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }
        else{
            [self presentViewController:picker animated:YES completion:nil];
        }
    }
    else{
        UIActionSheet *picker = [[UIActionSheet alloc] initWithTitle:@"Select an Account" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
        for(ACAccount *account in accounts){
            [picker addButtonWithTitle:[prefix stringByAppendingString:account.username]];
        }
        [picker showInView:self.view];
    }
}
#pragma mark - UI Helper Methods
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    CGFloat topCorrect = (self.textView.bounds.size.height - self.textView.contentSize.height * self.textView.zoomScale)/2.0;
    topCorrect = (topCorrect < 0.0 ? 0.0 : topCorrect);
    self.textView.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
}
-(void)presentBannerWithStyle:(MHAlertBannerViewStyle)style failure:(BOOL)status{
    MHAlertBannerView *banner = [MHAlertBannerView bannerWithBannerStyle:style];
    [self.view addSubview:banner];
    [banner presentBanner];
    if(!status){
        banner.delegate = self;
        banner.watchedObject = [self.social.requests objectAtIndex:self.social.requests.count - 2];
        [self.banners addObject:banner];
    }
    else{
        NSString *message;
        if(style == MHAlertBannerViewStyleFacebookPost){
            message = MHFacebookPostFailureMessage;
        }
        //If support for more networks is added in the future, this will need to be updated
        else if(style == MHAlertBannerViewStyleTwitterPost){
            message = MHTweetFailureMessage;
        }
        [banner operationFailedWithMessage:message];
    }
}
-(BOOL)sizeIsPortrait:(CGSize)size{
    if(size.height > size.width){
        return YES;
    }
    else{
        return NO;
    }
}
#pragma mark - MHAlertBannerViewDelegate Methods
-(void)alertDidCancel:(MHAlertBannerView *)alert{
    [alert operationFailedWithMessage:@"Canceled!"];
    [self.social cancelPost:alert.watchedObject];
}
#pragma mark - MHSocialDelegate Methods
-(void)post:(NSURLConnection *)post didFailWithError:(NSError *)error{
    for(MHAlertBannerView *banner in self.banners){
        if(banner.watchedObject == post){
            if([error.domain isEqualToString:@"MHSocialError"] && error.code == 100){
                //Here, we reassign the post's watchedObject to the new connection that should retry the post
                banner.watchedObject = self.social.requests[self.social.requests.count - 2];
            }
            else{
                if([post.originalRequest.URL.absoluteString containsString:@"graph.facebook.com"]){
                    [banner operationFailedWithMessage:MHFacebookPostFailureMessage];
                }
                //If more networks than just Facebook & Twitter are going to be supported in the future, this will need to be edited
                else{
                    [banner operationFailedWithMessage:MHTweetFailureMessage];
                }
                [self.banners removeObject:banner];
            }
        }
    }
}
-(void)postSucceeded:(NSURLConnection *)post{
    for(MHAlertBannerView *banner in self.banners){
        if(banner.watchedObject == post){
            if([post.originalRequest.URL.absoluteString containsString:@"graph.facebook.com"]){
                [banner operationSucceededWithMessage:MHFacebookPostSuccessMessage];
            }
            //If more networks than just Facebook & Twitter are going to be supported in the future, this will need to be edited
            else if([post.originalRequest.URL.absoluteString containsString:@"api.twitter.com"]){
                [banner operationSucceededWithMessage:MHTweetSuccessMessage];
            }
            [self.banners removeObject:banner];
        }
    }
}
-(ACAccount *)accountForAccountType:(ACAccountType *)accountType{
    return self.preferredAccount;
}
#pragma mark - UIActionSheetDelegate Methods
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex != actionSheet.cancelButtonIndex){
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if([title hasPrefix:@"@"]){
            title = [title substringFromIndex:1];
        }
        for(ACAccount *account in self.social.deviceAccounts.accounts){
            if([account.username isEqualToString:title]){
                self.preferredAccount = [self.social.deviceAccounts accountWithIdentifier:[actionSheet buttonTitleAtIndex:buttonIndex]];
                self.accountSelectionCompletion(self.preferredAccount);
                break;
            }
        }
    }
}
@end