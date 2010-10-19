/*
 **************************************************************************
 * Class: Convex Hull                                                     *
 * By Arash Partow - 2001                                                 *
 * URL: http://www.partow.net                                             *
 *                                                                        *
 * Copyright Notice:                                                      *
 * Free use of this library is permitted under the guidelines and         *
 * in accordance with the most current version of the Common Public       *
 * License.                                                               *
 * http://www.opensource.org/licenses/cpl.php                             *
 *                                                                        *
 **************************************************************************
*/


#ifndef INCLUDE_CONVEXHULL_H
#define INCLUDE_CONVEXHULL_H

#include <vector>
#include "Box2D.h"

//struct b2Vec2
//{
//   b2Vec2(float _x = 0.0 , float _y = 0.0) : x(_x), y(_y){}
//   float x;
//   float y;
//};

class ConvexHull
{
   public:

     virtual ~ConvexHull(){};
     virtual bool operator()(const std::vector<b2Vec2>& pnt, std::vector<b2Vec2>& final_hull) = 0;

};


#endif
