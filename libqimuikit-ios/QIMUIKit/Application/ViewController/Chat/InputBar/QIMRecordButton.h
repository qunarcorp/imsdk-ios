
#import "QIMCommonUIFramework.h"

@class QIMRecordButton;

typedef void (^RecordTouchDown)         (QIMRecordButton *recordButton);
typedef void (^RecordTouchUpOutside)    (QIMRecordButton *recordButton);
typedef void (^RecordTouchUpInside)     (QIMRecordButton *recordButton);
typedef void (^RecordTouchDragEnter)    (QIMRecordButton *recordButton);
typedef void (^RecordTouchDragInside)   (QIMRecordButton *recordButton);
typedef void (^RecordTouchDragOutside)  (QIMRecordButton *recordButton);
typedef void (^RecordTouchDragExit)     (QIMRecordButton *recordButton);

@interface QIMRecordButton : UIButton

@property (nonatomic, copy) RecordTouchDown         recordTouchDownAction;
@property (nonatomic, copy) RecordTouchUpOutside    recordTouchUpOutsideAction;
@property (nonatomic, copy) RecordTouchUpInside     recordTouchUpInsideAction;
@property (nonatomic, copy) RecordTouchDragEnter    recordTouchDragEnterAction;
@property (nonatomic, copy) RecordTouchDragInside   recordTouchDragInsideAction;
@property (nonatomic, copy) RecordTouchDragOutside  recordTouchDragOutsideAction;
@property (nonatomic, copy) RecordTouchDragExit     recordTouchDragExitAction;

- (void)setButtonStateWithRecording;
- (void)setButtonStateWithNormal;

@end
