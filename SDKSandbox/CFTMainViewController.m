//
//  CFTMainViewController.m
//  SDKSandbox
//
//  Created by Paul Tower on 2/23/15.
//  Copyright (c) 2015 CardFlight. All rights reserved.
//

#import "CFTMainViewController.h"
#import "CardFlight.h"

@interface CFTMainViewController () <CFTPaymentViewDelegate, CFTReaderDelegate, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel *sdkVersion;
@property (nonatomic, weak) IBOutlet UILabel *iosVersion;

@property (nonatomic, weak) IBOutlet UIView *manualView;
@property (nonatomic, weak) IBOutlet UILabel *manualLabel;
@property (nonatomic, weak) IBOutlet UIButton *manualTokenize;
@property (nonatomic, weak) IBOutlet UIButton *manualCharge;
@property (nonatomic) CFTPaymentView *paymentView;

@property (nonatomic, weak) IBOutlet UILabel *swipeStatus;
@property (nonatomic, weak) IBOutlet UIButton *startTransaction;
@property (nonatomic, weak) IBOutlet UIButton *swipeTokenize;
@property (nonatomic, weak) IBOutlet UIButton *swipeCharge;

@property (nonatomic, weak) IBOutlet UILabel *readerStatus;
@property (nonatomic, weak) IBOutlet UILabel *readerError;
@property (nonatomic, weak) IBOutlet UIButton *readerType;

@property (nonatomic) CFTCard *manualCard;
@property (nonatomic) CFTCard *swipedCard;
@property (nonatomic) CFTReader *reader;

@end

/*
 * Copy and paste your api key and account token below to make
 * test charges with CardFlight. The information can be found
 * in your developer dashboard at getcardflight.com
 */

static NSString *API_KEY = @"PUT_YOUR_API_KEY_HERE";
static NSString *ACCOUNT_TOKEN = @"PUT_YOUR_ACCOUNT_TOKEN_HERE";

@implementation CFTMainViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"https://staging.api.getcardflight.com/" forKey:@"ROOT_API_URL"];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(dismissKeyboard)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
    self.sdkVersion.text = [NSString stringWithFormat:@"SDK Version %@", [[CFTSessionManager sharedInstance] SDKVersion]];
    self.iosVersion.text = [NSString stringWithFormat:@"iOS Version %@", [[UIDevice currentDevice] systemVersion]];
    
    [self enableManualButtons:NO];
    [self enableSwipeButtons:NO];
    self.startTransaction.enabled = NO;
    self.readerType.enabled = NO;
    self.readerError.text = @"";
    self.swipeStatus.text = @"No Card Swiped";
    
    [[CFTSessionManager sharedInstance] setLogging:YES];
    [[CFTSessionManager sharedInstance] setApiToken:API_KEY
                                       accountToken:ACCOUNT_TOKEN
                                          completed:^(BOOL emvReady){}];
    
    self.reader = [[CFTReader alloc] initWithReader:0];
    self.reader.delegate = self;
    
    self.paymentView = [[CFTPaymentView alloc] initWithFrame:CGRectZero enableZip:YES];
    self.paymentView.delegate = self;
    [self.paymentView useKeyboardAppearance:UIKeyboardAppearanceDark];
    self.paymentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.manualView addSubview:self.paymentView];
    
    [self.manualView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_manualLabel]-20-[_paymentView(45)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_paymentView, _manualLabel)]];
    [self.manualView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_paymentView(290)]"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:NSDictionaryOfVariableBindings(_paymentView)]];
    [self.manualView addConstraint:[NSLayoutConstraint constraintWithItem:self.paymentView
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.paymentView.superview
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0
                                                                 constant:0]];
    
    [self.startTransaction addTarget:self
                          action:@selector(startTransactionPressed:)
                forControlEvents:UIControlEventTouchUpInside];
    [self.readerType addTarget:self
                        action:@selector(readerTypePressed:)
              forControlEvents:UIControlEventTouchUpInside];
    [self.swipeTokenize addTarget:self
                           action:@selector(tokenizePressed:)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.swipeCharge addTarget:self
                         action:@selector(swipeChargePressed:)
               forControlEvents:UIControlEventTouchUpInside];
    [self.manualTokenize addTarget:self
                            action:@selector(manualTokenizePressed:)
                  forControlEvents:UIControlEventTouchUpInside];
    [self.manualCharge addTarget:self
                          action:@selector(manualChargePressed:)
                forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void)dismissKeyboard {
    
    [self.paymentView resignAll];
}

- (void)promptForChargeAmount {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"CardFlight Demo"
                                                                   message:@"Enter test amount"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.delegate = self;
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Okay"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action){
                                                   UITextField *amount = alert.textFields.firstObject;
                                                   NSString *cleanCentString = [[amount.text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
                                                   NSDecimalNumber *decimal = [[NSDecimalNumber decimalNumberWithString:cleanCentString] decimalNumberByMultiplyingByPowerOf10:-2];
                                                   [self chargeCard:self.swipedCard withAmount:decimal];
                                               }];
    [alert addAction:cancel];
    [alert addAction:ok];
    [self presentViewController:alert
                       animated:YES
                     completion:nil];
}

- (void)promptForChargeAmountForCard:(CFTCard *)card {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"CardFlight Demo"
                                                                   message:@"Enter test amount"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.delegate = self;
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Okay"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action){
                                                   UITextField *amount = alert.textFields.firstObject;
                                                   NSString *cleanCentString = [[amount.text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
                                                   NSDecimalNumber *decimal = [[NSDecimalNumber decimalNumberWithString:cleanCentString] decimalNumberByMultiplyingByPowerOf10:-2];
                                                   [self chargeCard:card withAmount:decimal];
                                               }];
    [alert addAction:cancel];
    [alert addAction:ok];
    [self presentViewController:alert
                       animated:YES
                     completion:nil];
}

- (void)chargeCard:(CFTCard *)card
        withAmount:(NSDecimalNumber *)amount {
    
    if (card) {
        NSDictionary *paymentInfo = @{@"amount":amount,
                                      @"currency": @"USD",
                                      @"description": [NSNull null]};
//        NSLog(@"%@", paymentInfo);
        [card chargeCardWithParameters:paymentInfo
                                success:^(CFTCharge *charge) {
                                    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                                    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"CardFlight Demo"
                                                                                                   message:[NSString stringWithFormat:@"Successfully charged: %@", [formatter stringFromNumber:charge.amount]]
                                                                                            preferredStyle:UIAlertControllerStyleAlert];
                                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Okay"
                                                                                 style:UIAlertActionStyleDefault
                                                                               handler:nil];
                                    [alert addAction:ok];
                                    [self presentViewController:alert
                                                       animated:YES
                                                     completion:nil];
                                }
                                failure:^(NSError *error) {
                                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"CardFlight Demo"
                                                                                                   message:[NSString stringWithFormat:@"Error: %@", error.localizedDescription]
                                                                                            preferredStyle:UIAlertControllerStyleAlert];
                                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Okay"
                                                                                 style:UIAlertActionStyleDefault
                                                                               handler:nil];
                                    [alert addAction:ok];
                                    [self presentViewController:alert
                                                       animated:YES
                                                     completion:nil];
                                }];
    } else {
        [self.readerStatus setText:@"Error - No card to charge"];
    }
}

- (void)tokenizeCard:(CFTCard *)card {
    
    if (card) {
        [card tokenizeCardWithSuccess:^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"CardFlight Demo"
                                                                           message:@"Successfully Tokenized Card"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Okay"
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil];
            [alert addAction:ok];
            [self presentViewController:alert
                               animated:YES
                             completion:nil];
        }
                                         failure:^(NSError *error){
                                             UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"CardFlight Demo"
                                                                                                            message:[NSString stringWithFormat:@"Error: %@", error.localizedDescription]
                                                                                                     preferredStyle:UIAlertControllerStyleAlert];
                                             UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Okay"
                                                                                          style:UIAlertActionStyleDefault
                                                                                        handler:nil];
                                             [alert addAction:ok];
                                             [self presentViewController:alert
                                                                animated:YES
                                                              completion:nil];
                                         }];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"CardFlight Demo"
                                                                       message:@"Error: No Card to Tokenize"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Okay"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert
                           animated:YES
                         completion:nil];
    }
}

#pragma mark - Button Methods

- (void)startTransactionPressed:(UIButton *)sender {
    
    [self.reader beginSwipe];
    self.swipeStatus.text = @"Swipe Now";
}

- (void)readerTypePressed:(UIButton *)sender {
    
    self.readerStatus.text = [NSString stringWithFormat:@"Reader Type: %tu", [self.reader readerType]];
}

- (void)tokenizePressed:(UIButton *)sender {
    
    [self tokenizeCard:self.swipedCard];
}

- (void)swipeChargePressed:(UIButton *)sender {
    
    [self promptForChargeAmount];
}

- (void)manualTokenizePressed:(UIButton *)sender {
    
    [self.paymentView resignAll];
    [self tokenizeCard:self.manualCard];
}

- (void)manualChargePressed:(UIButton *)sender {
    
    [self.paymentView resignAll];
    [self promptForChargeAmountForCard:self.manualCard];
}

#pragma mark - Reader Delegate

- (void)transactionResult:(CFTCharge *)charge withError:(NSError *)error {
    
}

- (void)readerNotDetected {
    
    self.readerStatus.text = @"Reader Not Detected";
}

- (void)readerCardResponse:(CFTCard *)card withError:(NSError *)error {
    
    if (card) {
        self.swipedCard = card;
        [self enableSwipeButtons:YES];
        self.swipeStatus.text = [NSString stringWithFormat:@"%@******%@", self.swipedCard.first6, self.swipedCard.last4];
    } else {
        [self enableSwipeButtons:NO];
        self.swipeStatus.text = error.localizedDescription;
    }
}

- (void)readerIsAttached {
    
    self.readerStatus.text = @"Reader Attached, Connecting";
}

- (void)readerSwipeDetected {
    
    self.swipeStatus.text = @"Swip Detected, Processing";
}

- (void)readerIsDisconnected {
    
    self.readerStatus.text = @"Reader Not Connected";
    self.startTransaction.enabled = NO;
}

- (void)readerIsConnecting {
    
    self.readerStatus.text = @"Reader Is Connecting";
}

- (void)readerIsConnected:(BOOL)isConnected withError:(NSError *)error {
    
    if (isConnected) {
        self.readerStatus.text = @"Reader Connected";
        self.startTransaction.enabled = YES;
        self.readerType.enabled = YES;
        self.readerError.text = @"";
        [self.reader swipeHasTimeout:NO];
    } else {
        self.readerStatus.text = @"Reader Error";
        self.readerError.text = error.localizedDescription;
    }
}

- (void)emvErrorResponse:(NSError *)error {
    
    NSLog(@"%@", error.localizedDescription);
}

#pragma mark - Payment View Delegate

- (void)keyedCardResponse:(CFTCard *)card {
    
    if (card) {
        self.manualCard = card;
        [self enableManualButtons:YES];
    }
}

- (void)enableManualButtons:(BOOL)enabled {
    
    self.manualTokenize.enabled = enabled;
    self.manualCharge.enabled = enabled;
}

- (void)enableSwipeButtons:(BOOL)enabled {
    
    self.swipeTokenize.enabled = enabled;
    self.swipeCharge.enabled = enabled;
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
