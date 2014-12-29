//
//  MHQuote.h
//  Quoted
//
//  Created by Michael Hulet on 12/28/14.
//  Copyright (c) 2014 Michael Hulet. All rights reserved.
//
@import Foundation;
//Keys for NSDictionary passed into quoteWithDictionary:
static NSString *const MHQuoteDictionaryAuthorKey = @"author";
static NSString *const MHQuoteDictionaryQuoteKey = @"quote";
@interface MHQuote : NSObject
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSString *quote;
+(instancetype)randomQuote;
+(instancetype)quoteWithDictionary:(NSDictionary *)dictionary;
-(instancetype)initWithRandomQuote;
-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
