float3 GetAlignedWorldPosTexture(Interpolators fragIn)
{    
    float2 uv = (fragIn.worldPosition.xy / fragIn.worldPosition.w) / _WorldPosTextureZoom;
    return tex2D(_WorldPosTexture, uv);
}