//
//  QIMPreviewMsgVC.m
//  qunarChatIphone
//
//  Created by admin on 15/8/13.
//
//

#import "QIMPreviewMsgVC.h"
#import "QIMMessageBrowserVC.h"
#import "QIMAttributedLabel.h"
#import "QIMTextContainer.h"
#import "QIMMessageParser.h"

@interface QIMPreviewMsgVC (){
    
    UIScrollView *_scrollView;
    
    QIMAttributedLabel *_msgLabel;
}

@end

@implementation QIMPreviewMsgVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.message.messageDirection == MessageDirection_Received) {
        [self.view setBackgroundColor:[UIColor qim_leftBallocColor]];
    }else{
        [self.view setBackgroundColor:[UIColor qim_rightBallocColor]];
    }
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setShowsVerticalScrollIndicator:YES];
    [self.view addSubview:_scrollView];
    
    QIMTextContainer * container = [QIMMessageParser textContainerForMessage:self.message fromCache:NO];
    _msgLabel = [[QIMAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [_msgLabel setSize:[container getSuggestedSizeWithFramesetter:nil width:container.textWidth]];
    if (_msgLabel.height <= _scrollView.height) {
        [_msgLabel setCenter:_scrollView.center];
    }
    _msgLabel.backgroundColor = [UIColor clearColor];
    _msgLabel.textContainer = container;
    //    _msgLabel.delegate = self;
    [_scrollView addSubview:_msgLabel];
    [_scrollView setContentSize:CGSizeMake(_msgLabel.width, _msgLabel.height+20)];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClose)];
    [self.view addGestureRecognizer:tap];
}

- (void)onClose{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
