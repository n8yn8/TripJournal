//
//  PlacesDatabase.m
//  TripJournal
//
//  Created by Nathan Condell on 3/2/14.
//  Copyright (c) 2014 Nathan Condell. All rights reserved.
//

#import "PlacesDatabase.h"
#import "Place.h"

@implementation PlacesDatabase

static PlacesDatabase *_database;

+ (PlacesDatabase*)database {
    if (_database == nil) {
        _database = [[PlacesDatabase alloc] init];
    }
    return _database;
}

- (id)init {
    if ((self = [super init])) {
        
        NSLog(@"init of PlacesDatabase");
        
        NSString *docsDir;
        NSArray *dirPaths;
        // Get the documents directory
        dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        docsDir = dirPaths[0];
        //Identifies the application’s Documents directory and constructs a path to the places.db database file
        _databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"places.db"]];
        
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
                "CREATE TABLE IF NOT EXISTS PLACES (ID INTEGER PRIMARY KEY AUTOINCREMENT, TRIPID INT, NAME TEXT, DESCRIPTION TEXT, PHOTO TEXT, STARTDATE TEXT, ENDDATE TEXT)";
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
            NSLog(@"Database found");
        }
    }
    return self;
}

- (void)dealloc {
    sqlite3_close(_database);
    //[super dealloc];
}

- (NSMutableArray *)placesJournal:(NSNumber*) tripId {
    
    NSLog(@"Began search for places with tripId %@", tripId);
    
    _format = [[NSDateFormatter alloc] init];
    [_format setDateFormat:@"mm-dd-yyyy"];
    
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    if (sqlite3_open(dbpath, &_database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT id, tripid, name, description, photo, startdate, enddate FROM places WHERE tripid=%@", tripId];
        NSLog(@"%@", querySQL);
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSLog(@"A row is returned");
                int uniqueId = sqlite3_column_int(statement, 0);
                NSNumber *tripId = [[NSNumber alloc] initWithInt: sqlite3_column_int(statement, 1)];
                NSString *name = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 2)];
                NSLog(@"Place found has name %@", name);
                NSString *description = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 3)];
                NSString *photo = [[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 4)];
                NSDate *startdate = [_format dateFromString:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 5)]];
                NSDate *enddate = [_format dateFromString:[[NSString alloc] initWithUTF8String: (const char *) sqlite3_column_text(statement, 6)]];
                Place *place = [[Place alloc] initWithUniqueId:uniqueId tripId:tripId name:name description:description photo:photo startDate:startdate endDate:enddate];
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

@end
