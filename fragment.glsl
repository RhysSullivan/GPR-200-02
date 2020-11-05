#version 300 es
//#version 450

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
float lambertianReflectance(vec3 norm, vec3 pos, vec3 L, FPointLight pLight)
{
 float difCoeff = dot(norm, vec3(L)); 	
 float d = length(vec3(pLight.center) - pos);
 float iL = pLight.intensity;
 float d2 = d * d;
 float iL2 = iL * iL;
 float intensity = 1./(1. + d/iL + d2 / iL);
 return intensity * difCoeff; 		 		   
}

layout (location = 0) in vec4 aPosition;
layout (location = 1) in vec3 aNormal;
layout (location = 2) in vec4 aTexcoord;

// TRANFORMATION UNIFORMS
uniform sampler2D uTexture;
uniform mat4 uModelMat;
uniform mat4 uProjMat;
uniform mat4 uViewMat;
uniform mat4 uViewProjMat;
uniform float vTime;
//PER-FRAGMENT VARYING
out vec4 vNormal;
out vec4 vTexcoord;
out vec4 vCPos;
out vec4 vVPos;
// VARYING
out vec4 vColor;
out vec3 LightIntensity;

vec4 perVertex(vec4 pos_camera, vec3 normal, vec4 vertexPos);

void main()
{	
	
	vec4 transform = vec4(sin(vTime),cos(vTime),0.,0.);
	vVPos = aPosition + transform;
	//POSITION PIPELINE
	mat4 modelViewMat = uViewMat * uModelMat;
	vec4 pos_camera = modelViewMat * vVPos;
	vec4 pos_clip = uProjMat * pos_camera;
	gl_Position = pos_clip;

    //NORMAL PIPELINE
    mat3 normalMat = transpose(inverse(mat3(modelViewMat))) ;
	vec3 norm_camera = normalMat * aNormal;

	// TEXCOORD PIPELINE
	mat4 atlasMat = mat4(0.5,0.0,0.0,0.0,
						 0.0,0.5,0.0,0.0,
						 0.0,0.0,1.0,0.0,
						 0.25,0.25,0.0,1.0);
	vec4 uv_atlas = atlasMat * aTexcoord;
	#define ViewSpac
	#ifdef ViewSpace
	vec4 normalToUse = vec4(norm_camera, 0.);
	#else
	vec4 normalToUse = vec4(aNormal, 0.);
	#endif
	// PER-VERTEX: calculate and output final color
	vCPos = pos_camera;
	vNormal = normalToUse;
	vColor = perVertex(vCPos, vNormal.xyz, vVPos);
					
	// PER-FRAGMENT
	vTexcoord = uv_atlas;	
//	vColor = aTexcoord;

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

vec4 perVertex(vec4 pos_camera, vec3 normal, vec4 vertexPos)
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
    		    		    		          
            float iS =  phongReflectance(pos_camera.xyz, normal, pLights[i], aPosition.xyz);
            // IS End 

            sumCol += (iD) + (iS * pLights[i].color);
        }
   	return vec4(sumCol, 0.);
}