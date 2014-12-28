//
//  MHQuoter.h
//  Quoted
//
//  Created by Michael Hulet on 8/19/14.
//  Copyright (c) 2014 Michael Hulet. All rights reserved.
//

@import Foundation;

@interface MHQuoter : NSObject
-(NSDictionary *)randomQuote;
@property (nonatomic) NSUInteger lastQuoteIndex;
@end