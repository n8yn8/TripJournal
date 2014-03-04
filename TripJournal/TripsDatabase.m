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
        [_format setDateFormat:@"mm-dd-yyyy"];
        
        NSLog(@"init of TripsDatabase");
        
        NSString *docsDir;
        NSArray *dirPaths;
        // Get the documents directory
        dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        docsDir = dirPaths[0];
        //Identifies the application’s Documents directory and constructs a path to the trips.db database file
        _databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"trips.db"]];
        
        //Creates an NSFileManager instance and subsequently uses it to detect if the database file already exists.
        NSFileManager *filemgr = [NSFileManager defaultManager];
        if ([filemgr fileExistsAtPath: _databasePath ] == NO)
        {
            const char *dbpath = [_databasePath UTF8String];
            //If the file does not yet exist the code converts the path to a UTF-8 string and creates the database via a call to the SQLite sqlite3_open() function, passing through a reference to the tripsDB variable declared previously in the interface file (ViewController.h).
            if (sqlite3_open(dbpath, &_database) == SQLITE_OK)
            {
                char *errMsg;
                //Prepares a SQL statement to create the contacts table in the database
                const char *sql_stmt =
                "CREATE TABLE IF NOT EXISTS TRIPS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, DESCRIPTION TEXT, PHOTO TEXT, STARTDATE TEXT, ENDDATE TEXT)";
                //Reports the success or otherwise of the operation via the status label.
                if (sqlite3_exec(_database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
                {
                    NSLog(@"Failed to create table");
                }
                //Closes the db
                sqlite3_close(_database);
            } else {
                NSLog(@"Failed to open/create database");
            }
        } else {
            NSLog(@"Trips Database found");
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

-(void)addToJournal:(Trip *)trip {
    
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    if (sqlite3_open(dbpath, &_database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO TRIPS (name, description, photo, startdate, enddate) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\")", trip.name, trip.description, trip.photo, trip.startDate, trip.endDate];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_database, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"Successfully added Trip");
        } else {
            NSLog(@"Failed to add Trip");
        }
        sqlite3_finalize(statement);
    }
    
}

@end
