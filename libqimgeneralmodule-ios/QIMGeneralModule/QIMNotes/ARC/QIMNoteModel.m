//
//  QIMNoteModel.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/18.
//
//

#import "QIMNoteModel.h"
#import "NSObject+QIMRuntime.h"

@implementation QIMNoteModel

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addObserver];
    }
    return self;
}

- (void)addObserver {
    [self addObserver:self forKeyPath:@"qs_content" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"qs_content"]) {
        if (change[@"new"] && !([change[@"new"] isEqual:[NSNull null]])) {
            
            switch (self.qs_type) {
                case QIMPasswordTypeText:
                case QIMPasswordTypeURL:
                case QIMPasswordTypeEmail:
                case QIMPasswordTypeAddress:
                case QIMPasswordTypeDateTime:
                case QIMPasswordTypeYearMonth:
                case QIMPasswordTypeOnePassword:
                case QIMPasswordTypePassword:
                case QIMPasswordTypeTelphone:
                    if (self.pwdDelegate && [self.pwdDelegate respondsToSelector:@selector(updatePasswordModel)]) {
                        [self.pwdDelegate updatePasswordModel];
                    }
                    break;
//                case QIMNoteTypeTodoList:
//                if (self.todoDelegate && [self.todoDelegate respondsToSelector:@selector(updateTodoListModel)]) {
//                    [self.todoDelegate updateTodoListModel];
//                }
//                    break;
//                case QIMNoteTypeEverNote:
//                    if (self.noteDelegate && [self.noteDelegate respondsToSelector:@selector(updateEverNoteModel)]) {
//                        [self.noteDelegate updateEverNoteModel];
//                    }
//                    break;
                default:
                    break;
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"qs_content"];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        key = @"id";
        [super setValue:value forKey:key];
    } else {
        [super setValue:value forKey:key];
    }
}

- (NSString *)description {
    return [self qim_properties_aps];
}

@end
