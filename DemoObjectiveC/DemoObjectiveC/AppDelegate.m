//
//  AppDelegate.m
//  DemoObjectiveC
//
//  Created by Nuno Grilo on 09/09/16.
//  Copyright © 2016 Paw Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <ThemeKit/ThemeKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
    // Setup window theme policy
    [TKThemeKit sharedInstance].windowThemePolicy = TKThemeKitWindowThemePolicyThemeAllWindows;
    //[TKThemeKit sharedInstance].windowThemePolicy = TKThemeKitWindowThemePolicyThemeSomeWindowClasses;
    //[TKThemeKit sharedInstance].themableWindowClasses = @[[CustomWindow class]];
    //[TKThemeKit sharedInstance].windowThemePolicy = TKThemeKitWindowThemePolicyDoNotThemeWindows;
    
    // User themes folder
    NSString* workingDirectory = [NSFileManager defaultManager].currentDirectoryPath;
    NSURL* projectRootURL = [NSURL fileURLWithPath:workingDirectory isDirectory:YES].URLByDeletingLastPathComponent.URLByDeletingLastPathComponent.URLByDeletingLastPathComponent.URLByDeletingLastPathComponent;
    [TKThemeKit sharedInstance].userThemesFolderURL = projectRootURL;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


@end
