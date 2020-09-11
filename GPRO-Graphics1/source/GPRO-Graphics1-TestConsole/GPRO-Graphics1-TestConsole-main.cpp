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
	Referenced: Ray Tracing in One Weekend. raytracing.github.io/books/RayTracingInOneWeekend.html
	Accessed 9/10/2020.

	GPRO_Graphics1-TestConsole-main.cpp
	Main entry point for Windows console application.

	Original File By: Peter Shirley
	Modified by: Rhys Sullivan
	Modified because: Adjusted file to match project style, added multithreading, referenced: https://stackoverflow.com/questions/7686939/c-simple-return-value-from-stdthread
*/




#include <fstream>
#include <string>
#include <thread>
#include <future>
#include <ctime>
#include <iostream>
#include "gpro/gpro-graphics/gproCamera.h"
#include "gpro/gpro-graphics/rtweekend.h"
#include "gpro/gpro-graphics/Hittables/HittableList.h"
#include "gpro/gpro-graphics/Hittables/Sphere.h"
#include "gpro/gpro-graphics/gproColor.h"

color ray_color(const ray& r, const hittable& world) {
	hit_record rec;
	if (world.hit(r, 0.0f, infinity, rec)) {
		return 0.5f * (rec.normal + color(1.0f, 1.0f, 1.0f));
	}


	// Handles the background color
	vec3 unit_direction = unit_vector(r.direction());
	float screenGradient = 0.5f * (unit_direction.y + 1.0f);

	color bottomColor = color(1.0f, 0.0f, 0.0f); // white
	color topColor = color(0.5f, 0.5f, 0.0f); // blue
	return (1.0f - screenGradient) *  bottomColor + screenGradient * topColor; // gradient that is done by interping as we move up the screen
}


// VERTICAL: USE FROM TOP TO BOTTOM, vertical start > vertical  end
// HORIZONTAL: USE FROM LEFT TO RIGHT, horizontal start < horizontal end
// TODO:: Collapse general image stuff to struct?
void RayTraceImageSection(int image_height, int image_width, int image_section_vertical_start, int image_section_vertical_end, int image_section_horizontal_start, int image_section_horizontal_end, camera cam, int samples_per_pixel, hittable_list world, std::promise<std::string>&& OutStrPromise)
{
	std::string OutStrr;
	OutStrr.reserve(50000);
	for (int j = image_section_vertical_start; j >= image_section_vertical_end; --j) 
	{
		for (int i = image_section_horizontal_start; i < image_section_horizontal_end; ++i) 
		{
			color pixel_color(0, 0, 0);
			for (int s = 0; s < samples_per_pixel; ++s) {
				float u = (i + random_float()) / (image_width - 1);
				float v = (j + random_float()) / (image_height - 1);
				ray r = cam.get_ray(u, v);
				pixel_color += ray_color(r, world);
			}
			write_color(OutStrr, pixel_color, samples_per_pixel);
		}
	}
	OutStrPromise.set_value(OutStrr);
}
#define THREAD 
int main(int const argc, char const* const argv[])
{
	// Image
	const float aspect_ratio = 16.0f / 9.0f;
	const int image_width = 400; // Width in pixels
	const int image_height = static_cast<int>(image_width / aspect_ratio);
	const int samples_per_pixel = 100;

	// World
	hittable_list world;
	world.add(make_shared<sphere>(point3(0.0f, 0.0f, -1.0f), 0.2f));
	world.add(make_shared<sphere>(point3(1.0f, 0.0f, -1.0f), 0.2f));
	world.add(make_shared<sphere>(point3(0.0f, -100.5f, -1.0f), 100.0f));

	// Camera
	camera cam;

	// Render
	std::string OutStr;
	OutStr += "P3\n";
	OutStr += std::to_string(image_width);
	OutStr += " ";
	OutStr += std::to_string(image_height);
	OutStr += "\n";
	OutStr += "255\n";


	long long StartTime = std::chrono::duration_cast <std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
#ifdef THREAD 
	std::promise<std::string> TopHalfOutputPromise; // setup to wait for a return value since we cant put references into the threaded function
	std::future<std::string> TopHalfOutput = TopHalfOutputPromise.get_future(); //
	std::thread TopHalfThread(RayTraceImageSection, image_height, image_width, image_height-1, image_height/2, 0, image_width, cam, samples_per_pixel, world, std::move(TopHalfOutputPromise));

	std::promise<std::string> BottomHalfOutputPromise;
	std::future<std::string> BottomHalfOutput = BottomHalfOutputPromise.get_future();
	std::thread BottomHalfThread(RayTraceImageSection, image_height, image_width, image_height/2, 0, 0, image_width, cam, samples_per_pixel, world, std::move(BottomHalfOutputPromise));
	TopHalfThread.join();
	BottomHalfThread.join();
	std::string Out = TopHalfOutput.get() + BottomHalfOutput.get();
	OutStr += Out;
#else
	std::promise<std::string> TopHalfOutputPromise; // setup to wait for a return value since we cant put references into the threaded function
	std::future<std::string> TopHalfOutput = TopHalfOutputPromise.get_future(); //
	std::thread TopHalfThread(RayTraceImageSection, image_height, image_width, image_height - 1, 0, 0, image_width, cam, samples_per_pixel, world, std::move(TopHalfOutputPromise));
	TopHalfThread.join();
	OutStr += TopHalfOutput.get();
#endif
	long long EndTime = std::chrono::duration_cast <std::chrono::nanoseconds>(std::chrono::system_clock::now().time_since_epoch()).count();

	std::cout << "Took: " << (EndTime - StartTime) * .000000001f << " seconds" << std::endl;

	std::ofstream OutFile("Raytraced.ppm");
	
	OutFile << OutStr;
	printf("\n\n");
}
