// very basic data structures for simple shaders that don't need anything special
#ifndef __DATA_STRUCTURES__
#define __DATA_STRUCTURES__

// per vertex mesh data to be fed into the Vertex function
// also appdata is a terrible name
struct MeshData
{
    float4 vertex: POSITION;
    float2 uv: TEXCOORD0;

    #ifdef _NEEDS_NORMAL
        float3 normal: NORMAL0;
    #endif
};

// Interpolators getting passed around
struct Interpolators
{
    // sadly I have to call it pos because that's the only variable name
    // the unity lighting macro seems to accept :<
    float4 pos: SV_POSITION;
    float2 uv: TEXCOORD0;

    #ifdef _NEEDS_WORLD_POSITION
        float4 worldPosition: TEXCOORD6;
    #endif

    #ifdef _NEEDS_VIEW_DIRECTION
        float3 viewDirection: TEXCOORD7;
    #endif

    #ifdef _NEEDS_GRAB_UV
        float4 grabUV: TEXCOORD1;
    #endif

    #ifdef _NEEDS_NORMAL
        float3 worldNormal: NORMAL0;
    #endif

    #ifdef _NEEDS_LIGHTING_DATA
        LIGHTING_COORDS(4, 5)
    #endif

    #ifdef _NEEDS_VERTEX_NORMAL
        float3 vertexNormal: NORMAL1;
    #endif

    #ifdef _USES_GEOMETRY
        float3 edgeDistance: TEXCOORD3;
    #endif
};

#endif