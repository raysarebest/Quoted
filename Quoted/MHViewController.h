//
//  MHViewController.h
//  Quoted
//
//  Created by Michael Hulet on 8/19/14.
//  Copyright (c) 2014 Michael Hulet. All rights reserved.
//

@import UIKit;
@class MHQuoter;
@class MHColorPicker;
@class MHSocialSharer;
@interface MHViewController : UIViewController
@property (strong, nonatomic) MHQuoter *quoter;
@property (strong, nonatomic) MHColorPicker *colorPicker;
@property (strong, nonatomic) MHSocialSharer *social;
@property (strong, nonatomic) IBOutlet UILabel *quoteLabel;
@property (strong, nonatomic) IBOutlet UIButton *facebookButton;
@property (strong, nonatomic) IBOutlet UIButton *twitterButton;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
-(IBAction)postToFacebook:(UIButton *)sender;
-(IBAction)postToTwitter:(UIButton *)sender;
@end
