//
//  MHAlertBannerView.m
//  Quoted
//
//  Created by Michael Hulet on 11/15/14.
//  Copyright (c) 2014 Michael Hulet. All rights reserved.
//

#import "MHAlertBannerView.h"
#define bannerHeight 44
@interface MHAlertBannerView()
-(void)cancel;
@end
@implementation MHAlertBannerView
-(instancetype)init{
    self = [[MHAlertBannerView alloc] initWithFrame:CGRectMake(0, -bannerHeight - [UIApplication sharedApplication].statusBarFrame.size.height, [UIScreen mainScreen].bounds.size.width, bannerHeight)];
    self.resultImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 28, 28)];
    self.spinner.center = self.resultImageView.center;
    self.spinner.frame = self.resultImageView.frame;
    self.resultImageView.hidden = YES;
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 36, 8, 28, 28)];
    [self.cancelButton setTitle:@"X" forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    self.actionLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 8, [UIScreen mainScreen].bounds.size.width - 88, 28)];
    self.actionLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.resultImageView];
    [self addSubview:self.spinner];
    [self.spinner startAnimating];
    [self addSubview:self.cancelButton];
    [self addSubview:self.actionLabel];
    return self;
}
-(void)cancel{
    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"%f", [UIApplication sharedApplication].statusBarFrame.size.height);
}
-(void)dismissBanner{
    [UIView animateWithDuration:.25 animations:^{
        self.frame = CGRectMake(self.frame.origin.x, -66, self.frame.size.width, self.frame.size.height);
    }];
}
@end