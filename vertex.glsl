#version 300 es


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

// VARYING
// PER-VERTEX: recieve final color
in vec4 vColor;
uniform sampler2D vTexture;
//PER-FRAGMENT: recieving stuff used for final color
in vec4 vNormal;
in vec4 vCPos;
in vec4 vVPos;
in vec4 vTexcoord;

vec4 perFrag(vec4 pos_camera, vec3 norm_camera);

void main()
{
	//PER-VERTEX: input is just final color
	rtFragColor = vColor;

	
	//PER-FRAGMENT: calulate final color here using inputs
	#define fra
	#ifdef frag
	rtFragColor = perFrag(vVPos, vNormal.xyz);
	#else
	#endif

}

vec4 perFrag(vec4 pos_camera, vec3 norm_camera)
{
#define NUM_LIGHTS 1
        FPointLight[NUM_LIGHTS] pLights;
        vec4 pLightPos = vec4(3.,10.,8.,1.);
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
    		vec3 s = normalize( vec3(pLights[i].center.xyz  - pos.xyz ));
    		float Ld = pLights[i].intensity; // intensity
    		float Kd =  .8; // light lost to reflection
    		float iD = Ld * Kd * max(dot(s, norm_camera), 0.0);

    		
    		float d = length(vec3(pLights[i].center) - pos.xyz); // distance between light center and surface point
			float inv = 1./d; // precompute the inverse for speed 
	 	    vec3 L = (vec3(pLights[i].center) - pos.xyz) * inv; // Light Vector                       
            
            // IS Start
            #define BF
            #ifdef BF            
   			vec3 V = normalize(vCPos.xyz - vVPos.xyz); // View Vector   			
            vec3 R = reflect(-L, norm); // Reflect is: - 2.0 * dot(N, I) * N.
   			float kS = dot(V,R); // Specular Coefficient
   			kS = max(kS, 0.); //    
   			float iS = kS; // final specular intensity
            iS *= iS; // 2
            iS *= iS; // 4
            iS *= iS; // 8
            iS *= iS; // 16	
            #endif
            // IS End 
            sumCol += iD + iS;
        }
   return vec4(sumCol, 0.) + .1;
}