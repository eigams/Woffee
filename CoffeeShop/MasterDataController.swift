//
//  MasterDataController.swift
//  CoffeeShop
//
//  Created by Stefan Buretea on 4/20/15.
//  Copyright (c) 2015 Stefan Burettea. All rights reserved.
//

import UIKit

class MasterDataController: NSObject {

    private func configureRestKit() {
        
        
        let baseURL = NSURL(string: "https://api.foursquare.com/v2")
//        let client = AFHTTPClient(baseURL: baseURL)
//        
//        // initialize RestKit
//        let objectManager = RKObjectManager(HTTPClient: client)
//        
//        var venueMapping = RKObjectMapping.mappingForClass(Venue)
//        venueMapping.addAttributeMappingsFromDictionary(["name": "name",
//                                                         "id"  : "identifier"])
//
//        var locationMapping = RKObjectMapping.mappingForClass(Location)
//        RKObjectMapping *locationMapping = [RKObjectMapping mappingForClass:[Location class]];
//        [locationMapping addAttributeMappingsFromDictionary:@{ @"address" : @"address",
//        @"city" : @"city",
//        @"country" : @"country",
//        @"crossStreet" : @"crossStreet",
//        @"postalCode" : @"postalCode",
//        @"state" : @"state",
//        @"distance" : @"distance",
//        @"lat" : @"lat",
//        @"lng" : @"lng"}];
//        
//        [venueMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"location" toKeyPath:@"location" withMapping:locationMapping]];
//        
//        RKObjectMapping *tipsMapping = [RKObjectMapping mappingForClass:[TipR class]];
//        [tipsMapping addAttributeMappingsFromDictionary:@{ @"id": @"identifier",
//        @"createdAt": @"createdAt",
//        @"text": @"text"}];
//        
//        RKObjectMapping *statsMapping = [RKObjectMapping mappingForClass:[Stats class]];
//        [statsMapping addAttributeMappingsFromDictionary:@{ @"checkinsCount" : @"checkins",
//        @"tipsCount" : @"tips",
//        @"usersCount" : @"users"}];
//        
//        [venueMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"stats" toKeyPath:@"stats" withMapping:statsMapping]];
//        RKObjectMapping *groupsMapping = [RKObjectMapping mappingForClass:[Group class]];
//        [groupsMapping addAttributeMappingsFromDictionary:@{@"name" : @"name",
//        @"type" : @"type"}];
//        
//        RKObjectMapping *groupItemsMapping = [RKObjectMapping mappingForClass:[GroupItems class]];
//        [groupItemsMapping addAttributeMappingsFromDictionary:@{ @"referralId" : @"referralId",
//        @"reasons": @"reasons"}];
//        
//        [groupItemsMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"tips" toKeyPath:@"tips" withMapping:tipsMapping]];
//        [groupItemsMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"venue" toKeyPath:@"venue" withMapping:venueMapping]];
//        [groupsMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"items" toKeyPath:@"items" withMapping:groupItemsMapping]];
//        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:groupsMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"response.groups" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
//        
//        [objectManager addResponseDescriptor:responseDescriptor];
        
    }
    
    private func f() {
    
    }
    
}
