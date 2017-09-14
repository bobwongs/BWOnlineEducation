//
//  BMImageModel.m
//  BMWash
//
//  Created by elvin on 2016/10/19.
//  Copyright © 2016年 月亮小屋（中国）有限公司. All rights reserved.
//

#import "BMImageModel.h"

@implementation BMImageModel

- (void)setHeight:(CGFloat)height {

    _height = height;
    if (_height == 0.0) {
        _width  = 1.0;
        _height = 1.0;
    }
}

- (void)setWidth:(CGFloat)width {
    
    _width = width;
    if (_width == 0.0) {
        _width  = 1.0;
        _height = 1.0;
    }
}

@end