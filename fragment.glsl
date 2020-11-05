#version 300 es
//#version 450

// MAIN DUTY: PROCESS ATTRIBUTES
// e.g. 3D position in space
// e.g. normal
// e.g. 2D uv: texture coordinate

//PER-FRAGMENT VARYING
out vec4 vNormal;
out vec4 vTexcoord;
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


//  2D uv : texture coordinate
// TEXTURE SPACE
//layout (location = 2) in vec2 aTexcoord;
layout (location = 2) in vec4 aTexcoord;

// TRANFORMATION UNIFORMS
uniform mat4 uModelMat;
uniform mat4 uProjMat;
uniform mat4 uViewMat;
uniform mat4 uViewProjMat;

// VARYING
out vec4 vColor;
out vec3 LightIntensity;
void main()
{
	//POSITION PIPELINE
	mat4 modelViewMat = uViewMat * uModelMat;
	vec4 pos_camera = modelViewMat * aPosition;
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
	
		
	// PER-VERTEX: calculate and output final color
	#define NUM_LIGHTS 1
        FPointLight[NUM_LIGHTS] pLights;
        vec4 pLightPos = vec4(3.,10.,8.,1.);
        pLightPos.xyz = pLightPos.xyz;
        initPointLight(pLights[0],
								pLightPos, 
                       vec3(.8,.6,0.),
                       1.);                       
		/*
        initPointLight(pLights[1],
                       vec4(0.-2.,20.,1.), 
                       vec3(.0,.0,.8), 
                       10.);
        initPointLight(pLights[2],
                       vec4(sin(iTime*3.)*10.,-10.,0.,1.),
                       vec3(.8,.0,.8),
                       20.);        */
        vec3 sumCol;
        vec4 pos = pos_camera;   
        vec3 norm = norm_camera;
        for(int i = NUM_LIGHTS-1; i >= 0; --i)
        {
    		vec4 tnorm = normalize(uViewMat * vec4(aNormal, 0.));    
    		vec4 eyeCoords = modelViewMat * aPosition;
    		vec3 s = normalize( vec3(pLights[i].center.xyz  - eyeCoords.xyz ));
    		float Ld = pLights[i].intensity; // intensity
    		float Kd =  .8; // light lost to reflection
    		LightIntensity = vec3(Ld * Kd * max(dot(s, tnorm.xyz), 0.0));
    		sumCol += LightIntensity;
    		
	        continue;
            // ID Start
            float d = length(vec3(pLights[i].center) - pos.xyz); // distance between light center and surface point
            float inv = 1./d; // precompute the inverse for speed            
	 	    vec3 L = (vec3(pLights[i].center) - pos.xyz) * inv; // Light Vector
            float kD = dot(norm, L); //diffuse coefficient
            kD = max(kD, 0.);
 			float iL = pLights[i].intensity; // original light intensity
            float iLinv = 1./iL; // precompute inverse of light intensity
            float intensity = 1./(1. + d * iLinv + (d * iLinv * d * iLinv)); 
 			float iD = intensity * kD; // diffuse intensity                           
            // ID END                         
            
            // IS Start
            #define BF
            #ifdef BF            
   			vec3 V = normalize(aPosition.xyz- pos.xyz); // View Vector   			
            vec3 R = reflect(-L, norm); // Reflect is: - 2.0 * dot(N, I) * N.
   			float kS = dot(V,R); // Specular Coefficient
   			kS = max(kS, 0.); //    
   			float iS = kS; // final specular intensity
            iS *= iS; // 2
            iS *= iS; // 4
            iS *= iS; // 8
            iS *= iS; // 16	
            #endif
            #ifdef BFP
            float iS = blinnPhongReflectance(pos, norm, pLights[i], vec3(rayOrigin));
            #endif
            // IS End 
            sumCol += iD;			 
        }
        vColor = vec4(sumCol, 0.) + .1;
							
	// vColor = vec4(aNormal * 0.5 + 0.5,1.0);
	
	// PER-FRAGMENT
	vNormal = vec4(norm_camera, 0.0);
	
	vTexcoord = uv_atlas;
	//gl_Position = uProjMat * modelViewMat * aTexcoord;
}