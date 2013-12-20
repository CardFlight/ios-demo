/*
 *****************************************************************
 * CFTCustomView.h
 *
 * Containing view to hold the custom manual entry textfields.
 * The view receives no events directly and should never have an
 * appearance set.
 *
 * Can be placed above other controls and will not receive touch
 * events.
 *
 * All custom manual entry textfields must be contained with the
 * same instance of the CFTCustomEntryView.
 *
 * Appearance methods for the private textfields are sent through
 * a CFTCustomEntryView instance to protect the underlying data.
 *
 * Copyright (c) 2013 CardFlight Inc. All rights reserved.
 *****************************************************************
 */

#import <UIKit/UIKit.h>
@class CFTCard;
@class CFTCustomEntryTextField;

@interface CFTCustomView : UIView

@property (nonatomic) CFTCustomEntryTextField *cardNumber;
@property (nonatomic) CFTCustomEntryTextField *expirationDate;
@property (nonatomic) CFTCustomEntryTextField *cvvNumber;

/**
 * Creates the custom view without a CVV field
 */
- (id)initWithoutCVVField;

/**
 * Creates the custom view with a CVV field
 */
- (id)initWithCVVField;

/**
 * Takes the data from the custom manual entry textfields
 * and returns a CFTCard object.
 */
- (CFTCard *)generateCard;

@end
