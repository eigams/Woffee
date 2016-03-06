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

@interface RestKitConfigurator : NSObject

+ (void)generalConfiguration;
+ (void)venueTipsResponsesConfiguration;
+ (void)venuePhotosResponsesConfiguration;

@end

@implementation RestKitConfigurator

+ (void)generalConfiguration {
    
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

+ (void) venueTipsResponsesConfiguration {
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    RKObjectMapping *tipsMapping = [RKObjectMapping mappingForClass:[VenueTip class]];
    [tipsMapping addAttributeMappingsFromDictionary:@{ @"id": @"identifier",
                                                       @"createdAt": @"createdAt",
                                                       @"text": @"text"}];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:tipsMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"response.tips.items" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [objectManager addResponseDescriptor:responseDescriptor];
}

+ (void)venuePhotosResponsesConfiguration {
    
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

@end

@protocol IRequestBuilder <NSObject>

- (NSDictionary *)requestWithLocation:(CLLocation *)location radius:(NSString *)query eXtraParam:(NSString *)param;

@end

@interface QueryRequestBuilder : NSObject<IRequestBuilder>

@end

static const char *kCLIENTID = "ZZCLOTJ2RO5TY5LVDUVVUOWW41VN2PGQXHEL1IR3U14XEZTC";
static const char *kCLIENTSECRET = "Q3OCB5OC0V30JXVLCIBZRGMGJOFRWE2QXDRKKVTKIQSYF43N";

@implementation QueryRequestBuilder

- (NSDictionary *)requestWithLocation:(CLLocation *)location radius:(NSString *)radius eXtraParam:(NSString *)param {
    
    NSString *latLon = [NSString stringWithFormat:@"%.8f,%.8f", location.coordinate.latitude, location.coordinate.longitude];
    NSString *clientID = [NSString stringWithUTF8String:kCLIENTID];
    NSString *clientSecret = [NSString stringWithUTF8String:kCLIENTSECRET];
    
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:latLon, @"ll",
                                 clientID, @"client_id",
                                 clientSecret, @"client_secret",
                                 param, @"query",
                                 @"20150420", @"v",
                                 radius, @"radius",
                                 @"1", @"sortByDistance",
                                 @"100", @"limit", nil];
    
    return queryParams;
}

@end

@interface SectionRequestBuilder : NSObject<IRequestBuilder>

@end

@implementation SectionRequestBuilder

- (NSDictionary *)requestWithLocation:(CLLocation *)location radius:(NSString *)radius eXtraParam:(NSString *)param {
    
    NSString *latLon = [NSString stringWithFormat:@"%.8f,%.8f", location.coordinate.latitude, location.coordinate.longitude];
    NSString *clientID = [NSString stringWithUTF8String:kCLIENTID];
    NSString *clientSecret = [NSString stringWithUTF8String:kCLIENTSECRET];
    
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:latLon, @"ll",
                                 clientID, @"client_id",
                                 clientSecret, @"client_secret",
                                 param, @"section",
                                 @"20150420", @"v",
                                 radius, @"radius",
                                 @"1", @"sortByDistance",
                                 @"100", @"limit", nil];
    
    return queryParams;
}

@end


@implementation RestKitClient

+ (void)getWifiTaggedVenues:(CLLocation *)location
                     radius:(NSString *)radius
                 completion:(void (^)(NSArray *, NSError *))completion {
    
    id<IRequestBuilder> queryRequest = [[QueryRequestBuilder alloc] init];
    [[self class] getVenues:location radius:radius requestBuilder:queryRequest completion:completion];
}

+ (void)getDefaultWifiEnabledVenues:(CLLocation *)location
                              query:(NSString *)venueName
                             radius:(NSString *)radius
                         completion:(void (^)(NSArray *, NSError *))completion {
    
    id<IRequestBuilder> queryRequest = [[QueryRequestBuilder alloc] init];
    [[self class] getVenues:location radius:radius requestBuilder:queryRequest completion:completion];
}

+ (void)getStarbucksVenues:(CLLocation *)location
                    radius:(NSString *)radius
                completion:(void (^)(NSArray *, NSError *))completion {
    
    id<IRequestBuilder> queryRequest = [[QueryRequestBuilder alloc] init];
    [[self class] getVenues:location radius:radius requestBuilder:queryRequest completion:completion];
}

+ (void)getFoodVenues:(CLLocation *)location
               radius:(NSString *)radius
           completion:(void (^)(NSArray *, NSError *))completion {
    
    id<IRequestBuilder> sectionRequest = [[SectionRequestBuilder alloc] init];
    [[self class] getVenues:location radius:radius requestBuilder:sectionRequest completion:completion];
}

+ (void)getCoffeeVenues:(CLLocation *)location
                 radius:(NSString *)radius
             completion:(void (^)(NSArray *, NSError *))completion {

    id<IRequestBuilder> sectionRequest = [[SectionRequestBuilder alloc] init];

    [[self class] getVenues:location radius:radius requestBuilder:sectionRequest completion:completion];
}

+ (void)getVenues:(CLLocation *)location
           radius:(NSString *)radius
   requestBuilder:(id<IRequestBuilder>)requestBuilder
       completion:(void (^)(NSArray *, NSError *))completion {
    
    NSDictionary *request = [requestBuilder requestWithLocation:location radius:radius eXtraParam:@"coffee"];
    
    [[self class] sendRequestWithLocation:location requestParams:request completion:completion];
}


static NSString *const VERSION = @"20151030";
static NSString *const SORT_CRITERIA_RECENT = @"";

+ (void)getVenueTips:(NSArray *)venueIdentifiers completion:(void (^)(NSDictionary *, NSError *))completion {
    
    if ([venueIdentifiers count] < 1) {
        NSLog(@"ERROR: no venue identifiers to look for !!!");
        
        return;
    }
    
    NSDictionary *queryParams = @{ @"client_id"    : [NSString stringWithUTF8String:kCLIENTID],
                                   @"client_secret": [NSString stringWithUTF8String:kCLIENTSECRET],
                                   @"v"            : VERSION,
                                   @"sort"         : @"recent"
                                   };
    
    [RestKitConfigurator venueTipsResponsesConfiguration];
    
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

+ (void)getVenuePhotos:(NSString *)venueIdentifier completion:(void (^)(NSArray *, NSError *))completion {
    
    NSDictionary *queryParams = @{ @"client_id"    : [NSString stringWithUTF8String:kCLIENTID],
                                   @"client_secret": [NSString stringWithUTF8String:kCLIENTSECRET],
                                   @"v"            : VERSION,
                                   @"sort"         : @"recent"
                                   };
    
    [RestKitConfigurator venuePhotosResponsesConfiguration];
        
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

static NSString *const VENUES_PATH = @"/v2/venues/explore";
+ (void)sendRequestWithLocation:(CLLocation *)location
                   requestParams: (NSDictionary *)requestParams
                     completion:(void (^)(NSArray *, NSError *))completion {
    
    if(nil == location || nil == requestParams) {
        return ;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [RestKitConfigurator generalConfiguration];
    });
    
    [[RKObjectManager sharedManager] getObjectsAtPath:VENUES_PATH
                                           parameters:requestParams
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  
                                                  NSArray *results = [mappingResult array];
                                                  
                                                  NSMutableArray *sink = [NSMutableArray array];
                                                  
                                                  for(Group *group in results) {
                                                      
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
