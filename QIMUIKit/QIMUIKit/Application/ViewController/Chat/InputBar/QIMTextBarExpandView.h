//
//  QIMTextBarExpandView.h
//  qunarChatIphone
//
//  Created by chenjie on 15/7/9.
//
//

#import "QIMCommonUIFramework.h"
#import "QIMMsgBaseVC.h"
typedef enum {
    QIMTextBarExpandViewTypeNomal = 1 << 0,
    QIMTextBarExpandViewTypeGroup = 1 << 1,//群组
    QIMTextBarExpandViewTypeSingle = 1 << 2,//单人聊天
    QIMTextBarExpandViewTypeRobot = 1 << 3,//机器人
    QIMTextBarExpandViewTypeConsult = 1 << 4, //Consult会话
    QIMTextBarExpandViewTypeConsultServer = 1 << 5, //ConsultServer会话
    QIMTextBarExpandViewTypePublicNumber = 1 << 6, //公众号会话
} QIMTextBarExpandViewType;


#define QIMTextBarExpandViewItem_Photo            @"Album"
#define QIMTextBarExpandViewItem_Camera           @"Camera"
#define QIMTextBarExpandViewItem_MyFiles          @"MyFile"
#define QIMTextBarExpandViewItem_QuickReply       @"QuickReply"
#define QIMTextBarExpandViewItem_VideoCall        @"VideoCall"
#define QIMTextBarExpandViewItem_Location         @"Location"
#define QIMTextBarExpandViewItem_BurnAfterReading @"BurnAfterReading"
#define QIMTextBarExpandViewItem_ChatTransfer     @"ChatTransfer"
#define QIMTextBarExpandViewItem_ShareCard        @"ShareCard"
#define QIMTextBarExpandViewItem_RedPack          @"RedPack"
#define QIMTextBarExpandViewItem_AACollection     @"AACollection"
#define QIMTextBarExpandViewItem_SendProduct      @"SendProduct"
#define QIMTextBarExpandViewItem_SendActivity     @"SendActivity"
#define QIMTextBarExpandViewItem_Shock            @"Shock"
#define QIMTextBarExpandViewItem_TouPiao          @"toupiao"
#define QIMTextBarExpandViewItem_Task_list        @"Task_list"

@class QIMTextBarExpandView;
@protocol QIMTextBarExpandViewDelegate <NSObject>

- (void)didClickExpandItemForTrdextendId:(NSString *)trdextendId;

- (void)textBarExpandView:(QIMTextBarExpandView *)expandView forItemIndex:(NSInteger)itemIndex;

- (void)scrollViewDidScrollToIndex:(NSInteger)currentPage;

@end

@interface QIMTextBarExpandView : UIView <QIMMsgBaseVCDelegate>

@property (nonatomic,assign)id<QIMTextBarExpandViewDelegate> delegate;
@property (nonatomic,assign)UIViewController        * parentVC;
@property (nonatomic,assign)QIMTextBarExpandViewType   type;
-(instancetype)initWithFrame:(CGRect)frame;

- (void)displayItems;

- (void)addItems;

+ (NSDictionary *)getTrdExtendInfoForType:(NSNumber *)type;

@end
