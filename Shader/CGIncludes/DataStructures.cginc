// very basic data structures for simple shaders that don't need anything special
#ifndef __DATA_STRUCTURES__
#define __DATA_STRUCTURES__

// per vertex mesh data to be fed into the Vertex function
// also appdata is a terrible name
struct MeshData
{
    float4 vertex: POSITION;
    float2 uv: TEXCOORD0;

    #ifdef _USES_LIGHTING
        float3 normal: NORMAL0;
    #endif
};

// datatype to pass from Vertex to Fragment function
struct VertexData
{
    float4 vertex: SV_POSITION;
    float2 uv: TEXCOORD0;

    #ifdef _NEEDS_GRAB_UV
        float4 grabUV: TEXCOORD1;
    #endif

    #ifdef _USES_LIGHTING
        float3 worldNormal: NORMAL0;
        float3 viewDirection: TEXCOORD2;
        // to receive shadows
        SHADOW_COORDS(2)
    #endif
};

#endif