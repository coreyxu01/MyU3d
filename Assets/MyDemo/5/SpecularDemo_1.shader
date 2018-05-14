// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/SpecularDemo_1"
{
	Properties
	{
		_Diffuse ("Diffuse",Color) = (1,1,1,1)
		_Specular ("Specular",Color) = (1,1,1,1)
		_Gloss ("Gloss",Range(8.0,256)) = 20
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
				fixed3 worldNormal:TEXCOORD0;
				float3 worldPos:TEXCOORD1;
			};

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
			
			v2f vert (a2v v)
			{
				v2f o;
				//坐标转换到摄象机裁剪坐标
				o.pos = UnityObjectToClipPos(v.vertex);
				//法线信息转换到世界坐标
				o.worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
				//世界坐标
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				//灯光方向 在世界坐标系中
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				//计算漫反射 公式
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(i.worldNormal,worldLightDir));
				//反射光方向
				fixed3 reflectDir = normalize(reflect(-worldLightDir,i.worldNormal));
				//观察者角度
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
				//镜面反射
				fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(saturate(dot(reflectDir,viewDir)),_Gloss);
				//融合
				fixed3 color = ambient + diffuse + specular;

				return fixed4(color,1.0);
			}
			ENDCG
		}
	}
}
