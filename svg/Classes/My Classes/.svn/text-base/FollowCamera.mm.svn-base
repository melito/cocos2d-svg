//
//  FollowCamera.m
//  svgParser
//
//  Created by Skeeet on 11/14/09.
//  Copyright 2009 Munky Interactive / munkyinteractive.com. All rights reserved.
//

#import "FollowCamera.h"

#define RETURN_FRAMES 30

@implementation FollowCamera

@synthesize objectToFollow;


-(void) follow:(b2Body*) body
{
	storedObjectToFollow = NULL;
	objectToFollow = body;
	isReturningToObject = YES;

}
-(void) eventBegan:(NSSet *) touches
{
	[super eventBegan:touches];
	isReturningToObject = NO;
	
}
-(void) eventMoved:(NSSet *) touches
{	
	if([storedTouches count]==1)
	{
		UITouch * touch = [storedTouches objectAtIndex:0];
		CGPoint location = [touch locationInView: [touch view]];
		location = [[Director sharedDirector] convertToGL: location];
		CGPoint oldlocation = [touch previousLocationInView: [touch view]];
		oldlocation = [[Director sharedDirector] convertToGL: oldlocation];
		
		CGPoint curDelta = ccpSub(location, oldlocation);
		cameraPosition = ccpAdd(curDelta, cameraPosition);
	}
	
	if([storedTouches count]==2) // do zoom
	{
		UITouch * touch1 = [storedTouches objectAtIndex:0];
		CGPoint location1 = [touch1 locationInView: [touch1 view]];
		location1 = [[Director sharedDirector] convertToGL: location1];
		
		UITouch * touch2 = [storedTouches objectAtIndex:1];
		CGPoint location2 = [touch2 locationInView: [touch2 view]];
		location2 = [[Director sharedDirector] convertToGL: location2];
		
		float touchDistance = ccpDistance(location1, location2);
		
		if(touchDistance > oldTouchZoomDistance) // zoom +
		{
			[self ZoomTo:zoom + zoom/50];
		}
		else if(touchDistance < oldTouchZoomDistance) //zoom -
		{
			[self ZoomTo:zoom - zoom/50];
		}
		
		oldTouchZoomDistance = touchDistance;		
	}
	
	//[self updateFollowPosition];
	//CCLOG(@"Moved. Touch count: %d", [storedTouches count]);
}
-(void) eventEnded:(NSSet *) touches
{
	[super eventEnded:touches];
	
	if([storedTouches count]==0) 
	{
		isReturningToObject = YES;
	}
}

-(void) updateFollowPosition
{
	if(objectToFollow)
	{
		//pos in phy coords
		CGPoint objPosition = CGPointMake(-objectToFollow->GetPosition().x, -objectToFollow->GetPosition().y);
		
		//convert to screen coords
		objPosition = ccpMult(objPosition, ptmRatio);
		
		//add center of scren shift
		
		objPosition = ccpAdd(objPosition, CGPointMake(240, 160));
		

		CGPoint returnDelta = ccpSub(objPosition,cameraPosition);
		float deltaLength= ccpLength(returnDelta);
		if(deltaLength>0.5f)
		{
			returnDelta = ccpNormalize(returnDelta);
			returnDelta = ccpMult(returnDelta, deltaLength/10);
			cameraPosition = ccpAdd(cameraPosition, returnDelta);
		}
	}
}


@end
