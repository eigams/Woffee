//
//  TipR.h
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/19/15.
//  Copyright (c) 2015 Stefan Burettea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VenueTip : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, strong) NSNumber *createdAt;
@property (nonatomic, copy) NSString *text;

@end
