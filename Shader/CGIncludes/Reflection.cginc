#ifndef UNITY_PASS_FORWARDADD
float3 GetReflection(Interpolators fragIn)
{
    float3 reflectionDirection = reflect(fragIn.viewDirection, fragIn.worldNormal);
    Unity_GlossyEnvironmentData environmentData;
    environmentData.roughness = 1 - _Smoothness;
    environmentData.reflUVW = normalize(reflectionDirection);
    return Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE(unity_SpecCube0), unity_SpecCube0_HDR, environmentData);
}
#endif