/*
	Referenced: Ray Tracing in One Weekend. raytracing.github.io/books/RayTracingInOneWeekend.html
	Accessed 9/10/2020.

	gproRay.h
	Single include file to allow for easier including of header files and constants

	Original File By: Peter Shirley
	Modified by: Rhys Sullivan
	Modified because: Adjusted file to match project style, removed default constructor since a ray can't exist without an origin and direction.
*/

#ifndef _GPRO_RAY_H_ 
#define _GPRO_RAY_H_

#include "gpro/gpro-math/gproVector.h"

class ray {
public:
	ray(const point3& origin, const vec3& direction)
		: orig(origin), dir(direction)
	{}

	point3 origin() const { return orig; }
	vec3 direction() const { return dir; }

	point3 at(float t) const {
		return orig + (t * dir);
	}

public:
	point3 orig; // a ray is just a vector that can be positioned anywhere in space, origin is where we are being positioned
	vec3 dir; // direction is the direction from our origin that we travel
};

#endif