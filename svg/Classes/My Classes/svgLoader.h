//
//  svgLoader.h
//  svgParser
//
//  Created by Skeeet on 10/20/09.
//  Copyright 2009 Munky Interactive / munkyinteractive.com. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "JointDeclaration.h"
#import "TouchXML.h"
#import "GrahamScanConvexHull.h"
#include <vector>
#import "SpriteManager.h"



@interface svgLoader : NSObject 
{
	b2World* world;
	b2Body* staticBody;
	NSMutableSet * delayedJoints;
	NSMutableDictionary * addedObjects;
	
	float worldWidth;
	float worldHeight;
	float scaleFactor; // used for debug rendering and physycs creation from svg only
}
@property 	float scaleFactor; 

-(id) initWithWorld:(b2World*) world andStaticBody:(b2Body*) staticBody;

-(void) parseFile:(NSString*)filename;
-(void) initGroups:(NSArray *) shapes;
-(void) initRectangles:(NSArray *) shapes;
-(void) initShapes:(NSArray *) shapes;
-(b2Body*) getBodyByName:(NSString*) bodyName;
-(void) initJoints;
-(void) assignSpritesFromManager:(SpriteManager*)manager;
-(void) doCleanupShapes;

@end
