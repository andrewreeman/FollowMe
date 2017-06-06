//
//  ViewController.m
//  FollowMe
//
//  Created by Andrew on 05/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

#import "PathViewController.h"
#import "AppDelegate.h"
#import "NSString+StringExtensions_m.m"

@import GoogleMaps;

@interface PathViewController ()

@end

@implementation PathViewController

MapApi* m_mapApi;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate* app = [AppDelegate getApp];
    
    m_mapApi = app.mapApi;
    GMSMapView* map = [m_mapApi createMap];    
    
    [app startLocationUpdatesUsingPresenter:self AndUiLocationUpdateListener:^(CLLocation *location) {
        if(location != NULL) {
            [m_mapApi updateWithMap:map ToLocation:location];
        }
    }];
    
    
    self.view = (UIView*)map;      
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)present:(NSString*)message FromLocationDelegate: (LocationDelegate*)delegate {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[@"followMe" localized] message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:[@"ok" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        LocationUpdatedInteractor* locationInteractor = [[AppDelegate getApp]locationUpdatedInteractor];
        [delegate checkAuthorisation: locationInteractor.locationUsage];
    }];
    
    [alert addAction:ok];    
    [self presentViewController:alert animated:true completion: nil];
}


@end
