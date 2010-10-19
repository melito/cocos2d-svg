//
//  SpriteManager.h
//  Castlecrush
//
//  Created by skeeet on 11.05.09.
//  Copyright 2009 Munky Interactive/munkyinteractive.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TouchXML.h"

@interface SpriteInfo : NSObject 
{
	CGRect rect;
	NSString * textureName;
	NSString * name;
}
@property(nonatomic,assign) NSString * textureName;
@property(nonatomic,assign) NSString * name;
@property CGRect rect;
@end




@interface SpriteManager : NSObject 
{
	NSMutableDictionary * spriteDescriptions;
	NSMutableDictionary * managers;
	NSMutableArray * sprites;
	CocosNode * attachNode;
	int attachZ;
}


-(id) initWithNode:(CocosNode*)node z:(int)zVal;
-(AtlasSprite*) getSpriteWithName:(NSString*)name;
-(AtlasSprite*) getSpriteWithName:(NSString*)name fromTexture:(NSString*)texName;
-(AtlasSprite*) getSpriteWithName:(NSString*)name fromTexture:(NSString*)texName withAnchorPoint:(CGPoint)anchor;
-(void) detachWithCleanup:(BOOL)needCleanup;
-(void) clearSprites;
-(void) parseSvgFile:(NSString*)filename;
-(void) parsePlistFile:(NSString*)filename;

@end
