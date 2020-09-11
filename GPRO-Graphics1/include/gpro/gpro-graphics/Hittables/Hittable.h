#ifndef HITTABLE_H
#define HITTABLE_H

#include "gpro/gpro-graphics/gproRay.h"

struct hit_record {
	point3 p;
	vec3 normal;
	float t = 0;

	bool front_face = false;

	/*
	if the dot product is > 0 then the vectors are pointing in the same direction indicating that it is inside of the sphere
	*/
	inline void set_face_normal(const ray& r, const vec3& outward_normal) {
		front_face = dot(r.direction(), outward_normal) < 0;
		if (front_face)
		{
			normal = outward_normal;
		}
		else
		{
			normal = -outward_normal;
		}
	}
};

class hittable {
public:
	virtual bool hit(const ray& r, float  t_min, float t_max, hit_record& rec) const = 0;
};

#endif