// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "MyDemo/DiffuseDemo_1"
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
				float3 normal : NORMAL;	//法线信息
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 color : COLOR0;
				fixed3 worldNormal : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Diffuse;
			
			v2f vert (a2v v)
			{
				v2f o;
				//坐标转换到摄象机裁剪坐标
				o.pos = UnityObjectToClipPos(v.vertex);
				//法线信息转换到世界坐标
				o.worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//法线信息转换到世界坐标
				fixed3 worldNormal = normalize(i.worldNormal);
				//灯光方向 在世界坐标系中
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				//计算漫反射 公式
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));

				fixed3 color = ambient + diffuse;

				return fixed4(color,1.0);
			}
			ENDCG
		}
	}
}
