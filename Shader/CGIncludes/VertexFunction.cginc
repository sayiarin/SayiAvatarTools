#include "DataStructures.cginc"

Interpolators VertexFunction(MeshData meshData)
{
	Interpolators output;
	output.pos = UnityObjectToClipPos(meshData.vertex);
	output.uv = meshData.uv;

	// grabby grab 
	#ifdef _NEEDS_GRAB_UV
		output.grabUV = ComputeGrabScreenPos(output.pos);
	#endif

	// convert normals to world normals because that's where light comes from
	// and we want to use them for shadows
	#ifdef _USES_LIGHTING
		output.worldNormal = UnityObjectToWorldNormal(meshData.normal);
		TRANSFER_VERTEX_TO_FRAGMENT(output);
 	#endif

	#ifdef _NEEDS_VERTEX_NORMAL
		output.vertexNormal = abs(meshData.normal);
    #endif

	#ifdef _USES_GEOMETRY
		output.edgeDistance = float3(0,0,0);
	#endif

	return output;
}