//
//  WidgetTestRunView.h
//  Widget Test Plotter
//
//  Created by CP120 on 10/31/12.
//  Copyright (c) 2012 Hal Mueller. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WidgetTester;
@interface WidgetTestRunView : NSView

@property (retain) WidgetTester *widgetTester;
@property (nonatomic) NSUInteger drawingCount;
@property BOOL shouldDrawMouseInfo;
@property BOOL shiftKeyPressed;
@property BOOL ctrlKeyPressed;
@property BOOL mouseTxtFlipLeft;
@property BOOL mouseTxtFlipBottom;
@property NSPoint mousePositionViewCoordinates;

@end
