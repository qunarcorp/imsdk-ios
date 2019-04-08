//
//  EIRadioButton.h
//  EInsure
//
//  Created by ivan on 13-7-9.
//  Copyright (c) 2013年 ivan. All rights reserved.
//

#import "QIMCommonUIFramework.h"

@protocol QRadioButtonDelegate;

@interface QRadioButton : UIButton {
    NSString                        *_groupId;
    BOOL                            _checked;
}

@property (nonatomic, assign) id <QRadioButtonDelegate>   delegate;
@property (nonatomic, assign) BOOL checked;
@property (nonatomic, assign) BOOL radioEnabled;
@property (nonatomic, copy) NSString *groupId;

- (id)initWithDelegate:(id)delegate groupId:(NSString*)groupId;

@end

@protocol QRadioButtonDelegate <NSObject>

@optional

- (void)didSelectedRadioButton:(QRadioButton *)radio groupId:(NSString *)groupId;


- (void)didUnSelectedRadioButton:(QRadioButton *)radio groupId:(NSString *)groupId;

@end
