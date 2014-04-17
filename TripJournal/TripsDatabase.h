//
//  TripsDatabase.h
//  TripJournal
//
//  Created by Nathan Condell on 3/2/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Trip.h"
#import "Place.h"
#import "Memory.h"
#import "MyAnnotation.h"

@interface TripsDatabase : NSObject {
    sqlite3 *_database;
}

@property (strong, nonatomic) NSDateFormatter *format;
@property (strong, nonatomic) NSString *databasePath;

+ (TripsDatabase*)database;

- (NSMutableArray *)tripsJournal;
- (NSMutableArray *)tripsAnnotations;
-(long long)addTripToJournal:(Trip*)trip;
-(void)updateTrip:(Trip *)trip;
-(void)deleteTrip:(long long)tripId;

- (NSMutableArray *)placesJournal:(NSNumber*)tripId;
- (NSMutableArray *)placesAnnotations:(NSNumber*) tripId;
-(long long)addPlaceToJournal:(Place*)place;
-(void)updatePlace:(Place *)place;
-(void)deletePlace:(long long)placeId;

- (NSMutableArray *)memoriesJournal:(NSNumber*)placeId;
-(long long)addMemoryToJournal:(Memory*)memory;
-(void)updateMemory:(Memory *)memory;
-(void)deleteMemory:(long long)memoryId;

@end
