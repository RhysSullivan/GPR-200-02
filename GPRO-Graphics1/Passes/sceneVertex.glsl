#version 300 es
// Code by Rhys Sullivan and Demetrius Nekos

layout (location = 0) in vec4 aPosition;
layout (location = 1) in vec3 aNormal;

// TRANFORMATION UNIFORMS
uniform mat4 uModelMat;
uniform mat4 uViewMat;
uniform mat4 uProjMat;
uniform mat4 uViewProjMat;

//PER-FRAGMENT VARYING
out vec4 vNormal;
out vec4 vLightPos1;
out vec4 vLightPos2;
out vec3 VRayPos;
out vec4 vPosition;


void main()
{	
	//POSITION PIPELINE
	mat4 modelViewMat = uProjMat * uViewMat * uModelMat;
	gl_Position = modelViewMat * aPosition;	

    //NORMAL PIPELINE
    mat3 normalMat = transpose(inverse(mat3(modelViewMat))) ;
	vec3 norm_camera = normalMat * aNormal;
						
	// Set Varyings for fragment shader lighting
	vNormal = normalize(vec4(norm_camera, 0.0));
	VRayPos = (modelViewMat*vec4(0.0)).xyz;
	vPosition = modelViewMat*aPosition;
	vLightPos1 = modelViewMat*vec4(2.5);
	vLightPos2 = modelViewMat* vec4(-3.0,4.0,2.0,1.0);
}
