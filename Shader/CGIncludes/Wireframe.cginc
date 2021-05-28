// wirey frame

uniform float4 _WireframeColour;
uniform float _WireframeWidth;
uniform float _WireframeFadeOutDistance;

float4 ApplyWireframeColour(float4 colour, Interpolators interpolators, float3 normal)
{
    float3 distance = interpolators.edgeDistance;
    float wireframeAlpha = min(distance.x, min(distance.y, distance.z));
    float distanceToCamera = length(interpolators.worldPosition - _WorldSpaceCameraPos);

    // adjust wireframe width depending on distance to camera so the lines get thinner when camera comes closer
    float wireframeWidth = _WireframeWidth * saturate(distanceToCamera);
    
    // so it changes thiccness depending on distance
    wireframeAlpha *= interpolators.pos.w;
    // thiccness in general
    wireframeAlpha = exp2(-1 / wireframeWidth * wireframeAlpha * wireframeAlpha);
    // round the value so we get a sharp edge and not some washed out lines
    wireframeAlpha = round(saturate(wireframeAlpha));

    // fadeout the wireframe depending on the camera distance from the object and the specified fade out distance
    wireframeAlpha *= (_WireframeFadeOutDistance - distanceToCamera);
    wireframeAlpha = saturate(wireframeAlpha);

    // apply wireframe colour if wireframe is to be rendered here
    float4 wireframeColour = lerp(float4(abs(normal).xyz, 1), _WireframeColour, _WireframeColour.a);
    colour = lerp(colour, wireframeColour, wireframeAlpha);

    return colour;
}