Shader "Unlit/Step6"
{
    Properties
    {
        _Color   ("Color",   Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _Speed   ("Speed",   Range(0, 15)) = 5
        _Flap    ("(FrapAngleMin, FrapAngleMax, FlapBendMin, FlapBendMax)", Vector) = (-80, 60, 0, 10)
        _ZBend   ("(ZBendForward, ZBendBackwardMin, ZBendBackwardMax)", Vector) = (5, 0, 10, 0)
        _Updown  ("Updaown", Range(0, 10)) = 1
        _Tilt    ("(TiltForward, TiltBackward, TiltWhole)", Vector) = (40, 10, 20, 0)
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
            #include "Assets/Packages/NoiseShader/HLSL/ClassicNoise2D.hlsl"

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

            float  _Speed;
            float4 _Flap;
            float4 _ZBend;
            float  _Updown;
            float4 _Tilt;

            v2f vert (appdata v)
            {
                v2f o;

                float noiseT = cnoise(_Time.y);
                float noiseA = abs(noiseT);
                float noiseB = abs(cnoise(-_Time.y));
                float time   = _Time.y * _Speed + noiseT * 0.5;

                float flapAngle = lerp(_Flap.x, _Flap.y, abs(sin(time)));

                float angle = flapAngle
                            + (v.vertex.z < 0 || flapAngle < -60 ?
                            0 : lerp(_Flap.z, _Flap.w, pow(abs(v.vertex.x) / 5, 2)) * sin(time * 2 + 1.2));
                      angle *= v.vertex.x < 0 ? -(1 + noiseA) : (1 + noiseB);

                // Flapping (X-Waving)

                v.vertex.xyz = mul(v.vertex.xyz, RotationMatrixZ(DegreeToRadian(angle)));

                // Z-Waving

                float zBendAngleForward  = _ZBend.x * sin((v.vertex.z + time * 4) * 0.5);
                                         + v.vertex.x < 0 ? noiseA : noiseB;
                float zBendAngleBackward = lerp(_ZBend.y, _ZBend.z, pow(abs(v.vertex.z) / 5, 2)) * abs(sin(_Time.y));
                                         + v.vertex.x < 0 ? noiseA : noiseB;
                v.vertex.xyz = (v.vertex.z < 0) ?
                                mul(v.vertex.xyz, RotationMatrixX(DegreeToRadian(zBendAngleBackward))):
                                mul(v.vertex.xyz, RotationMatrixX(DegreeToRadian(zBendAngleForward)));

                // Rotation

                angle = DegreeToRadian(v.vertex.z < 0.2 ? _Tilt.y : _Tilt.x) * abs(sin(time));
                v.vertex.xyz = mul(v.vertex.xyz, RotationMatrixX(angle));

                angle = DegreeToRadian(_Tilt.z) * abs(sin(time));
                v.vertex.xyz = mul(v.vertex.xyz, RotationMatrixX(angle));

                // Updown

                v.vertex.y += sin(time * -2) * (_Updown + noiseA);

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
                //float noise = abs(sin(cnoise(i.uv + _Time.y / 10)));
                //return fixed4(noise,0,0,1);
                
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