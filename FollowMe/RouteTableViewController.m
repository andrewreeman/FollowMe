//
//  RouteTableViewController.m
//  FollowMe
//
//  Created by Andrew on 10/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "RouteTableViewController.h"
#import "NSString+StringExtensions_m.m"
#import "FollowMe-Swift.h"

@import Toast;

@interface RouteTableViewController ()

@end

RouteTableDelegate* m_tableDelegate;
@implementation RouteTableViewController

-(void) viewDidLoad {
    m_tableDelegate = [[RouteTableDelegate alloc]init];
    [[self m_routeTable] setDelegate:m_tableDelegate];
    [[self m_routeTable] setDataSource:m_tableDelegate];
}

-(void) viewDidAppear:(BOOL)animated {
    [_m_routeTable reloadData];
}

@end
