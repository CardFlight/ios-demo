/*
 *****************************************************************
 * CFTCustomView.h
 *
 * Containing view to hold the custom manual entry textfield.
 * The view receives no events directly and should never have an
 * appearance set.
 *
 * Can be placed above other controls and will not receive touch
 * events.
 *
 * Appearance methods for the private textfields are sent through
 * a CFTCustomEntryView instance to protect the underlying data.
 *
 * Auto layout constraints can be applied to this view and will
 * effect the underlying textfield.
 *
 * Copyright (c) 2013 CardFlight Inc. All rights reserved.
 *****************************************************************
 */

#import <UIKit/UIKit.h>
@class CFTCard;
@class CFTCustomEntryTextField;

@protocol customEntryDelegate <NSObject>

@optional

/**
 * Optional protocol method that gets called when the private
 * text field call textFieldDidBeginEditing
 */
- (void)customTextFieldDidBeginEditing:(NSInteger)textFieldTag;

/**
 * Optional protocol method that gets called when the private
 * text field call textFieldDidEndEditing
 */
- (void)customTextFieldDidEndEditing:(NSInteger)textFieldTag;

/**
 * Optional protocol method that gets called when the private
 * text field call textFieldShouldBeginEditing
 */
- (BOOL)customTextFieldShouldBeginEditing:(NSInteger)textFieldTag;

/**
 * Optional protocol method that gets called when the private
 * text field call textFieldShouldClear
 */
- (BOOL)customTextFieldShouldClear:(NSInteger)textFieldTag;

/**
 * Optional protocol method that gets called when the private
 * text fields call textFieldShouldReturn
 */
- (BOOL)customTextFieldShouldReturn:(NSInteger)textFieldTag;

// ******************** DEPRECATED ********************

/**
 * Optional protocol method that gets called when the private
 * text field call textField:shouldChangeCharactersInRange:replacementString:
 * THIS WILL BE REMOVED IN A LATER RELEASE
 * CURRENTLY ONLY RETURNS YES
 */
- (BOOL)customTextField:(NSInteger)textFieldTag shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

@end

@interface CFTCustomView : UIView

@property (nonatomic, weak) id<customEntryDelegate> delegate;
@property (nonatomic) CFTCustomEntryTextField *cardNumber;
@property (nonatomic) CFTCustomEntryTextField *expirationDate;
@property (nonatomic) CFTCustomEntryTextField *cvvNumber;
@property (nonatomic) CFTCustomEntryTextField *cardName;

/**
 * Creates the custom view with the card number field.
 * Using this initializer with create a card number field
 * the same size as the custom field. Any auto layout constraints
 * placed on the view will resize the card number field in 
 * exactly the same way.
 */
- (id)initWithNameField;

/**
 * Takes the data from the custom manual entry textfield
 * and the passed parameters and returns a CFTCard object
 * if valid or nil if the parameters were invalid.
 * CVV and ZipCode are optional and can be nil.
 */
- (CFTCard *)generateCardWithCVV:(NSString *)cvv
                 expirationMonth:(NSInteger)month
                  expirationYear:(NSInteger)year
                      andZipCode:(NSString *)zipcode;

// ******************** DEPRECATED ********************

/**
 * Creates the custom view without a CVV field
 * THIS WILL BE REMOVED IN A LATER RELEASE
 */
- (id)initWithoutCVVField;

/**
 * Creates the custom view with a CVV field
 * THIS WILL BE REMOVED IN A LATER RELEASE
 */
- (id)initWithCVVField;

/**
 * Takes the data from the custom manual entry textfields
 * and returns a CFTCard object.
 * THIS WILL BE REMOVED IN A LATER RELEASE
 */
- (CFTCard *)generateCard;

@end
