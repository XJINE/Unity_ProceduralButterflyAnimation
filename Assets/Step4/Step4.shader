Shader "Unlit/Step4"
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

                float time = _Time.y * 5;

                float angle = lerp(-80, 60, abs(sin(time)));
                      angle += v.vertex.z < 0 ?
                               0 : lerp(0, 10, pow(abs(v.vertex.x) / 5, 2)) * sin(time * 2 + 1.2);
                      angle *= v.vertex.x < 0 ? -1 : 1;

                // Flapping (X-Waving)

                v.vertex.xyz = mul(v.vertex.xyz, RotationMatrixZ(DegreeToRadian(angle)));

                // Z-Waving

                v.vertex.xyz = v.vertex.z < 0 ?
                                v.vertex.xyz:
                                mul(v.vertex.xyz, RotationMatrixX(DegreeToRadian(5 * sin((v.vertex.z + time * 4) * 0.5))));

                // Rotation

                angle = DegreeToRadian(40) * abs(sin(time));
                v.vertex.xyz = mul(v.vertex.xyz, RotationMatrixX(angle));

                // Updown

                v.vertex.y += sin(time * -2);

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