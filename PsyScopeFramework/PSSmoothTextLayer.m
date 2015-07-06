//
//  PSSmoothTextLayer.m
//  PsyScopeEditor
//
//  Created by James on 04/02/2015.
//

#import "PSSmoothTextLayer.h"

@implementation PSSmoothTextLayer



-(void) drawInContext:(CGContextRef)ctx {
    self.shadowRadius = 0.1;
    self.shadowOffset = CGSizeMake(0, 0);
    CGContextSaveGState(ctx);
    CGContextSetFillColorWithColor(ctx, [self backgroundColor]);
    CGContextFillRect(ctx, [self bounds]);
    CGContextSetAllowsAntialiasing(ctx, true);
    CGContextSetShouldAntialias(ctx, true);
    CGContextSetShouldSmoothFonts(ctx, true);
    CGContextSetAllowsFontSubpixelPositioning(ctx, true);
    CGContextSetAllowsFontSubpixelQuantization(ctx, true);
    CGContextSetShadowWithColor(ctx, CGSizeZero, 0.f, self.foregroundColor);

    [super drawInContext:ctx];
    CGContextRestoreGState(ctx);
}
@end
