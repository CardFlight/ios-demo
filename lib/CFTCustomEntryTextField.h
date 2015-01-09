/*
 *****************************************************************
 * CFTCustomEntryTextField.h
 *
 * Public facing interfaces to the private custom manual entry
 * textfields.
 *
 * Appearance method calls are sent to a CFTCustomEntryTextField
 * contained in a CFTCustomView to set the look and feel of the
 * private textfields that are actually displayed on screen.
 *
 * Currently the frame can only be set directly, auto layout is
 * not supported. Additionally, the frame and appearance must be
 * set in code, interface builder is not supported.
 *
 * Copyright (c) 2013 CardFlight Inc. All rights reserved.
 *****************************************************************
 */

#import <UIKit/UIKit.h>

__attribute__((deprecated))
@interface CFTCustomEntryTextField : UIView

/**
 * The following public methods allow customization of the manual
 * entry textfields while preventing direct access to the contents.
 * You can set values but cannot read them.
 * Currently, auto layout is not supported.
 */

- (void)customFieldFrame:(CGRect)newFrame;
- (void)customFieldText:(NSString *)newText;
- (void)customFieldTag:(NSInteger)newTag;
- (void)customFieldBackground:(UIImage *)newBackground;
- (void)customFieldLeftView:(UIView *)newView;
- (void)customFieldLeftViewMode:(UITextFieldViewMode)newViewMode;
- (void)customFieldRightView:(UIView *)newView;
- (void)customFieldRightViewMode:(UITextFieldViewMode)newViewMode;
- (void)customFieldFont:(UIFont *)newFont;
- (void)customFieldTextColor:(UIColor *)newColor;
- (void)customFieldPlaceholder:(NSString *)newPlaceholder;
- (void)customFieldAttributedPlaceholder:(NSAttributedString *)newAttributedPlaceholder;
- (void)customFieldTextAlignment:(NSTextAlignment)newAlignment;
- (void)customFieldBorderStyle:(UITextBorderStyle)newBorder;
- (void)customFieldKeyboardType:(UIKeyboardType)newKeyboard;
- (void)customFieldKeyboardAppearance:(UIKeyboardAppearance)newKeyboardAppearance;
- (void)customFieldReturnKeyType:(UIReturnKeyType)newReturnKeyType;
- (void)customFieldBecomeFirstResponder;
- (void)customFieldResignFirstResponder;

@end
