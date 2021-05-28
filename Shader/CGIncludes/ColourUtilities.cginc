// https://en.wikipedia.org/wiki/HSL_and_HSV
// https://www.programmersought.com/article/59764720552/
// even more confusing now, but it works better now

float3 HSVtoRGB(float3 c)
{
    float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
    float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
    return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
}

float3 RGBtoHSV(float3 c)
{
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
    float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
    float d = q.x - min( q.w, q.y );
    float e = 1.0e-10;
    return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

float4 ApplyHSVChangesToRGB(float4 colour, float3 hsvChanges)
{
    float3 hsvColour = RGBtoHSV(colour.rgb);
    hsvColour.x += hsvChanges.x;
    hsvColour.y += hsvChanges.y;
    hsvColour.z += hsvChanges.z;
    return float4(HSVtoRGB(hsvColour), colour.a);
}
