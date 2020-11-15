#version 300 es


#ifdef GL_ES
precision highp float;
#endif //GL_ES

layout (location = 0) out vec4 rtFragColor;
uniform sampler2D uTexture;
uniform sampler2D uPaperTexture;
// VARYING
in vec4 vColor;

void main()
{
	vec4 uv =  vColor * .5 + .5;
	vec4 outline = 1. - texture(uTexture, uv.xy);
	vec4 paper = texture(uPaperTexture, uv.xy);
	rtFragColor = outline * paper;
}
