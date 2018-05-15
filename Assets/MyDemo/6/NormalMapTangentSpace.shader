Shader "MyDemo/NormalMapTangentSpace"
{
	Properties
	{
		_ColorTint ("Color Tint",Color) = (1,1,1,1)
		_MainTex ("Main Tex",2D) = "white" {}
		_BumpMap ("Normal Map",2D) = "bump" {}
		_BumpScale ("Bump Scale",Float) = 1.0
		_Specular ("Specular",Color) = (1,1,1,1)
		_Gloss ("Gloss",Range(8.0,256)) = 20
	}
	SubShader
	{
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed4 _ColorTint;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

			struct a2v
			{
				float4 vertex : POSITION;//顶点坐标
				float3 normal : NORMAL;	//法线信息
				float4 tanget : TANGENT;//切线信息
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};

			
			v2f vert (a2v v)
			{
				v2f o;
				//坐标转换到摄象机裁剪坐标
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				//法线信息转换到世界坐标
				//o.worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				//切线信息转换到世界坐标
				fixed3 worldTangent = UnityObjectToWorldDir(v.tanget.xyz);
				fixed3 worldBinormal = cross(worldNormal,worldTangent) * v.tanget.w;
				float3x3 worldToTangent = float3x3(worldTangent,worldBinormal,worldNormal);
				o.lightDir = mul(worldToTangent,WorldSpaceLightDir(v.vertex));
				o.viewDir = mul(worldToTangent,WorldSpaceViewDir(v.vertex));

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);
				fixed4 packedNormal = tex2D(_BumpMap,i.uv.zw);
				fixed3 tangentNormal;
				tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));
				fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _ColorTint.rgb;
				//环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				//计算漫反射 公式
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));
				//新的矢量
				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
				//镜面反射
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);
				//融合
				fixed3 color = ambient + diffuse + specular;
				return fixed4(color,1.0);
			}
			ENDCG
		}
	}
}
