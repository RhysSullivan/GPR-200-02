#version 300 es
// Code by Rhys Sullivan and Demetrius Nekos

layout (location = 0) in vec4 aPosition;

// VARYING
out vec4 vPos;

void main()
{
	gl_Position = aPosition;
	vPos = aPosition; // vColor is being used to represent the UV Coords
}