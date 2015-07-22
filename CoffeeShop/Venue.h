//
//  Venue.h
//  CoffeeShop
//
//  Created by Stefan Burettea on 29/04/2013.
//  Copyright (c) 2013 Stefan Burettea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"
#import "Stats.h"

@interface Photo : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSNumber *createdAt;
@property (nonatomic, strong) NSNumber *width;
@property (nonatomic, strong) NSNumber *height;
@property (nonatomic, strong) NSString *prefix;
@property (nonatomic, strong) NSString *suffix;
@property (nonatomic, strong) NSString *visibility;

@end


@interface Hours : NSObject

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSNumber *isOpen;

@end

@interface Price : NSObject

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *currency;
@property (nonatomic, strong) NSNumber *tier;

@end


@interface Venue : NSObject

@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) Location *location;
@property (strong, nonatomic) Stats *stats;
@property (strong, nonatomic) NSNumber *rating;
@property (strong, nonatomic) NSString *ratingColor;
@property (strong, nonatomic) Hours *hours;
@property (strong, nonatomic) Price *price;
@property (copy, nonatomic) NSString *photo;

- (NSString *)address;

@end
