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
#import "CFTPaymentView.h"
#import "SVProgressHUD.h"

@interface CFTTestViewController () <CFTReaderDelegate, CFTPaymentViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate> {
    
    CGFloat animatedDistance;
}

@property (nonatomic) CFTReader *cardReader;
@property (nonatomic) CFTCard *card;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *numberLabel;
@property (nonatomic) UILabel *readerStatus;
@property (nonatomic) UILabel *messageLabel;
@property (nonatomic) UITextField *timeoutText;
@property (nonatomic) UIButton *chargeButton;
@property (nonatomic) CFTPaymentView *paymentView;

@end




/*
 * Copy and paste your api key and account token below to make
 * test charges with CardFlight. The information can be found
 * in your developer dashboard at getcardflight.com
*/
static NSString *API_KEY = @"eed212eed2dd88499950ade2425f9881";
static NSString *ACCOUNT_TOKEN = @"acc_f6c0bba813e64bf7";

//static NSString *API_KEY = @"PUT_YOUR_API_KEY_HERE";
//static NSString *ACCOUNT_TOKEN = @"PUT_YOUR_ACCOUNT_TOKEN_HERE";



static NSString *kDefaultFont = @"Avenir";
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;

@implementation CFTTestViewController

#pragma mark - Init Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.200f alpha:1.000]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [singleTap setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:singleTap];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"https://staging.api.getcardflight.com/" forKey:@"ROOT_API_URL"];
    
    [[CardFlight sharedInstance] setApiToken:API_KEY
                                accountToken:ACCOUNT_TOKEN];
    [[CardFlight sharedInstance] setAttacheReader:NO];
    [[CardFlight sharedInstance] setLogging:NO];
    
    _cardReader = [[CFTReader alloc] initAndConnect];
    [_cardReader setDelegate:self];
    
    UIFont *defaultFont = [UIFont fontWithName:kDefaultFont size:16];
    
    UILabel *headerLabel = [[UILabel alloc] init];
    [headerLabel setTextAlignment:NSTextAlignmentCenter];
    [headerLabel setText:@"CardFlight SDK Sandbox"];
    [headerLabel setFont:[UIFont fontWithName:kDefaultFont size:18]];
    
    UILabel *versionLabel = [[UILabel alloc] init];
    [versionLabel setTextAlignment:NSTextAlignmentCenter];
    [versionLabel setText:[NSString stringWithFormat:@"SDK %@     iOS %@",
                           [[CardFlight sharedInstance] SDKVersion],
                           [[UIDevice currentDevice] systemVersion]]];
    [versionLabel setFont:defaultFont];
    
    UIButton *swipeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [swipeButton setTitle:@"Attempt Swipe" forState:UIControlStateNormal];
    [swipeButton.titleLabel setFont:defaultFont];
    [swipeButton addTarget:self
                    action:@selector(swipeCard:)
          forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *serialButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [serialButton setTitle:@"Serial Number" forState:UIControlStateNormal];
    [serialButton.titleLabel setFont:defaultFont];
    [serialButton addTarget:self
                    action:@selector(displaySerialNumber:)
          forControlEvents:UIControlEventTouchUpInside];
    
    _nameLabel = [[UILabel alloc] init];
    [_nameLabel setTextAlignment:NSTextAlignmentCenter];
    [_nameLabel setFont:defaultFont];
    
    _numberLabel = [[UILabel alloc] init];
    [_numberLabel setTextAlignment:NSTextAlignmentCenter];
    [_numberLabel setFont:defaultFont];
    
    _messageLabel = [[UILabel alloc] init];
    [_messageLabel setTextAlignment:NSTextAlignmentCenter];
    [_messageLabel setNumberOfLines:0];
    [_messageLabel setFont:defaultFont];
    [_messageLabel setLineBreakMode:NSLineBreakByWordWrapping];
    
    _timeoutText = [[UITextField alloc] init];
    [_timeoutText setFont:defaultFont];
    [_timeoutText setDelegate:self];
    [_timeoutText setKeyboardAppearance:UIKeyboardAppearanceDark];
    [_timeoutText setReturnKeyType:UIReturnKeyDone];
    [_timeoutText setBorderStyle:UITextBorderStyleRoundedRect];
    [_timeoutText setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 0)]];
    [_timeoutText setLeftViewMode:UITextFieldViewModeAlways];
    [_timeoutText setText:@"20"];
    
    UIButton *timeoutButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [timeoutButton setTitle:@"Set Duration" forState:UIControlStateNormal];
    [timeoutButton.titleLabel setFont:defaultFont];
    [timeoutButton addTarget:self
                      action:@selector(setDuration:)
            forControlEvents:UIControlEventTouchUpInside];
    
    _chargeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_chargeButton setTitle:@"Test Charge" forState:UIControlStateNormal];
    [_chargeButton.titleLabel setFont:defaultFont];
    [_chargeButton addTarget:self
                      action:@selector(chargeButtonPressed:)
            forControlEvents:UIControlEventTouchUpInside];
    
    _readerStatus = [[UILabel alloc] init];
    [_readerStatus setTextAlignment:NSTextAlignmentCenter];
    [_readerStatus setTextColor:[UIColor redColor]];
    [_readerStatus setText:@"NOT CONNECTED"];
    [_readerStatus setFont:defaultFont];
    
    [headerLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [versionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [swipeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [serialButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_nameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_numberLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_messageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_timeoutText setTranslatesAutoresizingMaskIntoConstraints:NO];
    [timeoutButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_readerStatus setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_chargeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.view addSubview:headerLabel];
    [self.view addSubview:versionLabel];
    [self.view addSubview:swipeButton];
    [self.view addSubview:serialButton];
    [self.view addSubview:_nameLabel];
    [self.view addSubview:_numberLabel];
    [self.view addSubview:_messageLabel];
    [self.view addSubview:_timeoutText];
    [self.view addSubview:timeoutButton];
    [self.view addSubview:_readerStatus];
    [self.view addSubview:_chargeButton];
    
    NSDictionary *constraints = NSDictionaryOfVariableBindings(headerLabel, versionLabel, swipeButton, serialButton, timeoutButton, _readerStatus, _chargeButton, _messageLabel, _nameLabel, _numberLabel);
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        id topGuide = self.topLayoutGuide;
        [self addVisualConstraints:@"V:[topGuide]-[headerLabel]"
                    withDictionary:NSDictionaryOfVariableBindings(topGuide, headerLabel)];
    } else {
        [self addVisualConstraints:@"V:|-[headerLabel]"
                    withDictionary:NSDictionaryOfVariableBindings(headerLabel)];
    }
    
    [self addVisualConstraints:@"V:[headerLabel]-12-[versionLabel]-15-[swipeButton]"
                withDictionary:constraints];
    [self addVisualConstraints:@"V:[_nameLabel]-[_numberLabel]-[_messageLabel]-15-[_chargeButton]-15-[serialButton]-15-[timeoutButton]-20-[_readerStatus]-|"
                withDictionary:constraints];
    [self addVisualConstraints:@"|-[headerLabel]-|" withDictionary:NSDictionaryOfVariableBindings(headerLabel)];
    [self addVisualConstraints:@"|-[versionLabel]-|" withDictionary:NSDictionaryOfVariableBindings(versionLabel)];
    [self addVisualConstraints:@"|-[swipeButton]-|" withDictionary:NSDictionaryOfVariableBindings(swipeButton)];
    [self addVisualConstraints:@"|-[serialButton]-|" withDictionary:NSDictionaryOfVariableBindings(serialButton)];
    [self addVisualConstraints:@"|-[_nameLabel]-|" withDictionary:NSDictionaryOfVariableBindings(_nameLabel)];
    [self addVisualConstraints:@"|-[_numberLabel]-|" withDictionary:NSDictionaryOfVariableBindings(_numberLabel)];
    [self addVisualConstraints:@"|-[_messageLabel]-|" withDictionary:NSDictionaryOfVariableBindings(_messageLabel)];
    [self addVisualConstraints:@"|-[_chargeButton]-|" withDictionary:NSDictionaryOfVariableBindings(_chargeButton)];
    [self addVisualConstraints:@"[_timeoutText(45)]-[timeoutButton]"
                withDictionary:NSDictionaryOfVariableBindings(_timeoutText, timeoutButton)];
    [self addVisualConstraints:@"|-[_readerStatus]-|" withDictionary:NSDictionaryOfVariableBindings(_readerStatus)];
    
    [self addEqualConstraint:NSLayoutAttributeCenterY from:_timeoutText to:timeoutButton];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:timeoutButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:timeoutButton.superview
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:22]];
    
    _paymentView = [[CFTPaymentView alloc] initWithFrame:CGRectMake(15, 150, 290, 45)];
    [_paymentView setDelegate:self];
    [_paymentView useFont:[UIFont fontWithName:kDefaultFont size:17]];
    [_paymentView useKeyboardAppearance:UIKeyboardAppearanceDark];
    [self.view addSubview:_paymentView];
}

#pragma mark - Private Methods

- (void)addEqualConstraint:(NSLayoutAttribute)attribute from:(id)firstObject to:(id)secondObject {
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:firstObject
                                                          attribute:attribute
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:secondObject
                                                          attribute:attribute
                                                         multiplier:1
                                                           constant:0]];
}

- (void)addVisualConstraints:(NSString *)visualConstraints withDictionary:(NSDictionary *)dictionary {
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:visualConstraints
                                                                      options:0
                                                                      metrics:0
                                                                        views:dictionary]];
}

- (void)chargeButtonPressed:(id)sender {
    
    [self chargeCard];
}

- (void)dismissKeyboard {
    
    [_paymentView resignAll];
    [_timeoutText resignFirstResponder];
}

- (void)swipeCard:(id)sender {
    
    [_nameLabel setText:@""];
    [_numberLabel setText:@""];
    [_cardReader beginSwipeWithMessage:nil];
    [_messageLabel setText:@""];
}

- (void)displayError:(NSError *)error {
    
    [_messageLabel setText:[NSString stringWithFormat:@"Error %li - %@", (long)error.code, error.localizedDescription]];
}

- (void)displaySerialNumber:(id)sender {
    
    [_cardReader retrieveSerialNumber];
}

- (void)setDuration:(id)sender {
    
    [_cardReader swipeTimeoutDuration:[_timeoutText.text integerValue]];
}

- (void)chargeCard {
    
    if (_card) {
        [SVProgressHUD showWithStatus:@"Charging" maskType:SVProgressHUDMaskTypeClear];
        NSDictionary *paymentInfo = @{@"amount":[NSDecimalNumber decimalNumberWithString:@"1.00"],
                                      @"currency": @"USD",
                                      @"description": @"Description"};
        [_card chargeCardWithParameters:paymentInfo
                                success:^(CFTCharge *charge) {
                                    [SVProgressHUD showSuccessWithStatus:@"Success"];
                                    [_messageLabel setText:[NSString stringWithFormat:@"Successfully charged: %@", charge]];
                                }
                                failure:^(NSError *error) {
                                    [SVProgressHUD showErrorWithStatus:@"Failed"];
                                    [self displayError:error];
                                }];
    } else {
        [_messageLabel setText:@"Error - No card to charge"];
    }
}

#pragma mark - Payment View Delegate

- (void)keyedCardResponse:(CFTCard *)card {
    
    _card = card;
}

#pragma mark - Reader Delegate

- (void)readerCardResponse:(CFTCard *)card withError:(NSError *)error {
    
    if (!error) {
        [_nameLabel setText:card.name];
        [_numberLabel setText:card.encryptedCardNumber];
        _card = card;
    }
    else {
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
    
    [_messageLabel setText:[NSString stringWithFormat:@"Serial Number: %@", serialNumber]];
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
