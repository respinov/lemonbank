//
//  LBViewController.m
//  LemonBank Sample App
//
//  Copyright (c) 2020 ThreatMetrix. All rights reserved.
//

#import "LBViewController.h"

@implementation LBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self showLoginWidgets:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showBusy
{
    NSLog(@"show busy ui");

    [self.accountText   setEnabled:NO];
    [self.passwordText  setEnabled:NO];
    [self.loginButton   setEnabled:NO];
    [self.busyIndicator setHidden:NO];
    [self.busyIndicator setHidesWhenStopped:YES];
    [self.busyIndicator startAnimating];
}

- (void) endBusy
{
    NSLog(@"end busy ui");

    [self.accountText   setEnabled:YES];
    [self.passwordText  setEnabled:YES];
    [self.loginButton   setEnabled:YES];
    [self.busyIndicator setHidden:YES];
    [self.busyIndicator stopAnimating];
}

- (IBAction)prepareLogin:(UIButton *)sender
{
    // Here we want do a quick sanity check that the account/password has some value
    if( self.accountText.text == nil || [self.accountText.text length] == 0 ||
       self.passwordText.text == nil || [self.passwordText.text length] == 0 )
    {
        return;
    }

    // enable spinner to indicate we are doing stuff
    [self showBusy];

    // Now we want to ensure that profiling is complete before we submit
    while([self.td loginOkay] == NO)
    {
        // If profiling isn't complete, wait before submitting
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeInterval:[[self.td profileTimeout] intValue] sinceDate:[NSDate date]]];
    }

    NSLog(@"Profiling complete, go ahead with login immediately");
    [self showDataWidgets];
}

- (void) showDataWidgets
{
    NSLog(@"Submitting login details to server");

    //Clear the content of the WebView to avoid confusion
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    [self endBusy];

    NSString *session   = self.td.sessionID;
    NSString *username  = self.accountText.text;
    NSString *password  = self.passwordText.text;

    // Send the session id to the back end.
    // a POST is preferred here
    NSString *temp      = [NSString stringWithFormat:@"https://tdmobile.threatmetrix.com/mobile_5.php?type=1&session_id=%@&username=%@&password=%@", session, username, password];
    NSURL *url          = [NSURL URLWithString:temp];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    [theRequest setHTTPMethod:@"GET"];
#ifdef USE_BASIC_AUTHENTICATION
    NSString *username = @"username";
    NSString *password = @"password";

    NSString *authStr = [NSString stringWithFormat:@"%@:%@", username, password];
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodingWithLineLength:80]];
    [theRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
#endif

    // We don't actually have another view or XIB, we just
    // show a webview and load some server side info in it
    [self.webView setHidden:NO];
    [self.webView loadRequest:theRequest];
    [self.logoutButton setHidden:NO];
    [self.paymentButton setHidden:NO];
    [self.paymentButton setEnabled:NO]; // FIXME: enable payment button when TMXAuthentication module is ready for release
}

- (IBAction)prepareLogout:(id)sender
{
    [self showLoginWidgets:YES];
}

-(void) showLoginWidgets:(BOOL) callProfile
{
    [self.webView setHidden:YES];
    // Ensure we are in a non-busy state
    [self endBusy];

    if(callProfile)
    {
        [self.td doProfile];
    }

    self.accountText.text  = nil;
    self.passwordText.text = nil;
    [self.accountText becomeFirstResponder];
    [self.logoutButton setHidden:YES];
    [self.paymentButton setHidden:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.accountText)
    {
        [self.passwordText becomeFirstResponder];
    }
    else if(textField == self.passwordText)
    {
        [textField resignFirstResponder];
        [self prepareLogin:self.loginButton];
    }

    return YES;
}

-(IBAction)preparePayment:(UIButton *)sender
{
}

@end
