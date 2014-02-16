//
//  CFTTestViewController.m
//  SDKSandbox
//
//  Created by Paul Tower on 11/21/13.
//  Copyright (c) 2013 CardFlight. All rights reserved.
//

#import "CFTTestViewController.h"
#import "CFTReader.h"
#import "CFTCard.h"
#import "CardFlight.h"

@interface CFTTestViewController () <readerDelegate, UITextFieldDelegate> {
    
    CGFloat animatedDistance;
}

@property (nonatomic) CFTReader *cardReader;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *numberLabel;
@property (nonatomic) UILabel *readerStatus;
@property (nonatomic) UILabel *errorMessage;
@property (nonatomic) UITextField *timeoutText;

@end

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

@implementation CFTTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _cardReader = [[CFTReader alloc] initAndConnect];
    [_cardReader setDelegate:self];
    
    UILabel *headerLabel = [[UILabel alloc] init];
    [headerLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [headerLabel setTextAlignment:NSTextAlignmentCenter];
    if ([UIFont respondsToSelector:@selector(preferredFontForTextStyle:)]) {
        [headerLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    }
    [headerLabel setText:@"CardFlight SDK Sandbox"];
    [self.view addSubview:headerLabel];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[headerLabel]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(headerLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-45-[headerLabel]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(headerLabel)]];
    
    UILabel *versionLabel = [[UILabel alloc] init];
    [versionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [versionLabel setTextAlignment:NSTextAlignmentCenter];
    [versionLabel setText:[NSString stringWithFormat:@"SDK %@     iOS %@",
                           [[CardFlight sharedInstance] SDKVersion],
                           [[UIDevice currentDevice] systemVersion]]];
    [self.view addSubview:versionLabel];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[versionLabel]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(versionLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[headerLabel]-20-[versionLabel]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(headerLabel, versionLabel)]];
    
    UIButton *swipeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [swipeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [swipeButton setTitle:@"Attempt Swipe" forState:UIControlStateNormal];
    [swipeButton addTarget:self
                    action:@selector(swipeCard:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:swipeButton];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[swipeButton]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(swipeButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[versionLabel]-30-[swipeButton]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(swipeButton, versionLabel)]];
    
    UIButton *serialButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [serialButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [serialButton setTitle:@"Serial Number" forState:UIControlStateNormal];
    [serialButton addTarget:self
                    action:@selector(displaySerialNumber:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:serialButton];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[serialButton]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(serialButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[swipeButton]-30-[serialButton]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(swipeButton, serialButton)]];
    
    _nameLabel = [[UILabel alloc] init];
    [_nameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_nameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_nameLabel];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_nameLabel]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_nameLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[serialButton]-30-[_nameLabel]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_nameLabel, serialButton)]];
    
    _numberLabel = [[UILabel alloc] init];
    [_numberLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_numberLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_numberLabel];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_numberLabel]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_numberLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_nameLabel]-10-[_numberLabel]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_nameLabel, _numberLabel)]];
    
    _errorMessage = [[UILabel alloc] init];
    [_errorMessage setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_errorMessage setTextAlignment:NSTextAlignmentCenter];
    [_errorMessage setNumberOfLines:0];
    [_errorMessage setLineBreakMode:NSLineBreakByWordWrapping];
    [self.view addSubview:_errorMessage];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_errorMessage]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_errorMessage)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_numberLabel]-30-[_errorMessage]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_errorMessage, _numberLabel)]];
    
    _timeoutText = [[UITextField alloc] init];
    [_timeoutText setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_timeoutText setDelegate:self];
    [_timeoutText setKeyboardAppearance:UIKeyboardAppearanceDark];
    [_timeoutText setReturnKeyType:UIReturnKeyDone];
    [_timeoutText setBorderStyle:UITextBorderStyleRoundedRect];
    [_timeoutText setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 0)]];
    [_timeoutText setLeftViewMode:UITextFieldViewModeAlways];
    [_timeoutText setText:@"20"];
//    [self.view addSubview:_timeoutText];
    
    UIButton *timeoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [timeoutButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [timeoutButton setTitle:@"Set Duration" forState:UIControlStateNormal];
    [timeoutButton addTarget:self
                      action:@selector(setDuration:)
            forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:timeoutButton];
    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_timeoutText]-5-[timeoutButton]-|"
//                                                                      options:0
//                                                                      metrics:nil
//                                                                        views:NSDictionaryOfVariableBindings(_timeoutText, timeoutButton)]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_timeoutText]-80-|"
//                                                                      options:0
//                                                                      metrics:nil
//                                                                        views:NSDictionaryOfVariableBindings(_timeoutText)]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[timeoutButton]-80-|"
//                                                                      options:0
//                                                                      metrics:nil
//                                                                        views:NSDictionaryOfVariableBindings(timeoutButton)]];
    
    _readerStatus = [[UILabel alloc] init];
    [_readerStatus setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_readerStatus setTextAlignment:NSTextAlignmentCenter];
    [_readerStatus setTextColor:[UIColor redColor]];
    [_readerStatus setText:@"NOT CONNECTED"];
    [self.view addSubview:_readerStatus];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_readerStatus]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_readerStatus)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_readerStatus]-20-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_readerStatus)]];
}

- (void)swipeCard:(id)sender {
    
    [_nameLabel setText:@""];
    [_numberLabel setText:@""];
    [_cardReader beginSwipeWithMessage:@"Swipe your card now"];
    [_errorMessage setText:@""];
}

- (void)displayError:(NSError *)error {
    
    [_errorMessage setText:[NSString stringWithFormat:@"Error %i - %@", error.code, error.localizedDescription]];
}

- (void)displaySerialNumber:(id)sender {
    
    [_cardReader retrieveSerialNumber];
}

- (void)setDuration:(id)sender {
    
    [_cardReader swipeTimeoutDuration:[_timeoutText.text integerValue]];
}

#pragma mark - Reader Delegate

- (void)readerCardResponse:(CFTCard *)card withError:(NSError *)error {
    
    if (!error) {
        [_nameLabel setText:card.name];
        [_numberLabel setText:card.encryptedCardNumber];
        NSDictionary *paymentInfo = @{@"amount":[NSDecimalNumber decimalNumberWithString:@"1.00"],
                                      @"currency": @"USD",
                                      @"description": @"Description"};
        [card chargeCardWithParameters:paymentInfo
                               success:^(CFTCharge *charge) {
                                   NSLog(@"Successfully charged: %@", charge);
                                }
                                failure:^(NSError *error) {
                                    NSLog(@"Error charging card: %@", [error localizedDescription]);
                                    //[self displayError:error];
                                }];
    }
    else {
        // NSLog(@"Error: %@", [error localizedDescription]);
        [self displayError:error];
    }
}

- (void)readerIsConnected:(BOOL)isConnected withError:(NSError *)error {
    
    if (isConnected) {
        [_readerStatus setText:@"CONNECTED"];
        [_readerStatus setTextColor:[UIColor greenColor]];
        [self swipeCard:nil];
    }
    else {
        // NSLog(@"Error: %@", error);
        [self displayError:error];
    }
}

- (void)readerIsAttached {
    
    [_readerStatus setText:@"CONNECTING"];
    [_readerStatus setTextColor:[UIColor blueColor]];
}

- (void)readerIsDisconnected {
    
    [_readerStatus setText:@"NOT CONNECTED"];
    [_readerStatus setTextColor:[UIColor redColor]];
}

- (void)readerSerialNumber:(NSString *)serialNumber {
    
    [_errorMessage setText:[NSString stringWithFormat:@"Serial Number: %@", serialNumber]];
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0) {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0) {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else {
        //animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView animateWithDuration:KEYBOARD_ANIMATION_DURATION
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.view setFrame:viewFrame];
                     }
                     completion:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView animateWithDuration:KEYBOARD_ANIMATION_DURATION
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.view setFrame:viewFrame];
                     }
                     completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

@end
