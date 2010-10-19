//
//  AbstractCamera.m
//  svgParser
//
//  Created by Skeeet on 11/14/09.
//  Copyright 2009 Munky Interactive / munkyinteractive.com. All rights reserved.
//

#import "AbstractCamera.h"


@implementation AbstractCamera

@synthesize cameraPosition,zoom, maxZoom, minZoom, ptmRatio;

- (id) init
{
	self = [super init];
	if (self != nil) 
	{
		cameraPosition = CGPointZero;
		zoom = 1.0f;
		minZoom = 0.1;
		maxZoom = 10;
		ptmRatio = 10.0f;  //1 phy unit = 10 screen pixels by default
		originalPtmRatio = ptmRatio;
		
		storedTouches = [[NSMutableArray alloc] initWithCapacity:3];
	}
	return self;
}

- (void) dealloc
{
	[storedTouches release];
	[super dealloc];
}

-(void) eventBegan:(NSSet *) touches
{
	for( UITouch *touch in touches )[storedTouches addObject:touch];
	
//	if([touches count]==1) // do move
//	{
//		for( UITouch *touch in touches ) 
//		{
//			CGPoint location = [touch locationInView: [touch view]];
//			location = [[Director sharedDirector] convertToGL: location];
//		}
//	}
	//CCLOG(@"Began. Touch count: %d", [storedTouches count]);
}

-(void) eventMoved:(NSSet *) touches
{	
	CGPoint delta = CGPointZero;
	for (unsigned int i=0; i<[storedTouches count]; i++) 
	{
		UITouch * touch = [storedTouches objectAtIndex:i];
		CGPoint location = [touch locationInView: [touch view]];
		location = [[Director sharedDirector] convertToGL: location];
		
		CGPoint oldlocation = [touch previousLocationInView: [touch view]];
		oldlocation = [[Director sharedDirector] convertToGL: oldlocation];
		
		//delta = ccpSub(location, oldTouchLocation);
		CGPoint curDelta = ccpSub(location, oldlocation);
		delta = ccpAdd(delta,curDelta);
	}
	delta = ccpMult(delta, 1.0f/[storedTouches count]);
	
	cameraPosition = ccpAdd(delta, cameraPosition);
	
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
	//CCLOG(@"Moved. Touch count: %d", [storedTouches count]);
}
-(void) eventEnded:(NSSet *) touches
{
	
	for( UITouch *touch in touches )[storedTouches removeObject:touch];
	
	
	//CCLOG(@"Ended. Touch count: %d", [storedTouches count]);
}
-(void) updateFollowPosition
{
}

-(void) updateSpriteFromBody:(b2Body*) body
{
	if (body->GetUserData() != NULL) 
	{
		BodyInfo *bi = (BodyInfo*)body->GetUserData();
		if(bi.data)
		{
			AtlasSprite* actor = (AtlasSprite*)bi.data;
			
			//get position in physycs coords
			actor.position = CGPointMake( body->GetPosition().x , body->GetPosition().y);
			actor.position = ccpSub(actor.position, bi.spriteOffset);
			//map it to scren coords using PTM ratio
			actor.position = ccpMult(actor.position, ptmRatio);
			
			//add camera shift
			actor.position = ccpAdd(actor.position,cameraPosition);
			
			actor.rotation = -1 * CC_RADIANS_TO_DEGREES(body->GetAngle());
			actor.scale = 1.0f * zoom;
		}
	}
}

-(void) ZoomTo:(float)newZoom
{
	if(newZoom<minZoom)		newZoom = minZoom;
	else if(newZoom>maxZoom)	newZoom= maxZoom;
	else zoom = newZoom;
	
	ptmRatio = zoom * originalPtmRatio;
}

-(void) ZoomToObject:(b2Body*) body screenPart:(float) part
{
	if(!body) return;
	b2World * world = body->GetWorld();
	b2AABB aabb = world->GetAABBForBody(body);
	
	float w = aabb.lowerBound.x-aabb.upperBound.x;
	float h = aabb.lowerBound.y-aabb.upperBound.y;
	
	//object aabb diagonal in phy coords
	float length = sqrt(w*w+h*h);
	//converting to screen space
	length*=ptmRatio;
	
	//must be 1/10 in screen coords
	float scrLength = sqrt(480*480 + 320*320);
	
	float scaleFactor = scrLength/length*part;
	
	[self ZoomTo:scaleFactor];
}

-(b2Vec2) b2vPosition
{
	return b2Vec2(cameraPosition.x / ptmRatio, cameraPosition.y / ptmRatio);
}
@end
