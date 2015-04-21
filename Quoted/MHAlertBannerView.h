//
//  MHAlertBannerView.h
//  Quoted
//
//  Created by Michael Hulet on 11/15/14.
//  Copyright (c) 2014 Michael Hulet. All rights reserved.
//

@import UIKit;
typedef NS_ENUM(NSInteger, MHAlertBannerViewStyle){
    MHAlertBannerViewStyleFacebookPost,
    MHAlertBannerViewStyleTwitterPost,
    MHAlertBannerViewStyleCustom
};
@class MHAlertBannerView;
@protocol MHAlertBannerViewDelegate
-(void)alertDidCancel:(MHAlertBannerView *)alert;
@optional
-(void)alertWillShow:(MHAlertBannerView *)alert;
-(void)alertDidShow:(MHAlertBannerView *)alert;
-(void)alertWillDisappear:(MHAlertBannerView *)alert;
-(void)alertDidDisappear:(MHAlertBannerView *)alert;
-(void)alertWasTouched:(MHAlertBannerView *)alert;
@end
@interface MHAlertBannerView : UIView
@property (nonatomic) id watchedObject;
@property (strong, nonatomic) UILabel *actionLabel;
@property (strong, nonatomic) UIImageView *resultImageView;
@property (strong, nonatomic) UIImage *successImage;
@property (strong, nonatomic) UIImage *failImage;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) id<MHAlertBannerViewDelegate> delegate;
@property (nonatomic) MHAlertBannerViewStyle style;
//Designated initializer, though init is acceptable for custom banner
+(MHAlertBannerView *)bannerWithBannerStyle:(MHAlertBannerViewStyle)style;
-(void)dismissBanner;
-(void)presentBanner;
-(void)operationSucceededWithMessage:(NSString *)message;
-(void)operationFailedWithMessage:(NSString *)message;
@end