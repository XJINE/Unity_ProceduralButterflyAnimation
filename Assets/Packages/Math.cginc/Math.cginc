#ifndef XJ_MATH_INCLUDED
#define XJ_MATH_INCLUDED

#define PI 3.14159265358979

float3x3 RotationMatrixAxis(float radians, float3 axis)
{
    float _sin, _cos;
    sincos(radians, _sin, _cos);

    float t = 1 - _cos;
    float x = axis.x;
    float y = axis.y;
    float z = axis.z;

    return float3x3(t * x * x + _cos,      t * x * y - _sin * z,  t * x * z + _sin * y,
                    t * x * y + _sin * z,  t * y * y + _cos,      t * y * z - _sin * x,
                    t * x * z - _sin * y,  t * y * z + _sin * x,  t * z * z + _cos);
}

float3x3 RotationMatrixX(float radians)
{
    float _sin, _cos;
    sincos(radians, _sin, _cos);

    return float3x3(1,    0,     0,
                    0, _cos, -_sin,
                    0, _sin,  _cos);
}

float3x3 RotationMatrixY(float radians)
{
    float _sin, _cos;
    sincos(radians, _sin, _cos);

    return float3x3(_cos, 0, -_sin,
                       0, 1,     0,
                    _sin, 0,  _cos);
}

float3x3 RotationMatrixZ(float radians)
{
    float _sin, _cos;
    sincos(radians, _sin, _cos);

    return float3x3(_cos, -_sin,  0,
                    _sin,  _cos,  0,
                       0,     0,  1);
}

float DegreeToRadian(float degree)
{
    return degree * 0.01744;
}

float RadianToDegree(float radian)
{
    return radian * 57.3248;
}

float Random(float2 coordinate, int Seed)
{
    return frac(sin(dot(coordinate.xy, float2(12.9898, 78.233)) + Seed) * 43758.5453);
}

#endif // XJ_MATH_INCLUDED