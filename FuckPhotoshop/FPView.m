//
//  FPView.m
//  FuckPhotoshop
//
//  Created by James Womack on 2/27/13.
//  Copyright (c) 2013 James Womack. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FPView.h"
#import "UANoisyGradientLayer.h"
#import "FPTypes.h"


@interface FPView ()
{
    UIColor *_topColor, *_bottomColor;
}
@property BOOL wasLandscapeAfterLastDetectedOrientationChange;
@end



@implementation FPView

@dynamic topColor, bottomColor;


void FPDynamic(NSObject *a, NSObject *b, FPDynamicBlock block)
{
    if (![a isEqual:b])
    {
        a = b;
        block();
    }
}


void FPVisualDynamic(FPView *self, NSObject *a, NSObject *b)
{
    FPDynamic(a, b, ^{
        [self setNeedsDisplay];
    });
}


- (void)setTopColor:(UIColor *)topColor
{
    FPVisualDynamic(self, _topColor, topColor);
}


- (void)setBottomColor:(UIColor *)bottomColor
{
    FPVisualDynamic(self, _bottomColor, bottomColor);
}


- (UIColor *)bottomColor
{
    if (!_bottomColor)
    {
        _bottomColor = UIColor.blackColor;
    }
    return _bottomColor;
}


- (UIColor *)topColor
{
    if (!_topColor)
    {
        _topColor = UIColor.grayColor;
    }
    return _topColor;
}


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
    
    ((UANoisyGradientLayer*)self.layer).noiseOpacity = .2f;

#if FP_VISUAL_DEBUG == true
    self.layer.borderWidth = 3.f;
    self.layer.borderColor = UIColor.redColor.CGColor;
#endif
}


+ (Class)layerClass
{
    return UANoisyGradientLayer.class;
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


- (FPGradient)gradientFromTopColor:(UIColor *)topColor bottomColor:(UIColor *)bottomColor
{
    FPGradient gradient;
    [topColor getRed:&gradient.red0 green:&gradient.green0 blue:&gradient.blue0 alpha:&gradient.alpha0];
    [bottomColor getRed:&gradient.red1 green:&gradient.green1 blue:&gradient.blue1 alpha:&gradient.alpha1];
    return gradient;
}


- (void)drawRect:(CGRect)rect
{        
    size_t locationCount = 2;
    
    FPGradient gradient = [self gradientFromTopColor:self.topColor bottomColor:self.bottomColor];
    
    FPColorList colorList =
    {
        gradient.red0,
        gradient.green0,
        gradient.blue0,
        gradient.alpha0,
        gradient.red1,
        gradient.green1,
        gradient.blue1,
        gradient.alpha1
    };
    
    uint i = 8;
    while (i--)
    {
        malloc(colorList[i]);
    }
    
    [self drawGradientWithColors:colorList locations:NULL count:locationCount radial:NO];
    
    [super drawRect:rect];
}


- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [UIDevice.currentDevice endGeneratingDeviceOrientationNotifications];
}


@end
