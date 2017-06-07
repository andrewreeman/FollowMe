//
//  AppDelegate.h
//  FollowMe
//
//  Created by Andrew on 05/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FollowMe-Swift.h"
#import "LocationDelegate.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

@property (strong) MapApi *mapApi;
//@property (strong) LocationDelegate *locationDelegate;
@property (strong) LocationUpdatedInteractor* locationUpdatedInteractor;
@property (strong) LocationTrackingInteractor* locationTrackingInteractor;

+ (AppDelegate*) getApp;
- (void)saveContext;
-(void)startLocationUpdatesUsingPresenter: (NSObject<LocationMessagePresenter>*)presenter AndUiLocationUpdateListener: (LocationUpdatedListener)locationUiUpdateListener;
-(void)startListeningToTrackingStateUsing:(void(^)(TrackingState)) newTrackingState;

@end

