/*
	Referenced: Ray Tracing in One Weekend. raytracing.github.io/books/RayTracingInOneWeekend.html
	Accessed 9/10/2020.

	gproColor.h
	Single include file to allow for easier including of header files and constants

	Original File By: Peter Shirley
	Modified by: Rhys Sullivan
	Modified because: Adjusted file to match project style.
*/

#ifndef COLOR_H
#define COLOR_H

#include "gpro/gpro-math/gproVector.h"

#include <fstream>
#include <string>
/*
Write color allows us to write in the format of 
R G B 
to a new line in a stream object, in this case an out file stream.
This could be expanded later to write to an existing array of pixel colors and write those to a file in one operation for better performance. 
*/
void write_color(std::ofstream& out, color pixel_color) {
	// Write the translated [0,255] value of each color component.
	out << static_cast<int>(255.999 * pixel_color.x) << ' '
		<< static_cast<int>(255.999 * pixel_color.y) << ' '
		<< static_cast<int>(255.999 * pixel_color.z) << '\n';
}

void write_color(std::string& out, color pixel_color, int samples_per_pixel) {
	float r = pixel_color.x;
	float g = pixel_color.y;
	float b = pixel_color.z;

	// Divide the color by the number of samples.
	float scale = 1.0f / samples_per_pixel;
	r *= scale;
	g *= scale;
	b *= scale;
	// Write the translated [0,255] value of each color component.

	out += std::to_string(static_cast<int>(256 * clamp(r, 0.0f, 0.999f))) + ' ';
	out += std::to_string(static_cast<int>(256 * clamp(g, 0.0f, 0.999f))) + ' ';
	out += std::to_string(static_cast<int>(256 * clamp(b, 0.0f, 0.999f))) + '\n';
}

#endif