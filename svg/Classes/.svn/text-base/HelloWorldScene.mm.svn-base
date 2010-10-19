//
// Demo of calling integrating Box2D physics engine with cocos2d AtlasSprites
// a cocos2d example
// http://code.google.com/p/cocos2d-iphone
//
// by Steve Oldmeadow
//

// Import the interfaces
#import "HelloWorldScene.h"
#import "TouchXML.h"
#import "JointDeclaration.h"

#import "SpriteManager.h"
#import "BodyInfo.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.



//#define WORLD_HEIGHT 1000
// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagSpriteManager = 1,
	kTagAnimation1 = 1,
};



// HelloWorld implementation
@implementation HelloWorld

+(id) scene
{
	// 'scene' is an autorelease object.
	Scene *scene = [Scene node];
	
	// 'layer' is an autorelease object.
	HelloWorld *layer = [HelloWorld node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// initialize your instance here
-(id) init
{
	if( (self=[super init])) 
	{
		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = YES;
		
		CGSize screenSize = [Director sharedDirector].winSize;
		
		// Define the gravity vector.
		b2Vec2 gravity;
		gravity.Set(0.0f, -100.0f);
		
		// Do we want to let bodies sleep?
		bool doSleep = true;
		// Construct a world object, which will hold and simulate the rigid bodies.
		world = new b2World(gravity, doSleep);
		world->SetContinuousPhysics(true);
		
		
		
		
		freeCam = [[FreeCamera alloc] init];
		followCam = [[FollowCamera alloc] init];
		cam = followCam;
		
		//[cam ZoomTo:0.5];
		// Debug Draw functions
		m_debugDraw = new GLESDebugDraw( cam.ptmRatio ); //PTM RATIO

		world->SetDebugDraw(m_debugDraw);
		uint32 flags = 0;
		flags += b2DebugDraw::e_shapeBit;
		flags += b2DebugDraw::e_jointBit;
		//flags += b2DebugDraw::e_aabbBit;
		flags += b2DebugDraw::e_pairBit;
		flags += b2DebugDraw::e_centerOfMassBit;
		m_debugDraw->SetFlags(flags);		
		
		
		
		//init stuff from svg file
		svgLoader* loader = [self initGeometry];
		SpriteManager * manager = [[SpriteManager alloc] initWithNode:self z:10];
		[manager parsePlistFile:@"levin.plist"];
		
		[loader assignSpritesFromManager:manager];
		
		car = [loader getBodyByName:@"bober"];
		
		cam = followCam;
		//cam = freeCam;
		
		[followCam follow: [loader getBodyByName:@"bober"]];
		//[followCam follow: [loader getBodyByName:@"faxx3"]];
		
		[cam ZoomToObject:car screenPart:0.15];
		
		
		
		MenuItemFont * mi = [MenuItemFont itemFromString:@"OO" target:self selector:@selector(onButton:)];
		
		Menu * m = [Menu menuWithItems:mi,nil];
		[self addChild:m z:500];
		m.position = CGPointMake(460, 30);
		
		arrow = [Sprite spriteWithFile:@"arrow.png"];
		arrow.anchorPoint = CGPointMake(0, 2.5);
		arrow.scaleX = 3;
		[self addChild:arrow z:100 tag:0x777888];
		
		st =0;
		
		
		
		[self schedule: @selector(tick:)];
		
	}
	return self;
}

-(void) onButton:(id) sender
{
}
-(svgLoader*) initGeometry
{
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
	// load geometry from file
	b2Body* groundBody = world->CreateBody(&groundBodyDef);
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"drawing.svg" ofType:nil];  
	svgLoader * loader = [[svgLoader alloc] initWithWorld:world andStaticBody:groundBody];
	[loader parseFile:filePath];
	return loader;
}

-(void) draw
{	
	[super draw];
	glEnableClientState(GL_VERTEX_ARRAY);
	//world->DrawDebugData();
	b2Vec2 tmp = [cam b2vPosition];
	m_debugDraw->mRatio = cam.ptmRatio;

	world->DrawDebugData(&tmp);
	//world->DrawDebugData();
	glDisableClientState(GL_VERTEX_ARRAY);
	
}

-(void) tick: (ccTime) dt
{
//	st+=0.01;
//	float s = sin(st)*2.0f;
//	if(s<0) s*=-1.0f;
//	[cam ZoomTo: s +0.2f];
	[cam updateFollowPosition];
	
	int32 velocityIterations = 8;
	int32 positionIterations = 10;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	//world->Step(dt, velocityIterations, positionIterations);
	world->Step(1.0f/30.0f, velocityIterations, positionIterations);
	
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		[cam updateSpriteFromBody:b];
	}
	
}
- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[cam eventBegan:touches];
//	//Add a new body/atlas sprite at the touched location
//	for( UITouch *touch in touches ) {
//		CGPoint location = [touch locationInView: [touch view]];
//		location = [[Director sharedDirector] convertToGL: location];
//		if([touches count]==1) [myCamera eventBegan:location];
//	}
//	isThrottleEnabled = YES;
//	
//	
	return kEventHandled;
}
- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[cam eventMoved:touches];
	
//	for( UITouch *touch in touches ) 
//	{
//		CGPoint location = [touch locationInView: [touch view]];
//		location = [[Director sharedDirector] convertToGL: location];
//		if([touches count]==1)[myCamera eventMoved:location];
//	}
	return kEventHandled;
}
- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[cam eventEnded:touches];
//	//Add a new body/atlas sprite at the touched location
//	for( UITouch *touch in touches ) 
//	{
//		CGPoint location = [touch locationInView: [touch view]];
//		location = [[Director sharedDirector] convertToGL: location];
//		
////		if([touches count]==1) [myCamera eventEnded:location];
////		else  //[self addNewSpriteWithCoords: location];
////		{
////			myCamera.zoomFactor*=0.5f;
////		}
//		
//	}
////	
////	b2Vec2 vel = carBox->GetLinearVelocity();
////	vel.Normalize();
////	vel*=100.0f;
////	carBox->ApplyImpulse(vel, b2Vec2_zero);
//	isThrottleEnabled = NO;
	return kEventHandled;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
