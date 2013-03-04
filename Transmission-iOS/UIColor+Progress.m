//
//  UIColor+Progress.m
//  Transmission-iOS
//
//  Created by Brian Partridge on 3/3/13.
//  Copyright (c) 2013 Brian Partridge. All rights reserved.
//

#import "UIColor+Progress.h"

@implementation UIColor (Progress)

+ (UIColor *) progressWhiteColor
{
    return [[self class] colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
}

+ (UIColor *) progressGrayColor
{
    return [[self class] colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
}

+ (UIColor *) progressLightGrayColor
{
    return [[self class] colorWithRed:0.87 green:0.87 blue:0.87 alpha:1.0];
}

+ (UIColor *) progressBlueColor
{
    return [[self class] colorWithRed:0.35 green:0.67 blue:0.98 alpha:1.0];
}

+ (UIColor *) progressDarkBlueColor
{
    return [[self class] colorWithRed:0.616 green:0.722 blue:0.776 alpha:1.0];
}

+ (UIColor *) progressGreenColor
{
    return [[self class] colorWithRed:0.44 green:0.89 blue:0.40 alpha:1.0];
}

+ (UIColor *) progressLightGreenColor
{
    return [[self class] colorWithRed:0.62 green:0.99 blue:0.58 alpha:1.0];
}

+ (UIColor *) progressDarkGreenColor
{
    return [[self class] colorWithRed:0.627 green:0.714 blue:0.639 alpha:1.0];
}

+ (UIColor *) progressRedColor
{
    return [[self class] colorWithRed:0.902 green:0.439 blue:0.451 alpha:1.0];
}

+ (UIColor *) progressYellowColor
{
    return [[self class] colorWithRed:0.933 green:0.890 blue:0.243 alpha:1.0];
}

@end
