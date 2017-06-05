//
//  LocationDelegate.h
//  FollowMe
//
//  Created by Andrew on 05/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

#ifndef LocationDelegate_h
#define LocationDelegate_h

#import <CoreLocation/CoreLocation.h>
#import "Presenter.h"

@interface LocationDelegate : NSObject<CLLocationManagerDelegate>

-(void)setPresenter:(NSObject<Presenter>*)presenter;

@end

#endif /* LocationDelegate_h */
