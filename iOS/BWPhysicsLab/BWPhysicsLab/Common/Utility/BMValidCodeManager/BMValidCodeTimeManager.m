//
//  BMValidCodeTimeManager.m
//  BWPhysicsLab
//
//  Created by BobWong on 2016/10/24.
//  Copyright © 2016年 BobWongStudio. All rights reserved.
//

#import "BMValidCodeTimeManager.h"
#import "BMValidCodeTimeModel.h"
#import <TMCache.h>
#import <POP.h>

#define BMDefaultIntervalSeconds 120

@interface BMValidCodeTimeManager ()

@property (nonatomic, strong) BMValidCodeTimeModel *validCodeTimeModel;//验证码时间model
@property (strong, nonatomic) NSMutableDictionary *remainTimeDictM;  ///< 剩余时间记录
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation BMValidCodeTimeManager

#pragma mark - Life Cycle

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static BMValidCodeTimeManager *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BMValidCodeTimeManager alloc] init];
        sharedInstance.remainTimeDictM = [NSMutableDictionary new];
        [sharedInstance initDataFromDiskCache];
    });
    return sharedInstance;
}

#pragma mark - Public Method

//缓存到磁盘
- (void)cacheToDisk
{
    NSLog(@"缓存BMValidCodeTimeModel到本地:%@", self.validCodeTimeModel);
    [[TMCache sharedCache] setObject:self.validCodeTimeModel forKey:@"BMValidCodeTimeModelKey"];
}

//继续上一次倒计时
- (void)continuteLastCountDownAnimation:(UIButton *)btn withType:(BMValidCodeTimeType)type
{
    NSNumber *defaultRemainTime = self.remainTimeDictM[@(type)];
    if (!defaultRemainTime) return;
    [self startCountDownAnimationInButton:btn withType:type];
}

- (void)startTimer {
    if (!_timer) {
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(recordRemainTime) userInfo:nil repeats:YES];
        _timer = timer;
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
}

- (void)recordRemainTime {
    if (!_remainTimeDictM || _remainTimeDictM.count == 0) {
        if ([_timer isValid]) {
            [_timer invalidate];
            _timer = nil;
        }
        return;
    }
    
    NSMutableDictionary *dictM = [self.remainTimeDictM mutableCopy];
    [dictM enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSNumber *  _Nonnull number, BOOL * _Nonnull stop) {
        NSInteger remain = number.integerValue - 1;
        if (remain <= 0) {
            [self.remainTimeDictM removeObjectForKey:key];
            return;
        }
        self.remainTimeDictM[key] = @(remain);
    }];
}

//开始倒计时
- (void)startCountDownAnimationInButton:(UIButton *)btn withType:(BMValidCodeTimeType)type
{
    if (!btn) return;
    
    NSNumber *defaultRemainTime = self.remainTimeDictM[@(type)];
    if (!defaultRemainTime) {
        defaultRemainTime = @(BMDefaultIntervalSeconds + 1);
        self.remainTimeDictM[@(type)] = defaultRemainTime;
    }
    [self startTimer];
    
    NSString *orignTitle = btn.titleLabel.text;
    btn.enabled = NO;
    
    POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"BMFetchValidCodeCountDownProp" initializer:^(POPMutableAnimatableProperty *prop) {
        //修改变化后的值
        prop.writeBlock = ^(id obj, const CGFloat values[]){
            UIButton *button = (UIButton *)obj;
            NSUInteger remainingSeconds = values[0];
            NSLog(@"验证码倒计时剩余时间:%.0f", values[0]);
            NSString *btnTitle = [NSString stringWithFormat:@" %lus秒后重发 ",(unsigned long)remainingSeconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                [button setTitle:btnTitle forState:UIControlStateNormal];
            });
        };
        prop.threshold = 1;//间隔1s
    }];
    
    POPBasicAnimation *anBasic = [POPBasicAnimation linearAnimation];  // 线性
    anBasic.property = prop;
    anBasic.fromValue= @(defaultRemainTime.integerValue);
    anBasic.toValue = @(0);
    anBasic.duration = defaultRemainTime.integerValue;
    anBasic.beginTime = CACurrentMediaTime();
    [anBasic setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            btn.enabled = YES;
            [btn setTitle:orignTitle forState:UIControlStateNormal];
        });
    }];
    
    [btn pop_addAnimation:anBasic forKey:@"BMFetchValidCodeCountDownAnim"];
}

- (BOOL)countDowningWithType:(BMValidCodeTimeType)type {
    NSNumber *defaultRemainTime = self.remainTimeDictM[@(type)];
    if (!defaultRemainTime) {
        return NO;
    }
    return YES;
}

#pragma mark - 私有方法

//重置倒计时
- (void)resetCountDown
{
    self.validCodeTimeModel.intervalSeconds = 0;
    [self cacheToDisk];
}

- (void)initDataFromDiskCache
{
    BMValidCodeTimeModel *validCodeTimeModel = [[TMCache sharedCache] objectForKey:@"BMValidCodeTimeModelKey"];
    if (validCodeTimeModel) {
        self.validCodeTimeModel = validCodeTimeModel;
    }
    NSLog(@"从本地缓存获取validCodeTimeModel:%@",self.validCodeTimeModel);
}

#pragma mark - Setter and Getter

- (BMValidCodeTimeModel *)validCodeTimeModel
{
    if (_validCodeTimeModel == nil) {
        _validCodeTimeModel = [[BMValidCodeTimeModel alloc] init];
        _validCodeTimeModel.intervalSeconds = BMDefaultIntervalSeconds;
    }
    return _validCodeTimeModel;
}

@end
