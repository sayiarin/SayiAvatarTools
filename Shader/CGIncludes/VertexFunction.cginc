#include "DataStructures.cginc"

VertexData VertexFunction(MeshData meshData)
{
	VertexData output;
	output.vertex = UnityObjectToClipPos(meshData.vertex);
	output.uv = meshData.uv;

	// grabby grab 
	#ifdef _NEEDS_GRAB_UV
		output.grabUV = ComputeGrabScreenPos(output.vertex);
	#endif

	// convert normals to world normals because that's where light comes from
	// and we want to use them for shadows
	#ifdef _USES_LIGHTING
		output.worldNormal = UnityObjectToWorldNormal(meshData.normal);
		output.viewDirection = WorldSpaceViewDir(meshData.vertex);
		// receiving shadows
		TRANSFER_SHADOW(o);
	#endif

	return output;
}