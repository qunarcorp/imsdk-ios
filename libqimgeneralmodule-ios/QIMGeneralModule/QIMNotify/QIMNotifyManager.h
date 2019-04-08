//
//  QIMNotifyManager.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/2/26.
//

#import <Foundation/Foundation.h>

@class QIMNotifyView;

@protocol QIMNotifyManagerDelegate <NSObject>

- (void)showGloablNotifyWithView:(QIMNotifyView *)view;

@optional
- (void)showChatNotifyWithView:(QIMNotifyView *)view WithMessage:(NSDictionary *)message;

@end

@interface QIMNotifyManager : NSObject

+ (instancetype)shareNotifyManager;

@property (nonatomic, weak) id <QIMNotifyManagerDelegate> notifyManagerGlobalDelegate;

@property (nonatomic, weak) id <QIMNotifyManagerDelegate> notifyManagerSpecifiedDelegate;


- (void)showGlobalNotifyWithMessage:(NSDictionary *)message;

- (void)showChatNotifyWithMessage:(NSDictionary *)message;

@end
