#version 300 es


#ifdef GL_ES
precision highp float;
#endif //GL_ES

layout (location = 0) out vec4 rtFragColor;
uniform sampler2D uTexture;

// VARYING
in vec4 vColor;

void main()
{
	vec4 uv =  vColor * .5 + .5;
	rtFragColor = texture(uTexture, uv.xy);
}
