//
//  Trip.h
//  TripJournal
//
//  Created by Nathan Condell on 2/18/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Trip : NSObject {
    int _uniqueId;
    NSString *_name;
    NSString *_description;
    NSString *_photo;
    NSDate *_startDate;
    NSDate *_endDate;
}
@property (nonatomic, assign) int uniqueId;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *description;
@property (copy, nonatomic) NSString *photo;
@property (copy, nonatomic) NSDate *startDate;
@property (copy, nonatomic) NSDate *endDate;
//latitude
//longitude

- (id)initWithUniqueId:(int)uniqueId name:(NSString *)name description:(NSString *)description photo:(NSString *)photo startDate:(NSDate *)startDate endDate:(NSDate *)endDate;

@end
