// wirey frame

uniform float4 _WireframeColour;
uniform float _WireframeWidth;

float4 ApplyWireframeColour(float4 colour, Interpolators interpolators, float3 normal)
{
    float3 distance = interpolators.edgeDistance;
    float wireframeAlpha = min(distance.x, min(distance.y, distance.z));
    
    // so it changes thiccness depending on distance
    wireframeAlpha *= interpolators.pos.w;
    // thiccness in general
    wireframeAlpha = exp2(-1 / _WireframeWidth * wireframeAlpha * wireframeAlpha);
    wireframeAlpha = round(wireframeAlpha);

    float4 wireframeColour = lerp(float4(abs(normal).xyz, 1), _WireframeColour, _WireframeColour.a);
    colour = lerp(colour, wireframeColour, saturate(wireframeAlpha));
    return colour;
}