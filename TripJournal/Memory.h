//
//  Memory.h
//  TripJournal
//
//  Created by Nathan Condell on 2/19/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Memory : NSObject {
    int _uniqueId;
    NSNumber *_placeId;
    NSString *_name;
    NSString *_description;
    NSString *_photo;
    NSDate *_date;
}

@property (nonatomic, assign) int uniqueId;
@property (copy, nonatomic) NSNumber *placeId;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *description;
@property (copy, nonatomic) NSString *photo;
@property (copy, nonatomic) NSDate *date;

- (id)initWithUniqueId:(int)uniqueId placeId:(NSNumber *)placeId name:(NSString *)name description:(NSString *)description photo:(NSString *)photo date:(NSDate *)date;

@end
