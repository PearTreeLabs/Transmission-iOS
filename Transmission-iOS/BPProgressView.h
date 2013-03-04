//
//  BPProgressView.h
//  Transmission-iOS
//
//  Created by Brian Partridge on 3/3/13.
//  Copyright (c) 2013 Brian Partridge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BPProgressView : UIView

@property (nonatomic, strong) UIColor *progressColor;
@property (nonatomic, strong) UIColor *trackColor;
@property (nonatomic, assign) CGFloat progress;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
