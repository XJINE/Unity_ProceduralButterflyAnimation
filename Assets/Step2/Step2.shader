Shader "Unlit/Step2"
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
            #include "Assets/Packages/Math.cginc/Math.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv     : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4    _MainTex_ST;
            float4    _Color;

            v2f vert (appdata v)
            {
                v2f o;

                // (1) Make Pose.

                // v.vertex.xyz
                // = mul(v.vertex.xyz, RotationMatrixZ(DegreeToRadian(v.vertex.x < 0 ? 45 : -45)));

                // (2) Make Animation.

                float time  = _Time.y * 5;
                float angle = lerp(-80, 60, abs(sin(time))) * (v.vertex.x < 0 ? -1 : 1);

                v.vertex.xyz
                = mul(v.vertex.xyz, RotationMatrixZ(DegreeToRadian(angle)));

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv     = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                i.uv.y *= -1;

                fixed4 color = tex2D(_MainTex, i.uv) * _Color;
                
                if(color.a == 0)
                {
                    discard;
                }

                return color;
            }

            ENDCG
        }
    }
}