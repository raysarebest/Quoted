//
//  MHColorPicker.h
//  Quoted
//
//  Created by Michael Hulet on 9/27/14.
//  Copyright (c) 2014 Michael Hulet. All rights reserved.
//

@import Foundation;

@interface MHColorPicker : NSObject
-(UIColor *)randomColorWithMinColorDifference:(float)difference andRandomnessSpecificity:(u_int32_t)specificity andAlpha:(CGFloat)alpha;
-(UIColor *)textColorFromBackgroundColor:(UIColor *)background;
CGFloat randomColorValue(u_int32_t specificity);
@end