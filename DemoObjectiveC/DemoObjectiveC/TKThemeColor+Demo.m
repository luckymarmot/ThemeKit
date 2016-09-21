//
//  TKThemeColor+Demo.m
//  DemoObjectiveC
//
//  Created by Nuno Grilo on 09/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

#import "TKThemeColor+Demo.h"

@implementation TKThemeColor (Demo)

+ (TKThemeColor*)brandColor
{
    return [TKThemeColor colorWithSelector:_cmd];
}

@end
