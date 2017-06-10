//
//  AppDelegate.m
//  FollowMe
//
//  Created by Andrew on 05/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

#import "AppDelegate.h"
#import "NSString+StringExtensions_m.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

LocationDelegate* m_locationDelegate;

+(AppDelegate*)getApp {
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
                
    self.locationUpdatedInteractor = [[LocationUpdatedInteractor alloc]init];
    self.locationTrackingInteractor = [[LocationTrackingInteractor alloc]init];
    self.routeInteractor = [[RouteInteractorObjCWrapper alloc]init];
    m_locationDelegate = [[LocationDelegate alloc]init];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if( [[self locationUpdatedInteractor] locationUsage] == IN_APP ){
        [m_locationDelegate stop];
    }
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self startUpdatingLocation];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"FollowMe"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

//MARK: public methods

/**
 This will start the location updates. The presenter is used for displaying messages to the user regarding location authorisation. 
*/
-(void)startLocationUpdatesUsingPresenter: (NSObject<LocationMessagePresenter>*)presenter AndUiLocationUpdateListener:  (void(^)(CLLocation*, TrackingState))locationUiUpdateListener
{
    
    [[self routeInteractor] setUiUpdateListener:locationUiUpdateListener];
    [self locationUpdatedInteractor].locationUpdatedListener = [[self routeInteractor]locationUpdated];
    [m_locationDelegate setPresenter:presenter];
    [m_locationDelegate setLocationUpdatedListener:[[self locationUpdatedInteractor] locationUpdated]];
    
    [self startUpdatingLocation];
}

/**
 This will clear the current tracking state listeners then initialise and add the one passed as a parameter
*/
-(void)startListeningToTrackingStateUsing:(void(^)(TrackingState)) newTrackingState {
    [[self locationTrackingInteractor] clearTrackingStateListeners];
    
    // add tracking state listeners
    [[self locationTrackingInteractor] addWithTrackingStateListener:newTrackingState];
    
    // add the tracking state listener provided by the location updated interactor
    [[self locationTrackingInteractor] addWithTrackingStateListener:
     [[self locationUpdatedInteractor] trackingStateListener]
    ];
    
    /** There is a potential issue here! This is currently relying on the order of being added.
     startUpdatingLocation depends on the locationUpdatedInteractor's locationUsage being updated
     first. A better design would have a 'locationUsageUpdated' event in the locationUpdatedInteractor
    */
    [[self locationTrackingInteractor] addWithTrackingStateListener:^(enum TrackingState newState) {
        [self startUpdatingLocation];
    }];
}

-(void)stopLocationUpdates {
    [[self locationTrackingInteractor] updateTrackingWithNewState:TrackingStateTrackingOff];
    [m_locationDelegate stop];
    [[self locationTrackingInteractor] clearTrackingStateListeners];
}

// MARK: private methods

-(void)startUpdatingLocation {
    [m_locationDelegate startUpdatingLocation:[[self locationUpdatedInteractor] locationUsage]];
}

@end
