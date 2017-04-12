Shader "Custom/UI/SpookyTextShader"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		
		_StencilComp ("Stencil Comparison", Float) = 8
		_Stencil ("Stencil ID", Float) = 0
		_StencilOp ("Stencil Operation", Float) = 0
		_StencilWriteMask ("Stencil Write Mask", Float) = 255
		_StencilReadMask ("Stencil Read Mask", Float) = 255

		_ColorMask ("Color Mask", Float) = 15

		_NoiseTex("Noise texture", 2D) = "white"{}
		_TextHeight("Text Height", Float) = 20

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
	}

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}
		
		Stencil
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp] 
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
		}

		Cull Off
		Lighting Off
		ZWrite Off
		ZTest [unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask [_ColorMask]

		Pass
		{
			Name "Default"
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			#pragma multi_compile __ UNITY_UI_ALPHACLIP
			
			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				float2 texcoord  : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};
			
			float _TextHeight;
			fixed4 _Color;
			fixed4 _TextureSampleAdd;
			float4 _ClipRect;
			sampler2D _NoiseTex;

			// quill18's tutorial
			float4 spookyText(appdata_t IN)
			{
				float magnitudeOfSpookyness = 10;
				return float4( 
								tex2Dlod(_NoiseTex, float4( IN.vertex.y / 10 + _Time[0] , 0 , 0 , 0 ) ).r , 
								tex2Dlod(_NoiseTex, float4( 0 , IN.vertex.x / 10 + _Time[0] , 0 , 0 ) ).r, 
								0,
								0
								) * magnitudeOfSpookyness;
			}

			float4 periodicUpDownText(appdata_t IN)
			{
				float time = _Time[2];
				float magnitude = 10;
				return float4
				(
					IN.vertex.x,
					IN.vertex.y + sin(time) * magnitude,
					0,
					0
				);
			}

			float4 shakeyToStopText(appdata_t IN)
			{
				float time = 200*_Time[3];
				_TextHeight = _TextHeight - _Time[2]*_Time[2];

				// not the best way but all right.
				if(_TextHeight > 0.1)
				{
					_TextHeight = _TextHeight - _Time[2]*_Time[2];
				}
				else if(_TextHeight <= 0.1)
				{
					_TextHeight = 0.1;
				}
					
				
				return float4
				(
					IN.vertex.x,
					IN.vertex.y + (time % _TextHeight),
					0,
					0
				);
			}

			v2f vert(appdata_t IN)
			{
				v2f OUT;

				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);


				OUT.worldPosition = shakeyToStopText(IN);
				//OUT.worldPosition = IN.vertex;
				OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

				OUT.texcoord = IN.texcoord;
				
				OUT.color = IN.color * _Color;
				return OUT;
			}

			sampler2D _MainTex;

			fixed4 frag(v2f IN) : SV_Target
			{
				half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;
				
				color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
				
				#ifdef UNITY_UI_ALPHACLIP
				clip (color.a - 0.001);
				#endif

				return color;
			}
		ENDCG
		}
	}
}
