//
//  QIMEmotionSpirits.m
//  qunarChatIphone
//
//  Created by admin on 15/8/24.
//
//

#import "QIMEmotionSpirits.h"
#import "QIMEmotionManager.h"
#import "QIMSingleChatTimestampCell.h"

@protocol QIMEmotionSpiritsProtocol <NSObject>
@optional
- (CGRect)getCellBackViewFrame;
@end

static QIMEmotionSpirits *__emotion_spirits = nil;

@interface MyCAKeyframeAnimation : CAKeyframeAnimation
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) BOOL isEnd;
@end

@implementation MyCAKeyframeAnimation

@end

@implementation QIMEmotionSpirits{
    NSMutableDictionary *_dictionary;
    NSMutableArray *_emotionSpiritsList;
    dispatch_queue_t _play_emotion;
}


+ (UIImage *)imageFromText:(NSString *)text width:(float)width height:(float)height
{
    // set the font type and size
    UIFont *font = [UIFont systemFontOfSize:12.0];
    CGSize size  = CGSizeMake(width, height);// [text sizeWithFont:font];
    
    // check if UIGraphicsBeginImageContextWithOptions is available (iOS is 4.0+)
    if (&UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
    else
        // iOS is < 4.0
        UIGraphicsBeginImageContext(size);
    
    // optional: add a shadow, to avoid clipping the shadow you should make the context size bigger
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetShadowWithColor(ctx, CGSizeMake(1.0, 1.0), 5.0, [[UIColor clearColor] CGColor]);
    
    // draw in context, you can use  drawInRect/drawAtPoint:withFont:
    //[text drawAtPoint:CGPointMake(0.0, 0.0) withFont:font];
    [text drawInRect:CGRectMake(0, 0, width, height) withFont:font];
    
    // transfer image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (QIMEmotionSpirits *)sharedInstance{
    if (__emotion_spirits == nil) {
        __emotion_spirits = [[QIMEmotionSpirits alloc] init];
    }
    return __emotion_spirits;
}

- (instancetype)init{
    self = [super init];
    if (self) {
//        么么哒，生日快乐，恭喜你，我也爱你，清明时节雨纷纷，两只老虎跑得快，早生贵子，屌爆了，保重，得意，无聊，流泪，感动，可怜，发呆，色，喜爱，无奈。撇嘴，流汗，惊讶，UBB
        _emotionSpiritsList = [NSMutableArray array];
        _dictionary = [NSMutableDictionary dictionary];
        [_dictionary setObject:@"/fw" forKey:@"么么哒"];//3
        [_dictionary setObject:@"/bb" forKey:@"生日快乐"];//3
        [_dictionary setObject:@"/hs" forKey:@"我也爱你"];//3
//        [_dictionary setObject:@"/hs" forKey:@"清明时节雨纷纷"];//6
        [_dictionary setObject:@"/xx" forKey:@"想想"];
//        [_dictionary setObject:@"/maom" forKey:@"两只老虎跑得快"]; //2
//        [_dictionary setObject:@"/nping" forKey:@"早生贵子"];
//        [_dictionary setObject:@"/fengc" forKey:@"大风车吱呀吱悠悠的转"];
//        [_dictionary setObject:@"/guzg" forKey:@"恭喜"];
        [_dictionary setObject:@"/okok" forKey:@"ok"];
        [_dictionary setObject:@"/okok" forKey:@"好的"];
        [_dictionary setObject:@"/jiayou" forKey:@"加油"];
        [_dictionary setObject:@"/jiayou" forKey:@"day day up"];
        [_dictionary setObject:@"/zy" forKey:@"得意"];
//        [_dictionary setObject:@"/shui" forKey:@"无聊"];
//        [_dictionary setObject:@"/ll" forKey:@"流泪"];
        [_dictionary setObject:@"/kuaikl" forKey:@"可怜"];
        [_dictionary setObject:@"/bukx" forKey:@"发呆"];
        [_dictionary setObject:@"/hs" forKey:@"色咪咪"];
        [_dictionary setObject:@"/ka" forKey:@"可爱"];
        [_dictionary setObject:@"/xlh" forKey:@"汗"];
//        [_dictionary setObject:@"/pz" forKey:@"撇嘴"];
        [_dictionary setObject:@"/jingx" forKey:@"惊讶"];
//        [_dictionary setObject:@"🐵" forKey:@"猴"];
        [_dictionary setObject:@"/dah" forKey:@"困"];
        [_dictionary setObject:@"/dah" forKey:@"睡觉"];
        [_dictionary setObject:@"/yusan" forKey:@"下雨"];
        [_dictionary setObject:@"/yusan" forKey:@"大雨"];
        [_dictionary setObject:@"/yusan" forKey:@"暴雨"];
        [_dictionary setObject:@"/yusan" forKey:@"雨伞"];
        [_dictionary setObject:@"/yusan" forKey:@"带伞"];
        [_dictionary setObject:@"/zhuanj" forKey:@"求婚"];
        [_dictionary setObject:@"/zhuanj" forKey:@"表白"];
        [_dictionary setObject:@"/zhuanj" forKey:@"告白"];
        [_dictionary setObject:@"/shoutb" forKey:@"下班"];
        [_dictionary setObject:@"/chatw" forKey:@"生病"];
        [_dictionary setObject:@"/chatw" forKey:@"病假"];
        [_dictionary setObject:@"/chatw" forKey:@"感冒"];
        [_dictionary setObject:@"/shuangshhsh" forKey:@"拜托"];
        [_dictionary setObject:@"/shuangshhsh" forKey:@"保佑"];
        [_dictionary setObject:@"/shengdlr" forKey:@"圣诞"];
        [_dictionary setObject:@"/shengdlr" forKey:@"平安夜"];
        [_dictionary setObject:@"/shoub" forKey:@"买"];
        [_dictionary setObject:@"/laoyy" forKey:@"重阳节"];
        [_dictionary setObject:@"/shub" forKey:@"无聊"];
        [_dictionary setObject:@"/dak" forKey:@"哭"];
        [_dictionary setObject:@"/dak" forKey:@"伤心"];
        [_dictionary setObject:@"/paipsh" forKey:@"鼓掌"];
        [_dictionary setObject:@"/paipsh" forKey:@"赞"];
        [_dictionary setObject:@"/paipsh" forKey:@"欢迎"];
        [_dictionary setObject:@"/paipsh" forKey:@"啪啪"];
        _play_emotion = dispatch_queue_create("Play Emotion Spirits", 0);
//        [_dictionary setObject:@"/jy" forKey:@"1"];
    }
    return self;
}

- (void)playQIMEmotionSpiritsWithMessage:(NSString *)message{
    dispatch_async(_play_emotion, ^{
        for (NSString *key in _dictionary.allKeys) {
            if ([message rangeOfString:key].location != NSNotFound) {
                NSString *value = [_dictionary objectForKey:key];
                NSString * imageName  = [[QIMEmotionManager sharedInstance] getEmotionImagePathForShortCut:value withPackageId:@"EmojiOne"];
                if (imageName.length > 0) {
                    int count = (int)key.length;
                    for (int i = 0; i < count ; i++) {
                        UIImage * emotionImage = [UIImage imageWithContentsOfFile:imageName];
                        if (emotionImage) {
                            [_emotionSpiritsList addObject:emotionImage];
                        }
                    }
                } else {
//                    [_emotionSpiritsList addObject:[QIMEmotionSpirits imageFromText:value width:16 height:16]];
                }
            }
        }
        if (_emotionSpiritsList.count > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self playEmotionSpirit:[_emotionSpiritsList firstObject]];
            });
        }
    });
}

- (void)setTableView:(UITableView *)tableView{
    _tableView = tableView;
    [_emotionSpiritsList removeAllObjects];
}

- (void)playEmotionSpirit:(UIImage *)image{
    if (self.tableView == nil) {
        [_emotionSpiritsList removeAllObjects];
        return;
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(_tableView.contentSize.width / 2.0, self.tableView.contentOffset.y-30, 30, 30);
    [self.tableView addSubview:imageView];
    [self playAnimation:@{@"StartPoint":NSStringFromCGPoint(CGPointMake(self.tableView.width / 2.0,self.tableView.contentOffset.y-1)),@"Spirit":imageView}];
    [_emotionSpiritsList removeObject:image];
    UIImage *newImage = [_emotionSpiritsList firstObject];
    if (newImage) {
        CGFloat delay = (float)(arc4random() % 100)/100+0.4;
        [self performSelector:@selector(playEmotionSpirit:) withObject:newImage afterDelay:delay inModes:@[NSRunLoopCommonModes]];
    }
}

- (void)playAnimation:(NSDictionary*)animation{
    if (self.tableView == nil) {
        [_emotionSpiritsList removeAllObjects];
        return;
    }
    NSString *startPointStr = [animation objectForKey:@"StartPoint"];
    UIImageView *imgaeView = [animation objectForKey:@"Spirit"];
    CGPoint startPoint = CGPointFromString(startPointStr);
    CGPoint endPoint;
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:startPoint];
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat duration = 1;
    NSMutableArray *timeList = [NSMutableArray array];
    BOOL isEnd = YES;
    for (int row = (int)indexPath.row + 1 ; row < self.dataCount ; row ++) {
        id cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
        if (![cell isKindOfClass:[QIMSingleChatTimestampCell class]] && [cell respondsToSelector:@selector(getCellBackViewFrame)]) {
            CGRect rect = [cell getCellBackViewFrame];
            endPoint = CGPointMake(rect.origin.x+rect.size.width/2.0,rect.origin.y- imgaeView.height / 2.0);
            if (rect.size.width > 60) {
                CGFloat endX = rect.origin.x + 30 + ((long long)arc4random() % ((int)rect.size.width - 60));
                if (fabs(endX-startPoint.x) > _tableView.width/2.0) {
                    int xzz = (int)(_tableView.width/2.0-fabs(rect.origin.x-startPoint.x));
                    int a = (xzz==0?0:(long long)arc4random()%xzz);
                    endPoint.x = rect.origin.x + 30 + a;
                } else {
                    endPoint.x = endX;
                }
            }
            isEnd = NO;
            break;
        }
    }
    if (isEnd) {
        endPoint = CGPointMake(self.tableView.width/2.0, self.tableView.contentSize.height + 50);
        CGFloat endX = 50 + ((long long)arc4random() % ((int)self.tableView.width-100));
        int xzz = (int)(_tableView.width/2.0-fabs(50-startPoint.x));
        if (fabs(endX-startPoint.x) > _tableView.width/2.0) {
            endPoint.x = 50 + (xzz==0?0:(long long)arc4random()%xzz);
        } else {
            endPoint.x = endX;
        }
    }
    
    CGFloat cpx = startPoint.x;
    CGFloat cpy = startPoint.y - 25 - imgaeView.height / 2.0;
    if (startPoint.x > endPoint.x) {
        cpx += startPoint.x - endPoint.x > 60 ? -30: (endPoint.x - startPoint.x)/2.0;
    } else {
        cpx -= endPoint.x - startPoint.x > 60 ? -30: (startPoint.x - endPoint.x)/2.0;
    }
    CGFloat fabX = fabs(startPoint.x - endPoint.x);
    if (fabX > 70) {
        cpy = startPoint.y - 20 - 20 * (fabX - 70) / 140 - imgaeView.height/2.0;
    }
    CGPathMoveToPoint(path, NULL, startPoint.x, startPoint.y);
//    CGPathAddQuadCurveToPoint(path, NULL, startPoint.x, startPoint.y, cpx, cpy);
    CGPathAddQuadCurveToPoint(path, NULL, cpx, cpy-80, endPoint.x, endPoint.y);
    if (isEnd) {
        CGFloat jl = fabs(startPoint.x - endPoint.x);
        if (jl > 140) {
            duration = 0.6 + jl/ ((arc4random() % 800)+800);
        } else {
            duration = 0.6;
        }
        [timeList addObject:@(0.4)];
        [timeList addObject:@(1)];[self performSelector:@selector(playAnimationEnd:) withObject:@{@"StartPoint":NSStringFromCGPoint(endPoint),@"Spirit":imgaeView} afterDelay:duration+0.5 inModes:@[NSRunLoopCommonModes]];
    } else {
        CGFloat jl = fabs(startPoint.x - endPoint.x);
        if (jl > 140) {
            duration = 0.8 + jl / ((arc4random() % 800)+800);
        } else {
            duration = 0.8;
        }
        CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y);
        CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y-25);
        CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y);
        CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y-10);
        CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y);
        [timeList addObject:@(0.3)];
        [timeList addObject:@(0.7)];
        [timeList addObject:@(0.75)];
        [timeList addObject:@(0.85)];
        [timeList addObject:@(0.9)];
        [timeList addObject:@(0.95)];
        [timeList addObject:@(1)];
        endPoint.y += imgaeView.height / 2.0;
        [self performSelector:@selector(playAnimation:) withObject:@{@"StartPoint":NSStringFromCGPoint(endPoint),@"Spirit":imgaeView} afterDelay:duration+0.5 inModes:@[NSRunLoopCommonModes]];
    }
    
    MyCAKeyframeAnimation *pathAnimation = [MyCAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.imageView = imgaeView;
    pathAnimation.isEnd = isEnd;
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.duration = duration;
    pathAnimation.repeatCount = 1;
    pathAnimation.path = path; 
    if (isEnd) {
        pathAnimation.delegate = self;
    }
    CGPathRelease(path);
    pathAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [imgaeView.layer removeAllAnimations];
    [imgaeView.layer addAnimation:pathAnimation
                           forKey:@"moveTheSquare"];
}

- (void)playAnimationEnd:(NSDictionary*)animation{
    if (self.tableView == nil) {
        return;
    }
    UIImageView *imgaeView = [animation objectForKey:@"Spirit"];
    [imgaeView removeFromSuperview];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([anim isKindOfClass:[MyCAKeyframeAnimation class]]) {
        MyCAKeyframeAnimation *myCa = (MyCAKeyframeAnimation *)anim;
        if ([myCa isEnd]) {
            [[myCa imageView] removeFromSuperview];
        }
    }
}

@end
