//
//  BPProgressView.m
//  Transmission-iOS
//
//  Created by Brian Partridge on 3/3/13.
//  Copyright (c) 2013 Brian Partridge. All rights reserved.
//

#import "BPProgressView.h"

@implementation BPProgressView

- (void)setProgressColor:(UIColor *)progressColor {
    _progressColor = progressColor;
    [self setNeedsDisplay];
}

- (void)setTrackColor:(UIColor *)trackColor {
    _trackColor = trackColor;
    [self setNeedsDisplay];
}

- (void)setProgress:(CGFloat)progress {
    _progress = MIN(1.0, MAX(0.0, progress));
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self setNeedsDisplay];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    [UIView animateWithDuration:0.25 animations:^{
        self.progress = progress;
    }];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _progressColor = [UIColor blueColor];
        _trackColor = [UIColor lightGrayColor];
        _progress = 0.5;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGRect leftRect, rightRect;
    CGRectDivide(self.bounds, &leftRect, &rightRect, self.progress * self.bounds.size.width, CGRectMinXEdge);

    [self.progressColor setFill];
    CGContextFillRect(context, leftRect);

    [self.trackColor setFill];
    CGContextFillRect(context, rightRect);
}


@end
