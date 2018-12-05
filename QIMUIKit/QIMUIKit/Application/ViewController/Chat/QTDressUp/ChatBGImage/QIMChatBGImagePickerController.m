//
//  QIMChatBGImagePickerController.m
//  qunarChatIphone
//
//  Created by chenjie on 15/7/17.
//
//

#import "QIMChatBGImagePickerController.h"

@interface QIMChatBGImagePickerController ()
{
    UIImage         * _image;
    
    UIImageView     * _displayImageView;
}

@end

@implementation QIMChatBGImagePickerController

-(instancetype)initWithImage:(UIImage *)image
{
    if (self = [self init]) {
        _image = image;
        [self setUpDisplayImageView];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addNavItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addNavItems
{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"使用" style:UIBarButtonItemStylePlain target:self action:@selector(useBtnHandle:)];
    [self.navigationItem setRightBarButtonItem:rightItem];
}

- (void)setUpDisplayImageView
{
    _displayImageView = [[UIImageView alloc] initWithImage:_image];
    _displayImageView.frame = self.view.bounds;
    _displayImageView.contentMode = UIViewContentModeScaleAspectFit;
    _displayImageView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_displayImageView];
}


-(void)useBtnHandle:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePicker:willDismissWithImage:)]) {
        [self.delegate imagePicker:self willDismissWithImage:_image];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


@end
