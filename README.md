iOSBugShaker
============

Shake your iPhone and a MFMailComposerViewController will appear with a screenshot attached.

# Installation

1) Add *MessageUI.framework* to your target

2) Add shake gesture to the application delegate:

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    	...
    	[application setApplicationSupportsShakeToEdit:YES];
    	return YES;
    }

3) Import *BugShakerViewController.h* and *BugShakerViewController.m*:

4) Edit *BugShakerViewController.m* to set your email address:

    #define EMAIL_RECIPIENT @"me@me.com"


# Usage

Create a new View Controller as

    #import <UIKit/UIKit.h>
    #import "BugShakerViewController.h"
    
    @interface ViewController : BugShakerViewController
    @end

and be ready to shake...
