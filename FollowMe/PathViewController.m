//
//  ViewController.m
//  FollowMe
//
//  Created by Andrew on 05/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

#import "PathViewController.h"
#import "AppDelegate.h"
@import GoogleMaps;

@interface PathViewController ()

@end

@implementation PathViewController

MapApi* m_mapApi;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    m_mapApi = [AppDelegate getApp].mapApi;
    GMSMapView* map = [m_mapApi createMap];
    self.view = (UIView*)map;      
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
