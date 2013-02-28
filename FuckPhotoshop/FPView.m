//
//  FPView.m
//  FuckPhotoshop
//
//  Created by James Womack on 2/27/13.
//  Copyright (c) 2013 James Womack. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "FPView.h"


@interface FPView ()
@property BOOL wasLandscapeAfterLastDetectedOrientationChange;
@end


@implementation FPView


- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self initialization];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self initialization];
    }
    return self;
}


- (void)initialization
{
    [UIDevice.currentDevice beginGeneratingDeviceOrientationNotifications];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object:nil];

#if FP_VISUAL_DEBUG == true
    self.layer.borderWidth = 3.f;
    self.layer.borderColor = UIColor.redColor.CGColor;
#endif
}


- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    UIDeviceOrientation orientation = UIDevice.currentDevice.orientation;

    if (self.wasLandscapeAfterLastDetectedOrientationChange != orientation)
    {
        [self setNeedsDisplay];
    }
    
    self.wasLandscapeAfterLastDetectedOrientationChange = orientation;
}


- (void)drawGradientWithColors:(CGFloat*)colors locations:(CGFloat*)locations count:(size_t)count radial:(BOOL)radial
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
    CGMutablePathRef pRect = CGPathCreateMutable();
    
    CGPathAddRect(pRect, NULL, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
        
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, count);
    
    CGColorSpaceRelease(colorSpace), colorSpace = NULL;
    
    CGContextAddPath(context, pRect);
    
    CGContextSaveGState(context);
    
    CGContextClip(context);
        
    if (radial)
    {
        CGContextDrawRadialGradient(context,
                                    gradient,
                                    self.center,
                                    0.f,
                                    CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2),
                                    self.bounds.size.width,
                                    kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation
                                    );
    }
    else
    {
        CGContextDrawLinearGradient(context, gradient, CGPointMake(0,self.bounds.size.height/2), CGPointMake(self.bounds.size.width,self.bounds.size.height/2), kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    }
    
    CGGradientRelease(gradient);
    
    gradient = NULL;
    
    CGContextRestoreGState(context);
    
    CGPathRelease(pRect);
    
    CGContextRestoreGState(context);
}


- (void)drawRect:(CGRect)rect
{        
    CGFloat colorList[] =
    {
        0, 0, 0 , .5,
        0, 0, 0 , 0
    };
    
    size_t locationCount = 2;
    
    [self drawGradientWithColors:colorList locations:NULL count:locationCount radial:NO];
    
    [super drawRect:rect];
}


- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [UIDevice.currentDevice endGeneratingDeviceOrientationNotifications];
}


@end
