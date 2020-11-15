#version 300 es
//#version 450

layout (location = 0) in vec4 aPosition;
layout (location = 1) in vec3 aNormal;


layout (location = 2) in vec4 aTexcoord;
uniform sampler2D uTexture;

// TRANFORMATION UNIFORMS
uniform mat4 uModelMat;
uniform mat4 uViewMat;
uniform mat4 uProjMat;
uniform mat4 uViewProjMat;

// VARYING
out vec4 vColor;

//PER-FRAGMENT VARYING
out vec4 vNormal;
out vec4 vTexcoord;
out vec4 vLightPos1;
out vec4 vLightPos2;
out vec3 VRayPos;
out vec4 vPosition;

vec4 calcLighting (in vec4 lightpos, in vec4 lightcolor, float lightintense, in vec4 position,
                   in vec3 normal, in vec3 rayOrigin)
{
    //Taken from Lab 4
    // LAMBERTIAN REFLECTANCE
    vec3 lightVector = lightpos.xyz - position.xyz; // get vector of position to the light
	float lightLength = length(lightVector); // get length of light vector
    lightVector = lightVector / lightLength; // normalizes vector
   
    float diffuseCoefficient = max(0.0, dot(lightVector, normal)); // get coefficient
   
    float intensityRatio = lightLength/lightintense; // simplifying attenuation equation by doing this once
    float attenuation = 1.0 / (1.0 + intensityRatio +
                             (intensityRatio * intensityRatio)); // get attenuation
    float Lambertian = diffuseCoefficient * attenuation; // final lambertian

   // PHONG REFLECTANCE
        
    vec3 viewVector = normalize(rayOrigin.xyz - position.xyz);
    vec3 reflectedLightVector =reflect(-normalize(lightVector).xyz, 
                                           normal.xyz);
    float specular = max(0.0, dot(viewVector, reflectedLightVector));
    specular *= specular; // specularCoefficient^2
    specular *= specular; // specularCoefficient^4
    specular *= specular * specular * specular; // specularCoefficient^16
    specular *= specular * specular * specular; // specularCoefficient^64
   //return vec4(specularCoefficient);
    vec4 ambient = vec4(0.3,0.3,0.3,0.0);

    return ambient * 0.15 + (Lambertian * texture(uTexture,vTexcoord.xy*2.0*vec2(-1.0,1.0)) + specular) * lightcolor; //Phong color
}

void main()
{
	mat4 modelViewMat = uViewMat * uModelMat;
	vec4 pos_camera = modelViewMat * aPosition;
	vec4 pos_clip = uProjMat * pos_camera;
	gl_Position = pos_clip;

    //NORMAL PIPELINE
    mat3 normalMat = transpose(inverse(mat3(modelViewMat))) ;
	vec3 norm_camera = normalMat * aNormal;

	// TEXCOORD PIPELINE
	mat4 atlasMat = mat4(0.5,0.0,0.0,0.25,
						 0.0,0.5,0.0,0.25,
						 0.0,0.0,1.0,0.0,
						 0.0,0.0,0.0,1.0);
	vec4 uv_atlas = atlasMat * aTexcoord;
	vTexcoord = uv_atlas;

	vNormal = normalize(vec4(norm_camera, 0.0));
	VRayPos = (uModelMat*vec4(0.0)).xyz;
	vPosition = uModelMat*aPosition;
	vLightPos1 = uModelMat*vec4(2.5);
	vLightPos2 = uModelMat* vec4(-3.0,4.0,2.0,1.0);
	
	vColor = vec4(norm_camera, 0.);
}