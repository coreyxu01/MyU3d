// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "MyDemo/DiffuseDemo"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Diffuse("Diffuse",Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 color : COLOR0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Diffuse;
			
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				//Get ambient term
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//Transform the normal fram object space to world space
				fixed3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
				//Get the light direction in world space
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				//Compute diffuse term
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));

				o.color = ambient + diffuse;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return fixed4(i.color,1.0);
			}
			ENDCG
		}
	}
}
