//
//  TodayViewController.m
//  widget
//
//  Created by Michael Hulet on 12/27/14.
//  Copyright (c) 2014 Michael Hulet. All rights reserved.
//

#import "MHTodayViewController.h"
@import QuoteKit;
@import NotificationCenter;
@interface MHTodayViewController () <NCWidgetProviding>
-(void)updateQuote;
@end

@implementation MHTodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        self.quoteLabel.textAlignment = NSTextAlignmentCenter;
        self.authorLabel.textAlignment = NSTextAlignmentCenter;
    }
    [self updateQuote];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    [self updateQuote];
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateQuote) userInfo:nil repeats:YES];
    completionHandler(NCUpdateResultNewData);
}
-(UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets{
    return UIEdgeInsetsZero;
}
#pragma mark - Property Lazy Instantiation
-(MHColorPicker *)colorPicker{
    if(!_colorPicker){
        _colorPicker = [[MHColorPicker alloc] init];
    }
    return _colorPicker;
}
#pragma mark - Private Helper Methods
-(void)updateQuote{
    UIColor *background = [self.colorPicker randomColorWithMinColorDifference:.4 randomnessSpecificity:UINT32_MAX alpha:.3];
    UIColor *text = [self.colorPicker textColorFromBackgroundColor:background];
    self.view.backgroundColor = background;
    self.quoteLabel.textColor = text;
    self.authorLabel.textColor = text;
    MHQuote *quote = [MHQuote randomQuote];
    self.authorLabel.text = [@"- " stringByAppendingString:quote.author];
    self.quoteLabel.text = quote.quote;
    self.authorLabel.accessibilityLabel = quote.author;
    self.quoteLabel.accessibilityLabel = quote.quote;
}
@end
