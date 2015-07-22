//
//  Groups.h
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/19/15.
//  Copyright (c) 2015 Stefan Burettea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Group : NSObject

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray *items;

@end
