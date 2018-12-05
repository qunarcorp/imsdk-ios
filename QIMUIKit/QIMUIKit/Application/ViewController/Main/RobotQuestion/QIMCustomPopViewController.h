//
//  QIMCustomPopViewController.h
//  QIMUIVendorKit
//
//  Created by QIM on 11/5/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"

@interface QIMCustomPopViewController : UIViewController

@property (nonatomic, copy) NSString *popHeaderTitle;

@property (nonatomic, strong) NSMutableArray *items;

@end
