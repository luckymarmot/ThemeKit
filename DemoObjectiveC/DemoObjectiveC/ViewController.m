//
//  ViewController.m
//  DemoObjectiveC
//
//  Created by Nuno Grilo on 09/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

#import "ViewController.h"
#import "TKThemeColor+Demo.h"
#import "TKThemeGradient+Demo.h"
#import <ThemeKit/ThemeKit.h>

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[TKThemeKit sharedInstance] addObserver:self forKeyPath:@"themes" options:kNilOptions context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualTo:@"themes"]) {
        [self willChangeValueForKey:@"themes"];
        [self didChangeValueForKey:@"themes"];
    }
}

- (NSArray<id<TKTheme>>*)themes
{
    return [TKThemeKit sharedInstance].themes;
}

@end


@implementation CustomWindow

@end


@implementation CustomView

- (void)drawRect:(NSRect)dirtyRect
{
    // Draw solid color
    NSRect leftFrame = NSMakeRect(0, 0, NSWidth(self.bounds)/2, NSHeight(self.bounds));
    [[TKThemeColor brandColor] setFill];
    [NSBezierPath fillRect:leftFrame];
    
    // Draw gradient
    NSRect rightFrame = NSMakeRect(NSWidth(self.bounds)/2 + 1, 0, NSWidth(self.bounds) - NSWidth(self.bounds)/2 + 1, NSHeight(self.bounds));
    [[TKThemeGradient brandGradient] drawInRect:rightFrame angle:90];
}

@end
