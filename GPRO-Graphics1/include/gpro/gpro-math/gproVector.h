/*
   Copyright 2020 Daniel S. Buckstein

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

	   http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

/*
	gproVector.h
	Interface for vectors. Sets an example for C and C++ compatible headers.

	Modified by: Rhys Sullivan
	Modified because: Expanded vector class to allow for more operations
*/

#ifndef _GPRO_VECTOR_H_
#define _GPRO_VECTOR_H_
#include <cmath>

#ifdef __cplusplus
// DB: link C++ symbols as if they are C where possible
extern "C" {
#else	// !__cplusplus
// DB: forward declare C types... why?
//	-> in C++ you would instantiate one of these like so: 
//		vec3 someVector;
//	-> in C you do it like this: 
//		union vec3 someVector;
//	-> this forward declaration makes the first way possible in both languages!
typedef union vec3 vec3;
#endif	// __cplusplus


// DB: declare shorthand types

typedef float float3[3];		// 3 floats form the basis of a float vector
typedef float* floatv;			// generic float vector (pointer)
typedef float const* floatkv;	// generic constant float vector (pointer)


// DB: declare 3D vector
//	-> why union? all data in the union uses the same address... in this case: 
//		'v' and 'struct...' share the same address
//	-> this means you can have multiple names for the same stuff!

// vec3
//	A 3D vector data structure.
//		member v: array (pointer) version of data
//		members x, y, z: named components of vector
union vec3
{
	float3 v;
	struct { float x, y, z; };

#ifdef __cplusplus
	// DB: in C++ we can have convenient member functions
	//	-> e.g. constructors, operators

	explicit vec3();	// default ctor
	explicit vec3(float const xc, float const yc = 0.0f, float const zc = 0.0f);	// init ctor w one or more floats
	explicit vec3(float3 const vc);	// copy ctor w generic array of floats
	vec3(vec3 const& rh);	// copy ctor

	vec3& operator =(vec3 const& rh);	// assignment operator (copy other to this)
	
	vec3& operator +=(vec3 const& rh);	// addition assignment operator (add other to this)

	vec3& operator *= (const float rh);

	vec3 operator-() const { return vec3(-x, -y, -z); }

	float length_squared() const {
		return (x * x) + (y * y) + (z * z);
	}

	float length() const {
		return std::sqrt(length_squared());
	}

#endif	// __cplusplus
};
using point3 = vec3;
using color = vec3;


// DB: declare C functions (all equivalents of above C++ functions are here)
//	-> return pointers so you can chain operations (they just take pointers)

floatv vec3default(float3 v_out);	// default init
floatv vec3init(float3 v_out, float const xc, float const yc, float const zc);	// init w floats
floatv vec3copy(float3 v_out, float3 const v_rh);	// init w array of floats (same as assign and both copy ctors)

floatv vec3add(float3 v_lh_sum, float3 const v_rh);	// add other to lh vector

floatv vec3sum(float3 v_sum, float3 const v_lh, float3 const v_rh);	// get sum of lh and rh vector


#ifdef __cplusplus
// DB: end C linkage for C++ symbols
}
#endif	// __cplusplus


// DB: include inline definitions for this interface
#include "_inl/gproVector.inl"


#endif	// !_GPRO_VECTOR_H_