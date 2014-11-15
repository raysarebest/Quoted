//
//  MHAlertBannerView.h
//  Quoted
//
//  Created by Michael Hulet on 11/15/14.
//  Copyright (c) 2014 Michael Hulet. All rights reserved.
//

@import UIKit;
@interface MHAlertBannerView : UIView
@property (strong, nonatomic) UILabel *actionLabel;
@property (strong, nonatomic) UIImageView *resultImageView;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) UIButton *cancelButton;
@end
