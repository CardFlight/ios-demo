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
#import "CFTCustomView.h"
#import "CFTCustomEntryTextField.h"
#import "CardFlight.h"

@interface CFTTestViewController () <readerDelegate, UITextFieldDelegate> {
    
    CGFloat animatedDistance;
}

@property (nonatomic) CFTReader *cardReader;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *numberLabel;
@property (nonatomic) UILabel *readerStatus;
@property (nonatomic) UILabel *messageLabel;
@property (nonatomic) UITextField *timeoutText;
@property (nonatomic) CFTCustomView *customView;
@property (nonatomic) UITextField *expirationDate;
@property (nonatomic) UITextField *cvv;

@end




/*
 * Copy and paste your api key and account token below to make
 * test charges with CardFlight. The information can be found
 * in your developer dashboard at getcardflight.com
*/
static NSString *API_KEY = @"PUT_YOUR_API_KEY_HERE";
static NSString *ACCOUNT_TOKEN = @"PUT_YOUR_ACCOUNT_TOKEN_HERE";



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
    
    [[NSUserDefaults standardUserDefaults] setObject:@"https://staging.api.getcardflight.com/" forKey:@"ROOT_API_URL"];
    
    [[CardFlight sharedInstance] setApiToken:API_KEY
                                accountToken:ACCOUNT_TOKEN];
    [[CardFlight sharedInstance] setAttacheReader:NO];
    [[CardFlight sharedInstance] setLogging:YES];
    
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
    
    _customView = [[CFTCustomView alloc] initWithNameField];
    [_customView.cardNumber customFieldBorderStyle:UITextBorderStyleRoundedRect];
    [_customView.cardNumber customFieldPlaceholder:@"Card Number"];
    [_customView.cardNumber customFieldFont:defaultFont];
    
    _expirationDate = [[UITextField alloc] init];
    [_expirationDate setBorderStyle:UITextBorderStyleRoundedRect];
    [_expirationDate setFont:defaultFont];
    [_expirationDate setPlaceholder:@"Exp Date"];
    
    _cvv = [[UITextField alloc] init];
    [_cvv setBorderStyle:UITextBorderStyleRoundedRect];
    [_cvv setFont:defaultFont];
    [_cvv setPlaceholder:@"CVV"];
    
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
    [_customView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_expirationDate setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_cvv setTranslatesAutoresizingMaskIntoConstraints:NO];
    
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
    [self.view addSubview:_customView];
    [self.view addSubview:_expirationDate];
    [self.view addSubview:_cvv];
    
    NSDictionary *constraints = NSDictionaryOfVariableBindings(headerLabel, versionLabel, swipeButton, serialButton, timeoutButton, _readerStatus, _customView, _expirationDate);
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        id topGuide = self.topLayoutGuide;
        [self addVisualConstraints:@"V:[topGuide]-[headerLabel]"
                    withDictionary:NSDictionaryOfVariableBindings(topGuide, headerLabel)];
    } else {
        [self addVisualConstraints:@"V:|-[headerLabel]"
                    withDictionary:NSDictionaryOfVariableBindings(headerLabel)];
    }
    
    [self addVisualConstraints:@"V:[headerLabel]-12-[versionLabel]-15-[swipeButton]-15-[_customView]-[_expirationDate]"
                withDictionary:constraints];
    [self addVisualConstraints:@"V:[serialButton]-15-[timeoutButton]-20-[_readerStatus]-|"
                withDictionary:constraints];
    [self addVisualConstraints:@"|-[headerLabel]-|" withDictionary:NSDictionaryOfVariableBindings(headerLabel)];
    [self addVisualConstraints:@"|-[versionLabel]-|" withDictionary:NSDictionaryOfVariableBindings(versionLabel)];
    [self addVisualConstraints:@"|-[swipeButton]-|" withDictionary:NSDictionaryOfVariableBindings(swipeButton)];
    [self addVisualConstraints:@"|-[serialButton]-|" withDictionary:NSDictionaryOfVariableBindings(serialButton)];
    [self addVisualConstraints:@"|-30-[_customView]-30-|" withDictionary:NSDictionaryOfVariableBindings(_customView)];
    [self addVisualConstraints:@"|-30-[_expirationDate]-[_cvv]-30-|"
                withDictionary:NSDictionaryOfVariableBindings(_expirationDate, _cvv)];
    [self addVisualConstraints:@"|-[_nameLabel]-|" withDictionary:NSDictionaryOfVariableBindings(_nameLabel)];
    [self addVisualConstraints:@"|-[_numberLabel]-|" withDictionary:NSDictionaryOfVariableBindings(_numberLabel)];
    [self addVisualConstraints:@"|-[_messageLabel]-|" withDictionary:NSDictionaryOfVariableBindings(_messageLabel)];
    [self addVisualConstraints:@"[_timeoutText(45)]-[timeoutButton]"
                withDictionary:NSDictionaryOfVariableBindings(_timeoutText, timeoutButton)];
    [self addVisualConstraints:@"|-[_readerStatus]-|" withDictionary:NSDictionaryOfVariableBindings(_readerStatus)];
    
    [self addEqualConstraint:NSLayoutAttributeCenterY from:_timeoutText to:timeoutButton];
    [self addEqualConstraint:NSLayoutAttributeCenterY from:_cvv to:_expirationDate];
    [self addEqualConstraint:NSLayoutAttributeWidth from:_cvv to:_expirationDate];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:timeoutButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:timeoutButton.superview
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:22]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[serialButton]-30-[_nameLabel]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_nameLabel, serialButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_nameLabel]-10-[_numberLabel]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_nameLabel, _numberLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_numberLabel]-30-[_messageLabel]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_messageLabel, _numberLabel)]];
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
                                   [_messageLabel setText:[NSString stringWithFormat:@"Successfully charged: %@", charge]];
                                }
                                failure:^(NSError *error) {
                                    [self displayError:error];
                                }];
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
