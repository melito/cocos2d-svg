
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "JointDeclaration.h"
#import "svgLoader.h"


#import "AbstractCamera.h"
#import "FreeCamera.h"
#import "FollowCamera.h"

// HelloWorld Layer
@interface HelloWorld : Layer
{
	b2World* world;
	GLESDebugDraw *m_debugDraw;
	
	Sprite * arrow;
	
	AbstractCamera * cam;
	
	AbstractCamera * freeCam;
	FollowCamera * followCam;
	
	b2Body * car;
	
	float st;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

-(svgLoader*) initGeometry;

@end
