//
//  TodayViewController.h
//  widget
//
//  Created by Michael Hulet on 12/27/14.
//  Copyright (c) 2014 Michael Hulet. All rights reserved.
//

@import UIKit;
@class MHQuoter;
@class MHColorPicker;
@interface MHTodayViewController : UIViewController
@property (strong, nonatomic) MHColorPicker *colorPicker;
@property (weak, nonatomic) IBOutlet UILabel *quoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@end
