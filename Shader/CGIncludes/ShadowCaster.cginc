struct Interpolators
{
    V2F_SHADOW_CASTER;
};

Interpolators Vertex(appdata_base v)
{
    Interpolators output;
    TRANSFER_SHADOW_CASTER_NORMALOFFSET(output)
    return output;
}

float4 Fragment(Interpolators fragIn) : SV_TARGET
{
    SHADOW_CASTER_FRAGMENT(fragIn);
}