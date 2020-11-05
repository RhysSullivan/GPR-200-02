#version 300 es
// code by rhys sullivan, starter from Dan Buckstein

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

layout (location = 0) in vec4 aPosition;
layout (location = 1) in vec3 aNormal;
layout (location = 2) in vec4 aTexcoord;

// UNIFORMS
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
out vec4 vColor;

vec4 perVertex(vec4 pos_camera, vec3 normal, vec4 vertexPos);

void main()
{	
	vec4 transform = vec4(sin(vTime),cos(vTime),0.,0.); // transform of vertexes

	vVPos = aPosition + transform;
	
	//*****SETUP START******

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
	vTexcoord = uv_atlas;	
	#define ViewSpace
	#ifdef ViewSpace
	vec4 normalToUse = vec4(norm_camera, 0.);
	#else
	vec4 normalToUse = vec4(aNormal, 0.);
	#endif

	//*****SETUP END******	
	// PER-VERTEX: calculate and output final color
	vCPos = pos_camera;
	vNormal = normalToUse;
	vColor = perVertex(vCPos, vNormal.xyz, vVPos);
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