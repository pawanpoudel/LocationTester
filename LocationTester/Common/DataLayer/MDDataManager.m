//
//  MDDataManager.m
//  LocationTester
//
//  Created by PAWAN POUDEL on 10/18/12.
//  Copyright (c) 2012 Mobile Defense Inc. All rights reserved.
//

#import "MDDataManager.h"

#import "MDLocation.h"
#import "MDTrip.h"

@interface MDDataManager()

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation MDDataManager

#pragma mark - Accessors

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

#pragma mark - Convenience Methods

+ (MDDataManager *)sharedDataManager {
    static dispatch_once_t onceToken;
    static MDDataManager *dataManager = nil;
    
    dispatch_once(&onceToken, ^{
        dataManager = [[self alloc] init];
    });
    
    return dataManager;
}

#pragma mark - Data access helpers
#pragma mark - Create operations

- (MDLocation *)createLocationEntity {
    return [NSEntityDescription insertNewObjectForEntityForName:@"MDLocation"
                                         inManagedObjectContext:self.managedObjectContext];
}

- (MDTrip *)createTripEntity {
    return [NSEntityDescription insertNewObjectForEntityForName:@"MDTrip"
                                         inManagedObjectContext:self.managedObjectContext];
}

#pragma mark - Fetch Operations

- (NSArray *)fetchTrips {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"MDTrip"
                                                  inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entityDesc];
    
    NSError *error = nil;
    NSArray *trips = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (trips == nil) {
        DebugLog(@"Unable to fetch trips for entity: MDTrip. Error: %@", [error localizedDescription]);
    }
    
    return trips;
}

#pragma mark - Delete operations

- (NSString *)getFilePathForTrip:(MDTrip *)trip {
    NSDateFormatter *fileDateFomatter = [[NSDateFormatter alloc] init];
    [fileDateFomatter setDateFormat:@"yyyy-MM-dd--hh-mm-ss"];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/Location-%@.txt", 
                          NSTemporaryDirectory(),
                          [fileDateFomatter stringFromDate:trip.tripStartTime]];
    return filePath;
}

- (void)deleteTrips {
    NSArray *trips = [self fetchTrips];
    
    [trips enumerateObjectsUsingBlock:^(MDTrip *trip, NSUInteger index, BOOL *stop) {
        
        // Delete files from temp directory
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *filePath = [self getFilePathForTrip:trip];
        NSError *error = nil;
        
        if ([fileManager fileExistsAtPath:filePath]) {
            DebugLog(@"FileName to delete: %@", filePath);
            [fileManager removeItemAtPath:filePath error:&error];
        }
        
        [self.managedObjectContext deleteObject:trip];
    }];
    
    [self saveContext];
}

#pragma mark - Core Data stack

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {

            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Encountered unresolved error. Please restart the app."
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"OK", nil];
            [alertView show];
            
            DebugLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
        } 
    }
}

- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"LocationTester" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"LocationTester.sqlite"];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    

    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSError *error = nil;
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Encountered fatal error. Please restart the app."
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
        [alertView show];
        
        DebugLog(@"COREDATA FAILZORZ!!! Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
