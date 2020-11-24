//
//  LBViewController.h
//  LemonBank Sample App
//
//  Copyright (c) 2020 ThreatMetrix. All rights reserved.
//
#if defined(__has_feature) && __has_feature(modules)
@import UIKit;
#else
#import <UIKit/UIKit.h>
#endif

#import "LBProfileController.h"

/// All UI logic is handled here
@interface LBViewController : UIViewController <UITextFieldDelegate>

/// Reference to the Profile Controller
@property (strong, nonatomic) IBOutlet LBProfileController *td;
/// The username/account name text field
@property (strong, nonatomic) IBOutlet UITextField *accountText;
/// Password field
@property (strong, nonatomic) IBOutlet UITextField *passwordText;
/// Busy indicator, used if the profiling takes longer than expected and the user has to wait
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *busyIndicator;
/// Used to display the information from the server post-login
@property (strong, nonatomic) IBOutlet UIWebView *webView;
/// Used to log in (no actually logging in happens, but we switch to the data view)
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
/// Used to return to the log in screen (no actual logging out happens)
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;
/// Used to return to simulate strong authentication API calls
@property (strong, nonatomic) IBOutlet UIButton *paymentButton;
/// Used to pass push notification token to FP server in case it changes
@property (readwrite, nonatomic) BOOL isApnTokenChanged;

/// When the user clicks the login button this function is called.
///
/// Either the view will switch to the data view or at least display a spinner if the
/// login is delayed by the profiling
- (IBAction)prepareLogin:(UIButton *)sender;

/// This triggers the display of the "data" screen that is displayed after login
///
/// We want to send the login info and session id to the server. Usually you would want to
/// get an authentication validation response from the server before proceeding... but we don't actually
/// care here, so we just do a form submission and display the results from the server
- (void)showDataWidgets;

/// Display the login view
///
/// During start up, or after a "log out" (such as it is) we want to display the widgets
/// used in the login process. This is also where we trigger a profiling request. The earlier
/// we trigger the profile, the less impact it will have on the login.
-(void) showLoginWidgets:(BOOL)callProfile;

/// This is called when the user clicks the log out button, and initiates the transition
/// back to the login screen.
- (IBAction)prepareLogout:(id)sender;

/// Called after the view has loaded
///
/// This is where we display the "login" widgets
- (void)viewDidLoad;

/// Display the busy indicator and disable any input
- (void) showBusy;

/// Hide the busy indicator and enable input fields
- (void) endBusy;

/// When user clicks the payment button this method is called
/// FIXME: Currently an empty method, enable payment button after TMXAuthentication is released
- (IBAction)preparePayment:(id)sender;

@end
