//
//  NSString+StringExtensions_m.m
//  FollowMe
//
//  Created by Andrew on 05/06/2017.
//  Copyright © 2017 Stepwise. All rights reserved.
//

#import "NSString+StringExtensions_m.h"

@implementation NSString (StringExtensions_m)

-(NSString*)localized {
    return NSLocalizedString(self, "");
}

@end
