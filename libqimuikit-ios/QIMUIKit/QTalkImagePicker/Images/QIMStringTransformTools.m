//
//  QIMStringTransformTools.m
//  QunarUGC
//
//  Created by ping.xue on 13-11-11.
//
//

#import "QIMStringTransformTools.h"

@implementation QIMStringTransformTools

+ (NSString *)CapacityTransformStrWithSize:(long long)size{
    return [self CapacityTransformStrWithSize:size WithStrLenght:0];
}


+ (NSString *)CapacityTransformStrWithSize:(long long)size WithStrLenght:(NSUInteger)length{
    double lengths = size;
    NSString *lenStr = nil;
    NSString *unitStr = nil;
    int unit = 0;
    while ( lengths > 1000 && unit < 5) {
        unit++;
        lengths = lengths / 1024.0;
    }
    if (length == 0) {
        if (unit == 0) {
            lenStr = [NSString stringWithFormat:@"%.2fB",lengths];
        } else if (unit == 1) {
            lenStr = [NSString stringWithFormat:@"%.2fKB",lengths];
        } else if (unit == 2) {
            lenStr = [NSString stringWithFormat:@"%.2fMB",lengths];
        } else if (unit == 3) {
            lenStr = [NSString stringWithFormat:@"%.2fG",lengths];
        } else {
            lenStr = [NSString stringWithFormat:@"%.2fTB",lengths];
        }
    } else {
        if (unit == 0) {
            unitStr = @"B";
        } else if (unit == 1) {
            unitStr = @"KB";
        } else if (unit == 2) {
            unitStr = @"MB";
        } else if (unit == 3) {
            unitStr = @"G";
        } else {
            unitStr = @"TB";
        }
        if (length > 2) {
            NSInteger strl = length - [unitStr length];
            NSString *ls = [[NSString stringWithFormat:@"%.2f",lengths] substringToIndex:strl];
            if ([[ls substringWithRange:NSMakeRange(ls.length - 1, 1)] isEqualToString:@"."]) {
               ls = [ls substringToIndex:ls.length - 1];
            }
            lenStr = [NSString stringWithFormat:@"%@%@",ls,unitStr];
        } else {
            lenStr = [NSString stringWithFormat:@"%.2f%@",lengths,unitStr];
        }
    }
  
    return lenStr;
}

@end
