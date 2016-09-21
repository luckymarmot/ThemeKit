//
//  TKDarkTheme+Demo.m
//  DemoObjectiveC
//
//  Created by Nuno Grilo on 09/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

#import "TKDarkTheme+Demo.h"

@implementation TKDarkTheme (Demo)

- (NSColor*)brandColor
{
    return [NSColor lightGrayColor];
}

- (NSGradient*)brandGradient
{
    return [[NSGradient alloc] initWithStartingColor:[self brandColor] endingColor:[NSColor blueColor]];
}

@end
