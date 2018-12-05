//
//  SearchBar.m
//  QunarIphone
//
//  Created by Neo on 7/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "QIMCommonUIFramework.h"
#import "SearchBar.h"

#define kCurNormalFontOfSize(fontSize)				[UIFont systemFontOfSize:fontSize]
#define kCurBoldFontOfSize(fontSize)				[UIFont boldSystemFontOfSize:fontSize]
#define kCurItalicFontOfSize(fontSize)				[UIFont italicSystemFontOfSize:fontSize]

#define kUIColorOfHex(color)						[UIColor qim_colorWithHex:(color) alpha:1.0]

#define	kNaviBackBarButtonNormalImageFile		@"NaviItemBackNormal.png"
#define	kNaviBackBarButtonHighlightedImageFile	@"NaviItemBackPress.png"
#define	kNaviBackBarButtonDisableImageFile		@"NaviItemBackNormal.png"
#define	kNaviCloseBarButtonNormalImageFile		@"NaviItemCloseNormal.png"
#define	kNaviCloseBarButtonHighlightedImageFile	@"NaviItemClosePress.png"
#define kNavigationBarTitleArrowImageFile       @"NaviBarTitleArrow.png"
// 控件字体
#define	kSearchBarTextFieldFont					kCurNormalFontOfSize(14)
#define	kSearchBarButtonFont					kCurBoldFontOfSize(16)
#define kSearchBarLabelFont						kCurNormalFontOfSize(14)

// 颜色
#define	kSearchBarBackGroundColor				kUIColorOfHex(0x1ba9ba)
#define kSearchBarButtonTextColor             [UIColor qim_colorWithHex:0x77FFFF alpha:1.0f]
#define kSearchBarButtonTextPressColor        [UIColor qim_colorWithHex:0x77FFFF alpha:0.5f]
// ==================================================================
// 布局参数
// ==================================================================
// 控件尺寸
#define kSearchBarDefaultHeight					44
#define	kSearchBarBackButtonHeight				44
#define kSearchBarBackButtonWidth				50
#define	kSearchBarTextFieldHeight				28
#define	kSearchBarIndicatorViewWidth			10
#define	kSearchBarIndicatorViewHeight			10
#define	kSearchBarButtonHeight					28

// 控件间距
#define kSearchBarSelfHMargin					8
#define	kSearchBarButtonHMargin					10
#define	kSearchBarTextFieldLeftHMargin			14
#define kSearchBarTextFieldRightHMargin			10

#define kUIColorOfHex(color)						[UIColor qim_colorWithHex:(color) alpha:1.0]
// 控件字体
#define	kSearchBarTextFieldFont					kCurNormalFontOfSize(14)
#define	kSearchBarButtonFont					kCurBoldFontOfSize(16)
#define kSearchBarLabelFont						kCurNormalFontOfSize(14)

// 颜色
#define	kSearchBarBackGroundColor				kUIColorOfHex(0x1ba9ba)
#define kSearchBarButtonTextColor             [UIColor qim_colorWithHex:0x77FFFF alpha:1.0f]
#define kSearchBarButtonTextPressColor        [UIColor qim_colorWithHex:0x77FFFF alpha:0.5f]

@interface SearchBar ()

@property (nonatomic, strong) UIImageView *imageViewBG;		// 背景View
@property (nonatomic, strong) UIView *searchTextBG;			// 输入框View
@property (nonatomic, strong) UITextField *textField;		// 搜索输入框
@property (nonatomic, strong) UIButton *buttonBack;			// 按钮
@property (nonatomic, strong) UIButton *buttonBar;			// 按钮
@property (nonatomic, strong) UILabel *labelHint;			// 提示文本
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;	// 提示旋转
@property (nonatomic, assign) BOOL isBackButtonShow;		// 是否显示返回按钮
@property (nonatomic, assign) BOOL isButtonShow;			// 是否显示按钮
@property (nonatomic, assign) BOOL isIndicatorShow;			// 是否显示提示旋转
@property (nonatomic, assign) BOOL isLabelShow;				// 是否显示提示文本

// 输入中
- (void)searchChanged:(id)sender;

// 输入结束
- (void)searchFinished:(id)sender;

// 点击按钮
- (void)searchBarButtonClicked:(id)sender;

// 刷新Layout
- (void)reLayout:(BOOL)animated;

@end

// ==================================================================
// 实现
// ==================================================================
@implementation SearchBar

// 初始化
- (void)initlizeWithTitle:(NSString*)title
{
    // 设置黑色背景
    [self setBackgroundColor:[UIColor clearColor]];
    
    // 设置背景ImageView
    _imageViewBG = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_imageViewBG setBackgroundColor:[UIColor spectralColorLightColor]];
//    [_imageViewBG setBackgroundColor:kSearchBarBackGroundColor];
    [self addSubview:_imageViewBG];
    
    // 创建输入背景ImageView
    _searchTextBG = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_searchTextBG setBackgroundColor:[UIColor whiteColor]];
    [[_searchTextBG layer] setCornerRadius:4.0f];
    [[_searchTextBG layer] setMasksToBounds:YES];
    [self addSubview:_searchTextBG];
	
    // 设置TextField
    _textField = [[UITextField alloc] initWithFrame:CGRectZero];
    [_textField setBorderStyle:UITextBorderStyleNone];
    [_textField setFont:[UIFont systemFontOfSize:FONT_SIZE - 4]];
    [_textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
	[_textField setTextAlignment:NSTextAlignmentLeft];
    [_textField setClearButtonMode:UITextFieldViewModeWhileEditing];
	[_textField setAutocorrectionType:UITextAutocorrectionTypeNo];
	[_textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_textField addTarget:self action:@selector(searchStart:) forControlEvents:UIControlEventEditingDidBegin];
    [_textField addTarget:self action:@selector(searchChanged:) forControlEvents:UIControlEventEditingChanged];
    [_textField addTarget:self action:@selector(searchFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [_textField setDelegate:self];
    [self addSubview:_textField];
	
    // 提示文本
    _labelHint = [[UILabel alloc] initWithFrame:CGRectZero];
    [_labelHint setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_labelHint setBackgroundColor:[UIColor clearColor]];
    [_labelHint setFont:kSearchBarLabelFont];
    [_labelHint setTextColor:[UIColor lightGrayColor]];
    [self addSubview:_labelHint];
    
    // 创建Indicator
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:_indicatorView];
    
    // 设置搜索Button
    _buttonBar = [UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonBar setBackgroundColor:[UIColor clearColor]];
    [_buttonBar setTitleColor:kSearchBarButtonTextColor forState:UIControlStateNormal];
    [_buttonBar setTitleColor:kSearchBarButtonTextPressColor forState:UIControlStateHighlighted];
    [_buttonBar addTarget:self action:@selector(searchBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [[_buttonBar titleLabel] setFont:kSearchBarButtonFont];
    [self addSubview:_buttonBar];
    
    // 设置Button的背景图片
    _buttonBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonBack setBackgroundImage:[UIImage imageNamed:kNaviBackBarButtonNormalImageFile]
                           forState:UIControlStateNormal];
    [_buttonBack setBackgroundImage:[UIImage imageNamed:kNaviBackBarButtonHighlightedImageFile]
                           forState:UIControlStateHighlighted];
    [_buttonBack setBackgroundImage:[UIImage imageNamed:kNaviBackBarButtonDisableImageFile]
                           forState:UIControlStateDisabled];
    
    [_buttonBack addTarget:self
                    action:@selector(searchBackButtonClicked:)
          forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_buttonBack];
    
    // 显示
    if(title != nil)
    {
        [_buttonBar setTitle:title forState:UIControlStateNormal];
        _isButtonShow = YES;
    }
    else
    {
        [_buttonBar setTitle:nil forState:UIControlStateNormal];
        _isButtonShow = NO;
    }
    
    _isBackButtonShow = NO;
    _isIndicatorShow = NO;
    _isLabelShow = NO;
    
    // 刷新界面
    [self reLayout:NO];
}

- (SearchBar *)initWithCoder:(NSCoder *)aDecoder
{
    if((self = [super initWithCoder:aDecoder]) != nil)
    {
        [self initlizeWithTitle:nil];
    }
    return self;

}
- (SearchBar *)initWithFrame:(CGRect)frameInit andButton:(NSString *)title
{
	if((self = [super initWithFrame:frameInit]) != nil)
	{

		[self initlizeWithTitle:title];
		return self;
	}
	
	return nil;
}

// 设置frame
- (void)setFrame:(CGRect)frameNew
{
	[super setFrame:frameNew];
	
	// 刷新界面
	[self reLayout:NO];
}

// 设置和获取placeHolder
- (NSString *)placeHolder
{
	return [_textField placeholder];
}

- (void)setPlaceHolder:(NSString *)placeHolder
{
	[_textField setPlaceholder:placeHolder];
}

// 获取和设置Text
- (NSString *)text
{
	return [_textField text];
}

- (void)setText:(NSString *)textNew
{
	[_textField setText:textNew];
}

// 获取和设置Hint
- (NSString *)hint
{
	return [_labelHint text];
}

- (void)setHint:(NSString *)hintNew
{
	[_labelHint setText:hintNew];
	
	// 刷新界面
	[self reLayout:NO];
}

// 获取和设置自动大写字母
- (UITextAutocapitalizationType)autocapitalizationType
{
	return [_textField autocapitalizationType];
}

- (void)setAutocapitalizationType:(UITextAutocapitalizationType)newType
{
	[_textField setAutocapitalizationType:newType];
}

// 获取和设置纠正
- (UITextAutocorrectionType)autocorrectionType
{
	return [_textField autocorrectionType];
}

- (void)setAutocorrectionType:(UITextAutocorrectionType)newType
{
	[_textField setAutocorrectionType:newType];
}

// 键盘类型
- (UIKeyboardType)keyboardType
{
	return [_textField keyboardType];
}

- (void)setKeyboardType:(UIKeyboardType)newType
{
	[_textField setKeyboardType:newType];
}

// 设置返回键
- (UIReturnKeyType)returnKeyType
{
	return [_textField returnKeyType];
}

- (void)setReturnKeyType:(UIReturnKeyType)newType
{
	[_textField setReturnKeyType:newType];
}

- (void)showBackButton:(BOOL)isShow animated:(BOOL)animated
{
	if(_isBackButtonShow != isShow)
	{
		_isBackButtonShow = isShow;
		
		// 刷新
		[self reLayout:animated];
	}
}

// 控制BarButton
- (void)setBarButtonImage:(UIImage *)image forState:(UIControlState)stateNew
{
	[_buttonBar setBackgroundImage:image forState:stateNew];
}

- (void)setBarButtonTitle:(NSString *)title;
{
	[_buttonBar setTitle:title forState:UIControlStateNormal];
		
	// 隐藏按钮
	if((title == nil) || ([title length] == 0))
	{
		_isButtonShow = NO;
	}
	
	// 刷新
	[self reLayout:NO];
}

// 控制显示和隐藏
- (void)showBarButton:(BOOL)isShow animated:(BOOL)animated
{
	if(_isButtonShow != isShow)
	{
		_isButtonShow = isShow;
		
		// 刷新
		[self reLayout:animated];
	}
}

- (void)showHintLabel:(BOOL)isShow
{
	if(_isLabelShow != isShow)
	{
		_isLabelShow = isShow;
		
		// 控制旋转
		if(_isLabelShow == YES)
		{
			[_textField setClearButtonMode:UITextFieldViewModeNever];
		}
		else
		{
			if(_isIndicatorShow)
			{
				[_textField setClearButtonMode:UITextFieldViewModeNever];
			}
			else
			{
				[_textField setClearButtonMode:UITextFieldViewModeWhileEditing];
			}
		}
		
		// 刷新
		[self reLayout:NO];
	}
}

- (void)showIndicatorView:(BOOL)isShow
{
	if(_isIndicatorShow != isShow)
	{
		_isIndicatorShow = isShow;
		
		// 控制旋转
		if(_isIndicatorShow == YES)
		{
			[_textField setClearButtonMode:UITextFieldViewModeNever];
			[_indicatorView startAnimating];
		}
		else
		{
			if(_isLabelShow)
			{
				[_textField setClearButtonMode:UITextFieldViewModeNever];
			}
			else
			{
				[_textField setClearButtonMode:UITextFieldViewModeWhileEditing];
			}
			
			[_indicatorView stopAnimating];
		}
		
		// 刷新
		[self reLayout:NO];
	}
}

// 能否获得焦点
- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (BOOL)isFirstResponder{
    return [_textField isFirstResponder];
}

// 获得焦点
- (BOOL)becomeFirstResponder
{
	return [_textField becomeFirstResponder];
}

// 取消焦点
- (BOOL)resignFirstResponder
{
	if (([_textField text] != nil) && ([[_textField text] length] > 0))
	{
		[_textField setTextAlignment:NSTextAlignmentLeft];
	}
	else
	{
		[_textField setTextAlignment:NSTextAlignmentCenter];
	}
	
	[self reLayout:YES];
	
	return [_textField resignFirstResponder];
}

// =======================================================================
// 事件处理函数
// =======================================================================
- (void)searchStart:(id)sender
{
	[_textField setTextAlignment:NSTextAlignmentLeft];
	
	[self reLayout:YES];
}

- (void)searchChanged:(id)sender
{
	if(_delegate != nil)
	{
		if([_delegate respondsToSelector:@selector(searchBar:textDidChange:)] == YES)
		{
			[_delegate searchBar:self textDidChange:[self text]];
		}
	}
}

// 输入结束
- (void)searchFinished:(id)sender
{
	if (([_textField text] != nil) && ([[_textField text] length] > 0))
	{
		[_textField setTextAlignment:NSTextAlignmentLeft];
	}
	else
	{
		[_textField setTextAlignment:NSTextAlignmentCenter];
	}
	
	[self reLayout:YES];
	
	if(_delegate != nil)
	{
		if([_delegate respondsToSelector:@selector(searchBarSearchButtonClicked:)] == YES)
		{
			[_delegate searchBarSearchButtonClicked:self];
		}
	}
}

// 点击按钮
- (void)searchBarButtonClicked:(id)sender
{
	if(_delegate != nil)
	{
		if([_delegate respondsToSelector:@selector(searchBarBarButtonClicked:)] == YES)
		{
			[_delegate searchBarBarButtonClicked:self];
		}
	}
}

// 点击返回
- (void)searchBackButtonClicked:(id)sender
{
	if(_delegate != nil)
	{
		if([_delegate respondsToSelector:@selector(searchBarBackButtonClicked:)] == YES)
		{
			[_delegate searchBarBackButtonClicked:self];
		}
	}
}

// =======================================================================
// 辅助函数
// =======================================================================
// 刷新Layout
- (void)reLayout:(BOOL)animated
{
	// 父窗口尺寸
	CGRect parentFrame = [self frame];
	
	// 子控件高宽
	NSInteger spaceXStart = 0;
	NSInteger spaceXEnd = parentFrame.size.width;
	NSInteger spaceXEndButton = 0;
	NSInteger spaceXStartButton = 0;
	
	// 背景图片
	[_imageViewBG setFrame:CGRectMake(0, 0, parentFrame.size.width, parentFrame.size.height)];
	
	/* 间隔 */
	spaceXEnd -= kSearchBarSelfHMargin;
	spaceXEndButton = spaceXEnd;
	spaceXStartButton = spaceXStart;
	
	// 按钮高宽
	NSInteger buttonWidth = 0;
	NSInteger buttonHeight = 0;
	
	// 按钮高宽
	NSInteger backButtonWidth = 0;
	NSInteger backButtonHeight = kSearchBarBackButtonHeight;
	
	// 设置Button
	if(_buttonBar != nil)
	{
		// 计算字符串尺寸
		NSString *buttonTitle = [_buttonBar titleForState:UIControlStateNormal];
		if((buttonTitle != nil) && ([buttonTitle length] != 0))
		{
			CGSize titleSize = [buttonTitle qim_sizeWithFontCompatible:kSearchBarButtonFont];
			
			// 为了动画效果，需要重新设置宽度
			if(_isButtonShow == YES)
			{
				buttonWidth = titleSize.width + 2 * kSearchBarButtonHMargin;
			}
			buttonHeight = kSearchBarButtonHeight;
		}
		
		// 设置自己的尺寸
		if(_isButtonShow == NO)
		{
			NSTimeInterval duration = 0.0;
			if(animated)
			{
				duration = 0.15;
			}
			
			[UIView animateWithDuration:duration
								  delay:0
								options:UIViewAnimationOptionCurveEaseIn
							 animations:^{
								 [_buttonBar setFrame:CGRectMake(spaceXEnd - buttonWidth,
																 parentFrame.size.height - (NSInteger)(kSearchBarDefaultHeight - buttonHeight) / 2 - buttonHeight,
																 0.01, buttonHeight)];
							 }
							 completion:nil];
		}
		
		// 计算游标
		if(_isButtonShow)
		{
			// 调整子窗口
			spaceXEnd -= buttonWidth;
			
			/* 间隔 */
			spaceXEnd -= kSearchBarSelfHMargin;
		}
	}
	
	// 设置Button
	if(_buttonBack != nil)
	{
		if(_isBackButtonShow == YES)
		{
			backButtonWidth = kSearchBarBackButtonWidth;
		}
		
		// 设置自己的尺寸
		if(_isBackButtonShow == NO)
		{
			NSTimeInterval duration = 0.0;
			if(animated)
			{
				duration = 0.15;
			}
			
			[UIView animateWithDuration:duration
								  delay:0
								options:UIViewAnimationOptionCurveEaseIn
							 animations:^{
								 [_buttonBack setFrame:CGRectMake(spaceXStart, parentFrame.size.height - backButtonHeight, backButtonWidth, backButtonHeight)];
							 }
							 completion:nil];
		}
		
		// 计算游标
		if(_isBackButtonShow)
		{
			// 调整子窗口
			spaceXStart += kSearchBarBackButtonWidth;
		}
	}
	
	/* 间隔 */
	spaceXStart += kSearchBarSelfHMargin;
	
	// 设置背景ImageView
	if(_searchTextBG != nil)
	{
		// 设置自己的尺寸
		NSTimeInterval duration = 0.0;
		if(animated)
		{
			duration = 0.15;
		}
		
		[UIView animateWithDuration:duration
							  delay:0
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^{
										[_searchTextBG setFrame:CGRectMake(spaceXStart,
																		   parentFrame.size.height - (NSInteger)(kSearchBarDefaultHeight - kSearchBarTextFieldHeight) / 2 - kSearchBarTextFieldHeight,
																		   spaceXEnd - spaceXStart, kSearchBarTextFieldHeight)];
						 }
						 completion:nil];
	}
	
	// 设置IndicatorView
	if(_indicatorView != nil)
	{
		if(_isIndicatorShow)
		{
			NSTimeInterval duration = 0.0;
			if(animated)
			{
				duration = 0.15;
			}
			
			[UIView animateWithDuration:duration
								  delay:0
								options:UIViewAnimationOptionCurveEaseIn
							 animations:^{
											[_indicatorView setFrame:CGRectMake(spaceXEnd - kSearchBarTextFieldRightHMargin - kSearchBarIndicatorViewWidth,
																			   parentFrame.size.height - (NSInteger)(kSearchBarDefaultHeight - kSearchBarIndicatorViewHeight) / 2 - kSearchBarIndicatorViewHeight,
																			   kSearchBarIndicatorViewWidth, kSearchBarIndicatorViewHeight)];
							 }
							 completion:nil];
			[_indicatorView setHidden:NO];
		}
		else
		{
			[_indicatorView setHidden:YES];
		}
	}
	
	// 设置Hint
	if(_labelHint != nil)
	{
		if(_isLabelShow)
		{
			// 计算字符串尺寸
			NSString *hintText = [_labelHint text];
			if((hintText != nil) && ([hintText length] != 0))
			{
				CGSize hintSize = [hintText qim_sizeWithFontCompatible:kSearchBarLabelFont];
				
				// 设置自己的尺寸
				NSTimeInterval duration = 0.0;
				if(animated)
				{
					duration = 0.15;
				}
				
				[UIView animateWithDuration:duration
									  delay:0
									options:UIViewAnimationOptionCurveEaseIn
								 animations:^{
												[_labelHint setFrame:CGRectMake(spaceXEnd - kSearchBarTextFieldRightHMargin - hintSize.width,
																				parentFrame.size.height - (NSInteger)(kSearchBarDefaultHeight - hintSize.height) / 2 - hintSize.height,
																				hintSize.width, hintSize.height)];
								 }
								 completion:nil];
				[_labelHint setHidden:NO];
				
				// 调整子窗口
				spaceXEnd -= hintSize.width;
				
				/* 间隔 */
				spaceXEnd -= kSearchBarSelfHMargin * 2;
			}
			else
			{
				[_labelHint setHidden:YES];
			}
		}
		else
		{
			[_labelHint setHidden:YES];
		}
	}
	
	// 设置TextField
	if(_textField != nil)
	{
		NSTimeInterval duration = 0.0;
		if(animated)
		{
			duration = 0.15;
		}
		
		[UIView animateWithDuration:duration
							  delay:0
							options:UIViewAnimationOptionCurveEaseIn
						 animations:^{
								 if ([_textField textAlignment] == NSTextAlignmentCenter)
								 {
									 [_textField setFrame:CGRectMake(spaceXStart + kSearchBarTextFieldLeftHMargin,
																	 parentFrame.size.height - (NSInteger)(kSearchBarDefaultHeight - kSearchBarTextFieldHeight) / 2 - kSearchBarTextFieldHeight + 1,
																	 spaceXEnd - spaceXStart - kSearchBarTextFieldLeftHMargin*2,
																	 kSearchBarTextFieldHeight)];
								 }
								 else
								 {
									 [_textField setFrame:CGRectMake(spaceXStart + kSearchBarTextFieldLeftHMargin,
																	 parentFrame.size.height - (NSInteger)(kSearchBarDefaultHeight - kSearchBarTextFieldHeight) / 2 - kSearchBarTextFieldHeight + 1,
																	 spaceXEnd - spaceXStart - kSearchBarTextFieldLeftHMargin,
																	 kSearchBarTextFieldHeight)];
								 }
						 }
						 completion:nil];
	}
	
	// 设置自己的尺寸
	if(_isButtonShow)
	{
		// 设置Button
		if(_buttonBar != nil)
		{
			NSTimeInterval duration = 0.0;
			if(animated)
			{
				duration = 0.15;
			}
			
			[UIView animateWithDuration:duration
								  delay:0
								options:UIViewAnimationOptionCurveEaseIn
							 animations:^{
								 [_buttonBar setFrame:CGRectMake(spaceXEndButton - buttonWidth,
																 parentFrame.size.height - (NSInteger)(kSearchBarDefaultHeight - buttonHeight) / 2 - buttonHeight,
																 buttonWidth, buttonHeight)];
							 }
							 completion:nil];
		}
	}
	
	// 设置自己的尺寸
	if(_isBackButtonShow)
	{
		// 设置Button
		if(_buttonBack != nil)
		{
			NSTimeInterval duration = 0.0;
			if(animated)
			{
				duration = 0.15;
			}
			
			[UIView animateWithDuration:duration
								  delay:0
								options:UIViewAnimationOptionCurveEaseIn
							 animations:^{
								 [_buttonBack setFrame:CGRectMake(spaceXStartButton, parentFrame.size.height - backButtonHeight, backButtonWidth, backButtonHeight)];
							 }
							 completion:nil];
		}
	}
}

// =======================================================================
// TextField函数
// =======================================================================
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	if(_delegate != nil)
	{
		if([_delegate respondsToSelector:@selector(searchBar:shouldChangeTextInRange:replacementText:)] == YES)
		{
			return [_delegate searchBar:self shouldChangeTextInRange:range replacementText:string];
		}
	}
	
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if(_delegate != nil)
	{
		if([_delegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)] == YES)
		{
			[_delegate searchBarTextDidBeginEditing:self];
		}
	}
	
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if(_delegate != nil)
	{
		if([_delegate respondsToSelector:@selector(searchBarTextDidEndEditing:)] == YES)
		{
			[_delegate searchBarTextDidEndEditing:self];
		}
	}
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	if(_delegate != nil)
	{
		if([_delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)] == YES)
		{
			return [_delegate searchBarShouldBeginEditing:self];
		}
	}
	
	return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
	if(_delegate != nil)
	{
		if([_delegate respondsToSelector:@selector(searchBarShouldEndEditing:)] == YES)
		{
			return [_delegate searchBarShouldEndEditing:self];
		}
	}
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	return YES;
}

- (void)dealloc
{
	_delegate = nil;
}

@end
