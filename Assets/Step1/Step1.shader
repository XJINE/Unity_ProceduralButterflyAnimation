Shader "Unlit/Step1"
{
    Properties
    {
        _Color   ("Color", COLOR) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D)  = "white" {}
    }

    SubShader
    {
        Tags
        {
            "Queue"      = "AlphaTest"
            "RenderType" = "TransparentCutout"
        }

        Cull Off
        AlphaToMask On

        Pass
        {
            CGPROGRAM

            #pragma  vertex   vert
            #pragma  fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv     : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4    _MainTex_ST;
            float4    _Color;

            v2f vert (appdata v)
            {
                v2f o;

                // NOTE:
                // Check object-space coordinate.

                if(v.vertex.z ==  0) { v.vertex.x = 0; }
                if(v.vertex.z ==  5) { v.vertex.x = 0; }
                if(v.vertex.z == -5) { v.vertex.x = 5; }

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv     = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv) * _Color;
                return color;
            }

            ENDCG
        }
    }
}