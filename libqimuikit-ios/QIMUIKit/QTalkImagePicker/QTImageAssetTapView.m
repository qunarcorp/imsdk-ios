//
//  QTImageAssetTipView.m
//  qunarChatIphone
//
//  Created by admin on 15/8/18.
//
//

#import "QTImageAssetTapView.h"

#define IS_IOS7             ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)

@interface QTImageAssetTapView ()
@property(nonatomic,retain)UIImageView *selectView;
@end

@implementation QTImageAssetTapView{
    UIImage *checkedIcon;
    UIColor *selectedColor;
    UIColor *disabledColor;
}


-(id)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        //设置勾勾的位置
        
        checkedIcon = [UIImage imageNamed:@"photo_browser_checxbox_sel"];
        selectedColor   = [UIColor colorWithWhite:1 alpha:0.3];
        disabledColor   = [UIColor colorWithWhite:1 alpha:0.9];
        
        _selectView=[[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width-checkedIcon.size.width-2, 2, checkedIcon.size.width, checkedIcon.size.height)];
        [self addSubview:_selectView];
    }
    return self;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_disabled) {
        return;
    }
    
    if (_delegate!=nil&&[_delegate respondsToSelector:@selector(shouldTap)]) {
        if (![_delegate shouldTap]&&!_selected) {
            return;
        }
    }
    
    if ((_selected=!_selected)) {
        self.backgroundColor=selectedColor;
        [_selectView setImage:checkedIcon];
    }
    else{
        self.backgroundColor=[UIColor clearColor];
        [_selectView setImage:nil];
    }
    if (_delegate!=nil&&[_delegate respondsToSelector:@selector(touchSelect:)]) {
        [_delegate touchSelect:_selected];
    }
}

-(void)setDisabled:(BOOL)disabled{
    _disabled=disabled;
    if (_disabled) {
        self.backgroundColor=disabledColor;
    }
    else{
        self.backgroundColor=[UIColor clearColor];
    }
}

-(void)setSelected:(BOOL)selected{
    if (_disabled) {
        self.backgroundColor=disabledColor;
        [_selectView setImage:nil];
        return;
    }
    
    _selected=selected;
    if (_selected) {
        self.backgroundColor=selectedColor;
        [_selectView setImage:checkedIcon];
    }
    else{
        self.backgroundColor=[UIColor clearColor];
        [_selectView setImage:nil];
    }
}


@end
