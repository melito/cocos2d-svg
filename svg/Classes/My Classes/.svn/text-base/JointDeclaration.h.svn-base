//
//  JointDeclaration.h
//  svgParser
//
//  Created by Skeeet on 10/20/09.
//  Copyright 2009 Munky Interactive / munkyinteractive.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDistanceJoint 1
#define kRevoluteJoint 2

@interface JointDeclaration : NSObject {
	NSString * body1;
	NSString * body2;
	CGPoint point1;
	CGPoint point2;
	int jointType;
	
	float maxTorque;
	float motorSpeed;
	BOOL motorEnabled;
}


@property(retain,nonatomic) NSString * body1;
@property(retain,nonatomic) NSString * body2;
@property CGPoint point1;
@property CGPoint point2;
@property int jointType;

@property float maxTorque;
@property float motorSpeed;
@property BOOL motorEnabled;
@end
