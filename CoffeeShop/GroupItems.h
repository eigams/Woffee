//
//  GroupItems.h
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/19/15.
//  Copyright (c) 2015 Stefan Burettea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Venue.h"
#import "VenueTip.h"

@interface GroupItems : NSObject

@property (nonatomic, strong) Venue *venue;
@property (nonatomic, strong) NSArray *tips;
@property (nonatomic, strong) NSString *referralId;
@property (nonatomic, strong) NSDictionary *reasons;

@end
