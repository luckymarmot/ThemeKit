//
//  TKDefaultThemeTransformer.m
//  DemoObjectiveC
//
//  Created by Nuno Grilo on 09/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

#import "TKDefaultThemeTransformer.h"
#import <ThemeKit/ThemeKit.h>

@implementation TKDefaultThemeTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)value {
    return value ?: [TKThemeKit sharedInstance].defaultTheme.identifier;
}

@end
