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
@property (nonatomic) CGFloat statusBarHeight;
@property (nonatomic) MHAlertBannerViewStyle style;
-(void)cancel;
@end
@implementation MHAlertBannerView
#pragma mark - Initializers
-(instancetype)init{
    //Need to initialize success and fail images, when I set defaults
    self = [[MHAlertBannerView alloc] initWithFrame:CGRectMake(0, -bannerHeight - self.statusBarHeight, [UIScreen mainScreen].bounds.size.width, bannerHeight + self.statusBarHeight)];
    self.resultImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8 + self.statusBarHeight, 28, 28)];
    self.resultImageView.hidden = YES;
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.spinner.center = self.resultImageView.center;
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 36, self.spinner.center.y - 10, 20, 20)];
    [self.cancelButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    self.actionLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 8 + self.statusBarHeight, [UIScreen mainScreen].bounds.size.width - 88, 28)];
    self.actionLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.resultImageView];
    [self addSubview:self.spinner];
    [self.spinner startAnimating];
    [self addSubview:self.cancelButton];
    [self addSubview:self.actionLabel];
    return self;
}
+(MHAlertBannerView *)bannerWithBannerStyle:(MHAlertBannerViewStyle)style{
    MHAlertBannerView *banner = [[MHAlertBannerView alloc] init];
    banner.style = style;
    if(style == MHAlertBannerViewStyleFacebookPost){
        banner.backgroundColor = [UIColor colorWithRed:59.0/255.0f green:89.0/255.0f blue:152.0/255.0f alpha:1];
        banner.failImage = [UIImage imageNamed:@"dislike"];
        banner.successImage = [UIImage imageNamed:@"like"];
        banner.actionLabel.text = @"Posting to Facebook...";
    }
    else if(style == MHAlertBannerViewStyleTwitterPost){
        banner.backgroundColor = [UIColor colorWithRed:85.0/255.0f green:172.0/255.0f blue:238/255.0f alpha:1];
        banner.actionLabel.text = @"Tweeting...";
    }
    return banner;
}
#pragma mark - Actual Logic
-(void)cancel{
    [self.delegate alertDidCancel:self];
    [self dismissBanner];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSObject<MHAlertBannerViewDelegate> *delegate = (NSObject<MHAlertBannerViewDelegate> *)self.delegate;
    if([delegate respondsToSelector:@selector(alertWasTouched:)]){
        [delegate alertWasTouched:self];
    }
}
-(void)dismissBanner{
    __block NSObject<MHAlertBannerViewDelegate> *delegate = (NSObject<MHAlertBannerViewDelegate> *)self.delegate;
    if([delegate respondsToSelector:@selector(alertWillDisappear:)]){
        [delegate alertWillDisappear:self];
    }
    [UIView animateWithDuration:.25 animations:^{
        self.frame = CGRectMake(self.frame.origin.x, -(self.frame.size.height), self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        if([delegate respondsToSelector:@selector(alertDidDisappear:)]){
            [delegate alertDidDisappear:self];
        }
    }];
}
-(void)presentBanner{
    __block NSObject<MHAlertBannerViewDelegate> *delegate = (NSObject<MHAlertBannerViewDelegate> *)self.delegate;
    if([delegate respondsToSelector:@selector(alertWillShow:)]){
        [delegate alertWillShow:self];
    }
    [UIView animateWithDuration:.1 animations:^{
        self.frame = CGRectMake(self.frame.origin.x, 0, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        if([delegate respondsToSelector:@selector(alertDidShow:)]){
            [delegate alertDidShow:self];
        }
    }];
}
#pragma mark - Completion Methods
-(void)operationSucceeded{
    [UIView animateWithDuration:.25 animations:^{
        self.backgroundColor = [UIColor colorWithRed:0 green:200.0/255.0f blue:0 alpha:1];
    }];
    [self.spinner stopAnimating];
    self.resultImageView.image = self.successImage;
    self.spinner.hidden = YES;
    self.resultImageView.hidden = NO;
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(dismissBanner) userInfo:nil repeats:NO];
}
-(void)operationFailed{
    [UIView animateWithDuration:.25 animations:^{
        self.backgroundColor = [UIColor colorWithRed:200.0/255.0f green:0 blue:0 alpha:1];
    }];
    [self.spinner stopAnimating];
    self.resultImageView.image = self.failImage;
    self.spinner.hidden = YES;
    self.resultImageView.hidden = NO;
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(dismissBanner) userInfo:nil repeats:NO];
}
#pragma mark - Property Lazy Instantiation
-(CGFloat)statusBarHeight{
    if(!_statusBarHeight){
        _statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height / 2;
    }
    return _statusBarHeight;
}
@end