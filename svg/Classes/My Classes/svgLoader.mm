//
//  svgLoader.m
//  svgParser
//
//  Created by Skeeet on 10/20/09.
//  Copyright 2009 Munky Interactive / munkyinteractive.com. All rights reserved.
//

#import "svgLoader.h"
#import "Box2D.h"
#import "BodyInfo.h"


@implementation svgLoader
@synthesize scaleFactor;

-(id) initWithWorld:(b2World*) w andStaticBody:(b2Body*) sb;
{
	self = [super init];
	if (self != nil) 
	{
		world = w;
		staticBody = sb;
		delayedJoints = [[NSMutableSet alloc] initWithCapacity:10];
		addedObjects = [[NSMutableDictionary alloc] initWithCapacity:10];
		scaleFactor = 10.0f;
	}
	return self;
}

- (void) dealloc
{
	[delayedJoints release];
	[addedObjects release];
	[super dealloc];
}


-(void) parseFile:(NSString*)filename;
{
	//NSString *filePath = [[NSBundle mainBundle] pathForResource:@"drawing.svg" ofType:nil];  
	NSData *data = [NSData dataWithContentsOfFile:filename]; 
	CXMLDocument *svgDocument  = [[[CXMLDocument alloc] initWithData:data options:0 error:nil] autorelease];

	//get world space dimensions
	if([[svgDocument rootElement] attributeForName:@"width"])
	{
		worldWidth = [[[[svgDocument rootElement] attributeForName:@"width"] stringValue] floatValue] / scaleFactor;
	}
	else
	{
		worldWidth = 100.0f;
	}
	if([[svgDocument rootElement] attributeForName:@"height"])
	{
		worldHeight = [[[[svgDocument rootElement] attributeForName:@"height"] stringValue] floatValue] / scaleFactor;
	}
	else
	{
		worldHeight = 100.0f;
	}
	
    NSArray *layers = NULL;
	
    // root groups are layers for geometry
    layers = [[svgDocument rootElement] elementsForName:@"g"];
	for (CXMLElement * curLayer in layers) 
	{
		//layers with "ignore" attribute not loading
		if([curLayer attributeForName:@"ignore"])
		{
			CCLOG(@"SvgLoader: layer ignored: %@",[[curLayer attributeForName:@"id"] stringValue]);
			continue;
		}
		CCLOG(@"SvgLoader: loading layer: %@",[[curLayer attributeForName:@"id"] stringValue]);
		//add boxes first
		NSArray *rects = [curLayer elementsForName:@"rect"];
		[self initRectangles:rects];
		
		NSArray *nonrectangles = [curLayer elementsForName:@"path"];
		[self initShapes:nonrectangles];
		
		NSArray *groups = [curLayer elementsForName:@"g"];
		[self initGroups:groups];
		
		[self initJoints];
		CCLOG(@"SvgLoader: layer loaded: %@",[[curLayer attributeForName:@"id"] stringValue]);
	}
}

-(void) initGroups:(NSArray *) shapes
{
	for(CXMLElement * curGroup in shapes)
	{
		NSArray *rects = [curGroup elementsForName:@"rect"];
		b2BodyDef bodyDef;
		CGPoint bodyPos = CGPointZero;
		
		int activeCount=0;
		float minX = FLT_MAX ,maxX = FLT_MIN ,minY = FLT_MAX, maxY = FLT_MIN;
		
		
		for (CXMLElement * curShape in rects) 
		{
			NSString * x = [[curShape attributeForName:@"x"] stringValue];
			NSString * y = [[curShape attributeForName:@"y"] stringValue];
			NSString * height = [[curShape attributeForName:@"height"] stringValue];
			NSString * width = [[curShape attributeForName:@"width"] stringValue];
			if(!x || !y || !height || !width) continue;
			
			float fx = [x floatValue] / scaleFactor;
			float fy = [y floatValue] / scaleFactor;
			float fWidth = [width floatValue] / scaleFactor;
			float fHeight = [height floatValue] / scaleFactor;
			fy = worldHeight - (fy + fHeight * .5f);
			
			bodyPos.x = bodyPos.x + fx;
			bodyPos.y = bodyPos.y + fy;
			
			float t = fx-fWidth/2.0f;
			if(minX >t) minX = t; 
			
			t = fx+fWidth/2.0f;
			if(maxX < t) maxX = t; 
			
			t = fy-fHeight/2.0f;
			if(minY >t) minY = t; 
			
			t = fy+fHeight/2.0f;
			if(maxY < t) maxY = t; 
			
			activeCount++;
		}
//		bodyPos.x = bodyPos.x/ activeCount;
//		bodyPos.y = bodyPos.y/ activeCount;
		BodyInfo * bi = [[BodyInfo alloc] init];
		bi.name = [[curGroup attributeForName:@"id"] stringValue];
		bi.data = nil;
		bi.rect = CGSizeMake(maxX-minX, maxY-minY);
		bi.spriteName = [[curGroup attributeForName:@"sprite"] stringValue];
		bi.textureName = [[curGroup attributeForName:@"texture"] stringValue];
		bodyPos.x = minX + bi.rect.width;
		bodyPos.y = maxY - bi.rect.height/2.0f;
		
		bodyDef.position.Set(bodyPos.x, bodyPos.y);
		b2Body *body = world->CreateBody(&bodyDef);
	
		

		body->SetUserData(bi);
		
		CCLOG(@"SvgLoader: Composite body created name=%@ x=%f,y=%f   rect = (%f ; %f)",bi.name, bodyPos.x, bodyPos.y,bi.rect.width,bi.rect.height);
		
		for (CXMLElement * curShape in rects) 
		{
			NSString * width = [[curShape attributeForName:@"width"] stringValue];
			NSString * height = [[curShape attributeForName:@"height"] stringValue]; 
			NSString * x = [[curShape attributeForName:@"x"] stringValue];
			NSString * y = [[curShape attributeForName:@"y"] stringValue];
			NSString * density = [[curShape attributeForName:@"phy_density"] stringValue];
			NSString * friction = [[curShape attributeForName:@"phy_friction"] stringValue];
			NSString * restitution = [[curShape attributeForName:@"phy_restitution"] stringValue]; 
			
			
			if(!x || !y || !width || !height) continue;
			
			//CCLOG(@"SvgLoader: loading shape: %@",name);
			float fx = [x floatValue] / scaleFactor;
			float fy = [y floatValue] / scaleFactor;
			float fWidth = [width floatValue] / scaleFactor;
			float fHeight = [height floatValue] / scaleFactor;
			fx = fx + fWidth * .5f;
			fy = worldHeight - (fy + fHeight * .5f);
			
			if([curShape attributeForName:@"sprite"])
			{
				bi.spriteOffset = CGPointMake(fx - bodyPos.x, -(fy - bodyPos.y));
				bi.spriteName = [[curShape attributeForName:@"sprite"] stringValue];
				bi.textureName = [[curShape attributeForName:@"texture"] stringValue];
			}
			
			if([curShape attributeForName:@"isCircle"])
			{
				//float r = sqrt((fWidth/2)*(fWidth/2) + (fHeight/2)*(fHeight/2));;
				float r = fWidth/2;
				
				b2CircleShape circle;
				circle.m_radius = r;
				circle.m_p = b2Vec2(fx - bodyPos.x,fy - bodyPos.y);
				
				b2FixtureDef fixtureDef;
				fixtureDef.shape = &circle;	
				
				
				if(density)	fixtureDef.density =[density floatValue];
				else fixtureDef.density = 0.0f;
				
				if(friction) fixtureDef.friction =[friction floatValue];
				else fixtureDef.friction = 0.5f;
				
				body->CreateFixture(&fixtureDef);
				CCLOG(@"SvgLoader: \tLoaded circle. x=%f,y=%f r=%f, density=%f, friction = %f", fx, fy, r,fixtureDef.density,fixtureDef.friction);
				
			}
			else
			{				
				b2PolygonShape dynamicBox;
				dynamicBox.SetAsBox(fWidth * .5f,
									fHeight * .5f,
									b2Vec2(fx - bodyPos.x ,fy - bodyPos.y),
									0.0f);
				
				
				// Define the dynamic body fixture.
				b2FixtureDef fixtureDef;
				fixtureDef.shape = &dynamicBox;
				
				if(density)	fixtureDef.density =[density floatValue];
				else fixtureDef.density = 0.0f;
				
				if(friction) fixtureDef.friction =[friction floatValue];
				else fixtureDef.friction = 0.5f;
				
				if(restitution) fixtureDef.restitution =[restitution floatValue];
				
				//fixtureDef.density = 0.0f;
				//fixtureDef.density = 0.1f;
				body->CreateFixture(&fixtureDef);
				CCLOG(@"SvgLoader: \tLoaded rectangle. w=%f h=%f at %f,%f  friction = %f, density = %f", fWidth,fHeight,fx,fy, fixtureDef.friction, fixtureDef.density);
			}
		}	
		
	}	
}

-(void) initRectangles:(NSArray *) shapes
{
	for (CXMLElement * curShape in shapes) 
	{
		NSString * width = [[curShape attributeForName:@"width"] stringValue];
		NSString * height = [[curShape attributeForName:@"height"] stringValue];
		NSString * x = [[curShape attributeForName:@"x"] stringValue];
		NSString * y = [[curShape attributeForName:@"y"] stringValue];
		NSString * density = [[curShape attributeForName:@"phy_density"] stringValue];
		NSString * friction = [[curShape attributeForName:@"phy_friction"] stringValue];
		NSString * restitution = [[curShape attributeForName:@"phy_restitution"] stringValue];
		NSString * name = [[curShape attributeForName:@"id"] stringValue];
		
		
		if(!x || !y) continue;
		if(!width || !height) continue;
		float fx = [x floatValue] / scaleFactor;
		float fy = [y floatValue] / scaleFactor;;
		float fWidth = [width floatValue] / scaleFactor;
		float fHeight = [height floatValue] / scaleFactor;

		
		
		
		if( [curShape attributeForName:@"isRevoluteJoint"]) //this is revolute joint
		{
			//CCLOG(@"------------%@",[curShape stringValue]);
			JointDeclaration * curJoint = [[JointDeclaration alloc] init];
			curJoint.point1 = CGPointMake(fx + fWidth/2, worldHeight - (fy + fHeight/2) );
			//curJoint.point1 = CGPointMake(fx, fy);
			
			curJoint.body1 = [[curShape attributeForName:@"body1"] stringValue];
			curJoint.body2 = [[curShape attributeForName:@"body2"] stringValue];
			
			curJoint.jointType = kRevoluteJoint;
			
			if([curShape attributeForName:@"motorEnabled"]) 
				curJoint.motorEnabled = YES;
			
			if([curShape attributeForName:@"motorSpeed"]) 
				curJoint.motorSpeed = [[[curShape attributeForName:@"motorSpeed"] stringValue] floatValue];
			
			if([curShape attributeForName:@"maxTorque"]) 
				curJoint.maxTorque = [[[curShape attributeForName:@"maxTorque"] stringValue] floatValue];			
			
			
			[delayedJoints addObject:curJoint];
			continue;
		}
		
		fx = fx + fWidth / 2;
		fy = worldHeight - (fy + fHeight / 2);
		
		//CCLOG(@"SvgLoader: loading shape: %@",name);

		
		BodyInfo * bi = [[BodyInfo alloc] init];
		bi.name = name;
		bi.spriteName = [[curShape attributeForName:@"sprite"] stringValue];
		bi.textureName = [[curShape attributeForName:@"texture"] stringValue];
		bi.data = nil;
		
		if([curShape attributeForName:@"isCircle"])
		{
			//float r = sqrt((fWidth/2)*(fWidth/2) + (fHeight/2)*(fHeight/2));;
			float r = fWidth/2;
			
			b2BodyDef bodyDef;
			bodyDef.position.Set(fx, fy);
			
			b2Body *body = world->CreateBody(&bodyDef);
			
			b2CircleShape circle;
			circle.m_radius = r;
			
			b2FixtureDef fixtureDef;
			fixtureDef.shape = &circle;	
			
			if(density)	fixtureDef.density =[density floatValue];
			else fixtureDef.density = 0.0f;
			
			if(friction) fixtureDef.friction =[friction floatValue];
			else fixtureDef.friction = 0.5f;
			if(restitution) fixtureDef.restitution =[restitution floatValue];
			//else fixtureDef.friction = 0.5f;
			
			body->CreateFixture(&fixtureDef);
			bi.rect = CGSizeMake(fWidth, fHeight);
			if(name) body->SetUserData(bi);
			CCLOG(@"SvgLoader: Loaded circle. name=%@ x=%f,y=%f r=%f, density=%f, friction = %f",name, fx, fy, r,fixtureDef.density,fixtureDef.friction);
		}
		else
		{
			
			b2BodyDef bodyDef;
			bodyDef.position.Set(fx, fy);
			
			//bodyDef.userData = sprite;
			b2Body *body = world->CreateBody(&bodyDef);
			
			// Define another box shape for our dynamic body.
			b2PolygonShape dynamicBox;
			dynamicBox.SetAsBox(fWidth * .5f, fHeight * .5f);//These are mid points for our 1m box
			
			
			// Define the dynamic body fixture.
			b2FixtureDef fixtureDef;
			fixtureDef.shape = &dynamicBox;	
			
			if(density)	fixtureDef.density =[density floatValue];
			else fixtureDef.density = 0.0f;
			
			if(friction) fixtureDef.friction =[friction floatValue];
			else fixtureDef.friction = 0.5f;
			
			if(restitution) fixtureDef.restitution =[restitution floatValue];
			
			//fixtureDef.density = 0.0f;
			//fixtureDef.density = 0.1f;
			body->CreateFixture(&fixtureDef);
			
			bi.rect = CGSizeMake(fWidth, fHeight);
			if(name) body->SetUserData(bi);
			CCLOG(@"SvgLoader: Loaded rectangle. name=%@ w=%f h=%f at %f,%f  friction = %f, density = %f",name, fWidth,fHeight,fx,fy, fixtureDef.friction, fixtureDef.density);
		}
		
	}
}

-(void) initShapes:(NSArray *) shapes
{
	for (CXMLElement * curShape in shapes) 
	{
		
		NSString * density = [[curShape attributeForName:@"phy_density"] stringValue];
		NSString * friction = [[curShape attributeForName:@"phy_friction"] stringValue];
		NSString * name = [[curShape attributeForName:@"id"] stringValue];
		
		
		if([curShape attributeForName:@"isEdge"])
		{
			NSString * tmp = [[[curShape attributeForName:@"d"] stringValue] uppercaseString];
			NSString * data = [tmp stringByReplacingOccurrencesOfString:@" L" withString:@""];
			NSArray * dataComponents =[data componentsSeparatedByString:@"M "]; 
			
			b2PolygonShape edgeShape;
			for (NSString * curComponent in dataComponents) 
			{
				if([curComponent length] < 3) continue;
				NSArray * points = [[[curComponent stringByReplacingOccurrencesOfString:@"  " withString:@""] stringByReplacingOccurrencesOfString:@"Z " withString:@""] componentsSeparatedByString:@" "];
				//CCLOG(@"%@",points);
				if([points count]>1)
				{
					CGPoint p1,p2;
					
					for (uint32 i = 1; i< [points count]; i++) 
					{
						if([[points objectAtIndex:i] length]<2) continue;
						
						p1 = CGPointFromString([NSString stringWithFormat:@"{%@}",[points objectAtIndex:i-1]]);
						p2 = CGPointFromString([NSString stringWithFormat:@"{%@}",[points objectAtIndex:i]]);
						p1.y /=scaleFactor;
						p2.y /=scaleFactor;
						
						p1.y = worldHeight-p1.y;
						p2.y = worldHeight-p2.y;
						p1.x /=scaleFactor;
						p2.x /=scaleFactor;


						
						edgeShape.SetAsEdge(b2Vec2(p1.x,p1.y), b2Vec2(p2.x,p2.y));
						
						b2Fixture* edgeFixture = staticBody->CreateFixture(&edgeShape);
						
						if(friction)	edgeFixture->SetFriction([friction floatValue]);
						else edgeFixture->SetFriction(0.5f);
					}
				}
			}
			//NSArray * points = [data componentsSeparatedByString:@" "];
			// Define the ground box shape.
			
			CCLOG(@"SvgLoader: loaded static edge: %@",name);
			//CCLOG(@"Static Edge : %@",data);
			
		}
		else if([curShape attributeForName:@"isCustomShape"])
		{
			NSString * tmp = [[[curShape attributeForName:@"d"] stringValue] uppercaseString];
			NSString * data = [tmp stringByReplacingOccurrencesOfString:@" L" withString:@""];
			NSArray * dataComponents =[data componentsSeparatedByString:@"M "]; 
			
			b2PolygonShape customShape;
			for (NSString * curComponent in dataComponents) 
			{
				if([curComponent length] < 3) continue;
				NSArray * points = [[[curComponent stringByReplacingOccurrencesOfString:@"  " withString:@""] stringByReplacingOccurrencesOfString:@"Z " withString:@""] componentsSeparatedByString:@" "];
				
				if([points count]>2 &&[points count]<=8)
				{
					int vx=[points count];
					b2Vec2 p[vx];
					b2Vec2 avg(0,0);
					
					for (int i =0; i<vx; i++) 
					{
						CGPoint cp = CGPointFromString([NSString stringWithFormat:@"{%@}",[points objectAtIndex:i]]);
						p[i] = b2Vec2(cp.x,cp.y);
						p[i].y = worldHeight-p[i].y;
						avg+=p[i];
						CCLOG(@"------      %f %f",cp.x,cp.y);
					}
					
					avg*=1.0f/vx;
					
					///TODO: add graham scan there
					
					//std::vector <b2Vec2> inVec(p,p);
//					std::vector <b2Vec2> outVec;
//					
//					ConvexHull* hull_generator = new GrahamScanConvexHull();
//					(*hull_generator)(p, p);
					//delete hull_generator;
					
					b2BodyDef bodyDef;
					bodyDef.position.Set(avg.x, avg.y);
					
					//bodyDef.userData = sprite;
					b2Body *body = world->CreateBody(&bodyDef);
					
					// Define another box shape for our dynamic body.
					b2PolygonShape dynamicBox;
					
					dynamicBox.Set(p,vx);
					
					
					// Define the dynamic body fixture.
					b2FixtureDef fixtureDef;
					fixtureDef.shape = &dynamicBox;	
					
					if(density)	fixtureDef.density =[density floatValue];
					else fixtureDef.density = 0.0f;
					
					if(friction) fixtureDef.friction =[friction floatValue];
					else fixtureDef.friction = 0.5f;
					
					//fixtureDef.density = 0.0f;
					//fixtureDef.density = 0.1f;
					body->CreateFixture(&fixtureDef);
					
					if(name) body->SetUserData(name);
					CCLOG(@"SvgLoader: Loaded custom shape. name=%@ at %f,%f  friction = %f, density = %f",name, avg.x, avg.y, fixtureDef.friction, fixtureDef.density);
				}
			}
			
		}
		else if([curShape attributeForName:@"isDistanceJoint"])
		{
			
			NSString * tmp = [[[curShape attributeForName:@"d"] stringValue] uppercaseString];
			NSString * data = [[tmp stringByReplacingOccurrencesOfString:@" L" withString:@""]  stringByReplacingOccurrencesOfString:@"M " withString:@""];
			NSArray * points =[data componentsSeparatedByString:@" "];
			//CCLOG(@"joint data : %@",points);
			if([points count]==2)
			{
				CGPoint p1,p2;
				p1 = CGPointFromString([NSString stringWithFormat:@"{%@}",[points objectAtIndex:0]]);
				p2 = CGPointFromString([NSString stringWithFormat:@"{%@}",[points objectAtIndex:1]]);
				JointDeclaration * curJoint = [[JointDeclaration alloc] init];
				p1.x /=scaleFactor;
				p2.x /=scaleFactor;
				p1.y /=scaleFactor;
				p2.y /=scaleFactor;
				curJoint.point1 = p1;
				curJoint.point2 = p2;

				curJoint.body1 = [[curShape attributeForName:@"body1"] stringValue];
				curJoint.body2 = [[curShape attributeForName:@"body2"] stringValue];
				
				curJoint.jointType = kDistanceJoint;
				[delayedJoints addObject:curJoint];

			}
		}
		else continue;
	}
}

-(b2Body*) getBodyByName:(NSString*) bodyName
{
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) 
		{
			BodyInfo * bi = (BodyInfo*)b->GetUserData();
			if(bi && [bi.name isEqualToString:bodyName]) return b;
		}
	}
	return NULL;
}
-(void) initJoints
{
	for (JointDeclaration * curJointData in delayedJoints) 
	{
		//CCLOG(@"joint data : %@",curJointData);
		b2Body *b1 = [self getBodyByName:curJointData.body1];
		b2Body *b2 = [self getBodyByName:curJointData.body2];
		if(curJointData.jointType==kDistanceJoint && b1)
		{
			CGPoint p1 = curJointData.point1;
			CGPoint p2 = curJointData.point2;
			p1.y = worldHeight-p1.y;
			p2.y = worldHeight-p2.y;
			b2DistanceJointDef jointDef;
			
			if(b2) jointDef.Initialize(b1, b2, b2Vec2(p1.x,p1.y), b2Vec2(p2.x,p2.y));
			else jointDef.Initialize(b1, staticBody, b2Vec2(p1.x,p1.y), b2Vec2(p2.x,p2.y));
			
			jointDef.collideConnected = true;
			world->CreateJoint(&jointDef);
			CCLOG(@"SvgLoader: Loaded DistanceJoint. body1=\"%@\" body2=\"%@\" at %f,%f  %f,%F",
				  curJointData.body1,curJointData.body2==nil?@"static":curJointData.body2,p1.x,p1.y,p2.x,p2.y);
		}
		else if(curJointData.jointType==kRevoluteJoint && b1)
		{
			CGPoint p1 = curJointData.point1;
			//p1.y = worldHeight-p1.y;
			b2RevoluteJointDef jointDef;
			
			jointDef.enableMotor= curJointData.motorEnabled?true:false;
			jointDef.motorSpeed = curJointData.motorSpeed;
			jointDef.maxMotorTorque = curJointData.maxTorque;
			
			if(b2) jointDef.Initialize(b1, b2, b2Vec2(p1.x,p1.y));
			else jointDef.Initialize(b1, staticBody, b2Vec2(p1.x,p1.y));
			
			world->CreateJoint(&jointDef);
			CCLOG(@"SvgLoader: Loaded RevoluteJoint. body1=\"%@\" body2=\"%@\" at %f,%f ",
				  curJointData.body1,curJointData.body2==nil?@"static":curJointData.body2,p1.x,p1.y);
		}
	}
}

-(void) assignSpritesFromManager:(SpriteManager*)manager
{
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) 
		{
			BodyInfo *bi = (BodyInfo*)b->GetUserData();
			if(bi && bi.textureName && bi.spriteName)
			{
				bi.data = [manager getSpriteWithName:bi.spriteName fromTexture:bi.textureName];
			}
			else if(bi && bi.spriteName)
			{
				bi.data = [manager getSpriteWithName:bi.spriteName];
			}
		}
	}
}

-(void) doCleanupShapes
{
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		b->SetUserData(NULL);
	}
}
@end
