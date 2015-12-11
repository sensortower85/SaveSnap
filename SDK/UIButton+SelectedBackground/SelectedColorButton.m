//
//  SelectedColorButton.m
//  SaveSnap
//
//  Created by heliumsoft on 12/30/14.
//  Copyright (c) 2014 quantum. All rights reserved.
//

#import "SelectedColorButton.h"

@implementation SelectedColorButton

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder: aDecoder]))
    {
        [self setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:203/255.0f green:204/255.0f blue:208/255.0f alpha:1.0f]] forState:UIControlStateSelected];
    }
    
    return self;
}

@end
