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
#include <cstdlib>

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

inline float random_float() {
	// Returns a random real in [0,1).
	return rand() / (RAND_MAX + 1.0f);
}

inline float random_double(float min, float max) {
	// Returns a random real in [min,max).
	return min + (max - min) * random_float();
}

inline float clamp(float x, float min, float max) {
	if (x < min) return min;
	if (x > max) return max;
	return x;
}

// Common Headers

#include "gpro/gpro-graphics/gproRay.h"
#include "gpro/gpro-math/gproVector.h"


#endif