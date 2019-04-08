//
//  SearchBar.h
//  QunarIphone
//
//  Created by Neo on 7/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QIMCommonUIFramework.h"

@class SearchBar;

// 代理协议
@protocol SearchBarDelgt <NSObject>

@optional

- (void)searchBar:(SearchBar *)searchBar textDidChange:(NSString *)searchText;
- (BOOL)searchBar:(SearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (BOOL)searchBarShouldBeginEditing:(SearchBar *)searchBar;
- (void)searchBarTextDidBeginEditing:(SearchBar *)searchBar;
- (BOOL)searchBarShouldEndEditing:(SearchBar *)searchBar;
- (void)searchBarTextDidEndEditing:(SearchBar *)searchBar;
- (void)searchBarSearchButtonClicked:(SearchBar *)searchBar;
- (void)searchBarBackButtonClicked:(SearchBar *)searchBar;
- (void)searchBarBarButtonClicked:(SearchBar *)searchBar;

@end

// 搜索框
@interface SearchBar : UIView <UITextFieldDelegate>

@property (nonatomic, weak) id<SearchBarDelgt> delegate;	// 代理

// 初始化
- (SearchBar *)initWithCoder:(NSCoder *)aDecoder;   // 添加对xib的支持@aruisi.chen
- (SearchBar *)initWithFrame:(CGRect)frameInit andButton:(NSString *)title;

// 设置frame
- (void)setFrame:(CGRect)frameNew;

// 设置和获取placeHolder
- (NSString *)placeHolder;
- (void)setPlaceHolder:(NSString *)placeHolder;

// 获取和设置Text
- (NSString *)text;
- (void)setText:(NSString *)textNew;

// 获取和设置Hint
- (NSString *)hint;
- (void)setHint:(NSString *)hintNew;

// 获取和设置自动大写字母
- (UITextAutocapitalizationType)autocapitalizationType;
- (void)setAutocapitalizationType:(UITextAutocapitalizationType)typeNew;

// 获取和设置纠正
- (UITextAutocorrectionType)autocorrectionType;
- (void)setAutocorrectionType:(UITextAutocorrectionType)typeNew;

// 键盘类型
- (UIKeyboardType)keyboardType;
- (void)setKeyboardType:(UIKeyboardType)typeNew;

// 设置返回键
- (UIReturnKeyType)returnKeyType;
- (void)setReturnKeyType:(UIReturnKeyType)typeNew;

// 控制BarButton
- (void)setBarButtonImage:(UIImage *)image forState:(UIControlState)stateNew;
- (void)setBarButtonTitle:(NSString *)title;

// 显示和隐藏
- (void)showBackButton:(BOOL)isShow animated:(BOOL)animated;
- (void)showBarButton:(BOOL)isShow animated:(BOOL)animated;
- (void)showHintLabel:(BOOL)isShow;
- (void)showIndicatorView:(BOOL)isShow;

// 焦点
- (BOOL)canBecomeFirstResponder;
- (BOOL)becomeFirstResponder;
- (BOOL)resignFirstResponder;


@end
