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
	GPRO-Graphics1-TestConsole-main.c/.cpp
	Main entry point source file for a Windows console application.

	Modified by: ____________
	Modified because: ____________
*/




#include <fstream>

#include "gpro/gpro-graphics/rtweekend.h"
#include "gpro/gpro-graphics/Hittables/HittableList.h"
#include "gpro/gpro-graphics/Hittables/Sphere.h"
#include "gpro/gpro-graphics/gproColor.h"

color ray_color(const ray& r, const hittable& world) {
	hit_record rec;
	if (world.hit(r, 0.0f, infinity, rec)) {
		return 0.5f * (rec.normal + color(1.0f, 1.0f, 1.0f));
	}
	vec3 unit_direction = unit_vector(r.direction());
	float t = 0.5f * (unit_direction.y + 1.0f);
	return (1.0f - t) * color(1.0f, 1.0f, 1.0f) + t * color(0.5f, 0.7f, 1.0f);
}

int main(int const argc, char const* const argv[])
{
	// Image
	const float aspect_ratio = 16.0f / 9.0f;
	const int image_width = 400;
	const int image_height = static_cast<int>(image_width / aspect_ratio);
	std::ofstream OutFile("Raytraced.ppm");

	// World
	hittable_list world;
	world.add(make_shared<sphere>(point3(0.0f, 0.0f, -1.0f), 0.5f));
	world.add(make_shared<sphere>(point3(0.0f, -100.5f, -1.0f), 100.0f));

	// Camera

	float viewport_height = 2.0;
	float viewport_width = aspect_ratio * viewport_height;
	float focal_length = 1.0;
	
	point3 origin = point3(0, 0, 0);
	vec3 horizontal = vec3(viewport_width, 0, 0);
	vec3 vertical = vec3(0, viewport_height, 0);
	point3 lower_left_corner = origin - (horizontal / 2) - (vertical / 2) - vec3(0, 0, focal_length);

	// Render

	OutFile << "P3\n" << image_width << ' ' << image_height << "\n255\n";

	for (int j = image_height - 1; j >= 0; --j) {
		for (int i = 0; i < image_width; ++i) {
			float u = float(i) / (image_width - 1);
			float v = float(j) / (image_height - 1);
			ray r(origin, lower_left_corner + (u * horizontal) + (v * vertical) - origin);
			color pixel_color = ray_color(r, world);
			//pixel_color = color(float (i) / (image_width - 1), float(j) / (image_height - 1), 0.25);
			write_color(OutFile, pixel_color);
		}
	}

	printf("\n\n");
	system("pause");
}
