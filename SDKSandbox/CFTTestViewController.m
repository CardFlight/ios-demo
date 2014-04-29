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
#import "CFTCharge.h"
#import "CardFlight.h"
#import "CFTPaymentView.h"
#import "SVProgressHUD.h"

@interface CFTTestViewController () <CFTReaderDelegate, CFTPaymentViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate> {
    
    CGFloat animatedDistance;
}

@property (nonatomic) CFTReader *cardReader;
@property (nonatomic) CFTCard *card;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *numberLabel;
@property (nonatomic) UILabel *readerStatus;
@property (nonatomic) UILabel *messageLabel;
@property (nonatomic) UITextField *timeoutText;
@property (nonatomic) UIButton *swipeButton;
@property (nonatomic) UIButton *tokenizeButton;
@property (nonatomic) UIButton *chargeButton;
@property (nonatomic) CFTPaymentView *paymentView;

@end




/*
 * Copy and paste your api key and account token below to make
 * test charges with CardFlight. The information can be found
 * in your developer dashboard at getcardflight.com
*/

static NSString *API_KEY = @"PUT_YOUR_API_KEY_HERE";
static NSString *ACCOUNT_TOKEN = @"PUT_YOUR_ACCOUNT_TOKEN_HERE";



static NSString *kDefaultFont = @"Avenir";

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
    
    _swipeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_swipeButton setTitle:@"Attempt Swipe" forState:UIControlStateNormal];
    [_swipeButton.titleLabel setFont:defaultFont];
    [_swipeButton addTarget:self
                     action:@selector(swipeCard:)
           forControlEvents:UIControlEventTouchUpInside];
    [_swipeButton setEnabled:NO];
    
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
    [_chargeButton setEnabled:NO];
    
    _tokenizeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_tokenizeButton setTitle:@"Test Tokenize" forState:UIControlStateNormal];
    [_tokenizeButton addTarget:self
                        action:@selector(tokenizeButtonPressed:)
              forControlEvents:UIControlEventTouchUpInside];
    [_tokenizeButton setEnabled:NO];
    
    _readerStatus = [[UILabel alloc] init];
    [_readerStatus setTextAlignment:NSTextAlignmentCenter];
    [_readerStatus setTextColor:[UIColor redColor]];
    [_readerStatus setText:@"NOT CONNECTED"];
    [_readerStatus setFont:defaultFont];
    
    _paymentView = [[CFTPaymentView alloc] initWithFrame:CGRectZero];
    [_paymentView setDelegate:self];
    [_paymentView useFont:[UIFont fontWithName:kDefaultFont size:17]];
    [_paymentView useKeyboardAppearance:UIKeyboardAppearanceDark];
    
    [headerLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [versionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_swipeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [serialButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_nameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_numberLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_messageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_timeoutText setTranslatesAutoresizingMaskIntoConstraints:NO];
    [timeoutButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_readerStatus setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_chargeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_tokenizeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_paymentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.view addSubview:headerLabel];
    [self.view addSubview:versionLabel];
    [self.view addSubview:_swipeButton];
    [self.view addSubview:serialButton];
    [self.view addSubview:_nameLabel];
    [self.view addSubview:_numberLabel];
    [self.view addSubview:_messageLabel];
    [self.view addSubview:_timeoutText];
    [self.view addSubview:timeoutButton];
    [self.view addSubview:_readerStatus];
    [self.view addSubview:_chargeButton];
    [self.view addSubview:_tokenizeButton];
    [self.view addSubview:_paymentView];
    
    NSDictionary *constraints = NSDictionaryOfVariableBindings(headerLabel, versionLabel, _swipeButton, _paymentView, serialButton, timeoutButton, _readerStatus, _chargeButton, _tokenizeButton, _messageLabel, _nameLabel, _numberLabel);
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        id topGuide = self.topLayoutGuide;
        [self addVisualConstraints:@"V:[topGuide]-[headerLabel]"
                    withDictionary:NSDictionaryOfVariableBindings(topGuide, headerLabel)];
    } else {
        [self addVisualConstraints:@"V:|-[headerLabel]"
                    withDictionary:NSDictionaryOfVariableBindings(headerLabel)];
    }
    
    [self addVisualConstraints:@"V:[headerLabel]-12-[versionLabel]-15-[_swipeButton]-15-[_paymentView(45)]-15-[_nameLabel]-[_numberLabel]-[_messageLabel]"
                withDictionary:constraints];
    [self addVisualConstraints:@"V:[_tokenizeButton]-[_chargeButton]-[serialButton]-[timeoutButton]-15-[_readerStatus]-|"
                withDictionary:constraints];
    [self addVisualConstraints:@"|-[headerLabel]-|" withDictionary:NSDictionaryOfVariableBindings(headerLabel)];
    [self addVisualConstraints:@"|-[versionLabel]-|" withDictionary:NSDictionaryOfVariableBindings(versionLabel)];
    [self addVisualConstraints:@"|-[_swipeButton]-|" withDictionary:NSDictionaryOfVariableBindings(_swipeButton)];
    [self addVisualConstraints:@"[_paymentView(290)]" withDictionary:NSDictionaryOfVariableBindings(_paymentView)];
    [self addVisualConstraints:@"|-[serialButton]-|" withDictionary:NSDictionaryOfVariableBindings(serialButton)];
    [self addVisualConstraints:@"|-[_nameLabel]-|" withDictionary:NSDictionaryOfVariableBindings(_nameLabel)];
    [self addVisualConstraints:@"|-[_numberLabel]-|" withDictionary:NSDictionaryOfVariableBindings(_numberLabel)];
    [self addVisualConstraints:@"|-[_messageLabel]-|" withDictionary:NSDictionaryOfVariableBindings(_messageLabel)];
    [self addVisualConstraints:@"|-[_chargeButton]-|" withDictionary:NSDictionaryOfVariableBindings(_chargeButton)];
    [self addVisualConstraints:@"|-[_tokenizeButton]-|" withDictionary:NSDictionaryOfVariableBindings(_tokenizeButton)];
    [self addVisualConstraints:@"[_timeoutText(45)]-[timeoutButton]"
                withDictionary:NSDictionaryOfVariableBindings(_timeoutText, timeoutButton)];
    [self addVisualConstraints:@"|-[_readerStatus]-|" withDictionary:NSDictionaryOfVariableBindings(_readerStatus)];
    
    [self addEqualConstraint:NSLayoutAttributeCenterX from:_paymentView to:_paymentView.superview];
    [self addEqualConstraint:NSLayoutAttributeCenterY from:_timeoutText to:timeoutButton];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:timeoutButton
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:timeoutButton.superview
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:22]];
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
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CardFlight Demo"
                                                    message:@"Enter charge amount"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Test Charge", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alert textFieldAtIndex:0] setDelegate:self];
    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    [[alert textFieldAtIndex:0] setKeyboardAppearance:UIKeyboardAppearanceDark];
    [[alert textFieldAtIndex:0] setTextAlignment:NSTextAlignmentRight];
    [alert show];
//    [self chargeCard];
}

- (void)tokenizeButtonPressed:(id)sender {
    
    [SVProgressHUD showWithStatus:@"Tokenizing" maskType:SVProgressHUDMaskTypeClear];
    if (_card) {
        [_card tokenizeCardWithSuccess:^{
            [SVProgressHUD showSuccessWithStatus:@"Success"];
            [_messageLabel setText:[NSString stringWithFormat:@"Successfully tokenized: %@", _card.cardToken]];
        }
                               failure:^(NSError *error){
                                   [SVProgressHUD showErrorWithStatus:@"Failed"];
                                   [self displayError:error];
                               }];
    } else {
        [_messageLabel setText:@"Error - No card to tokenize"];
    }
}

- (void)dismissKeyboard {
    
    [_paymentView resignAll];
    [_timeoutText resignFirstResponder];
}

- (void)swipeCard:(id)sender {
    
    [_nameLabel setText:@""];
    [_numberLabel setText:@""];
    [_cardReader beginSwipeWithMessage:nil];
    [_readerStatus setText:@"SWIPE NOW"];
    [_swipeButton setEnabled:NO];
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

- (void)chargeCardWithAmount:(NSDecimalNumber *)amount {
    
    if (_card) {
        [SVProgressHUD showWithStatus:@"Charging" maskType:SVProgressHUDMaskTypeClear];
        NSDictionary *paymentInfo = @{@"amount":amount,
                                      @"currency": @"USD",
                                      @"description": @"Description"};
        [_card chargeCardWithParameters:paymentInfo
                                success:^(CFTCharge *charge) {
                                    [SVProgressHUD showSuccessWithStatus:@"Success"];
                                    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                                    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                                    [_messageLabel setText:[NSString stringWithFormat:@"Successfully charged: %@", [formatter stringFromNumber:charge.amount]]];
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
    [_chargeButton setEnabled:YES];
    [_tokenizeButton setEnabled:YES];
}

#pragma mark - Reader Delegate

- (void)readerCardResponse:(CFTCard *)card withError:(NSError *)error {
    
    [_swipeButton setEnabled:YES];
    [_readerStatus setText:@"CONNECTED"];
    if (!error) {
        [_nameLabel setText:card.name];
        [_numberLabel setText:card.encryptedCardNumber];
        _card = card;
        [_chargeButton setEnabled:YES];
        [_tokenizeButton setEnabled:YES];
    }
    else {
        [self displayError:error];
    }
}

- (void)readerIsConnected:(BOOL)isConnected withError:(NSError *)error {
    
    if (isConnected) {
        [_readerStatus setText:@"CONNECTED"];
        [self swipeCard:nil];
    }
    else {
        [_readerStatus setText:@"NOT CONNECTED"];
        [_readerStatus setTextColor:[UIColor redColor]];
        [self displayError:error];
    }
}

- (void)readerIsAttached {
    
    [_messageLabel setText:@""];
    [_readerStatus setText:@"CONNECTING"];
    [_readerStatus setTextColor:[UIColor blueColor]];
}

- (void)readerIsDisconnected {
    
    [_readerStatus setText:@"NOT CONNECTED"];
    [_readerStatus setTextColor:[UIColor redColor]];
    [_swipeButton setEnabled:NO];
}

- (void)readerSerialNumber:(NSString *)serialNumber {
    
    [_messageLabel setText:[NSString stringWithFormat:@"Serial Number: %@", serialNumber]];
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        NSString *cleanCentString = [[[alertView textFieldAtIndex:0].text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
        NSDecimalNumber *amount = [[NSDecimalNumber decimalNumberWithString:cleanCentString] decimalNumberByMultiplyingByPowerOf10:-2];
        [self chargeCardWithAmount:amount];
    }
}

#pragma mark - Text Field Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *cleanCentString = [[textField.text componentsSeparatedByCharactersInSet: [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    NSInteger centValue= cleanCentString.integerValue;
    
    if (string.length > 0) {
        centValue = centValue * 10 + string.integerValue;
    }
    else {
        centValue = centValue / 10;
    }
    
    NSNumber *formatedValue;
    formatedValue = [[NSNumber alloc] initWithFloat:(float)centValue / 100.0f];
    NSNumberFormatter *_currencyFormatter = [[NSNumberFormatter alloc] init];
    [_currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    textField.text = [_currencyFormatter stringFromNumber:formatedValue];
    return NO;
}

@end
