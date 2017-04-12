// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PostEffectShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;

			// distort vision
			float2 distortVision(v2f i)
			{
				float distortionAmt = 100; // low - most distortion, high - less distortion
				float time = _Time[3];

				return float2(
								cos( (i.vertex.x + time) )/distortionAmt, 
								sin( (i.vertex.y + time) )/distortionAmt
							 );
			} 

			//give objects jagged edges
			float2 jaggedEdges(v2f i)
			{
				float distortionAmt = 500;
				float jaggedAmt = 1 ;

				return float2(
								cos( i.vertex.y/jaggedAmt )/ distortionAmt , 
								sin( i.vertex.x/jaggedAmt ) / distortionAmt   
							 );
			}

			// pulsing distortion vision
			float2 pulsingDistortion(v2f i)
			{
				float pulseTiming = ( 50 * _Time[1] )% 30; // 50 - speed up time amt.
				float distortionStartAmt = 50;
				float amtOfDistortionInTheEnd = 50;
				float waviness = 0.2;

				return float2( 
								cos(i.vertex.y / waviness)/( distortionStartAmt + amtOfDistortionInTheEnd * pulseTiming) , 
								sin(i.vertex.x / waviness)/( distortionStartAmt +  amtOfDistortionInTheEnd * pulseTiming) 
							 );
			}

			float2 shrinkExpandVertically(v2f i)
			{
				float propagationAmt = 20; // low - more waviness, high - less waviness
				float distortionOfTheObjectsAmt = 50;

				return float2(0, cos(i.vertex.y/distortionOfTheObjectsAmt + _Time[3])/propagationAmt );
			}

			float2 shrinkExpandHorizontally(v2f i)
			{
				float propagationAmt = 100; // low - more waviness, high - less waviness
				float distortionOfTheObjectsAmt = 25;

				return float2(sin(i.vertex.x/distortionOfTheObjectsAmt + _Time[3])/propagationAmt, 0 );
			}

			float2 shrinkExpandBothDirections(v2f i)
			{
				float propagationAmt = 100; // low - more waviness, high - less waviness
				float distortionOfTheObjectsAmt = 25;
				
				return float2(
								sin(i.vertex.x/distortionOfTheObjectsAmt + _Time[1])/propagationAmt, 
								cos(i.vertex.y/distortionOfTheObjectsAmt + _Time[3])/propagationAmt 
						     );
			}

			float2 waveVision(v2f i)
			{
				float propagationAmt = 100; // low - more waviness, high - less waviness
				float distortionOfTheObjectsAmt = 100;

				return float2(
								sin(i.vertex.y/distortionOfTheObjectsAmt + _Time[1])/propagationAmt, 
								cos(i.vertex.x/distortionOfTheObjectsAmt + _Time[3])/propagationAmt 
						     );
			}
			

			fixed4 frag (v2f i) : SV_Target
			{
				//float2 invertScreen = 1 - i.uv;

				fixed4 col = tex2D( _MainTex, i.uv );
				
				// just invert the colors
				//scol = 1 - col;
				col.r = 0.96; // make the world nice a pink like real life
				
				return col;
			}
			ENDCG
		}
	}
}
