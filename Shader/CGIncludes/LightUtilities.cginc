#ifdef _LIT
// Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
#pragma exclude_renderers d3d11 gles
uniform int _EnableDirectionalShadow;
uniform float _ShadowSmoothness;
uniform float _ShadowStrength;
uniform int _EnableShadowRamp;
uniform sampler2D _ShadowRamp;

// fake lighting and shadows, only on unlit version
#else
uniform int _EnableFakeShadows;
uniform float _FakeShadowStrength;
uniform float4 _FakeLightDirection;
uniform sampler2D _FakeShadowRamp;
#endif

// for some weird reason I have to #ifdef everywhere otherwise my unlit shader variants have compile errors
// not quite sure yet what's going on there, I'll figure it out eventually when I learn how to make proper shader variants I guess
#ifdef _LIT
float GetCelShadedLightIntensity(float3 normal, float3 lightPosition)
{
    float lightIntensity = 0.0f;
    if(_EnableShadowRamp)
    {
        float lightDirection = saturate(dot(normal, normalize(lightPosition)) + 1) / 2;
        lightIntensity = tex2D(_ShadowRamp, float2(lightDirection, 0));
    }
    else
    {
        float lightDirection = saturate(dot(normal, normalize(lightPosition)));
        lightIntensity = smoothstep(0, _ShadowSmoothness, lightDirection);
    }
    lightIntensity = saturate(lightIntensity + (1 - _ShadowStrength));
    return lightIntensity;
}

// also Shade4PointLights only has smooth shading, so I kinda have to do my own thing here
// using ideas I saw from Skulds and Xiexes shader to make it look good
float3 CalculateVertexLightsWithToonShading(float3 worldNormal, float3 worldPosition)
{
    float3 finalVertexLightColour = float3(0, 0, 0);
    float4 vertexLightAttenuation = float4(0, 0, 0, 0);

    // distance to light, pretty much like the "default"
    float4 lightPositionsX = unity_4LightPosX0;
    float4 lightPositionsY = unity_4LightPosY0;
    float4 lightPositionsZ = unity_4LightPosZ0;

    float4 toLightX = lightPositionsX - worldPosition.x;
    float4 toLightY = lightPositionsY - worldPosition.y;
    float4 toLightZ = lightPositionsZ - worldPosition.z;

    float4 lengthSquared = 0;
    lengthSquared += toLightX * toLightX;
    lengthSquared += toLightY * toLightY;
    lengthSquared += toLightZ * toLightZ;
    // don't produce NaNs if some vertex position overlaps with the light
    lengthSquared = max(lengthSquared, 0.000001);

    // modified attenuation calculation inspired by what I've seen other shaders do
    float4 simpleAttenuation = 1.0 / (1.0 + lengthSquared * unity_4LightAtten0);
    float4 squaredAttenuation = saturate(1 - (lengthSquared * unity_4LightAtten0 / 25));
    squaredAttenuation *= squaredAttenuation;
    vertexLightAttenuation = min(simpleAttenuation, squaredAttenuation);

    for(int i = 0; i < 4; i++)
    {
        // calculate individual colours
        float3 vertexLightColour = unity_LightColor[i] * vertexLightAttenuation[i];

        // shaded without taking shadows into account for now because I'm dumb dumb
        finalVertexLightColour += vertexLightColour;
    }

    return finalVertexLightColour;
}
#endif

float3 ApplyLighting(Interpolators fragIn, float4 colour)
{
    #ifdef _LIT
        // calculate actual lighting
        float lightAttenuation = LIGHT_ATTENUATION(fragIn) / SHADOW_ATTENUATION(fragIn);
    
        if(_EnableDirectionalShadow)
        {
            colour *= GetCelShadedLightIntensity(fragIn.worldNormal, _WorldSpaceLightPos0);
        }

        // apply directional light, lightprobes and vertex lights
        float3 lightProbeColour = ShadeSH9(float4(float3(0, 1, 0), 1.0));
        float3 lightColour = lightProbeColour + _LightColor0.rgb * lightAttenuation;

        lightColour += CalculateVertexLightsWithToonShading(fragIn.worldNormal, fragIn.worldPosition);

        colour.rgb *= lightColour;
        return colour.rgb;
    #else
        // calculate fake shadows if necessary on UNLIT variants
        if(_EnableFakeShadows)
        {
            float shadowRampPosition = (dot(fragIn.worldNormal, normalize(_FakeLightDirection)) + 1) / 2;
            float4 fakeShadowColour = tex2D(_FakeShadowRamp, float2(shadowRampPosition, 0));
            colour *= saturate(fakeShadowColour + (1 - _FakeShadowStrength));
        }
        return colour.rgb;
    #endif
}