#include "DataStructures.cginc"

float3 DistanceToCenter(float4 vertex1, float4 vertex2, float4 vertex3)
{
    float2 screenSpacePos1 = _ScreenParams.xy * vertex1.xy / vertex1.w;
    float2 screenSpacePos2 = _ScreenParams.xy * vertex2.xy / vertex2.w;
    float2 screenSpacePos3 = _ScreenParams.xy * vertex3.xy / vertex3.w;
    
    float2 edge1 = screenSpacePos3 - screenSpacePos2;
    float2 edge2 = screenSpacePos3 - screenSpacePos1;
    float2 edge3 = screenSpacePos2 - screenSpacePos1;
    
    float area = abs(edge2.x * edge3.y - edge2.y * edge3.x);
    
    float distance1 = area / length(edge1);
    float distance2 = area / length(edge3);
    float distance3 = area / length(edge3);

    return float3(distance1, distance2, distance3);
}

[maxvertexcount(3)]
void GeometryFunction(triangle Interpolators interpolators[3], inout TriangleStream<Interpolators> triangleStream)
{
    if (_EnableWireframe == 1)
    {
        float3 edgeDistance = DistanceToCenter(interpolators[0].pos, interpolators[1].pos, interpolators[2].pos);

        Interpolators output;

        // first vertex
        output = interpolators[0];
        output.edgeDistance = float3(edgeDistance.x, 0, 0);
        triangleStream.Append(output);
    
        // second vertex
        output = interpolators[1];
        output.edgeDistance = float3(0, edgeDistance.y, 0);
        triangleStream.Append(output);
    
        // third vertex
        output = interpolators[2];
        output.edgeDistance = float3(0, 0, edgeDistance.z);
        triangleStream.Append(output);
    }
    else
    {
        // since no geometry feature is enabled we can just pass out data through here
        triangleStream.Append(interpolators[0]);
        triangleStream.Append(interpolators[1]);
        triangleStream.Append(interpolators[2]);
    }
}