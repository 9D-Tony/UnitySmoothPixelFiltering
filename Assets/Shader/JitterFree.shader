Shader "Unlit/JitterFreeShader"
{
    Properties
    {
        _MainTex("Sprite Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
			float4 _MainTex_TexelSize;
            float4 _MainTex_ST;
			
			float4 texturePointSmooth(sampler2D tex, float2 uvs) {
			float2 size;
			size.x = _MainTex_TexelSize.z;
			size.y = _MainTex_TexelSize.w;
			 
			float2 pixel = float2(1.0,1.0) / size;
			
			uvs -= pixel * float2(0.5,0.5);
			float2 uv_pixels = uvs * size;
			float2 delta_pixel = frac(uv_pixels) - float2(0.5,0.5);
			
			float2 ddxy = fwidth(uv_pixels);
			float2 mip = log2(ddxy) - 0.5;
			
			float2 clampedUV = uvs + (clamp(delta_pixel / ddxy, 0.0, 1.0) - delta_pixel) * pixel;
			
			float scale = exp2(min(mip.x, mip.y));
			
			return tex2Dlod(tex, float4(clampedUV,0, min(mip.x, mip.y)));
			}

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
				 fixed4 col = texturePointSmooth(_MainTex, i.uv);
				
				
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
				
				
				
				
            }
			
            ENDCG
        }
    }
}
