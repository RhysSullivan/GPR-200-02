#version 300 es


#ifdef GL_ES
precision highp float;
#endif //GL_ES

layout (location = 0) out vec4 rtFragColor;
uniform sampler2D uTexture;
uniform vec2 uViewportSize;
// VARYING
in vec4 vColor;

vec4 getPixel(float xOff, float yOff)
{
	vec2 texCoord = (vColor * .5 + .5).xy;
	texCoord += vec2(xOff, yOff);
	
    return texture(uTexture, texCoord);
    //return texture(channel, vec2(x - 0.5, y) * inverseReso);
}

void main()
{
	vec4 fragCoord =  vColor * .5 + .5;
	
	   //Edge detect
    vec2 invRes = 1. / uViewportSize;
	// kernal taken from https://docs.gimp.org/2.8/en/plug-in-convmatrix.html
	// only 1 of the middle cells (in C and D) are negative so that the end result is as well
    vec3 kernel = vec3(1.0,2.0,1.0);
	
	vec4[3] pixelsy = vec4[3]( getPixel(0.,-1. * invRes.y),
                getPixel(0.,0.0),
                getPixel(0.0,1. * invRes.y)
                );
    vec4 blur = pixelsy[0] * kernel[0]+
        pixelsy[1] * kernel[1]+
        pixelsy[2] * kernel[2];
	
    

	
	rtFragColor = blur;
	//rtFragColor = vColor;
}
