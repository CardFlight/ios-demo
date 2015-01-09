//
//  CFTPaymentView.h
//  CardFlightLibrary
//
//  Created by Paul Tower on 3/31/14.
//  Copyright (c) 2014 CardFlight Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CFTCard;

@protocol CFTPaymentViewDelegate <NSObject>

@required

/**
 * Required protocol method that gets called whenever the
 * manual entry receives enough valid input to generate a
 * credit card object.
 */
- (void)keyedCardResponse:(CFTCard *)card;

@end

@interface CFTPaymentView : UIView

@property (nonatomic, weak) id<CFTPaymentViewDelegate> delegate;

/**
 * Constructor with option to prompt for a zip code in manual entry
 */
- (instancetype)initWithFrame:(CGRect)frame enableZip:(BOOL)zipEnabled;

/**
 * Sends the custom manual entry textfields the resignFirstResponder
 * message.
 */
- (void)resignAll;

/**
 * Clears all the input from the textfields and returns it to its
 * initial state.
 */
- (void)clearInput;

/**
 * Assigns a UIKeyboardAppearance to the custom manual entry textfields.
 * UIKeyboardAppearanceDefault is used by default.
 */
- (void)useKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance;

/**
 * Assigns a font to use for the custom manual entry textfields.
 * Uses bold system font size 17 by default.
 * Passing nil reenables the default font.
 */
- (void)useFont:(UIFont *)newFont;

/**
 * Assigns a color to use for the font for the custom manual
 * entry textfields. 
 * Black is used by default.
 * Passing nil reenables the default font color.
 */
- (void)useFontColor:(UIColor *)newColor;

/**
 * Assigns a color to use for the font when the validation fails.
 * A red color (253, 0, 17) is used by default.
 * Passing nil reenables the default alert font color.
 */
- (void)useFontAlertColor:(UIColor *)newColor;

/**
 * Assigns a new color to the textfield border.
 * Black is used by default.
 * Passing nil reenables the default border color.
 */
- (void)useBorderColor:(UIColor *)newColor;

// ******************** DEPRECATED ********************

/**
 * Takes the data from the custom manual entry textfields
 * and returns a CFTCard object.
 * THIS WILL BE REMOVED IN A LATER RELEASE
 */
- (CFTCard *)generateCard __attribute__((deprecated));

@end
