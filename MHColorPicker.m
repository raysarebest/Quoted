//
//  MHColorPicker.m
//  Quoted
//
//  Created by Michael Hulet on 9/27/14.
//  Copyright (c) 2014 Michael Hulet. All rights reserved.
//

#import "MHColorPicker.h"
@interface MHColorPicker()
void scatterColors(float specificity, u_int32_t randomness);
@end
@implementation MHColorPicker
#pragma mark - Global Variables/Constants
//I have to declare an array for colors globally, because you can't pass arrays as function arguments in C :(
CGFloat colors[3];
#pragma mark - Public Methods
-(UIColor *)randomColorWithMinColorDifference:(float)difference andRandomnessSpecificity:(u_int32_t)specificity andAlpha:(CGFloat)alpha{
    UIColor *color = [UIColor colorWithRed:randomColorValue(specificity) green:randomColorValue(specificity) blue:randomColorValue(specificity) alpha:alpha];
    [color getRed:&colors[0] green:&colors[1] blue:&colors[2] alpha:nil];
    scatterColors(difference, specificity);
    return [UIColor colorWithRed:colors[0] green:colors[1] blue:colors[2] alpha:alpha];
}
-(UIColor *)textColorFromBackgroundColor:(UIColor *)background{
    return [UIColor colorWithRed:1-colors[0] green:1-colors[1] blue:1-colors[2] alpha:1];
}
CGFloat randomColorValue(u_int32_t specificity){
    return (CGFloat)arc4random_uniform(specificity)/specificity;
}
#pragma mark - Helper Methods
void scatterColors(float specificity, u_int32_t randomness){
    if((colors[0] <= colors[1]+specificity && colors[0] >= colors[1]-specificity) && (colors[1] <= colors[2]+specificity && colors[1] >= colors[2]-specificity) && (colors[0] <= colors[2]+specificity && colors[0] >= colors[2]-specificity)){
        //Float typecast to int might cause a crash at runtime, but it should be a round number, so we'll see
        for(int i=0; i<3; i++){
            colors[i] = randomColorValue(randomness);
            scatterColors(specificity, randomness);
        }
    }
}
@end