//
//  MHQuote.m
//  Quoted
//
//  Created by Michael Hulet on 12/28/14.
//  Copyright (c) 2014 Michael Hulet. All rights reserved.
//

#import "MHQuote.h"
#import "MHQuoteStore.h"
@interface MHQuote ()
@property (strong, nonatomic) MHQuoteStore *db;
@end
@implementation MHQuote
#pragma mark - Object Initializers
-(instancetype)initWithRandomQuote{
    if(self = [super init]){
        NSDictionary *quote = [self.db randomQuote];
        self.author = quote.allKeys.firstObject;
        self.quote = quote[self.author];
    }
    return self;
}
-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    if([dictionary.allKeys containsObject:MHQuoteDictionaryAuthorKey] && [dictionary.allKeys containsObject:MHQuoteDictionaryQuoteKey]){
        if(self = [super init]){
            self.author = dictionary[MHQuoteDictionaryAuthorKey];
            self.quote = dictionary[MHQuoteDictionaryQuoteKey];
        }
    }
    return self;
}
#pragma mark - Convenience Constructors
+(instancetype)randomQuote{
    return [[self alloc] initWithRandomQuote];
}
+(instancetype)quoteWithDictionary:(NSDictionary *)dictionary{
    return [[self alloc] initWithDictionary:dictionary];
}
#pragma mark - Property Lazy Instantiation
-(MHQuoteStore *)db{
    if(!_db){
        _db = [MHQuoteStore sharedStore];
    }
    return _db;
}
@end
