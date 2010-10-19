/*
 **************************************************************************
 * Class: Graham Scan Convex Hull                                         *
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


#ifndef INCLUDE_GRAHAMSCANCONVEXHULL_H
#define INCLUDE_GRAHAMSCANCONVEXHULL_H

#include <iostream>
#include <deque>
#include <vector>
#include <algorithm>
#include <math.h>
#include "ConvexHull.h"


struct gs_b2Vec2
{
public:
   gs_b2Vec2(float _x = 0.0, float _y = 0.0, float _angle = 0.0) : x(_x), y(_y), angle(_angle){}
   float x;
   float y;
   float angle;
};

const float _180DivPI  = 57.295779513082320876798154814105000;
const int    counter_clock_wise = +1;
const int    clock_wise         = -1;


class GSb2Vec2Compare
{
public:

   GSb2Vec2Compare(gs_b2Vec2* _anchor):anchor(_anchor){};

   bool operator()(const gs_b2Vec2& p1, const gs_b2Vec2& p2)
   {
      if (p1.angle < p2.angle)      return true;
      else if (p1.angle > p2.angle) return false;
      else if (is_equal(p1,p2))     return false;
      else if (lay_distance(anchor->x, anchor->y, p1.x, p1.y) < lay_distance(anchor->x, anchor->y, p2.x, p2.y))
         return true;
      else
         return false;
   }

private:

   inline bool is_equal(const gs_b2Vec2 p1, gs_b2Vec2 p2)
   {
      return  is_equal(p1.x,p2.x) && is_equal(p1.y,p2.y);
   }

   inline bool is_equal(const float v1, const float& v2, const float epsilon = 1.0e-12)
   {
      float diff = v1 - v2;
      return  (-epsilon <= diff) && (diff <= epsilon);
   }

   inline float lay_distance(const float& x1, const float& y1, const float& x2, const float& y2)
   {
      float dx = (x1 - x2);
      float dy = (y1 - y2);
      return (dx * dx + dy * dy);
   }

   gs_b2Vec2* anchor;

};


class GrahamScanConvexHull : public ConvexHull
{
public:

   GrahamScanConvexHull(){};
  ~GrahamScanConvexHull(){};

   virtual bool operator()(const std::vector < b2Vec2 >& pnt, std::vector< b2Vec2 >& final_hull);

private:

   void graham_scan(std::vector< b2Vec2 >& final_hull);

   inline float cartesian_angle(float x, float y);

   inline int orientation(const gs_b2Vec2& p1,
                          const gs_b2Vec2& p2,
                          const gs_b2Vec2& p3);

   inline int orientation(const float x1, const float y1,
                          const float x2, const float y2,
                          const float px, const float py);

   inline bool is_equal(const float v1, const float& v2, const float epsilon = 1.0e-12);

   std::vector<gs_b2Vec2> point;
   gs_b2Vec2              anchor;

};



#endif
