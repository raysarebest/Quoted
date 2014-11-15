//
//  MHAlertBannerView.m
//  Quoted
//
//  Created by Michael Hulet on 11/15/14.
//  Copyright (c) 2014 Michael Hulet. All rights reserved.
//

#import "MHAlertBannerView.h"

@implementation MHAlertBannerView
-(instancetype)init{
    self = [[MHAlertBannerView alloc] initWithFrame:CGRectMake(0, -44, [UIScreen mainScreen].bounds.size.width, 44)];
    self.resultImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 28, 28)];
    self.spinner.center = self.resultImageView.center;
    self.spinner.frame = self.resultImageView.frame;
    self.resultImageView.hidden = YES;
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 36, 8, 28, 28)];
    [self.cancelButton setTitle:@"X" forState:UIControlStateNormal];
    self.actionLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 8, [UIScreen mainScreen].bounds.size.width - 88, 28)];
    [self addSubview:self.resultImageView];
    [self addSubview:self.spinner];
    [self addSubview:self.cancelButton];
    [self addSubview:self.actionLabel];
    return self;
}
@end