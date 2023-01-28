Shader "Sprites/JitterFreeUnlit"
{
    Properties
    {
        [PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
        _Color("Tint", Color) = (1,1,1,1)
    }
        SubShader
        {
            Tags
            {
                "Queue" = "Transparent"
                "IgnoreProjector" = "True"
                "RenderType" = "Transparent"
                "PreviewType" = "Plane"
                "CanUseSpriteAtlas" = "True"
            }

            Cull Off
            Lighting Off
            ZWrite Off
            Blend One OneMinusSrcAlpha

            Pass
            {
                Blend SrcAlpha OneMinusSrcAlpha
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"

                struct appdata_t
                {
                    float4 vertex : POSITION;
                    fixed4 color : COLOR;
                    float2 texcoord : TEXCOORD0;
                };

                struct v2f
                {
                    float4 vertex : SV_POSITION;
                    float2 texcoord : TEXCOORD0;
                    fixed4 color : COLOR;
                };

                fixed4 _Color;

                v2f vert(appdata_t IN)
                {
                    v2f OUT;
                    OUT.vertex = UnityObjectToClipPos(IN.vertex);
                    OUT.texcoord = IN.texcoord;
                    OUT.color = IN.color * _Color;
                    return OUT;
                }

                sampler2D _MainTex;
                float4 _MainTex_TexelSize;
                float4 _MainTex_ST;

                float4 texturePointSmooth(sampler2D tex, float2 uvs)
                {
                    uvs -= float2(_MainTex_TexelSize.x,_MainTex_TexelSize.y) * float2(0.5,0.5);
                    float2 uv_pixels = uvs * float2(_MainTex_TexelSize.z,_MainTex_TexelSize.w);
                    float2 delta_pixel = frac(uv_pixels) - float2(0.5,0.5);

                    float2 ddxy = fwidth(uv_pixels);
                    float2 mip = log2(ddxy) - 0.5;

                    float2 clampedUV = uvs + (clamp(delta_pixel / ddxy, 0.0, 1.0) - delta_pixel) * float2(_MainTex_TexelSize.x,_MainTex_TexelSize.y);
                    return tex2Dlod(tex, float4(clampedUV,0, min(mip.x, mip.y)));
                }

                fixed4 frag(v2f IN) : SV_Target
                {
                    fixed4 c = texturePointSmooth(_MainTex, IN.texcoord) * IN.color;
                    return c;
                }

                ENDCG
            }
        }
}
