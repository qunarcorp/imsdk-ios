//
//  
//
//  Created by kimziv on 13-9-14.
//

#include "QIMHanyuPinyinOutputFormat.h"

@implementation QIMHanyuPinyinOutputFormat
@synthesize vCharType=_vCharType;
@synthesize caseType=_caseType;
@synthesize toneType=_toneType;

- (id)init {
  if (self = [super init]) {
    [self restoreDefault];
  }
  return self;
}

- (void)restoreDefault {
    _vCharType = VCharTypeWithUAndColon;
    _caseType = CaseTypeLowercase;
    _toneType = ToneTypeWithToneNumber;
}

@end
