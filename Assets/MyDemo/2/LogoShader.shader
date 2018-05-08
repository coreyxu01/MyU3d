Shader "MyDemo/LogoShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags
		 {
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}

		// No culling or depth
		Cull Off 
		ZWrite Off 
		ZTest Off
		Blend SrcAlpha OneMinusSrcAlpha
        AlphaTest Greater 0.1

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
			float4 _MainTex_ST;

			float inFlash(float angle,float2 uv,float xLength,int interval,int beginTime,float offX,float loopTime)
			{
				//亮度值
				float brightness = 0;	
				//斜角度
				float angleInRad = 0.0174444 * angle;
				//当前时间
				float currentTime = _Time.y;
				//获取本次闪光起始时间
				int currentTimeInt = _Time.y/interval;
				currentTimeInt*= interval;

				float currentTimePassed = currentTime - currentTimeInt;
				if(currentTimePassed > beginTime)
				{
					//底部左边界和右边界
					float xBottomLeftBound;
					float xBottomRightBound;

					//此点边界
					float xPointLeftBound;
					float xPointRightBound;

					float x0 = currentTimePassed - beginTime;
					x0 /= loopTime;

					//设置右边界
					xBottomRightBound = x0;
					//设置左边界
					xBottomLeftBound = x0 - xLength;

					//投影至x的长度 = y/tan(angle)
					float xProjL;
					xProjL = (uv.y)/tan(angleInRad);

					//此点的左边界 = 底部左边界 - 投影至x的长度
					xPointLeftBound = xBottomLeftBound - xProjL;
					//此点的右边界 = 底部右边界 - 投影至x的长度
					xPointRightBound = xBottomRightBound - xProjL;

					//边界加上一个偏移
					xPointLeftBound += offX;
					xPointRightBound += offX;

					//如果该点在区域内
					if(uv.x > xPointLeftBound && uv.x < xPointRightBound)
					{
						//得到发光区域的中心点
						float midness = (xPointLeftBound + xPointRightBound)/2;
						//趋近中心点的程度，0表示位于边缘，1表示位于中心
						float rate = (xLength - 2*abs(uv.x - midness)) / xLength; 
						brightness = rate;
					}					
				}
				brightness = max(brightness,0);
				
				//返回颜色 = 纯白色 * 亮度
				float4 coi = float4(1,1,1,1) * brightness;
				return brightness;
			}

			float4 frag (v2f i) : COLOR
			{
				float4 outCol;
				float4 col = tex2D(_MainTex, i.uv);
				//传入i.uv等参数，得到亮度值
				float tempBrightness = inFlash(75 , i.uv , 0.25 , 5 , 2 , 0.15 , 0.7);
				//图像区域，判断设置颜色A>0.5 , 输出为材质颜色 + 光亮值
				if (col.w > 0.5)
				{
					outCol = col + float4(1,1,1,1)*tempBrightness;
				}
				else
				{
					outCol = float4(0,0,0,0);
				}

				return outCol;
			}
			ENDCG
		}
	}
}
