//
//  BugShakerViewController.m
//  Mobee
//
//  Created by Thibault Le Conte on 6/3/13.
//
//

#import "BugShakerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "AppDelegate.h"

#define EMAIL_RECIPIENT @"me@me.com"

@interface BugShakerViewController ()

@property (strong, nonatomic) NSData *screenshotImageData;

@end

@implementation BugShakerViewController

#pragma mark - screenshot

- (NSData*)returnScreenshotImageData {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(appDelegate.window.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(appDelegate.window.bounds.size);
    [appDelegate.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *data = UIImagePNGRepresentation(image);
    return data;
}

#pragma mark - subject

- (NSString*)returnSubject {
    NSString *subject = [NSString stringWithFormat:@"\n-- Infos --\nTarget name: %@\n", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
    subject = [subject stringByAppendingFormat:@"Target version: %@\n", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    subject = [subject stringByAppendingFormat:@"Target build: %@\n", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    
    return subject;
}

#pragma mark - email

- (void)sendEmail {
    // Init composer
    MFMailComposeViewController *composeView = [[MFMailComposeViewController alloc] init];
    [composeView setMailComposeDelegate:self];
    // Set recipients
    [composeView setToRecipients:[[NSArray alloc] initWithObjects:EMAIL_RECIPIENT, nil]];
    // Set subject title
    [composeView setSubject:[NSString stringWithFormat:@"[BS]-iOS-%@-%@",
                             [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"],
                             [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]];
    // Set message
    [composeView setMessageBody:[self returnSubject] isHTML:NO];
    // Add screenshot
    if (self.screenshotImageData)
        [composeView addAttachmentData:self.screenshotImageData mimeType:@"image/png"
                              fileName:[NSString stringWithFormat:@"debug-screenshot-%f.png",
                                        [[NSDate date] timeIntervalSince1970]]];
    // Display composer
    if ([MFMailComposeViewController canSendMail])
        [self presentViewController:composeView animated:YES completion:^{}];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    switch (result) {
        case MFMailComposeResultCancelled: case MFMailComposeResultFailed: case MFMailComposeResultSaved:
            NSLog(@"Email share failed");
            break;
        case MFMailComposeResultSent: {
            NSLog(@"Email share succeeded");
            
            [self dismissViewControllerAnimated:YES completion:^{}];
            break;
        }
        default:
            NSLog(@"Unknown Email social share result");
            break;
    }
    
    [controller.presentingViewController dismissViewControllerAnimated:YES completion:^{}];
}


#pragma mark - shake gesture
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if ([MFMailComposeViewController canSendMail]) {
        self.screenshotImageData = [self returnScreenshotImageData];
        [self sendEmail];
    }
}

#pragma mark - View lifecycle -

- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Init
    self.screenshotImageData = [[NSData alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // Shake motion handler
    [self becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    // Shake motion handler
    [self resignFirstResponder];
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
}

@end
