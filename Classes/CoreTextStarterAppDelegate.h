//
//  CoreTextStarterAppDelegate.h
//  CoreTextStarter
//
//  Created by Joshua Garnham on 14/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CoreTextStarterViewController;

@interface CoreTextStarterAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    CoreTextStarterViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CoreTextStarterViewController *viewController;

@end

