//
//  Place.h
//  TripJournal
//
//  Created by Nathan Condell on 2/19/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Place : NSObject {
    int _uniqueId;
    NSNumber *_tripId;
    NSString *_name;
    NSString *_description;
    NSString *_photo;
    NSDate *_startDate;
    NSDate *_endDate;
}

@property (nonatomic, assign) int uniqueId;
@property (copy, nonatomic) NSNumber *tripId;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *description;
@property (copy, nonatomic) NSString *photo;
@property (copy, nonatomic) NSDate *startDate;
@property (copy, nonatomic) NSDate *endDate;

- (id)initWithUniqueId:(int)uniqueId tripId:(NSNumber *)tripId name:(NSString *)name description:(NSString *)description photo:(NSString *)photo startDate:(NSDate *)startDate endDate:(NSDate *)endDate;

@end
