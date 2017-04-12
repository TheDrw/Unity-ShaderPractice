// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/KatUnite"
{
	// variables
	Properties
	{
		_MainTex("Main Color (RGB) Hello!", 2D) = "white"{}
		_Color("Kleur", Color) = (1,1,1,1)

		_DissolveTex("Cheese", 2D) = "white"{}
		_DissolveAmt("Cheese cut out amt", Range(0, 1) ) = 1

		_ExtrudeAmt("Extrude amt", float) = 1

	}//properties

	// can have multiple subshaders for separate things
	SubShader
	{
		// can have multiple passes but adds more draw calls
		Pass
		{
			CGPROGRAM
			#pragma vertex vertexFunction // build the object
			#pragma fragment fragmentFunction // paint the object

			#include "UnityCG.cginc"

			// vertices, normal, color, uv
			struct appdata
			{
				//datatype name : type;
				float4 vertex : POSITION; 
				float2 uv: TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
			};//struct

			sampler2D _DissolveTex;
			float _DissolveAmt;
			float _ExtrudeAmt;

			// build obj
			v2f vertexFunction(appdata IN)
			{
				v2f OUT;

				IN.vertex.x += IN.normal.x * _ExtrudeAmt * cos(_Time[3] ); 
				IN.vertex.y += IN.normal.y * _ExtrudeAmt * sin(_Time[1] * 20); 
				//IN.vertex.z += IN.normal.z * _ExtrudeAmt * cos(_Time[2]) * 2; 
				IN.vertex.z += IN.normal.z * _ExtrudeAmt * sin(_Time[2]);

				OUT.position = UnityObjectToClipPos(IN.vertex);
				OUT.uv = IN.uv;

				return OUT;
			}//v2f

			sampler2D _MainTex;
			float4 _Color;

			// color in obj
			fixed4 fragmentFunction(v2f IN) : SV_Target
			{
				float4 textureColor = tex2D(_MainTex, IN.uv);
				float4 dissolveColor = tex2D(_DissolveTex, IN.uv);

				clip(dissolveColor.rgb - _DissolveAmt);

				return textureColor * _Color;
			}//Fixed4

			ENDCG
		}//pass
	}//subshader
}//shader 