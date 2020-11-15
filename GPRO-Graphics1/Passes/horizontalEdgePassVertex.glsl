#version 300 es
//#version 450

layout (location = 0) in vec4 aPosition;
layout (location = 1) in vec3 aNormal;


// VARYING
out vec4 vColor;

void main()
{
	gl_Position = aPosition;
	vColor = aPosition;
}
