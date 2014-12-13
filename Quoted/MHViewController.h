//
//  MHViewController.h
//  Quoted
//
//  Created by Michael Hulet on 8/19/14.
//  Copyright (c) 2014 Michael Hulet. All rights reserved.
//

#import "MHAlertBannerView.h"
#import "MHSocialSharer.h"
@import UIKit;
@import iAd;
@class MHQuoter;
@class MHColorPicker;
@interface MHViewController : UIViewController <ADBannerViewDelegate, MHAlertBannerViewDelegate, MHSocialDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) MHQuoter *quoter;
@property (strong, nonatomic) MHColorPicker *colorPicker;
@property (strong, nonatomic) MHSocialSharer *social;
@property (strong, nonatomic) IBOutlet UIButton *facebookButton;
@property (strong, nonatomic) IBOutlet UIButton *twitterButton;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UITextView *textView;
-(IBAction)postToFacebook:(UIButton *)sender;
-(IBAction)postToTwitter:(UIButton *)sender;
-(void)layoutSocialButtons;
@end