//
//  SpriteManager.m
//  Castlecrush
//
//  Created by skeeet on 11.05.09.
//  Copyright 2009 Munky Interactive/munkyinteractive.com. All rights reserved.
//

#import "SpriteManager.h"


@implementation SpriteInfo
@synthesize rect;
@synthesize textureName;
@synthesize name;
- (void) dealloc
{
	[textureName release];
	[name release];
	[super dealloc];
}

@end

@implementation SpriteManager


- (void) dealloc
{
	[spriteDescriptions release];
	[sprites release];
	[managers release];
	[super dealloc];
}

-(id) init
{
	self = [super init];
	if (self != nil) 
	{
		spriteDescriptions = [[NSMutableDictionary alloc] initWithCapacity:1];
		managers = [[NSMutableDictionary alloc] initWithCapacity:1];
		sprites = [[NSMutableArray alloc] initWithCapacity:1];
	}
	return self;
}

-(id) initWithNode:(CocosNode*)node z:(int)zVal
{
	self = [super init];
	if (self != nil) 
	{
		spriteDescriptions = [[NSMutableDictionary alloc] initWithCapacity:1];
		managers = [[NSMutableDictionary alloc] initWithCapacity:1];
		sprites = [[NSMutableArray alloc] initWithCapacity:1];
		attachNode = node;
		attachZ = zVal;
	}
	return self;
}

-(void) parsePlistFile:(NSString*)filename
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *curFileName = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
    BOOL success = [fileManager fileExistsAtPath:curFileName];
	if(!success) return;
	NSDictionary * data  = [[NSDictionary alloc] initWithContentsOfFile:curFileName];

	if(data && [data objectForKey:@"frames"])
	{
		//init atlas manager
		NSString* textureName = [data objectForKey:@"textureName"];
		AtlasSpriteManager *mgr = [AtlasSpriteManager spriteManagerWithFile:textureName capacity:1];
		[managers setObject:mgr forKey:textureName];
		[attachNode addChild:mgr z:attachZ tag:[mgr hash]];
		CCLOG(@"SpriteManager: Created Atlasmanager for texture: %@",textureName);
		
		
		
		//init sprite data
		NSDictionary * frames = [data objectForKey:@"frames"];
		for (NSString * spriteName in [frames allKeys]) 
		{
			NSDictionary * curFrameData = [frames objectForKey:spriteName];
			int width = [[curFrameData objectForKey:@"width"] intValue];
			int height = [[curFrameData objectForKey:@"height"] intValue];
			int x = [[curFrameData objectForKey:@"x"] intValue];
			int y = [[curFrameData objectForKey:@"y"] intValue];
			
			CGRect r = CGRectMake(x,y,width,height);
			SpriteInfo * c = [[SpriteInfo alloc] init];
			c.rect = r;
			c.name= spriteName;
			c.textureName = textureName;
			[spriteDescriptions setObject:c forKey:[NSString stringWithFormat:@"%@-%@",textureName,spriteName]];
			[c release];
		}
	}
	[data release];
}

-(void) parseSvgFile:(NSString*)filename
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *curFileName = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
    BOOL success = [fileManager fileExistsAtPath:curFileName];
	if(!success) return;
	
	NSData *data = [NSData dataWithContentsOfFile:curFileName]; 
	CXMLDocument *svgDocument  = [[[CXMLDocument alloc] initWithData:data options:0 error:nil] autorelease];
    NSArray *layers = NULL;
	

	NSString * textureName =nil;
    // root groups are layers for geometry
    layers = [[svgDocument rootElement] elementsForName:@"g"];
	for (CXMLElement * curLayer in layers) 
	{
		//layers with "ignore" attribute not loading
		if([curLayer attributeForName:@"ignore"])
		{
			CCLOG(@"SpriteManager: layer ignored: %@",[[curLayer attributeForName:@"id"] stringValue]);
			continue;
		}
		
		//CCLOG(@"%@",[curLayer attributes]);
		//load texture if needed
		if([curLayer attributeForName:@"isTexture"])
		{
			if(![[managers allKeys] containsObject:[[curLayer attributeForName:@"id"] stringValue]])
			{
				//[Texture2D saveTexParameters];
				//[Texture2D setAliasTexParameters];
				textureName = [[curLayer attributeForName:@"id"] stringValue];
				AtlasSpriteManager *mgr = [AtlasSpriteManager spriteManagerWithFile:[[curLayer attributeForName:@"id"] stringValue] capacity:1];
				[managers setObject:mgr forKey:[[curLayer attributeForName:@"id"] stringValue]];
				
				[attachNode addChild:mgr z:attachZ tag:[mgr hash]];
				
				CCLOG(@"SpriteManager: Created Atlasmanager for texture: %@",[[curLayer attributeForName:@"id"] stringValue]);
				//[Texture2D setAntiAliasTexParameters];
				//[Texture2D restoreTexParameters];
				continue;
			}
		}
		
		CCLOG(@"SpriteManager: loading layer: %@",[[curLayer attributeForName:@"id"] stringValue]);
		//processing textures
		NSArray *rects = [curLayer elementsForName:@"rect"];
		for (CXMLElement * curInfo in rects) 
		{
			NSString * width = [[curInfo attributeForName:@"width"] stringValue];
			NSString * height = [[curInfo attributeForName:@"height"] stringValue];
			NSString * x = [[curInfo attributeForName:@"x"] stringValue];
			NSString * y = [[curInfo attributeForName:@"y"] stringValue];
			NSString * spriteName = [[curInfo attributeForName:@"id"] stringValue];
			CGRect r = CGRectMake([x floatValue],[y floatValue],[width floatValue], [height floatValue]);
			SpriteInfo * c = [[SpriteInfo alloc] init];
			c.rect = r;
			c.name= spriteName;
			c.textureName = textureName;
			[spriteDescriptions setObject:c forKey:[NSString stringWithFormat:@"%@-%@",textureName,spriteName]];
			[c release];
		}	
		CCLOG(@"SpriteManager: layer loaded: %@",[[curLayer attributeForName:@"id"] stringValue]);
		//CCLOG(@"---managers     %@",managers);
		//CCLOG(@"---spriteDescriptions     %@",spriteDescriptions);
	}
}
-(void) clearSprites
{
	for (NSString * key in [managers allKeys]) 
	{
		AtlasSpriteManager *mgr = (AtlasSpriteManager *)[managers objectForKey:key];
		[mgr removeAllChildrenWithCleanup:YES];
	}
	[sprites removeAllObjects];
}

-(void) detachWithCleanup:(BOOL)needCleanup
{
	
	[spriteDescriptions removeAllObjects];
	for (NSString * key in [managers allKeys]) 
	{
		AtlasSpriteManager *mgr = (AtlasSpriteManager *)[managers objectForKey:key];
		[mgr removeAllChildrenWithCleanup:needCleanup];
		[attachNode removeChild:mgr cleanup:needCleanup];
	}
	for (NSString * key in [spriteDescriptions allKeys]) 
	{
		//[[spriteDescriptions objectForKey:key] release];
	}
	[spriteDescriptions removeAllObjects];
	
	[sprites removeAllObjects];
	//[sprites release];
	//sprites = [[NSMutableArray alloc] initWithCapacity:1];
	attachNode = nil;
	
	[managers removeAllObjects];
	
}
// will return first sprite with suitable name
-(AtlasSprite*) getSpriteWithName:(NSString*)name
{
	for (NSString* curKey in [spriteDescriptions allKeys]) 
	{
		NSArray * parts = [curKey componentsSeparatedByString:@"-"];
		if([parts count]>1)
		{
			NSString * spName = [parts objectAtIndex:1];
			
			if([spName isEqualToString:name])
			{
				SpriteInfo * c = [spriteDescriptions objectForKey:curKey];
				AtlasSprite * s = [AtlasSprite spriteWithRect:c.rect spriteManager: [managers objectForKey:c.textureName]];
				[sprites addObject:[s retain]];
				AtlasSpriteManager *mgr = (AtlasSpriteManager *)[managers objectForKey:c.textureName];
				[mgr addChild:s];
				return [s autorelease];
			}
		}
	}
	
	return nil;
}
-(AtlasSprite*) getSpriteWithName:(NSString*)name fromTexture:(NSString*)texName
{
	if([managers objectForKey:texName]!=nil)
	{
		if([spriteDescriptions objectForKey:[NSString stringWithFormat:@"%@-%@",texName,name]])
		{
			SpriteInfo * c = [spriteDescriptions objectForKey:[NSString stringWithFormat:@"%@-%@",texName,name]];
			AtlasSprite * s = [AtlasSprite spriteWithRect:c.rect spriteManager: [managers objectForKey:c.textureName]];
			[sprites addObject:[s retain]];
			AtlasSpriteManager *mgr = (AtlasSpriteManager *)[managers objectForKey:c.textureName];
			[mgr addChild:s];
			//[s autorelease];
			return [s autorelease];
		}
		else return nil;
	}
	return nil;
}
-(AtlasSprite*) getSpriteWithName:(NSString*)name fromTexture:(NSString*)texName withAnchorPoint:(CGPoint)anchor
{
	AtlasSprite * s = [self getSpriteWithName:name fromTexture:texName];
	if(s)
	{
		s.anchorPoint = anchor;
	}
	
	return s;
}
@end

