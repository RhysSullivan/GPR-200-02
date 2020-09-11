#ifndef SPHERE_H
#define SPHERE_H

#include "gpro/gpro-graphics/Hittables/Hittable.h"
#include "gpro/gpro-math/gproVector.h"

class sphere : public hittable {
public:
	sphere() {
		center = point3(0.0f, 0.0f, 0.0f);
		radius = 0.0f;
	}
	sphere(point3 cen, float r) : center(cen), radius(r) {};

	virtual bool hit(
		const ray& r, float tmin, float tmax, hit_record& rec) const override;

public:
	point3 center;
	float radius;
};


/*
Sphere isn't made up of geometry, we're just checking for intersections with the equation
0 roots = no intersection
1 roots = 1 intersection
2 roots = 2 intersections
*/
bool sphere::hit(const ray& r, float t_min, float t_max, hit_record& rec) const {
	
	/*
	This section of code is solving for
	sqrt(h^2 - ac)
	*/
	
	vec3 oc = r.origin() - center;
	float a = r.direction().length_squared();
	float half_b = dot(oc, r.direction());
	float c = oc.length_squared() - radius * radius;
	float discriminant = half_b * half_b - a * c;

	if (discriminant > 0) {
		float root = sqrt(discriminant);
		
		float temp = (-half_b - root) / a;
		if (temp < t_max && temp > t_min) {
			rec.t = temp;
			rec.p = r.at(rec.t);
			vec3 outward_normal = (rec.p - center) / radius;
			rec.set_face_normal(r, outward_normal);
			return true;
		}

		temp = (-half_b + root) / a;
		if (temp < t_max && temp > t_min) {
			rec.t = temp;
			rec.p = r.at(rec.t);
			vec3 outward_normal = (rec.p - center) / radius;
			rec.set_face_normal(r, outward_normal);
			return true;
		}
	}

	return false;
}


#endif