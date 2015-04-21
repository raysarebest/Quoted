//
//  InterfaceController.h
//  Quoted WatchKit Extension
//
//  Created by Michael Hulet on 1/13/15.
//  Copyright (c) 2015 Michael Hulet. All rights reserved.
//

@import WatchKit;
@import Foundation;
@import QuoteKit;
@interface MHInterfaceController : WKInterfaceController
@property (weak, nonatomic, nonnull) IBOutlet WKInterfaceLabel *quoteLabel;
@property (weak, nonatomic, nonnull) IBOutlet WKInterfaceLabel *authorLabel;
@property (weak, nonatomic, nonnull) IBOutlet WKInterfaceGroup *background;
-(IBAction)newQuote;
@end
