//
//  JointDeclaration.m
//  svgParser
//
//  Created by Skeeet on 10/20/09.
//  Copyright 2009 Munky Interactive / munkyinteractive.com. All rights reserved.
//

#import "JointDeclaration.h"


@implementation JointDeclaration

@synthesize body1, body2, point1, point2, jointType, maxTorque,motorSpeed,motorEnabled;;



- (NSString *)description
{
	return [NSString stringWithFormat:@"Joint: type: %@, b1=%@, b2=%@, p1=%fx%f, p2=%fx%f",jointType==1?@"kDistanceJoint":@"kRevoluteJoint",body1,body2,point1.x,point1.y,point2.x,point2.y];
}
@end
