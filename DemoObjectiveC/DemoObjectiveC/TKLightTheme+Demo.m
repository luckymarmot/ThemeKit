//
//  TKLightTheme+Demo.m
//  DemoObjectiveC
//
//  Created by Nuno Grilo on 09/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

#import "TKLightTheme+Demo.h"

@implementation TKLightTheme (Demo)

- (NSColor*)brandColor
{
    return [NSColor orangeColor];
}

- (NSGradient*)brandGradient
{
    return [[NSGradient alloc] initWithStartingColor:[self brandColor] endingColor:[NSColor blackColor]];
}

@end
