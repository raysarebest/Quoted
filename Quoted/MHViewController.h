//
//  MHViewController.h
//  Quoted
//
//  Created by Michael Hulet on 8/19/14.
//  Copyright (c) 2014 Michael Hulet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MHQuoter;
@class MHColorPicker;
@interface MHViewController : UIViewController
@property (strong, nonatomic) MHQuoter *quoter;
@property (strong, nonatomic) MHColorPicker *colorPicker;
@property (strong, nonatomic) IBOutlet UILabel *quoteLabel;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@end
