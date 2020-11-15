#version 300 es
// Code by Rhys Sullivan and Demetrius Nekos

#ifdef GL_ES
precision highp float;
#endif //GL_ES

layout (location = 0) out vec4 rtFragColor;
uniform sampler2D uTexture;
uniform sampler2D uPaperTexture;
// VARYING
in vec4 vPos;

void main()
{
	vec4 uv =  vPos * .5 + .5;
	vec4 outline = vec4(1. - texture(uTexture, uv.xy).x); // grey scale the outline
	vec4 paper = texture(uPaperTexture, uv.xy);
	rtFragColor = outline * paper; // multiplication composite the rendered scene with a paper texture 
}
