//
//  CFTPaymentView.h
//  CardFlightLibrary
//
//  Created by Paul Tower on 3/31/14.
//  Copyright (c) 2014 CardFlight Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CFTCard;

@interface CFTPaymentView : UIView

/**
 * Takes the data from the custom manual entry textfields
 * and returns a CFTCard object.
 */
- (CFTCard *)generateCard;

/**
 * Sends the custom manual entry textfields the resignFirstResponder
 * message.
 */
- (void)resignAll;

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
 * A red color (253,0,17) is used by default.
 * Passing nil reenables the default alert font color.
 */
- (void)useFontAlertColor:(UIColor *)newColor;

/**
 * Assigns a new color to the textfield border.
 * Black is used by default.
 * Passing nil reenables the default border color.
 */
- (void)useBorderColor:(UIColor *)newColor;

@end
