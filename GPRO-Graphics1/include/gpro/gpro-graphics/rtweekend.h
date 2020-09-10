/*
	Referenced: Ray Tracing in One Weekend. raytracing.github.io/books/RayTracingInOneWeekend.html
	Accessed 9/10/2020.

	rtweekend.h
	Single include file to allow for easier including of header files and constants

	Original File By: Peter Shirley
	Modified by: Rhys Sullivan
	Modified because: Adjusted file to use floats.
*/

#ifndef RTWEEKEND_H
#define RTWEEKEND_H

#include <cmath>
#include <cstdlib>
#include <limits>
#include <memory>


// Usings

using std::shared_ptr;
using std::make_shared;
using std::sqrt;

// Constants

const float infinity = std::numeric_limits<float>::infinity();
const float pi = 3.1415926535897932385f;

// Utility Functions

inline float degrees_to_radians(float degrees) {
	return degrees * pi / 180.0f;
}

// Common Headers

#include "gpro/gpro-graphics/gproRay.h"
#include "gpro/gpro-math/gproVector.h"


#endif