//
//  ShareLocationUserImageView.h
//  qunarChatIphone
//
//  Created by chenjie on 16/1/28.
//
//

#import "QIMCommonUIFramework.h"

@interface ShareLocationUserImageView :UIView

-(instancetype)initWithUserId:(NSString *)userId;

- (void)updateDirectionTo:(double)degrees;

@end
