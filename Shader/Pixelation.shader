Shader "Sayiarin/Pixelation"
{
	Properties
	{
		_PixelSizeX("Pixel Size X Axis", float) = 0.005
		_PixelSizeY("Pixel Size Y Axis", float) = 0.005
	}

	SubShader
	{
		Tags
		{
			"RenderType" = "Opaque"
			"Queue" = "Transparent"
		}

		LOD 100
		Cull Off

		GrabPass { "_GrabbedTexture"}

		Pass
		{
			CGPROGRAM
			#pragma vertex VertexFunction
			#pragma fragment Fragment

			#define _NEEDS_GRAB_UV

			#include "UnityCG.cginc"
			#include "CGIncludes/VertexFunction.cginc"

			float _PixelSizeX;
			float _PixelSizeY;
			sampler2D _GrabbedTexture;

			float4 Fragment(Interpolators fragIn) : COLOR
			{
				float2 distortionValues = float2(_PixelSizeX, _PixelSizeY);
				float2 pixelation = fragIn.grabUV.xy / fragIn.grabUV.w;
				pixelation /= distortionValues;
				pixelation = round(pixelation);
				pixelation *= distortionValues;
				return tex2D(_GrabbedTexture, pixelation);
			}
			ENDCG
		}
	}
}