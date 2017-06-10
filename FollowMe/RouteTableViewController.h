//
//  ViewController.h
//  FollowMe
//
//  Created by Andrew on 05/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FollowMe-Swift.h"

/**
 This will show the routes the user has taken
*/

@interface RouteTableViewController : UIViewController<RouteTableMessagePresenter>
@property (nonnull, nonatomic) IBOutlet UILabel* m_title;
@property (nonnull, nonatomic) IBOutlet UITableView* m_routeTable;
@property (nonnull, nonatomic) IBOutlet UIButton* m_currentLocationBtn;
@end

