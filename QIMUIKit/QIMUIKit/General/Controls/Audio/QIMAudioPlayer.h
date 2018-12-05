//
//  QIMAudioPlayer.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/15.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMAudioPlayer : UIView

@property (nonatomic, strong) NSString *audioPath;
@property (nonatomic, strong) NSString *audioName;

- (void)play;

@end
