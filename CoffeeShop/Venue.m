//
//  Venue.m
//  CoffeeShop
//
//  Created by Stefan Burettea on 29/04/2013.
//  Copyright (c) 2013 Stefan Burettea. All rights reserved.
//

#import "Venue.h"

@implementation Photo

@end

@implementation Hours

@end

@implementation Price

@end

@implementation Venue

- (NSString *)lastStringChar:(NSString *)input {
    
    if(nil == input || [input length] < 1) {
        return @"";
    }
    
    return [input substringFromIndex:[input length] - 1];
}

- (NSString *)address {
    NSString *address = @"";
    
    if(nil == self.location) {
        return address;
    }

//    if(self.location.address) {
//        address = [address stringByAppendingString:self.location.address];
//    }
    
    if([self.location.city length] > 0) {
//        if([address length] > 0 && ![[self lastStringChar:address] isEqualToString:@","]) {
//            address = [address stringByAppendingString:@", "];
//        }
        
        address = [address stringByAppendingString:[NSString stringWithFormat: @"%@", self.location.city]];
    }
    
    if([self.location.postalCode length] > 0) {
        if([address length] > 0 && ![[self lastStringChar:address] isEqualToString:@","]) {
            address = [address stringByAppendingString:@", "];
        }
        
        address = [address stringByAppendingString:[NSString stringWithFormat: @"%@", self.location.postalCode]];
    }
    
    return address;
}

- (BOOL)isEqualToVenue:(Venue *)venue {
    
    if(nil == venue) {
        return NO;
    }
    
    BOOL haveEqualIdentifiers = (!self.identifier && !venue.identifier) || [self.identifier isEqualToString:venue.identifier];
    BOOL haveEqualAddresses = (!self.location && !venue.location) || [self.location.address isEqualToString:venue.location.address];
    BOOL haveEqualNames = (!self.name && !venue.name) || [self.name isEqualToString:venue.name];
    
    return haveEqualIdentifiers && haveEqualAddresses && haveEqualNames;
}

- (BOOL)isEqual:(id)object {
    
    if(self == object) {
        return YES;
    }
    
    if(NO == [object isKindOfClass:[Venue class]]) {
        return NO;
    }
    
    return [self isEqualToVenue:(Venue *)object];
}

- (NSUInteger)hash {
    return [self.identifier hash] ^ [self.location.address hash] ^ [self.name hash];
}

@end
