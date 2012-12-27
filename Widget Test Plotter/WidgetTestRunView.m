//
//  WidgetTestRunView.m
//  Widget Test Plotter
//
//  Created by CP120 on 10/31/12.
//  Copyright (c) 2012 Hal Mueller. All rights reserved.
//

#import "WidgetTestRunView.h"
#import "WidgetTester.h"
#import "WidgetTestObservationPoint.h"
#import "KeyStrings.h"

@implementation WidgetTestRunView

- (id)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
		NSTrackingArea *ta = [[NSTrackingArea alloc] initWithRect:NSZeroRect
						options:(NSTrackingMouseEnteredAndExited
						| NSTrackingMouseMoved
					    | NSTrackingActiveAlways
				        | NSTrackingInVisibleRect)
						owner:self userInfo:nil];
		[self addTrackingArea:ta];
		[ta release];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	NSRect bounds = [self bounds];
	self.drawingCount++;
	MyLog(@"drawRect: count %ld bounds %@", self.drawingCount, NSStringFromRect(bounds));
	
	NSBezierPath *pointsPath = [NSBezierPath bezierPath];
	double xOffset = self.widgetTester.timeMinimum;
	double yOffset = self.widgetTester.sensorMinimum;
	double xRange = self.widgetTester.timeMaximum - self.widgetTester.timeMinimum;
	double yRange = self.widgetTester.sensorMaximum - self.widgetTester.sensorMinimum;
	
	NSPoint xAxisStart = bounds.origin;
	NSPoint xAxisEnd = bounds.origin;
	xAxisEnd.x += bounds.size.width;
	
	NSUInteger drawingStyleNumber = [[NSUserDefaults standardUserDefaults] integerForKey:drawingStyleKey];
	
	[pointsPath moveToPoint:xAxisStart];
	for (WidgetTestObservationPoint *observation in self.widgetTester.testData) {
		NSPoint projectedPoint;
        projectedPoint.x = (observation.observationTime - xOffset)/xRange * bounds.size.width;
		projectedPoint.y = (observation.voltage - yOffset)/yRange * bounds.size.height;
		
		[pointsPath lineToPoint:projectedPoint];
	}
	[pointsPath lineToPoint:xAxisEnd];
	[pointsPath closePath];
	
	switch (drawingStyleNumber) {
		case 0:
			[[NSColor greenColor] set];
			[NSBezierPath fillRect:bounds];
			
			[[NSColor grayColor] set];
			[pointsPath fill];
			break;
		case 1:
			[[NSColor redColor] set];
			[NSBezierPath fillRect:bounds];
			
			[pointsPath setLineWidth:5.0];
			[[NSColor blueColor] set];
			[pointsPath stroke];
			break;
		case 2:
			[[NSColor purpleColor] set];
			[NSBezierPath fillRect:bounds];
			
			[[NSColor greenColor] set];
			[pointsPath fill];
			CGFloat dashingArray[2];
			dashingArray[0] = 8.0;
			dashingArray[1] = 6.0;
			
			[pointsPath setLineDash: dashingArray count: 2 phase: 0.0];
			[pointsPath setLineWidth:2.0];
			[[NSColor blueColor] set];
			[pointsPath stroke];
			break;
	}
	if (self.shouldDrawMouseInfo) {
		NSDictionary *stringAttributes = nil;
		
		if(self.shiftKeyPressed) {
			stringAttributes =
			[NSDictionary dictionaryWithObjectsAndKeys:[NSColor blackColor],
			 NSForegroundColorAttributeName,
			 [NSColor colorWithDeviceWhite:0.8 alpha:0.5], NSBackgroundColorAttributeName,
			 [NSFont fontWithName:@"Verdana-Italic" size:14.], NSFontAttributeName,
			 nil];
		}
		else if(self.ctrlKeyPressed) {
			stringAttributes =
			[NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor],
			 NSForegroundColorAttributeName,
			 [NSColor colorWithDeviceWhite:0.8 alpha:0.5], NSBackgroundColorAttributeName,
			 [NSFont fontWithName:@"Impact-Italic" size:11.], NSFontAttributeName,
			 nil];
		}
		else {
			stringAttributes =
			[NSDictionary dictionaryWithObjectsAndKeys:[NSColor blackColor],
			 NSForegroundColorAttributeName,
			 [NSColor colorWithDeviceWhite:0.8 alpha:0.5], NSBackgroundColorAttributeName,
			 [NSFont fontWithName:@"Verdana" size:14.], NSFontAttributeName,
			 nil];
		}
		
		NSPoint mousePositionDataCoordinates;
		mousePositionDataCoordinates.x = self.mousePositionViewCoordinates.x / bounds.size.width
			* xRange + xOffset;
		mousePositionDataCoordinates.y = self.mousePositionViewCoordinates.y / bounds.size.height
			* yRange + yOffset;
		NSString *mouseMessage = [NSString stringWithFormat:@"View:(%4.0f,%4.0f) Data: (%4.1f, %4.1f)",
								  self.mousePositionViewCoordinates.x, self.mousePositionViewCoordinates.y,
								  mousePositionDataCoordinates.x, mousePositionDataCoordinates.y];
		MyLog(@"%@", mouseMessage);
		NSAttributedString *mouseInfo = [[[NSAttributedString alloc]
										  initWithString:mouseMessage
										  attributes:stringAttributes] autorelease];
		NSPoint drawPoint = self.mousePositionViewCoordinates;
		NSSize stringSize = mouseInfo.size;
		if((drawPoint.x + stringSize.width) >= bounds.size.width) {
			self.mouseTxtFlipLeft = YES;
		}
		else if(self.mouseTxtFlipLeft && (drawPoint.x - stringSize.width) <= 0) {
			self.mouseTxtFlipLeft = NO;
		}
		
		if((drawPoint.y + stringSize.height) >= bounds.size.height) {
			self.mouseTxtFlipBottom = YES;
		}
		else if(self.mouseTxtFlipBottom && (drawPoint.y - stringSize.height) <= 0) {
			self.mouseTxtFlipBottom = NO;
		}
		
		if(self.mouseTxtFlipLeft) {
			drawPoint.x -= stringSize.width;
		}
		
		if(self.mouseTxtFlipBottom) {
			drawPoint.y -= stringSize.height;
		}
		
		[mouseInfo drawAtPoint:drawPoint];
	}
}

#pragma mark -
#pragma mark mouse events
- (void)mouseMoved:(NSEvent *)theEvent
{
	NSLog(@"mouseMoved: %@", NSStringFromPoint(theEvent.locationInWindow));
	
	self.shouldDrawMouseInfo = YES;
	self.mousePositionViewCoordinates = [self convertPoint:theEvent.locationInWindow fromView:nil];
	[self setNeedsDisplay:YES];
	
	if(theEvent.modifierFlags & NSShiftKeyMask) {
		self.shiftKeyPressed = YES;
	}
	else {
		self.shiftKeyPressed = NO;
	}
	
	if(theEvent.modifierFlags & NSControlKeyMask) {
		self.ctrlKeyPressed = YES;
	}
	else {
		self.ctrlKeyPressed = NO;
	}
}
- (void)mouseEntered:(NSEvent *)theEvent
{
	NSLog(@"mouseEntered: %@", NSStringFromPoint(theEvent.locationInWindow));
	if(theEvent.modifierFlags & NSShiftKeyMask) {
		self.shouldDrawMouseInfo = YES;
		self.mousePositionViewCoordinates = [self convertPoint:theEvent.locationInWindow fromView:nil];
		[self setNeedsDisplay:YES];
	}
	else {
		self.shouldDrawMouseInfo = NO;
	}
}
- (void)mouseExited:(NSEvent *)theEvent
{
	NSLog(@"mouseExited: %@", NSStringFromPoint(theEvent.locationInWindow));
	self.shouldDrawMouseInfo = NO;
	self.mousePositionViewCoordinates = [self convertPoint:theEvent.locationInWindow fromView:nil];
	[self setNeedsDisplay:YES];
}

@end
