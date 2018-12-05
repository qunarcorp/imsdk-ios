//
//  QIMMoviePlayer.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/15.
//
//

#import "QIMCommonUIFramework.h"

@class AVPlayerLayer;
@interface VideoView : UIView
@property (nonatomic, weak) AVPlayerLayer *playerLayer;
@end

@interface QIMMoviePlayer : UIView

@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, strong) NSString *videoName;

- (void) play;
- (void) stop;
- (void) resume;

@end
