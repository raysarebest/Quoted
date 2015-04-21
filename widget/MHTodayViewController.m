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
@property (strong, nonatomic) NSTimer *changeTimer;
-(void)updateQuoteAfterTap:(BOOL)tapped;
-(void)resetTimer;
-(NSTimer *)newTimer;
@end

@implementation MHTodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
        self.quoteLabel.textAlignment = NSTextAlignmentCenter;
        self.authorLabel.textAlignment = NSTextAlignmentCenter;
    }
    [self updateQuoteAfterTap:NO];
    [self resetTimer];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateQuoteAfterTap:)];
    [self.quoteLabel addGestureRecognizer:tap];
    [self.authorLabel addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    //[self updateQuote];
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    completionHandler(NCUpdateResultNoData);
}
-(UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets{
    return UIEdgeInsetsZero;
}

#pragma mark - Private Helper Methods
-(void)updateQuoteAfterTap:(BOOL)tapped{
    if(tapped){
        [self resetTimer];
    }
    UIColor *background = [MHColorPicker randomColorWithMinColorDifference:.4 randomnessSpecificity:UINT32_MAX alpha:.3];
    UIColor *text = [MHColorPicker textColorFromBackgroundColor:background];
    self.view.backgroundColor = background;
    self.quoteLabel.textColor = text;
    self.authorLabel.textColor = text;
    MHQuote *quote = [MHQuote randomQuote];
    self.authorLabel.text = [@"- " stringByAppendingString:quote.author];
    self.quoteLabel.text = quote.quote;
    [self.quoteLabel sizeToFit];
    self.authorLabel.accessibilityLabel = quote.author;
    self.quoteLabel.accessibilityLabel = quote.quote;
}
-(void)resetTimer{
    [self.changeTimer invalidate];
    self.changeTimer = [self newTimer];
}
-(NSTimer *)newTimer{
    return [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateQuoteAfterTap:) userInfo:nil repeats:YES];
}
#pragma mark - User Interaction
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self updateQuoteAfterTap:YES];
}
#pragma mark - Property Lazy Instantiation
-(NSTimer *)changeTimer{
    if(!_changeTimer){
        _changeTimer = [NSTimer new];
    }
    return _changeTimer;
}
@end
