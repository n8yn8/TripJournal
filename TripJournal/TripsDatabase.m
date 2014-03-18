//
//  TripsDatabase.m
//  TripJournal
//
//  Created by Nathan Condell on 3/2/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import "TripsDatabase.h"

@implementation TripsDatabase

static TripsDatabase *_database;

+ (TripsDatabase*)database {
    if (_database == nil) {
        _database = [[TripsDatabase alloc] init];
    }
    return _database;
}

- (id)init {
    if ((self = [super init])) {
        
        _format = [[NSDateFormatter alloc] init];
        [_format setDateStyle:NSDateFormatterMediumStyle];
        [_format setTimeStyle:NSDateFormatterMediumStyle];
        
        NSString *docsDir;
        NSArray *dirPaths;
        // Get the documents directory
        dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        docsDir = dirPaths[0];
        //Identifies the application’s Documents directory and constructs a path to the journal.db database file
        _databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"journal.db"]];
        
        //Creates an NSFileManager instance and subsequently uses it to detect if the database file already exists.
        NSFileManager *filemgr = [NSFileManager defaultManager];
        if ([filemgr fileExistsAtPath: _databasePath ] == NO)
        {
            const char *dbpath = [_databasePath UTF8String];
            //If the file does not yet exist the code converts the path to a UTF-8 string and creates the database via a call to the SQLite sqlite3_open() function, passing through a reference to the tripsDB variable declared previously in the interface file (ViewController.h).
            if (sqlite3_open(dbpath, &_database) == SQLITE_OK)
            {
                char *errMsg;
                //Prepares a SQL statement to create the table in the database
                const char *sql_trip = "CREATE TABLE IF NOT EXISTS TRIPS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, DESCRIPTION TEXT, PHOTO TEXT, STARTDATE TEXT, ENDDATE TEXT, LATITUDE INT, LONGITUDE INT)";
                //Reports the success or otherwise of the operation via the status label.
                if (sqlite3_exec(_database, sql_trip, NULL, NULL, &errMsg) != SQLITE_OK)
                {
                    NSLog(@"Failed to create trips table");
                }
                const char *sql_place = "CREATE TABLE IF NOT EXISTS PLACES (ID INTEGER PRIMARY KEY AUTOINCREMENT, TRIPID INT, NAME TEXT, DESCRIPTION TEXT, PHOTO TEXT, STARTDATE TEXT, ENDDATE TEXT, LATITUDE INT, LONGITUDE INT)";
                //Reports the success or otherwise of the operation via the status label.
                if (sqlite3_exec(_database, sql_place, NULL, NULL, &errMsg) != SQLITE_OK)
                {
                    NSLog(@"Failed to create places table");
                }
                const char *sql_memories = "CREATE TABLE IF NOT EXISTS MEMORIES (ID INTEGER PRIMARY KEY AUTOINCREMENT, PLACEID INT, NAME TEXT, DESCRIPTION TEXT, PHOTO TEXT, DATE TEXT, LATITUDE INT, LONGITUDE INT)";
                if (sqlite3_exec(_database, sql_memories, NULL, NULL, &errMsg) != SQLITE_OK)
                {
                    NSLog(@"Failed to create memories table");
                }
                //Closes the db
                sqlite3_close(_database);
            } else {
                NSLog(@"Failed to open/create database");
            }
        } else {
            //NSLog(@"Trips Database found");
        }
    }
    return self;
}

- (void)dealloc {
    sqlite3_close(_database);
    //[super dealloc];
}

- (NSMutableArray *)tripsJournal {
    
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    if (sqlite3_open(dbpath, &_database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT id, name, description, photo, startdate, enddate FROM trips"];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                int uniqueId = sqlite3_column_int(statement, 0);
                NSString *name = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 1)];
                NSString *description = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)];
                NSString *photo = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)];
                NSDate *startdate = [_format dateFromString:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 4)]];
                NSDate *enddate = [_format dateFromString:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 5)]];
                Trip *trip = [[Trip alloc] initWithUniqueId:uniqueId name:name description:description photo:photo startDate:startdate endDate:enddate];
                [retval addObject:trip];
            }
            sqlite3_finalize(statement);
        }
        else {
            NSLog(@"Query returned nothing.");
        }
    }
    return retval;
}

- (NSMutableArray *)tripsAnnotations {
    
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    if (sqlite3_open(dbpath, &_database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT name, latitude, longitude FROM trips"];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *name = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)];
                CLLocationDegrees latitude = sqlite3_column_double(statement, 1);
                CLLocationDegrees longitude = sqlite3_column_double(statement, 2);
                CLLocationCoordinate2D latlng = CLLocationCoordinate2DMake(latitude, longitude);
                MyAnnotation *annot = [[MyAnnotation alloc] initWithTitle:name andCoordinate:latlng];
                [retval addObject:annot];
            }
            sqlite3_finalize(statement);
        }
        else {
            NSLog(@"Query returned nothing.");
        }
    }
    return retval;
}

- (NSMutableArray *)placesJournal:(NSNumber*) tripId {
    
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    if (sqlite3_open(dbpath, &_database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT id, tripid, name, description, photo, startdate, enddate, latitude, longitude FROM places WHERE tripid=%@", tripId];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                int uniqueId = sqlite3_column_int(statement, 0);
                NSNumber *tripId = [[NSNumber alloc] initWithInt: sqlite3_column_int(statement, 1)];
                NSString *name = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)];
                NSString *description = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)];
                NSString *photo = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 4)];
                NSDate *startdate = [_format dateFromString:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 5)]];
                NSDate *enddate = [_format dateFromString:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 6)]];
                CLLocationDegrees latitude = sqlite3_column_double(statement, 7);
                CLLocationDegrees longitude = sqlite3_column_double(statement, 8);
                CLLocationCoordinate2D latlng = CLLocationCoordinate2DMake(latitude, longitude);
                Place *place = [[Place alloc] initWithUniqueId:uniqueId tripId:tripId name:name description:description photo:photo startDate:startdate endDate:enddate];
                place.latlng = latlng;
                [retval addObject:place];
            }
            sqlite3_finalize(statement);
        }
        else {
            NSLog(@"Query returned nothing.");
        }
    }
    return retval;
}
- (NSMutableArray *)placesAnnotations:(NSNumber*) tripId {
    
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    if (sqlite3_open(dbpath, &_database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT name, latitude, longitude FROM places WHERE tripid=%@", tripId];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *name = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 0)];
                CLLocationDegrees latitude = sqlite3_column_double(statement, 1);
                CLLocationDegrees longitude = sqlite3_column_double(statement, 2);
                CLLocationCoordinate2D latlng = CLLocationCoordinate2DMake(latitude, longitude);
                MyAnnotation *annot = [[MyAnnotation alloc] initWithTitle: name andCoordinate:latlng];
                [retval addObject:annot];
            }
            sqlite3_finalize(statement);
        }
        else {
            NSLog(@"Query returned nothing.");
        }
    }
    return retval;
}

-(long long)addTripToJournal:(Trip *)trip {
    
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    if (sqlite3_open(dbpath, &_database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO TRIPS (name, description, photo, startdate, enddate) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\")", trip.name, trip.description, trip.photo, [_format stringFromDate:trip.startDate], [_format stringFromDate:trip.endDate]];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_database, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            return sqlite3_last_insert_rowid(_database);
        } else {
            NSLog(@"Failed to add Trip");
            return -1;
        }
        sqlite3_finalize(statement);
    } else return -1;
    
}

-(void)updateTrip:(Trip *)trip {
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    if (sqlite3_open(dbpath, &_database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"UPDATE trips SET name=\'%@\', description=\'%@\', photo=\'%@\', startdate=\'%@\', enddate=\'%@\', latitude=\'%f\', longitude=\'%f\' WHERE id=%lld", trip.name, trip.description, trip.photo, [_format stringFromDate:trip.startDate], [_format stringFromDate:trip.endDate], trip.latlng.latitude, trip.latlng.longitude, trip.uniqueId];
        //NSLog(@"%@", insertSQL);
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_database, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            //NSLog(@"Trip updated");
        } else {
            NSLog(@"Failed to update Trip");
        }
        sqlite3_finalize(statement);
    }
}

-(long long)addPlaceToJournal:(Place *)place {
    
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    if (sqlite3_open(dbpath, &_database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO PLACES (tripid, name, description, photo, startdate, enddate, latitude, longitude) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%f\", \"%f\")", place.tripId, place.name, place.description, place.photo, [_format stringFromDate:place.startDate], [_format stringFromDate:place.endDate], place.latlng.latitude, place.latlng.longitude];
        //NSLog(@"%@", insertSQL);
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_database, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            return sqlite3_last_insert_rowid(_database);
        } else {
            NSLog(@"Failed to add Place");
            return -1;
        }
        sqlite3_finalize(statement);
    } else return -1;
}

-(void)updatePlace:(Place *)place {
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    if (sqlite3_open(dbpath, &_database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"UPDATE places SET name=\'%@\', description=\'%@\', photo=\'%@\', startdate=\'%@\', enddate=\'%@\', latitude=\'%f\', longitude=\'%f\' WHERE id=%lld", place.name, place.description, place.photo, [_format stringFromDate:place.startDate], [_format stringFromDate:place.endDate], place.latlng.latitude, place.latlng.longitude, place.uniqueId];
        //NSLog(@"%@", insertSQL);
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_database, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            //NSLog(@"Place updated");
        } else {
            NSLog(@"Failed to update place");
        }
        sqlite3_finalize(statement);
    }
}

- (NSMutableArray *)memoriesJournal:(NSNumber *)placeId {
    
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    if (sqlite3_open(dbpath, &_database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT id, placeid, name, description, photo, date, latitude, longitude FROM memories WHERE placeid=%@", placeId];
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                int uniqueId = sqlite3_column_int(statement, 0);
                NSNumber *placeId = [[NSNumber alloc] initWithInt: sqlite3_column_int(statement, 1)];
                NSString *name = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)];
                NSString *description = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)];
                NSString *photo = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 4)];
                NSString *dateString =[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 5)];
                NSDate *date = [_format dateFromString:dateString];
                CLLocationDegrees latitude = sqlite3_column_double(statement, 6);
                CLLocationDegrees longitude = sqlite3_column_double(statement, 7);
                CLLocationCoordinate2D latlng = CLLocationCoordinate2DMake(latitude, longitude);
                
                Memory *memory = [[Memory alloc] initWithUniqueId:uniqueId placeId:placeId name:name description:description photo:photo date:date latlng:latlng];
                [retval addObject:memory];
            }
            sqlite3_finalize(statement);
        }
        else {
            NSLog(@"Query returned nothing.");
        }
    }
    return retval;
}

-(long long)addMemoryToJournal:(Memory *)memory {
    
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    if (sqlite3_open(dbpath, &_database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO MEMORIES (placeid, name, description, photo, date, latitude, longitude) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%f\", \"%f\")", memory.placeId, memory.name, memory.description, memory.photo, [_format stringFromDate:memory.date], memory.latlng.latitude, memory.latlng.longitude];
        //NSLog(@"%@", insertSQL);
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_database, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            return sqlite3_last_insert_rowid(_database);
        } else {
            NSLog(@"Failed to add Memory");
            return -1;
        }
        sqlite3_finalize(statement);
    } else return -1;
    
}

-(void)updateMemory:(Memory *)memory {
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    if (sqlite3_open(dbpath, &_database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"UPDATE memories SET name=\'%@\', description=\'%@\', photo=\'%@\', date=\'%@\', latitude=\'%f\', longitude=\'%f\' WHERE id=%lld", memory.name, memory.description, memory.photo, [_format stringFromDate:memory.date], memory.latlng.latitude, memory.latlng.longitude, memory.uniqueId];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_database, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            //NSLog(@"Memory updated");
        } else {
            NSLog(@"Failed to update Memory");
        }
        sqlite3_finalize(statement);
    }
}

@end
