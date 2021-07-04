// for some weird reason I have to #ifdef everywhere otherwise my unlit shader variants have compile errors
// not quite sure yet what's going on there, I'll figure it out eventually when I learn how to make proper shader variants I guess
#ifdef _LIT
float GetCelShadedLightIntensity(float3 normal, float3 lightDirection)
{
    float lightIntensity = 0.0f;
    if(_EnableShadowRamp)
    {
        float lightAngle = saturate(dot(normal, lightDirection) + 1) / 2;
        lightIntensity = tex2D(_ShadowRamp, float2(lightAngle, 0));
    }
    else
    {
        float lightAngle = saturate(dot(normal, lightDirection));
        lightIntensity = smoothstep(0, _ShadowSmoothness, lightAngle);
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

        // calculate shadows for each light if enabled
        if(_EnableDirectionalShadow)
        {
            float3 vertexLightDirection = float3(toLightX[i], toLightY[i], toLightZ[i]);
            float vertexLightToonIntensity = GetCelShadedLightIntensity(worldNormal, vertexLightDirection);
            vertexLightColour *= vertexLightToonIntensity;
        }

        // finally add the vertex light
        finalVertexLightColour += vertexLightColour;
    }

    return finalVertexLightColour;
}
#endif

float3 CalculatedLightColour(Interpolators fragIn)
{
    #ifdef _LIT
        float3 lightColour = _LightColor0.rgb;

        // different add distance based falloff for lightcolour, then continue with shadow calculation
        // like normal
        #ifdef UNITY_PASS_FORWARDADD
        UNITY_LIGHT_ATTENUATION(lightAttenuation, fragIn, fragIn.worldPosition.xyz);
        lightColour *= lightAttenuation;
        #endif

        // calculate shadows
        if(_EnableDirectionalShadow)
        {
            float3 lightDirection = _WorldSpaceLightPos0.xyz;
            // in forward add we have to calculate the direction ourselves, the directional light
            // in the base pass will already have a direction in _WorldSpaceLightPos0
            #ifdef UNITY_PASS_FORWARDADD
            lightDirection = UnityWorldSpaceLightDir(fragIn.worldPosition);
            #endif

            lightColour *= GetCelShadedLightIntensity(fragIn.worldNormal, normalize(lightDirection));
        }

        // apply directional light, lightprobes and vertex lights
        #ifndef UNITY_PASS_FORWARDADD
        float3 lightProbeColour = ShadeSH9(float4(float3(0, 1, 0), 1.0));
        lightColour += lightProbeColour;

        lightColour += CalculateVertexLightsWithToonShading(fragIn.worldNormal, fragIn.worldPosition);
        #endif

        return lightColour;
    #else
        #ifndef UNITY_PASS_FORWARDADD
            float3 lightColour = float3(1, 1, 1);
            // calculate fake shadows if necessary on UNLIT variants
            if(_EnableFakeShadows)
            {
                float shadowRampPosition = (dot(fragIn.worldNormal, normalize(_FakeLightDirection)) + 1) / 2;
                float4 fakeShadowColour = tex2D(_FakeShadowRamp, float2(shadowRampPosition, 0));
                lightColour *= saturate(fakeShadowColour + (1 - _FakeShadowStrength));
            }
            return lightColour;
        #endif
    #endif
}

// correcting light Colour by normalizing only if any of the vectors values are above 1
// this is important because this way we'll keep all attenuation calculated before
// while at the same time keeping the lightColour at a normalized level in order to not
// make the avatar light up too brightly
float3 CorrectedLightColour(Interpolators fragIn)
{
    float3 lightColour = CalculatedLightColour(fragIn);

    if(lightColour.x > 1 || lightColour.y > 1 || lightColour.z > 1)
    {
        lightColour = normalize(lightColour);
    }

    return lightColour;
}