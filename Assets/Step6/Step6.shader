Shader "Unlit/Step6"
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

                float2 baseAngleRange = float2(-80, 60);
                float2 bendRange      = float2(0, 10);
                float2 zBendRangeF    = float2(0, 10);
                float  zBendRangeB    = 5;
                float  tiltAngleRange = 20;

                float time = _Time.y * 2;

                float baseAngle = lerp(-80, 60, abs(sin(time)));

                float angle = baseAngle
                            +(v.vertex.z < 0 || baseAngle < -60 ?
                            0 : lerp(0, 10, pow(abs(v.vertex.x) / 5, 2)) * sin(time * 2 + 1.2));
                      angle *= v.vertex.x < 0 ? -1 : 1;

                // Flapping (X-Waving)
                v.vertex.xyz = mul(v.vertex.xyz, RotationMatrixZ(DegreeToRadian(angle)));

                // Z-Waving
                v.vertex.xyz = (v.vertex.z < 0) ?
                                mul(v.vertex.xyz, RotationMatrixX(DegreeToRadian(lerp(0, 10, pow(abs(v.vertex.z) / 5, 2)) * abs(sin(_Time.y))))):
                                mul(v.vertex.xyz, RotationMatrixX(DegreeToRadian(5 * sin((v.vertex.z + time * 4) * 0.5))));

                // Updown
                v.vertex.y += sin(time * -2);

                // Rotation
                angle = DegreeToRadian(v.vertex.z < 0.2 ? 10 : 40) * abs(sin(time));
                v.vertex.xyz = mul(v.vertex.xyz, RotationMatrixX(angle));

                angle = DegreeToRadian(20) * abs(sin(time));
                v.vertex.xyz = mul(v.vertex.xyz, RotationMatrixX(angle));

                // Noisy Move & Rotatoin.
                v.vertex.x += sin(_Time.y);
                v.vertex.z += cos(_Time.w);
                v.vertex.xyz = mul(v.vertex.xyz, RotationMatrixY(DegreeToRadian(10 * sin(_Time.y) * cos(_Time.w))));
                v.vertex.xyz = mul(v.vertex.xyz, RotationMatrixZ(DegreeToRadian(10 * sin(_Time.w) * cos(_Time.y))));

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