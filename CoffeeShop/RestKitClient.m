//
//  RestKitClient.m
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/20/15.
//  Copyright (c) 2015 Stefan Burettea. All rights reserved.
//

#import "RestKitClient.h"
#import <RestKit/RestKit.h> 
#import <CoreLocation/CoreLocation.h>

#import "Group.h"
#import "GroupItems.h"
#import "Venue.h"


@implementation RestKitClient

+ (void)configureRestKit {
    
    NSURL *baseURL = [NSURL URLWithString:@"https://api.foursquare.com/v2"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    // initialize RestKit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    RKObjectMapping *venueMapping = [RKObjectMapping mappingForClass:[Venue class]];
    [venueMapping addAttributeMappingsFromDictionary:@{@"name" : @"name",
                                                       @"id": @"identifier",
                                                       @"rating": @"rating",
                                                       @"ratingColor": @"ratingColor"}];

    RKObjectMapping *priceMapping = [RKObjectMapping mappingForClass:[Price class]];
    [priceMapping addAttributeMappingsFromDictionary:@{@"tier" : @"tier",
                                                       @"message": @"message",
                                                       @"currency": @"currency"}];
    
    RKObjectMapping *hoursMapping = [RKObjectMapping mappingForClass:[Hours class]];
    [hoursMapping addAttributeMappingsFromDictionary:@{@"status" : @"status",
                                                       @"isOpen": @"isOpen"}];
    
    RKObjectMapping *locationMapping = [RKObjectMapping mappingForClass:[Location class]];
    [locationMapping addAttributeMappingsFromDictionary:@{ @"address" : @"address",
                                                           @"city" : @"city",
                                                           @"country" : @"country",
                                                           @"cc" : @"cc",
                                                           @"postalCode" : @"postalCode",
                                                           @"state" : @"state",
                                                           @"distance" : @"distance",
                                                           @"lat" : @"lat",
                                                           @"lng" : @"lng"}];
    
    [venueMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"location" toKeyPath:@"location" withMapping:locationMapping]];
    [venueMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"price" toKeyPath:@"price" withMapping:priceMapping]];
    [venueMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"hours" toKeyPath:@"hours" withMapping:hoursMapping]];
    
    RKObjectMapping *tipsMapping = [RKObjectMapping mappingForClass:[VenueTip class]];
    [tipsMapping addAttributeMappingsFromDictionary:@{ @"id": @"identifier",
                                                       @"createdAt": @"createdAt",
                                                       @"text": @"text"}];
    
    RKObjectMapping *statsMapping = [RKObjectMapping mappingForClass:[Stats class]];
    [statsMapping addAttributeMappingsFromDictionary:@{ @"checkinsCount" : @"checkins",
                                                        @"tipsCount" : @"tips",
                                                        @"usersCount" : @"users"}];
    
    [venueMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"stats" toKeyPath:@"stats" withMapping:statsMapping]];
    RKObjectMapping *groupsMapping = [RKObjectMapping mappingForClass:[Group class]];
    [groupsMapping addAttributeMappingsFromDictionary:@{@"name" : @"name",
                                                        @"type" : @"type"}];
    
    RKObjectMapping *groupItemsMapping = [RKObjectMapping mappingForClass:[GroupItems class]];
    [groupItemsMapping addAttributeMappingsFromDictionary:@{ @"referralId" : @"referralId",
                                                             @"reasons": @"reasons"}];
    
    [groupItemsMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"tips" toKeyPath:@"tips" withMapping:tipsMapping]];
    [groupItemsMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"venue" toKeyPath:@"venue" withMapping:venueMapping]];
    [groupsMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"items" toKeyPath:@"items" withMapping:groupItemsMapping]];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:groupsMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"response.groups" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [objectManager addResponseDescriptor:responseDescriptor];
}

+ (void)configureRestKitForVenueTipsResponses {
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    RKObjectMapping *tipsMapping = [RKObjectMapping mappingForClass:[VenueTip class]];
    [tipsMapping addAttributeMappingsFromDictionary:@{ @"id": @"identifier",
                                                       @"createdAt": @"createdAt",
                                                       @"text": @"text"}];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:tipsMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"response.tips.items" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [objectManager addResponseDescriptor:responseDescriptor];
}

+ (void)configureRestKitForVenuePhotosResponses {
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    RKObjectMapping *photoMapping = [RKObjectMapping mappingForClass:[Photo class]];
    [photoMapping addAttributeMappingsFromDictionary:@{ @"id": @"identifier",
                                                       @"createdAt": @"createdAt",
                                                       @"width": @"width",
                                                       @"height": @"height",
                                                       @"prefix": @"prefix",
                                                       @"suffix": @"suffix",
                                                       @"visibility": @"visibility" }];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:photoMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"response.photos.items" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [objectManager addResponseDescriptor:responseDescriptor];
}


static const char *kCLIENTID = "ZZCLOTJ2RO5TY5LVDUVVUOWW41VN2PGQXHEL1IR3U14XEZTC";
static const char *kCLIENTSECRET = "Q3OCB5OC0V30JXVLCIBZRGMGJOFRWE2QXDRKKVTKIQSYF43N";

+ (NSDictionary *)requestWithLocation:(CLLocation *)location query:(NSString *)query radius:(NSString *)radius {
    
    NSString *latLon = [NSString stringWithFormat:@"%.8f,%.8f", location.coordinate.latitude, location.coordinate.longitude];
    NSString *clientID = [NSString stringWithUTF8String:kCLIENTID];
    NSString *clientSecret = [NSString stringWithUTF8String:kCLIENTSECRET];
    
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:latLon, @"ll",
                                 clientID, @"client_id",
                                 clientSecret, @"client_secret",
                                 query, @"query",
                                 @"20150420", @"v",
                                 radius, @"radius",
                                 @"1", @"sortByDistance",
                                 @"100", @"limit", nil];
    
    return queryParams;
}

+ (NSDictionary *)requestWithLocation:(CLLocation *)location section:(NSString *)section radius:(NSString *)radius{
    
//    NSString *latLon = [NSString stringWithFormat:@"51.5148,-0.1432"];//, location.coordinate.latitude, location.coordinate.longitude];
    NSString *latLon = [NSString stringWithFormat:@"%.8f,%.8f", location.coordinate.latitude, location.coordinate.longitude];
    NSString *clientID = [NSString stringWithUTF8String:kCLIENTID];
    NSString *clientSecret = [NSString stringWithUTF8String:kCLIENTSECRET];
    
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:latLon, @"ll",
                                 clientID, @"client_id",
                                 clientSecret, @"client_secret",
                                 section, @"section",
                                 @"20150420", @"v",
                                 radius, @"radius",
                                 @"1", @"sortByDistance",
                                 @"100", @"limit", nil];
    
    return queryParams;
}

+ (void)getWifiTaggedVenues:(CLLocation *)location radius:(NSString *)radius completion:(void (^)(NSArray *, NSError *))completion {
    [[self class] sendRequestWithLocation:location query:@"wifi" radius:radius completion:completion];
}

+ (void)getDefaultWifiEnabledVenues:(CLLocation *)location query:(NSString *)venueName radius:(NSString *)radius completion:(void (^)(NSArray *, NSError *))completion {
    [[self class] sendRequestWithLocation:location query:venueName radius:radius completion:completion];
}

+ (void)getStarbucksVenues:(CLLocation *)location radius:(NSString *)radius completion:(void (^)(NSArray *, NSError *))completion {
    
    [[self class] sendRequestWithLocation:location query:@"starbucks" radius:radius completion:completion];
}

+ (void)getFoodVenues:(CLLocation *)location radius:(NSString *)radius completion:(void (^)(NSArray *, NSError *))completion {
    
    [[self class] sendRequestWithLocation:location section:@"food" radius:radius completion:completion];
}

+ (void)getCoffeeVenues:(CLLocation *)location radius:radius completion:(void (^)(NSArray *, NSError *))completion {
    
    [[self class] sendRequestWithLocation:location section:@"coffee" radius:radius completion:completion];
}

+ (NSDictionary *)requestForVenueTips:(NSString *)venueIdentifier {
    
    NSString *clientID = [NSString stringWithUTF8String:kCLIENTID];
    NSString *clientSecret = [NSString stringWithUTF8String:kCLIENTSECRET];
    
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys: clientID, @"client_id",
                                 clientSecret, @"client_secret",
                                 @"20150420", @"v", nil];
    
    return queryParams;
}

+ (void)getVenueTips:(NSArray *)venueIdentifiers completion:(void (^)(NSDictionary *, NSError *))completion {

    if ([venueIdentifiers count] < 1) {
        NSLog(@"ERROR: no venue identifiers to look for !!!");
        
        return;
    }
    
    NSDictionary *queryParams = @{ @"client_id"    : [NSString stringWithUTF8String:kCLIENTID],
                                   @"client_secret": [NSString stringWithUTF8String:kCLIENTSECRET],
                                   @"v"            : @"20150420",
                                   @"sort"         : @"recent"
                                 };
    
    [[self class] configureRestKitForVenueTipsResponses];
    
    for (NSString *identifier in venueIdentifiers) {
        
        NSString *urlPath = [NSString stringWithFormat:@"/v2/venues/%@/tips", identifier];
        [[RKObjectManager sharedManager] getObjectsAtPath:urlPath
                                               parameters:queryParams
                                                  success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                      
                                                      NSArray *results = [mappingResult array];
                                                      
                                                      completion(@{identifier: results}, nil);
                                                  }
                                                  failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                      NSLog(@"%@", error);
                                                      completion(nil, error);
                                                  }];
        
    }
    
}

+ (NSDictionary *)requestForVenuePhotos:(NSString *)venueIdentifier {
    
    NSString *clientID = [NSString stringWithUTF8String:kCLIENTID];
    NSString *clientSecret = [NSString stringWithUTF8String:kCLIENTSECRET];
    
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys: clientID, @"client_id",
                                 clientSecret, @"client_secret",
                                 @"20150420", @"v", nil];
    
    return queryParams;
}

+ (void)getVenuePhotos:(NSString *)venueIdentifier completion:(void (^)(NSArray *, NSError *))completion {
    
    NSDictionary *queryParams = @{ @"client_id"    : [NSString stringWithUTF8String:kCLIENTID],
                                   @"client_secret": [NSString stringWithUTF8String:kCLIENTSECRET],
                                   @"v"            : @"20150420",
                                   @"sort"         : @"recent"
                                   };
    
    [[self class] configureRestKitForVenuePhotosResponses];
        
    NSString *urlPath = [NSString stringWithFormat:@"/v2/venues/%@/photos", venueIdentifier];
    [[RKObjectManager sharedManager] getObjectsAtPath:urlPath
                                           parameters:queryParams
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  NSArray *results = [mappingResult array];
                                                  
                                                  completion(results, nil);
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"%@", error);
                                                  completion(nil, error);
                                              }];
    
}

+ (void)sendRequestWithLocation:(CLLocation *)location
                          query:(NSString *)query
                         radius:(NSString *)radius
                     completion:(void (^)(NSArray *, NSError *))completion {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[self class] configureRestKit];
    });
    
    NSDictionary *queryParams = [[self class] requestWithLocation:location query:query radius:radius];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/v2/venues/explore"
                                           parameters:queryParams
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  NSArray *result = [mappingResult array];
                                                  
                                                  NSMutableArray *sink = [NSMutableArray array];
                                                  
                                                  for(Group *group in result) {
                                                      
                                                      for (GroupItems *gItems in group.items) {
                                                          [sink addObject:gItems.venue];
                                                      }
                                                  }
                                                  
                                                  completion(sink, nil);
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"%@", error);
                                                  completion(nil, error);
                                              }];
}

+ (void)sendRequestWithLocation:(CLLocation *)location
                        section:(NSString *)section
                        radius:(NSString *)radius
                     completion:(void (^)(NSArray *, NSError *))completion {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[self class] configureRestKit];
    });
    
    NSDictionary *queryParams = [[self class] requestWithLocation:location section:section radius:radius];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/v2/venues/explore"
                                           parameters:queryParams
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  NSArray *result = [mappingResult array];
                                                  
                                                  NSMutableArray *sink = [NSMutableArray array];
                                                  
                                                  for(Group *group in result) {
                                                      
                                                      for (GroupItems *gItems in group.items) {
                                                          [sink addObject:gItems.venue];
                                                      }
                                                  }
                                                  
                                                  completion(sink, nil);
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"%@", error);
                                                  completion(nil, error);
                                              }];
}


@end
