//
//  FPView.h
//  FuckPhotoshop
//
//  Created by James Womack on 2/27/13.
//  Copyright (c) 2013 James Womack. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FPDynamicBlock)(void);

@interface FPView : UIView

extern void FPDynamic(NSObject *a, NSObject *b, FPDynamicBlock block);
extern void FPVisualDynamic(FPView *self, NSObject *a, NSObject *b);

- (id)initWithTopColor:(UIColor *)topColor bottomColor:(UIColor *)bottomColor radial:(BOOL)radial noiseOpacity:(CGFloat)noiseOpacity frame:(CGRect)frame;

@property (assign, readwrite) UIColor *topColor;
@property (assign, readwrite) UIColor *bottomColor;
@property BOOL radial;
@property CGFloat noiseOpacity;

@end
