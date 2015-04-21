//
//  InterfaceController.m
//  Quoted WatchKit Extension
//
//  Created by Michael Hulet on 1/13/15.
//  Copyright (c) 2015 Michael Hulet. All rights reserved.
//

#import "MHInterfaceController.h"
@interface MHInterfaceController()
-(nonnull NSString *)authorString:(nonnull NSString *)author;
@end
@implementation MHInterfaceController
-(void)awakeWithContext:(id)context{
    [super awakeWithContext:context];
    // Configure interface objects here.
    [self newQuote];
}
-(void)willActivate{
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}
-(void)didDeactivate{
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}
-(IBAction)newQuote{
    UIColor *fill = [MHColorPicker randomColor];
    UIColor *textColor = [MHColorPicker textColorFromBackgroundColor:fill];
    [self.background setBackgroundColor:fill];
    MHQuote *quote = [MHQuote randomQuote];
    [self.authorLabel setText:[self authorString:quote.author]];
    [self.authorLabel setAccessibilityLabel:quote.author];
    [self.authorLabel setTextColor:textColor];
    [self.quoteLabel setText:quote.quote];
    [self.quoteLabel setAccessibilityLabel:quote.quote];
    [self.quoteLabel setTextColor:textColor];
}
-(nonnull NSString *)authorString:(nonnull NSString *)author{
    return [@"- " stringByAppendingString:author];
}
@end