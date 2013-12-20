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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
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
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, [UIScreen mainScreen].bounds.size.width, 20)];
    [headerLabel setTextAlignment:NSTextAlignmentCenter];
    if ([UIFont respondsToSelector:@selector(preferredFontForTextStyle:)]) {
        [headerLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    }
    [headerLabel setText:@"SDK Sandbox"];
    [self.view addSubview:headerLabel];
    
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, headerLabel.frame.origin.y + 25, [UIScreen mainScreen].bounds.size.width, 20)];
    [versionLabel setTextAlignment:NSTextAlignmentCenter];
    [versionLabel setText:[NSString stringWithFormat:@"SDK %@     iOS %@",
                           [[CardFlight sharedInstance] SDKVersion],
                           [[UIDevice currentDevice] systemVersion]]];
    [self.view addSubview:versionLabel];
    
    UIButton *swipeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [swipeButton setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width / 2) - 70, versionLabel.frame.origin.y + 50, 140, 44)];
    [swipeButton setTitle:@"Attempt Swipe" forState:UIControlStateNormal];
    [swipeButton addTarget:self
                    action:@selector(swipeCard:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:swipeButton];
    
    UIButton *serialButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [serialButton setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width / 2) - 70, swipeButton.frame.origin.y + 65, 140, 44)];
    [serialButton setTitle:@"Serial Number" forState:UIControlStateNormal];
    [serialButton addTarget:self
                    action:@selector(displaySerialNumber:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:serialButton];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, serialButton.frame.origin.y + 65, [UIScreen mainScreen].bounds.size.width, 20)];
    [_nameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_nameLabel];
    
    _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _nameLabel.frame.origin.y + 25, [UIScreen mainScreen].bounds.size.width, 20)];
    [_numberLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_numberLabel];
    
    _errorMessage = [[UILabel alloc] initWithFrame:CGRectMake(10, _numberLabel.frame.origin.y + 50, [UIScreen mainScreen].bounds.size.width - 20, 80)];
    [_errorMessage setTextAlignment:NSTextAlignmentCenter];
    [_errorMessage setNumberOfLines:0];
    [_errorMessage setLineBreakMode:NSLineBreakByWordWrapping];
    [self.view addSubview:_errorMessage];
    
    _timeoutText = [[UITextField alloc] initWithFrame:CGRectMake(90, [UIScreen mainScreen].bounds.size.height - 100, 50, 40)];
    [_timeoutText setDelegate:self];
    [_timeoutText setKeyboardAppearance:UIKeyboardAppearanceDark];
    [_timeoutText setReturnKeyType:UIReturnKeyDone];
    [_timeoutText setBorderStyle:UITextBorderStyleRoundedRect];
    [_timeoutText setLeftView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 0)]];
    [_timeoutText setLeftViewMode:UITextFieldViewModeAlways];
    [_timeoutText setText:@"20"];
    [self.view addSubview:_timeoutText];
    
    UIButton *timeoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [timeoutButton setFrame:CGRectMake(140, _timeoutText.frame.origin.y, 100, 44)];
    [timeoutButton setTitle:@"Set Duration" forState:UIControlStateNormal];
    [timeoutButton addTarget:self
                      action:@selector(setDuration:)
            forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:timeoutButton];
    
    _readerStatus = [[UILabel alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 40, [UIScreen mainScreen].bounds.size.width, 20)];
    [_readerStatus setTextAlignment:NSTextAlignmentCenter];
    [_readerStatus setTextColor:[UIColor redColor]];
    [_readerStatus setText:@"NOT CONNECTED"];
    [self.view addSubview:_readerStatus];
}

- (void)swipeCard:(id)sender {
    
    [_nameLabel setText:@""];
    [_numberLabel setText:@""];
    [_cardReader beginSwipeWithMessage:@"Swipe yo face!"];
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
//        NSDictionary *paymentInfo = @{@"amount":[NSDecimalNumber decimalNumberWithString:@"1.00"],
//                                      @"currency": @"USD",
//                                      @"description": @"PHHHOTO delivered to "};
//        [card chargeCardWithParameters:paymentInfo
//                               success:^(CFTCharge *charge) {
//                                   NSLog(@"Successfully charged: %@", charge);
//                                }
//                                failure:^(NSError *error) {
//                                    // NSLog(@"Error charging card: %@", [error localizedDescription]);
//                                    [self displayError:error];
//                                }];
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
