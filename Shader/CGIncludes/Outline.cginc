// everything regarding outline
// probably strongly against any best practices to stuff what's basically a 
// full CGPROGRAM  into a cginc file but I want my main shader file to be 
// less cluttered and who's going to stop me, huh? :>
        
#include "UnityCG.cginc"
        
uniform float4 _OutlineColour;
uniform float _OutlineWidth;
        
struct MeshData
{
    float4 vertex: POSITION;
    float3 normal: NORMAL;
};
        
struct VertexData
{
    float4 vertex: SV_POSITION;
    float3 normal: NORMAL;
};
        
VertexData Vertex(MeshData meshData)
{
    VertexData output;
    meshData.vertex.xyz += meshData.normal * _OutlineWidth;
    output.vertex = UnityObjectToClipPos(meshData.vertex);
    output.normal = meshData.normal;
    return output;
}
        
float4 Fragment(VertexData vertexData) : SV_TARGET
{
    return _OutlineColour;
}
