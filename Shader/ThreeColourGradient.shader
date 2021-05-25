Shader "Sayiarin/ThreeColourGradient"
{
	Properties
	{
		[HDR]_FirstColour("1st Colour", Color) = (0, 0, 0, 0)
		[HDR]_SecondColour("2nd Colour", Color) = (0, 0, 0, 0)
		[HDR]_ThirdColour("3rd Colour", Color) = (0, 0, 0, 0)
		_CenterPosition("Middle Colour Position", Range(0, 1)) = 0.5
		[Space]
		_FirstColourStart("1st Colour Start Position", Range(0, 1)) = 0
		_FirstColourEnd("1st Colour End Position", Range(0, 1)) = 1
		[Space]
		_SecondColourStart("2nd Colour Start Position", Range(0, 1)) = 0
		_SecondColourEnd("2nd Colour End Position", Range(0, 1)) = 1
	}

	SubShader
	{
		Tags 
		{
			"RenderType" = "Opaque"
			"IsEmissive" = "true"
		}

		Cull Back

		Pass 
		{
			CGPROGRAM
			#pragma vertex VertexFunction
			#pragma fragment Fragment

			#include "UnityCG.cginc"
			#include "CGIncludes/DataStructures.cginc"
			#include "CGIncludes/VertexFunction.cginc"

			uniform float4 _FirstColour;
			uniform float4 _SecondColour;
			uniform float4 _ThirdColour;
			uniform float _CenterPosition;
			uniform float _FirstColourStart; 
			uniform float _FirstColourEnd;
			uniform float _SecondColourStart;
			uniform float _SecondColourEnd;

			float InverseLerp(float a, float b, float value)
			{
				return (value - a) / (b - a);
			}

			fixed4 Fragment(VertexData fragIn) : COLOR
			{
				if(fragIn.uv.x < _CenterPosition)
				{
					// saturate() clamps values, wtf
					float colourTransitionWeight = saturate(InverseLerp(_FirstColourStart, _FirstColourEnd, fragIn.uv.x / _CenterPosition));
					return lerp(_FirstColour, _SecondColour, colourTransitionWeight);
				}
				else
				{
					float colourTransitionWeight = saturate(InverseLerp(_SecondColourStart, _SecondColourEnd, (fragIn.uv.x - _CenterPosition) / _CenterPosition));
					return lerp(_SecondColour, _ThirdColour, colourTransitionWeight);
				}
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
} 
