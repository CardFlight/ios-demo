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

/*
 * Required protocol method that gets called whenever the
 * manual entry receives enough valid input to generate a
 * credit card object.
 */
- (void)keyedCardResponse:(CFTCard *)card;

@end

@interface CFTPaymentView : UIView

@property (nonatomic, weak) id<CFTPaymentViewDelegate> delegate;

/*
 * Constructor with option to prompt for a zip code in manual entry
 *
 * Updated in 1.8.3
 */
- (instancetype)initWithFrame:(CGRect)frame enableZip:(BOOL)zipEnabled;

/*
 * Sends the custom manual entry textfields the resignFirstResponder
 * message.
 *
 * Added in 1.5.1
 */
- (void)resignAll;

/*
 * Clears all the input from the textfields and returns it to its
 * initial state.
 *
 * Added in 1.5.1
 */
- (void)clearInput;

/*
 * Assigns a UIKeyboardAppearance to the custom manual entry textfields.
 * UIKeyboardAppearanceDefault is used by default.
 *
 * Added in 1.5.1
 */
- (void)useKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance;

/*
 * Assigns a font to use for the custom manual entry textfields.
 * Uses bold system font size 17 by default.
 * Passing nil reenables the default font.
 *
 * Added in 1.5.1
 */
- (void)useFont:(UIFont *)newFont;

/*
 * Assigns a color to use for the font for the custom manual
 * entry textfields. 
 * Black is used by default.
 * Passing nil reenables the default font color.
 *
 * Added in 1.5.1
 */
- (void)useFontColor:(UIColor *)newColor;

/*
 * Assigns a color to use for the font when the validation fails.
 * A red color (253, 0, 17) is used by default.
 * Passing nil reenables the default alert font color.
 *
 * Added in 1.5.1
 */
- (void)useFontAlertColor:(UIColor *)newColor;

/*
 * Assigns a new color to the textfield border.
 * Black is used by default.
 * Passing nil reenables the default border color.
 *
 * Added in 1.5.1
 */
- (void)useBorderColor:(UIColor *)newColor;

@end
