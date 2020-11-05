#version 300 es
// code by rhys sullivan, starter from Dan Buckstein

#ifdef GL_ES
precision highp float;
#endif //GL_ES

struct FPointLight
{
 	vec4 center;
    vec3 color;
    float intensity;
};

void initPointLight(out FPointLight pLight, vec4 center, vec3 color, float intensity)
{
    pLight.center = center;
    pLight.color = color;
    pLight.intensity = intensity;    
}

layout (location = 0) out vec4 rtFragColor;
//out vec4 rtFragColor;

in vec4 vColor;
uniform sampler2D vTexture;

// VARYING
in vec4 vNormal;
in vec4 vCPos;
in vec4 vVPos;
in vec4 vTexcoord;

vec4 perFrag(vec4 pos_camera, vec3 norm_camera, vec4 vertexPos);

void main()
{
	//PER-VERTEX: input is just final color
	rtFragColor = vColor;

	//PER-FRAGMENT: calulate final color here using inputs
	#define frag
	#ifdef frag
	rtFragColor = perFrag(vCPos, vNormal.xyz, vVPos);
	#else
	#endif

}

float phongReflectance(vec3 pos, vec3 norm, FPointLight pLight, vec3 rayOrigin)
{
   // Phong Reflectance
   vec3 L = normalize(vec3(pLight.center) - pos); // Light Vector        
   vec3 V = normalize(rayOrigin - pos); // View Vector
   vec3 R = reflect(-L, norm);
   float kS = dot(V,R);   
   kS = max(kS, 0.);
    
   float iS = pow(kS, 16.);
   return iS;
}

vec4 perFrag(vec4 pos_camera, vec3 normal, vec4 vertexPos)
{
#define NUM_LIGHTS 3
        FPointLight[NUM_LIGHTS] pLights;
        vec4 pLightPos = vec4(3.,2.,0.,1.);
        initPointLight(pLights[0],
								pLightPos, 
                       vec3(.8,.6,0.),
                       .3);                       
		
        initPointLight(pLights[1],
                       vec4(-2.,200.,1.,0.), 
                       vec3(.0,.0,.8), 
                       .6);
        initPointLight(pLights[2],
                       vec4(10.,-10.,0.,1.),
                       vec3(.8,.0,.8),
                       .3);        
        vec3 sumCol;
        for(int i = NUM_LIGHTS-1; i >= 0; --i)
        {    		
    		vec3 s = normalize( vec3(pLights[i].center.xyz  - pos_camera.xyz ));
    		float Ld = pLights[i].intensity; // intensity
    		float Kd =  .8; // light lost to reflection
    		float iD = Ld * Kd * max(dot(s, normal), 0.0);
    		    		    		          
            float iS =  phongReflectance(pos_camera.xyz, normal, pLights[i], vertexPos.xyz);
            // IS End 

            sumCol += (iD * texture(vTexture, vTexcoord.xy).xyz) + (iS * pLights[i].color);
        }
   	return vec4(sumCol, 0.);
}