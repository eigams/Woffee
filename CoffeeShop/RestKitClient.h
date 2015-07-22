//
//  RestKitClient.h
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/20/15.
//  Copyright (c) 2015 Stefan Burettea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface RestKitClient : NSObject

+ (void)getWifiTaggedVenues:(CLLocation *)location radius:(NSString *)radius completion:(void (^)(NSArray *, NSError *))completion;
+ (void)getDefaultWifiEnabledVenues:(CLLocation *)location query:(NSString *)venueName radius:(NSString *)radius completion:(void (^)(NSArray *, NSError *))completion;
+ (void)getStarbucksVenues:(CLLocation *)location radius:(NSString *)radius completion:(void (^)(NSArray *, NSError *))completion;
+ (void)getFoodVenues:(CLLocation *)location radius:(NSString *)radius completion:(void (^)(NSArray *, NSError *))completion;
+ (void)getCoffeeVenues:(CLLocation *)location radius:(NSString *)radius completion:(void (^)(NSArray *, NSError *))completion;
+ (void)getVenueTips:(NSArray *)venueIdentifiers completion:(void (^)(NSDictionary *, NSError *))completion;
+ (void)getVenuePhotos:(NSString *)venueIdentifier completion:(void (^)(NSArray *, NSError *))completion;
    
@end
