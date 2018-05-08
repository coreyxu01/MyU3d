Shader "MyDemo/UVMoveShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_SecTex ("SecTexture",2D) = "white" {}
		_MainSpeed ("MainSpeed",Range(0,1)) = 0.1 
		_SecSpeed ("SecSpeed",Range(0,1)) = 0.2
	}
	SubShader
	{
		Tags
		{
			"Queue" = "Transparent" 
			"RenderType" = "Transparent"
		}
		// No culling or depth
		Cull Off 
		ZWrite Off 
		ZTest Always

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
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _SecTex;
			fixed _MainSpeed;
			fixed _SecSpeed;

			fixed4 frag (v2f i) : SV_Target
			{
				float u_x = i.uv.x - _MainSpeed*_Time;
				float2 uv_earth = float2(u_x,i.uv.y);
				fixed4 main_col = tex2D(_MainTex, uv_earth);
				
				u_x = i.uv.x - _SecSpeed*_Time;
				float2 uv_Sec = float2(u_x,i.uv.y);
				fixed4 sec_col = tex2D(_SecTex,uv_Sec);

				return lerp(main_col,sec_col,0.6);
			}
			ENDCG
		}
	}
}
